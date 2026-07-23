#!/usr/bin/env bash
#
# apply-fase1-config.sh — Tarea 3 del Paso 0: autoinstalación del fda-template
# sobre sí mismo como sandbox de calibración.
#
# Lo ejecuta una PERSONA desde Terminal. Existe porque los tres archivos que
# toca están denegados a los agentes por .claude/settings.json:
#     Edit(./CODEOWNERS)  ·  Edit(./.claude/settings.json)  ·  Edit(./.github/workflows/**)
# Esa denegación es deliberada: son los archivos que definen quién revisa, qué
# puede hacer un agente y qué código se ejecuta con los secretos del repo.
#
# QUÉ HACE
#   1. CODEOWNERS      → sustituye {{PROPIEDAD_COMPONENTES}} por @ivanes189
#   2. settings.json   → añade a `allow` los comandos de validación del sandbox
#   3. ci.yml          → sustituye el bloque {{COMANDOS_VALIDACION}} por la
#                        validación real: actionlint + shellcheck + tests + link-check
#
# QUÉ NO HACE: no toca guard.sh, ni los agentes, ni los WPs, ni claude.yml, ni
#   code-review.yml. No hace commit, ni push, ni configura nada en GitHub.
#   Lo verifica al final por huella SHA-256.
#
# Copias de seguridad en evidence/WP-000/backups/<fecha>/
# Registro completo en evidence/WP-000/apply-fase1-config.log
#
# Compatible con bash 3.2 (macOS). Uso:
#   bash evidence/WP-000/apply-fase1-config.sh

set -eu

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

LOG="evidence/WP-000/apply-fase1-config.log"
BACKUP_DIR="evidence/WP-000/backups"
STAMP="$(date +%Y%m%d-%H%M%S)"
OWNER="@ivanes189"

huella() {
  if [ ! -f "$1" ]; then echo "(no existe)"; return 0; fi
  if command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | awk '{print $1}'
  else wc -c < "$1" | tr -d ' '; fi
}

main() {
  echo "=============================================================="
  echo " FDA — Tarea 3 del Paso 0: autoinstalación del sandbox"
  echo " Fecha:       $(date +'%Y-%m-%d %H:%M:%S')"
  echo " Repositorio: $REPO_ROOT"
  echo " Propietario: $OWNER"
  echo "=============================================================="
  echo

  # --- Paso 0: comprobaciones previas ---------------------------------------
  echo "--- Paso 0: comprobaciones previas ---"
  [ -f CLAUDE.md ] && [ -d .claude ] || { echo "ERROR: no parece el repo de la FDA."; return 1; }
  echo "  OK  Repositorio correcto"
  python3 -c "import json,sys; json.load(open('.claude/settings.json'))" \
    || { echo "ERROR: .claude/settings.json no es JSON válido antes de empezar."; return 1; }
  echo "  OK  settings.json parte de un estado válido"

  GUARD_ANTES="$(huella .claude/hooks/guard.sh)"
  AGENTS_ANTES="$(huella .claude/agents/implementer.md)"
  CLAUDE_ANTES="$(huella CLAUDE.md)"
  echo "  OK  Huellas de control registradas"
  echo

  # --- Paso 1: copias de seguridad ------------------------------------------
  echo "--- Paso 1: copias de seguridad ---"
  mkdir -p "$BACKUP_DIR/$STAMP"
  for f in CODEOWNERS .claude/settings.json .github/workflows/ci.yml; do
    if [ -f "$f" ]; then
      cp "$f" "$BACKUP_DIR/$STAMP/$(basename "$f")"
      echo "  Guardada copia: $BACKUP_DIR/$STAMP/$(basename "$f")"
    fi
  done
  echo

  # --- Paso 2: CODEOWNERS ----------------------------------------------------
  echo "--- Paso 2: CODEOWNERS ---"
  ANTES=$(grep -c '{{PROPIEDAD_COMPONENTES}}' CODEOWNERS || true)
  python3 - "$OWNER" <<'PY'
import pathlib, sys
owner = sys.argv[1]
p = pathlib.Path("CODEOWNERS")
p.write_text(p.read_text(encoding="utf-8").replace("{{PROPIEDAD_COMPONENTES}}", owner), encoding="utf-8")
PY
  DESPUES=$(grep -c '{{PROPIEDAD_COMPONENTES}}' CODEOWNERS || true)
  echo "  Marcadores sustituidos: $ANTES → quedan $DESPUES"
  [ "$DESPUES" -eq 0 ] || { echo "ERROR: quedan marcadores sin sustituir."; return 1; }
  echo "  Propietario efectivo:"
  grep -E '^\*' CODEOWNERS | sed 's/^/    /'
  echo

  # --- Paso 3: settings.json -------------------------------------------------
  echo "--- Paso 3: settings.json (comandos de validación del sandbox) ---"
  python3 <<'PY'
import json, pathlib
p = pathlib.Path(".claude/settings.json")
d = json.loads(p.read_text(encoding="utf-8"))
allow = d["permissions"]["allow"]

# Comandos de validación del propio fda-template usado como sandbox.
nuevos = [
    "Bash(actionlint*)",
    "Bash(shellcheck*)",
    "Bash(bash tests/*)",
    "Bash(python3 evidence/WP-000/checks/*)",
    "Bash(python3 .claude/skills/run-verification/validate-workflows.py*)",
    "Bash(python3 scripts/check_scope.py*)",
]
anadidos = [n for n in nuevos if n not in allow]
allow.extend(anadidos)
d["permissions"]["allow"] = allow
p.write_text(json.dumps(d, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
json.loads(p.read_text(encoding="utf-8"))   # revalida
print("  Reglas allow añadidas:", len(anadidos))
for a in anadidos:
    print("   +", a)
print("  Total allow:", len(allow))
print("  Matcher del hook:", d["hooks"]["PreToolUse"][0]["matcher"])
PY
  echo

  # --- Paso 4: ci.yml --------------------------------------------------------
  echo "--- Paso 4: ci.yml (job 'calidad' con la validación real) ---"
  python3 <<'PY'
import pathlib, re
p = pathlib.Path(".github/workflows/ci.yml")
texto = p.read_text(encoding="utf-8")

inicio = texto.index("  # ---------------------------------------------------------------------------\n  # Calidad:")
fin    = texto.index("  # ---------------------------------------------------------------------------\n  # Secretos.")

nuevo = '''  # ---------------------------------------------------------------------------
  # Calidad — {{COMANDOS_VALIDACION}} INSTANCIADO
  #
  # El fda-template se usa a sí mismo como sandbox de calibración (Fase 1), así
  # que su "stack" es su propio gobierno. Validación = actionlint (workflows) +
  # shellcheck (hooks y scripts) + suite del guard + link-check del manual.
  #
  # shellcheck corre a --severity=warning: bloquea ante problemas reales e
  # ignora avisos de estilo. Endurecer a 'style' es un WP posterior, no algo
  # que deba decidirse en el Paso 0.
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
        run: go install github.com/rhysd/actionlint/cmd/actionlint@v1.7.7

      - name: actionlint (workflows)
        run: $(go env GOPATH)/bin/actionlint -color

      - name: shellcheck (hooks, tests y scripts)
        run: |
          set -euo pipefail
          archivos=$(find .claude/hooks tests scripts evidence/WP-000/checks \\
                       -name '*.sh' -type f 2>/dev/null | sort)
          if [ -z "$archivos" ]; then echo "::error::no se encontró ningún .sh"; exit 1; fi
          echo "$archivos" | sed 's/^/  /'
          # shellcheck está preinstalado en los runners ubuntu-latest
          shellcheck --severity=warning --shell=bash $archivos

      - name: Suite adversarial del guard
        run: bash tests/guard/run-suite.sh

      - name: Link-check del manual
        run: python3 evidence/WP-000/checks/check-manual.py

'''
p.write_text(texto[:inicio] + nuevo + texto[fin:], encoding="utf-8")
print("  Job 'calidad' sustituido.")
PY

  python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/ci.yml'))" \
    && echo "  OK  ci.yml sigue siendo YAML válido"
  python3 .claude/skills/run-verification/validate-workflows.py .github/workflows
  echo

  # --- Paso 5: integridad ----------------------------------------------------
  echo "--- Paso 5: comprobar que no se ha tocado nada más ---"
  I=0
  [ "$GUARD_ANTES"  = "$(huella .claude/hooks/guard.sh)" ] \
    && echo "  OK     guard.sh SIN modificar" || { echo "  ALERTA guard.sh CAMBIÓ"; I=1; }
  [ "$AGENTS_ANTES" = "$(huella .claude/agents/implementer.md)" ] \
    && echo "  OK     agentes SIN modificar" || { echo "  ALERTA agentes CAMBIARON"; I=1; }
  [ "$CLAUDE_ANTES" = "$(huella CLAUDE.md)" ] \
    && echo "  OK     CLAUDE.md SIN modificar" || { echo "  ALERTA CLAUDE.md CAMBIÓ"; I=1; }
  [ "$I" -eq 0 ] || { echo "ERROR: se modificaron archivos fuera de alcance."; return 1; }
  echo

  echo "=============================================================="
  echo " RESULTADO: TODO CORRECTO"
  echo " CODEOWNERS, settings.json y ci.yml instanciados."
  echo " No se ha hecho commit, ni push, ni cambios en GitHub."
  echo "=============================================================="
}

mkdir -p "$(dirname "$LOG")"
main 2>&1 | tee "$LOG"
exit "${PIPESTATUS[0]}"
