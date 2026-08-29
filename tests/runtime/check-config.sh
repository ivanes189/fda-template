#!/usr/bin/env bash
#
# check-config.sh — Preflight estructural del runtime fail-closed (WP-008).
#
# Comprueba que .claude/settings.json invoca el hook por una ruta ANCLADA con
# CLAUDE_PROJECT_DIR, que normaliza a exit 2 cualquier fallo del guard, y que
# las ocho reglas de archivo estan ancladas a la raiz del proyecto.
#
# Headless: sin red, sin prompts, sin TTY, con codigo de salida significativo.
# Contadores propios e independientes de cualquier otra suite del repositorio.
# Compatible con bash 3.2 (macOS) y bash 5 (runners de CI).
#
# Uso:
#   bash tests/runtime/check-config.sh [ruta_settings] [ruta_repo]
#
# Ambos argumentos son opcionales y por defecto apuntan al repositorio real.
# El argumento explicito manda sobre el valor por defecto (invariante I4 de
# ADR-001): es lo que permite validar un candidato ANTES de sustituir el
# archivo real, y probar este propio preflight contra fixtures.
#
# Salida:
#   exit 0  todas las comprobaciones conformes
#   exit 1  alguna no conformidad
#   exit 2  argumentos invalidos, archivo ausente o entorno invalido
#
# Los dos oraculos versionados viven junto a este script y son la referencia
# del test, no la fuente contractual: la fuente contractual es el WP aprobado.

set -u

EXIT_OK=0
EXIT_NO_CONFORME=1
EXIT_ARGS=2

SCRIPT_DIR=$( cd -P "$(dirname "$0")" >/dev/null 2>&1 && pwd -P ) || exit $EXIT_ARGS
ORACULO_COMANDO="$SCRIPT_DIR/command-canonico.txt"
ORACULO_REGLAS="$SCRIPT_DIR/reglas-canonicas.txt"

abortar() {
  printf 'ABORTADO: %s\n' "$1" >&2
  exit $EXIT_ARGS
}

# --- 1. Argumentos ------------------------------------------------------------

[ "$#" -gt 2 ] && abortar "demasiados argumentos (maximo 2): $*"

for _a in "$@"; do
  case "$_a" in
    -*) abortar "argumento no reconocido: $_a" ;;
  esac
done

RAIZ_POR_DEFECTO=$( cd -P "$SCRIPT_DIR/../.." >/dev/null 2>&1 && pwd -P ) || \
  abortar "no se puede resolver la raiz por defecto"

if [ "$#" -ge 2 ]; then
  RAIZ_ARG="$2"
else
  RAIZ_ARG="$RAIZ_POR_DEFECTO"
fi

[ -d "$RAIZ_ARG" ] || abortar "la raiz del proyecto no existe o no es un directorio: $RAIZ_ARG"
RAIZ=$( cd -P "$RAIZ_ARG" >/dev/null 2>&1 && pwd -P ) || abortar "raiz no canonicalizable: $RAIZ_ARG"

if [ "$#" -ge 1 ]; then
  SETTINGS="$1"
else
  SETTINGS="$RAIZ/.claude/settings.json"
fi

[ -e "$SETTINGS" ] || abortar "no existe el archivo de configuracion: $SETTINGS"
[ -f "$SETTINGS" ] || abortar "la configuracion no es un archivo regular: $SETTINGS"
[ -r "$SETTINGS" ] || abortar "la configuracion no es legible: $SETTINGS"

[ -f "$ORACULO_COMANDO" ] || abortar "falta el oraculo del comando: $ORACULO_COMANDO"
[ -f "$ORACULO_REGLAS" ] || abortar "falta el oraculo de reglas: $ORACULO_REGLAS"
command -v python3 >/dev/null 2>&1 || abortar "python3 no esta disponible"

# --- 2. Lectura estructurada de la configuracion ------------------------------
#
# python3 extrae los datos y los emite en un protocolo de lineas separadas por
# tabulador. El command se normaliza aqui (secuencias de espacios a un solo
# espacio y recorte de extremos), de modo que el valor emitido nunca contiene
# saltos de linea ni tabuladores.

DATOS="$(python3 - "$SETTINGS" <<'PY'
import json
import sys

MATCHER_CONTRATADO = "Edit|Write|MultiEdit|NotebookEdit|Bash"


def emitir(clave, valor=""):
    print("%s\t%s" % (clave, valor))


try:
    with open(sys.argv[1], "r", encoding="utf-8") as fh:
        datos = json.load(fh)
except Exception as exc:  # JSON invalido, ilegible o vacio
    emitir("JSON", "0")
    emitir("JSON_ERROR", str(exc).replace("\t", " ").replace("\n", " "))
    sys.exit(0)

if not isinstance(datos, dict):
    emitir("JSON", "0")
    emitir("JSON_ERROR", "el documento no es un objeto JSON")
    sys.exit(0)

emitir("JSON", "1")

hooks = datos.get("hooks")
grupos = hooks.get("PreToolUse") if isinstance(hooks, dict) else None
if isinstance(grupos, list) and grupos:
    emitir("PRETOOLUSE", "1")
else:
    emitir("PRETOOLUSE", "0")
    grupos = []

exacto = None
primero = None
for grupo in grupos:
    if not isinstance(grupo, dict):
        continue
    matcher = grupo.get("matcher")
    if primero is None:
        primero = grupo
    if matcher == MATCHER_CONTRATADO and exacto is None:
        exacto = grupo

emitir("MATCHER_EXACTO", "1" if exacto is not None else "0")

elegido = exacto if exacto is not None else primero
comando = None
if isinstance(elegido, dict):
    for hook in elegido.get("hooks") or []:
        if isinstance(hook, dict) and isinstance(hook.get("command"), str):
            comando = hook["command"]
            break

if comando is None:
    emitir("COMMAND_PRESENTE", "0")
else:
    emitir("COMMAND_PRESENTE", "1")
    emitir("COMMAND", " ".join(comando.split()))

permisos = datos.get("permissions")
if not isinstance(permisos, dict):
    permisos = {}
for lista in ("deny", "ask", "allow"):
    for regla in permisos.get(lista) or []:
        if not isinstance(regla, str):
            continue
        if regla.startswith(("Read(", "Edit(", "Write(")):
            emitir("REGLA", regla.replace("\t", " "))
PY
)"

leer_campo() {
  printf '%s\n' "$DATOS" | awk -F'\t' -v k="$1" '$1 == k { sub(/^[^\t]*\t/, ""); print; exit }'
}

leer_reglas() {
  printf '%s\n' "$DATOS" | awk -F'\t' '$1 == "REGLA" { sub(/^[^\t]*\t/, ""); print }'
}

JSON_OK="$(leer_campo JSON)"
[ -z "$JSON_OK" ] && JSON_OK="0"

# El veredicto de la comprobacion 1 lo determina el METODO CONTRATADO:
# python3 -m json.tool. La extraccion estructurada con json.load es posterior y
# NO puede sustituirlo. Si ambos discreparan —el metodo contratado acepta el
# archivo y la extraccion no— se declara NO CONFORME: fail-closed.
JSON_TOOL_ERROR="$(python3 -m json.tool "$SETTINGS" 2>&1 >/dev/null)"
JSON_TOOL_COD=$?

if [ "$JSON_TOOL_COD" -eq 0 ] && [ "$JSON_OK" = "1" ]; then
  JSON_VALIDO=1
else
  JSON_VALIDO=0
fi

# --- 3. Motor de comprobaciones ----------------------------------------------

CONFORMES=0
NO_CONFORMES=0

comprobacion() {
  # $1 numero · $2 titulo · $3 veredicto (ok|ko) · $4 detalle
  _n="$1"; _titulo="$2"; _veredicto="$3"; _detalle="${4:-}"
  if [ "$_veredicto" = "ok" ]; then
    CONFORMES=$(( CONFORMES + 1 ))
    if [ -n "$_detalle" ]; then
      printf '[%s] %-46s CONFORME (%s)\n' "$_n" "$_titulo" "$_detalle"
    else
      printf '[%s] %-46s CONFORME\n' "$_n" "$_titulo"
    fi
  else
    NO_CONFORMES=$(( NO_CONFORMES + 1 ))
    printf '[%s] %-46s NO CONFORME: %s\n' "$_n" "$_titulo" "$_detalle"
  fi
}

printf '=== Preflight de configuracion del runtime fail-closed (WP-008) ===\n'
printf 'settings: %s\n' "$SETTINGS"
printf 'raiz:     %s\n' "$RAIZ"
printf '\n'

# --- Comprobacion 1: JSON valido ---------------------------------------------
if [ "$JSON_VALIDO" = "1" ]; then
  comprobacion 1 "JSON valido" ok "python3 -m json.tool"
elif [ "$JSON_TOOL_COD" -ne 0 ]; then
  comprobacion 1 "JSON valido" ko "python3 -m json.tool rechaza el archivo: $JSON_TOOL_ERROR"
else
  comprobacion 1 "JSON valido" ko \
    "python3 -m json.tool lo acepta pero la extraccion estructurada no: $(leer_campo JSON_ERROR)"
fi

NO_EVALUABLE="no evaluable: la configuracion no parsea como JSON"

# --- Comprobacion 2: PreToolUse presente -------------------------------------
if [ "$JSON_VALIDO" != "1" ]; then
  comprobacion 2 "hooks.PreToolUse presente" ko "$NO_EVALUABLE"
elif [ "$(leer_campo PRETOOLUSE)" = "1" ]; then
  comprobacion 2 "hooks.PreToolUse presente" ok
else
  comprobacion 2 "hooks.PreToolUse presente" ko "no existe hooks.PreToolUse o es una lista vacia"
fi

# --- Comprobacion 3: matcher exacto ------------------------------------------
if [ "$JSON_VALIDO" != "1" ]; then
  comprobacion 3 "Matcher exacto" ko "$NO_EVALUABLE"
elif [ "$(leer_campo MATCHER_EXACTO)" = "1" ]; then
  comprobacion 3 "Matcher exacto" ok
else
  comprobacion 3 "Matcher exacto" ko "ningun grupo tiene el matcher contratado, caracter a caracter"
fi

# --- Comprobacion 4: comando canonico exacto ---------------------------------
COMANDO_ORACULO="$(tr -s '[:space:]' ' ' < "$ORACULO_COMANDO" | sed -e 's/^ *//' -e 's/ *$//')"
if [ "$JSON_VALIDO" != "1" ]; then
  comprobacion 4 "Comando canonico exacto" ko "$NO_EVALUABLE"
elif [ "$(leer_campo COMMAND_PRESENTE)" != "1" ]; then
  comprobacion 4 "Comando canonico exacto" ko "el grupo de PreToolUse no declara ningun command"
elif [ "$(leer_campo COMMAND)" = "$COMANDO_ORACULO" ]; then
  comprobacion 4 "Comando canonico exacto" ok
else
  comprobacion 4 "Comando canonico exacto" ko "el command no es identico al oraculo tras normalizar espacios"
fi

# --- Comprobacion 5: guard presente y ejecutable -----------------------------
GUARD="$RAIZ/.claude/hooks/guard.sh"
if [ ! -e "$GUARD" ]; then
  comprobacion 5 "guard.sh presente y ejecutable" ko "no existe $GUARD"
elif [ ! -x "$GUARD" ]; then
  comprobacion 5 "guard.sh presente y ejecutable" ko "existe pero no tiene permiso de ejecucion"
else
  comprobacion 5 "guard.sh presente y ejecutable" ok
fi

# --- Comprobaciones 6 a 9: las reglas de archivo -----------------------------
REGLAS_TODAS="$(leer_reglas)"
REGLAS_ARCHIVO="$(printf '%s\n' "$REGLAS_TODAS" | grep -E '^(Read|Edit)\(' || true)"
REGLAS_WRITE="$(printf '%s\n' "$REGLAS_TODAS" | grep -E '^Write\(' || true)"

contar() {
  if [ -z "$1" ]; then printf '0\n'; else printf '%s\n' "$1" | grep -c '' ; fi
}

N_ARCHIVO="$(contar "$REGLAS_ARCHIVO")"
N_WRITE="$(contar "$REGLAS_WRITE")"

# 6 — ninguna regla con './' ni sin anclar
if [ "$JSON_VALIDO" != "1" ]; then
  comprobacion 6 "Reglas ancladas a la raiz del proyecto" ko "$NO_EVALUABLE"
else
  N_SIN_ANCLAR=0
  if [ -n "$REGLAS_ARCHIVO" ]; then
    while IFS= read -r _r; do
      [ -z "$_r" ] && continue
      _interior="${_r#*(}"
      _interior="${_interior%)}"
      case "$_interior" in
        ./*) N_SIN_ANCLAR=$(( N_SIN_ANCLAR + 1 )) ;;
        /*)  : ;;
        *)   N_SIN_ANCLAR=$(( N_SIN_ANCLAR + 1 )) ;;
      esac
    done <<EOF
$REGLAS_ARCHIVO
EOF
  fi
  if [ "$N_SIN_ANCLAR" -eq 0 ]; then
    comprobacion 6 "Reglas ancladas a la raiz del proyecto" ok
  else
    comprobacion 6 "Reglas ancladas a la raiz del proyecto" ko \
      "$N_SIN_ANCLAR regla(s) con prefijo './' o sin anclar"
  fi
fi

# 7 — ninguna regla Write(...) inerte
if [ "$JSON_VALIDO" != "1" ]; then
  comprobacion 7 "Sin reglas Write(...) inertes" ko "$NO_EVALUABLE"
elif [ "$N_WRITE" -eq 0 ]; then
  comprobacion 7 "Sin reglas Write(...) inertes" ok
else
  comprobacion 7 "Sin reglas Write(...) inertes" ko "$N_WRITE regla(s) Write(...) presentes"
fi

# 8 — recuento exacto
if [ "$JSON_VALIDO" != "1" ]; then
  comprobacion 8 "Recuento de reglas de archivo" ko "$NO_EVALUABLE"
elif [ "$N_ARCHIVO" -eq 8 ]; then
  comprobacion 8 "Recuento de reglas de archivo" ok "8"
else
  comprobacion 8 "Recuento de reglas de archivo" ko "se esperaban 8 y hay $N_ARCHIVO"
fi

# 9 — conjunto exacto, elemento a elemento y con duplicados significativos
if [ "$JSON_VALIDO" != "1" ]; then
  comprobacion 9 "Conjunto exacto de reglas" ko "$NO_EVALUABLE"
else
  ACTUAL_ORDENADO="$(printf '%s\n' "$REGLAS_ARCHIVO" | grep -v '^$' | LC_ALL=C sort)"
  ORACULO_ORDENADO="$(grep -v '^[[:space:]]*$' "$ORACULO_REGLAS" | LC_ALL=C sort)"
  if [ "$ACTUAL_ORDENADO" = "$ORACULO_ORDENADO" ]; then
    comprobacion 9 "Conjunto exacto de reglas" ok
  else
    FALTAN="$(printf '%s\n' "$ORACULO_ORDENADO" | grep -vxF -f <(printf '%s\n' "$ACTUAL_ORDENADO") || true)"
    SOBRAN="$(printf '%s\n' "$ACTUAL_ORDENADO" | grep -vxF -f <(printf '%s\n' "$ORACULO_ORDENADO") || true)"
    _det="el conjunto no coincide elemento a elemento con el oraculo"
    [ -n "$FALTAN" ] && _det="$_det · faltan: $(printf '%s' "$FALTAN" | tr '\n' ' ')"
    [ -n "$SOBRAN" ] && _det="$_det · sobran: $(printf '%s' "$SOBRAN" | tr '\n' ' ')"
    if [ -z "$FALTAN" ] && [ -z "$SOBRAN" ]; then
      _det="$_det · misma composicion con multiplicidades distintas (duplicado)"
    fi
    comprobacion 9 "Conjunto exacto de reglas" ko "$_det"
  fi
fi

printf '\n'
printf 'RESULTADO: %s conformes · %s no conformes\n' "$CONFORMES" "$NO_CONFORMES"

[ "$NO_CONFORMES" -eq 0 ] && exit $EXIT_OK
exit $EXIT_NO_CONFORME
