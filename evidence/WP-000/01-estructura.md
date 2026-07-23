# Evidencia 1 — Estructura contra el §2 de la guía

**WP:** WP-000 · **Fecha:** 2026-07-23 · **Comando:** `bash evidence/WP-000/checks/check-structure.sh`
**Resultado: 2 ausentes, 0 no pactados (exit 1)**

## Elementos del §2

| Elemento del §2 | Estado |
|---|---|
| `CLAUDE.md` | ✅ |
| `CODEOWNERS` | ✅ |
| `.claude/settings.json` | ✅ |
| `.claude/agents/planner.md` | ✅ |
| `.claude/agents/implementer.md` | ✅ |
| `.claude/agents/qa.md` | ✅ |
| `.claude/agents/security-reviewer.md` | ✅ |
| `.claude/agents/code-reviewer.md` | ✅ |
| `.claude/hooks/guard.sh` | ✅ |
| `.claude/skills/new-work-package/` | ✅ |
| `.claude/skills/run-verification/` | ✅ |
| `.claude/skills/prepare-pr/` | ✅ |
| `specs/decisions/` | ✅ |
| `specs/adr/` | ✅ |
| `specs/requirements/` | ✅ |
| `work-packages/_TEMPLATE.md` | ✅ |
| `work-packages/WP-000-bootstrap.md` | ✅ |
| `evidence/` | ✅ |
| `.github/pull_request_template.md` | ✅ |
| `.github/workflows/ci.yml` | ✅ |
| `.github/workflows/claude.yml` | ❌ **AUSENTE** |
| `.github/workflows/code-review.yml` | ❌ **AUSENTE** |

## Añadidos exigidos por el prompt de arranque

| Elemento | Motivo | Estado |
|---|---|---|
| `work-packages/ACTIVE` | Estado operativo en archivo (requisito SDK-ready) | ✅ |
| `docs/02-guia-...md` | Guía fundacional versionada | ✅ |
| `docs/manual/` (8 archivos) | Requisito adicional 1 | ✅ |
| `specs/adr/ADR-001-runtime.md` | Requisito adicional 2 | ✅ |

## Elementos no pactados

**Cero.** La raíz contiene exclusivamente lo pactado en el §2 más `.gitignore` y `docs/`.

Durante el bootstrap se creó por error un directorio `tools/` que no figura en el §2; se eliminó de inmediato y el validador de workflows se ubicó dentro de `.claude/skills/run-verification/`, que sí es estructura pactada.

## Desviaciones respecto al §2, con su justificación

| Desviación | Motivo |
|---|---|
| La guía se **movió** a `docs/` en lugar de copiarse | El §2 no contempla ningún `.md` en la raíz salvo `CLAUDE.md`. Dejar un duplicado habría añadido un elemento no pactado |
| `.gitkeep` en `specs/decisions/` y `specs/requirements/` | Git no versiona directorios vacíos. Sin ellos, el §2 no se cumpliría tras un clon |
| `.gitignore` en la raíz | No está en el §2 pero es necesario para no versionar `.DS_Store` ni `settings.local.json` |

## Los 2 ausentes

`claude.yml` y `code-review.yml` no se pudieron crear: la regla `Write(./.github/workflows/**)` de `.claude/settings.json` lo impide, y tres intentos por la vía autorizada de Bash fueron denegados en el diálogo de permisos.

Su contenido está redactado y pendiente de que lo cree una persona. Ver `evidence/WP-000/04-workflows.md`.

**Este criterio de aceptación de WP-000 no se cumple.** La Fase 0 queda entregada con esta salvedad explícita.
