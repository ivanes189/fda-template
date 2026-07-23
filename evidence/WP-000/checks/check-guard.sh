#!/usr/bin/env bash
#
# check-guard.sh — Verificación 3 de la Fase 0.
# Demuestra que .claude/hooks/guard.sh bloquea fuera de alcance, permite dentro
# y falla cerrado. Headless: sin interacción, exit 0 = todo OK, 1 = algún fallo.
#
# Uso: bash evidence/WP-000/checks/check-guard.sh

set -u

REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
GUARD="$REPO_ROOT/.claude/hooks/guard.sh"
PASS=0
FAIL=0

# run <esperado> <descripcion> <json> [project_dir]
run() {
  _exp="$1"; _desc="$2"; _json="$3"; _dir="${4:-$REPO_ROOT}"
  _out="$(printf '%s' "$_json" | CLAUDE_PROJECT_DIR="$_dir" bash "$GUARD" 2>&1)"
  _code=$?
  if [ "$_code" = "$_exp" ]; then
    PASS=$((PASS+1))
    printf '  OK    exit=%s  %s\n' "$_code" "$_desc"
  else
    FAIL=$((FAIL+1))
    printf '  FALLO exit=%s (esperado %s)  %s\n' "$_code" "$_exp" "$_desc"
    printf '%s\n' "$_out" | sed 's/^/          /'
  fi
}

w() { printf '{"tool_name":"Write","tool_input":{"file_path":"%s"}}' "$1"; }

echo "=============================================================="
echo " Verificación del hook guard.sh — WP activo: $(grep -v '^[[:space:]]*#' "$REPO_ROOT/work-packages/ACTIVE" | grep -v '^[[:space:]]*$' | head -1 | tr -d '[:space:]')"
echo " Convención: exit 0 = permite · exit 2 = BLOQUEA"
echo "=============================================================="

echo
echo "--- A. Rutas DENTRO del alcance de WP-000 (deben permitirse) ---"
run 0 "CLAUDE.md"                          "$(w 'CLAUDE.md')"
run 0 "CODEOWNERS"                         "$(w 'CODEOWNERS')"
run 0 ".claude/agents/planner.md"          "$(w '.claude/agents/planner.md')"
run 0 "docs/manual/MANUAL.md"              "$(w 'docs/manual/MANUAL.md')"
run 0 "specs/adr/ADR-001-runtime.md"       "$(w 'specs/adr/ADR-001-runtime.md')"
run 0 ".github/workflows/ci.yml"           "$(w '.github/workflows/ci.yml')"
run 0 "ruta absoluta interna"              "$(w "$REPO_ROOT/docs/manual/07-troubleshooting.md")"

echo
echo "--- B. REGRESIÓN: rutas permitidas que AÚN NO EXISTEN en disco ---"
echo "    (un for con variable sin comillas expandiría los globs contra el"
echo "     disco y bloquearía estas rutas pese a estar dentro de alcance)"
run 0 "docs/inexistente/futuro.md"         "$(w 'docs/inexistente/futuro.md')"
run 0 "evidence/WP-777/nuevo/log.txt"      "$(w 'evidence/WP-777/nuevo/log.txt')"
run 0 "specs/requirements/REQ-NUEVO.md"    "$(w 'specs/requirements/REQ-NUEVO.md')"

echo
echo "--- C. Rutas FUERA del alcance por omisión (deben bloquearse) ---"
run 2 "src/pagos/cobros.py"                "$(w 'src/pagos/cobros.py')"
run 2 "package.json"                       "$(w 'package.json')"
run 2 "tests/test_x.py"                    "$(w 'tests/test_x.py')"
run 2 "CLAUDE.md.bak (no es prefijo)"      "$(w 'CLAUDE.md.bak')"
run 2 "docsX/otro.md (no es docs/)"        "$(w 'docsX/otro.md')"

echo
echo "--- D. Rutas PROHIBIDAS explícitamente (prohibido gana a permitido) ---"
run 2 ".env.production"                    "$(w '.env.production')"
run 2 "docs/secrets/clave.txt"             "$(w 'docs/secrets/clave.txt')"
run 2 "specs/cert.pem"                     "$(w 'specs/cert.pem')"

echo
echo "--- E. Evasión (deben bloquearse) ---"
run 2 "traversal ../fuera.txt"             "$(w '../fuera.txt')"
run 2 "traversal docs/../../fuera.txt"     "$(w 'docs/../../fuera.txt')"
run 2 "absoluta fuera del repo"            "$(w '/etc/passwd')"
run 2 "NotebookEdit fuera de alcance"      '{"tool_name":"NotebookEdit","tool_input":{"notebook_path":"src/n.ipynb"}}'

echo
echo "--- F. FAIL-CLOSED: ante cualquier duda, denegar ---"
FIX="$(mktemp -d)"
trap 'rm -rf "$FIX"' EXIT

mkdir -p "$FIX/a/work-packages"
run 2 "sin archivo ACTIVE"                 "$(w 'docs/x.md')" "$FIX/a"

mkdir -p "$FIX/b/work-packages"
printf '# solo comentarios\n\n' > "$FIX/b/work-packages/ACTIVE"
run 2 "ACTIVE vacío"                       "$(w 'docs/x.md')" "$FIX/b"

mkdir -p "$FIX/c/work-packages"
printf 'WP-999\n' > "$FIX/c/work-packages/ACTIVE"
run 2 "ACTIVE apunta a WP inexistente"     "$(w 'docs/x.md')" "$FIX/c"

mkdir -p "$FIX/d/work-packages"
printf 'WP-500\n' > "$FIX/d/work-packages/ACTIVE"
printf '# WP-500 — sin rutas\n\n## Archivos permitidos\n\n## Archivos prohibidos\n- ninguno\n' \
  > "$FIX/d/work-packages/WP-500-vacio.md"
run 2 "WP sin rutas permitidas"            "$(w 'docs/x.md')" "$FIX/d"

echo
echo "=============================================================="
printf ' RESULTADO: %s correctas, %s fallidas\n' "$PASS" "$FAIL"
echo "=============================================================="
[ "$FAIL" -eq 0 ] || exit 1
exit 0
