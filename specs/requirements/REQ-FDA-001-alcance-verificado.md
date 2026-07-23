# REQ-FDA-001 — El diff de toda PR está dentro del alcance del WP

**Id:** REQ-FDA-001 · **Categoría:** FR (funcional, gobierno) · **Estado:** activo · **Fecha:** 2026-07-23

## Texto

Todo archivo modificado, añadido, renombrado o eliminado en una pull request debe estar cubierto por un patrón de la sección `## Archivos permitidos` del work package que la PR referencia, y no coincidir con ningún patrón de `## Archivos prohibidos`.

El cumplimiento se verifica **sobre el diff** —no sobre la intención del agente— y se comprueba de forma automática y bloqueante en CI.

## Justificación

El hook `guard.sh` es un control **preventivo** y local: intercepta llamadas a herramientas antes de que ocurran. Su cobertura sobre `Bash` es best-effort y no puede ser exhaustiva, porque el shell admite vías de escritura no enumerables (`python -c "open(...,'w')"`, `eval`, `git apply`…).

La verificación sobre el diff es **post-hoc y determinista**: mide el resultado, no el método. Sobre el diff de una PR no hay bypass posible, sea cual sea la herramienta que produjo el cambio. Las dos capas son complementarias: el hook evita el error, el check del diff lo hace imposible de fusionar.

## Criterio de verificación

1. Existe un ejecutable que, dados un WP-ID y un rango git, devuelve código de salida `≠ 0` si algún archivo del diff queda fuera del alcance del WP, y `0` si todos están dentro.
2. Su salida enumera **todas** las violaciones encontradas, no solo la primera, indicando archivo y motivo (fuera de permitidos / coincide con prohibidos).
3. Un job de CI lo ejecuta sobre el diff de cada PR contra `main`, extrayendo el WP-ID del nombre de la rama (`wp/WP-XXX-*`).
4. Ese job está marcado como **check obligatorio** en el ruleset de `main`.
5. Prueba demostrativa: una PR que toca un archivo fuera de alcance hace **fallar** el CI; una PR válida lo deja en verde. Ambos runs quedan como evidencia.

## Verificación actual

| Mecanismo | Estado |
|---|---|
| Hook preventivo (`guard.sh`) | Operativo — 42 casos en `evidence/WP-000/checks/check-guard.sh` |
| Check post-hoc del diff | **Pendiente** — lo construye WP-002 |
| Check obligatorio en CI | **Pendiente** — lo integra WP-005 |

## Trazabilidad

- Implementa: WP-002 (`check_scope`), WP-005 (integración en CI y ruleset)
- Origen: `FDA-diagnostico-y-plan-fase1.md` §1.3-B2
- Relacionado: [`CLAUDE.md`](../../CLAUDE.md) (alcance del trabajo), [`work-packages/_TEMPLATE.md`](../../work-packages/_TEMPLATE.md)
