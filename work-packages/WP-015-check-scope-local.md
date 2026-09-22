# WP-015 — Verificador local de alcance y biblioteca única

estado: ready
prioridad: P0
riesgo: T3
agente_responsable: Claude Code (implementer)
agente_revisor: GPT-6 Astra (Alto, contexto nuevo, solo lectura)
requisitos: [REQ-FDA-001]
adr: [ADR-001]
decision: [DEC-002, DEC-003, DEC-007, DEC-010, DEC-011, DEC-012]
presupuesto_max_eur: 40
max_ciclos_correccion: 2

<!-- Candidata nueva y replanteada tras DEC-012. No es C3 ni continuación de
la candidata externa agotada. Su materialización, aprobación, admisión y
activación requieren actos humanos posteriores y separados. -->

## Objetivo y contexto

Existen `scripts/check_scope.py` y `scripts/scope_rules.py`. Dados un WP-ID y
un rango Git canónico `<base>...<head>`, el ejecutable lee el contrato
exclusivamente del `merge-base`, evalúa todo el diff con la gramática de
DEC-012 y la semántica de DEC-002, enumera todas las violaciones y termina con
`0`, `1` o `2` de forma determinista. Una suite adversarial headless demuestra
el contrato sin leer rutas de confianza desde el working tree.

Contexto: DEC-011 sitúa primero el juez local del resultado. Este WP es el
sucesor mínimo y limpio de WP-002; no reabre aquel contrato ni reutiliza sus
candidatas. Su cierre solo acredita un ejecutable local. No acredita CI,
ruleset, bloqueo de fusión, convergencia del guard, runtime, sandbox ni cierre
de la pausa.

## Alcance incluido y fuera de alcance

**Incluido:**

- biblioteca única de parseo, matching, traversal y resolución textual de
  destinos de symlink;
- CLI local que obtiene contrato y diff mediante objetos Git;
- pruebas unitarias e integrales sobre repositorios temporales desechables;
- documentación de la invocación local, límites y tres estados de entrega;
- evidencias, coste y registro durable de ciclos.

**Fuera de alcance:**

- CI, workflows, ruleset, checks requeridos y política de ramas `ops/*`;
- modificar o hacer converger `guard.sh`, ejecutar o cerrar WP-007;
- clasificador T1/T2/T3, sandbox E2, runtime, humo y producto;
- contratos, `ACTIVE`, requisitos, ADR, decisiones o candidatas históricas;
- dependencias nuevas, red, secretos y lectura del sistema de archivos para
  resolver contratos, diffs o symlinks versionados.

## Archivos permitidos

- scripts/check_scope.py
- scripts/scope_rules.py
- tests/scope/**
- evidence/WP-015/**
- docs/manual/02-ciclo-de-un-wp.md

## Archivos prohibidos

- work-packages/**
- .github/**
- .claude/**
- .codex/**
- .agents/**
- AGENTS.md
- specs/**
- tests/guard/**
- tests/governance/**
- evidence/WP-002/**
- evidence/WP-005/**
- evidence/WP-007/**
- evidence/WP-008/**
- evidence/WP-009/**
- evidence/WP-013/**
- evidence/WP-014/**

## Contratos técnicos

### 1. Interfaz y códigos de salida

```text
python3 scripts/check_scope.py WP-NNN BASE...HEAD
```

- `0`: una única línea `OK` seguida de JSON válido y cero violaciones;
- `1`: una línea `VIOLACION` por cada incumplimiento, cada una seguida de JSON;
- `2`: una línea `ERROR` seguida de JSON ante uso, contrato, Git, codificación
  o forma no resoluble.

El JSON se emite en una sola línea, con claves ordenadas y strings escapados;
una ruta con espacios, tabuladores, saltos de línea o no ASCII no puede forjar
otra entrada del log. Las violaciones se ordenan establemente por ruta, rol y
motivo y se informa el inventario completo, no solo la primera.

El WP-ID debe cumplir `WP-[0-9]{3}`. El rango acepta exactamente una forma
`<base>...<head>`, con ambos extremos no vacíos. No se invoca shell. Todo fallo
de subprocess, salida truncada o registro Git desconocido es exit `2`.

### 2. Fuente de confianza y diff

La revisión confiable es exclusivamente `git merge-base <base> <head>`. En
ella se localiza mediante `git ls-tree -r -z` exactamente un contrato
`work-packages/WP-NNN-*.md`, y se lee su blob con Git. Cero contratos, más de
uno, nombre no canónico, blob ausente o UTF-8 inválido son exit `2`.

Queda prohibido abrir desde el working tree el contrato, un destino de symlink
o cualquier ruta juzgada. `HEAD`, `ACTIVE` y `specs/decisions/**` nunca son
fuentes del contrato en tiempo de ejecución.

El diff se obtiene respecto del `merge-base` con salida NUL, detección de
renombrados y copias. Se consumen correctamente una o dos rutas para `A`, `M`,
`D`, `T`, `R` y `C`; estados no fusionados, desconocidos o ambiguos son exit
`2`. En `R` y `C` se juzgan origen y destino. No hay exenciones para
`work-packages/**`, incluido `ACTIVE` o el contrato propio.

### 3. Gramática DEC-012

`scripts/scope_rules.py` expone una API importable para parsear el blob y
evaluar rutas. Es la única implementación de estas reglas; la CLI no duplica
el parser ni el matcher.

En cada sección exacta `## Archivos permitidos` y
`## Archivos prohibidos`, una entrada ejecutable cumple `H* "-" H+ P H*`,
donde `H` es solo espacio ASCII o tabulador. Tras retirar marcador y recorte
exterior, todo `P` es patrón literal completo: no se eliminan comentarios,
paréntesis, `#` o backticks y no existen escapes ni interpretación CommonMark.
Una explicación separada sin marcador se ignora.

Son contrato malformado y exit `2`: sección permitida ausente, duplicada o
vacía; entrada vacía; marcador `*` o `+`; marcador de lista malformado;
sentinela mezclado con patrones; UTF-8 inválido; o cualquier extracción
incompleta. Solo `ninguno`, `none`, `n/a` y `-`, exactos y solos, son lista
vacía. Permitidos vacío es error; prohibidos vacío es válido.

La suite reproduce íntegramente la tabla vinculante de DEC-012 §6. En
particular, `docs/(draft).md` autoriza solo esa ruta; `docs/** # nota` incluye
literalmente `# nota`; los backticks son bytes literales. También cubre el
corpus de transición de DEC-012: permitidos `*`, prohibidos `-`, ruta `-`,
U+000C y whitespace Unicode distinto de U+0020 y U+0009. El contrato vivo de
este WP usa únicamente el subconjunto temporal compatible.

### 4. Matching, traversal y precedencia

- `*` no cruza `/`; `**` sí; `?` representa un carácter distinto de `/`;
- un patrón acabado en `/` cubre todo su contenido;
- el resto de caracteres es literal y la comparación distingue mayúsculas;
- prohibidos gana; fuera de permitidos se deniega;
- traversal existe solo si un componente separado por `/` es exactamente
  `..`; se deniega antes del matching y nunca se resuelve;
- no se consulta el sistema de archivos.

Las ocho filas de DEC-002 §7 son pruebas obligatorias. La API pública separa
parseo, matching y evaluación para que un guard delgado posterior pueda
consumirla sin copiar reglas. Este WP no modifica el guard ni declara ya
convergencia.

### 5. Symlinks por objetos Git

Un symlink se identifica solo por modo Git `120000`; su destino es el blob de
la revisión correspondiente. Para `A` y `M` se inspecciona `head`; para `D`,
`merge-base`; para `R`, `C` y `T`, los extremos aplicables de ambas revisiones.

El destino relativo se resuelve textualmente contra el directorio del enlace.
Destino absoluto, salida de la raíz, codificación inválida, blob ausente o
destino fuera de permitidos o dentro de prohibidos es violación o exit `2`
según sea un veredicto de alcance o imposibilidad de decidir. Nunca se usan
`open`, `readlink`, `realpath`, `stat` ni la existencia en disco.

### 6. Límites, aislamiento e identidad verificable

El control ve solo cambios representados por Git. No detecta escrituras fuera
del repositorio ni cambios que no lleguen al diff, y ningún texto puede afirmar
lo contrario. Las pruebas crean sus repositorios con `mktemp -d`, fijan identidad
Git local y pueden ejecutar `init/config/add/commit/mv/rm` solo dentro de esos
temporales; no usan remotos ni red y limpian únicamente sus propios temporales.
El repositorio FDA se mantiene en solo lectura durante la suite y su estado
antes y después queda idéntico.

La verificación de entrega se ejecuta sobre un commit de implementación
`TESTED_HEAD` que contiene código, pruebas y manual. Antes de probar, esas rutas
deben coincidir exactamente con sus blobs en `TESTED_HEAD`, sin cambios staged,
unstaged ni archivos sin seguimiento. Se registra base, `TESTED_HEAD`, árbol,
merge-base y un manifiesto JSON ordenado con ruta, modo, blob Git y SHA-256 del
contenido de cada archivo probado. Un cambio posterior en código, pruebas o
manual invalida la evidencia y obliga a repetir las comprobaciones afectadas.
Commits posteriores solo de evidencia se identifican aparte y deben demostrar
diff cero entre `TESTED_HEAD` y el head presentado para las rutas probadas.

## Entorno autorizado

- Herramientas: Read, Grep, Glob, Edit, Write, Bash
- Comandos sobre FDA: `python3`, `bash`, `git` local de solo lectura,
  `shellcheck`, `shasum`, `find`, `sort`, `mktemp`
- Git mutable: solo dentro de repositorios temporales propios de
  `tests/scope/**`, sin remotos ni red
- Red: NINGUNA para autor e implementación; la PR usa únicamente el CI ya
  existente, sin modificarlo
- Secretos: NINGUNO
- Dependencias: solo biblioteca estándar de Python y herramientas ya presentes

## Verificación

```bash
git diff --exit-code HEAD -- scripts/check_scope.py scripts/scope_rules.py tests/scope docs/manual/02-ciclo-de-un-wp.md
git diff --cached --exit-code HEAD -- scripts/check_scope.py scripts/scope_rules.py tests/scope docs/manual/02-ciclo-de-un-wp.md
bash -o pipefail -c 'git ls-files --others --exclude-standard -z -- scripts/check_scope.py scripts/scope_rules.py tests/scope docs/manual/02-ciclo-de-un-wp.md | python3 -c "import sys; raise SystemExit(bool(sys.stdin.buffer.read()))"'
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests/scope -p 'test_*.py'
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests/scope -p 'test_security_static.py'
bash tests/scope/run-suite.sh
python3 scripts/check_scope.py WP-015 origin/main...HEAD
shellcheck --severity=warning --shell=bash tests/scope/run-suite.sh
bash tests/governance/test-check-active.sh
bash tests/guard/run-suite.sh
PYTHONDONTWRITEBYTECODE=1 python3 evidence/WP-000/checks/check-manual.py
git diff --check
```

`test_security_static.py` analiza con `ast` ambos módulos de producción y
falla ante shell, evaluación dinámica o APIs de lectura del filesystem
prohibidas por este contrato. El expediente versiona el resultado del job
existente `Escaneo de secretos` sobre `TESTED_HEAD` u otro commit anterior
identificado. El head final de la PR debe obtener ese check verde, comprobado
externamente sin exigir que incorpore dentro de sí su propio SHA o resultado.
No se añade ni modifica CI. No hay dependencias ni lockfiles nuevos: la
evidencia debe demostrar ambos hechos.

**Criterios de aceptación:**

- [ ] La suite cubre las tablas completas de DEC-002 y DEC-012, el corpus de
  transición, precedencia, globs, directorios y mayúsculas.
- [ ] Repositorios temporales cubren `A/M/D/T/R/C`, nombres inusuales, todas
  las violaciones en una ejecución y los tres códigos exactos.
- [ ] Symlinks añadidos, modificados, eliminados, renombrados y con cambio de
  tipo se juzgan desde modos y blobs Git, incluida salida de raíz.
- [ ] Ausencia, duplicidad, manipulación del contrato propio, rango inválido,
  UTF-8 inválido, marcador alternativo y sentinela mezclado fallan cerrados.
- [ ] Modificar o retirar el contrato del working tree no altera el veredicto
  obtenido desde el `merge-base`.
- [ ] La suite deja idénticos `git status --porcelain=v1 -z -uall` y `HEAD` del
  repositorio FDA antes y después.
- [ ] La CLI enumera el inventario completo en JSON de una línea y documenta
  que es local y no bloquea fusiones.
- [ ] `scripts/check_scope.py` importa la semántica de `scope_rules.py`; no hay
  una segunda implementación de gramática o matching.
- [ ] La evidencia identifica los bytes probados y acredita el suelo T3.
- [ ] Todas las verificaciones terminan en verde y el diff queda limitado a
  los cinco patrones de archivos permitidos.

## Evidencias exigidas

- [ ] `evidence/WP-015/verification.md` con comando, salida íntegra, exit,
  `TESTED_HEAD`, árbol, merge-base, manifiesto de blobs/SHA-256 y prueba de
  identidad frente al head presentado.
- [ ] `evidence/WP-015/corpus.md` con correspondencia caso por caso de ambas
  tablas y del corpus de transición.
- [ ] `evidence/WP-015/fuente-confianza.md` con `merge-base`, contrato y blob
  usados, y demostración de manipulación ineficaz del contrato propio.
- [ ] `evidence/WP-015/symlinks.md` con revisión, modo `120000`, blob y veredicto
  de cada estado cubierto.
- [ ] `evidence/WP-015/aislamiento.md` con `HEAD` y huella NUL del estado Git
  antes y después.
- [ ] `evidence/WP-015/seguridad.md` con resultado del análisis AST, último
  `Escaneo de secretos` capturado sobre un commit previo identificado, y
  ausencia de dependencias/lockfiles. El check verde del head final se verifica
  externamente y no se versiona de forma autorreferencial.
- [ ] `evidence/WP-015/revision-astra.md` y revalidaciones enfocadas si existen.
- [ ] `evidence/WP-015/ciclos.md`, versionado antes de cada C1 o C2.
- [ ] `evidence/WP-015/cost.md` conforme a DEC-001 y DEC-004.

## Condiciones de parada específicas

- Cualquier necesidad de tocar una ruta no permitida, en particular contratos,
  guard, suite del guard, CI, ruleset, requisitos o decisiones.
- Cualquier semántica no resuelta por DEC-002, DEC-012 o la plantilla.
- Necesidad de leer working tree o candidatas históricas para decidir.
- Una prueba que dependa de red, plataforma, locale, TTY o filesystem real.
- Divergencia o duplicación entre biblioteca y CLI, falso verde, inventario
  incompleto o imposibilidad de decidir con certeza.
- Hallazgo ALTO o CRÍTICO, exceso de 40 EUR o revalidación NO APTA tras C2.

## Migración y rollback

No hay migración ni consumidor automático. Hasta un sucesor de WP-005, la
ejecución es local y voluntaria y no bloquea fusiones. Rollback posterior a una
fusión: PR nueva que revierta íntegramente el commit, sin reescribir historia.
Antes de publicar, se preserva la rama; nunca se usa force-push, `reset --hard`
ni borrado forzado.
