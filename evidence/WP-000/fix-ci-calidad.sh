#!/usr/bin/env bash
#
# fix-ci-calidad.sh — Corrige el job 'calidad' de ci.yml.
#
# El primer run de CI tras instanciar el sandbox falló, y falló bien: actionlint
# encontró tres defectos en el propio job que acabábamos de escribir.
#
#   1. SC2046 — `$(go env GOPATH)/bin/actionlint` sin comillas: word splitting.
#      Arreglo: añadir GOPATH/bin al PATH e invocar `actionlint` a secas.
#
#   2. SC1072/SC1073 — el comentario «# shellcheck está preinstalado...» empieza
#      por la palabra `shellcheck`, así que la propia herramienta intenta
#      parsearlo como una DIRECTIVA suya y no entiende el castellano.
#      Arreglo: reformular el comentario para que no empiece por esa palabra.
#
#   3. Latente (aún no había explotado) — `set -o pipefail` con `find` sobre
#      `scripts/`, que todavía no existe: find devuelve ≠0, el pipe falla y el
#      paso aborta. Arreglo: absorber el fallo de find con `|| true`.
#
# Lo ejecuta una PERSONA: .github/workflows/** está denegado a los agentes.
# No toca ningún otro archivo. Copia de seguridad previa y validación posterior.
#
# Uso:  bash evidence/WP-000/fix-ci-calidad.sh

set -eu

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

LOG="evidence/WP-000/fix-ci-calidad.log"
BACKUP_DIR="evidence/WP-000/backups"
STAMP="$(date +%Y%m%d-%H%M%S)"

huella() {
  if [ ! -f "$1" ]; then echo "(no existe)"; return 0; fi
  if command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | awk '{print $1}'
  else wc -c < "$1" | tr -d ' '; fi
}

main() {
  echo "=============================================================="
  echo " FDA — Corrección del job 'calidad' de ci.yml"
  echo " Fecha: $(date +'%Y-%m-%d %H:%M:%S')"
  echo "=============================================================="
  echo

  echo "--- Paso 0: comprobaciones previas ---"
  [ -f .github/workflows/ci.yml ] || { echo "ERROR: no existe ci.yml"; return 1; }
  GUARD_ANTES="$(huella .claude/hooks/guard.sh)"
  SET_ANTES="$(huella .claude/settings.json)"
  echo "  OK  ci.yml presente y huellas registradas"
  echo

  echo "--- Paso 1: copia de seguridad ---"
  mkdir -p "$BACKUP_DIR/$STAMP"
  cp .github/workflows/ci.yml "$BACKUP_DIR/$STAMP/ci.yml"
  echo "  Guardada: $BACKUP_DIR/$STAMP/ci.yml"
  echo

  echo "--- Paso 2: reescribir el job 'calidad' ---"
  python3 <<'PY'
import pathlib
p = pathlib.Path(".github/workflows/ci.yml")
texto = p.read_text(encoding="utf-8")

inicio = texto.index("  # ---------------------------------------------------------------------------\n  # Calidad")
fin    = texto.index("  # ---------------------------------------------------------------------------\n  # Secretos.")

nuevo = '''  # ---------------------------------------------------------------------------
  # Calidad — {{COMANDOS_VALIDACION}} INSTANCIADO
  #
  # El fda-template se usa a sí mismo como sandbox de calibración (Fase 1), así
  # que su "stack" es su propio gobierno. Validación = actionlint (workflows) +
  # shellcheck (hooks y scripts) + suite del guard + link-check del manual.
  #
  # La herramienta shellcheck viene preinstalada en los runners ubuntu-latest.
  # OJO: no empieces un comentario por la palabra "shellcheck" — la trata como
  # una directiva suya y falla con SC1072/SC1073.
  #
  # Severidad 'warning': bloquea ante problemas reales e ignora avisos de estilo.
  # Endurecer a 'style' es un WP posterior, no una decisión del Paso 0.
  # ---------------------------------------------------------------------------
  calidad:
    name: Lint · Shell · Tests · Manual
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Instalar PyYAML
        run: pip install --quiet pyyaml

      - name: Instalar actionlint
        run: |
          go install github.com/rhysd/actionlint/cmd/actionlint@v1.7.7
          echo "$(go env GOPATH)/bin" >> "$GITHUB_PATH"

      - name: actionlint (workflows)
        run: actionlint -color

      - name: shellcheck (hooks, tests y scripts)
        run: |
          set -euo pipefail
          archivos=$( { find .claude/hooks tests scripts evidence/WP-000/checks \\
                          -name '*.sh' -type f 2>/dev/null || true; } | sort )
          if [ -z "$archivos" ]; then
            echo "::error::no se encontró ningún archivo .sh que analizar"
            exit 1
          fi
          echo "Archivos analizados:"
          echo "$archivos" | sed 's/^/  /'
          # shellcheck disable=SC2086
          shellcheck --severity=warning --shell=bash $archivos

      - name: Suite adversarial del guard
        run: bash tests/guard/run-suite.sh

      - name: Link-check del manual
        run: python3 evidence/WP-000/checks/check-manual.py

'''
p.write_text(texto[:inicio] + nuevo + texto[fin:], encoding="utf-8")
print("  Job 'calidad' reescrito.")
PY
  echo

  echo "--- Paso 3: validar ---"
  python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))" \
    && echo "  OK  ci.yml es YAML válido"
  python3 .claude/skills/run-verification/validate-workflows.py .github/workflows
  echo

  echo "--- Paso 4: integridad ---"
  I=0
  [ "$GUARD_ANTES" = "$(huella .claude/hooks/guard.sh)" ] \
    && echo "  OK     guard.sh SIN modificar" || { echo "  ALERTA guard.sh CAMBIÓ"; I=1; }
  [ "$SET_ANTES" = "$(huella .claude/settings.json)" ] \
    && echo "  OK     settings.json SIN modificar" || { echo "  ALERTA settings.json CAMBIÓ"; I=1; }
  [ "$I" -eq 0 ] || { echo "ERROR: se tocó algo fuera de alcance."; return 1; }
  echo

  echo "=============================================================="
  echo " RESULTADO: TODO CORRECTO"
  echo " Ejecuta ahora:  git add -A && git commit -m 'WP-000: corregir el job calidad de ci.yml' && git push"
  echo "=============================================================="
}

mkdir -p "$(dirname "$LOG")"
main 2>&1 | tee "$LOG"
exit "${PIPESTATUS[0]}"
