# Evidencia 3 — Demostración de bloqueo del hook

**WP:** WP-000 · **Fecha:** 2026-07-23 · **Comando:** `bash evidence/WP-000/checks/check-guard.sh`
**Resultado: 26 casos, 26 correctos, 0 fallidos (exit 0)**

Esta evidencia tiene dos partes: los bloqueos **provocados** con la suite de pruebas, y los bloqueos **reales** que el hook produjo contra el propio agente durante esta sesión.

---

## Parte A — Bloqueos reales durante el bootstrap

Los más valiosos: no son simulaciones, son el hook interceptando operaciones reales de Claude Code en esta sesión.

### A.1 — Escritura fuera del repositorio (hook `PreToolUse` en vivo)

El agente intentó escribir en su directorio temporal de trabajo. El hook lo denegó:

```
PreToolUse:Write hook error: [.claude/hooks/guard.sh]: BLOQUEADO por la FDA (.claude/hooks/guard.sh)

Ruta fuera del repositorio: /private/tmp/claude-501/-Users-ivan-Desktop-fda-template/
                            f37f3ac6-29bf-4261-bedb-cc57bc2b5c78/scratchpad/claude.yml

La FDA solo permite escrituras dentro del repositorio (/Users/ivan/Desktop/fda-template).
Si necesitas escribir fuera, es una decisión humana: detente y solicítala.
```

### A.2 — Escritura en ruta protegida (capa `permissions.deny`)

El agente intentó crear `.github/workflows/ci.yml` con la herramienta `Write`:

```
File is in a directory that is denied by your permission settings.
```

Bloqueado por `.claude/settings.json` → `permissions.deny` → `Write(./.github/workflows/**)`.
Nótese que `.github/pull_request_template.md` **sí** se creó sin problema: el deny discrimina por ruta, no bloquea `.github/` entero.

### A.3 — Modificación del propio hook

El agente intentó modificar `.claude/hooks/guard.sh` para añadirle una guarda de Bash:

```
File is in a directory that is denied by your permission settings.
```

**Resultado de gobierno:** un agente no puede desactivar ni debilitar sus propias guardas. Ni siquiera el agente que las está construyendo. Esta es la propiedad que hace que el control sea un control y no una recomendación.

---

## Parte B — Suite de pruebas (26 casos)

```
==============================================================
 Verificación del hook guard.sh — WP activo: WP-000
 Convención: exit 0 = permite · exit 2 = BLOQUEA
==============================================================

--- A. Rutas DENTRO del alcance de WP-000 (deben permitirse) ---
  OK    exit=0  CLAUDE.md
  OK    exit=0  CODEOWNERS
  OK    exit=0  .claude/agents/planner.md
  OK    exit=0  docs/manual/MANUAL.md
  OK    exit=0  specs/adr/ADR-001-runtime.md
  OK    exit=0  .github/workflows/ci.yml
  OK    exit=0  ruta absoluta interna

--- B. REGRESIÓN: rutas permitidas que AÚN NO EXISTEN en disco ---
  OK    exit=0  docs/inexistente/futuro.md
  OK    exit=0  evidence/WP-777/nuevo/log.txt
  OK    exit=0  specs/requirements/REQ-NUEVO.md

--- C. Rutas FUERA del alcance por omisión (deben bloquearse) ---
  OK    exit=2  src/pagos/cobros.py
  OK    exit=2  package.json
  OK    exit=2  tests/test_x.py
  OK    exit=2  CLAUDE.md.bak (no es prefijo)
  OK    exit=2  docsX/otro.md (no es docs/)

--- D. Rutas PROHIBIDAS explícitamente (prohibido gana a permitido) ---
  OK    exit=2  .env.production
  OK    exit=2  docs/secrets/clave.txt
  OK    exit=2  specs/cert.pem

--- E. Evasión (deben bloquearse) ---
  OK    exit=2  traversal ../fuera.txt
  OK    exit=2  traversal docs/../../fuera.txt
  OK    exit=2  absoluta fuera del repo
  OK    exit=2  NotebookEdit fuera de alcance

--- F. FAIL-CLOSED: ante cualquier duda, denegar ---
  OK    exit=2  sin archivo ACTIVE
  OK    exit=2  ACTIVE vacío
  OK    exit=2  ACTIVE apunta a WP inexistente
  OK    exit=2  WP sin rutas permitidas

==============================================================
 RESULTADO: 26 correctas, 0 fallidas
==============================================================
```

### Salida literal de una denegación

```
$ echo '{"tool_name":"Write","tool_input":{"file_path":"src/pagos/cobros.py"}}' \
    | .claude/hooks/guard.sh

BLOQUEADO por la FDA (.claude/hooks/guard.sh)

Ruta fuera del alcance de WP-000: src/pagos/cobros.py

Rutas permitidas por el WP activo:
  - CLAUDE.md
  - CODEOWNERS
  - .gitignore
  - .claude/**
  - docs/**
  - specs/**
  - work-packages/**
  - evidence/**
  - .github/**

Qué hacer (CLAUDE.md, regla 3 del implementer): DETENTE y solicita decisión.
No amplíes el alcance por tu cuenta ni edites work-packages/ACTIVE para
esquivar este control. Si el cambio es realmente necesario, el WP está mal
definido y hay que corregirlo explícitamente.

exit=2
```

---

## Bug encontrado y corregido durante la verificación

El grupo **B (regresión)** existe por un defecto real detectado y corregido en esta sesión.

**Defecto:** `matches_any()` iteraba los patrones con `for _g in $_globs`. Una variable sin comillas en un `for` sufre *pathname expansion*: bash expandía cada patrón **contra el disco real** antes de compararlo. `docs/**` se convertía en `docs/manual docs/02-guia-...`.

**Consecuencia:** el guard comparaba contra la lista de archivos que **ya existían**, no contra el contrato del WP. Rutas nuevas dentro de alcance se bloqueaban, y el control dejaba de significar lo que decía significar.

**Detección:** los casos permitidos con `**` fallaban mientras los literales (`CLAUDE.md`, `.gitignore`) pasaban — porque coincidían con archivos existentes.

**Corrección:** iteración con `while IFS= read -r`, que no divide ni expande. Los 3 casos del grupo B son la prueba de no regresión.

Un segundo defecto previo (BSD sed trata `\` como escape dentro de clases de caracteres, GNU no) se corrigió reescribiendo `glob_to_ere()` en bash puro, sin `sed`.

---

## Límite conocido de este control

`guard.sh` se dispara con `matcher: "Edit|Write|MultiEdit|NotebookEdit"`. **No cubre `Bash`.** Un agente con `Bash` puede escribir con `echo x > ruta` y saltárselo entero.

Cerrar ese hueco requiere modificar `.claude/settings.json` y `.claude/hooks/guard.sh`, **ambos bloqueados por el propio deny** (ver A.3). Queda pendiente de ejecución humana y documentado en `docs/manual/07-troubleshooting.md`.

Red de seguridad mientras tanto: job `Gobierno FDA` en CI, revisión del diff completo y branch protection. Nada llega a `main` sin pasar por ahí.
