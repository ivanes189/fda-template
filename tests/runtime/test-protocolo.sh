#!/usr/bin/env bash
#
# test-protocolo.sh — La maquina de estados del parche de WP-008, probada
# integramente sobre COPIAS EXTERNAS de la plantilla versionada.
#
# DOCE escenarios, con contadores propios. Headless, sin red, sin prompts y sin
# TTY. Compatible con bash 3.2 y con bash 5.
#
# Reglas que este test hace cumplir, no solo declara:
#
#   1. tests/runtime/fixtures/proyecto/** contiene UNICAMENTE plantillas
#      versionadas e inmutables. Ninguna prueba las modifica jamas.
#   2. Cada escenario COPIA lo que necesita a una raiz de trabajo externa a la
#      raiz fisica del repositorio, creada con mktemp -d conforme a la seccion 9.
#   3. Esa copia —y solo ella— lleva el marcador .fda-fixture.
#   4. --root recibe exclusivamente esa copia externa.
#
# La instantanea del arbol de plantillas se captura una sola vez al arrancar
# —la PREIMAGEN, antes de copiar nada—, una POSTIMAGEN INTERMEDIA por escenario
# y una POSTIMAGEN FINAL tras las limpiezas. Cualquier diferencia hace fallar el
# test, nombrando la ruta y el campo que cambiaron.
#
# Uso:   bash tests/runtime/test-protocolo.sh
# Salida: exit 0 con 0 fallidas · exit 1 si alguna falla · exit 2 si el entorno
#         no permite ejecutar las pruebas.
#
# Los artefactos detallados se escriben en el directorio temporal de la
# ejecucion, cuya ruta fisica se imprime al final bajo la etiqueta ARTEFACTOS.

set -u

SCRIPT_DIR=$( cd -P "$(dirname "$0")" >/dev/null 2>&1 && pwd -P ) || exit 2
REPO=$( cd -P "$SCRIPT_DIR/../.." >/dev/null 2>&1 && pwd -P ) || exit 2
PLANTILLA="$SCRIPT_DIR/fixtures/proyecto"
APLICAR="$REPO/evidence/WP-008/parche/aplicar.sh"
HUELLAS="$REPO/evidence/WP-008/parche/huellas.sha256"

CORRECTAS=0
FALLIDAS=0

abortar() { printf 'ABORTADO: %s\n' "$1" >&2; exit 2; }

[ -d "$PLANTILLA" ] || abortar "falta la plantilla de proyecto"
[ -f "$APLICAR" ] || abortar "falta $APLICAR"
[ -f "$HUELLAS" ] || abortar "falta $HUELLAS"

dentro_de() {
  case "$1" in
    "$2") return 0 ;;
    "$2"/*) return 0 ;;
  esac
  return 1
}

digest_stdin() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 | awk '{print $1}'
  else
    sha256sum | awk '{print $1}'
  fi
}

digest_archivo() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

if stat -f '%Lp' . >/dev/null 2>&1; then
  modo_de() { stat -f '%Lp' "$1"; }
else
  modo_de() { stat -c '%a' "$1"; }
fi

leer_huella() { awk -v k="$1" '$1 == k { print $2; exit }' "$HUELLAS"; }
SETTINGS_ANTES="$(leer_huella SETTINGS_ANTES)"
SETTINGS_DESPUES="$(leer_huella SETTINGS_DESPUES)"
CI_ANTES="$(leer_huella CI_ANTES)"
CI_DESPUES="$(leer_huella CI_DESPUES)"

# Todo directorio creado con mktemp -d se canonicaliza y debe quedar FUERA de la
# raiz fisica del repositorio (seccion 9 del WP). Si queda dentro, se elimina
# vacio y se aborta con exit 2.
crear_temporal() {
  # Plantilla explicita: 'mktemp -d' sin plantilla ignora TMPDIR en macOS.
  _b="$(mktemp -d "${TMPDIR:-/tmp}/fda-wp008-protocolo.XXXXXX" 2>/dev/null)" || abortar "mktemp -d ha fallado"
  _c=$( cd -P "$_b" >/dev/null 2>&1 && pwd -P ) || abortar "temporal no canonicalizable"
  if dentro_de "$_c" "$REPO"; then
    rmdir "$_c" 2>/dev/null
    abortar "el temporal de mktemp -d queda DENTRO del repositorio (revisa TMPDIR)"
  fi
  printf '%s' "$_c"
}

TMP="$(crear_temporal)"
# Los artefactos viven en su propio temporal y SOBREVIVEN a la limpieza: su ruta
# fisica se imprime al final para poder incorporarlos como evidencia.
ART="$(crear_temporal)"
trap 'rm -rf "$TMP"' EXIT

# --- Instantanea NUL-safe de un arbol ----------------------------------------
#
# Por entrada: ruta relativa, tipo, modo, SHA-256 de los bytes de cada archivo
# regular y destino literal de cada enlace simbolico. Los campos van separados
# por el separador de unidad (0x1f) y cada entrada termina en NUL, de modo que
# ni un espacio ni un salto de linea en un nombre pueden partir ni fundir
# entradas. El orden es determinista por bytes.
#
# .git/** se excluye por completo: los comandos de Git pueden actualizar
# metadatos internos aunque no cambie el contenido del proyecto.

US=$(printf '\037')

# Escapa de forma INYECTIVA e inequivoca: primero la barra invertida, despues
# los saltos de linea. Asi ningun campo puede contener un salto de linea, y la
# rendicion legible sigue siendo una entrada por linea aunque una ruta lleve
# saltos de linea en su nombre. La transformacion es reversible, de modo que el
# digest agregado sigue detectando cualquier cambio.
escapar() {
  _e="$1"
  _e="${_e//\\/\\\\}"
  _e="${_e//$'\n'/\\n}"
  printf '%s' "$_e"
}

instantanea_cruda() {
  _raiz="$1"
  ( cd "$_raiz" 2>/dev/null || exit 1
    find . -mindepth 1 -name .git -prune -o -print0 2>/dev/null \
      | LC_ALL=C sort -z \
      | while IFS= read -r -d '' _p; do
          if [ -L "$_p" ]; then
            _tipo="enlace"; _dig="-"
            # La sustitucion de comandos come los saltos de linea finales: el
            # centinela los conserva, y el destino queda literal y completo.
            _dest="$(readlink "$_p"; printf X)"
            _dest="${_dest%X}"
          elif [ -d "$_p" ]; then
            _tipo="directorio"; _dig="-"; _dest="-"
          elif [ -f "$_p" ]; then
            _tipo="regular"; _dig="$(digest_archivo "$_p")"; _dest="-"
          else
            _tipo="otro"; _dig="-"; _dest="-"
          fi
          printf '%s%s%s%s%s%s%s%s%s\0' \
            "$(escapar "$_p")" "$US" "$_tipo" "$US" "$(modo_de "$_p")" "$US" \
            "$_dig" "$US" "$(escapar "$_dest")"
        done
  )
}

# Rendicion legible: una entrada por linea. Como el productor ya escapo los
# saltos de linea, la correspondencia entrada-linea es exacta y cada campo
# queda identificable por su posicion.
CAMPOS='ruta | tipo | modo | sha256 | destino'
instantanea_legible() {
  instantanea_cruda "$1" | tr '\0' '\n' | sed 's/\x1f/ | /g'
}

instantanea_digest() { instantanea_cruda "$1" | digest_stdin; }

# El digest agregado es la magnitud vinculante. El recuento cuenta REGISTROS
# terminados en NUL, y es exacto tambien con rutas que lleven saltos de linea
# porque el productor ya los ha escapado.
instantanea_entradas() { instantanea_cruda "$1" | tr '\0' '\n' | grep -c '' | tr -d ' '; }

# Compara dos rendiciones y nombra la ruta y el campo que cambiaron.
diferencias_legibles() {
  printf '           | campos: %s\n' "$CAMPOS"
  diff "$1" "$2" 2>/dev/null | sed 's/^/           | /'
}

# --- Preimagen del arbol de plantillas, ANTES de copiar nada -----------------

PRE_TXT="$ART/plantillas-preimagen.txt"
instantanea_legible "$PLANTILLA" > "$PRE_TXT"
PRE_DIGEST="$(instantanea_digest "$PLANTILLA")"
PRE_ENTRADAS="$(instantanea_entradas "$PLANTILLA")"

comprobar_plantillas() {
  _etq="$1"
  _txt="$ART/plantillas-$_etq.txt"
  instantanea_legible "$PLANTILLA" > "$_txt"
  _d="$(instantanea_digest "$PLANTILLA")"
  if [ "$_d" = "$PRE_DIGEST" ]; then
    return 0
  fi
  printf '           | ARBOL DE PLANTILLAS ALTERADO en %s\n' "$_etq"
  diferencias_legibles "$PRE_TXT" "$_txt"
  return 1
}

# --- Materializacion de una copia externa de trabajo -------------------------

materializar() {
  _d="$1"
  mkdir -p "$_d/.claude/hooks" "$_d/.github/workflows" || return 1
  cp "$PLANTILLA/settings-antes.json" "$_d/.claude/settings.json" || return 1
  cp "$PLANTILLA/ci-antes.yml" "$_d/.github/workflows/ci.yml" || return 1
  cp "$PLANTILLA/workflow-claude.yml" "$_d/.github/workflows/claude.yml" || return 1
  cp "$PLANTILLA/workflow-code-review.yml" "$_d/.github/workflows/code-review.yml" || return 1
  cp "$PLANTILLA/guard-trivial.sh" "$_d/.claude/hooks/guard.sh" || return 1
  chmod 644 "$_d/.claude/settings.json" "$_d/.github/workflows/ci.yml" \
            "$_d/.github/workflows/claude.yml" "$_d/.github/workflows/code-review.yml" || return 1
  chmod 755 "$_d/.claude/hooks/guard.sh" || return 1
  printf 'copia externa de trabajo de WP-008\n' > "$_d/.fda-fixture" || return 1
  return 0
}

copia_nueva() {
  _n="$1"
  _d="$TMP/copias/$_n"
  mkdir -p "$_d" || abortar "no se pudo crear la copia $_d"
  materializar "$_d" || abortar "no se pudo materializar la copia $_d"
  printf '%s' "$_d"
}

estado_de() {
  _d="$1"
  _s="$(digest_archivo "$_d/.claude/settings.json")"
  _c="$(digest_archivo "$_d/.github/workflows/ci.yml")"
  if [ "$_s" = "$SETTINGS_ANTES" ] && [ "$_c" = "$CI_ANTES" ]; then printf 'S0\n'
  elif [ "$_s" = "$SETTINGS_ANTES" ] && [ "$_c" = "$CI_DESPUES" ]; then printf 'S1\n'
  elif [ "$_s" = "$SETTINGS_DESPUES" ] && [ "$_c" = "$CI_DESPUES" ]; then printf 'S2\n'
  else printf 'DESCONOCIDO\n'; fi
}

# --- Huellas del repositorio real, invariantes durante todo el test ----------

h_otros_repo() { git -C "$REPO" diff --binary | digest_stdin; }
h_staged_repo() { git -C "$REPO" diff --cached --binary | digest_stdin; }

# --- Motor de escenarios ------------------------------------------------------

ESC_FALLOS=0
sub_ok()  { printf '           | %-46s OK\n' "$1"; }
sub_ko()  { printf '           | %-46s FALLA: %s\n' "$1" "$2"; ESC_FALLOS=$(( ESC_FALLOS + 1 )); }

exigir() { # $1 nombre · $2 esperado · $3 obtenido
  if [ "$2" = "$3" ]; then sub_ok "$1"; else sub_ko "$1" "esperado [$2] y obtenido [$3]"; fi
}

abrir_escenario() { ESC_FALLOS=0; printf '[escenario %02d] %s\n' "$1" "$2"; }

PLANTILLAS_ALTERADAS=0

# Cierra el escenario capturando su POSTIMAGEN INTERMEDIA del arbol de
# plantillas, inmediatamente despues de la ultima invocacion de aplicar.sh que
# le pertenece. Hay UNA comprobacion efectiva y causal por escenario, ni una
# mas. Ante la primera diferencia se nombra la ruta y el campo, se marca fallo
# y NO se continua con el escenario siguiente.
cerrar_escenario() {
  _num="$1"
  if comprobar_plantillas "$(printf 'e%02d' "$_num")"; then
    sub_ok "postimagen del arbol de plantillas intacta"
  else
    sub_ko "postimagen del arbol de plantillas intacta" "digest agregado distinto del de la preimagen"
    PLANTILLAS_ALTERADAS=1
  fi
  if [ "$ESC_FALLOS" -eq 0 ]; then
    CORRECTAS=$(( CORRECTAS + 1 ))
    printf '           => OK\n\n'
  else
    FALLIDAS=$(( FALLIDAS + 1 ))
    printf '           => FALLA (%s subcomprobaciones)\n\n' "$ESC_FALLOS"
  fi
  if [ "$PLANTILLAS_ALTERADAS" -eq 1 ]; then
    printf 'PARADA: el arbol de plantillas versionadas ha cambiado.\n'
    printf 'No se continua con el escenario siguiente.\n'
    printf 'ARTEFACTOS: %s\n' "$ART"
    printf 'RESULTADO: %s correctas · %s fallidas\n' "$CORRECTAS" "$FALLIDAS"
    exit 1
  fi
}

SALIDA=""
COD=0
correr() { # $@ = argumentos de aplicar.sh
  SALIDA="$(bash "$APLICAR" "$@" 2>&1)"
  COD=$?
  return 0
}

printf '=== Pruebas del protocolo del parche (WP-008) — 12 escenarios ===\n'
printf 'plantilla: %s\n' "$PLANTILLA"
printf 'temporal:  %s\n' "$TMP"
printf 'preimagen del arbol de plantillas: %s entradas · digest %s\n\n' "$PRE_ENTRADAS" "$PRE_DIGEST"

H_OTROS_INICIO="$(h_otros_repo)"
H_STAGED_INICIO="$(h_staged_repo)"

# --- Escenario 1: rojo desde S0 ----------------------------------------------

abrir_escenario 1 "rojo desde S0"
D="$(copia_nueva e01)"
ANTES_TXT="$ART/e01-antes.txt"; instantanea_legible "$D" > "$ANTES_TXT"
correr --root "$D" rojo
exigir "exit" "0" "$COD"
printf '%s\n' "$SALIDA" | grep -q 'APLICADO ROJO (S1)' && sub_ok "mensaje APLICADO ROJO (S1)" || sub_ko "mensaje APLICADO ROJO (S1)" "no aparece"
exigir "estado final" "S1" "$(estado_de "$D")"
DESPUES_TXT="$ART/e01-despues.txt"; instantanea_legible "$D" > "$DESPUES_TXT"
# Instantanea: identica salvo el archivo objetivo, sin altas ni bajas.
CAMBIOS="$(diff "$ANTES_TXT" "$DESPUES_TXT" | grep -c '^[<>]' | tr -d ' ')"
exigir "solo cambia el objetivo (2 lineas de diff)" "2" "$CAMBIOS"
diff "$ANTES_TXT" "$DESPUES_TXT" | grep '^[<>]' | grep -q './.github/workflows/ci.yml' \
  && sub_ok "la unica ruta que cambia es ci.yml" || sub_ko "la unica ruta que cambia es ci.yml" "cambia otra ruta"
# Subcomprobacion de la seccion 9: TMPDIR dentro del repositorio.
D9="$(copia_nueva e01-tmpdir)"
SAL9="$(TMPDIR="$REPO/evidence/WP-008" bash "$APLICAR" --root "$D9" rojo 2>&1)"; C9=$?
exigir "tmpdir-dentro-del-repo: exit" "2" "$C9"
exigir "tmpdir-dentro-del-repo: sin escribir" "S0" "$(estado_de "$D9")"
printf '%s\n' "$SAL9" | grep -q 'DENTRO del repositorio real' \
  && sub_ok "tmpdir-dentro-del-repo: motivo" || sub_ko "tmpdir-dentro-del-repo: motivo" "otro motivo: $SAL9"
[ -z "$(find "$REPO/evidence/WP-008" -mindepth 1 -maxdepth 1 -type d -name 'fda-wp008-parche.*' 2>/dev/null)" ] \
  && sub_ok "tmpdir-dentro-del-repo: no deja residuo" || sub_ko "tmpdir-dentro-del-repo: no deja residuo" "queda un directorio"
SAL9B="$(TMPDIR="$D9" bash "$APLICAR" --root "$D9" rojo 2>&1)"; C9B=$?
exigir "tmpdir-dentro-de-la-copia: exit" "2" "$C9B"
printf '%s\n' "$SAL9B" | grep -q 'DENTRO de la copia externa' \
  && sub_ok "tmpdir-dentro-de-la-copia: motivo" || sub_ko "tmpdir-dentro-de-la-copia: motivo" "otro motivo: $SAL9B"
exigir "tmpdir-dentro-de-la-copia: sin escribir" "S0" "$(estado_de "$D9")"
# El directorio recien creado dentro de la copia externa se elimina vacio: la
# busqueda se limita a esa raiz controlada por el test, sin tocar ni enumerar
# ningun temporal ajeno.
[ -z "$(find "$D9" -mindepth 1 -type d -name 'fda-wp008-parche.*' 2>/dev/null)" ] \
  && sub_ok "tmpdir-dentro-de-la-copia: no deja residuo" \
  || sub_ko "tmpdir-dentro-de-la-copia: no deja residuo" "queda el directorio recien creado"
cerrar_escenario 1

# --- Escenario 2: rojo repetido en S1 ----------------------------------------

abrir_escenario 2 "rojo repetido en S1"
ANTES_TXT="$ART/e02-antes.txt"; instantanea_legible "$D" > "$ANTES_TXT"
correr --root "$D" rojo
exigir "exit" "0" "$COD"
printf '%s\n' "$SALIDA" | grep -q '^YA EN ROJO$' && sub_ok "mensaje YA EN ROJO" || sub_ko "mensaje YA EN ROJO" "no aparece"
exigir "estado" "S1" "$(estado_de "$D")"
DESPUES_TXT="$ART/e02-despues.txt"; instantanea_legible "$D" > "$DESPUES_TXT"
exigir "sin cambios" "0" "$(diff "$ANTES_TXT" "$DESPUES_TXT" | grep -c '^[<>]' | tr -d ' ')"
cerrar_escenario 2

# --- Escenario 3: verde desde S1 ---------------------------------------------

abrir_escenario 3 "verde desde S1"
ANTES_TXT="$ART/e03-antes.txt"; instantanea_legible "$D" > "$ANTES_TXT"
correr --root "$D" verde
exigir "exit" "0" "$COD"
printf '%s\n' "$SALIDA" | grep -q 'APLICADO VERDE (S2)' && sub_ok "mensaje APLICADO VERDE (S2)" || sub_ko "mensaje APLICADO VERDE (S2)" "no aparece"
exigir "estado final" "S2" "$(estado_de "$D")"
# La suite del preflight es validacion posterior de la fase verde en LOS DOS
# modos: aqui se exige que conste su ejecucion sobre una copia externa.
printf '%s\n' "$SALIDA" | grep -q 'test-check-config.sh=0' \
  && sub_ok "test-check-config.sh ejecutado tambien en modo fixture" \
  || sub_ko "test-check-config.sh ejecutado tambien en modo fixture" "no consta en el log de la fase"
DESPUES_TXT="$ART/e03-despues.txt"; instantanea_legible "$D" > "$DESPUES_TXT"
exigir "solo cambia el objetivo (2 lineas de diff)" "2" "$(diff "$ANTES_TXT" "$DESPUES_TXT" | grep -c '^[<>]' | tr -d ' ')"
diff "$ANTES_TXT" "$DESPUES_TXT" | grep '^[<>]' | grep -q './.claude/settings.json' \
  && sub_ok "la unica ruta que cambia es settings.json" || sub_ko "la unica ruta que cambia es settings.json" "cambia otra ruta"
cerrar_escenario 3

# --- Escenario 4: verde repetido en S2 ---------------------------------------

abrir_escenario 4 "verde repetido en S2"
ANTES_TXT="$ART/e04-antes.txt"; instantanea_legible "$D" > "$ANTES_TXT"
correr --root "$D" verde
exigir "exit" "0" "$COD"
printf '%s\n' "$SALIDA" | grep -q '^YA EN VERDE$' && sub_ok "mensaje YA EN VERDE" || sub_ko "mensaje YA EN VERDE" "no aparece"
exigir "estado" "S2" "$(estado_de "$D")"
DESPUES_TXT="$ART/e04-despues.txt"; instantanea_legible "$D" > "$DESPUES_TXT"
exigir "sin cambios" "0" "$(diff "$ANTES_TXT" "$DESPUES_TXT" | grep -c '^[<>]' | tr -d ' ')"
cerrar_escenario 4

# --- Escenario 5: verde desde S0 ---------------------------------------------

LOG_ORDEN="$ART/05-abortado-orden.log"
abrir_escenario 5 "verde desde S0: aborta sin escribir"
D5="$(copia_nueva e05)"
ANTES_TXT="$ART/e05-antes.txt"; instantanea_legible "$D5" > "$ANTES_TXT"
correr --root "$D5" verde
{ printf '=== verde desde S0 ===\n'; printf '%s\n' "$SALIDA"; printf 'exit=%s\n\n' "$COD"; } > "$LOG_ORDEN"
exigir "exit" "2" "$COD"
printf '%s\n' "$SALIDA" | grep -q '^ABORTADO' && sub_ok "mensaje ABORTADO" || sub_ko "mensaje ABORTADO" "no aparece"
exigir "estado sin tocar" "S0" "$(estado_de "$D5")"
DESPUES_TXT="$ART/e05-despues.txt"; instantanea_legible "$D5" > "$DESPUES_TXT"
exigir "no ha escrito nada" "0" "$(diff "$ANTES_TXT" "$DESPUES_TXT" | grep -c '^[<>]' | tr -d ' ')"
cerrar_escenario 5

# --- Escenario 6: rojo desde S2 ----------------------------------------------

abrir_escenario 6 "rojo desde S2: aborta sin escribir"
ANTES_TXT="$ART/e06-antes.txt"; instantanea_legible "$D" > "$ANTES_TXT"
correr --root "$D" rojo
{ printf '=== rojo desde S2 ===\n'; printf '%s\n' "$SALIDA"; printf 'exit=%s\n' "$COD"; } >> "$LOG_ORDEN"
exigir "exit" "2" "$COD"
printf '%s\n' "$SALIDA" | grep -q '^ABORTADO' && sub_ok "mensaje ABORTADO" || sub_ko "mensaje ABORTADO" "no aparece"
exigir "estado sin tocar" "S2" "$(estado_de "$D")"
DESPUES_TXT="$ART/e06-despues.txt"; instantanea_legible "$D" > "$DESPUES_TXT"
exigir "no ha escrito nada" "0" "$(diff "$ANTES_TXT" "$DESPUES_TXT" | grep -c '^[<>]' | tr -d ' ')"
cerrar_escenario 6

# --- Escenario 7: par invertido ----------------------------------------------

LOG_INVERTIDO="$ART/06-abortado-par-invertido.log"
abrir_escenario 7 "par invertido: settings DESPUES con ci ANTES"
D7="$(copia_nueva e07)"
cp "$REPO/evidence/WP-008/parche/settings.json.candidato" "$D7/.claude/settings.json"
exigir "par construido" "DESCONOCIDO" "$(estado_de "$D7")"
ANTES_TXT="$ART/e07-antes.txt"; instantanea_legible "$D7" > "$ANTES_TXT"
correr --root "$D7" rojo
{ printf '=== par invertido · fase roja ===\n'; printf '%s\n' "$SALIDA"; printf 'exit=%s\n\n' "$COD"; } > "$LOG_INVERTIDO"
exigir "rojo: exit" "2" "$COD"
correr --root "$D7" verde
{ printf '=== par invertido · fase verde ===\n'; printf '%s\n' "$SALIDA"; printf 'exit=%s\n\n' "$COD"; } >> "$LOG_INVERTIDO"
exigir "verde: exit" "2" "$COD"
DESPUES_TXT="$ART/e07-despues.txt"; instantanea_legible "$D7" > "$DESPUES_TXT"
exigir "no ha escrito nada en ninguna fase" "0" "$(diff "$ANTES_TXT" "$DESPUES_TXT" | grep -c '^[<>]' | tr -d ' ')"
cerrar_escenario 7

# --- Escenario 8: estado desconocido -----------------------------------------

abrir_escenario 8 "estado desconocido: un tercer contenido"
D8="$(copia_nueva e08)"
printf '\n# tercer contenido, ni ANTES ni DESPUES\n' >> "$D8/.github/workflows/ci.yml"
exigir "par construido" "DESCONOCIDO" "$(estado_de "$D8")"
ANTES_TXT="$ART/e08-antes.txt"; instantanea_legible "$D8" > "$ANTES_TXT"
correr --root "$D8" rojo
{ printf '=== estado desconocido · fase roja ===\n'; printf '%s\n' "$SALIDA"; printf 'exit=%s\n\n' "$COD"; } >> "$LOG_INVERTIDO"
exigir "rojo: exit" "2" "$COD"
correr --root "$D8" verde
{ printf '=== estado desconocido · fase verde ===\n'; printf '%s\n' "$SALIDA"; printf 'exit=%s\n' "$COD"; } >> "$LOG_INVERTIDO"
exigir "verde: exit" "2" "$COD"
DESPUES_TXT="$ART/e08-despues.txt"; instantanea_legible "$D8" > "$DESPUES_TXT"
exigir "no ha escrito nada" "0" "$(diff "$ANTES_TXT" "$DESPUES_TXT" | grep -c '^[<>]' | tr -d ' ')"
cerrar_escenario 8

# --- Escenario 9: fallo provocado tras sustituir en la fase roja -------------

LOG_ROLLBACK_ROJO="$ART/07-rollback-rojo.log"
LOG_FAILPOINT="$ART/failpoint-rechazado.log"
abrir_escenario 9 "rollback de la fase roja"
D9R="$(copia_nueva e09)"
ANTES_TXT="$ART/e09-antes.txt"; instantanea_legible "$D9R" > "$ANTES_TXT"
SALIDA="$(FDA_PARCHE_FAILPOINT=rojo bash "$APLICAR" --root "$D9R" rojo 2>&1)"; COD=$?
{ printf '=== failpoint en la fase roja ===\n'; printf '%s\n' "$SALIDA"; printf 'exit=%s\n' "$COD"; } > "$LOG_ROLLBACK_ROJO"
exigir "exit distinto de cero" "1" "$COD"
printf '%s\n' "$SALIDA" | grep -q 'ROLLBACK APLICADO' && sub_ok "mensaje ROLLBACK APLICADO" || sub_ko "mensaje ROLLBACK APLICADO" "no aparece"
exigir "par restaurado" "S0" "$(estado_de "$D9R")"
DESPUES_TXT="$ART/e09-despues.txt"; instantanea_legible "$D9R" > "$DESPUES_TXT"
exigir "el arbol vuelve a su estado previo" "0" "$(diff "$ANTES_TXT" "$DESPUES_TXT" | grep -c '^[<>]' | tr -d ' ')"
# El failpoint se rechaza fuera de su unico contexto autorizado.
SALIDA="$(FDA_PARCHE_FAILPOINT=rojo bash "$APLICAR" rojo 2>&1)"; COD=$?
{ printf '=== failpoint SIN --root ===\n'; printf '%s\n' "$SALIDA"; printf 'exit=%s\n\n' "$COD"; } > "$LOG_FAILPOINT"
exigir "failpoint sin --root: exit" "2" "$COD"
SIN_MARCA="$TMP/copias/sin-marcador"
mkdir -p "$SIN_MARCA" && materializar "$SIN_MARCA" && rm -f "$SIN_MARCA/.fda-fixture"
SALIDA="$(FDA_PARCHE_FAILPOINT=rojo bash "$APLICAR" --root "$SIN_MARCA" rojo 2>&1)"; COD=$?
{ printf '=== failpoint contra una raiz SIN marcador .fda-fixture ===\n'; printf '%s\n' "$SALIDA"; printf 'exit=%s\n\n' "$COD"; } >> "$LOG_FAILPOINT"
exigir "failpoint sin marcador: exit" "2" "$COD"
exigir "raiz sin marcador: sin escribir" "S0" "$(estado_de "$SIN_MARCA")"
SALIDA="$(bash "$APLICAR" --root "$REPO" rojo 2>&1)"; COD=$?
{ printf '=== --root apuntando al repositorio real ===\n'; printf '%s\n' "$SALIDA"; printf 'exit=%s\n' "$COD"; } >> "$LOG_FAILPOINT"
exigir "--root dentro del repositorio: exit" "2" "$COD"
cerrar_escenario 9

# --- Escenario 10: fallo provocado tras sustituir en la fase verde -----------

LOG_ROLLBACK_VERDE="$ART/08-rollback-verde.log"
abrir_escenario 10 "rollback de la fase verde"
D10="$(copia_nueva e10)"
correr --root "$D10" rojo
exigir "preparado en S1" "S1" "$(estado_de "$D10")"
ANTES_TXT="$ART/e10-antes.txt"; instantanea_legible "$D10" > "$ANTES_TXT"
SALIDA="$(FDA_PARCHE_FAILPOINT=verde bash "$APLICAR" --root "$D10" verde 2>&1)"; COD=$?
{ printf '=== failpoint en la fase verde ===\n'; printf '%s\n' "$SALIDA"; printf 'exit=%s\n' "$COD"; } > "$LOG_ROLLBACK_VERDE"
exigir "exit distinto de cero" "1" "$COD"
printf '%s\n' "$SALIDA" | grep -q 'ROLLBACK APLICADO' && sub_ok "mensaje ROLLBACK APLICADO" || sub_ko "mensaje ROLLBACK APLICADO" "no aparece"
exigir "par restaurado a S1, no a S0" "S1" "$(estado_de "$D10")"
DESPUES_TXT="$ART/e10-despues.txt"; instantanea_legible "$D10" > "$DESPUES_TXT"
exigir "el arbol vuelve a su estado previo" "0" "$(diff "$ANTES_TXT" "$DESPUES_TXT" | grep -c '^[<>]' | tr -d ' ')"
# El fallo de la validacion posterior test-check-config.sh tambien provoca el
# rollback contractual a S1, y no a S0.
D10B="$(copia_nueva e10b)"
correr --root "$D10B" rojo
exigir "segunda copia preparada en S1" "S1" "$(estado_de "$D10B")"
ANTES_TXT="$ART/e10b-antes.txt"; instantanea_legible "$D10B" > "$ANTES_TXT"
SALIDA="$(FDA_PARCHE_FAILPOINT=verde-suite bash "$APLICAR" --root "$D10B" verde 2>&1)"; COD=$?
{ printf '\n=== failpoint en la validacion posterior test-check-config.sh ===\n'; printf '%s\n' "$SALIDA"; printf 'exit=%s\n' "$COD"; } >> "$LOG_ROLLBACK_VERDE"
exigir "fallo de test-check-config.sh: exit" "1" "$COD"
printf '%s\n' "$SALIDA" | grep -q 'test-check-config.sh=0' \
  && sub_ok "la suite se ejecuto de verdad antes de forzar su fallo" \
  || sub_ko "la suite se ejecuto de verdad antes de forzar su fallo" "no consta su ejecucion"
printf '%s\n' "$SALIDA" | grep -q 'ROLLBACK APLICADO' \
  && sub_ok "fallo de la suite: ROLLBACK APLICADO" || sub_ko "fallo de la suite: ROLLBACK APLICADO" "no aparece"
exigir "fallo de la suite: par restaurado a S1" "S1" "$(estado_de "$D10B")"
DESPUES_TXT="$ART/e10b-despues.txt"; instantanea_legible "$D10B" > "$DESPUES_TXT"
exigir "fallo de la suite: el arbol vuelve a su estado previo" "0" "$(diff "$ANTES_TXT" "$DESPUES_TXT" | grep -c '^[<>]' | tr -d ' ')"
cerrar_escenario 10

# --- Escenario 11: alcance de la fase roja -----------------------------------

abrir_escenario 11 "alcance de la fase roja"
D11="$(copia_nueva e11)"
ANTES_TXT="$ART/e11-antes.txt"; instantanea_legible "$D11" > "$ANTES_TXT"
HO="$(h_otros_repo)"; HS="$(h_staged_repo)"
correr --root "$D11" rojo
exigir "exit" "0" "$COD"
DESPUES_TXT="$ART/e11-despues.txt"; instantanea_legible "$D11" > "$DESPUES_TXT"
exigir "instantanea identica salvo ci.yml" "2" "$(diff "$ANTES_TXT" "$DESPUES_TXT" | grep -c '^[<>]' | tr -d ' ')"
exigir "H_OTROS invariante" "$HO" "$(h_otros_repo)"
exigir "H_STAGED invariante" "$HS" "$(h_staged_repo)"
printf '%s\n' "$SALIDA" | grep -q 'H_OTROS_DESPUES=' \
  && sub_ok "el log registra H_OTROS y H_STAGED" \
  || sub_ko "el log registra H_OTROS y H_STAGED" "la salida de la fase no las registra"
cerrar_escenario 11

# --- Escenario 12: alcance de la fase verde ----------------------------------

abrir_escenario 12 "alcance de la fase verde"
ANTES_TXT="$ART/e12-antes.txt"; instantanea_legible "$D11" > "$ANTES_TXT"
HO="$(h_otros_repo)"; HS="$(h_staged_repo)"
correr --root "$D11" verde
exigir "exit" "0" "$COD"
DESPUES_TXT="$ART/e12-despues.txt"; instantanea_legible "$D11" > "$DESPUES_TXT"
exigir "instantanea identica salvo settings.json" "2" "$(diff "$ANTES_TXT" "$DESPUES_TXT" | grep -c '^[<>]' | tr -d ' ')"
exigir "H_OTROS invariante" "$HO" "$(h_otros_repo)"
exigir "H_STAGED invariante" "$HS" "$(h_staged_repo)"
cerrar_escenario 12

# --- Demostracion de que la instantanea detecta las siete familias -----------

LOG_DETECCION="$ART/instantanea-deteccion.log"
DD="$TMP/copias/deteccion"
mkdir -p "$DD/sub" || abortar "no se pudo preparar la copia de deteccion"
printf 'contenido\n' > "$DD/archivo.txt"
printf 'otro\n' > "$DD/sub/otro.txt"
ln -s archivo.txt "$DD/enlace"
BASE_DIGEST="$(instantanea_digest "$DD")"
{
  printf '=== Deteccion por instantanea: siete familias ===\n'
  printf 'digest base: %s\n\n' "$BASE_DIGEST"
} > "$LOG_DETECCION"

familia() { # $1 nombre · $2 digest tras la mutacion
  if [ "$2" != "$BASE_DIGEST" ]; then
    printf '%-22s digest %s  DETECTADA\n' "$1" "$2" >> "$LOG_DETECCION"
    return 0
  fi
  printf '%-22s digest %s  NO DETECTADA\n' "$1" "$2" >> "$LOG_DETECCION"
  return 1
}

DET_FALLOS=0
printf 'nuevo\n' > "$DD/alta.txt";            familia "alta"                "$(instantanea_digest "$DD")" || DET_FALLOS=$((DET_FALLOS+1)); rm -f "$DD/alta.txt"
mv "$DD/sub/otro.txt" "$TMP/otro.guardado";   familia "baja"                "$(instantanea_digest "$DD")" || DET_FALLOS=$((DET_FALLOS+1)); mv "$TMP/otro.guardado" "$DD/sub/otro.txt"
mv "$DD/archivo.txt" "$DD/renombrado.txt";    familia "renombrado"          "$(instantanea_digest "$DD")" || DET_FALLOS=$((DET_FALLOS+1)); mv "$DD/renombrado.txt" "$DD/archivo.txt"
rm -f "$DD/sub/otro.txt"; mkdir "$DD/sub/otro.txt"; familia "cambio de tipo" "$(instantanea_digest "$DD")" || DET_FALLOS=$((DET_FALLOS+1)); rmdir "$DD/sub/otro.txt"; printf 'otro\n' > "$DD/sub/otro.txt"
chmod 700 "$DD/archivo.txt";                  familia "cambio de modo"      "$(instantanea_digest "$DD")" || DET_FALLOS=$((DET_FALLOS+1)); chmod 644 "$DD/archivo.txt"
printf 'distinto\n' > "$DD/archivo.txt";      familia "cambio de contenido" "$(instantanea_digest "$DD")" || DET_FALLOS=$((DET_FALLOS+1)); printf 'contenido\n' > "$DD/archivo.txt"
rm -f "$DD/enlace"; ln -s sub/otro.txt "$DD/enlace"; familia "destino de enlace" "$(instantanea_digest "$DD")" || DET_FALLOS=$((DET_FALLOS+1)); rm -f "$DD/enlace"; ln -s archivo.txt "$DD/enlace"
FINAL_DIGEST="$(instantanea_digest "$DD")"
{
  printf '\ndigest tras deshacer todas las mutaciones: %s\n' "$FINAL_DIGEST"
  printf 'reproducible: %s\n' "$( [ "$FINAL_DIGEST" = "$BASE_DIGEST" ] && printf 'si' || printf 'NO' )"
} >> "$LOG_DETECCION"

printf 'Deteccion por instantanea: 7 familias · %s no detectadas\n' "$DET_FALLOS"
if [ "$DET_FALLOS" -ne 0 ]; then FALLIDAS=$(( FALLIDAS + 1 )); fi
if [ "$FINAL_DIGEST" != "$BASE_DIGEST" ]; then
  FALLIDAS=$(( FALLIDAS + 1 ))
  printf 'FALLA: la instantanea no es reproducible sobre el mismo arbol\n'
fi

# --- Limites NUL-safe --------------------------------------------------------
#
# Subcomprobaciones AUXILIARES: no crean un escenario 13 ni una octava familia,
# pero tienen veredicto ejecutable y contribuyen a FALLIDAS. Todo ocurre dentro
# de la copia externa de la demostracion; el arbol versionado no se toca y no se
# limpia ningun temporal ajeno.

LIM_FALLOS=0
lim_ok() { printf '  limite NUL-safe: %-54s OK\n' "$1"; }
lim_ko() { printf '  limite NUL-safe: %-54s FALLA: %s\n' "$1" "$2"; LIM_FALLOS=$(( LIM_FALLOS + 1 )); }

ENTRADAS_BASE="$(instantanea_entradas "$DD")"
RUTA_SALTO="$DD/$(printf 'con\nsalto.txt')"
printf 'contenido con salto de linea en el nombre\n' > "$RUTA_SALTO"
# El centinela conserva los saltos finales del destino, que la sustitucion de
# comandos se comeria.
DEST_SALTO="$(printf 'destino-con-salto\n'; printf X)"
DEST_SALTO="${DEST_SALTO%X}"
ln -s "$DEST_SALTO" "$DD/enlace-con-salto"

ENTRADAS_LIM="$(instantanea_entradas "$DD")"
LINEAS_LIM="$(instantanea_legible "$DD" | grep -c '' | tr -d ' ')"
LEGIBLE_LIM="$ART/limites-nul-safe.txt"
instantanea_legible "$DD" > "$LEGIBLE_LIM"

if [ "$ENTRADAS_LIM" -eq $(( ENTRADAS_BASE + 2 )) ]; then
  lim_ok "una ruta con salto de linea cuenta como UNA sola entrada"
else
  lim_ko "una ruta con salto de linea cuenta como UNA sola entrada" \
    "de $ENTRADAS_BASE a $ENTRADAS_LIM, se esperaban $(( ENTRADAS_BASE + 2 ))"
fi

if [ "$LINEAS_LIM" -eq "$ENTRADAS_LIM" ]; then
  lim_ok "la rendicion mantiene una linea por entrada"
else
  lim_ko "la rendicion mantiene una linea por entrada" "$LINEAS_LIM lineas para $ENTRADAS_LIM entradas"
fi

if [ "$(grep -Fc 'con\nsalto.txt' "$LEGIBLE_LIM" | tr -d ' ')" = "1" ]; then
  lim_ok "la ruta aparece escapada de forma inequivoca"
else
  lim_ko "la ruta aparece escapada de forma inequivoca" "no consta la forma escapada"
fi

if [ "$(grep -Fc 'destino-con-salto\n' "$LEGIBLE_LIM" | tr -d ' ')" = "1" ]; then
  lim_ok "el destino del enlace conserva sus saltos finales, escapados"
else
  lim_ko "el destino del enlace conserva sus saltos finales, escapados" "el destino se ha truncado o no esta escapado"
fi

rm -f "$RUTA_SALTO" "$DD/enlace-con-salto"
DIGEST_TRAS_LIMITES="$(instantanea_digest "$DD")"
if [ "$DIGEST_TRAS_LIMITES" = "$BASE_DIGEST" ]; then
  lim_ok "retiradas solo esas entradas, el digest vuelve al digest base"
else
  lim_ko "retiradas solo esas entradas, el digest vuelve al digest base" "$DIGEST_TRAS_LIMITES"
fi

{
  printf '\n%s\n' '--- LIMITES NUL-SAFE ---'
  printf 'entradas antes: %s · con los dos limites: %s · lineas de la rendicion: %s\n' \
    "$ENTRADAS_BASE" "$ENTRADAS_LIM" "$LINEAS_LIM"
  printf 'digest base: %s\n' "$BASE_DIGEST"
  printf 'digest tras retirar los limites: %s\n' "$DIGEST_TRAS_LIMITES"
  printf 'aserciones fallidas: %s\n' "$LIM_FALLOS"
} >> "$LOG_DETECCION"

printf 'Limites NUL-safe: 5 aserciones · %s fallidas\n' "$LIM_FALLOS"
if [ "$LIM_FALLOS" -ne 0 ]; then FALLIDAS=$(( FALLIDAS + 1 )); fi

# --- Postimagen final, tras las limpiezas ------------------------------------

rm -rf "$TMP/copias"
POST_TXT="$ART/plantillas-postimagen-final.txt"
instantanea_legible "$PLANTILLA" > "$POST_TXT"
POST_DIGEST="$(instantanea_digest "$PLANTILLA")"
POST_ENTRADAS="$(instantanea_entradas "$PLANTILLA")"

{
  printf '=== Arbol de plantillas versionadas: tests/runtime/fixtures/proyecto/** ===\n\n'
  printf '%s\n' '--- PREIMAGEN (antes del primer escenario y antes de copiar nada) ---'
  printf 'entradas: %s\n' "$PRE_ENTRADAS"
  printf 'digest agregado: %s\n\n' "$PRE_DIGEST"
  cat "$PRE_TXT"
  printf '\n%s\n' '--- POSTIMAGEN FINAL (tras todas las limpiezas) ---'
  printf 'entradas: %s\n' "$POST_ENTRADAS"
  printf 'digest agregado: %s\n\n' "$POST_DIGEST"
  cat "$POST_TXT"
  printf '\n%s\n' '--- CONSTATACION ---'
  if [ "$PRE_DIGEST" = "$POST_DIGEST" ]; then
    printf 'Los dos digests agregados COINCIDEN: ninguna prueba modifico lo versionado.\n'
  else
    printf 'DIFIEREN: algo escribio sobre el arbol de plantillas.\n'
  fi
} > "$ART/plantillas-intactas.txt"

if [ "$PRE_DIGEST" = "$POST_DIGEST" ]; then
  printf 'Arbol de plantillas: preimagen y postimagen final coinciden (%s).\n' "$POST_DIGEST"
else
  FALLIDAS=$(( FALLIDAS + 1 ))
  printf 'FALLA: el digest agregado del arbol de plantillas ha cambiado.\n'
  diferencias_legibles "$PRE_TXT" "$POST_TXT"
fi

# --- Huellas del repositorio real --------------------------------------------

if [ "$H_OTROS_INICIO" = "$(h_otros_repo)" ] && [ "$H_STAGED_INICIO" = "$(h_staged_repo)" ]; then
  printf 'Repositorio real: H_OTROS y H_STAGED invariantes durante todo el test.\n'
else
  FALLIDAS=$(( FALLIDAS + 1 ))
  printf 'FALLA: H_OTROS o H_STAGED del repositorio real han cambiado.\n'
fi

printf '\nARTEFACTOS: %s\n' "$ART"
printf 'RESULTADO: %s correctas · %s fallidas\n' "$CORRECTAS" "$FALLIDAS"
[ "$FALLIDAS" -eq 0 ] || exit 1
exit 0
