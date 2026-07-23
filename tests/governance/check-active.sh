#!/usr/bin/env bash
#
# check-active.sh — Valida la coherencia del estado operativo de la FDA.
#
# El estado operativo vive en work-packages/ACTIVE (ADR-001, invariante I1).
# Este script reconoce TRES estados y los distingue por código de salida y por
# texto, para que el log de CI sea legible sin abrir el repositorio.
#
#   exit 0 · REPOSO  — ACTIVE vacío. Estado VÁLIDO: no hay trabajo en curso.
#                      El guard sigue denegando toda escritura (fail-closed).
#   exit 0 · ACTIVO  — ACTIVE nombra un WP que existe y declara alcance.
#   exit 1 · ERROR   — ACTIVE nombra un WP inexistente, mal formado o sin alcance.
#   exit 2 · ERROR   — No existe el archivo ACTIVE.
#
# POR QUÉ ESTE SCRIPT EXISTE: esta lógica vivía incrustada en un bloque `run:`
# de .github/workflows/ci.yml, y trataba ACTIVE vacío como error. Entre dos WPs
# no hay ninguno activo, así que el estado seguro rompía el CI — y como el job
# es check obligatorio, bloqueaba toda fusión, incluida la que lo arreglaría.
#
# Al vivir en un script versionado: se ejecuta igual en local y en CI, tiene
# pruebas (tests/governance/test-check-active.sh), y evolucionar la validación
# ya no exige tocar un workflow, que está vedado a los agentes.
#
# Headless, sin red. Uso:
#   bash tests/governance/check-active.sh [ruta_repo]

set -u

REPO_ROOT="${1:-$(cd "$(dirname "$0")/../.." && pwd)}"
ACTIVE_FILE="$REPO_ROOT/work-packages/ACTIVE"

# En GitHub Actions emite anotaciones nativas; en local, texto limpio.
anotar_error() {
  [ -n "${GITHUB_ACTIONS:-}" ] && printf '::error::%s\n' "$1"
  return 0
}

# --- Caso 3: no existe el archivo -------------------------------------------
if [ ! -f "$ACTIVE_FILE" ]; then
  anotar_error "No existe work-packages/ACTIVE"
  echo "ERROR: no existe work-packages/ACTIVE"
  echo
  echo "  El estado operativo de la FDA vive en ese archivo. Sin él no se puede"
  echo "  saber si hay trabajo en curso ni qué rutas están autorizadas."
  echo "  Créalo vacío para dejar la fábrica en reposo, o escribe en él el WP-ID."
  exit 2
fi

# Primera línea no vacía y no comentada.
WP="$(grep -v '^[[:space:]]*#' "$ACTIVE_FILE" 2>/dev/null \
      | grep -v '^[[:space:]]*$' | head -1 | tr -d '[:space:]')"

# --- Caso 1: reposo ----------------------------------------------------------
if [ -z "$WP" ]; then
  echo "REPOSO: no hay WP activo."
  echo
  echo "  Estado VÁLIDO: la fábrica no tiene trabajo en curso."
  echo "  El guard deniega toda escritura ordinaria mientras dure (fail-closed)."
  echo "  Para iniciar un WP: escribe su ID en work-packages/ACTIVE."
  exit 0
fi

# --- Caso 2b: formato del identificador --------------------------------------
case "$WP" in
  WP-[0-9][0-9][0-9]) ;;
  *)
    anotar_error "ACTIVE contiene un identificador mal formado: '$WP'"
    echo "ERROR: identificador mal formado en work-packages/ACTIVE: '$WP'"
    echo
    echo "  Formato esperado: WP-NNN (tres dígitos). Por ejemplo: WP-001."
    exit 1
    ;;
esac

# --- Caso 2c: el archivo del WP existe ---------------------------------------
WP_FILE=""
for candidato in "$REPO_ROOT/work-packages/$WP".md "$REPO_ROOT/work-packages/$WP"-*.md; do
  [ -f "$candidato" ] && { WP_FILE="$candidato"; break; }
done

if [ -z "$WP_FILE" ]; then
  anotar_error "ACTIVE apunta a $WP pero no existe work-packages/$WP*.md"
  echo "ERROR: ACTIVE apunta a '$WP' pero no existe work-packages/$WP*.md"
  echo
  echo "  Corrige ACTIVE, o crea el work package que falta."
  exit 1
fi

# --- Caso 2d: el WP declara alcance ------------------------------------------
# Un WP sin rutas permitidas deja al guard denegando todo: es indistinguible
# del reposo para quien trabaja, pero sin decirlo. Se trata como incoherencia.
RUTAS="$(awk '
  /^##[[:space:]]/ {
    linea = $0
    sub(/^##[[:space:]]*/, "", linea)
    dentro = (index(tolower(linea), "archivos permitidos") == 1)
    next
  }
  dentro && /^[[:space:]]*[-*][[:space:]]+/ {
    sub(/^[[:space:]]*[-*][[:space:]]+/, "")
    gsub(/`/, "")
    sub(/[[:space:]]*#.*$/, "")
    gsub(/^[[:space:]]+|[[:space:]]+$/, "")
    if (length($0) > 0 && $0 !~ /^(ninguno|none|n\/a|-)$/) print
  }
' "$WP_FILE")"

if [ -z "$RUTAS" ]; then
  anotar_error "$WP no declara ninguna ruta en '## Archivos permitidos'"
  echo "ERROR: $WP no declara ninguna ruta en '## Archivos permitidos'"
  echo
  echo "  Un WP sin alcance declarado no cumple la Definition of Ready y deja"
  echo "  al guard denegando toda escritura, sin explicar por qué."
  exit 1
fi

N_RUTAS="$(printf '%s\n' "$RUTAS" | grep -c .)"
echo "ACTIVO: $WP"
echo
echo "  Contrato:  ${WP_FILE#"$REPO_ROOT"/}"
echo "  Alcance:   $N_RUTAS ruta(s) permitida(s)"
printf '%s\n' "$RUTAS" | sed 's/^/    - /'
exit 0
