# Paso 0 de la Fase 1 — Resumen de la preparación

**Fecha:** 2026-07-23 · **WP:** WP-000 (cierre del bootstrap) · **Plan vinculante:** `FDA-diagnostico-y-plan-fase1.md`

Preparación previa a la calibración. **No se ha ejecutado ningún WP de la Fase 1**, ni se ha pasado ninguno a `ready`.

## Las 9 tareas

| # | Tarea | Estado |
|---|---|---|
| 1 | Divisa: DEC + `fx-rates.md` + conversión de WP-000 | ✅ |
| 2 | ADR-001 con criterios M1/M2/M3 + veto | ✅ |
| 3 | Autoinstalación del sandbox (3 valores) | ✅ |
| 4 | Requisitos semilla | ✅ |
| 5 | Convenciones: globs, WP-ID explícito, `memory` off | ✅ |
| 6 | Suite adversarial en `tests/guard/` | ✅ |
| 7 | WP-001 a WP-005 en `draft` | ✅ |
| 8 | GitHub: repo, ruleset, scanning, Dependabot | ✅ salvo el secreto de API |
| 9 | Verificación y evidencias | ✅ este directorio |

## Lo creado, por tarea

### 1 — Divisa

- `specs/decisions/DEC-001-divisa-costes.md` — USD registro inmutable, EUR gobierno, tipo BCE congelado por mes natural, formato de `cost.md`, agregación mensual y doble vista histórica (contable en EUR / técnica en USD).
- `specs/finops/fx-rates.md` — registro *append-only*. Primera entrada: **2026-07 → 1,1383** (BCE, 2026-07-01, vía frankfurter.dev).
- `evidence/WP-000/cost.md` — conversión reconstruida: **15,14 USD → 13,30 € = 18 %** de 75 €.

### 2 — ADR-001

Estado `accepted`. Criterios de activación del harness sustituidos por **M1 madurez ∧ M2 dolor ∧ M3 economía**, más veto hasta completar la Fase 2. Añadido el invariante **I4**: el WP-ID se pasa como argumento explícito, no solo por `ACTIVE`.

### 3 — Autoinstalación del sandbox

- `CODEOWNERS` → `@ivanes189` (13 marcadores sustituidos).
- `.claude/settings.json` → 6 reglas `allow` nuevas para los comandos de validación.
- `.github/workflows/ci.yml` → job `calidad` instanciado: **actionlint + shellcheck + suite del guard + link-check**.

### 4 — Requisitos semilla

`REQ-FDA-001` (alcance del diff verificado en CI) · `REQ-FDA-002` (workflows con permisos mínimos y actions por SHA) · `REQ-FDA-003` (manual navegable) · `SEC-001` (sin secretos en repo ni logs). Cada uno con id, texto, justificación, criterio de verificación y estado actual.

### 5 — Convenciones

- `_TEMPLATE.md` documenta la semántica de «Archivos permitidos»: rutas relativas a la raíz, `*` no cruza `/`, `**` sí, precedencia de prohibidos, traversal denegado, symlinks que no amplían alcance, sensibilidad a mayúsculas.
- Las 3 skills aceptan el WP-ID como argumento, con `ACTIVE` como respaldo.
- `memory: project` comentado —no borrado— en los 5 agentes.

### 6 — Suite adversarial

`tests/guard/run-suite.sh` con **58 casos verdes y 8 huecos conocidos** documentados como `xfail` con el WP que los cerrará. Grupos nuevos: **I (autoprotección)** y **J (huecos conocidos)**.

### 7 — WPs de calibración

`WP-001` a `WP-005`, todos en `draft`, transcritos de las fichas del §3 sin inventar campos.

### 8 — GitHub

Repositorio, ruleset activo, secret scanning, push protection y Dependabot. Detalle en `04-github.md`.

## Desviaciones respecto al plan, con su justificación

| Punto del plan | Qué se hizo | Por qué |
|---|---|---|
| «patrones fnmatch» | Se documentó la semántica **realmente implementada**: `*` no cruza `/`, `**` sí | En fnmatch de Python `*` también cruza `/`, luego `src/*` cubriría `src/a/b/c.py`. Documentar fnmatch habría creado divergencia entre el contrato escrito y `guard.sh`, que es el fallo más grave que podía introducir el Paso 0 |
| Repo **privado** | Repo **público** | Rulesets y branch protection no están disponibles en repos privados de cuentas sin Pro. El plan clasifica la protección de rama como *bloqueo real* (§1.3-B1): sin ella, la Fase 1 mediría una fábrica cuya garantía central no está activa. Decisión humana explícita |
| — | Historial anonimizado antes de publicar | Los 35 commits llevaban un correo personal que habría quedado público y permanente. Sustituido por el `noreply` de GitHub; árbol de archivos idéntico |
| `tests/guard/` | Se amplió el alcance de WP-000 a `tests/**` | La ruta exigida por la tarea 6 no estaba en los archivos permitidos. Ampliación consciente, con commit propio y anotación en el WP |
| Revisores adicionales | En comentario HTML | La plantilla tiene un solo campo `agente_revisor` y las fichas de WP-002 y WP-005 nombran dos. No se inventaron campos |

## Hallazgos del propio Paso 0

El CI y los linters encontraron **cinco defectos reales** en el trabajo de esta sesión, cuatro de ellos en archivos escritos durante ella:

1. `SC2046` — `$(go env GOPATH)/bin/actionlint` sin comillas en `ci.yml`.
2. `SC1072/SC1073` — comentarios que empiezan por la palabra `shellcheck`: la herramienta los interpreta como directivas suyas. **Se cometió dos veces**, la segunda diez minutos después de documentar el fallo en el manual.
3. Latente — `set -o pipefail` con `find` sobre `scripts/`, que aún no existe: habría abortado el paso.
4. `SC2001` — `echo "$var" | sed` en `ci.yml`.
5. `SC1087` (error) — `"$_out[^/]*"` en `guard.sh`: forma ambigua que parece indexado de array.

Ninguno lo detectó una persona leyendo el código. El argumento a favor de tener los linters en local, y no confiar en que quien escribe recuerde sus propias notas, queda documentado con datos.

## Estado de la Fase 1

**No iniciada.** `work-packages/ACTIVE` apunta a `WP-000`. Los cinco WPs de calibración están en `draft` y esperan aprobación humana explícita para pasar a `ready`.
