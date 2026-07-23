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

## Confirmación de carga real en el CLI

Los checks anteriores validan los archivos (frontmatter y rutas). La carga efectiva por Claude Code se confirmó en una **sesión interactiva real** sobre el repositorio, el 2026-07-23.

### Skills — CONFIRMADO ✅

`/skills` en Claude Code **v2.1.218** listó las tres, todas con ámbito `project` y estado `on`:

```
Skills — 3 skills · project
  ✔ on   new-work-package · project · ~60 tok
  ✔ on   prepare-pr · project · ~40 tok
  ✔ on   run-verification · project · ~60 tok
```

Es confirmación de primer orden: no es que los archivos existan, es que el CLI los ha leído del proyecto y los ha activado.

### Agentes — CONFIRMADO ✅

⚠️ En Claude Code **v2.1.218 el asistente `/agents` fue retirado** y ya no lista los subagentes (devuelve un mensaje remitiendo a `.claude/agents/` y a los docs). El comando del criterio original ya no aplica en esta versión.

Se confirmó por enumeración directa en sesión interactiva. Al preguntar «¿Qué subagentes tienes disponibles en este proyecto?», el CLI listó los 5 del proyecto junto a los integrados del sistema:

```
- code-reviewer        ← proyecto
- implementer          ← proyecto
- planner              ← proyecto
- qa                   ← proyecto
- security-reviewer    ← proyecto
  (además: claude, claude-code-guide, Explore, general-purpose,
           Plan, statusline-setup — integrados del sistema)
```

**Los 5 agentes definidos en `.claude/agents/` están cargados y disponibles para delegación.**

### Indicios convergentes ya registrados

- El hook de `.claude/settings.json` **se activó y bloqueó operaciones reales** del agente (ver `03-bloqueo-hook.md`, parte A): Claude Code lee la configuración de `.claude/` de este repositorio.
- El CLI **leyó y evaluó `settings.json`** hasta el punto de avisar de las 4 reglas `Write(...)` inertes, que después se eliminaron.
- Las 3 skills se cargan desde `.claude/skills/`, mismo mecanismo de descubrimiento de proyecto que `.claude/agents/`.
