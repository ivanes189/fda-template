#!/usr/bin/env bash
#
# capturar-ci-rojo.sh — Comprobador headless de las DOS barreras de CI de WP-008.
#
# La composicion de los runs la valida este script versionado, no una persona:
# la persona lanza el comprobador y NO interpreta la salida de gh.
#
# Formas de invocacion admitidas, y ninguna otra combinacion ni orden:
#
#   bash tests/runtime/capturar-ci-rojo.sh RUN_ID C_ROJO [DIRECTORIO_SALIDA]
#   bash tests/runtime/capturar-ci-rojo.sh --verde RUN_ID C_VERDE [DIRECTORIO_SALIDA]
#   bash tests/runtime/capturar-ci-rojo.sh --validar ARCHIVO_JSON C_ROJO
#   bash tests/runtime/capturar-ci-rojo.sh --fixture-root RUTA RUN_ID C_ROJO [DIRECTORIO_SALIDA]
#   bash tests/runtime/capturar-ci-rojo.sh --fixture-root RUTA --verde RUN_ID C_VERDE [DIRECTORIO_SALIDA]
#
# ADQUISICION y VALIDACION PURA estan separadas: el modo --validar no toca la
# red, no recibe directorio de salida y decide solo a partir de un JSON ya
# adquirido.
#
# Codigos de salida, comunes a todos los modos:
#   0  la composicion es exacta
#   1  el run termino pero la composicion no es conforme
#   2  argumentos invalidos, entorno invalido, JSON malformado, respuesta de gh
#      inutilizable, directorio de salida no conforme o expiracion del tiempo
#      maximo
#
# Costura de pruebas, con tres nombres contractuales:
#
#   FDA_CI_TEST_GH                 ejecutable de gh que debe invocarse
#   FDA_CI_TEST_INTERVAL_SECONDS   intervalo de polling
#   FDA_CI_TEST_TIMEOUT_SECONDS    tiempo maximo de espera
#
# Solo se aceptan con --fixture-root RUTA, con la raiz FUERA del repositorio
# real y con el marcador .fda-fixture. En adquisicion real, la presencia de
# cualquiera de las tres produce exit 2 ANTES de ejecutar gh.
#
# Una captura admisible como evidencia real solo puede proceder de modo=real.

set -u

EXIT_OK=0
EXIT_NO_CONFORME=1
EXIT_ABORTO=2

SCRIPT_DIR=$( cd -P "$(dirname "$0")" >/dev/null 2>&1 && pwd -P ) || exit 2
REPO=$( cd -P "$SCRIPT_DIR/../.." >/dev/null 2>&1 && pwd -P ) || exit 2

# El tiempo maximo contractual de espera es de 20 minutos, con intervalo de 15
# segundos. No existe la espera indefinida.
TIMEOUT_REAL=1200
INTERVALO_REAL=15

JOB_GOBIERNO="Gobierno FDA"
MARCA_PREFLIGHT="preflight"

abortar() {
  printf 'ABORTADO: %s\n' "$1" >&2
  exit $EXIT_ABORTO
}

dentro_de() {
  case "$1" in
    "$2") return 0 ;;
    "$2"/*) return 0 ;;
  esac
  return 1
}

es_entero_positivo() {
  case "$1" in
    ''|*[!0-9]*) return 1 ;;
  esac
  [ "$1" -gt 0 ] 2>/dev/null
}

# --- 1. Argumentos: orden estricto -------------------------------------------

[ "$#" -ge 1 ] || abortar "faltan argumentos"

MODO_FIXTURE=0
RAIZ_FIX_ARG=""
RAIZ_FIX=""
ES_VERDE=0
ES_VALIDAR=0

if [ "$1" = "--validar" ]; then
  ES_VALIDAR=1
  shift
  [ "$#" -eq 2 ] || abortar "--validar exige exactamente ARCHIVO_JSON y el hash esperado"
else
  if [ "$1" = "--fixture-root" ]; then
    MODO_FIXTURE=1
    [ "$#" -ge 2 ] || abortar "--fixture-root exige una ruta"
    RAIZ_FIX_ARG="$2"
    shift 2
  fi
  [ "$#" -ge 1 ] || abortar "faltan argumentos"
  if [ "$1" = "--verde" ]; then
    ES_VERDE=1
    shift
  fi
  [ "$#" -ge 2 ] || abortar "faltan RUN_ID y el hash esperado"
  [ "$#" -le 3 ] || abortar "demasiados argumentos"
fi

for _a in "$@"; do
  case "$_a" in
    -*) abortar "argumento no reconocido o fuera de orden: $_a" ;;
  esac
done

MODO="real"
[ "$MODO_FIXTURE" -eq 1 ] && MODO="fixture"

# --- 2. Validador puro --------------------------------------------------------

validar_json() {
  # $1 archivo JSON · $2 hash esperado · $3 rojo|verde
  python3 - "$1" "$2" "$3" "$JOB_GOBIERNO" "$MARCA_PREFLIGHT" <<'PY'
import json
import sys

ruta, esperado, fase, job_gobierno, marca_preflight = sys.argv[1:6]

FALLIDOS = ("failure", "cancelled", "timed_out", "startup_failure", "action_required")


def salir(codigo, *lineas):
    for linea in lineas:
        print(linea)
    sys.exit(codigo)


try:
    with open(ruta, "r", encoding="utf-8") as fh:
        run = json.load(fh)
except Exception as exc:
    salir(2, "ABORTADO: respuesta inutilizable o JSON malformado: %s" % exc)

if not isinstance(run, dict):
    salir(2, "ABORTADO: la respuesta no es un objeto JSON")

jobs = run.get("jobs")
if not isinstance(jobs, list):
    salir(2, "ABORTADO: la respuesta no trae la lista de jobs")

no_conformes = []


def exigir(numero, titulo, condicion, detalle=""):
    if condicion:
        print("[%s] %-52s CONFORME" % (numero, titulo))
    else:
        print("[%s] %-52s NO CONFORME: %s" % (numero, titulo, detalle))
        no_conformes.append(numero)


terminado = run.get("status") == "completed"
conclusion = run.get("conclusion")
head = run.get("headSha")

if fase == "verde":
    exigir(1, "El run ha terminado", terminado, "status=%s" % run.get("status"))
    exigir(2, "headSha es igual a C_VERDE", head == esperado, "headSha=%s" % head)
    exigir(3, "conclusion es success", conclusion == "success", "conclusion=%s" % conclusion)
else:
    exigir(1, "El run ha terminado", terminado, "status=%s" % run.get("status"))
    exigir(2, "headSha es igual a C_ROJO", head == esperado, "headSha=%s" % head)
    exigir(
        3,
        "conclusion es failure y nunca cancelled",
        conclusion == "failure",
        "conclusion=%s" % conclusion,
    )

    gobierno = None
    otros = []
    for job in jobs:
        if not isinstance(job, dict):
            salir(2, "ABORTADO: un job de la respuesta no es un objeto")
        if job.get("name") == job_gobierno:
            gobierno = job
        else:
            otros.append(job)

    if gobierno is None:
        salir(2, "ABORTADO: la respuesta no contiene el job '%s'" % job_gobierno)

    pasos = gobierno.get("steps")
    if not isinstance(pasos, list) or not pasos:
        salir(2, "ABORTADO: el job '%s' no trae pasos" % job_gobierno)

    indice = None
    for i, paso in enumerate(pasos):
        if not isinstance(paso, dict):
            salir(2, "ABORTADO: un paso de '%s' no es un objeto" % job_gobierno)
        if marca_preflight in (paso.get("name") or ""):
            indice = i
            break

    if indice is None:
        salir(2, "ABORTADO: no se encuentra el paso del preflight en '%s'" % job_gobierno)

    anteriores = pasos[:indice]
    preflight = pasos[indice]
    posteriores = pasos[indice + 1:]

    malos_antes = [p.get("name") for p in anteriores if p.get("conclusion") != "success"]
    exigir(
        4,
        "Pasos anteriores al preflight en success",
        not malos_antes,
        "no son success: %s" % ", ".join(str(n) for n in malos_antes),
    )

    exigir(
        5,
        "El paso del preflight esta en failure",
        preflight.get("conclusion") == "failure",
        "conclusion=%s" % preflight.get("conclusion"),
    )

    malos_despues = [p.get("name") for p in posteriores if p.get("conclusion") != "skipped"]
    exigir(
        6,
        "Pasos posteriores del mismo job en skipped",
        not malos_despues,
        "no son skipped: %s" % ", ".join(str(n) for n in malos_despues),
    )

    malos_jobs = [j.get("name") for j in otros if j.get("conclusion") != "success"]
    exigir(
        7,
        "Los demas jobs del workflow en success",
        not malos_jobs,
        "no son success: %s" % ", ".join(str(n) for n in malos_jobs),
    )

    segundas = []
    for job in jobs:
        pasos_job = job.get("steps")
        if pasos_job is None:
            pasos_job = []
        if not isinstance(pasos_job, list):
            salir(2, "ABORTADO: los pasos de '%s' no son una lista" % job.get("name"))
        for paso in pasos_job:
            if not isinstance(paso, dict):
                salir(2, "ABORTADO: un paso de '%s' no es un objeto" % job.get("name"))
            if paso is preflight:
                continue
            if (paso.get("conclusion") or "") in FALLIDOS:
                segundas.append("%s :: %s" % (job.get("name"), paso.get("name")))
    exigir(
        8,
        "No existe una segunda causa de fallo en el run",
        not segundas,
        "tambien fallan: %s" % ", ".join(segundas),
    )

print("")
print("run_id: %s" % run.get("databaseId"))
print("url: %s" % run.get("url"))
print("headSha: %s" % head)
print("conclusion: %s" % conclusion)
print("")
print("RESULTADO: %s no conformidades" % len(no_conformes))
sys.exit(1 if no_conformes else 0)
PY
}

# --- 3. Modo --validar: puro, sin red y sin directorio de salida -------------

if [ "$ES_VALIDAR" -eq 1 ]; then
  ARCHIVO="$1"
  ESPERADO="$2"
  [ -f "$ARCHIVO" ] || abortar "el archivo JSON no existe: $ARCHIVO"
  [ -r "$ARCHIVO" ] || abortar "el archivo JSON no es legible: $ARCHIVO"
  validar_json "$ARCHIVO" "$ESPERADO" "rojo"
  case $? in
    0) exit $EXIT_OK ;;
    1) exit $EXIT_NO_CONFORME ;;
    *) exit $EXIT_ABORTO ;;
  esac
fi

# --- 4. Costura de pruebas: nombres, modo y rechazo en produccion ------------
#
# Toda la validacion es FISICA, sobre rutas canonicalizadas, no textual, y
# ocurre ANTES de ejecutar el stub y ANTES de cualquier acceso a la red.

STUB="${FDA_CI_TEST_GH:-}"
INTERVALO_VAR="${FDA_CI_TEST_INTERVAL_SECONDS:-}"
TIMEOUT_VAR="${FDA_CI_TEST_TIMEOUT_SECONDS:-}"

if [ "$MODO" = "real" ]; then
  [ -z "$STUB" ] || abortar "FDA_CI_TEST_GH no se admite en adquisicion real"
  [ -z "$INTERVALO_VAR" ] || abortar "FDA_CI_TEST_INTERVAL_SECONDS no se admite en adquisicion real"
  [ -z "$TIMEOUT_VAR" ] || abortar "FDA_CI_TEST_TIMEOUT_SECONDS no se admite en adquisicion real"
  GH="gh"
  INTERVALO="$INTERVALO_REAL"
  TIMEOUT="$TIMEOUT_REAL"
  command -v gh >/dev/null 2>&1 || abortar "gh no esta disponible"
else
  [ -d "$RAIZ_FIX_ARG" ] || abortar "la raiz de fixture no existe o no es un directorio: $RAIZ_FIX_ARG"
  RAIZ_FIX=$( cd -P "$RAIZ_FIX_ARG" >/dev/null 2>&1 && pwd -P ) || abortar "raiz de fixture no canonicalizable"
  dentro_de "$RAIZ_FIX" "$REPO" && abortar "--fixture-root canonicaliza DENTRO del repositorio real: $RAIZ_FIX"

  MARCADOR="$RAIZ_FIX/.fda-fixture"
  [ -e "$MARCADOR" ] || abortar "la raiz de fixture no lleva el marcador .fda-fixture"
  [ -L "$MARCADOR" ] && abortar "el marcador .fda-fixture es un enlace simbolico"
  [ -f "$MARCADOR" ] || abortar "el marcador .fda-fixture no es un archivo regular"

  [ -n "$STUB" ] || abortar "en modo fixture falta FDA_CI_TEST_GH"
  [ -n "$INTERVALO_VAR" ] || abortar "en modo fixture falta FDA_CI_TEST_INTERVAL_SECONDS"
  [ -n "$TIMEOUT_VAR" ] || abortar "en modo fixture falta FDA_CI_TEST_TIMEOUT_SECONDS"

  [ -L "$STUB" ] && abortar "FDA_CI_TEST_GH es un enlace simbolico"
  [ -f "$STUB" ] || abortar "FDA_CI_TEST_GH no es un archivo regular"
  [ -x "$STUB" ] || abortar "FDA_CI_TEST_GH no es ejecutable"
  STUB_DIR=$( cd -P "$(dirname "$STUB")" >/dev/null 2>&1 && pwd -P ) || abortar "stub no canonicalizable"
  STUB_FISICO="$STUB_DIR/$(basename "$STUB")"
  dentro_de "$STUB_FISICO" "$RAIZ_FIX" || abortar "el stub esta fuera de la raiz fisica del fixture"

  es_entero_positivo "$INTERVALO_VAR" || abortar "FDA_CI_TEST_INTERVAL_SECONDS no es un entero positivo"
  es_entero_positivo "$TIMEOUT_VAR" || abortar "FDA_CI_TEST_TIMEOUT_SECONDS no es un entero positivo"

  GH="$STUB_FISICO"
  INTERVALO="$INTERVALO_VAR"
  TIMEOUT="$TIMEOUT_VAR"
fi

RUN_ID="$1"
ESPERADO="$2"
SALIDA_ARG="${3:-}"

[ -n "$RUN_ID" ] || abortar "RUN_ID vacio"
[ -n "$ESPERADO" ] || abortar "el hash esperado esta vacio"

# --- 5. Directorio de salida: se comprueba ANTES de tocar la red -------------

if [ -n "$SALIDA_ARG" ]; then
  # Nunca se crea primero una ruta proporcionada por el llamante para poder
  # canonicalizarla: si no existe, se rechaza.
  [ -e "$SALIDA_ARG" ] || abortar "el directorio de salida no existe y no se crea: $SALIDA_ARG"
  [ -L "$SALIDA_ARG" ] && abortar "el directorio de salida es un enlace simbolico"
  [ -d "$SALIDA_ARG" ] || abortar "el directorio de salida no es un directorio"
  SALIDA=$( cd -P "$SALIDA_ARG" >/dev/null 2>&1 && pwd -P ) || abortar "directorio de salida no canonicalizable"
  dentro_de "$SALIDA" "$REPO" && abortar "el directorio de salida resuelve DENTRO del repositorio real"
else
  # Plantilla explicita: 'mktemp -d' sin plantilla ignora TMPDIR en macOS.
  _b="$(mktemp -d "${TMPDIR:-/tmp}/fda-wp008-ci.XXXXXX" 2>/dev/null)" || abortar "mktemp -d ha fallado"
  SALIDA=$( cd -P "$_b" >/dev/null 2>&1 && pwd -P ) || abortar "temporal no canonicalizable"
  if dentro_de "$SALIDA" "$REPO"; then
    rmdir "$SALIDA" 2>/dev/null
    abortar "el temporal de mktemp -d queda DENTRO del repositorio (revisa TMPDIR)"
  fi
  # La seccion 9 exige las DOS cosas cuando se opera sobre una copia externa:
  # fuera del repositorio y fuera de la raiz fisica del fixture.
  if [ "$MODO" = "fixture" ] && dentro_de "$SALIDA" "$RAIZ_FIX"; then
    rmdir "$SALIDA" 2>/dev/null
    abortar "el temporal de mktemp -d queda DENTRO de la copia externa (revisa TMPDIR)"
  fi
fi

FASE="rojo"
[ "$ES_VERDE" -eq 1 ] && FASE="verde"

LOG="$SALIDA/captura-$FASE.log"
RESPUESTA="$SALIDA/run-$FASE.json"

# El modo consta INEQUIVOCAMENTE en la primera linea del log.
printf 'modo=%s\n' "$MODO" > "$LOG"
{
  printf 'fase=%s\n' "$FASE"
  printf 'run_id=%s\n' "$RUN_ID"
  printf 'hash_esperado=%s\n' "$ESPERADO"
  printf 'salida=%s\n' "$SALIDA"
  printf 'intervalo=%s\n' "$INTERVALO"
  printf 'timeout=%s\n' "$TIMEOUT"
} >> "$LOG"

# --- 6. Adquisicion con polling acotado --------------------------------------

CAMPOS="status,conclusion,headSha,databaseId,url,jobs"
TRANSCURRIDO=0
TERMINADO=0

while :; do
  if ! "$GH" run view "$RUN_ID" --json "$CAMPOS" > "$RESPUESTA" 2>>"$LOG"; then
    printf 'ABORTADO: la adquisicion ha fallado\n' >> "$LOG"
    abortar "la adquisicion ha fallado (ver $LOG)"
  fi
  ESTADO="$(python3 -c 'import json,sys
try:
    d = json.load(open(sys.argv[1]))
except Exception:
    print("__ILEGIBLE__"); raise SystemExit(0)
print(d.get("status") if isinstance(d, dict) else "__ILEGIBLE__")' "$RESPUESTA" 2>/dev/null)"
  if [ "$ESTADO" = "__ILEGIBLE__" ] || [ -z "$ESTADO" ]; then
    printf 'ABORTADO: respuesta de adquisicion inutilizable\n' >> "$LOG"
    abortar "respuesta de adquisicion inutilizable (ver $LOG)"
  fi
  printf 'sondeo t=%ss status=%s\n' "$TRANSCURRIDO" "$ESTADO" >> "$LOG"
  if [ "$ESTADO" = "completed" ]; then
    TERMINADO=1
    break
  fi
  if [ "$TRANSCURRIDO" -ge "$TIMEOUT" ]; then
    break
  fi
  sleep "$INTERVALO"
  TRANSCURRIDO=$(( TRANSCURRIDO + INTERVALO ))
done

if [ "$TERMINADO" -ne 1 ]; then
  printf 'ABORTADO: expiro el tiempo maximo de espera (%ss)\n' "$TIMEOUT" >> "$LOG"
  abortar "expiro el tiempo maximo de espera de $TIMEOUT segundos"
fi

# --- 7. Delegacion al validador puro -----------------------------------------

VEREDICTO="$(validar_json "$RESPUESTA" "$ESPERADO" "$FASE")"
COD=$?
printf '%s\n' "$VEREDICTO"
printf '%s\n' "$VEREDICTO" >> "$LOG"
printf 'exit=%s\n' "$COD" >> "$LOG"
printf 'log: %s\n' "$LOG"
case "$COD" in
  0) exit $EXIT_OK ;;
  1) exit $EXIT_NO_CONFORME ;;
  *) exit $EXIT_ABORTO ;;
esac
