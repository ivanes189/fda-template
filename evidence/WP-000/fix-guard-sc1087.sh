#!/usr/bin/env bash
#
# fix-guard-sc1087.sh — Corrige SC1087 en .claude/hooks/guard.sh.
#
# HALLAZGO (severidad 'error', bloquea el paso shellcheck del CI):
#   línea 230:  _out="$_out[^/]*"
#   línea 232:  _out="$_out[^/]"
#   SC1087: «Use braces when expanding arrays».
#
# ¿ES UN BUG REAL? No. En bash el nombre de variable termina en '[', así que
# `$_out[^/]*` expande $_out y deja `[^/]*` literal — que es justo lo que
# queremos. Pero la forma es ambigua a la vista (parece indexado de array) y
# shellcheck la marca como error. En un control de seguridad, código que
# *parece* otra cosa es un problema aunque funcione.
#
# ARREGLO: `${_out}[^/]*`. Comportamiento idéntico, intención explícita.
#
# Lo ejecuta una PERSONA: .claude/hooks/** está denegado a los agentes.
# Verificación posterior: shellcheck limpio + los 58 casos de la suite en verde.
#
# Uso:  bash evidence/WP-000/fix-guard-sc1087.sh

set -eu

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$REPO_ROOT"

GUARD=".claude/hooks/guard.sh"
BACKUP_DIR="evidence/WP-000/backups"
STAMP="$(date +%Y%m%d-%H%M%S)"

echo "=============================================================="
echo " FDA — Corrección de SC1087 en guard.sh"
echo " Fecha: $(date +'%Y-%m-%d %H:%M:%S')"
echo "=============================================================="
echo

echo "--- Paso 1: copia de seguridad ---"
mkdir -p "$BACKUP_DIR/$STAMP"
cp "$GUARD" "$BACKUP_DIR/$STAMP/guard.sh"
echo "  $BACKUP_DIR/$STAMP/guard.sh"
echo

echo "--- Paso 2: estado previo de la suite (línea base) ---"
ANTES="$(bash tests/guard/run-suite.sh 2>&1 | grep 'RESULTADO:' || true)"
echo "  $ANTES"
echo

echo "--- Paso 3: aplicar el arreglo ---"
python3 - "$GUARD" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text(encoding="utf-8")
cambios = [
    ('_out="$_out[^/]*"',  '_out="${_out}[^/]*"'),
    ('_out="$_out[^/]"',   '_out="${_out}[^/]"'),
]
n = 0
for viejo, nuevo in cambios:
    if viejo in t:
        t = t.replace(viejo, nuevo, 1)
        n += 1
        print(f"  {viejo}  ->  {nuevo}")
if n != 2:
    print(f"  ERROR: se esperaban 2 sustituciones, se hicieron {n}.")
    print("  ¿Ya estaba arreglado? Revisa el archivo antes de continuar.")
    sys.exit(1)
p.write_text(t, encoding="utf-8")
PY
echo

echo "--- Paso 4: shellcheck sobre guard.sh ---"
if command -v shellcheck >/dev/null 2>&1; then
  shellcheck --severity=warning --shell=bash "$GUARD" && echo "  OK  sin hallazgos"
else
  echo "  (shellcheck no disponible)"
fi
echo

echo "--- Paso 5: la suite completa, sin regresión ---"
bash tests/guard/run-suite.sh 2>&1 | tail -4
DESPUES="$(bash tests/guard/run-suite.sh 2>&1 | grep 'RESULTADO:' || true)"
echo
echo "  antes:   $ANTES"
echo "  después: $DESPUES"
if [ "$ANTES" != "$DESPUES" ]; then
  echo
  echo "  ERROR: el resultado de la suite ha cambiado. NO commitees."
  echo "  Restaura con: cp $BACKUP_DIR/$STAMP/guard.sh $GUARD"
  exit 1
fi
echo "  OK  resultado idéntico: el arreglo es puramente cosmético"
echo

echo "--- Paso 6: shellcheck completo (el mismo comando del CI) ---"
if command -v shellcheck >/dev/null 2>&1; then
  archivos=$( { find .claude/hooks tests scripts evidence/WP-000/checks \
                  -name '*.sh' -type f 2>/dev/null || true; } | sort )
  printf '%s\n' "$archivos" | sed 's/^/  /'
  # shellcheck disable=SC2086
  shellcheck --severity=warning --shell=bash $archivos && echo "  OK  todo limpio"
fi
echo

if command -v actionlint >/dev/null 2>&1; then
  echo "--- Paso 7: actionlint ---"
  actionlint && echo "  OK  sin hallazgos"
  echo
fi

echo "=============================================================="
echo " LISTO — todo verde en local."
echo "=============================================================="
