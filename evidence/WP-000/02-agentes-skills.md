# Evidencia 2 — Carga de agentes y skills

**WP:** WP-000 · **Fecha:** 2026-07-23 · **Comando:** `python3 evidence/WP-000/checks/check-agents-skills.py`
**Resultado: 0 fallos, 0 avisos (exit 0)**

## Los 5 agentes

```
--- Agentes (.claude/agents/) ---
  OK     planner            model=opus     maxTurns=30    solo lectura
  OK     implementer        model=sonnet   maxTurns=60    escribe
  OK     qa                 model=sonnet   maxTurns=40    escribe
  OK     security-reviewer  model=opus     maxTurns=30    solo lectura
  OK     code-reviewer      model=opus     maxTurns=30    solo lectura
```

Comprobado en cada uno: frontmatter que empieza en la línea 1, YAML válido, `name` coincidente con el nombre del archivo, `description` presente, y ausencia de `Edit`/`Write` en los tres agentes de solo lectura.

| Agente | tools | disallowedTools | model | maxTurns | Extra |
|---|---|---|---|---|---|
| `planner` | Read, Grep, Glob, Bash | Edit, Write, NotebookEdit | opus | 30 | — |
| `implementer` | Read, Grep, Glob, Edit, Write, Bash | — | sonnet | 60 | `isolation: worktree` |
| `qa` | Read, Grep, Glob, Bash, Edit, Write | — | sonnet | 40 | — |
| `security-reviewer` | Read, Grep, Glob, Bash | Edit, Write, NotebookEdit | opus | 30 | — |
| `code-reviewer` | Read, Grep, Glob, Bash | Edit, Write, NotebookEdit | opus | 30 | — |

El frontmatter de `implementer` es literal el del §3 de la guía. Los otros cuatro siguen su patrón con menos permisos, según §3 párrafo 2.

## Las 3 skills

```
--- Skills (.claude/skills/<nombre>/SKILL.md) ---
  OK     new-work-package   Genera un work package nuevo desde la planti...
  OK     run-verification   Ejecuta la batería de validación del WP acti...
  OK     prepare-pr         Abre la PR de un WP con la plantilla rellena...
```

Las tres en `.claude/skills/<nombre>/SKILL.md`, con `name` coincidente con su directorio y `description` presente.

## Hook

```
--- Hook ---
  OK     guard.sh ejecutable
```

## ⚠️ Límite de esta evidencia

El criterio original pedía que «`claude` en el repo carga los 5 agentes y las 3 skills». **Esa comprobación no se ha ejecutado**: no es posible lanzar una sesión interactiva de `claude` desde dentro de esta sesión.

Lo verificado aquí es que los archivos están en las rutas que lee Claude Code y que su frontmatter es válido y parseable — condición necesaria, no suficiente.

**Pendiente de confirmación humana**, en una sesión interactiva sobre el repositorio:

```bash
claude
```

```
/agents    → deben aparecer: planner, implementer, qa, security-reviewer, code-reviewer
/skills    → deben aparecer: new-work-package, run-verification, prepare-pr
```

Indicio favorable registrado en esta sesión: el hook declarado en `.claude/settings.json` **se activó y bloqueó operaciones reales** del agente (ver `03-bloqueo-hook.md`, parte A), lo que demuestra que Claude Code sí está leyendo la configuración de `.claude/` de este repositorio.
