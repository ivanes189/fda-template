#!/usr/bin/env bash
#
# tests/guard/run-suite.sh — Suite adversarial de .claude/hooks/guard.sh
#
# Convención: exit 0 = el guard permite · exit 2 = el guard BLOQUEA
#
# Tipos de caso:
#   run    <esperado> <desc> <json> [project_dir]
#          Debe cumplirse. Si no se cumple, la suite falla.
#   xfail  <deseado>  <desc> <json> <ref> [project_dir]
#          Hueco CONOCIDO del guard. Hoy NO se comporta como se desea; se
#          documenta con la referencia del WP que lo cerrará. Si algún día pasa,
#          se reporta como XPASS (buena noticia) y hay que promoverlo a `run`.
#
# Headless. Salida: exit 0 = todo conforme · exit 1 = algún fallo inesperado.
#
# Uso:  bash tests/guard/run-suite.sh
#       FDA_GUARD=/ruta/candidato.sh bash tests/guard/run-suite.sh   (validar un parche)

set -u

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
GUARD="${FDA_GUARD:-$REPO_ROOT/.claude/hooks/guard.sh}"
PASS=0; FAIL=0; XFAIL=0; XPASS=0

FIX="$(mktemp -d)"
trap 'rm -rf "$FIX"' EXIT

_exec() {
  printf '%s' "$2" | CLAUDE_PROJECT_DIR="$1" bash "$GUARD" 2>&1
}

run() {
  _exp="$1"; _desc="$2"; _json="$3"; _dir="${4:-$REPO_ROOT}"
  _out="$(_exec "$_dir" "$_json")"; _code=$?
  if [ "$_code" = "$_exp" ]; then
    PASS=$((PASS+1)); printf '  OK    exit=%s  %s\n' "$_code" "$_desc"
  else
    FAIL=$((FAIL+1)); printf '  FALLO exit=%s (esperado %s)  %s\n' "$_code" "$_exp" "$_desc"
    printf '%s\n' "$_out" | head -4 | sed 's/^/          /'
  fi
}

xfail() {
  _want="$1"; _desc="$2"; _json="$3"; _ref="$4"; _dir="${5:-$REPO_ROOT}"
  _out="$(_exec "$_dir" "$_json")"; _code=$?
  if [ "$_code" = "$_want" ]; then
    XPASS=$((XPASS+1))
    printf '  XPASS exit=%s  %s\n' "$_code" "$_desc"
    printf '        ^ hueco CERRADO. Promover a `run` en esta suite. (%s)\n' "$_ref"
  else
    XFAIL=$((XFAIL+1))
    printf '  xfail exit=%s (se desea %s)  %s  [%s]\n' "$_code" "$_want" "$_desc" "$_ref"
  fi
}

w() { printf '{"tool_name":"Write","tool_input":{"file_path":"%s"}}' "$1"; }

b() {
  if command -v jq >/dev/null 2>&1; then
    jq -nc --arg c "$1" '{tool_name:"Bash",tool_input:{command:$c}}'
  else
    python3 -c 'import json,sys; print(json.dumps({"tool_name":"Bash","tool_input":{"command":sys.argv[1]}}))' "$1"
  fi
}

# --- Fixture con alcance REALISTA de WP de calibración -----------------------
# Necesario para los vectores de autoprotección: el alcance de bootstrap de
# WP-000 incluye .claude/**, work-packages/** y CODEOWNERS, así que contra
# WP-000 esas escrituras están legítimamente permitidas. La pregunta "¿puede el
# implementer reescribir su propio contrato?" solo tiene sentido frente a un WP
# de trabajo normal.
REAL="$FIX/realista"
mkdir -p "$REAL/work-packages" "$REAL/docs/manual"
printf 'WP-900\n' > "$REAL/work-packages/ACTIVE"
cat > "$REAL/work-packages/WP-900-realista.md" <<'WPEOF'
# WP-900 — WP de alcance realista (fixture)

## Archivos permitidos
- docs/manual/**

## Archivos prohibidos
- ninguno
WPEOF

echo "=============================================================="
echo " Suite adversarial del guard"
echo " Guard bajo prueba: $GUARD"
echo " Convención: exit 0 = permite · exit 2 = BLOQUEA"
echo "=============================================================="

echo
echo "--- A. Rutas DENTRO del alcance de WP-000 ---"
run 0 "CLAUDE.md"                          "$(w 'CLAUDE.md')"
run 0 "CODEOWNERS"                         "$(w 'CODEOWNERS')"
run 0 ".claude/agents/planner.md"          "$(w '.claude/agents/planner.md')"
run 0 "docs/manual/MANUAL.md"              "$(w 'docs/manual/MANUAL.md')"
run 0 "specs/adr/ADR-001-runtime.md"       "$(w 'specs/adr/ADR-001-runtime.md')"
run 0 ".github/workflows/ci.yml"           "$(w '.github/workflows/ci.yml')"
run 0 "ruta absoluta interna"              "$(w "$REPO_ROOT/docs/manual/07-troubleshooting.md")"

echo
echo "--- B. REGRESIÓN: rutas permitidas que aún no existen en disco ---"
run 0 "docs/inexistente/futuro.md"         "$(w 'docs/inexistente/futuro.md')"
run 0 "evidence/WP-777/nuevo/log.txt"      "$(w 'evidence/WP-777/nuevo/log.txt')"
run 0 "tests/scope/test_nuevo.py"          "$(w 'tests/scope/test_nuevo.py')"

echo
echo "--- C. Fuera del alcance por omisión ---"
run 2 "src/pagos/cobros.py"                "$(w 'src/pagos/cobros.py')"
run 2 "package.json"                       "$(w 'package.json')"
run 2 "CLAUDE.md.bak (no es prefijo)"      "$(w 'CLAUDE.md.bak')"
run 2 "docsX/otro.md (no es docs/)"        "$(w 'docsX/otro.md')"

echo
echo "--- D. Prohibidos explícitos (prohibido gana a permitido) ---"
run 2 ".env.production"                    "$(w '.env.production')"
run 2 "docs/secrets/clave.txt"             "$(w 'docs/secrets/clave.txt')"
run 2 "specs/cert.pem"                     "$(w 'specs/cert.pem')"

echo
echo "--- E. Evasión por forma de la ruta ---"
run 2 "traversal ../fuera.txt"             "$(w '../fuera.txt')"
run 2 "traversal docs/../../fuera.txt"     "$(w 'docs/../../fuera.txt')"
run 2 "absoluta fuera del repo"            "$(w '/etc/passwd')"
run 2 "NotebookEdit fuera de alcance"      '{"tool_name":"NotebookEdit","tool_input":{"notebook_path":"src/n.ipynb"}}'

echo
echo "--- F. FAIL-CLOSED ---"
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
printf '# WP-500\n\n## Archivos permitidos\n\n## Archivos prohibidos\n- ninguno\n' \
  > "$FIX/d/work-packages/WP-500-vacio.md"
run 2 "WP sin rutas permitidas"            "$(w 'docs/x.md')" "$FIX/d"

echo
echo "--- G. BASH: escrituras vía shell ---"
run 2 "echo > src/y.py (redirección)"      "$(b 'echo "codigo" > src/y.py')"
run 2 "echo >> package.json (append)"      "$(b 'echo x >> package.json')"
run 2 "tee src/z.py"                       "$(b 'cat fichero | tee src/z.py')"
run 2 "sed -i sobre src/"                  "$(b "sed -i '' 's/a/b/' src/z.py")"
run 2 "cp hacia src/"                      "$(b 'cp plantilla.txt src/b.txt')"
run 2 "mv hacia src/"                      "$(b 'mv a.py src/b.py')"
run 2 "rm -rf src/"                        "$(b 'rm -rf src/')"
run 2 "dd of=src/big.bin"                  "$(b 'dd if=/dev/zero of=src/big.bin')"
run 2 "redirección con ruta entrecomillada" "$(b 'echo x > "src/con espacio.py"')"
run 2 "truncate sobre src/"                "$(b 'truncate -s 0 src/a.py')"
run 2 "ln -s hacia src/"                   "$(b 'ln -s /tmp/x src/enlace')"

echo
echo "--- H. BASH: lo que NO debe bloquearse (falsos positivos) ---"
run 0 "echo > docs/ok.md (en alcance)"     "$(b 'echo "texto" > docs/ok.md')"
run 0 "echo >> evidence/WP-000/log.txt"    "$(b 'echo x >> evidence/WP-000/log.txt')"
run 0 "redirección a /dev/null"            "$(b 'ruidoso 2>/dev/null')"
run 0 "escritura en /tmp"                  "$(b 'echo x > /tmp/scratch.txt')"
run 0 "commit con > dentro de comillas"    "$(b 'git commit -m "arreglar a > b"')"
run 0 "pytest (sin escrituras)"            "$(b 'pytest --cov --cov-report=term')"
run 0 "grep con > en el patrón"            "$(b "grep -n '>' docs/manual/MANUAL.md")"

echo
echo "--- I. AUTOPROTECCIÓN (fixture WP-900: solo docs/manual/**) ---"
echo "    Si el implementer pudiera escribir aquí, podría ampliarse el alcance"
echo "    a sí mismo y todo el enforcement colapsaría."
run 0 "docs/manual/x.md (en alcance)"      "$(w 'docs/manual/x.md')" "$REAL"
run 2 "work-packages/ACTIVE"               "$(w 'work-packages/ACTIVE')" "$REAL"
run 2 "work-packages/WP-900-realista.md"   "$(w 'work-packages/WP-900-realista.md')" "$REAL"
run 2 "work-packages/WP-001-otro.md"       "$(w 'work-packages/WP-001-otro.md')" "$REAL"
run 2 ".claude/settings.json"              "$(w '.claude/settings.json')" "$REAL"
run 2 ".claude/hooks/guard.sh"             "$(w '.claude/hooks/guard.sh')" "$REAL"
run 2 ".claude/agents/implementer.md"      "$(w '.claude/agents/implementer.md')" "$REAL"
run 2 "CODEOWNERS"                         "$(w 'CODEOWNERS')" "$REAL"
run 2 "CLAUDE.md"                          "$(w 'CLAUDE.md')" "$REAL"
run 2 ".github/workflows/ci.yml"           "$(w '.github/workflows/ci.yml')" "$REAL"
run 2 "Bash: echo > ACTIVE"                "$(b 'echo WP-001 > work-packages/ACTIVE')" "$REAL"
run 2 "Bash: cp sobre CLAUDE.md"           "$(b 'cp /tmp/x CLAUDE.md')" "$REAL"
run 2 "Bash: mv sobre settings.json"       "$(b 'mv /tmp/x .claude/settings.json')" "$REAL"
run 2 "Bash: sed -i sobre el WP activo"    "$(b "sed -i '' 's/a/b/' work-packages/WP-900-realista.md")" "$REAL"

echo
echo "--- J. HUECOS CONOCIDOS (expected-fail, no se corrigen en el Paso 0) ---"
echo "    El guard es preventivo y best-effort. La defensa concluyente es la"
echo "    verificación post-hoc del diff (check_scope, WP-002), sobre la que no"
echo "    hay bypass posible sea cual sea la herramienta empleada."

# Symlink dentro de alcance apuntando fuera: el guard compara la RUTA, no resuelve el destino.
mkdir -p "$REAL/docs/manual" "$REAL/fuera"
ln -sfn "../../fuera" "$REAL/docs/manual/enlace" 2>/dev/null || true
xfail 2 "symlink en alcance que apunta fuera"  "$(w 'docs/manual/enlace/x.md')" "WP-002" "$REAL"

xfail 2 "python -c con open(...,'w')" \
      "$(b "python3 -c \"open('src/x.py','w').write('x')\"")" "WP-002"

# Redirección dentro de comillas simples: el desentrecomillado la neutraliza
# ENTERA y no queda ninguna ruta que analizar. Es el hueco limpio del analizador.
xfail 2 "subshell con redirección entrecomillada" \
      "$(b "bash -c 'echo x > src/y.py'")" "WP-002"

xfail 2 "git apply de parche fuera de alcance" \
      "$(b 'git apply /tmp/parche.diff')" "WP-002"
xfail 2 "tar extrayendo sobre ruta fuera de alcance" \
      "$(b 'tar -xf paquete.tar -C src/')" "WP-002"

# Vector APFS: exige un WP donde el patrón PERMITIDO cubra la variante en
# minúsculas mientras el PROHIBIDO solo nombra la mayúscula. En macOS ambas
# rutas son el MISMO archivo en disco, pero patrones distintos para el matcher.
APFS="$FIX/apfs"
mkdir -p "$APFS/work-packages"
printf 'WP-901\n' > "$APFS/work-packages/ACTIVE"
cat > "$APFS/work-packages/WP-901-apfs.md" <<'WPEOF'
# WP-901 — fixture de sensibilidad a mayúsculas

## Archivos permitidos
- *.md

## Archivos prohibidos
- CLAUDE.md
WPEOF
run   2 "APFS: CLAUDE.md prohibido se bloquea"  "$(w 'CLAUDE.md')" "$APFS"
xfail 2 "APFS: 'claude.md' elude el prohibido" \
      "$(w 'claude.md')" "WP-002 (macOS case-insensitive)" "$APFS"
# FALSO POSITIVO detectado en el Paso 0 de la Fase 1.
# La extracción de "redirecciones con destino entrecomillado" opera sobre el
# comando ORIGINAL, no sobre el desentrecomillado. Cualquier '>' dentro de una
# cadena, seguido inmediatamente de comilla, produce un objetivo inventado y
# bloquea un comando que no escribe nada.
# Caso real que lo destapó:
#   python3 -c "print('a =', round(x), 'EUR ->', round(y), '%')"
#   -> objetivo extraído: ", round(y), "
# Aquí se desea exit 0 (permitir); hoy devuelve 2.
xfail 0 "falso positivo: '>' entrecomillado seguido de cadena" \
      "$(b "echo 'a->', 'b'")" "defecto del analizador Bash"

xfail 2 "git push -f (control en settings.json, no en guard)" \
      "$(b 'git push -f origin main')" "capa de permisos, no guard.sh"
xfail 2 "git push --force (idem)" \
      "$(b 'git push --force origin main')" "capa de permisos, no guard.sh"

echo
echo "=============================================================="
printf ' RESULTADO: %s correctas · %s fallidas · %s huecos conocidos · %s huecos cerrados\n' \
       "$PASS" "$FAIL" "$XFAIL" "$XPASS"
echo "=============================================================="
if [ "$XPASS" -gt 0 ]; then
  echo
  echo "NOTA: $XPASS caso(s) marcados como hueco conocido ya pasan."
  echo "      Promuévelos de 'xfail' a 'run' para que queden como regresión."
fi
[ "$FAIL" -eq 0 ] || exit 1
exit 0
