# Manual de la Fábrica de Desarrollo Agéntica

Este manual permite operar la FDA **sin memoria conversacional**. Todo el conocimiento operativo vive aquí; si algo solo se sabe porque se dijo en un chat, no se sabe.

> **Regla vinculante** (`CLAUDE.md`): todo cambio de proceso, contrato o agente actualiza `docs/manual/` en la misma PR. Manual desactualizado = PR incompleta. El job `gobierno` de CI lo comprueba automáticamente.

## Qué es la FDA

Un sistema donde agentes de IA especializados implementan software mediante tareas pequeñas, contratos explícitos, ramas aisladas, PRs, CI bloqueante y supervisión humana. Es una **plantilla reutilizable** que se instala en cada proyecto, no un módulo de ninguno.

Lo valioso no es el runtime (hoy Claude Code) sino la **capa de gobierno**: los archivos versionados que definen qué puede hacer cada agente y bajo qué condiciones se detiene. Si mañana cambias de runtime, el gobierno sobrevive.

La seguridad **no depende de que el modelo obedezca instrucciones**. Depende de controles que viven fuera del prompt. Conviene distinguir cinco cosas que suelen fundirse: lo que **el ruleset impone técnicamente hoy**, lo que es **práctica del operador**, lo que es **política escrita** (`CLAUDE.md`), lo que es **restricción operativa** (allowlists de herramientas, automatización desactivada) y lo que está **declarado como necesario pero todavía no impuesto técnicamente**. Y separar todo eso de las **capas objetivo** que la hoja de ruta fija y que aún no existen.

La capa de plataforma está por tanto **parcialmente materializada**, no entera.

**Controles que operan hoy:**

| Control | Dónde vive | Qué hace | Alcance real |
|---|---|---|---|
| Permisos de GitHub | branch protection / ruleset | PR obligatoria; tres checks bloqueantes; `non_fast_forward` y `deletion` bloqueados | **Impuesto técnicamente por el ruleset**; **esas cuatro reglas son todo lo acreditado por el expediente actual**. Determinista para lo que cubre; **no comprueba el alcance del WP**, y **las vías observadas no impiden la autofusión** |
| Prohibición de fusionar la propia PR | `CLAUDE.md` (política) + allowlists de `.claude/agents/*.md` + workflows de agente desactivados ([`DEC-003`](../../specs/decisions/DEC-003-pausa-migracion-y-contencion.md) §3) | La **política** de `CLAUDE.md` prohíbe la autofusión; las **restricciones operativas** conocidas reducen la superficie | **Política vigente + restricción operativa, NO impuesta por el ruleset.** **No se ha acreditado una imposibilidad técnica universal** ni se han auditado todos los actores y credenciales: el **comportamiento empírico** no está medido |
| Allowlists de herramientas | `.claude/agents/*.md` | Impiden que un revisor modifique código | Determinista **por herramienta, no por ruta** |
| Hook `guard.sh` | `.claude/hooks/guard.sh` | Deniega en el momento las escrituras fuera del alcance del WP que reconoce | **Feedback preventivo best-effort.** No es garantía: falla abierto si no es ejecutable o no llega a invocarse ([`DEC-003`](../../specs/decisions/DEC-003-pausa-migracion-y-contencion.md) §1) y su analizador de `Bash` tiene huecos conocidos ([04 — Los agentes](04-agentes.md)) |
| Lectura del diff y fusión humana | Operador, en cada PR | Rechazan un diff que toque archivos fuera del WP | **Práctica del operador, NO impuesta por el ruleset.** Es hoy lo que efectivamente cierra el alcance, y por eso conviene saber que **depende de disciplina**, no de una barrera |

**Declarado necesario y todavía NO impuesto técnicamente.** Al menos **una
aprobación humana** y la **revisión de `CODEOWNERS`**. El ruleset registra hoy
`required_approving_review_count: 0` y `require_code_owner_review: false`,
mientras `CODEOWNERS` y este manual los describen como obligatorios.
[`DEC-003`](../../specs/decisions/DEC-003-pausa-migracion-y-contencion.md) lo
consigna como **riesgo abierto y no aprobado**, con destino **WP-011**. **No lo
des por impuesto.**

**Riesgo pendiente.** Con `required_approving_review_count: 0`, el ruleset **no
impide por sí solo** que el autor de una PR la fusione si tiene permisos
suficientes. La prohibición de autofusión es **política y operación**, no una
barrera del ruleset; su cierre técnico es **WP-011**.

**Capas objetivo, todavía NO materializadas** — hoja de ruta [`docs/03`](../03-hoja-de-ruta.md), principio P1:

| Capa objetivo | Estado hoy |
|---|---|
| Sandbox del sistema operativo: escritura restringida a nivel de kernel y egreso de red por allowlist | **No instalado.** Pendiente del experimento E2 y de su gate |
| `check_scope`: comprobación del diff de la PR en CI contra el contrato del WP | **No implementado.** `WP-002` está `blocked` y `WP-005` en `draft` |

**No des por existente ninguna de las dos.** Mientras no lo estén, quien decide el alcance es la **lectura humana del diff** —una práctica, no una barrera—, no el hook y no la protección de rama, que **no comprueba el alcance del WP**.

## Índice

| Documento | Cuándo leerlo |
|---|---|
| [01 — Instalación](01-instalacion.md) | Al instalar la plantilla en un proyecto nuevo |
| [02 — El ciclo de un WP](02-ciclo-de-un-wp.md) | Cada vez que ejecutes un work package |
| [03 — Redactar un WP](03-redactar-un-wp.md) | Antes de escribir una hoja de encargo |
| [04 — Los agentes](04-agentes.md) | Para saber a quién lanzar y con qué permisos |
| [05 — Bloqueos y parada](05-bloqueos-y-parada.md) | Cuando un agente se detiene |
| [06 — Costes y métricas](06-costes-y-metricas.md) | Al cerrar un WP y al revisar la semana |
| [07 — Troubleshooting](07-troubleshooting.md) | Cuando algo no funciona |

## Documentos fundacionales

- [CLAUDE.md](../../CLAUDE.md) — la constitución que todo agente carga siempre.
- [Hoja de ruta](../03-hoja-de-ruta.md) — **el rumbo vigente**: arquitectura objetivo del enforcement, etapas y secuencia posterior a la pausa. Es el segundo documento del orden de lectura obligatorio de `CLAUDE.md`, antes de este manual.
- [Guía de implantación](../02-guia-fabrica-desarrollo-agentica.md) — la especificación vinculante del sistema. Describe el diseño de la fábrica; la dirección y su estado de materialización viven en la hoja de ruta.
- [Análisis de las conversaciones](../04-analisis-conversaciones-ia.md) y [Investigación y revalidación](../05-analisis-investigacion-leandro-y-revalidacion.md) — procedencia y razonamiento del rumbo. Son fotos fijas: no se mantienen al día.
- [ADR-001 — Runtime](../../specs/adr/ADR-001-runtime.md) — por qué Claude Code hoy y cuándo activar el harness SDK.
- [Contrato de work package](../../work-packages/_TEMPLATE.md) — la plantilla de hoja de encargo.

## Mapa del repositorio

```
CLAUDE.md              Constitución: normas que todo agente carga siempre
CODEOWNERS             Propiedad declarada por componente; revisión obligatoria como norma,
                       todavía NO impuesta técnicamente por el ruleset — WP-011
.claude/
  settings.json        Permisos (allow/deny/ask) y hooks globales
  agents/              Los 5 agentes, uno por archivo
  hooks/guard.sh       PreToolUse best-effort: deniega las escrituras fuera del alcance
                       del WP activo que reconoce; falla abierto. El deny de rutas
                       protegidas y comandos vetados vive en settings.json, no aquí
  skills/              new-work-package · run-verification · prepare-pr
docs/
  02-guia-...          Especificación vinculante del sistema
  03-hoja-de-ruta.md   Rumbo vigente: arquitectura objetivo, etapas y secuencia
  04-... · 05-...      Procedencia y razonamiento del rumbo (fotos fijas)
specs/
  decisions/           DEC-xxx.md — decisiones, una por archivo
  adr/                 ADR-xxx.md — decisiones de arquitectura
  requirements/        REQ por categoría (FR, NFR, SEC...)
work-packages/
  _TEMPLATE.md         Contrato de hoja de encargo
  ACTIVE               WP en curso ← lo lee guard.sh
  WP-XXX-*.md          Un archivo por work package
evidence/WP-XXX/       Logs, resultados y costes por WP
.github/               Plantilla de PR y workflows de CI
docs/manual/           Este manual
```

## El principio que lo sostiene todo

**El estado vive en archivos del repositorio, nunca en la sesión.** `work-packages/ACTIVE`, el estado de cada WP y las evidencias son archivos versionados. Cualquiera —persona o agente, hoy o dentro de seis meses— puede reconstruir en qué punto está el trabajo leyendo el repositorio y nada más.

De ahí se derivan las tres reglas que no se negocian:

1. **Sin WP, no hay cambios.** Un agente trabaja sobre un único WP aprobado.
2. **Solo los archivos permitidos.** El hook avisa y deniega de inmediato lo que reconoce, pero quien decide es el diff que se fusiona: un archivo fuera de la lista es rechazo en revisión.
3. **Ante ambigüedad, parada.** Detenerse a preguntar es el comportamiento correcto, no un fallo.
