#!/usr/bin/env bash
#
# fix-ci-sc2001.sh — Arregla el último hallazgo de actionlint en ci.yml.
#
# SC2001 (style): `echo "$archivos" | sed 's/^/  /'`
#   shellcheck sugiere ${var//buscar/reemplazar}. El patrón que dispara la regla
#   es específicamente `echo "$var" | sed`; con `printf` no salta — por eso el
#   job 'secretos', que hace exactamente lo mismo con printf, nunca la disparó.
#
# Nota: actionlint falla ante CUALQUIER hallazgo de shellcheck, incluidos los de
# severidad 'style'. No es lo mismo que el paso `shellcheck --severity=warning`,
# que sí filtra por severidad. Son dos controles distintos con criterios distintos.
#
# Lo ejecuta una PERSONA: .github/workflows/** está denegado a los agentes.
# Uso:  bash evidence/WP-000/fix-ci-sc2001.sh

set -eu

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

CI=".github/workflows/ci.yml"
BACKUP_DIR="evidence/WP-000/backups"
STAMP="$(date +%Y%m%d-%H%M%S)"

echo "=== Copia de seguridad ==="
mkdir -p "$BACKUP_DIR/$STAMP"
cp "$CI" "$BACKUP_DIR/$STAMP/ci.yml"
echo "  $BACKUP_DIR/$STAMP/ci.yml"

echo "=== Aplicando arreglo ==="
python3 - "$CI" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text(encoding="utf-8")
viejo = '''          echo "Archivos analizados:"
          echo "$archivos" | sed 's/^/  /\''''
nuevo = '''          echo "Archivos analizados:"
          printf '%s\\n' "$archivos" | sed 's/^/  /\''''
if viejo not in t:
    print("  ERROR: no se encontró el bloque a sustituir. ¿Ya estaba arreglado?")
    sys.exit(1)
p.write_text(t.replace(viejo, nuevo, 1), encoding="utf-8")
print("  echo -> printf aplicado")
PY

echo "=== Validando ==="
python3 -c "import yaml; yaml.safe_load(open('$CI'))" && echo "  OK  YAML válido"
python3 .claude/skills/run-verification/validate-workflows.py .github/workflows | tail -2

if command -v actionlint >/dev/null 2>&1; then
  echo "=== actionlint local ==="
  actionlint && echo "  OK  actionlint sin hallazgos"
else
  echo "  (actionlint no instalado localmente: se validará en CI)"
fi

if command -v shellcheck >/dev/null 2>&1; then
  echo "=== shellcheck local (mismo comando que el CI) ==="
  archivos=$( { find .claude/hooks tests scripts evidence/WP-000/checks \
                  -name '*.sh' -type f 2>/dev/null || true; } | sort )
  printf '%s\n' "$archivos" | sed 's/^/  /'
  # shellcheck disable=SC2086
  shellcheck --severity=warning --shell=bash $archivos && echo "  OK  shellcheck sin hallazgos"
else
  echo "  (shellcheck no instalado localmente: se validará en CI)"
fi

echo
echo "=============================================================="
echo " LISTO. Si todo lo anterior está OK, commitea y empuja."
echo "=============================================================="
