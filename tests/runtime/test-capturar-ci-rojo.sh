#!/usr/bin/env bash
#
# test-capturar-ci-rojo.sh — Pruebas del comprobador de las barreras de CI.
#
# DIECINUEVE casos, con contadores propios. Headless y SIN RED en todos ellos:
# se usan respuestas de gh grabadas en tests/runtime/fixtures/ci/ y un stub
# inyectado por la costura explicita de la seccion 6e.
#
#   Casos  1 a 12 — el modo puro --validar
#   Casos 13 a 16 — la envoltura de adquisicion en modo fixture
#   Casos 17 a 19 — el modo --verde, tambien en modo fixture
#
# El caso 13 lleva TRECE subcomprobaciones nombradas. En las trece se demuestra
# ademas que NI EL STUB NI EL gh REAL llegaron a ejecutarse: ambos dejan un
# marcador en disco cuando se ejecutan, y las trece exigen su ausencia.
#
# Uso:   bash tests/runtime/test-capturar-ci-rojo.sh
# Salida: exit 0 con 0 fallidas · exit 1 si alguna falla · exit 2 si el entorno
#         no permite ejecutar las pruebas.

set -u

SCRIPT_DIR=$( cd -P "$(dirname "$0")" >/dev/null 2>&1 && pwd -P ) || exit 2
REPO=$( cd -P "$SCRIPT_DIR/../.." >/dev/null 2>&1 && pwd -P ) || exit 2
COMPROBADOR="$SCRIPT_DIR/capturar-ci-rojo.sh"
FIX="$SCRIPT_DIR/fixtures/ci"

C_ROJO="1111111111111111111111111111111111111111"
C_VERDE="2222222222222222222222222222222222222222"

CORRECTAS=0
FALLIDAS=0

abortar() { printf 'ABORTADO: %s\n' "$1" >&2; exit 2; }

[ -f "$COMPROBADOR" ] || abortar "falta $COMPROBADOR"
[ -d "$FIX" ] || abortar "faltan los fixtures de CI"

dentro_de() {
  case "$1" in
    "$2") return 0 ;;
    "$2"/*) return 0 ;;
  esac
  return 1
}

# Plantilla explicita: 'mktemp -d' sin plantilla ignora TMPDIR en macOS.
TMP_BRUTO="$(mktemp -d "${TMPDIR:-/tmp}/fda-wp008-ci-test.XXXXXX" 2>/dev/null)" || abortar "mktemp -d ha fallado"
TMP=$( cd -P "$TMP_BRUTO" >/dev/null 2>&1 && pwd -P ) || abortar "temporal no canonicalizable"
if dentro_de "$TMP" "$REPO"; then
  rmdir "$TMP" 2>/dev/null
  abortar "el temporal de mktemp -d queda DENTRO del repositorio (revisa TMPDIR)"
fi
trap 'rm -rf "$TMP"' EXIT

ok_caso() { CORRECTAS=$(( CORRECTAS + 1 )); printf '[caso %02d] %-46s OK\n' "$1" "$2"; }
ko_caso() { FALLIDAS=$(( FALLIDAS + 1 )); printf '[caso %02d] %-46s FALLA: %s\n' "$1" "$2" "$3"; }

SALIDA=""
COD=0

# --- Casos 1 a 12: el modo puro --validar ------------------------------------
#
# $1 numero · $2 titulo · $3 fixture · $4 exit esperado · $5 validacion que debe
# aparecer como NO CONFORME (vacio si no aplica)

caso_validar() {
  _n="$1"; _t="$2"; _fx="$3"; _esp="$4"; _val="${5:-}"
  SALIDA="$(bash "$COMPROBADOR" --validar "$_fx" "$C_ROJO" 2>&1)"
  COD=$?
  if [ "$COD" -ne "$_esp" ]; then
    ko_caso "$_n" "$_t" "esperado exit $_esp y obtenido $COD"
    printf '%s\n' "$SALIDA" | sed 's/^/           | /'
    return 0
  fi
  if [ -n "$_val" ]; then
    if ! printf '%s\n' "$SALIDA" | grep -q "^\[$_val\].*NO CONFORME"; then
      ko_caso "$_n" "$_t" "la validacion $_val no aparece como NO CONFORME"
      printf '%s\n' "$SALIDA" | sed 's/^/           | /'
      return 0
    fi
  fi
  ok_caso "$_n" "$_t"
  printf '%s\n' "$SALIDA" | grep -E 'NO CONFORME|RESULTADO' | sed 's/^/           | /'
}

printf '=== Pruebas del comprobador de barreras de CI (WP-008) — 19 casos ===\n'
printf 'comprobador: %s\n' "$COMPROBADOR"
printf 'temporal:    %s\n\n' "$TMP"

caso_validar 1 "JSON completamente conforme" "$FIX/rojo-conforme.json" 0 ""
caso_validar 2 "Run no terminado" "$FIX/rojo-no-terminado.json" 1 "1"
caso_validar 3 "headSha incorrecto" "$FIX/rojo-headsha-incorrecto.json" 1 "2"
caso_validar 4 "conclusion igual a success" "$FIX/rojo-conclusion-success.json" 1 "3"
caso_validar 5 "conclusion igual a cancelled" "$FIX/rojo-conclusion-cancelled.json" 1 "3"
caso_validar 6 "Paso anterior distinto de success" "$FIX/rojo-paso-anterior-no-success.json" 1 "4"
caso_validar 7 "Preflight distinto de failure" "$FIX/rojo-preflight-no-failure.json" 1 "5"
caso_validar 8 "Paso posterior distinto de skipped" "$FIX/rojo-paso-posterior-no-skipped.json" 1 "6"
caso_validar 9 "Otro job distinto de success" "$FIX/rojo-otro-job-no-success.json" 1 "7"
caso_validar 10 "Segunda causa de fallo en el run" "$FIX/rojo-segunda-causa.json" 1 "8"
# Caso 11 — dos formas de respuesta INUTILIZABLE, ambas exit 2. La segunda es
# estructural: un elemento de steps que no es un objeto. La variacion se genera
# en el temporal externo del test; no se versiona ningun fixture nuevo.
cat > "$TMP/rojo-paso-no-objeto.json" <<'JSON'
{
  "status": "completed",
  "conclusion": "failure",
  "headSha": "1111111111111111111111111111111111111111",
  "databaseId": 90015,
  "url": "https://example.invalid/runs/90015",
  "jobs": [
    {
      "name": "Gobierno FDA",
      "status": "completed",
      "conclusion": "failure",
      "steps": [
        { "number": 1, "name": "El hook guard.sh es ejecutable", "status": "completed", "conclusion": "success" },
        { "number": 2, "name": "Configuración del runtime fail-closed (preflight)", "status": "completed", "conclusion": "failure" },
        { "number": 3, "name": "Manual sin enlaces rotos", "status": "completed", "conclusion": "skipped" }
      ]
    },
    {
      "name": "Escaneo de secretos",
      "status": "completed",
      "conclusion": "success",
      "steps": ["no soy un objeto"]
    }
  ]
}
JSON
SALIDA="$(bash "$COMPROBADOR" --validar "$FIX/json-malformado.json" "$C_ROJO" 2>&1)"; COD=$?
SALIDA2="$(bash "$COMPROBADOR" --validar "$TMP/rojo-paso-no-objeto.json" "$C_ROJO" 2>&1)"; COD2=$?
if [ "$COD" -eq 2 ] && [ "$COD2" -eq 2 ] && printf '%s\n' "$SALIDA2" | grep -q 'no es un objeto'; then
  ok_caso 11 "JSON malformado o inutilizable"
  printf '           | malformado -> exit %s · paso que no es objeto -> exit %s, clasificado inutilizable\n' "$COD" "$COD2"
else
  ko_caso 11 "JSON malformado o inutilizable" "obtenidos $COD y $COD2, se esperaba 2 y 2 con diagnostico estructural"
  printf '%s\n' "$SALIDA2" | sed 's/^/           | /'
fi

SALIDA="$(bash "$COMPROBADOR" --validar "$FIX/rojo-conforme.json" 2>&1)"; COD=$?
SALIDA2="$(bash "$COMPROBADOR" --validar --verde "$FIX/rojo-conforme.json" "$C_ROJO" 2>&1)"; COD2=$?
if [ "$COD" -eq 2 ] && [ "$COD2" -eq 2 ] \
   && printf '%s\n' "$SALIDA" | grep -q '^ABORTADO' \
   && printf '%s\n' "$SALIDA2" | grep -q '^ABORTADO'; then
  ok_caso 12 "Argumentos invalidos"
  printf '           | sin hash esperado -> exit %s · combinacion no admitida -> exit %s, ambas ABORTADO\n' "$COD" "$COD2"
else
  ko_caso 12 "Argumentos invalidos" "obtenidos $COD y $COD2, se esperaba 2 y 2 con ABORTADO"
fi

# --- Infraestructura de fixture para los casos 13 a 19 -----------------------
#
# El stub y el gh falso escriben un marcador cuando se ejecutan. Su AUSENCIA es
# la prueba de que una invocacion se rechazo antes de tocar nada.

MARCA_STUB="$TMP/stub-invocado"
MARCA_GH="$TMP/gh-real-invocado"

crear_fixture() {
  _f="$TMP/$1"
  mkdir -p "$_f/bin" || abortar "no se pudo crear el fixture $_f"
  printf 'raiz de fixture del comprobador de CI\n' > "$_f/.fda-fixture"
  # gh falso, primero en PATH: si el comprobador llegara a invocar el gh real,
  # este marcador aparecería.
  {
    printf '#!/usr/bin/env bash\n'
    printf 'printf "x" >> "%s"\n' "$MARCA_GH"
    printf 'printf "{}\\n"\n'
  } > "$_f/bin/gh"
  chmod 755 "$_f/bin/gh"
  printf '%s' "$_f"
}

# $1 raiz · $2.. archivos JSON que el stub emite, en orden; el ultimo se repite.
crear_stub() {
  _f="$1"; shift
  : > "$_f/stub-lista"
  for _a in "$@"; do printf '%s\n' "$_a" >> "$_f/stub-lista"; done
  {
    printf '#!/usr/bin/env bash\n'
    printf 'D=$( cd -P "$(dirname "$0")" >/dev/null 2>&1 && pwd -P )\n'
    printf 'printf "x" >> "%s"\n' "$MARCA_STUB"
    printf 'printf "x" >> "$D/stub-llamadas"\n'
    printf 'N=$(wc -c < "$D/stub-llamadas" | tr -d " ")\n'
    printf 'A=$(sed -n "${N}p" "$D/stub-lista")\n'
    printf '[ -z "$A" ] && A=$(tail -1 "$D/stub-lista")\n'
    printf '[ "$A" = "FALLO" ] && exit 3\n'
    printf '[ "$A" = "BASURA" ] && { printf "no soy json\\n"; exit 0; }\n'
    printf 'cat "$A"\n'
  } > "$_f/gh-stub"
  chmod 755 "$_f/gh-stub"
  printf '%s' "$_f/gh-stub"
}

SUB_FALLOS=0
# Recuento EJECUTABLE de subcomprobaciones CONTRACTUALES del caso 13. Solo lo
# incrementan los veredictos nombrados de la tabla de §6d; las aserciones
# subordinadas no cuentan.
SUB_CONTRACTUALES=0

sub_ok() { printf '           | %-42s OK\n' "$1"; }
sub_ko() { printf '           | %-42s FALLA: %s\n' "$1" "$2"; SUB_FALLOS=$(( SUB_FALLOS + 1 )); }
sub_contractual_ok() { SUB_CONTRACTUALES=$(( SUB_CONTRACTUALES + 1 )); sub_ok "$1"; }
sub_contractual_ko() { SUB_CONTRACTUALES=$(( SUB_CONTRACTUALES + 1 )); sub_ko "$1" "$2"; }
detalle() { printf '           |   · %s\n' "$1"; }

# Ejecuta una invocacion que DEBE ser rechazada con exit 2 sin tocar nada, y
# devuelve 0 o 1. NO emite veredicto nombrado ni cuenta como subcomprobacion:
# es la pieza con la que se construyen tanto los rechazos simples como los
# agregados.
intento_rechazado() {
  _desc="$1"; shift
  rm -f "$MARCA_STUB" "$MARCA_GH"
  _sal="$("$@" 2>&1)"
  _cod=$?
  if [ "$_cod" -ne 2 ]; then detalle "$_desc: esperado exit 2 y obtenido $_cod"; return 1; fi
  if [ -e "$MARCA_STUB" ]; then detalle "$_desc: el stub llego a ejecutarse"; return 1; fi
  if [ -e "$MARCA_GH" ]; then detalle "$_desc: el gh real llego a ejecutarse"; return 1; fi
  detalle "$_desc: exit 2, sin stub y sin gh"
  return 0
}

# Un rechazo simple: una invocacion, un veredicto contractual nombrado.
rechazo() {
  _nombre="$1"; shift
  _det="$(intento_rechazado "$_nombre" "$@")"
  _r=$?
  if [ "$_r" -eq 0 ]; then
    sub_contractual_ok "$_nombre"
  else
    sub_contractual_ko "$_nombre" "no fue rechazado limpiamente"
    printf '%s\n' "$_det"
  fi
}

# --- Caso 13: rechazos de la costura y de las rutas --------------------------

printf '[caso 13] %-46s\n' "Rechazos de la costura y de las rutas"
SUB_FALLOS=0
SUB_CONTRACTUALES=0
F13="$(crear_fixture f13)"
STUB13="$(crear_stub "$F13" "$FIX/rojo-conforme.json")"
export PATH="$F13/bin:$PATH"

SALIDA_OK="$TMP/salida-conforme"
mkdir -p "$SALIDA_OK"

rechazo "salida-dentro-del-repo" \
  env FDA_CI_TEST_GH="$STUB13" FDA_CI_TEST_INTERVAL_SECONDS=1 FDA_CI_TEST_TIMEOUT_SECONDS=5 \
  bash "$COMPROBADOR" --fixture-root "$F13" 90001 "$C_ROJO" "$REPO/evidence/WP-008"

ln -s "$REPO/evidence/WP-008" "$TMP/enlace-al-repo"
rechazo "salida-symlink-al-repo" \
  env FDA_CI_TEST_GH="$STUB13" FDA_CI_TEST_INTERVAL_SECONDS=1 FDA_CI_TEST_TIMEOUT_SECONDS=5 \
  bash "$COMPROBADOR" --fixture-root "$F13" 90001 "$C_ROJO" "$TMP/enlace-al-repo"

rechazo "salida-inexistente" \
  env FDA_CI_TEST_GH="$STUB13" FDA_CI_TEST_INTERVAL_SECONDS=1 FDA_CI_TEST_TIMEOUT_SECONDS=5 \
  bash "$COMPROBADOR" --fixture-root "$F13" 90001 "$C_ROJO" "$TMP/no-existe-esta-salida"
if [ -e "$TMP/no-existe-esta-salida" ]; then
  detalle "salida-inexistente: se ha creado la ruta rechazada"
  SUB_FALLOS=$(( SUB_FALLOS + 1 ))
else
  detalle "salida-inexistente: la ruta rechazada no se materializa"
fi

# Subcomprobacion contractual UNICA que agrega las DOS raices que la seccion 9
# prohibe para un mktemp -d, con su control de residuo cada una. Emite un solo
# veredicto nombrado; lo demas son aserciones subordinadas.
AGR=0
intento_rechazado "raiz 1: TMPDIR dentro del repositorio real" \
  env TMPDIR="$REPO/evidence/WP-008" FDA_CI_TEST_GH="$STUB13" FDA_CI_TEST_INTERVAL_SECONDS=1 FDA_CI_TEST_TIMEOUT_SECONDS=5 \
  bash "$COMPROBADOR" --fixture-root "$F13" 90001 "$C_ROJO" || AGR=$(( AGR + 1 ))
if [ -n "$(find "$REPO/evidence/WP-008" -mindepth 1 -maxdepth 1 -type d -name 'fda-wp008-ci.*' 2>/dev/null)" ]; then
  detalle "raiz 1: queda el directorio recien creado en el repositorio"
  AGR=$(( AGR + 1 ))
else
  detalle "raiz 1: no queda el directorio recien creado"
fi
intento_rechazado "raiz 2: TMPDIR dentro de la raiz fisica del fixture" \
  env TMPDIR="$F13" FDA_CI_TEST_GH="$STUB13" FDA_CI_TEST_INTERVAL_SECONDS=1 FDA_CI_TEST_TIMEOUT_SECONDS=5 \
  bash "$COMPROBADOR" --fixture-root "$F13" 90001 "$C_ROJO" || AGR=$(( AGR + 1 ))
if [ -n "$(find "$F13" -mindepth 1 -maxdepth 1 -type d -name 'fda-wp008-ci.*' 2>/dev/null)" ]; then
  detalle "raiz 2: queda el directorio recien creado en la copia externa"
  AGR=$(( AGR + 1 ))
else
  detalle "raiz 2: no queda el directorio recien creado"
fi
if [ "$AGR" -eq 0 ]; then
  sub_contractual_ok "tmpdir-dentro-del-repo"
else
  sub_contractual_ko "tmpdir-dentro-del-repo" "$AGR aserciones subordinadas fallidas"
fi

rechazo "real-con-gh" \
  env FDA_CI_TEST_GH="$STUB13" bash "$COMPROBADOR" 90001 "$C_ROJO" "$SALIDA_OK"
rechazo "real-con-interval" \
  env FDA_CI_TEST_INTERVAL_SECONDS=1 bash "$COMPROBADOR" 90001 "$C_ROJO" "$SALIDA_OK"
rechazo "real-con-timeout" \
  env FDA_CI_TEST_TIMEOUT_SECONDS=5 bash "$COMPROBADOR" 90001 "$C_ROJO" "$SALIDA_OK"

rechazo "fixture-variable-ausente" \
  env FDA_CI_TEST_GH="$STUB13" FDA_CI_TEST_INTERVAL_SECONDS=1 \
  bash "$COMPROBADOR" --fixture-root "$F13" 90001 "$C_ROJO" "$SALIDA_OK"

rechazo "duracion-invalida" \
  env FDA_CI_TEST_GH="$STUB13" FDA_CI_TEST_INTERVAL_SECONDS=0 FDA_CI_TEST_TIMEOUT_SECONDS=cinco \
  bash "$COMPROBADOR" --fixture-root "$F13" 90001 "$C_ROJO" "$SALIDA_OK"

rechazo "raiz-dentro-del-repo" \
  env FDA_CI_TEST_GH="$STUB13" FDA_CI_TEST_INTERVAL_SECONDS=1 FDA_CI_TEST_TIMEOUT_SECONDS=5 \
  bash "$COMPROBADOR" --fixture-root "$REPO" 90001 "$C_ROJO" "$SALIDA_OK"

F13B="$(crear_fixture f13b)"
STUB13B="$(crear_stub "$F13B" "$FIX/rojo-conforme.json")"
rm -f "$F13B/.fda-fixture"
rechazo "marcador-ausente" \
  env FDA_CI_TEST_GH="$STUB13B" FDA_CI_TEST_INTERVAL_SECONDS=1 FDA_CI_TEST_TIMEOUT_SECONDS=5 \
  bash "$COMPROBADOR" --fixture-root "$F13B" 90001 "$C_ROJO" "$SALIDA_OK"

printf 'marcador real\n' > "$TMP/marcador-real"
ln -s "$TMP/marcador-real" "$F13B/.fda-fixture"
rechazo "marcador-symlink" \
  env FDA_CI_TEST_GH="$STUB13B" FDA_CI_TEST_INTERVAL_SECONDS=1 FDA_CI_TEST_TIMEOUT_SECONDS=5 \
  bash "$COMPROBADOR" --fixture-root "$F13B" 90001 "$C_ROJO" "$SALIDA_OK"

STUB_FUERA="$TMP/gh-stub-fuera"
{ printf '#!/usr/bin/env bash\n'; printf 'printf "x" >> "%s"\n' "$MARCA_STUB"; printf 'exit 0\n'; } > "$STUB_FUERA"
chmod 755 "$STUB_FUERA"
rechazo "stub-fuera-o-symlink" \
  env FDA_CI_TEST_GH="$STUB_FUERA" FDA_CI_TEST_INTERVAL_SECONDS=1 FDA_CI_TEST_TIMEOUT_SECONDS=5 \
  bash "$COMPROBADOR" --fixture-root "$F13" 90001 "$C_ROJO" "$SALIDA_OK"

# El recuento de subcomprobaciones contractuales es EJECUTABLE: el caso no se
# declara conforme si no son exactamente trece.
if [ "$SUB_CONTRACTUALES" -ne 13 ]; then
  FALLIDAS=$(( FALLIDAS + 1 ))
  printf '           => FALLA: se contaron %s subcomprobaciones contractuales y deben ser 13\n' "$SUB_CONTRACTUALES"
elif [ "$SUB_FALLOS" -eq 0 ]; then
  CORRECTAS=$(( CORRECTAS + 1 ))
  printf '           => OK (%s subcomprobaciones contractuales contadas, ni el stub ni el gh real se ejecutaron)\n' "$SUB_CONTRACTUALES"
else
  FALLIDAS=$(( FALLIDAS + 1 ))
  printf '           => FALLA (%s aserciones fallidas sobre %s subcomprobaciones contractuales)\n' "$SUB_FALLOS" "$SUB_CONTRACTUALES"
fi

# --- Caso 14: polling, persistencia externa y delegacion ---------------------

F14="$(crear_fixture f14)"
STUB14="$(crear_stub "$F14" "$FIX/rojo-no-terminado.json" "$FIX/rojo-conforme.json")"
SAL14="$TMP/salida14"; mkdir -p "$SAL14"
rm -f "$MARCA_STUB" "$MARCA_GH"
SALIDA="$(FDA_CI_TEST_GH="$STUB14" FDA_CI_TEST_INTERVAL_SECONDS=1 FDA_CI_TEST_TIMEOUT_SECONDS=30 \
  bash "$COMPROBADOR" --fixture-root "$F14" 90001 "$C_ROJO" "$SAL14" 2>&1)"; COD=$?
LLAMADAS="$(wc -c < "$F14/stub-llamadas" 2>/dev/null | tr -d ' ')"
if [ "$COD" -eq 0 ] && [ "$LLAMADAS" = "2" ] \
   && [ -s "$SAL14/run-rojo.json" ] \
   && head -1 "$SAL14/captura-rojo.log" | grep -q '^modo=fixture$' \
   && printf '%s\n' "$SALIDA" | grep -q 'RESULTADO: 0 no conformidades' \
   && [ ! -e "$MARCA_GH" ]; then
  ok_caso 14 "Polling, persistencia externa y delegacion"
  printf '           | invocaciones del stub: %s · modo=fixture en la primera linea del log\n' "$LLAMADAS"
else
  ko_caso 14 "Polling, persistencia externa y delegacion" "exit=$COD llamadas=$LLAMADAS"
  printf '%s\n' "$SALIDA" | sed 's/^/           | /'
fi

# --- Caso 15: fallo del stub o respuesta inutilizable ------------------------

F15="$(crear_fixture f15)"
STUB15="$(crear_stub "$F15" "FALLO")"
SAL15="$TMP/salida15"; mkdir -p "$SAL15"
SALIDA="$(FDA_CI_TEST_GH="$STUB15" FDA_CI_TEST_INTERVAL_SECONDS=1 FDA_CI_TEST_TIMEOUT_SECONDS=10 \
  bash "$COMPROBADOR" --fixture-root "$F15" 90001 "$C_ROJO" "$SAL15" 2>&1)"; COD=$?
F15B="$(crear_fixture f15b)"
STUB15B="$(crear_stub "$F15B" "BASURA")"
SAL15B="$TMP/salida15b"; mkdir -p "$SAL15B"
SALIDA2="$(FDA_CI_TEST_GH="$STUB15B" FDA_CI_TEST_INTERVAL_SECONDS=1 FDA_CI_TEST_TIMEOUT_SECONDS=10 \
  bash "$COMPROBADOR" --fixture-root "$F15B" 90001 "$C_ROJO" "$SAL15B" 2>&1)"; COD2=$?
if [ "$COD" -eq 2 ] && [ "$COD2" -eq 2 ] \
   && printf '%s\n' "$SALIDA" | grep -q '^ABORTADO' \
   && printf '%s\n' "$SALIDA2" | grep -q 'inutilizable'; then
  ok_caso 15 "Fallo del stub o respuesta inutilizable"
  printf '           | stub que falla -> exit %s · respuesta ilegible -> exit %s, declarada inutilizable\n' "$COD" "$COD2"
else
  ko_caso 15 "Fallo del stub o respuesta inutilizable" "obtenidos $COD y $COD2, se esperaba 2 y 2 con diagnostico"
fi

# --- Caso 16: expiracion del tiempo maximo, sin espera real prolongada -------

F16="$(crear_fixture f16)"
STUB16="$(crear_stub "$F16" "$FIX/rojo-no-terminado.json")"
SAL16="$TMP/salida16"; mkdir -p "$SAL16"
INICIO="$(date +%s)"
SALIDA="$(FDA_CI_TEST_GH="$STUB16" FDA_CI_TEST_INTERVAL_SECONDS=1 FDA_CI_TEST_TIMEOUT_SECONDS=2 \
  bash "$COMPROBADOR" --fixture-root "$F16" 90001 "$C_ROJO" "$SAL16" 2>&1)"; COD=$?
FIN="$(date +%s)"
TARDANZA=$(( FIN - INICIO ))
if [ "$COD" -eq 2 ] && [ "$TARDANZA" -lt 60 ] && printf '%s\n' "$SALIDA" | grep -q 'tiempo maximo'; then
  ok_caso 16 "Expiracion del tiempo maximo"
  printf '           | exit %s en %s segundos, sin espera real prolongada\n' "$COD" "$TARDANZA"
else
  ko_caso 16 "Expiracion del tiempo maximo" "exit=$COD tardanza=${TARDANZA}s"
  printf '%s\n' "$SALIDA" | sed 's/^/           | /'
fi

# --- Casos 17 a 19: el modo --verde ------------------------------------------

F17="$(crear_fixture f17)"
STUB17="$(crear_stub "$F17" "$FIX/verde-no-terminado.json" "$FIX/verde-conforme.json")"
SAL17="$TMP/salida17"; mkdir -p "$SAL17"
SALIDA="$(FDA_CI_TEST_GH="$STUB17" FDA_CI_TEST_INTERVAL_SECONDS=1 FDA_CI_TEST_TIMEOUT_SECONDS=30 \
  bash "$COMPROBADOR" --fixture-root "$F17" --verde 90011 "$C_VERDE" "$SAL17" 2>&1)"; COD=$?
if [ "$COD" -eq 0 ] && head -1 "$SAL17/captura-verde.log" | grep -q '^modo=fixture$'; then
  ok_caso 17 "Adquisicion verde conforme por stub"
  printf '%s\n' "$SALIDA" | grep -E 'RESULTADO' | sed 's/^/           | /'
else
  ko_caso 17 "Adquisicion verde conforme por stub" "exit=$COD"
  printf '%s\n' "$SALIDA" | sed 's/^/           | /'
fi

F18="$(crear_fixture f18)"
STUB18="$(crear_stub "$F18" "$FIX/verde-headsha-incorrecto.json")"
SAL18="$TMP/salida18"; mkdir -p "$SAL18"
SALIDA="$(FDA_CI_TEST_GH="$STUB18" FDA_CI_TEST_INTERVAL_SECONDS=1 FDA_CI_TEST_TIMEOUT_SECONDS=30 \
  bash "$COMPROBADOR" --fixture-root "$F18" --verde 90013 "$C_VERDE" "$SAL18" 2>&1)"; COD=$?
if [ "$COD" -eq 1 ] && printf '%s\n' "$SALIDA" | grep -q '^\[2\].*NO CONFORME'; then
  ok_caso 18 "Verde terminado con headSha incorrecto"
else
  ko_caso 18 "Verde terminado con headSha incorrecto" "exit=$COD"
  printf '%s\n' "$SALIDA" | sed 's/^/           | /'
fi

F19="$(crear_fixture f19)"
STUB19="$(crear_stub "$F19" "$FIX/verde-conclusion-distinta.json")"
SAL19="$TMP/salida19"; mkdir -p "$SAL19"
SALIDA="$(FDA_CI_TEST_GH="$STUB19" FDA_CI_TEST_INTERVAL_SECONDS=1 FDA_CI_TEST_TIMEOUT_SECONDS=30 \
  bash "$COMPROBADOR" --fixture-root "$F19" --verde 90014 "$C_VERDE" "$SAL19" 2>&1)"; COD=$?
if [ "$COD" -eq 1 ] && printf '%s\n' "$SALIDA" | grep -q '^\[3\].*NO CONFORME'; then
  ok_caso 19 "Verde con conclusion distinta de success"
else
  ko_caso 19 "Verde con conclusion distinta de success" "exit=$COD"
  printf '%s\n' "$SALIDA" | sed 's/^/           | /'
fi

printf '\nNingun caso ha usado la red: todas las adquisiciones son por stub.\n'
printf 'RESULTADO: %s correctas · %s fallidas\n' "$CORRECTAS" "$FALLIDAS"
[ "$FALLIDAS" -eq 0 ] || exit 1
exit 0
