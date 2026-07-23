# Evidencia 3 — Demostración de bloqueo del hook

**WP:** WP-000 · **Fecha:** 2026-07-23 · **Comando:** `bash evidence/WP-000/checks/check-guard.sh`
**Resultado: 42 casos, 42 correctos, 0 fallidos (exit 0)** ✅

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

Bloqueado por `.claude/settings.json` → `permissions.deny` → **`Edit(./.github/workflows/**)`**.
Nótese que `.github/pull_request_template.md` **sí** se creó sin problema: el deny discrimina por ruta, no bloquea `.github/` entero.

> **Corrección posterior.** Esta evidencia atribuyó inicialmente el bloqueo a una regla `Write(./.github/workflows/**)` que se había añadido para "endurecer" el deny. Es incorrecto: en Claude Code, las reglas de permiso sobre archivos se evalúan **solo** con `Edit(ruta)`, y esa forma cubre todas las herramientas de edición (`Edit`, `Write`, `MultiEdit`, `NotebookEdit`). Las entradas `Write(...)` son inertes y el CLI las señala al arrancar. La protección real la ejercía la regla `Edit(...)` que ya venía del §3 de la guía. Ver `docs/manual/07-troubleshooting.md`.

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

--- G. BASH: escrituras vía shell (el vector que saltaba el hook) ---
  OK    exit=2  echo > src/y.py (redirección)
  OK    exit=2  echo >> package.json (append)
  OK    exit=2  tee src/z.py
  OK    exit=2  sed -i sobre src/
  OK    exit=2  cp hacia src/
  OK    exit=2  mv hacia tests/
  OK    exit=2  rm -rf src/
  OK    exit=2  dd of=src/big.bin
  OK    exit=2  redirección con ruta entrecomillada

--- H. BASH: lo que NO debe bloquearse (falsos positivos) ---
  OK    exit=0  echo > docs/ok.md (en alcance)
  OK    exit=0  echo >> evidence/WP-000/log.txt
  OK    exit=0  redirección a /dev/null
  OK    exit=0  escritura en /tmp
  OK    exit=0  commit con > dentro de comillas
  OK    exit=0  pytest (sin escrituras)
  OK    exit=0  grep con > en el patrón

==============================================================
 RESULTADO: 42 correctas, 0 fallidas
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

## El bypass de Bash: encontrado, medido y cerrado

**El hueco.** El matcher original era `Edit|Write|MultiEdit|NotebookEdit`. No incluía `Bash`, de modo que un agente con esa herramienta —el `implementer` la tiene— podía hacer `echo "codigo" > src/fuera_de_alcance.py` y saltarse el control central por completo. Los `deny` de `settings.json` tenían el mismo límite: cubren las herramientas de edición, no el shell.

**Medición antes del arreglo.** Se añadieron 16 casos de Bash a la suite y se ejecutó contra el guard entonces instalado:

```
 RESULTADO: 33 correctas, 9 fallidas
```

Los 9 fallos son exactamente los 9 vectores de escritura del grupo G, todos devolviendo `exit=0` (permitido) cuando debían devolver `exit=2`. El hueco quedó cuantificado, no supuesto.

**El arreglo.** `guard.sh` analiza ahora el comando de Bash y extrae rutas de escritura de: `>`, `>>` (incluido destino entrecomillado), `tee`, `sed -i`, `perl -i`, `dd of=`, `cp`, `mv`, `rm`, `rmdir`, `truncate`, `touch`, `install`, `shred` y `ln`. El matcher pasó a `Edit|Write|MultiEdit|NotebookEdit|Bash`.

Para evitar falsos positivos, el contenido entrecomillado se neutraliza antes de buscar redirecciones —`git commit -m "arreglar a > b"` no dispara— y se exentan `/dev/null`, `/dev/std*`, `/tmp` y `$TMPDIR`. Los 7 casos del grupo H prueban justo eso.

**Verificación posterior:** 42/42, sin regresión en ninguno de los 26 casos originales.

**Cómo se aplicó.** El propio deny impedía a cualquier agente modificar `.claude/hooks/**` y `.claude/settings.json` — incluido el agente que construía la FDA. El parche se validó primero como candidato en `evidence/` (42/42) y lo aplicó una persona. Es la propiedad que hace que el control sea un control: **ni el agente que lo escribe puede desactivarlo.**

## Límite que permanece

El analizador de Bash es **best-effort, no hermético**. El shell es demasiado expresivo para garantizarlo:

```bash
python3 -c "open('src/x.py','w').write('...')"   # no se detecta
eval "$(printf 'echo x > src/y.py')"              # no se detecta
```

Red de seguridad: job `Gobierno FDA` en CI, revisión del diff completo y branch protection. Nada llega a `main` sin pasar por ahí. Documentado en `docs/manual/07-troubleshooting.md`.

⚠️ **La línea más sensible de toda la configuración** es el matcher de `settings.json`. Si alguien retira `Bash`, el hueco se reabre entero y en silencio. La suite lo detecta: 9 de los 42 casos fallan.
