#!/usr/bin/env bash
#
# guard.sh — Guarda determinista de la FDA (hook PreToolUse)
#
# Convierte "límites de modificación por componente" de prosa a código.
# Lee el WP activo en work-packages/ACTIVE y BLOQUEA cualquier escritura sobre
# una ruta que ese WP no permita explícitamente.
#
# Contrato del hook (Claude Code):
#   entrada : JSON por stdin con .tool_name y .tool_input
#             (.file_path | .notebook_path | .command)
#   salida  : exit 0 = permitir · exit 2 = BLOQUEAR (stderr se devuelve al agente)
#
# Herramientas vigiladas: Edit, Write, MultiEdit, NotebookEdit y **Bash**.
#   El matcher de .claude/settings.json debe incluir las cinco. Si Bash queda
#   fuera, un agente escribe con 'echo x > ruta' y se salta el control entero.
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
#   echo '{"tool_name":"Bash","tool_input":{"command":"echo x > src/y.py"}}' | .claude/hooks/guard.sh; echo "exit=$?"

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
' "$1" 2>/dev/null
  fi
}

TOOL_NAME="$(json_get '.tool_name')"
debug "tool=$TOOL_NAME"

# --- 3. Determinar las rutas objetivo ----------------------------------------
#
# Para Bash se analiza el comando en busca de vectores de escritura. Es
# BEST-EFFORT y NO hermético: el shell es demasiado expresivo para garantizarlo
# (python -c "open(...,'w')", eval, base64, xxd, here-docs con variables...).
# Cubre los vectores triviales, que son los que se dan por descuido. La red de
# seguridad real sigue siendo CI + branch protection + revisión humana.
# Ver docs/manual/07-troubleshooting.md.

# Neutraliza el contenido entrecomillado antes de buscar redirecciones:
# 'git commit -m "arreglar a > b"' no es una escritura a un archivo llamado "b".
dequote() {
  printf '%s' "$1" | sed -e "s/'[^']*'/@FDAQ@/g" -e 's/"[^"]*"/@FDAQ@/g'
}

bash_targets() {
  _c="$1"
  _dq="$(dequote "$_c")"
  {
    # redirecciones sin comillas:  > ruta   >> ruta   (no casa con >&1, 2>&1)
    printf '%s\n' "$_dq" | grep -oE '>>?[[:space:]]*[^[:space:];|&<>()]+' \
      | sed -E 's/^>+[[:space:]]*//'
    # redirecciones con destino entrecomillado (sobre el comando original)
    printf '%s\n' "$_c" | grep -oE '>>?[[:space:]]*"[^"]+"' \
      | sed -E 's/^>+[[:space:]]*"//; s/"$//'
    printf '%s\n' "$_c" | grep -oE ">>?[[:space:]]*'[^']+'" \
      | sed -E "s/^>+[[:space:]]*'//; s/'\$//"
    # tee [-a] ruta
    printf '%s\n' "$_dq" | grep -oE '\btee[[:space:]]+(-a[[:space:]]+)?[^[:space:];|&<>()]+' \
      | sed -E 's/^tee[[:space:]]+(-a[[:space:]]+)?//'
    # edición en sitio: sed -i / perl -i  → último argumento
    printf '%s\n' "$_dq" | grep -oE '\b(sed|perl)[[:space:]]+-i[^;|&]*' | awk '{print $NF}'
    # dd of=ruta
    printf '%s\n' "$_dq" | grep -oE '\bof=[^[:space:];|&]+' | sed 's/^of=//'
    # copia, movimiento, borrado, truncado, enlaces
    printf '%s\n' "$_dq" \
      | grep -oE '\b(cp|mv|rm|rmdir|truncate|touch|install|shred|ln)[[:space:]]+[^;|&]+' \
      | sed -E 's/^[a-z]+[[:space:]]+//' | tr ' ' '\n' | grep -vE '^-'
  } 2>/dev/null | grep -vE '^(@FDAQ@)?$' | sort -u
}

# Destinos que no son archivos del repositorio: no son asunto de este control.
is_exempt() {
  case "$1" in
    /dev/null|/dev/stdout|/dev/stderr|/dev/tty|/dev/fd/*) return 0 ;;
    /tmp/*|/private/tmp/*|/var/tmp/*|/var/folders/*)      return 0 ;;
  esac
  if [ -n "${TMPDIR:-}" ]; then
    case "$1" in "$TMPDIR"*) return 0 ;; esac
  fi
  return 1
}

TARGETS=""
IS_BASH=0
if [ "$TOOL_NAME" = "Bash" ]; then
  IS_BASH=1
  CMD="$(json_get '.tool_input.command')"
  [ -z "$CMD" ] && exit $ALLOW
  TARGETS="$(bash_targets "$CMD")"
  debug "bash targets: $(printf '%s' "$TARGETS" | tr '\n' ' ')"
else
  TARGETS="$(json_get '.tool_input.file_path')"
  [ -z "$TARGETS" ] && TARGETS="$(json_get '.tool_input.notebook_path')"
  debug "file=$TARGETS"
fi

# Herramienta sin rutas asociadas: nada que vigilar.
[ -z "$TARGETS" ] && exit $ALLOW

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

# --- 8. Veredicto, ruta a ruta ------------------------------------------------
check_target() {
  _raw="$1"

  # Destinos que no son archivos del repo (solo aplicable a Bash).
  if [ "$IS_BASH" = "1" ] && is_exempt "$_raw"; then
    debug "exento: $_raw"
    return 0
  fi

  # Normalizar a ruta relativa del repositorio.
  case "$_raw" in
    "$REPO_ROOT"/*) _rel="${_raw#"$REPO_ROOT"/}" ;;
    /*)             deny "Ruta fuera del repositorio: $_raw

La FDA solo permite escrituras dentro del repositorio ($REPO_ROOT).
Si necesitas escribir fuera, es una decisión humana: detente y solicítala." ;;
    ./*)            _rel="${_raw#./}" ;;
    *)              _rel="$_raw" ;;
  esac

  # Escapes de traversal: se bloquean siempre, sin excepción.
  case "$_rel" in
    *../*|*/..|..) deny "Ruta con traversal (..): $_raw" ;;
  esac
  debug "rel=$_rel"

  # Prohibido gana sobre permitido, siempre.
  if [ -n "$FORBIDDEN" ]; then
    if _hit="$(matches_any "$_rel" "$FORBIDDEN")"; then
      deny "Ruta explícitamente PROHIBIDA por $WP_ID: $_rel
Coincide con el patrón prohibido: $_hit

Esta ruta está fuera de alcance por decisión del contrato. No busques un rodeo:
si el cambio es necesario, detente y solicita una modificación del WP."
    fi
  fi

  if _hit="$(matches_any "$_rel" "$ALLOWED")"; then
    debug "PERMITIDO $_rel (patrón $_hit)"
    return 0
  fi

  # No coincide con nada permitido → bloquear.
  _via="la herramienta $TOOL_NAME"
  [ "$IS_BASH" = "1" ] && _via="un comando de shell (escritura detectada en Bash)"

  deny "Ruta fuera del alcance de $WP_ID: $_rel
Detectada mediante: $_via

Rutas permitidas por el WP activo:
$(printf '%s\n' "$ALLOWED" | sed 's/^/  - /')

Qué hacer (CLAUDE.md, regla 3 del implementer): DETENTE y solicita decisión.
No amplíes el alcance por tu cuenta, no edites work-packages/ACTIVE para
esquivar este control y no reescribas el comando para evadir la detección.
Si el cambio es realmente necesario, el WP está mal definido y hay que
corregirlo explícitamente."
}

while IFS= read -r _t; do
  [ -z "$_t" ] && continue
  check_target "$_t"
done <<EOF
$TARGETS
EOF

exit $ALLOW
