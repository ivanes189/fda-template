# WP-005 — `check-scope` en CI y endurecimiento de workflows

estado: draft
prioridad: P0
agente_responsable: implementer     agente_revisor: security-reviewer
requisitos: [REQ-FDA-001, REQ-FDA-002, SEC-001]     adr: [ADR-001]
presupuesto_max_eur: 60             max_ciclos_correccion: 2

<!-- Revisores: security-reviewer (obligatorio: toca CI/CD) + code-reviewer.
     Fusión humana obligatoria. -->

## Objetivo y contexto

`ci.yml` ejecuta `check_scope` sobre el diff de cada pull request —extrayendo el WP-ID del nombre de la rama `wp/WP-XXX-*`— y falla si hay archivos fuera de alcance. Además, los workflows quedan endurecidos: `permissions:` mínimos declarados, acciones de terceros fijadas por SHA y sin construcciones inseguras con `pull_request_target`.

Contexto: es el WP que lleva el enforcement del alcance desde el hook local —evitable, preventivo— hasta **la frontera inviolable**, que es GitHub. Tras fusionarlo, un cambio fuera de alcance no puede llegar a `main` por ninguna vía, use el agente la herramienta que use.

Activa por contrato al `security-reviewer`: toca CI/CD, que es la superficie más sensible del repositorio.

## Alcance (incluido / fuera de alcance)

**Incluido:**
- Job en `ci.yml` que ejecuta `scripts/check_scope.py` sobre el diff de la PR.
- Extracción del WP-ID desde el nombre de la rama (`wp/WP-XXX-*`).
- `permissions:` mínimos y explícitos en `ci.yml`.
- Fijación por SHA de las acciones de terceros usadas en `ci.yml`.
- Wiring mínimo en `scripts/**` si el job lo necesita.

**Fuera de alcance:**
- Modificar `claude.yml` o `code-review.yml`. Su endurecimiento irá en un WP propio.
- Cambiar la lógica de `check_scope.py` (viene de WP-002 y se da por buena).
- Marcar el check como obligatorio en el ruleset: es acción humana en GitHub, no código.
- Cualquier cambio en `.claude/**`.

## Archivos permitidos

- .github/workflows/ci.yml
- scripts/**

## Archivos prohibidos

- .github/workflows/claude.yml
- .github/workflows/code-review.yml
- .claude/**

## Contratos técnicos (interfaces, schemas, eventos, invariantes)

**Contrato del job de alcance:**

- Se dispara en `pull_request` contra `main`.
- Extrae el WP-ID de `github.head_ref` con el patrón `wp/(WP-[0-9]{3})-.*`.
- Si la rama no sigue el patrón: el job **falla** con mensaje explícito. Una PR sin WP identificable no es fusionable (convención: un WP = una rama = una PR).
- Ejecuta `python3 scripts/check_scope.py <WP-ID> <base>...<head>` y propaga su código de salida.

**Invariantes de seguridad (REQ-FDA-002):**

- Todo workflow declara `permissions:` explícitamente, con el mínimo necesario.
- Toda acción de terceros va fijada por SHA de 40 caracteres, con la versión legible en un comentario adyacente.
- Ningún valor controlable por terceros se interpola con `${{ }}` dentro de un bloque `run:`; se pasa por `env:`.
- No se usa `pull_request_target`.

## Entorno autorizado (herramientas, comandos, red, secretos)

- Herramientas: Read, Grep, Glob, Edit, Write, Bash
- Comandos: `actionlint`, `python3`, `git` (local), `gh` (solo lectura de runs)
- Red: solo la necesaria para consultar los SHA de las acciones en GitHub
- Secretos: NINGUNO. Este WP **no** lee ni escribe secretos; solo declara qué permisos necesita cada job.

## Verificación (comandos de validación + criterios de aceptación medibles)

**Comandos:**

```bash
actionlint .github/workflows/ci.yml
grep -n 'uses:' .github/workflows/ci.yml | grep -v '@[0-9a-f]\{40\}' | grep -v 'uses: \./'
python3 .claude/skills/run-verification/validate-workflows.py .github/workflows
```

El `grep` debe devolver **vacío**: significa que no queda ninguna acción sin fijar por SHA.

**Criterios de aceptación:**

- [ ] `actionlint` en verde sobre `ci.yml`
- [ ] Ninguna acción de terceros sin SHA de 40 caracteres
- [ ] Todos los jobs declaran `permissions:` explícitos y mínimos
- [ ] **PR de prueba con un archivo fuera de alcance → el CI FALLA** (run capturado)
- [ ] **PR válida → el CI queda en verde** (run capturado)
- [ ] Informe del `security-reviewer` con severidades, y **todas las ALTAS resueltas**
- [ ] Tras fusionar: el check queda marcado como obligatorio en el ruleset (acción humana)

## Evidencias exigidas (qué debe aparecer en evidence/WP-005/)

- [ ] Salida del run de CI **fallando** ante el archivo fuera de alcance
- [ ] Salida del run de CI **en verde** con la PR válida
- [ ] Salida de `actionlint`
- [ ] Informe completo del `security-reviewer`, con la resolución de cada hallazgo alto
- [ ] `cost.md` con el formato de DEC-001

## Condiciones de parada específicas

- Necesidad de tocar `claude.yml` o `code-review.yml`: parar. Están fuera de alcance por contrato y su endurecimiento merece su propio WP con su propia revisión.
- Cualquier hallazgo **CRÍTICO o ALTO** del `security-reviewer`: el WP se bloquea hasta resolverlo. Al tocar CI/CD, un fallo aquí compromete los secretos del repositorio.
- Si fijar una acción por SHA exige red y no está disponible: parar y solicitar los SHA, en lugar de dejar etiquetas móviles.

## Migración / rollback

El cambio afecta a CI, no a datos. Rollback = revertir el commit de `ci.yml`; el check deja de ejecutarse y se vuelve al estado anterior sin efectos colaterales.

**Orden de activación importante:** primero se fusiona el WP (el check empieza a ejecutarse pero no bloquea), y **después** se marca como obligatorio en el ruleset. Marcarlo obligatorio antes de que exista dejaría todas las PRs bloqueadas por un check que nunca reporta.
