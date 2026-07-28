#!/usr/bin/env bash
#
# test-check-active.sh — Pruebas de tests/governance/check-active.sh
#
# Cubre los cuatro estados que el script debe distinguir, comprobando en cada
# uno el código de salida Y el texto: un log de CI tiene que decir cuál de los
# casos se dio sin obligar a nadie a abrir el repositorio.
#
# Cubre además el invariante que la reparación NO debe romper: que el reposo
# siga siendo fail-closed para escrituras reales. Que el CI acepte ACTIVE vacío
# no puede convertirse, por descuido, en que el guard también lo acepte.
#
# Headless, sin red. exit 0 = todo conforme · exit 1 = algún fallo.
# Uso:  bash tests/governance/test-check-active.sh

set -u

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CHECK="$REPO_ROOT/tests/governance/check-active.sh"
GUARD="$REPO_ROOT/.claude/hooks/guard.sh"
PASS=0
FAIL=0

FIX="$(mktemp -d)"
trap 'rm -rf "$FIX"' EXIT

# caso <nombre> <exit_esperado> <marca_esperada_en_salida> <dir_fixture>
caso() {
  _nombre="$1"; _exp="$2"; _marca="$3"; _dir="$4"
  _out="$(bash "$CHECK" "$_dir" 2>&1)"; _code=$?
  _ok=1
  [ "$_code" = "$_exp" ] || _ok=0
  printf '%s' "$_out" | grep -q "$_marca" || _ok=0
  if [ "$_ok" = "1" ]; then
    PASS=$((PASS+1))
    printf '  OK    exit=%s  marca=%-7s  %s\n' "$_code" "$_marca" "$_nombre"
  else
    FAIL=$((FAIL+1))
    printf '  FALLO exit=%s (esperado %s) marca=%s  %s\n' "$_code" "$_exp" "$_marca" "$_nombre"
    printf '%s\n' "$_out" | head -4 | sed 's/^/          /'
  fi
}

# Construye un fixture de repositorio mínimo.
# fixture <nombre> <contenido_ACTIVE|__SIN_ARCHIVO__> [wp_id_a_crear] [rutas_permitidas]
fixture() {
  _n="$1"; _active="$2"; _wp="${3:-}"; _rutas="${4:-}"
  _d="$FIX/$_n"
  mkdir -p "$_d/work-packages"
  if [ "$_active" != "__SIN_ARCHIVO__" ]; then
    printf '%s\n' "$_active" > "$_d/work-packages/ACTIVE"
  fi
  if [ -n "$_wp" ]; then
    {
      printf '# %s — fixture\n\n' "$_wp"
      printf '## Archivos permitidos\n'
      if [ -n "$_rutas" ]; then
        printf -- '- %s\n' "$_rutas"
      fi
      printf '\n## Archivos prohibidos\n- ninguno\n'
    } > "$_d/work-packages/$_wp-fixture.md"
  fi
  printf '%s' "$_d"
}

echo "=============================================================="
echo " Validación del estado operativo — check-active.sh"
echo " 0=REPOSO o ACTIVO · 1=ERROR de coherencia · 2=ERROR sin archivo"
echo "=============================================================="
echo
echo "--- Los cuatro estados ---"

caso "ACTIVE vacío (solo comentarios) → reposo" 0 "REPOSO" \
     "$(fixture reposo '# comentario, sin WP')"

caso "ACTIVE con archivo totalmente vacío → reposo" 0 "REPOSO" \
     "$(fixture reposo2 '')"

caso "ACTIVE con WP existente y con alcance → activo" 0 "ACTIVO" \
     "$(fixture activo 'WP-042' 'WP-042' 'docs/**')"

caso "ACTIVE apunta a WP inexistente → error" 1 "ERROR" \
     "$(fixture inexistente 'WP-999')"

caso "no existe el archivo ACTIVE → error" 2 "ERROR" \
     "$(fixture sinarchivo '__SIN_ARCHIVO__')"

echo
echo "--- Coherencia adicional ---"

caso "identificador mal formado (WP-7) → error" 1 "ERROR" \
     "$(fixture malformado 'WP-7')"

caso "identificador mal formado (basura) → error" 1 "ERROR" \
     "$(fixture basura 'esto-no-es-un-wp')"

caso "WP existente pero SIN rutas permitidas → error" 1 "ERROR" \
     "$(fixture sinalcance 'WP-500' 'WP-500' '')"

echo
echo "--- Los mensajes son distinguibles entre sí ---"
_m_reposo="$(bash "$CHECK" "$FIX/reposo" 2>&1 | head -1)"
_m_activo="$(bash "$CHECK" "$FIX/activo" 2>&1 | head -1)"
_m_inexist="$(bash "$CHECK" "$FIX/inexistente" 2>&1 | head -1)"
_m_sinarch="$(bash "$CHECK" "$FIX/sinarchivo" 2>&1 | head -1)"
_distintos="$(printf '%s\n%s\n%s\n%s\n' "$_m_reposo" "$_m_activo" "$_m_inexist" "$_m_sinarch" | sort -u | grep -c .)"
if [ "$_distintos" = "4" ]; then
  PASS=$((PASS+1)); echo "  OK    los 4 mensajes de primera línea son distintos"
else
  FAIL=$((FAIL+1)); echo "  FALLO solo $_distintos mensajes distintos de 4"
fi
printf '        reposo     : %s\n' "$_m_reposo"
printf '        activo     : %s\n' "$_m_activo"
printf '        inexistente: %s\n' "$_m_inexist"
printf '        sin archivo: %s\n' "$_m_sinarch"

echo
echo "--- INVARIANTE: el reposo sigue siendo fail-closed para escrituras ---"
echo "    (que el CI acepte ACTIVE vacío no relaja el guard)"
_w='{"tool_name":"Write","tool_input":{"file_path":"docs/manual/x.md"}}'
_out="$(printf '%s' "$_w" | CLAUDE_PROJECT_DIR="$FIX/reposo" bash "$GUARD" 2>&1)"; _code=$?
if [ "$_code" = "2" ]; then
  PASS=$((PASS+1)); echo "  OK    exit=2  el guard DENIEGA una escritura con ACTIVE vacío"
else
  FAIL=$((FAIL+1)); echo "  FALLO exit=$_code (esperado 2) el guard permitió escribir en reposo"
  printf '%s\n' "$_out" | head -3 | sed 's/^/          /'
fi

echo
echo "=============================================================="
printf ' RESULTADO: %s correctas, %s fallidas\n' "$PASS" "$FAIL"
echo "=============================================================="
[ "$FAIL" -eq 0 ] || exit 1
exit 0
