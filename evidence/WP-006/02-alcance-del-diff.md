# Evidencia WP-006 — Alcance del diff

**Fecha:** 2026-07-23 · **Comando:** `git diff --name-only origin/main...HEAD`

## Archivos del diff

| Archivo | ¿Dentro del alcance de WP-006? |
|---|---|
| `tests/governance/check-active.sh` | ✅ `tests/**` |
| `tests/governance/test-check-active.sh` | ✅ `tests/**` |
| `tests/guard/run-suite.sh` | ✅ `tests/**` |
| `.github/workflows/ci.yml` | ✅ ruta explícita |
| `.claude/hooks/guard.sh` | ✅ ruta explícita |
| `docs/manual/02-ciclo-de-un-wp.md` | ✅ `docs/manual/**` |
| `docs/manual/05-bloqueos-y-parada.md` | ✅ `docs/manual/**` |
| `docs/manual/07-troubleshooting.md` | ✅ `docs/manual/**` |
| `evidence/WP-006/**` | ✅ `evidence/WP-006/**` |
| `work-packages/WP-006-reposo-y-validacion-gobierno.md` | ⚠️ **acto del operador** |
| `work-packages/ACTIVE` | ⚠️ **acto del operador** |

## Los dos archivos marcados: un hallazgo sobre `check_scope`

Las dos últimas filas están **explícitamente prohibidas** por el propio WP-006, y sin embargo aparecen en su diff. No es una violación: es un vacío en la definición del control que conviene cerrar antes de construirlo.

**Qué pasó.** Crear el contrato (`WP-006-*.md`) y activarlo (`ACTIVE`) son los dos actos que hacen existir el work package. Se realizaron **antes** de que WP-006 gobernara nada, bajo el alcance de WP-000, que sí permite `work-packages/**`. En ese instante eran legítimos.

**Por qué están prohibidos en WP-006.** Por autoprotección: un WP cuyo alcance incluya `ACTIVE` o su propio archivo puede ampliarse a voluntad, y todo el enforcement se desmorona. El grupo I de `tests/guard/run-suite.sh` prueba justamente eso.

**La tensión de diseño.** La convención de la FDA es «un WP = una rama = una PR», así que la creación y activación del WP viven necesariamente en su propia PR. Pero un verificador ingenuo que compare el diff completo contra los archivos permitidos marcaría siempre esos dos archivos como violación, en **todos** los WPs. Un control que da un falso positivo garantizado en cada ejecución se acaba ignorando.

**Convención que debe implementar `check_scope` (WP-002):**

> El archivo de contrato del propio WP (`work-packages/WP-XXX-*.md`) y el puntero `work-packages/ACTIVE` son **actos del operador humano**, no del agente implementador. Quedan **exentos** de la comprobación de alcance del WP al que pertenecen.
>
> La exención es nominal, no genérica: `check_scope` para `WP-XXX` exime exactamente `work-packages/ACTIVE` y `work-packages/WP-XXX-*.md`. Cualquier **otro** archivo bajo `work-packages/` sigue siendo violación — en particular, el contrato de un WP distinto.

Sin esa precisión la exención sería una puerta abierta: bastaría con tocar el WP de otro para escapar del control.

**Dueño y condición de cierre:** WP-002, al implementar `scripts/check_scope.py`. Su contrato ya exige cubrir los casos mínimos; este añade uno más, y debe llevar prueba propia.

## Verificación manual mientras tanto

Hasta que exista `check_scope`, la comprobación es visual y le corresponde al revisor humano y al `code-reviewer`:

```bash
git diff --name-only origin/main...HEAD
```

Contrastar cada línea con `## Archivos permitidos` del WP, aceptando únicamente las dos exenciones nominales descritas arriba.
