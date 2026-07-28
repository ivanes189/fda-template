# WP-006 — Estado de reposo válido y validación de gobierno verificable

estado: ready
prioridad: P0
agente_responsable: implementer     agente_revisor: code-reviewer
requisitos: [REQ-FDA-001]           adr: []
presupuesto_max_eur: 25             max_ciclos_correccion: 2

## Objetivo y contexto

La validación de gobierno vive en un script versionado y probado, no en un bloque de YAML incrustado en el workflow, y reconoce **tres** estados de `work-packages/ACTIVE`:

| Estado de `ACTIVE` | Significado | CI |
|---|---|---|
| Vacío | Fábrica en reposo. Ninguna escritura ordinaria autorizada (fail-closed) | **verde** |
| WP existente y bien formado | Trabajo en curso, guard limitado a ese alcance | **verde** |
| WP inexistente o mal formado | Estado incoherente | **rojo**, con mensaje explícito |

**Contexto — el defecto.** El paso `El WP activo existe` de `ci.yml` trata `ACTIVE` vacío como error y devuelve exit 1. Como `Gobierno FDA` es check obligatorio del ruleset, vaciar `ACTIVE` —que es el estado seguro entre dos WPs— bloquearía **toda** fusión, incluida la de la PR que lo arreglase.

La causa raíz no es vaciar `ACTIVE`: es que la comprobación se escribió asumiendo que siempre hay un WP en curso. Entre dos WPs no lo hay, y ese es precisamente el estado deseable.

**Contexto — por qué a un script.** Los workflows están vedados a los agentes (`Edit(./.github/workflows/**)`), y con razón: un workflow ejecuta código arbitrario con los secretos del repositorio. Mientras la lógica de gobierno viva incrustada en el YAML, cada ajuste exigirá intervención humana. Moviéndola a `tests/governance/`, el workflow queda como una línea estable que invoca el script, y la lógica pasa a ser versionable, ejecutable en local con el mismo comando que en CI, y cubierta por pruebas.

## Alcance (incluido / fuera de alcance)

**Incluido:**
- `tests/governance/check-active.sh` — validación de los tres estados, con códigos de salida y mensajes distinguibles.
- `tests/governance/test-check-active.sh` — pruebas de los tres casos y de los mensajes.
- `ci.yml`: el paso inline se sustituye por la llamada al script.
- `guard.sh`: los destinos exentos (`/dev/null`, `/tmp`…) se filtran **antes** del chequeo fail-closed.
- Casos nuevos en `tests/guard/run-suite.sh` para el defecto anterior.
- Manual: documentar el estado de reposo y el protocolo de reparación bloqueada.

**Fuera de alcance:**
- Los demás huecos conocidos del guard (`xfail` del grupo J): los cierra WP-002.
- Cualquier otro job o workflow (`claude.yml`, `code-review.yml`).
- Cambiar el ruleset o los checks obligatorios.
- Refactorizar `guard.sh` más allá del reordenamiento de la exención.

## Archivos permitidos

- tests/**
- .github/workflows/ci.yml
- .claude/hooks/guard.sh
- docs/manual/**
- evidence/WP-006/**

## Archivos prohibidos

- work-packages/ACTIVE
- work-packages/**
- .claude/settings.json
- CLAUDE.md
- CODEOWNERS

<!-- ACTIVE y el resto de work-packages/ quedan explícitamente PROHIBIDOS aunque
     este WP trate sobre la semántica de ACTIVE: un WP que puede reescribir el
     archivo que define su propio alcance puede ampliarse a voluntad, y todo el
     enforcement colapsa. Las transiciones de ACTIVE son actos del operador
     humano, no del agente. -->

## Contratos técnicos (interfaces, schemas, eventos, invariantes)

**Interfaz de `tests/governance/check-active.sh`:**

```bash
bash tests/governance/check-active.sh [ruta_repo]
```

| Código de salida | Significado | Marca en la salida |
|---|---|---|
| `0` | Reposo (ACTIVE vacío) **o** WP válido | `REPOSO` / `ACTIVO` |
| `1` | ACTIVE apunta a un WP inexistente o mal formado | `ERROR` |
| `2` | No existe el archivo `ACTIVE` | `ERROR` |

Los tres casos deben ser distinguibles **por texto** además de por código, para que un humano leyendo el log de CI sepa cuál se dio sin abrir el repositorio.

**Invariante que no cambia:** el reposo sigue siendo **fail-closed para escrituras reales**. Que el CI acepte `ACTIVE` vacío no relaja el guard: con `ACTIVE` vacío, `guard.sh` sigue denegando toda escritura ordinaria. Son dos controles con propósitos distintos — el CI valida coherencia del estado; el guard autoriza escrituras.

**Cambio en `guard.sh`:** los destinos exentos se filtran antes de resolver el WP activo. Un comando cuyos únicos objetivos sean exentos (`echo x 2>/dev/null`) devuelve `0` sin consultar `ACTIVE`.

## Entorno autorizado (herramientas, comandos, red, secretos)

- Herramientas: Read, Grep, Glob, Edit, Write, Bash
- Comandos: `bash`, `python3`, `git` (local), `actionlint`, `shellcheck`, `grep`, `find`
- Red: NINGUNA
- Secretos: NINGUNO

## Verificación (comandos de validación + criterios de aceptación medibles)

**Comandos** (headless, código de salida significativo):

```bash
bash tests/governance/test-check-active.sh
bash tests/guard/run-suite.sh
bash evidence/WP-000/checks/check-structure.sh
python3 evidence/WP-000/checks/check-agents-skills.py
python3 .claude/skills/run-verification/validate-workflows.py .github/workflows
python3 evidence/WP-000/checks/check-manual.py
actionlint
shellcheck --severity=warning --shell=bash $(find .claude/hooks tests evidence/WP-000/checks -name '*.sh')
```

**Criterios de aceptación:**

- [ ] `check-active.sh` con `ACTIVE` **vacío** → exit `0` y la salida contiene `REPOSO`
- [ ] `check-active.sh` con **WP válido** → exit `0` y la salida contiene `ACTIVO` y el WP-ID
- [ ] `check-active.sh` con **WP inexistente** → exit `1` y la salida contiene `ERROR`
- [ ] `check-active.sh` **sin archivo** `ACTIVE` → exit `2` y la salida contiene `ERROR`
- [ ] Los cuatro mensajes son distinguibles entre sí por texto
- [ ] Con `ACTIVE` vacío, `guard.sh` sigue **denegando** una escritura ordinaria (fail-closed intacto)
- [ ] Con `ACTIVE` vacío, `guard.sh` **permite** un comando cuyos únicos destinos son exentos (`2>/dev/null`)
- [ ] `ci.yml` invoca el script en lugar de la lógica inline
- [ ] Las 8 comprobaciones de arriba en verde
- [ ] `git diff --name-only main...HEAD` ⊂ archivos permitidos

## Evidencias exigidas (qué debe aparecer en evidence/WP-006/)

- [ ] Salida de `test-check-active.sh` con su código de salida
- [ ] Salida de `tests/guard/run-suite.sh`
- [ ] Demostración de los 4 estados de `ACTIVE` con sus códigos y mensajes
- [ ] Demostración de que el reposo sigue siendo fail-closed
- [ ] `git diff --name-only main...HEAD`
- [ ] `cost.md` con el formato de DEC-001

## Condiciones de parada específicas

- Si arreglar el orden de la exención en `guard.sh` exigiera reestructurar el analizador de comandos: parar. Este WP es una reparación acotada, no un refactor; el resto de huecos son de WP-002.
- Si el cambio en `ci.yml` requiriera tocar otro workflow: parar.
- Si al mover la lógica a script apareciese una divergencia de comportamiento con la versión inline: parar y reportar, no ajustar la prueba para que pase.

## Migración / rollback

Sin datos ni consumidores externos. Rollback = revertir los commits o cerrar la PR sin fusionar; `ci.yml` vuelve a su lógica inline y `guard.sh` a su orden anterior.

**Orden de aplicación importante:** el script y sus pruebas se añaden **antes** de que `ci.yml` empiece a invocarlo. Cambiar el workflow primero dejaría el CI llamando a un archivo inexistente.
