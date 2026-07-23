#!/usr/bin/env bash
#
# check-structure.sh — Verificación 1 de la Fase 0.
# Compara la estructura del repo contra el §2 de la guía.
# Headless: exit 0 = completa y sin extras, 1 = discrepancias.

set -u
cd "$(dirname "$0")/../../.." || exit 1

FALTA=0
EXTRA=0

echo "=============================================================="
echo " Estructura contra el §2 de docs/02-guia-fabrica-desarrollo-agentica.md"
echo "=============================================================="
echo

echo "--- Archivos y directorios exigidos por el §2 ---"
while IFS='|' read -r ruta tipo desc; do
  [ -z "$ruta" ] && continue
  if [ "$tipo" = "d" ]; then
    if [ -d "$ruta" ]; then printf '  OK    %-46s %s\n' "$ruta/" "$desc"
    else printf '  FALTA %-46s %s\n' "$ruta/" "$desc"; FALTA=$((FALTA+1)); fi
  else
    if [ -f "$ruta" ]; then printf '  OK    %-46s %s\n' "$ruta" "$desc"
    else printf '  FALTA %-46s %s\n' "$ruta" "$desc"; FALTA=$((FALTA+1)); fi
  fi
done <<'LISTA'
CLAUDE.md|f|Constitución
CODEOWNERS|f|Propiedad por componente
.claude/settings.json|f|Permisos y hooks
.claude/agents/planner.md|f|Valida DoR, no toca código
.claude/agents/implementer.md|f|Implementa 1 WP
.claude/agents/qa.md|f|Ejecuta y amplía pruebas
.claude/agents/security-reviewer.md|f|Revisión de seguridad
.claude/agents/code-reviewer.md|f|Revisión de la PR
.claude/hooks/guard.sh|f|PreToolUse: rutas protegidas
.claude/skills/new-work-package|d|Skill: genera WP
.claude/skills/run-verification|d|Skill: batería + evidencias
.claude/skills/prepare-pr|d|Skill: abre PR
specs/decisions|d|DEC-xxx.md
specs/adr|d|ADR-xxx.md
specs/requirements|d|REQ por categoría
work-packages/_TEMPLATE.md|f|Contrato de hoja de encargo
work-packages/WP-000-bootstrap.md|f|WP de bootstrap
evidence|d|Evidencias por WP
.github/pull_request_template.md|f|Checklist de evidencias
.github/workflows/ci.yml|f|CI bloqueante
.github/workflows/claude.yml|f|@claude en issues/PRs
.github/workflows/code-review.yml|f|Revisión automática
LISTA

echo
echo "--- Añadidos por el prompt de arranque (Fase 0) ---"
while IFS='|' read -r ruta tipo desc; do
  [ -z "$ruta" ] && continue
  if { [ "$tipo" = "d" ] && [ -d "$ruta" ]; } || { [ "$tipo" = "f" ] && [ -f "$ruta" ]; }; then
    printf '  OK    %-46s %s\n' "$ruta" "$desc"
  else
    printf '  FALTA %-46s %s\n' "$ruta" "$desc"; FALTA=$((FALTA+1))
  fi
done <<'LISTA'
work-packages/ACTIVE|f|Estado operativo en archivo (SDK-ready)
docs/02-guia-fabrica-desarrollo-agentica.md|f|Guía fundacional versionada
docs/manual/MANUAL.md|f|Manual: índice
docs/manual/01-instalacion.md|f|Manual: instalación
docs/manual/02-ciclo-de-un-wp.md|f|Manual: ciclo
docs/manual/03-redactar-un-wp.md|f|Manual: redactar WP
docs/manual/04-agentes.md|f|Manual: agentes
docs/manual/05-bloqueos-y-parada.md|f|Manual: bloqueos
docs/manual/06-costes-y-metricas.md|f|Manual: costes
docs/manual/07-troubleshooting.md|f|Manual: troubleshooting
specs/adr/ADR-001-runtime.md|f|ADR de runtime (SDK-ready)
LISTA

echo
echo "--- Elementos NO pactados en la raíz (deben ser cero) ---"
# Se itera con globs y no con $(ls -A): recorrer la salida de ls se rompe con
# nombres que contienen espacios o saltos de línea (SC2045).
# '.[!.]*' y '..?*' cubren los ocultos sin arrastrar '.' ni '..'.
for e in .[!.]* ..?* *; do
  [ -e "$e" ] || continue          # glob sin coincidencias: queda literal
  case "$e" in
    CLAUDE.md|CODEOWNERS|.gitignore|.claude|specs|work-packages|evidence|tests|.github|docs|.git) ;;
    FDA-diagnostico-y-plan-fase1.md) ;;   # plan vinculante de la Fase 1 (versionado por decisión humana)
    *) printf '  EXTRA %s\n' "$e"; EXTRA=$((EXTRA+1)) ;;
  esac
done
[ "$EXTRA" -eq 0 ] && echo "  (ninguno)"

echo
echo "=============================================================="
printf ' RESULTADO: %s ausentes, %s no pactados\n' "$FALTA" "$EXTRA"
echo "=============================================================="
[ "$FALTA" -eq 0 ] && [ "$EXTRA" -eq 0 ] || exit 1
exit 0
