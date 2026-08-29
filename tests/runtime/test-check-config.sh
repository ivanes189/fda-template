#!/usr/bin/env bash
#
# test-check-config.sh — Pruebas del preflight estructural de WP-008.
#
# VEINTIDOS casos, con contadores propios e independientes de cualquier otra
# suite. Headless, sin red, sin prompts y sin TTY.
#
#   Casos  1 a 12 — estructura de la configuracion
#   Casos 13 a 16 — conjunto exacto de reglas (15 y 16 mantienen el total en 8)
#   Casos 17 a 22 — comportamiento del comando canonico, ejecutandolo de verdad
#
# El caso 1 lleva ademas una subcomprobacion nombrada, 'ruta-inexistente', que
# exige exit 2 cuando el archivo de configuracion no existe. Es una propiedad
# del contrato del preflight y no un caso adicional: el total sigue siendo 22.
#
# Las raices de proyecto de los casos 9, 10 y 17 a 22 se crean con mktemp -d
# conforme a la seccion 9 del WP: se canonicalizan y deben quedar FUERA de la
# raiz fisica del repositorio. EL HOOK REAL NUNCA SE RENOMBRA, NI SE SUSTITUYE,
# NI PIERDE PERMISOS: todos los guards de prueba son scripts triviales creados
# dentro de esas raices temporales.
#
# Uso:   bash tests/runtime/test-check-config.sh
# Salida: exit 0 con 0 fallidas · exit 1 si alguna falla · exit 2 si el entorno
#         no permite ejecutar las pruebas.

set -u

SCRIPT_DIR=$( cd -P "$(dirname "$0")" >/dev/null 2>&1 && pwd -P ) || exit 2
REPO=$( cd -P "$SCRIPT_DIR/../.." >/dev/null 2>&1 && pwd -P ) || exit 2
PREFLIGHT="$SCRIPT_DIR/check-config.sh"
FIX="$SCRIPT_DIR/fixtures/config"
ORACULO_COMANDO="$SCRIPT_DIR/command-canonico.txt"

CORRECTAS=0
FALLIDAS=0

abortar() { printf 'ABORTADO: %s\n' "$1" >&2; exit 2; }

[ -f "$PREFLIGHT" ] || abortar "falta $PREFLIGHT"
[ -d "$FIX" ] || abortar "faltan los fixtures de configuracion"
[ -f "$ORACULO_COMANDO" ] || abortar "falta el oraculo del comando"

dentro_de() {
  case "$1" in
    "$2") return 0 ;;
    "$2"/*) return 0 ;;
  esac
  return 1
}

# Plantilla explicita: 'mktemp -d' sin plantilla ignora TMPDIR en macOS.
TMP_BRUTO="$(mktemp -d "${TMPDIR:-/tmp}/fda-wp008-preflight.XXXXXX" 2>/dev/null)" || abortar "mktemp -d ha fallado"
TMP=$( cd -P "$TMP_BRUTO" >/dev/null 2>&1 && pwd -P ) || abortar "temporal no canonicalizable"
if dentro_de "$TMP" "$REPO"; then
  rmdir "$TMP" 2>/dev/null
  abortar "el temporal de mktemp -d queda DENTRO del repositorio (revisa TMPDIR)"
fi
trap 'rm -rf "$TMP"' EXIT

# --- Raices de proyecto de usar y tirar --------------------------------------
#
# $1 nombre del directorio · $2 estado del guard: ok | sin-bit | ausente

crear_raiz() {
  _nombre="$1"
  _guard="$2"
  _r="$TMP/$_nombre"
  mkdir -p "$_r/.claude/hooks" || abortar "no se pudo crear la raiz $_r"
  if [ "$_guard" != "ausente" ]; then
    printf '#!/usr/bin/env bash\nexit 0\n' > "$_r/.claude/hooks/guard.sh"
    if [ "$_guard" = "ok" ]; then
      chmod 755 "$_r/.claude/hooks/guard.sh"
    else
      chmod 644 "$_r/.claude/hooks/guard.sh"
    fi
  fi
  printf '%s' "$_r"
}

# Guard trivial con un codigo de salida fijo, para los casos 17 a 22.
crear_raiz_guard_codigo() {
  _r="$1"
  _codigo="$2"
  mkdir -p "$_r/.claude/hooks" || abortar "no se pudo crear la raiz $_r"
  printf '#!/usr/bin/env bash\nexit %s\n' "$_codigo" > "$_r/.claude/hooks/guard.sh"
  chmod 755 "$_r/.claude/hooks/guard.sh"
}

RAIZ_OK="$(crear_raiz raiz-con-guard ok)"
RAIZ_SIN_BIT="$(crear_raiz raiz-guard-sin-bit sin-bit)"
RAIZ_AUSENTE="$(crear_raiz raiz-sin-guard ausente)"

# --- Motor de casos -----------------------------------------------------------

SALIDA=""
COD=0

ejecutar_preflight() {
  SALIDA="$(bash "$PREFLIGHT" "$1" "$2" 2>&1)"
  COD=$?
  return 0
}

# Numeros de comprobacion marcados NO CONFORME, en orden y separados por espacio.
no_conformes() {
  printf '%s\n' "$SALIDA" | awk '/NO CONFORME/ { gsub(/[^0-9]/, "", $1); printf "%s ", $1 }' | sed 's/ $//'
}

ok_caso() {
  CORRECTAS=$(( CORRECTAS + 1 ))
  printf '[caso %02d] %-42s OK\n' "$1" "$2"
}

ko_caso() {
  FALLIDAS=$(( FALLIDAS + 1 ))
  printf '[caso %02d] %-42s FALLA: %s\n' "$1" "$2" "$3"
}

volcar_salida() {
  printf '%s\n' "$SALIDA" | sed 's/^/           | /'
}

# $1 numero · $2 titulo · $3 fixture · $4 raiz · $5 exit esperado ·
# $6 comprobaciones NO CONFORMES esperadas, exactas y separadas por espacio
caso_estructura() {
  _n="$1"; _t="$2"; _fx="$3"; _raiz="$4"; _esp="$5"; _fallos_esp="$6"
  ejecutar_preflight "$_fx" "$_raiz"
  _obt="$(no_conformes)"
  if [ "$COD" -ne "$_esp" ]; then
    ko_caso "$_n" "$_t" "esperado exit $_esp y obtenido $COD"
    volcar_salida
    return 0
  fi
  if [ "$_obt" != "$_fallos_esp" ]; then
    ko_caso "$_n" "$_t" "se esperaban las comprobaciones [$_fallos_esp] y han fallado [$_obt]"
    volcar_salida
    return 0
  fi
  ok_caso "$_n" "$_t"
  volcar_salida
}

# $1 numero · $2 titulo · $3 raiz · $4 exit esperado del comando canonico
caso_comportamiento() {
  _n="$1"; _t="$2"; _raiz="$3"; _esp="$4"
  CLAUDE_PROJECT_DIR="$_raiz" bash -c "$(cat "$ORACULO_COMANDO")" >/dev/null 2>&1
  _obt=$?
  if [ "$_obt" -eq "$_esp" ]; then
    ok_caso "$_n" "$_t"
    printf '           | CLAUDE_PROJECT_DIR=%s -> exit %s (esperado %s)\n' "$_raiz" "$_obt" "$_esp"
  else
    ko_caso "$_n" "$_t" "el comando canonico ha salido $_obt y se esperaba $_esp"
  fi
}

printf '=== Pruebas del preflight de configuracion (WP-008) — 22 casos ===\n'
printf 'preflight: %s\n' "$PREFLIGHT"
printf 'temporal:  %s\n\n' "$TMP"

# --- Casos 1 a 12: estructura -------------------------------------------------

caso_estructura 1 "Configuracion conforme completa" "$FIX/conforme.json" "$RAIZ_OK" 0 ""

# Subcomprobacion nombrada del caso 1: el preflight sale 2 si el archivo no existe.
bash "$PREFLIGHT" "$TMP/ruta-que-no-existe.json" "$RAIZ_OK" >/dev/null 2>&1
SUB=$?
if [ "$SUB" -eq 2 ]; then
  printf '           | subcomprobacion ruta-inexistente -> exit 2 (esperado 2) OK\n'
else
  FALLIDAS=$(( FALLIDAS + 1 ))
  printf '           | subcomprobacion ruta-inexistente -> exit %s (esperado 2) FALLA\n' "$SUB"
fi

caso_estructura 2 "JSON malformado" "$FIX/json-malformado.json" "$RAIZ_OK" 1 "1 2 3 4 6 7 8 9"
caso_estructura 3 "Sin hooks.PreToolUse" "$FIX/sin-pretooluse.json" "$RAIZ_OK" 1 "2 3 4"
caso_estructura 4 "Matcher sin Bash" "$FIX/matcher-sin-bash.json" "$RAIZ_OK" 1 "3"
caso_estructura 5 "Matcher con otro orden" "$FIX/matcher-desordenado.json" "$RAIZ_OK" 1 "3"
caso_estructura 6 "command con ruta relativa" "$FIX/command-relativo.json" "$RAIZ_OK" 1 "4"
caso_estructura 7 "command inerte con las cadenas" "$FIX/command-inerte.json" "$RAIZ_OK" 1 "4"
caso_estructura 8 "command con un espacio de mas" "$FIX/command-espacio-de-mas.json" "$RAIZ_OK" 0 ""
caso_estructura 9 "Guard ausente en el fixture" "$FIX/conforme.json" "$RAIZ_AUSENTE" 1 "5"
caso_estructura 10 "Guard sin bit de ejecucion" "$FIX/conforme.json" "$RAIZ_SIN_BIT" 1 "5"
caso_estructura 11 "Una regla Edit(./...)" "$FIX/regla-relativa.json" "$RAIZ_OK" 1 "6 9"
caso_estructura 12 "Una regla Write(...)" "$FIX/regla-write.json" "$RAIZ_OK" 1 "7"

# --- Casos 13 a 16: conjunto exacto ------------------------------------------

caso_estructura 13 "Falta una regla: siete en total" "$FIX/falta-una-regla.json" "$RAIZ_OK" 1 "8 9"
caso_estructura 14 "Sobra una regla: nueve en total" "$FIX/sobra-una-regla.json" "$RAIZ_OK" 1 "8 9"
caso_estructura 15 "Duplicada y ausente: ocho en total" "$FIX/duplicada-y-ausente.json" "$RAIZ_OK" 1 "9"
caso_estructura 16 "Sustituida: ocho en total" "$FIX/sustituida.json" "$RAIZ_OK" 1 "9"

# --- Casos 17 a 22: comportamiento del comando canonico ----------------------

crear_raiz_guard_codigo "$TMP/guard-0" 0
crear_raiz_guard_codigo "$TMP/guard-1" 1
crear_raiz_guard_codigo "$TMP/guard-2" 2

caso_comportamiento 17 "Guard de fixture que sale 0" "$TMP/guard-0" 0
caso_comportamiento 18 "Guard de fixture que sale 1" "$TMP/guard-1" 2
caso_comportamiento 19 "Guard de fixture que sale 2" "$TMP/guard-2" 2
caso_comportamiento 20 "Guard ausente" "$RAIZ_AUSENTE" 2
caso_comportamiento 21 "Guard sin permiso de ejecucion" "$RAIZ_SIN_BIT" 2

# Caso 22: raiz con un espacio en el nombre, repitiendo 17 y 19.
RAIZ_ESPACIO="$TMP/raiz con espacio"
crear_raiz_guard_codigo "$RAIZ_ESPACIO/guard-0" 0
crear_raiz_guard_codigo "$RAIZ_ESPACIO/guard-2" 2
CLAUDE_PROJECT_DIR="$RAIZ_ESPACIO/guard-0" bash -c "$(cat "$ORACULO_COMANDO")" >/dev/null 2>&1
E22A=$?
CLAUDE_PROJECT_DIR="$RAIZ_ESPACIO/guard-2" bash -c "$(cat "$ORACULO_COMANDO")" >/dev/null 2>&1
E22B=$?
if [ "$E22A" -eq 0 ] && [ "$E22B" -eq 2 ]; then
  ok_caso 22 "Raiz con espacio: repite 17 y 19"
  printf '           | guard 0 -> exit %s (esperado 0) · guard 2 -> exit %s (esperado 2)\n' "$E22A" "$E22B"
else
  ko_caso 22 "Raiz con espacio: repite 17 y 19" "obtenidos $E22A y $E22B, se esperaban 0 y 2"
fi

# --- Invariante del hook real -------------------------------------------------

if [ -x "$REPO/.claude/hooks/guard.sh" ]; then
  printf '\nInvariante: .claude/hooks/guard.sh conserva ruta y bit de ejecucion.\n'
else
  FALLIDAS=$(( FALLIDAS + 1 ))
  printf '\nFALLA: .claude/hooks/guard.sh ha perdido su ruta o su bit de ejecucion.\n'
fi

printf '\nRESULTADO: %s correctas · %s fallidas\n' "$CORRECTAS" "$FALLIDAS"
[ "$FALLIDAS" -eq 0 ] || exit 1
exit 0
