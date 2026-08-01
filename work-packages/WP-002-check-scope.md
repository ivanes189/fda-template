# WP-002 — `check-scope`: verificación determinista de alcance

estado: blocked
prioridad: P0
agente_responsable: implementer     agente_revisor: code-reviewer
requisitos: [REQ-FDA-001]           adr: [ADR-001]
presupuesto_max_eur: 40             max_ciclos_correccion: 2

<!-- Revisores: qa (pruebas) + code-reviewer (revisión de la PR). -->

## Bloqueo

**`blocked` desde 2026-08-01. No se implementa.** Ninguna rama avanza y no se produce código contra este contrato.

**Causa exacta.** La sección «Semántica de patrones» exigía a la vez dos cosas incompatibles:

1. implementar «la semántica documentada en `_TEMPLATE.md`», cuya prosa decía «toda ruta que contenga `..` se deniega» —lectura de **subcadena**—; y
2. cumplir el **invariante crítico** de coincidir con `.claude/hooks/guard.sh`, que implementa una tercera lectura —`case "$_rel" in *../*|*/..|..)`, §8 `check_target`— que no es ni la de subcadena ni la de componente.

Medido sobre `guard.sh` con este WP activo y rutas de su propia allowlist —de modo que la única causa posible de denegación sea el traversal—, el hook **permite** `evidence/WP-002/notas..md`, `evidence/WP-002/..hidden.md` y `evidence/WP-002/bar..`, lo que contradice la prosa; y **deniega** `evidence/WP-002/foo../bar` con exit `2`, pese a que `foo..` es un nombre de directorio legítimo y ningún componente de esa ruta es `..`.

Quien siguiera la prosa divergía del hook; quien copiara el hook incumplía el contrato escrito, que es lo que el `code-reviewer` comprueba. No es un problema de implementación que se resuelva con más esfuerzo: es un **defecto del contrato**, y por tanto una **Definition of Ready rota**. Se activaron las dos condiciones de parada específicas de este WP —ambigüedad en la semántica de los globs, y divergencia entre `guard.sh` y lo documentado— y la condición general n.º 2 de `CLAUDE.md`, contradicción entre requisitos.

La contradicción está **resuelta** en [`DEC-002`](../specs/decisions/DEC-002-semantica-de-traversal.md): traversal es un **componente**, no una subcadena. Este contrato ya recoge esa semántica en «Semántica de patrones». Lo que sigue pendiente no es la norma, sino la **capa que todavía no la cumple**: `guard.sh`.

**Criterio de desbloqueo.** Este WP puede volver a `ready` cuando se cumplan **todas** estas condiciones, verificables sobre `main` y sin interpretación:

- [ ] La **PR de implementación de WP-007 está fusionada en `main`** por decisión humana (PR-3 de la migración de DEC-002).
- [ ] En `main`, `.claude/hooks/guard.sh` juzga el traversal **por componente** conforme a DEC-002 §1–§3: el `case "$_rel" in *../*|*/..|..)` de §8 ha sido sustituido y ninguna ruta se juzga ya por subcadena.
- [ ] En `main`, `bash tests/guard/run-suite.sh` termina en verde con las **siete** pruebas discriminantes nuevas y los **diez** `xfail` intactos —ni uno más, ni uno menos, ninguno promovido a `run`, ningún XPASS—.
- [ ] Medido sobre `main`, `guard.sh` reproduce las **ocho** filas de la tabla de DEC-002 §7 en su columna «Tras WP-007»; en particular `evidence/WP-002/foo../bar` pasa de exit `2` a exit `0`.
- [ ] Las validaciones de WP-007 están en verde y sus evidencias registradas en `evidence/WP-007/`.
- [ ] `work-packages/_TEMPLATE.md` y la sección «Semántica de patrones» de este contrato describen la semántica por componente, sin resto alguno de la lectura de subcadena.

**Qué NO forma parte del criterio.** No se exige que WP-007 figure ya versionado como `done`: sería circular, porque quien lo marca `done` es la misma PR que desbloquea este WP.

**Cómo se materializa el desbloqueo.** Cumplido lo anterior, una **PR de operador** —PR-4 de la migración de DEC-002— realiza las **tres transiciones de estado en un mismo diff, de forma atómica**:

1. `work-packages/WP-007-semantica-de-traversal.md` → `estado: done`
2. este contrato → `estado: ready`
3. `work-packages/ACTIVE` → `WP-002`

El orden vinculante es, por tanto: **fusión humana de la implementación de WP-007 primero; PR-4 de operador después.** La implementación de este WP arranca **desde el `main` resultante**, con `guard.sh` ya alineado; nunca antes, porque hacerlo abriría exactamente la ventana de divergencia entre las dos capas que el invariante crítico existe para impedir.

**Qué NO cambia con este bloqueo.** La sección «Fuente de confianza del contrato» sigue vigente **palabra por palabra**: rango exclusivamente `<base>...<head>`; revisión base `git merge-base <base> <head>`; contrato localizado y leído **solo** de esa revisión mediante objetos Git; prohibido `open()` sobre el working tree y prohibido resolver contra `HEAD`. DEC-002 cambia la semántica que interpreta el programa, **no** la fuente de confianza del contrato: `check_scope.py` **no leerá `specs/decisions/` en tiempo de ejecución**. El **caso 8** —contrato propio manipulado que añade rutas permitidas y aun así sigue siendo violación— queda **intacto** y sigue siendo la prueba de que la fuente de confianza es el `merge-base`.

## Objetivo y contexto

`scripts/check_scope.py` existe y, dados un WP-ID y un rango git en la forma `<base>...<head>`, devuelve código de salida distinto de cero si el diff toca algún archivo fuera del alcance de ese WP, enumerando todas las violaciones. Acompañado de una suite de pruebas ejecutable en headless.

Contexto: es la pieza que cierra por construcción la clase de fallo **B2** del diagnóstico. El hook `guard.sh` es preventivo y su cobertura sobre `Bash` es best-effort —el shell admite vías no enumerables (`python -c "open(...,'w')"`, `eval`, `git apply`)—. La verificación post-hoc sobre el diff mide el **resultado**, no el método: sobre el diff de una PR no hay bypass posible.

**Qué entrega este WP y qué no.** WP-002 **crea** la verificación post-hoc determinista y la deja **ejecutable en local**: la invocan a mano el operador, el `qa` y el `code-reviewer` antes de aprobar una PR. Hasta WP-005 **no** es un check de GitHub y **no** bloquea por sí solo ninguna fusión; un incumplimiento detectado aquí lo detiene una persona, no la plataforma. **WP-005** integrará el script en `ci.yml` y, una vez marcado como check obligatorio en el ruleset, convertirá una violación en **bloqueo obligatorio de fusión**.

Las dos capas son complementarias, no redundantes: el hook evita el error mientras se trabaja; este script lo detecta de forma determinista sobre el resultado, sin depender de qué herramienta lo produjo.

## Alcance (incluido / fuera de alcance)

**Incluido:**
- `scripts/check_scope.py` con interfaz de línea de comandos: WP-ID y rango `<base>...<head>` como argumentos.
- Resolución del contrato del WP desde la **revisión base** (`merge-base`), leída con Git y nunca desde `HEAD` ni desde el working tree.
- Comprobación de symlinks versionados por inspección de objetos Git (modo `120000`), sin resolver enlaces contra el working tree.
- Parseo de `## Archivos permitidos` y `## Archivos prohibidos` del WP, con la semántica documentada en `_TEMPLATE.md`.
- Suite de pruebas en `tests/scope/` que construye repositorios git temporales como fixtures y cubre los nueve casos mínimos y el comportamiento fail-closed.
- Documentar la verificación local en `docs/manual/02-ciclo-de-un-wp.md` (Paso 4).

**Fuera de alcance:**
- Integrar el script en CI y marcarlo obligatorio en el ruleset (eso es WP-005).
- Modificar `work-packages/WP-005-check-scope-en-ci.md`, aunque este WP registre deuda que le afecta.
- Modificar `guard.sh`, `tests/guard/**` o sus diez `xfail`.
- Modificar `tests/governance/**`.
- Modificar `evidence/WP-006/**`: es registro histórico y no se reescribe.
- Unificar el parseo con el de `guard.sh` en una librería común: deseable, pero es refactor y no entra aquí.
- Cualquier cambio en workflows o en el agente `code-reviewer`.
- Añadir dependencias: no se instala `pytest` ni ningún otro paquete.

## Archivos permitidos

- scripts/**
- tests/scope/**
- evidence/WP-002/**
- docs/manual/02-ciclo-de-un-wp.md

## Archivos prohibidos

- .github/**
- .claude/**
- work-packages/**
- tests/guard/**
- tests/governance/**

<!-- Prohibidos para ESCRITURA, sin excepciones ni exenciones nominales.
     El script tampoco LEE work-packages/ del working tree: obtiene el contrato
     de la revisión base mediante Git (ver «Fuente de confianza del contrato»).
     Un WP que pudiera reescribir el archivo que define su propio alcance
     podría ampliarse a voluntad, y todo el enforcement colapsa. -->

## Contratos técnicos (interfaces, schemas, eventos, invariantes)

### Interfaz

```bash
python3 scripts/check_scope.py <WP-ID> <base>...<head>
# ejemplo: python3 scripts/check_scope.py WP-014 main...HEAD
```

| Código de salida | Significado | Marca en la salida |
|---|---|---|
| `0` | Todos los archivos del diff están dentro del alcance | `OK` |
| `1` | Al menos una violación de alcance | `VIOLACION` |
| `2` | Fail-closed: uso incorrecto o contrato no resoluble | `ERROR` |

Ante violaciones, la salida las enumera **todas**, no solo la primera, indicando archivo y motivo (fuera de permitidos / coincide con prohibidos). Los tres casos son distinguibles **por texto** además de por código, para que un humano leyendo el log sepa cuál se dio.

### Fuente de confianza del contrato

Es el punto crítico de este WP. El script **no puede leer el contrato del WP desde el working tree ni desde `HEAD`**. Si lo hiciera, un implementador que eludiese el hook podría modificar su propio contrato —ampliar la allowlist, retirar prohibiciones— y el verificador evaluaría el diff contra un contrato ya manipulado: el control se estaría validando a sí mismo.

Obligatorio:

1. **Forma canónica única:** el rango se acepta exclusivamente como `<base>...<head>`. Cualquier otra forma (`<base>..<head>`, una sola revisión, cadena vacía) es error fail-closed → exit `2`.
2. **Revisión base:** se calcula `git merge-base <base> <head>`. Esa es la única revisión confiable, por ser anterior a todo commit de la rama que se está juzgando.
3. **Lectura por Git, no por sistema de archivos:** el contrato se localiza y se lee de esa revisión —por ejemplo con `git ls-tree -r --name-only <merge-base> -- work-packages/` y `git cat-file blob <merge-base>:<ruta>`—. Queda prohibido `open()` sobre el working tree y queda prohibido resolver contra `HEAD`.
4. **Unicidad:** debe existir **exactamente un** contrato correspondiente al WP-ID en la revisión base (`work-packages/WP-XXX-*.md`). Cero coincidencias → exit `2`. Dos o más → ambigüedad → exit `2`.
5. **Buena formación:** si el contrato carece de la sección `## Archivos permitidos`, o esa sección queda vacía tras el parseo → exit `2`. Una allowlist vacía **nunca** se interpreta como «todo permitido».

En los tres supuestos —ausencia, ambigüedad, contrato malformado— el comportamiento es **fail-closed**: mensaje explícito y código de salida `2`. Nunca exit `0` por no haber podido decidir.

### Obtención de los archivos del diff

Los cambios se obtienen de forma no ambigua con:

```bash
git diff --name-status -z -M <merge-base> <head>
```

- `-z` separa los campos con NUL: soporta rutas con espacios, saltos de línea o caracteres no ASCII sin necesidad de descomillar.
- `-M` detecta renombrados, que de otro modo aparecerían como par borrado+añadido y perderían la relación.
- Los estados `R` y `C` llevan **dos** rutas (origen y destino); el resto, una. El parseo debe consumir el número correcto de campos por registro.

Cualquier mecanismo equivalente es aceptable siempre que preserve estas tres propiedades: separación no ambigua, detección de renombrados y ambas rutas disponibles.

**Límite de este comando.** `--name-status` aporta **estados y rutas, y nada más**: no dice si una ruta es un symlink ni a dónde apunta. La comprobación de enlaces exige inspeccionar los objetos Git, y se especifica en la sección siguiente.

### Symlinks

Un symlink **versionado** situado dentro del alcance cuyo destino cae fuera del alcance autorizado es una **violación**: el enlace no amplía el alcance. Comprobarlo exige leer los objetos Git y **nunca** resolver el enlace contra el working tree, que puede no existir, estar sucio o haber sido manipulado.

Procedimiento obligatorio:

1. **Identificación:** una entrada es symlink si su **modo Git es `120000`**. Los modos se obtienen de la revisión pertinente con `git ls-tree <rev> -- <ruta>`, o de una sola pasada con `git diff --raw -z -M <merge-base> <head>`, que expone modo de origen y modo de destino junto al estado.
2. **Destino:** el destino del enlace **es el contenido de su blob** y se lee con `git cat-file blob <rev>:<ruta>`. Queda prohibido `os.readlink()`, `os.path.realpath()` y cualquier otra consulta al sistema de archivos.
3. **Revisión que corresponde a cada estado:**
   - Añadido (`A`) y modificado (`M`): se inspecciona en `<head>`.
   - Renombrado (`R`): se inspeccionan **los dos extremos** — el origen en `<merge-base>` y el destino en `<head>`.
   - Eliminado (`D`): se inspecciona en `<merge-base>`, para poder informar de qué enlace se retiró y a dónde apuntaba.
4. **Normalización del destino:** un destino relativo se resuelve **textualmente** respecto al directorio del enlace, sin tocar disco. Todo destino absoluto se deniega, y todo destino que tras normalizar salga de la raíz del repositorio se deniega, coincida o no con un patrón.
5. **Veredicto:** si el enlace está dentro del alcance pero su destino queda fuera —fuera de permitidos, o dentro de prohibidos—, es **violación**, y la salida indica enlace, destino y revisión inspeccionada.

**Límite explícito de este control.** Una verificación post-hoc del diff **solo ve cambios versionados**. No detecta —ni puede detectar— escrituras a archivos externos al repositorio, ni escrituras que no hayan producido ningún cambio versionado. Esa clase de fuga la mitiga el hook preventivo, no este script. Ni la salida del script, ni el manual, ni ningún criterio de aceptación de este WP pueden dar a entender lo contrario.

### Renombrados

Un renombrado se comprueba en **las dos rutas**: origen y destino. Si **cualquiera** de las dos queda fuera del alcance —fuera de permitidos, o dentro de prohibidos—, el resultado es **violación**, y la salida indica cuál de las dos la provoca.

Sacar un archivo de una ruta permitida a una prohibida, y traerlo de una prohibida a una permitida, son **ambas** violaciones: el alcance cubre el movimiento completo, no solo su destino.

### Semántica de patrones

Exactamente la documentada en `work-packages/_TEMPLATE.md`, sección «Archivos permitidos», **tal como la fija** [`DEC-002`](../specs/decisions/DEC-002-semantica-de-traversal.md). En particular: `*` no cruza `/`, `**` sí, `?` es un carácter que no sea `/`, las rutas son relativas a la raíz, un patrón terminado en `/` cubre todo su contenido, los metacaracteres de regex son literales, prohibidos gana sobre permitidos, lo que no coincide con ningún permitido se deniega y los symlinks no amplían el alcance.

**Traversal (DEC-002).** Una ruta tiene traversal **si y solo si alguno de sus componentes separados por `/` es exactamente `..`**. Una subcadena `..` dentro de un nombre legítimo —`notas..md`, `..oculto.md`, `bar..`, `foo../bar`— **no** es traversal. El componente `..` **no se resuelve** contra el anterior; la comprobación es puramente textual, sin consultar el sistema de archivos; y se hace **antes** de evaluar prohibidos y permitidos, denegando coincida o no con un patrón. DEC-002 §4 **no cambia** el tratamiento de `.`, de los separadores duplicados, de los iniciales o finales ni de las mayúsculas: en esos puntos cada implementación conserva exactamente el comportamiento que tiene hoy.

La tabla de ocho casos de DEC-002 §7 es el **criterio de conformidad** y debe reproducirse como pruebas ejecutables en `tests/scope/`.

Esto **no** altera la sección «Symlinks» de este contrato: allí `..` es información legítima del destino de un enlace y sí se resuelve, textualmente y contra el directorio del enlace, sin tocar disco. Son dos reglas distintas y confundirlas produce uno de dos defectos graves: un verificador de enlaces incapaz de seguir ningún destino relativo, o un verificador de rutas que se traga el traversal.

**Invariante crítico:** `check_scope.py` y `guard.sh` deben coincidir en su interpretación de los patrones. Una divergencia entre ambos produciría el peor resultado posible: un cambio que el hook permite y el CI rechaza, o al revés. Por eso este WP **no se reinicia** hasta que la implementación de WP-007 esté fusionada en `main` y una PR de operador lo devuelva a `ready` (ver «Bloqueo»).

### Sin exenciones para `work-packages/`

No hay exenciones, ni nominales ni genéricas. Los tres supuestos son **violación**:

- `work-packages/ACTIVE` en el diff (caso 7).
- El contrato del **propio** WP en el diff (caso 8), aunque el cambio pretenda ampliar la allowlist.
- El contrato de **cualquier otro** WP en el diff (caso 9).

### Precedencia normativa sobre la evidencia de WP-006

`evidence/WP-006/02-alcance-del-diff.md` registró una convención anterior según la cual `check_scope` debía implementar exenciones nominales para `work-packages/ACTIVE` y `work-packages/WP-XXX-*.md`. Para evitar dos normas incompatibles vigentes a la vez, se declara la siguiente regla de precedencia, vinculante para la implementación:

1. **Especificación vigente:** para todo lo relativo a `check_scope`, la especificación vigente es **este contrato en estado `ready`**. Sustituye a la recomendación registrada en aquella evidencia. Ante cualquier discrepancia, prevalece este documento.
2. **Estatus de la evidencia:** `evidence/WP-006/02-alcance-del-diff.md` se conserva como **registro histórico** de por qué se planteó la exención. **No es especificación vigente** y **no se modifica** en esta PR: está fuera del alcance de WP-002 y las evidencias no se reescriben.
3. **Motivo de la sustitución:** cuando se redactó aquella evidencia, la preparación y activación de un WP compartían PR con su implementación, y un verificador ingenuo habría producido un falso positivo garantizado en cada ejecución. Hoy no ocurre: **la preparación/activación y la implementación viven en PR separadas** —ramas `ops/*` para los actos del operador, `wp/WP-XXX-*` para la implementación—. Desaparecido el falso positivo, desaparece el motivo de la exención; y mantenerla debilitaría el caso 8, que es precisamente la prueba de que el contrato se lee del `merge-base`.

Si durante la implementación se concluyera que esta sustitución exige un ADR o una decisión versionada (`specs/decisions/DEC-xxx.md`) además de este contrato: **parar y reportar**. No se amplía el alcance por cuenta propia; `specs/` no está entre los archivos permitidos.

### Deuda declarada: WP-005 y las ramas `ops/*`

El contrato actual de `work-packages/WP-005-check-scope-en-ci.md` hace **fallar** el job cuando la rama no encaja en `wp/(WP-[0-9]{3})-.*`. Consolidado el flujo de PR de operador, las ramas `ops/*` —que son las que legítimamente tocan `work-packages/`— harían fallar ese job en cada PR de preparación o de cierre.

Queda registrado aquí como **deuda declarada y bloqueo previo a la activación de WP-005**: antes de marcar el check como obligatorio en el ruleset, WP-005 debe decidir qué hace con las ramas que no son de WP —omitir el job, o exigir aprobación humana explícita—. **No se corrige aquí:** `work-packages/**` está prohibido en este WP y `WP-005-check-scope-en-ci.md` **no se modifica** en esta PR.

## Entorno autorizado (herramientas, comandos, red, secretos)

- Herramientas: Read, Grep, Glob, Edit, Write, Bash
- Comandos: `python3` (biblioteca estándar), `bash`, `git` (local, solo lectura), `shellcheck`
- Red: NINGUNA
- Secretos: NINGUNO

**Sin dependencias nuevas.** `pytest` **no está instalado** en el entorno de referencia y no se instala: la suite es un script Bash que invoca `python3` con la biblioteca estándar, siguiendo la convención ya establecida en `tests/governance/test-check-active.sh`. Debe funcionar con el `bash` 3.2 de macOS (sin `globstar`, sin arrays asociativos, sin `mapfile`).

**Aislamiento de las pruebas.** La suite construye sus propios repositorios git temporales (`mktemp -d`, `git init`, commits sintéticos) y los destruye al terminar. **Nunca** opera sobre el repositorio real, ni crea ramas en él, ni escribe fuera de su directorio temporal. Los symlinks de prueba se crean **dentro** de esos repositorios temporales y se versionan, que es la única forma de ejercitar el modo `120000`.

## Verificación (comandos de validación + criterios de aceptación medibles)

**Comandos** (headless, sin red, código de salida significativo):

```bash
bash tests/scope/run-suite.sh
python3 scripts/check_scope.py WP-002 main...HEAD
shellcheck --severity=warning --shell=bash tests/scope/run-suite.sh
bash tests/governance/test-check-active.sh
bash tests/guard/run-suite.sh
```

Los dos últimos son de **no regresión**: este WP no toca `guard.sh` ni la validación de gobierno, y deben seguir en verde sin cambios. Sus diez `xfail` deben seguir siendo diez.

**Nueve casos mínimos que debe cubrir la suite**, cada uno sobre un repositorio git temporal propio:

- [ ] 1. Archivo **permitido** por coincidencia literal → dentro de alcance
- [ ] 2. Archivo **fuera de todos los patrones** permitidos → violación
- [ ] 3. **Globs**: `**` cruza `/` y `*` **no** lo cruza (`scripts/*.py` no cubre `scripts/sub/a.py`)
- [ ] 4. **Archivo nuevo** (estado `A`) → se evalúa igual que uno modificado
- [ ] 5. **Symlink versionado** dentro del alcance que apunta fuera → violación, detectada por modo `120000` y por el blob del enlace, **sin** consultar el working tree; se ejercitan enlace añadido, modificado, renombrado y eliminado
- [ ] 6. **Renombrado** (estado `R`) → se comprueban origen y destino; violación si cualquiera de los dos incumple
- [ ] 7. **`work-packages/ACTIVE`** en el diff → violación (no hay exención)
- [ ] 8. **Contrato propio manipulado:** el diff modifica `work-packages/WP-002-check-scope.md` **añadiendo** rutas permitidas que cubrirían un archivo fuera de alcance → sigue siendo **violación**, porque el contrato se evalúa desde el `merge-base` y la manipulación no surte efecto
- [ ] 9. **Contrato ajeno** (`work-packages/WP-005-*.md`) en el diff → violación

El caso 8 es la prueba de que la fuente de confianza es el `merge-base`. Debe fallar por **dos** motivos simultáneos —el archivo fuera de alcance sigue siendo violación, y tocar `work-packages/**` también lo es— y la suite debe comprobar además que la allowlist ampliada **no** aparece en el razonamiento del script.

**Comportamiento fail-closed exigido** (además de los nueve casos):

- [ ] Rango en forma no canónica (`main..HEAD`, una sola revisión, cadena vacía) → exit `2`
- [ ] WP-ID sin contrato en la revisión base → exit `2`
- [ ] Dos contratos para el mismo WP-ID en la revisión base → exit `2`
- [ ] Contrato sin `## Archivos permitidos`, o con esa sección vacía → exit `2`, nunca «todo permitido»

**Criterios de aceptación:**

- [ ] `bash tests/scope/run-suite.sh` en verde: **100 %** de los casos pasan
- [ ] Ante una violación, la salida **enumera todas** las violaciones con archivo y motivo
- [ ] Los códigos de salida son exactamente: `0` sin violaciones, `1` con violaciones, `2` en fail-closed
- [ ] El script **no** abre ningún archivo del working tree: ni contratos de `work-packages/`, ni destinos de symlink. Verificable por inspección del código (`open()`, `os.readlink`, `realpath` ausentes sobre rutas del repositorio) y por los casos 5 y 8
- [ ] La salida y el manual declaran el límite del control: **no** detecta escrituras externas al repositorio ni cambios no versionados
- [ ] La suite no deja rastro: ningún fichero nuevo, ninguna rama y ningún cambio en el repositorio real tras ejecutarla
- [ ] `shellcheck` sin avisos sobre la suite
- [ ] `tests/guard/run-suite.sh` y `tests/governance/test-check-active.sh` siguen en verde, con los mismos diez `xfail`
- [ ] `docs/manual/02-ciclo-de-un-wp.md` documenta la invocación local y dice explícitamente que **no bloquea la fusión hasta WP-005**
- [ ] `git diff --name-status -M main...HEAD` ⊂ archivos permitidos

## Evidencias exigidas (qué debe aparecer en evidence/WP-002/)

- [ ] Log completo de `bash tests/scope/run-suite.sh` con su código de salida
- [ ] Ejecución de ejemplo con una violación simulada, mostrando la salida y el exit `1`
- [ ] Demostración del caso 8: contrato propio manipulado que **no** amplía el alcance, indicando el `merge-base` empleado
- [ ] Demostración del caso 5: los cuatro estados de symlink (añadido, modificado, renombrado, eliminado) con el modo `120000` y el destino leído del blob
- [ ] Demostración de los cuatro supuestos fail-closed, con su exit `2` y su mensaje
- [ ] `git status --porcelain` antes y después de la suite, idénticos (aislamiento de fixtures)
- [ ] Salidas de `tests/guard/run-suite.sh` y `tests/governance/test-check-active.sh` (no regresión)
- [ ] `git diff --name-status -M main...HEAD`
- [ ] `cost.md` con el formato de DEC-001

## Condiciones de parada específicas

- Ambigüedad en la semántica de los globs. No debería darse: la convención quedó fijada en el Paso 0, en `_TEMPLATE.md`. Si aun así aparece un caso no cubierto por esa convención, **parar**: resolverlo por cuenta propia produciría divergencia con `guard.sh`, que es el fallo más grave que puede introducir este WP.
- Si al implementar se descubre que `guard.sh` interpreta algún patrón de forma distinta a lo documentado: parar y reportar. Es un hallazgo, no algo que arreglar aquí; `guard.sh` está fuera de alcance.
- Si la sustitución declarada en «Precedencia normativa» pareciera exigir un ADR o un `DEC-xxx`: **parar y reportar**. `specs/` no está entre los archivos permitidos y el alcance no se amplía por cuenta propia.
- Si cubrir un caso exigiera escribir en `work-packages/`, `tests/guard/`, `tests/governance/` o `evidence/WP-006/`: parar. Las pruebas construyen repositorios git temporales, nunca manipulan el repositorio real.
- Si en un escenario legítimo el `merge-base` no existiera o el rango no fuera resoluble (por ejemplo, historiales sin ancestro común): parar y reportar **antes** de relajar la regla a `HEAD`. Relajarla anularía el control.

## Migración / rollback

No aplica migración: script nuevo, sin consumidores todavía. Ningún proceso depende de él hasta que WP-005 lo integre en CI; hasta entonces su ejecución es local y voluntaria, de modo que revertirlo no deja ningún check roto.

**Rollback no destructivo.** Nunca `git reset --hard`, nunca `git branch -D`, nunca force-push y nunca reescritura de historial:

- **Antes del commit:** restaurar únicamente las rutas explícitas afectadas con `git restore --source=HEAD --staged --worktree --` seguido de esas rutas. Nada de `git checkout .` ni de restauraciones masivas.
- **Tras un commit local no publicado:** cambiar a `main` con `git switch main` y **conservar la rama intacta**. `main` no se toca y el commit no se pierde.
  - Si se desea abandonar la rama, **no se borra automáticamente**: se informa del **nombre de la rama** y del **hash del commit**, y se espera **autorización humana explícita**.
  - Solo cuando Git confirme que la rama ya está fusionada podrá usarse `git branch -d`, que es el borrado seguro y que el propio Git rechaza si quedan commits sin fusionar. `git branch -D` queda **prohibido**: fuerza el borrado aunque haya trabajo no fusionado, y por tanto es destructivo.
- **Tras el push:** cerrar la PR sin fusionar y borrar la rama remota. `main` no se modifica, y no se hace force-push.
- **Tras una eventual fusión:** revertir mediante una **PR nueva** de revert. No se reescribe el historial de `main`.
