# Evidencia 4 — Validación de workflows

**WP:** WP-000 · **Fecha:** 2026-07-23
**Comando:** `python3 .claude/skills/run-verification/validate-workflows.py .github/workflows`
**Resultado: 0 errores, 0 avisos (exit 0) — pero solo 1 de 3 workflows existe**

## Salida

```
Workflows analizados: 1
  - .github/workflows/ci.yml

RESULTADO: 0 errores, 0 avisos
```

## Herramienta empleada

`actionlint` **no está disponible** en esta máquina y su instalación requiere descargar un binario de la red, fuera del entorno autorizado de WP-000 (`Red: NINGUNA`).

Se usó un validador equivalente escrito para la ocasión, que comprueba:

- YAML sintácticamente válido
- Claves obligatorias: `name`, `on`, `jobs`
- Cada job con `runs-on` y `steps` no vacíos
- Cada paso con `uses` o `run`
- Acciones de terceros ancladas a una versión (avisa si apuntan a `main`/`master`)

Detalle de implementación: la clave `on` de YAML 1.1 se interpreta como booleano `True`, así que el validador acepta ambas formas. Es el fallo silencioso más común al validar workflows con PyYAML.

**No sustituye a `actionlint` en profundidad**: no valida expresiones `${{ }}` ni el catálogo de acciones. Recomendado ejecutarlo también cuando esté disponible:

```bash
actionlint .github/workflows/*.yml
```

## Estado de los 3 workflows

| Workflow | Estado | Contenido |
|---|---|---|
| `ci.yml` | ✅ creado y validado | 3 jobs: `gobierno`, `calidad`, `secretos` |
| `claude.yml` | ❌ **AUSENTE** | Redactado, pendiente de creación humana |
| `code-review.yml` | ❌ **AUSENTE** | Redactado, pendiente de creación humana |

### Por qué faltan dos

`.claude/settings.json` deniega `Write(./.github/workflows/**)` y `Edit(./.github/workflows/**)`. Es deliberado: un agente que puede escribir workflows puede ejecutar código arbitrario con acceso a `ANTHROPIC_API_KEY` y al `GITHUB_TOKEN` del repositorio.

`ci.yml` se creó por la vía de Bash expresamente autorizada para el bootstrap. Los otros dos requerían la misma autorización y **fueron denegados tres veces en el diálogo de permisos**. Se optó por no buscar una cuarta vía: rodear un control de seguridad tras varias negativas es exactamente lo que la FDA prohíbe a sus agentes.

**Criterio de aceptación no cumplido.** Ver el hand-off en el resumen de la sesión.

## Contenido de `ci.yml` (creado)

Tres jobs, todos pensados como status checks obligatorios:

**`gobierno`** — independiente del stack, se ejecuta igual en cualquier instalación:
archivos de gobierno presentes · `guard.sh` ejecutable · el WP activo existe · la suite de 26 casos del guard · workflows válidos · manual sin enlaces rotos · el manual acompaña a los cambios de proceso.

**`calidad`** — bloque marcado `{{COMANDOS_VALIDACION}}`, con autodetección de stack (Python y Node) para que la plantilla vacía no falle. En un proyecto real deben fijarse los comandos.

**`secretos`** — `gitleaks` anclado a `v2` + comprobación de que no hay `.env`, `*.pem` ni `secrets/` versionados.

Nota de seguridad aplicada: el SHA base se pasa por variable de entorno (`env: BASE_SHA`) en lugar de interpolar `${{ }}` directamente dentro de `run:`, que es el patrón de inyección habitual en GitHub Actions.
