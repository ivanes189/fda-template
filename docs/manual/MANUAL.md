# Manual de la Fábrica de Desarrollo Agéntica

Este manual permite operar la FDA **sin memoria conversacional**. Todo el conocimiento operativo vive aquí; si algo solo se sabe porque se dijo en un chat, no se sabe.

> **Regla vinculante** (`CLAUDE.md`): todo cambio de proceso, contrato o agente actualiza `docs/manual/` en la misma PR. Manual desactualizado = PR incompleta. El job `gobierno` de CI lo comprueba automáticamente.

## Qué es la FDA

Un sistema donde agentes de IA especializados implementan software mediante tareas pequeñas, contratos explícitos, ramas aisladas, PRs, CI bloqueante y supervisión humana. Es una **plantilla reutilizable** que se instala en cada proyecto, no un módulo de ninguno.

Lo valioso no es el runtime (hoy Claude Code) sino la **capa de gobierno**: los archivos versionados que definen qué puede hacer cada agente y bajo qué condiciones se detiene. Si mañana cambias de runtime, el gobierno sobrevive.

La seguridad **no depende de que el modelo obedezca instrucciones**. Depende de cuatro controles deterministas:

| Control | Dónde vive | Qué impide |
|---|---|---|
| Permisos de GitHub | branch protection / ruleset | Que un agente fusione su propia PR |
| Allowlists de herramientas | `.claude/agents/*.md` | Que un revisor modifique código |
| Hook `guard.sh` | `.claude/hooks/guard.sh` | Que se escriba fuera del alcance del WP |
| Preflight de configuración | `tests/runtime/check-config.sh`, ejecutado en el job `Gobierno FDA` | Que se fusione una configuración degradada: hook invocado por ruta relativa, sin normalizar a `exit 2`, o reglas de permiso desancladas de la raíz |

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

- [Guía de implantación](../02-guia-fabrica-desarrollo-agentica.md) — la especificación vinculante del sistema.
- [CLAUDE.md](../../CLAUDE.md) — la constitución que todo agente carga siempre.
- [ADR-001 — Runtime](../../specs/adr/ADR-001-runtime.md) — por qué Claude Code hoy y cuándo activar el harness SDK.
- [Contrato de work package](../../work-packages/_TEMPLATE.md) — la plantilla de hoja de encargo.

## Mapa del repositorio

```
CLAUDE.md              Constitución: normas que todo agente carga siempre
CODEOWNERS             Propiedad por componente (revisión obligatoria)
.claude/
  settings.json        Permisos (allow/deny/ask) y hooks globales
  agents/              Los 5 agentes, uno por archivo
  hooks/guard.sh       Bloquea escrituras fuera del alcance del WP activo
  skills/              new-work-package · run-verification · prepare-pr
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
2. **Solo los archivos permitidos.** Lo demás lo bloquea el hook, no la buena voluntad.
3. **Ante ambigüedad, parada.** Detenerse a preguntar es el comportamiento correcto, no un fallo.
