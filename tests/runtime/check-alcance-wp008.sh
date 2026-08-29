#!/usr/bin/env bash
#
# check-alcance-wp008.sh — Comprobaciones LOCALES de conformidad de WP-008.
#
# Dos responsabilidades, ambas especificas de este WP, ambas locales y
# redundantes, y ninguna generica:
#
#   a) ALCANCE      — que ninguna ruta del cambio quede fuera de los veintidos
#                     patrones de '## Archivos permitidos'.
#   b) CUARENTENA   — que ningun script de este WP enumere lo no versionado.
#
# Uso:
#   bash tests/runtime/check-alcance-wp008.sh [--lista ARCHIVO_NUL]
#   bash tests/runtime/check-alcance-wp008.sh --cuarentena
#   bash tests/runtime/check-alcance-wp008.sh --cuarentena --lista-scripts ARCHIVO_NUL
#
# Sin --lista, el modo de alcance hace DOS cosas en una sola invocacion:
# comprueba el diff real y despues ejecuta automaticamente las DOS
# demostraciones, usando --lista como costura interna.
#
# Sin --lista-scripts, el modo --cuarentena hace DOS cosas: el escaneo real
# sobre los SIETE scripts de la lista cerrada —el escaner incluido— y despues
# las SEIS pruebas, usando --lista-scripts como costura interna.
#
# Un resultado esperado de 1 cuenta como CORRECTO cuando se obtiene 1.
#
# Salida: exit 0 conforme · exit 1 no conforme · exit 2 argumentos o entorno.
#
# QUE NO ES. Esta comprobacion es local y redundante para WP-008 y NO CIERRA NI
# SATISFACE REQ-FDA-001: el mecanismo post-hoc global que ese requisito exige
# sigue pendiente de WP-002 y WP-005. WP-008 endurece la capa preventiva y
# verifica su propio diff.

set -u

EXIT_OK=0
EXIT_NO_CONFORME=1
EXIT_ARGS=2

SCRIPT_DIR=$( cd -P "$(dirname "$0")" >/dev/null 2>&1 && pwd -P ) || exit 2
REPO=$( cd -P "$SCRIPT_DIR/../.." >/dev/null 2>&1 && pwd -P ) || exit 2
PATRONES="$SCRIPT_DIR/fixtures/cuarentena/patrones.txt"

abortar() { printf 'ABORTADO: %s\n' "$1" >&2; exit $EXIT_ARGS; }

dentro_de() {
  case "$1" in
    "$2") return 0 ;;
    "$2"/*) return 0 ;;
  esac
  return 1
}

crear_temporal() {
  # Plantilla explicita: 'mktemp -d' sin plantilla ignora TMPDIR en macOS.
  _b="$(mktemp -d "${TMPDIR:-/tmp}/fda-wp008-alcance.XXXXXX" 2>/dev/null)" || abortar "mktemp -d ha fallado"
  _c=$( cd -P "$_b" >/dev/null 2>&1 && pwd -P ) || abortar "temporal no canonicalizable"
  if dentro_de "$_c" "$REPO"; then
    rmdir "$_c" 2>/dev/null
    abortar "el temporal de mktemp -d queda DENTRO del repositorio (revisa TMPDIR)"
  fi
  printf '%s' "$_c"
}

# --- Los VEINTIDOS patrones permitidos, transcritos literalmente -------------

PERMITIDOS='.claude/settings.json
.github/workflows/ci.yml
tests/runtime/check-config.sh
tests/runtime/test-check-config.sh
tests/runtime/test-protocolo.sh
tests/runtime/capturar-ci-rojo.sh
tests/runtime/test-capturar-ci-rojo.sh
tests/runtime/check-alcance-wp008.sh
tests/runtime/command-canonico.txt
tests/runtime/reglas-canonicas.txt
tests/runtime/fixtures/config/**
tests/runtime/fixtures/proyecto/**
tests/runtime/fixtures/ci/**
tests/runtime/fixtures/cuarentena/**
evidence/WP-008/**
docs/02-guia-fabrica-desarrollo-agentica.md
docs/manual/MANUAL.md
docs/manual/01-instalacion.md
docs/manual/02-ciclo-de-un-wp.md
docs/manual/04-agentes.md
docs/manual/07-troubleshooting.md
specs/requirements/SEC-001-sin-secretos.md'

# La lista CERRADA y NOMINAL de scripts de este WP. No se recorre
# tests/runtime/ de forma recursiva y no se usa ningun comodin sobre ese arbol,
# porque contiene tambien rutas de WP-012, con su propio control equivalente.
# La lista INCLUYE AL PROPIO ESCANER.
SCRIPTS_WP='tests/runtime/check-config.sh
tests/runtime/test-check-config.sh
tests/runtime/test-protocolo.sh
tests/runtime/capturar-ci-rojo.sh
tests/runtime/test-capturar-ci-rojo.sh
tests/runtime/check-alcance-wp008.sh
evidence/WP-008/parche/aplicar.sh'

ruta_permitida() {
  _p="$1"
  while IFS= read -r _pat; do
    [ -z "$_pat" ] && continue
    case "$_pat" in
      */\*\*)
        _pref="${_pat%\*\*}"
        case "$_p" in
          "$_pref"*) return 0 ;;
        esac
        ;;
      *)
        [ "$_p" = "$_pat" ] && return 0
        ;;
    esac
  done <<EOF
$PERMITIDOS
EOF
  return 1
}

# --- Modo de alcance ----------------------------------------------------------

comprobar_lista() {
  _archivo="$1"
  [ -f "$_archivo" ] || abortar "la lista no existe: $_archivo"
  _fuera=0
  _total=0
  while IFS= read -r -d '' _ruta; do
    [ -z "$_ruta" ] && continue
    _total=$(( _total + 1 ))
    if ruta_permitida "$_ruta"; then
      :
    else
      _fuera=$(( _fuera + 1 ))
      printf 'FUERA DE ALCANCE: %s\n' "$_ruta"
    fi
  done < "$_archivo"
  printf 'rutas comprobadas: %s · fuera de alcance: %s\n' "$_total" "$_fuera"
  [ "$_fuera" -eq 0 ] && return $EXIT_OK
  return $EXIT_NO_CONFORME
}

# --- Modo cuarentena ----------------------------------------------------------

leer_seccion() {
  awk -v s="$1" '
    /^\[/ { dentro = ($0 == "[" s "]"); next }
    dentro && NF && $0 !~ /^#/ { print }
  ' "$PATRONES"
}

escanear_scripts() {
  _archivo="$1"
  [ -f "$PATRONES" ] || abortar "falta el archivo de patrones: $PATRONES"

  TOKEN="$(leer_seccion token | head -1)"
  [ -n "$TOKEN" ] || abortar "el archivo de patrones no declara el token"
  TOK1="${TOKEN%% *}"
  TOK2="${TOKEN#* }"
  ACEPTADAS="$(leer_seccion aceptadas)"
  PROHIBIDAS="$(leer_seccion prohibidas)"
  [ -n "$ACEPTADAS" ] || abortar "el archivo de patrones no declara formas aceptadas"
  [ -n "$PROHIBIDAS" ] || abortar "el archivo de patrones no declara formas prohibidas"

  _hallazgos=0
  _revisados=0

  while IFS= read -r -d '' _rel; do
    [ -z "$_rel" ] && continue
    _f="$_rel"
    [ -f "$_f" ] || _f="$REPO/$_rel"
    if [ ! -f "$_f" ]; then
      printf 'HALLAZGO %s:0 el archivo no existe\n' "$_rel"
      _hallazgos=$(( _hallazgos + 1 ))
      continue
    fi
    _revisados=$(( _revisados + 1 ))
    _n=0
    while IFS= read -r _linea; do
      _n=$(( _n + 1 ))

      # Hallazgo 2 — cualquier forma prohibida, por si sola.
      while IFS= read -r _mala; do
        [ -z "$_mala" ] && continue
        case "$_linea" in
          *"$_mala"*)
            printf 'HALLAZGO %s:%s forma prohibida presente\n' "$_rel" "$_n"
            _hallazgos=$(( _hallazgos + 1 ))
            ;;
        esac
      done <<EOF
$PROHIBIDAS
EOF

      # Una invocacion real es la primera palabra del token seguida, en la MISMA
      # linea logica, de la segunda, admitiendo entre medias opciones y
      # argumentos —entrecomillados, expandidos o desnudos—, pero NUNCA un
      # separador de comandos: cubre la forma directa y la forma con -C sobre
      # otra raiz, y no confunde dos ordenes encadenadas con una sola.
      _ere_argumento="(-[^[:space:]]+|\"[^\"]*\"|'[^']*'|\\\$[^[:space:]]+|[^-\"'\\\$;|&\`[:space:]][^;|&\`[:space:]]*)[[:space:]]+"
      _ere_invocacion="(^|[^A-Za-z-])${TOK1}[[:space:]]+(${_ere_argumento})*${TOK2}([^A-Za-z]|$)"
      # Mando LITERAL es solo el que esta en posicion real de mando y seguido de
      # separacion de argumentos. Que la palabra aparezca DENTRO de una
      # sustitucion —$(printf git) o su forma con acentos graves— no la
      # convierte en un mando literal conforme.
      _ere_mando_literal="(^|[^A-Za-z-])${TOK1}[[:space:]]"
      # Mando ensamblado: el ejecutable se obtiene de una variable.
      _ere_ensamblaje="\\\$[A-Za-z_({][^[:space:]]*[[:space:]]+${TOK2}([^A-Za-z]|$)"
      # Mando construido por sustitucion de comando, en sus dos formas: lo que
      # precede a la segunda palabra del token es el cierre de la sustitucion.
      _ere_subst_mando="[)\`][[:space:]]+${TOK2}([^A-Za-z]|$)"
      # Sustitucion situada ENTRE el mando literal y la segunda palabra.
      _ere_subst_intermedia="(^|[^A-Za-z-])${TOK1}[[:space:]]+[^;|&]*(\\\$\\(|\`)[^;|&]*${TOK2}([^A-Za-z]|$)"

      # Hallazgo 3 — invocacion NO VERIFICABLE por lectura estatica.
      if printf '%s' "$_linea" | grep -qE "(^|[^A-Za-z])${TOK1}[[:space:]]*\\\\$"; then
        printf 'HALLAZGO %s:%s invocacion partida por continuacion de linea\n' "$_rel" "$_n"
        _hallazgos=$(( _hallazgos + 1 ))
      fi
      if { printf '%s' "$_linea" | grep -qE "$_ere_ensamblaje" || \
           printf '%s' "$_linea" | grep -qE "$_ere_subst_mando"; } && \
         ! printf '%s' "$_linea" | grep -qE "$_ere_mando_literal"; then
        printf 'HALLAZGO %s:%s mando ensamblado por sustitucion o variable\n' "$_rel" "$_n"
        _hallazgos=$(( _hallazgos + 1 ))
      fi
      if printf '%s' "$_linea" | grep -qE "$_ere_subst_intermedia"; then
        printf 'HALLAZGO %s:%s sustitucion de comando dentro de la invocacion\n' "$_rel" "$_n"
        _hallazgos=$(( _hallazgos + 1 ))
      fi
      if printf '%s' "$_linea" | grep -qE "(^|[^A-Za-z])alias[[:space:]]" && \
         printf '%s' "$_linea" | grep -qE "(^|[^A-Za-z])${TOK2}([^A-Za-z]|$)"; then
        printf 'HALLAZGO %s:%s invocacion encubierta tras un alias\n' "$_rel" "$_n"
        _hallazgos=$(( _hallazgos + 1 ))
      fi

      # Hallazgo 1 — invocacion real del token sin ninguna forma aceptada en la
      # MISMA linea logica.
      if printf '%s' "$_linea" | grep -qE "$_ere_invocacion"; then
        _tiene=0
        while IFS= read -r _buena; do
          [ -z "$_buena" ] && continue
          case "$_linea" in
            *"$_buena"*) _tiene=1 ;;
          esac
        done <<EOF
$ACEPTADAS
EOF
        if [ "$_tiene" -eq 0 ]; then
          printf 'HALLAZGO %s:%s invocacion del estado de Git sin forma aceptada\n' "$_rel" "$_n"
          _hallazgos=$(( _hallazgos + 1 ))
        fi
      fi
    done < "$_f"
  done < "$_archivo"

  printf 'archivos revisados: %s · hallazgos: %s\n' "$_revisados" "$_hallazgos"
  [ "$_hallazgos" -eq 0 ] && return $EXIT_OK
  return $EXIT_NO_CONFORME
}

lista_nul_desde() {
  # $1 destino · resto: lineas
  _dest="$1"; shift
  : > "$_dest"
  while IFS= read -r _l; do
    [ -z "$_l" ] && continue
    printf '%s\0' "$_l" >> "$_dest"
  done <<EOF
$1
EOF
}

# --- Argumentos ---------------------------------------------------------------

MODO="alcance"
LISTA=""

if [ "$#" -gt 0 ] && [ "$1" = "--cuarentena" ]; then
  MODO="cuarentena"
  shift
  if [ "$#" -gt 0 ]; then
    [ "$1" = "--lista-scripts" ] || abortar "argumento no reconocido: $1"
    [ "$#" -eq 2 ] || abortar "--lista-scripts exige exactamente un archivo"
    LISTA="$2"
  fi
elif [ "$#" -gt 0 ]; then
  [ "$1" = "--lista" ] || abortar "argumento no reconocido: $1"
  [ "$#" -eq 2 ] || abortar "--lista exige exactamente un archivo"
  LISTA="$2"
fi

# --- Costuras: comprueban SOLO la lista dada y no disparan las pruebas -------

if [ -n "$LISTA" ]; then
  if [ "$MODO" = "cuarentena" ]; then
    escanear_scripts "$LISTA"
    exit $?
  fi
  comprobar_lista "$LISTA"
  exit $?
fi

TMP="$(crear_temporal)"
trap 'rm -rf "$TMP"' EXIT
GLOBAL=$EXIT_OK

if [ "$MODO" = "alcance" ]; then
  printf '=== Alcance de WP-008 ===\n\n'
  printf -- '--- Diff real de la rama contra main ---\n'
  # La referencia es 'main', literalmente, como exige el contrato. Que la rama
  # local este sincronizada es una PRECONDICION OPERATIVA de la persona, no una
  # licencia para que este script compare contra otra cosa. Y un fallo aqui no
  # se degrada a lista vacia: eso seria fail-open en un WP fail-closed.
  git -C "$REPO" rev-parse --verify --quiet main >/dev/null 2>&1 \
    || abortar "no existe o no es resoluble la referencia main; sincronizala antes de comprobar el alcance"
  printf 'referencia de comparacion: main (%s)\n' "$(git -C "$REPO" rev-parse main)"
  git -C "$REPO" diff --name-only -z main...HEAD > "$TMP/diff.nul" 2>/dev/null \
    || abortar "git diff contra main...HEAD ha fallado"
  comprobar_lista "$TMP/diff.nul"
  COD=$?
  printf 'diff real: exit %s (esperado 0)\n\n' "$COD"
  [ "$COD" -ne 0 ] && GLOBAL=$EXIT_NO_CONFORME

  printf -- '--- Demostracion 1: lista conforme ---\n'
  lista_nul_desde "$TMP/d1.nul" 'tests/runtime/check-config.sh
tests/runtime/fixtures/config/conforme.json
evidence/WP-008/parche/aplicar.sh
docs/manual/MANUAL.md
specs/requirements/SEC-001-sin-secretos.md'
  comprobar_lista "$TMP/d1.nul"
  D1=$?
  printf 'demostracion 1: obtenido %s · esperado 0\n\n' "$D1"
  [ "$D1" -ne 0 ] && GLOBAL=$EXIT_NO_CONFORME

  printf -- '--- Demostracion 2: una ruta de WP-012 no admitida ---\n'
  lista_nul_desde "$TMP/d2.nul" 'tests/runtime/check-config.sh
tests/runtime/empirico/runner-empirico.sh'
  comprobar_lista "$TMP/d2.nul"
  D2=$?
  printf 'demostracion 2: obtenido %s · esperado 1\n\n' "$D2"
  [ "$D2" -ne 1 ] && GLOBAL=$EXIT_NO_CONFORME

  printf 'RESULTADO: alcance %s\n' "$( [ "$GLOBAL" -eq 0 ] && printf 'conforme' || printf 'NO conforme' )"
  exit $GLOBAL
fi

# --- Modo cuarentena agregado -------------------------------------------------

printf '=== Invariante de cuarentena de WP-008 ===\n\n'
printf -- '--- Escaneo real: los SIETE scripts de la lista cerrada ---\n'
lista_nul_desde "$TMP/scripts.nul" "$SCRIPTS_WP"
escanear_scripts "$TMP/scripts.nul"
REAL=$?
printf 'escaneo real: obtenido %s · esperado 0\n\n' "$REAL"
[ "$REAL" -ne 0 ] && GLOBAL=$EXIT_NO_CONFORME

# Las SEIS pruebas deterministas: dos positivas y cuatro negativas. Los archivos
# se construyen en el temporal, se listan con --lista-scripts y NUNCA se
# ejecutan.
TOKEN="$(leer_seccion token | head -1)"
ACEPT1="$(leer_seccion aceptadas | sed -n '1p')"
ACEPT2="$(leer_seccion aceptadas | sed -n '2p')"
PROH1="$(leer_seccion prohibidas | sed -n '3p')"
PROH2="$(leer_seccion prohibidas | sed -n '1p')"
PROH3="$(leer_seccion prohibidas | sed -n '2p')"

PRUEBAS="$TMP/pruebas"
mkdir -p "$PRUEBAS"

# Las pruebas 2 y 3 ejercitan la forma con -C sobre otra raiz, que es la que
# aparece de verdad en los scripts de este WP: sin ellas, la deteccion de esa
# forma no estaria demostrada por ninguna negativa.
T1="${TOKEN%% *}"
T2="${TOKEN#* }"
printf '%s %s | wc -l\n' "$TOKEN" "$ACEPT1" > "$PRUEBAS/p1-positiva.txt"
printf '%s -C "$RAIZ" %s %s | wc -l\n' "$T1" "$T2" "$ACEPT2" > "$PRUEBAS/p2-positiva.txt"
printf '%s -C "$RAIZ" %s --porcelain=v1 | wc -l\n' "$T1" "$T2" > "$PRUEBAS/p3-negativa.txt"
printf '%s %s | wc -l\n' "$TOKEN" "$PROH1" > "$PRUEBAS/p4-negativa.txt"
{ printf '%s %s | wc -l\n' "$TOKEN" "$PROH2"; printf '%s %s | wc -l\n' "$TOKEN" "$PROH3"; } > "$PRUEBAS/p5-negativa.txt"
# La negativa 6 materializa las CUATRO formas no verificables del contrato:
# continuacion de linea, variable, sustitucion $(...) y acentos graves. Sigue
# siendo UNA prueba: no se crea una septima.
{
  printf '%s \\\n' "$T1"
  printf '  %s %s\n' "$T2" "$ACEPT1"
  printf 'G=%s\n' "$T1"
  printf '"$G" %s %s\n' "$T2" "$ACEPT1"
  printf '$(printf %s) %s %s\n' "$T1" "$T2" "$ACEPT1"
  printf '`printf %s` %s %s\n' "$T1" "$T2" "$ACEPT1"
} > "$PRUEBAS/p6-negativa.txt"

prueba_cuarentena() {
  _n="$1"; _archivo="$2"; _esperado="$3"; _titulo="$4"
  printf '%s\0' "$_archivo" > "$TMP/una.nul"
  _salida="$(escanear_scripts "$TMP/una.nul")"
  _cod=$?
  if [ "$_cod" -eq "$_esperado" ]; then
    printf '[prueba %s] %-46s obtenido %s · esperado %s  OK\n' "$_n" "$_titulo" "$_cod" "$_esperado"
  else
    printf '[prueba %s] %-46s obtenido %s · esperado %s  FALLA\n' "$_n" "$_titulo" "$_cod" "$_esperado"
    GLOBAL=$EXIT_NO_CONFORME
  fi
  printf '%s\n' "$_salida" | sed 's/^/           | /'
}

printf -- '--- Las SEIS pruebas: dos positivas y cuatro negativas ---\n'
prueba_cuarentena 1 "$PRUEBAS/p1-positiva.txt" 0 "positiva: forma directa con forma aceptada"
prueba_cuarentena 2 "$PRUEBAS/p2-positiva.txt" 0 "positiva: forma con -C RUTA y forma aceptada"
prueba_cuarentena 3 "$PRUEBAS/p3-negativa.txt" 1 "negativa: -C RUTA sin ninguna forma aceptada"
prueba_cuarentena 4 "$PRUEBAS/p4-negativa.txt" 1 "negativa: forma prohibida corta"
prueba_cuarentena 5 "$PRUEBAS/p5-negativa.txt" 1 "negativa: forma prohibida larga, dos variantes"
prueba_cuarentena 6 "$PRUEBAS/p6-negativa.txt" 1 "negativa: no verificable"

printf '\nRESULTADO: cuarentena %s\n' "$( [ "$GLOBAL" -eq 0 ] && printf 'conforme' || printf 'NO conforme' )"
exit $GLOBAL
