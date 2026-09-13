# WP-014 — Verificación (preparación, previa a la aplicación humana)

Este documento cubre lo que Claude Code puede verificar **antes** del acto
protegido de Iván (`git apply --check --index -` y `git apply --index -`,
ambas fuera de alcance de este agente). Los comandos de la sección
«Verificación» del contrato que comparan `WP014_BASE` con `WP014_HEAD` y
esperan las diez postimágenes **no pueden pasar todavía**, porque hasta que
Iván aplique el parche `HEAD` es idéntico a `BASE_SHA` en los tres workflows.
Eso es el estado correcto y esperado en esta fase, no un fallo.

## 1. Cardinalidad actual (preimagen, sin aplicar)

```
$ grep -rn 'uses:' .github/workflows/ | grep -v '@[0-9a-f]\{40\}' | grep -v 'uses: \./'
.github/workflows/ci.yml:29:      - uses: actions/checkout@v4
.github/workflows/ci.yml:33:      - uses: actions/setup-python@v5
.github/workflows/ci.yml:109:      - uses: actions/checkout@v4
.github/workflows/ci.yml:111:      - uses: actions/setup-python@v5
.github/workflows/ci.yml:158:      - uses: actions/checkout@v4
.github/workflows/ci.yml:163:        uses: gitleaks/gitleaks-action@v2
.github/workflows/claude.yml:40:      - uses: actions/checkout@v4
.github/workflows/claude.yml:44:      - uses: anthropics/claude-code-action@v1
.github/workflows/code-review.yml:25:      - uses: actions/checkout@v4
.github/workflows/code-review.yml:29:      - uses: anthropics/claude-code-action@v1
```

Exactamente diez líneas, en las posiciones y con la distribución (5 checkout,
2 setup-python, 1 gitleaks, 2 claude-code-action) que exige la matriz cerrada
del contrato. Ninguna línea `uses:` adicional de terceros existe en los tres
workflows. Este es el criterio 2 de `REQ-FDA-002`, **hoy en incumplimiento
esperado**: quedará en vacío únicamente después de que Iván aplique el
parche.

## 2. actionlint

```
$ actionlint -color .github/workflows/*.yml
```

Salida: vacía. Código de salida: `0`. Sin errores sobre los tres workflows en
su estado actual (preimagen).

## 3. Validador de workflows de la FDA

```
$ python3 .claude/skills/run-verification/validate-workflows.py .github/workflows
Workflows analizados: 3
  - .github/workflows/ci.yml
  - .github/workflows/claude.yml
  - .github/workflows/code-review.yml

RESULTADO: 0 errores, 0 avisos
```

Código de salida: `0`.

## 4. Estado operativo (`ACTIVE`)

```
$ bash tests/governance/check-active.sh
ACTIVO: WP-014

  Contrato:  work-packages/WP-014-diez-pins-acciones-sha.md
  Alcance:   6 ruta(s) permitida(s)
    - .github/workflows/ci.yml
    - .github/workflows/claude.yml
    - .github/workflows/code-review.yml
    - specs/requirements/REQ-FDA-002-workflows-endurecidos.md
    - docs/manual/01-instalacion.md
    - evidence/WP-014/**
```

Código de salida: `0`. Primera línea: `ACTIVO: WP-014`, tal como exige el
comando de verificación del contrato.

## 5. Manual sin enlaces rotos

```
$ python3 evidence/WP-000/checks/check-manual.py
...
RESULTADO: 0 fallos
```

Código de salida: `0`. Incluye la comprobación de los enlaces y placeholders
de `docs/manual/01-instalacion.md`, que en este WP incorpora la nota sobre
acciones fijadas por SHA.

## 6. Parche protegido: cardinalidad y alcance

El parche `evidence/WP-014/parche/workflows-actions-sha.patch` contiene
exactamente tres secciones `diff --git`, una por workflow objetivo, y diez
líneas retiradas y diez añadidas (una pareja `-`/`+` por cada una de las diez
sustituciones). No toca ninguna otra ruta. Verificado por lectura directa del
propio parche (adjunto en este mismo commit) — no se ejecuta `git apply` en
ninguna variante para esta comprobación.

Recuento manual de hunks y líneas modificadas:

| Workflow | Hunks | Líneas `-` | Líneas `+` |
|---|---:|---:|---:|
| `ci.yml` | 3 | 6 | 6 |
| `claude.yml` | 1 | 2 | 2 |
| `code-review.yml` | 1 | 2 | 2 |
| **Total** | **5** | **10** | **10** |

Nota: en `ci.yml` la primera y segunda sustitución (checkout + setup-python
del job `gobierno`, y checkout + setup-python del job `calidad`) comparten
hunk con la línea de contexto intermedia por estar a menos de tres líneas de
distancia (comportamiento estándar de un diff de contexto 3, igual que
produciría `git diff` con las mismas preimágenes/postimágenes); por eso hay 3
hunks en `ci.yml` y no 4, aunque las sustituciones dentro de `ci.yml` son
cuatro (2 checkout + 2 setup-python) más la del job `secretos` (checkout +
gitleaks) en el tercer hunk. Total de sustituciones en `ci.yml`: 3 checkout +
2 setup-python + 1 gitleaks = 6; en `claude.yml`: 1 checkout + 1
claude-code-action = 2; en `code-review.yml`: 1 checkout + 1
claude-code-action = 2. Suma: **10**, coincide con la matriz cerrada.

## 7. Diff limitado a las rutas permitidas del WP

Cambios de este WP hasta este commit, sobre archivos versionados
directamente (sin contar el parche, que vive bajo `evidence/`):

- `specs/requirements/REQ-FDA-002-workflows-endurecidos.md` (permitido)
- `docs/manual/01-instalacion.md` (permitido)
- `evidence/WP-014/**` (permitido)

Ningún archivo de `.github/workflows/**` fue tocado directamente por Claude
Code: la edición directa de esas rutas está denegada por
`.claude/settings.json` (`Edit(./.github/workflows/**)`) y, además, el
entorno de ejecución de Bash de este agente solo permite los comandos
explícitamente listados en `permissions.allow` — no incluye `cp`, `mkdir`
salvo para crear directorios de evidencia, `sed -i`, `python3 -c` arbitrario
ni ninguna variante de `git apply`. Esto se confirmó empíricamente durante la
preparación: los intentos de usar `cp`/command substitution genérico fueron
denegados por el propio entorno antes de llegar a `guard.sh`.

## 8. Higiene local (sin red)

No se leyó, imprimió ni versionó ningún secreto. No se tocó ningún archivo
bajo `.env`, `*.pem` ni `secrets/`. No hubo acceso de red durante esta
preparación (ningún comando ejecutado lo requirió).

## 9. Comandos NO ejecutados (reservados a Iván)

Explícitamente no ejecutados por este agente, conforme al punto de parada del
contrato:

- `git apply --check --index -` (sobre el blob `PATCH_BLOB`)
- `git apply --index -` (sobre el mismo blob)
- Cualquier `git rev-parse`, `git cat-file` o `git merge-base` que formen
  parte de la secuencia protegida de Iván (no están en la lista de comandos
  permitidos a este agente y no se intentaron).

## 10. Estado tras la aplicación humana

La transición prevista en la evidencia previa quedó resuelta así:

- el bloque completo de la sección «Verificación» del contrato se ejecutó con
  código `0`; su resultado está en §11;
- `PRE_APPLY_HEAD` y la confirmación saneada del acto humano están registrados
  en `evidence/WP-014/aplicacion-humana.md`;
- la revisión Astra completa de contrato, código y seguridad sigue pendiente;
- la referencia al job remoto `secretos / Escaneo de secretos` seguirá
  pendiente hasta que el operador cree la PR de implementación.

## 11. Verificación contractual completa tras la aplicación humana

La aplicación humana quedó commiteada junto con su confirmación antes de esta
ejecución. Se ejecutó sin alterar ni reordenar el bloque completo de la sección
«Verificación» del contrato de WP-014.

```text
fecha_utc: 2026-09-13T20:33:59Z
WP014_BASE: 1feb66554c8754e586a1089822e1ab5a6edae900
WP014_HEAD: 3a0fbf6d7ffba29dce7caa7c938ee871e702d53e
estado_inicial: limpio y commiteado
```

Resultados de las comprobaciones sin salida, todas con código `0` salvo el
`git grep` de higiene, cuyo código esperado y aceptado fue `1` —ninguna
coincidencia—:

- base y HEAD no vacíos, relación de ancestro y árbol limpio;
- `git diff --check`;
- `actionlint`;
- primera línea de `check-active.sh` igual a `ACTIVO: WP-014`;
- identificador único de `ACTIVE` igual a `WP-014`;
- ausencia de `uses:` móviles de terceros;
- ausencia de rutas sensibles en el diff;
- escaneo local de patrones de secreto sin coincidencias;
- diff final limitado a los seis patrones permitidos.

Salida completa de los comandos que emitieron texto:

```text
Workflows analizados: 3
  - .github/workflows/ci.yml
  - .github/workflows/claude.yml
  - .github/workflows/code-review.yml

RESULTADO: 0 errores, 0 avisos
==============================================================
 Manual — enlaces internos y placeholders de instalación
==============================================================

--- Enlaces internos (9 archivos) ---
  OK    docs/manual/01-instalacion.md
  OK    docs/manual/02-ciclo-de-un-wp.md
  OK    docs/manual/03-redactar-un-wp.md
  OK    docs/manual/04-agentes.md
  OK    docs/manual/05-bloqueos-y-parada.md
  OK    docs/manual/06-costes-y-metricas.md
  OK    docs/manual/07-troubleshooting.md
  OK    docs/manual/MANUAL.md
  OK    CLAUDE.md

  Enlaces internos comprobados: 60

--- Placeholders en docs/manual/01-instalacion.md ---
  OK    {{COMANDOS_VALIDACION}}
  OK    {{PROPIEDAD_COMPONENTES}}
  OK    {{PRESUPUESTOS_Y_MODELOS}}

--- Estado de los archivos parametrizables (informativo) ---
  instanciado CODEOWNERS                        sin marcador (valor real aplicado)
  plantilla  .github/workflows/ci.yml           conserva {{COMANDOS_VALIDACION}}
  plantilla  .github/workflows/claude.yml       conserva {{PRESUPUESTOS_Y_MODELOS}}
  plantilla  .github/workflows/code-review.yml  conserva {{PRESUPUESTOS_Y_MODELOS}}

  3 sin instanciar · 1 instanciados
  Nota: instalación parcial. Es lo esperado mientras el repo sirva
        de plantilla y de sandbox a la vez.

==============================================================
 RESULTADO: 0 fallos
==============================================================
postimages_ok counts=[5, 2, 1, 2]
WP014_BASE=1feb66554c8754e586a1089822e1ab5a6edae900
WP014_HEAD=3a0fbf6d7ffba29dce7caa7c938ee871e702d53e
VERIFICATION_EXIT=0
```

**Veredicto local de esta ejecución:** `APTO`. Comandos fallidos: `0`.
La revisión independiente de Astra y el job remoto de secretos continúan
pendientes y no se sustituyen por este resultado local.
