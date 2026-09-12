# WP-009 — Acciones de GitHub fijadas por SHA

estado: ready
prioridad: P0
agente_responsable: implementer     agente_revisor: code-reviewer
requisitos: [REQ-FDA-002, SEC-001]  adr: [ADR-001]
presupuesto_max_eur: 30             max_ciclos_correccion: 2

## Objetivo y contexto

Los diez usos de acciones de terceros en los tres workflows quedan fijados a
commits completos de 40 caracteres, con su versión legible en comentario
adyacente, sin cambiar triggers, permisos, inputs ni comportamiento. El criterio
2 de REQ-FDA-002 devuelve vacío y su verificación actual y trazabilidad reflejan
que WP-009 lo cumple.

WP-009 es T3 porque modifica controles sensibles. El agente prepara y verifica
el parche; una persona lo aplica sobre las rutas protegidas.
El manual registra el pinning aplicado y cómo verificarlo al mantener acciones.

## Alcance (incluido / fuera de alcance)

**Incluido:**
- sustituir 10 referencias mutables por los cuatro SHA cerrados de este contrato;
- conservar las versiones mayores actuales y añadir el comentario legible;
- preparar parche humano con preimagen, postimagen, rollback y huellas;
- actualizar solo el estado actual y la trazabilidad de REQ-FDA-002;
- actualizar de forma limitada el manual sobre pinning y mantenimiento;
- añadir la línea mensual 2026-09 al registro append-only de tipos con el dato
  oficial del BCE del primer día hábil, para poder cerrar el coste del WP;
- producir evidencia, coste, revisión de código y revisión de seguridad.

**Fuera de alcance:**
- actualizar acciones a otra versión mayor o cambiar sus inputs;
- cambiar eventos, permisos, jobs, steps, expresiones, secretos o rulesets;
- activar workflows deshabilitados o modificar su estado en GitHub;
- cambiar código de producto, guard, `ACTIVE`, contratos o decisiones;
- corregir otros puntos de REQ-FDA-002.

## Archivos permitidos

- .github/workflows/ci.yml
- .github/workflows/claude.yml
- .github/workflows/code-review.yml
- specs/requirements/REQ-FDA-002-workflows-endurecidos.md
- docs/manual/02-ciclo-de-un-wp.md
- specs/finops/fx-rates.md
- evidence/WP-009/**

## Archivos prohibidos

- tests/guard/run-suite.sh
- work-packages/**
- .claude/**
- CODEOWNERS
- specs/decisions/**

## Contratos técnicos (interfaces, schemas, eventos, invariantes)

| Acción | Apariciones | Tag exacto | SHA fijado | Comentario |
|---|---:|---|---|---|
| `actions/checkout` | 5 | `v4.4.0` | `11d5960a326750d5838078e36cf38b85af677262` | `v4.4.0` |
| `actions/setup-python` | 2 | `v5.6.0` | `a26af69be951a213d495a4c3e4e4022e16d87065` | `v5.6.0` |
| `anthropics/claude-code-action` | 2 | `v1.0.219` | `5ccc3a35a6367cdb8e6fbd0728287467540ecfe2` | `v1.0.219` |
| `gitleaks/gitleaks-action` | 1 | `v2.3.9` | `ff98106e4c7b2bc287b24eaf42907196329070c7` | `v2.3.9` |

Se conservan los cuatro SHA y comentarios aprobados. Para cada acción, la mayor
se determina por el componente numérico del tag exacto (`v4`, `v5`, `v1`, `v2`)
y debe coincidir con la referencia mayor que usa el workflow antes del cambio.
El control no resuelve la punta viva de esos tags mayores ni selecciona una
versión automáticamente: son punteros móviles y no forman parte del criterio de
aceptación.

El aplicador humano `evidence/WP-009/parche/APLICAR-ACCIONES-SHA.sh` aborta antes
de escribir si falla el respaldo, las tres preimágenes no coinciden o cualquiera
de los cuatro tags exactos no resuelve, tras desreferenciar tags anotados, al SHA
aprobado y a un objeto Git de tipo `commit`. Respuestas ausentes, duplicadas,
inesperadas o ambiguas, fallos de red y objetos de otro tipo fallan de forma
cerrada. La adquisición usa configuración Git aislada, sin credenciales, y no
ejecuta ni hace checkout del código obtenido.
Tras aplicar, acredita postimágenes, alcance exacto y rollback por huellas.
Las pruebas del aplicador operan solo sobre copias desechables.
Los workflows siguen válidos aunque `claude.yml` y `code-review.yml`
permanezcan deshabilitados manualmente.

El único cambio permitido en `specs/finops/fx-rates.md` es añadir al final de la
tabla, preservando byte a byte las entradas anteriores, la línea mensual
`2026-09` con `1.1590`, fecha BCE `2026-09-01`, fuente oficial BCE y fecha de
adición real. Si ya existe una línea para ese mes o la fuente no concuerda, se
detiene sin escribir.

## Entorno autorizado (herramientas, comandos, red, secretos)

- Herramientas: Read, Grep, Glob, Write/Edit solo en evidencia, requisito,
  manual y registro mensual de tipos; Bash.
- Comandos: `git` local, `bash`, `grep`, `sed`, `diff`, `shasum`,
  `actionlint`, `shellcheck`, `python3`.
- Red del agente: solo lectura de los cuatro tags exactos y de los objetos Git
  necesarios para comprobar su tipo en los cuatro repositorios oficiales;
  consulta de la referencia EUR/USD del 2026-09-01 en la fuente oficial del BCE.
- Red del operador: push/PR normales y ejecución de CI.
- Secretos: ninguno; no leer credenciales ni valores de secretos.

## Verificación (comandos + criterios medibles)

**Comandos headless:**

```bash
git diff --check
git apply --check --reverse evidence/WP-009/parche/acciones-sha.patch
bash evidence/WP-009/checks/test-aplicador.sh
python3 evidence/WP-009/checks/test-verify-workflow-diff.py
test "$(grep -Rh 'uses:' .github/workflows/*.yml | wc -l | tr -d ' ')" = 10
! grep -rn 'uses:' .github/workflows/ | grep -v '@[0-9a-f]\{40\}' | grep -v 'uses: \./'
test "$(grep -Rh 'actions/checkout@11d5960a326750d5838078e36cf38b85af677262.*v4.4.0' .github/workflows/*.yml | wc -l | tr -d ' ')" = 5
test "$(grep -Rh 'actions/setup-python@a26af69be951a213d495a4c3e4e4022e16d87065.*v5.6.0' .github/workflows/*.yml | wc -l | tr -d ' ')" = 2
test "$(grep -Rh 'anthropics/claude-code-action@5ccc3a35a6367cdb8e6fbd0728287467540ecfe2.*v1.0.219' .github/workflows/*.yml | wc -l | tr -d ' ')" = 2
test "$(grep -Rh 'gitleaks/gitleaks-action@ff98106e4c7b2bc287b24eaf42907196329070c7.*v2.3.9' .github/workflows/*.yml | wc -l | tr -d ' ')" = 1
actionlint
python3 .claude/skills/run-verification/validate-workflows.py .github/workflows
bash tests/governance/check-active.sh
BASE_SHA="$(git merge-base origin/main HEAD)"
python3 evidence/WP-009/checks/verify-workflow-diff.py --base "$BASE_SHA" \
  .github/workflows/ci.yml .github/workflows/claude.yml \
  .github/workflows/code-review.yml
```

**Criterios de aceptación:**
- [ ] Cada comando, incluidas todas sus iteraciones, termina en 0; la comprobación
      de referencias no fijadas no imprime líneas.
- [ ] Existen exactamente 10 usos y el reparto es 5 + 2 + 2 + 1.
- [ ] Cada uso contiene SHA completo y comentario de versión exactos.
- [ ] En los workflows solo cambian las 10 líneas `uses:`; triggers, permisos,
      jobs, steps, inputs, expresiones y secretos son byte a byte iguales.
- [ ] El diff completo está contenido en las siete rutas permitidas.
- [ ] REQ-FDA-002 atribuye este punto a WP-009 sin alterar su norma.
- [ ] El manual explica los SHA completos, comentarios de versión y comprobación
      previa de procedencia sin ampliar el resto del proceso.
- [ ] `specs/finops/fx-rates.md` añade solo la línea `2026-09` con tasa `1.1590`
      y fecha BCE `2026-09-01`; todas las líneas previas permanecen idénticas.
- [ ] `check-active.sh` devuelve salida 0 y primera línea `ACTIVO: WP-009`.
- [ ] Revisión `code-reviewer` sin incumplimientos bloqueantes abiertos.
- [ ] Revisión de seguridad sin hallazgos ALTOS o CRÍTICOS abiertos.
- [ ] Coste conforme a DEC-004 y ≤ 30 EUR.

## Evidencias exigidas

- [ ] Inventario antes/después con rutas, líneas, acción, tag, SHA y comentario.
- [ ] Fuentes oficiales y fecha UTC que acreditan los cuatro tags exactos, sus
      SHA, el tipo de objeto `commit` y la correspondencia semántica de mayor.
- [ ] Fuente oficial del BCE y huella antes/después de la adición append-only de
      la tasa mensual 2026-09.
- [ ] Aplicador y parche humanos; huellas, respaldo, postimágenes y rollback.
- [ ] Pruebas del aplicador: éxito, preimagen incorrecta, procedencia inválida,
      fallo de respaldo y rollback; cada una comprueba salida, código y huellas.
      La matriz de procedencia cubre tag ligero y anotado válidos, tag ausente o
      movido, respuestas duplicadas o inesperadas, fallo de red y objeto no
      `commit`, sin escribir los destinos en ningún fallo.
- [ ] Pruebas del verificador de alcance: éxito, cambio ajeno a `uses:` y fallo de
      lectura o normalización; cualquier error termina distinto de cero.
- [ ] Salida íntegra y código de cada comando y de todas sus iteraciones.
- [ ] Diff de workflows y diff completo contra la base de la PR.
- [ ] `cost.md` conforme a DEC-004; revisiones de código y seguridad referenciadas.

## Condiciones de parada específicas

- Un tag exacto no resuelve al SHA aprobado, no identifica un objeto `commit`,
  su mayor semántica discrepa, falta `actionlint` o una prueba no corre.
- El parche exige un cambio distinto de referencia/comentario o toca otra ruta.
- Aparece una vulnerabilidad o incompatibilidad en uno de los commits fijados.
- El coste supera 30 EUR o se alcanza un tercer ciclo de corrección.

## Migración / rollback

Sin datos. Ante fallo previo al commit, el operador restaura las tres preimágenes
y verifica sus SHA. Tras commit, rollback = revertir la PR completa. Los
workflows deshabilitados no se reactivan.
