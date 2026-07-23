#!/usr/bin/env bash
#
# check-guard.sh — Envoltorio de compatibilidad.
#
# La suite del guard vive ahora en tests/guard/run-suite.sh, como código de
# pruebas versionado y re-ejecutable, no como script de evidencias.
#
# Este envoltorio se mantiene porque .github/workflows/ci.yml referencia esta
# ruta y los workflows están fuera del alcance editable de los agentes
# (deny Edit(./.github/workflows/**)). Se eliminará cuando WP-005 actualice ci.yml.
#
# Uso: bash evidence/WP-000/checks/check-guard.sh

set -u
REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
exec bash "$REPO_ROOT/tests/guard/run-suite.sh" "$@"
