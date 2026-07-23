# Evidencia — Suite adversarial del guard

**Comando:** `bash tests/guard/run-suite.sh` · **Fecha:** 2026-07-23T14:56:46Z · **Commit:** 2fa0f3b

```
==============================================================
 Suite adversarial del guard
 Guard bajo prueba: /Users/ivan/Desktop/fda-template/.claude/hooks/guard.sh
 Convención: exit 0 = permite · exit 2 = BLOQUEA
==============================================================

--- A. Rutas DENTRO del alcance de WP-000 ---
  OK    exit=0  CLAUDE.md
  OK    exit=0  CODEOWNERS
  OK    exit=0  .claude/agents/planner.md
  OK    exit=0  docs/manual/MANUAL.md
  OK    exit=0  specs/adr/ADR-001-runtime.md
  OK    exit=0  .github/workflows/ci.yml
  OK    exit=0  ruta absoluta interna

--- B. REGRESIÓN: rutas permitidas que aún no existen en disco ---
  OK    exit=0  docs/inexistente/futuro.md
  OK    exit=0  evidence/WP-777/nuevo/log.txt
  OK    exit=0  tests/scope/test_nuevo.py

--- C. Fuera del alcance por omisión ---
  OK    exit=2  src/pagos/cobros.py
  OK    exit=2  package.json
  OK    exit=2  CLAUDE.md.bak (no es prefijo)
  OK    exit=2  docsX/otro.md (no es docs/)

--- D. Prohibidos explícitos (prohibido gana a permitido) ---
  OK    exit=2  .env.production
  OK    exit=2  docs/secrets/clave.txt
  OK    exit=2  specs/cert.pem

--- E. Evasión por forma de la ruta ---
  OK    exit=2  traversal ../fuera.txt
  OK    exit=2  traversal docs/../../fuera.txt
  OK    exit=2  absoluta fuera del repo
  OK    exit=2  NotebookEdit fuera de alcance

--- F. FAIL-CLOSED ---
  OK    exit=2  sin archivo ACTIVE
  OK    exit=2  ACTIVE vacío
  OK    exit=2  ACTIVE apunta a WP inexistente
  OK    exit=2  WP sin rutas permitidas

--- G. BASH: escrituras vía shell ---
  OK    exit=2  echo > src/y.py (redirección)
  OK    exit=2  echo >> package.json (append)
  OK    exit=2  tee src/z.py
  OK    exit=2  sed -i sobre src/
  OK    exit=2  cp hacia src/
  OK    exit=2  mv hacia src/
  OK    exit=2  rm -rf src/
  OK    exit=2  dd of=src/big.bin
  OK    exit=2  redirección con ruta entrecomillada
  OK    exit=2  truncate sobre src/
  OK    exit=2  ln -s hacia src/

--- H. BASH: lo que NO debe bloquearse (falsos positivos) ---
  OK    exit=0  echo > docs/ok.md (en alcance)
  OK    exit=0  echo >> evidence/WP-000/log.txt
  OK    exit=0  redirección a /dev/null
  OK    exit=0  escritura en /tmp
  OK    exit=0  commit con > dentro de comillas
  OK    exit=0  pytest (sin escrituras)
  OK    exit=0  grep con > en el patrón

--- I. AUTOPROTECCIÓN (fixture WP-900: solo docs/manual/**) ---
    Si el implementer pudiera escribir aquí, podría ampliarse el alcance
    a sí mismo y todo el enforcement colapsaría.
  OK    exit=0  docs/manual/x.md (en alcance)
  OK    exit=2  work-packages/ACTIVE
  OK    exit=2  work-packages/WP-900-realista.md
  OK    exit=2  work-packages/WP-001-otro.md
  OK    exit=2  .claude/settings.json
  OK    exit=2  .claude/hooks/guard.sh
  OK    exit=2  .claude/agents/implementer.md
  OK    exit=2  CODEOWNERS
  OK    exit=2  CLAUDE.md
  OK    exit=2  .github/workflows/ci.yml
  OK    exit=2  Bash: echo > ACTIVE
  OK    exit=2  Bash: cp sobre CLAUDE.md
  OK    exit=2  Bash: mv sobre settings.json
  OK    exit=2  Bash: sed -i sobre el WP activo

--- J. HUECOS CONOCIDOS (expected-fail, no se corrigen en el Paso 0) ---
    El guard es preventivo y best-effort. La defensa concluyente es la
    verificación post-hoc del diff (check_scope, WP-002), sobre la que no
    hay bypass posible sea cual sea la herramienta empleada.
  xfail exit=0 (se desea 2)  symlink en alcance que apunta fuera  [WP-002]
  xfail exit=0 (se desea 2)  python -c con open(...,'w')  [WP-002]
  xfail exit=0 (se desea 2)  subshell con redirección entrecomillada  [WP-002]
  xfail exit=0 (se desea 2)  git apply de parche fuera de alcance  [WP-002]
  xfail exit=0 (se desea 2)  tar extrayendo sobre ruta fuera de alcance  [WP-002]
  OK    exit=2  APFS: CLAUDE.md prohibido se bloquea
  xfail exit=0 (se desea 2)  APFS: 'claude.md' elude el prohibido  [WP-002 (macOS case-insensitive)]
  xfail exit=0 (se desea 2)  git push -f (control en settings.json, no en guard)  [capa de permisos, no guard.sh]
  xfail exit=0 (se desea 2)  git push --force (idem)  [capa de permisos, no guard.sh]

==============================================================
 RESULTADO: 58 correctas · 0 fallidas · 8 huecos conocidos · 0 huecos cerrados
==============================================================
=== EXIT: 0 ===
```
