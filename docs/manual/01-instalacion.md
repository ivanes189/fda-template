[← Manual](MANUAL.md)

# 01 — Instalación en un proyecto nuevo

Instalar la FDA = copiar la plantilla y ajustar **3 valores**. Después, una configuración de GitHub que se hace **una sola vez por proyecto**.

## Paso 1 — Copiar la plantilla

```bash
# Opción A: desde GitHub, como template repository (recomendado)
gh repo create mi-proyecto --template <tu-org>/fda-template --private

# Opción B: sobre un repositorio existente
cp -r fda-template/{CLAUDE.md,CODEOWNERS,.claude,specs,work-packages,evidence,.github,docs} mi-proyecto/
```

Si instalas sobre un repositorio existente, revisa que no pisas un `.github/workflows/` que ya tuvieras.

```bash
chmod +x .claude/hooks/guard.sh   # imprescindible: si no es ejecutable, el hook no bloquea
```

## Paso 2 — Los 3 valores por proyecto

Son los únicos parámetros que cambian entre proyectos. Búscalos con:

```bash
grep -rn "{{COMANDOS_VALIDACION}}\|{{PROPIEDAD_COMPONENTES}}\|{{PRESUPUESTOS_Y_MODELOS}}" . --exclude-dir=.git
```

### `{{COMANDOS_VALIDACION}}` — los comandos de tu stack

**Dónde:** `.github/workflows/ci.yml` (job `calidad`, bloque marcado) y `.claude/settings.json` (lista `permissions.allow`).

| Stack | Lint | Tipos | Pruebas |
|---|---|---|---|
| Python | `ruff check .` | `mypy .` | `pytest --cov` |
| Node/TS | `npx eslint .` | `npx tsc --noEmit` | `npm test` |

En `ci.yml` el bloque viene con autodetección por stack para que la plantilla vacía no falle. **En un proyecto real, fija los comandos y quita los condicionales `if: hashFiles(...)`**: un job que se salta en silencio no es un control, es un adorno.

En `settings.json`, la lista `allow` evita que el agente pida permiso en cada ejecución de pruebas. Añade los tuyos y quita los que no uses.

### `{{PROPIEDAD_COMPONENTES}}` — quién revisa qué

**Dónde:** `CODEOWNERS` (todas las líneas) y `.claude/settings.json` (lista `permissions.deny`, rutas protegidas).

```bash
# Sustituye el placeholder por tu usuario u equipo de GitHub
sed -i '' 's/{{PROPIEDAD_COMPONENTES}}/@tu-usuario/g' CODEOWNERS   # macOS
sed -i    's/{{PROPIEDAD_COMPONENTES}}/@tu-usuario/g' CODEOWNERS   # Linux
```

Después, añade una línea por componente real del proyecto. La propiedad por componente es lo que convierte «revisión obligatoria» en algo que GitHub hace cumplir.

En `settings.json`, amplía `deny` con las rutas críticas de **tu** proyecto (migraciones, infraestructura, configuración de producción):

```json
"deny": ["Edit(./migrations/**)", "Edit(./infra/**)"]
```

### `{{PRESUPUESTOS_Y_MODELOS}}` — umbrales y política de modelos

**Dónde:** `work-packages/_TEMPLATE.md` (campo `presupuesto_max_eur`), `.claude/agents/*.md` (campos `model` y `maxTurns`) y los `claude_args` de `.github/workflows/claude.yml` y `code-review.yml`.

Umbrales de referencia:

| Umbral | Valor | Qué ocurre al superarlo |
|---|---|---|
| Objetivo por WP | 75 € | Nada: es el valor esperado |
| Aviso por WP | 100 € | Se registra y se revisa el troceado |
| Aprobación por WP | 150 € | El agente **para** y pide autorización |
| Aviso mensual | 750 € | Revisión de la política de modelos |

Política de modelos por tipo de tarea:

| Tarea | Modelo | Agentes |
|---|---|---|
| Arquitectura, seguridad, revisión crítica | premium (`opus`) | `planner`, `security-reviewer`, `code-reviewer` |
| Implementación | estándar (`sonnet`) | `implementer`, `qa` |
| Scaffolding, documentación | económico (`haiku`) | — |

Detalle en [06 — Costes y métricas](06-costes-y-metricas.md).

## Paso 3 — Configuración de GitHub (una sola vez por proyecto)

⚠️ Nada de esto lo hace un agente. Son permisos del plano de control: si un agente pudiera cambiarlos, no serían un control.

- [ ] **Branch protection / ruleset sobre `main`**
  - [ ] Pull request obligatoria antes de fusionar
  - [ ] Status checks obligatorios: `Gobierno FDA`, `Lint · Tipos · Pruebas`, `Escaneo de secretos`
  - [ ] Al menos **1 revisión** aprobatoria
  - [ ] Revisión de **Code Owners** obligatoria
  - [ ] **Force-push prohibido** y borrado de rama prohibido
  - [ ] Aplicar también a administradores (si no, el control es opcional)

- [ ] **Secret scanning + push protection** (Settings → Code security)

- [ ] **Dependabot**: alertas de seguridad y actualizaciones de versión

- [ ] **Secreto `ANTHROPIC_API_KEY`** (Settings → Secrets and variables → Actions).
      Lo necesitan `claude.yml` y `code-review.yml`. Sin él, esos workflows fallan.

- [ ] **Permisos de Actions**: lectura por defecto; permitir crear y aprobar PRs solo si vas a usar `claude.yml`.

> **Por qué la fusión es humana:** el `implementer` no tiene permiso de merge porque GitHub no se lo da, no porque su prompt se lo pida. Esa es toda la diferencia entre un control y una recomendación.

## Paso 4 — Verificar la instalación

```bash
# 1. El hook bloquea de verdad
bash evidence/WP-000/checks/check-guard.sh

# 2. Estructura completa
bash evidence/WP-000/checks/check-structure.sh

# 3. Agentes y skills cargables
python3 evidence/WP-000/checks/check-agents-skills.py

# 4. Workflows válidos
python3 .claude/skills/run-verification/validate-workflows.py .github/workflows

# 5. Manual sin enlaces rotos
python3 evidence/WP-000/checks/check-manual.py
```

Y en una sesión interactiva, que el runtime carga el gobierno:

```bash
claude
```

```
/agents    → deben aparecer: planner, implementer, qa, security-reviewer, code-reviewer
/skills    → deben aparecer: new-work-package, run-verification, prepare-pr
```

## Paso 5 — Primer WP

```bash
cp work-packages/_TEMPLATE.md work-packages/WP-001-mi-primer-cambio.md
# rellena el contrato: ver 03-redactar-un-wp.md
echo "WP-001" > work-packages/ACTIVE
```

Empieza con algo **trivial y verificable**. Los primeros WPs son calibración del sistema, no entrega de valor: no saques conclusiones de coste ni de calidad antes del quinto.

## Errores de instalación frecuentes

| Síntoma | Causa | Arreglo |
|---|---|---|
| El hook no bloquea nada | `guard.sh` sin permiso de ejecución | `chmod +x .claude/hooks/guard.sh` |
| Todo se bloquea | `work-packages/ACTIVE` vacío o ausente | Es intencionado (fail-closed): escribe el WP-ID |
| CI verde sin ejecutar pruebas | Condicionales `hashFiles` del bloque `{{COMANDOS_VALIDACION}}` | Fija los comandos de tu stack |
| `claude.yml` falla | Falta el secreto `ANTHROPIC_API_KEY` | Añádelo en Settings → Secrets |
| CODEOWNERS ignorado | Falta «Require review from Code Owners» | Actívalo en el ruleset |

Más en [07 — Troubleshooting](07-troubleshooting.md).
