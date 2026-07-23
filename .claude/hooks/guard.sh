#!/usr/bin/env bash
#
# guard.sh — Guarda determinista de la FDA (hook PreToolUse)
#
# Convierte "límites de modificación por componente" de prosa a código.
# Lee el WP activo en work-packages/ACTIVE y BLOQUEA cualquier escritura sobre
# una ruta que ese WP no permita explícitamente.
#
# Contrato del hook (Claude Code):
#   entrada : JSON por stdin con .tool_name, .tool_input.file_path, .cwd
#   salida  : exit 0 = permitir · exit 2 = BLOQUEAR (stderr se devuelve al agente)
#
# Principio de diseño: FAIL CLOSED. Ante cualquier duda (sin WP activo, WP
# ilegible, sin sección de rutas permitidas) se deniega. Un guard que ante un
# error deja pasar la escritura no es un guard.
#
# Compatible con bash 3.2 (macOS por defecto) y bash 5 (runners de CI).
# Headless: no pregunta nada, no asume TTY, no depende de sesión interactiva.
#
# Depuración:  FDA_GUARD_DEBUG=1  → traza a stderr
# Prueba manual:
#   echo '{"tool_name":"Write","tool_input":{"file_path":"src/x.py"}}' | .claude/hooks/guard.sh; echo "exit=$?"

set -u

ALLOW=0
BLOCK=2

debug() { [ "${FDA_GUARD_DEBUG:-0}" = "1" ] && printf 'guard: %s\n' "$*" >&2; return 0; }

# Deniega con mensaje accionable para el agente.
deny() {
  printf 'BLOQUEADO por la FDA (.claude/hooks/guard.sh)\n\n%s\n' "$1" >&2
  exit $BLOCK
}

# --- 1. Raíz del repositorio -------------------------------------------------
REPO_ROOT="${CLAUDE_PROJECT_DIR:-}"
if [ -z "$REPO_ROOT" ]; then
  REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
fi
[ -z "$REPO_ROOT" ] && REPO_ROOT="$PWD"
debug "repo_root=$REPO_ROOT"

# --- 2. Leer la llamada de herramienta (stdin) -------------------------------
PAYLOAD="$(cat)"
[ -z "$PAYLOAD" ] && exit $ALLOW   # sin payload no hay nada que juzgar

# Extrae un campo del JSON. jq si está; python3 como respaldo.
json_get() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$PAYLOAD" | jq -r "$1 // empty" 2>/dev/null
  else
    printf '%s' "$PAYLOAD" | python3 -c '
import json,sys
try: d=json.load(sys.stdin)
except Exception: sys.exit(0)
path=sys.argv[1].lstrip(".").split(".")
for k in path:
    if not isinstance(d,dict): sys.exit(0)
    d=d.get(k)
    if d is None: sys.exit(0)
print(d)
' "${1%% //*}" 2>/dev/null
  fi
}

TOOL_NAME="$(json_get '.tool_name')"
FILE_PATH="$(json_get '.tool_input.file_path')"
[ -z "$FILE_PATH" ] && FILE_PATH="$(json_get '.tool_input.notebook_path')"
debug "tool=$TOOL_NAME file=$FILE_PATH"

# Herramienta sin ruta asociada: nada que vigilar.
[ -z "$FILE_PATH" ] && exit $ALLOW

# --- 3. Normalizar la ruta a relativa del repo -------------------------------
case "$FILE_PATH" in
  "$REPO_ROOT"/*) REL="${FILE_PATH#"$REPO_ROOT"/}" ;;
  /*)             deny "Ruta fuera del repositorio: $FILE_PATH

La FDA solo permite escrituras dentro del repositorio ($REPO_ROOT).
Si necesitas escribir fuera, es una decisión humana: detente y solicítala." ;;
  ./*)            REL="${FILE_PATH#./}" ;;
  *)              REL="$FILE_PATH" ;;
esac

# Escapes de traversal: se bloquean siempre, sin excepción.
case "$REL" in
  *../*|*/..) deny "Ruta con traversal (..): $FILE_PATH" ;;
esac
debug "rel=$REL"

# --- 4. WP activo ------------------------------------------------------------
ACTIVE_FILE="$REPO_ROOT/work-packages/ACTIVE"

if [ ! -f "$ACTIVE_FILE" ]; then
  deny "No existe work-packages/ACTIVE.

Sin WP activo no hay cambios (CLAUDE.md). Crea el WP, ponlo en estado 'ready'
y escribe su ID en work-packages/ACTIVE antes de editar nada."
fi

# Primera línea no vacía y no comentada.
WP_ID="$(grep -v '^[[:space:]]*#' "$ACTIVE_FILE" 2>/dev/null | grep -v '^[[:space:]]*$' | head -1 | tr -d '[:space:]')"

if [ -z "$WP_ID" ]; then
  deny "work-packages/ACTIVE está vacío.

Escribe el ID del WP en curso (por ejemplo: WP-000) antes de editar nada."
fi
debug "wp_id=$WP_ID"

# --- 5. Localizar el archivo del WP ------------------------------------------
WP_FILE=""
for candidate in "$REPO_ROOT/work-packages/$WP_ID".md "$REPO_ROOT/work-packages/$WP_ID"-*.md; do
  [ -f "$candidate" ] && { WP_FILE="$candidate"; break; }
done

if [ -z "$WP_FILE" ]; then
  deny "work-packages/ACTIVE apunta a '$WP_ID' pero no existe work-packages/$WP_ID*.md

Corrige ACTIVE o crea el work package."
fi
debug "wp_file=$WP_FILE"

# --- 6. Extraer listas de rutas del WP ---------------------------------------
# Toma los items de lista ('- ruta') bajo una cabecera '## <titulo>' hasta la
# siguiente cabecera '##'. Limpia backticks, comentarios inline y espacios.
extract_section() {
  awk -v want="$1" '
    /^##[[:space:]]/ {
      line = $0
      sub(/^##[[:space:]]*/, "", line)
      inside = (index(tolower(line), tolower(want)) == 1)
      next
    }
    inside && /^[[:space:]]*[-*][[:space:]]+/ {
      sub(/^[[:space:]]*[-*][[:space:]]+/, "")
      gsub(/`/, "")
      sub(/[[:space:]]*#.*$/, "")       # comentario inline
      sub(/[[:space:]]*\(.*$/, "")      # anotación entre paréntesis
      gsub(/^[[:space:]]+|[[:space:]]+$/, "")
      if (length($0) > 0 && $0 !~ /^(ninguno|none|n\/a|-)$/) print
    }
  ' "$WP_FILE"
}

ALLOWED="$(extract_section 'Archivos permitidos')"
FORBIDDEN="$(extract_section 'Archivos prohibidos')"

if [ -z "$ALLOWED" ]; then
  deny "El WP activo ($WP_ID) no declara ninguna ruta en '## Archivos permitidos'.

Un WP sin rutas permitidas no cumple la Definition of Ready. No se permite
ninguna escritura hasta que el WP declare su alcance de archivos."
fi

# --- 7. Glob → ERE ------------------------------------------------------------
#   **  → .*        (cruza separadores de directorio)
#   *   → [^/]*     (no cruza /)
#   ?   → [^/]
#
# Implementado en bash puro a propósito: las clases de caracteres de sed
# divergen entre BSD (macOS) y GNU (runners de CI) en el tratamiento de '\'
# dentro de corchetes. Un control de seguridad no puede depender de esa
# diferencia, ni de que sed esté instalado.
glob_to_ere() {
  _in="$1"; _out=""; _i=0; _n=${#_in}
  while [ "$_i" -lt "$_n" ]; do
    _c="${_in:$_i:1}"
    case "$_c" in
      '*')
        if [ "${_in:$((_i+1)):1}" = "*" ]; then
          _out="$_out.*"; _i=$((_i+2)); continue
        fi
        _out="$_out[^/]*"
        ;;
      '?')  _out="$_out[^/]" ;;
      '.'|'^'|'$'|'+'|'('|')'|'{'|'}'|'|'|'['|']'|'\')
            _out="$_out\\$_c" ;;
      *)    _out="$_out$_c" ;;
    esac
    _i=$((_i+1))
  done
  printf '%s' "$_out"
}

# ¿Coincide $1 (ruta) con alguno de los globs de $2 (lista, uno por línea)?
#
# Se itera con 'read' y no con 'for _g in $_globs' a propósito: una variable sin
# comillas en un for sufre pathname expansion, y bash expandiría cada patrón
# contra el disco real ('docs/**' -> 'docs/manual') en vez de tratarlo como
# patrón. El guard compararía entonces contra los archivos que ya existen y no
# contra el contrato del WP: rutas nuevas dentro de alcance se bloquearían y el
# control dejaría de significar lo que dice significar.
matches_any() {
  _path="$1"
  _globs="$2"
  while IFS= read -r _g; do
    [ -z "$_g" ] && continue
    _g="${_g#./}"
    _ere="$(glob_to_ere "$_g")"
    # Un glob que nombra un directorio cubre todo su contenido.
    case "$_g" in
      */) _ere="$_ere.*" ;;
    esac
    if [[ "$_path" =~ ^$_ere$ ]]; then
      debug "match: $_path ~ $_g"
      printf '%s' "$_g"
      return 0
    fi
  done <<EOF
$_globs
EOF
  return 1
}

# --- 8. Veredicto -------------------------------------------------------------
# Prohibido gana sobre permitido, siempre.
if [ -n "$FORBIDDEN" ]; then
  if HIT="$(matches_any "$REL" "$FORBIDDEN")"; then
    deny "Ruta explícitamente PROHIBIDA por $WP_ID: $REL
Coincide con el patrón prohibido: $HIT

Esta ruta está fuera de alcance por decisión del contrato. No busques un rodeo:
si el cambio es necesario, detente y solicita una modificación del WP."
  fi
fi

if HIT="$(matches_any "$REL" "$ALLOWED")"; then
  debug "PERMITIDO $REL (patrón $HIT)"
  exit $ALLOW
fi

# No coincide con nada permitido → bloquear.
deny "Ruta fuera del alcance de $WP_ID: $REL

Rutas permitidas por el WP activo:
$(printf '%s\n' "$ALLOWED" | sed 's/^/  - /')

Qué hacer (CLAUDE.md, regla 3 del implementer): DETENTE y solicita decisión.
No amplíes el alcance por tu cuenta ni edites work-packages/ACTIVE para
esquivar este control. Si el cambio es realmente necesario, el WP está mal
definido y hay que corregirlo explícitamente."
