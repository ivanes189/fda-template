# WP-008 — Runtime fail-closed: anclaje del hook y de las reglas, y preflight bloqueante en CI

estado: ready
prioridad: P0
agente_responsable: implementer     agente_revisor: code-reviewer
requisitos: [REQ-FDA-001, REQ-FDA-003, SEC-001]  adr: [ADR-001]
presupuesto_max_eur: 40             max_ciclos_correccion: 6

<!-- Revisores: qa (pruebas) + code-reviewer (revisión de la PR) + security-reviewer
     OBLIGATORIO, porque este WP toca CI y el sistema de permisos.

     El estado 'ready' que figura arriba es la PROPUESTA del contrato.
     Materializar este contrato con estado ready y escribir WP-008 en
     work-packages/ACTIVE son actos del operador humano, en una PR de operador
     separada. Este WP no se activa a sí mismo.

     Edit(/.github/workflows/**) y Edit(/.claude/settings.json) están en el deny
     de .claude/settings.json: NINGÚN agente escribe esos dos archivos, tenga
     este WP el alcance que tenga. Los aplica una persona con el parche
     verificado de "Contratos técnicos" §7. -->

## Replanificación humana — 2026-08-08

**Acto del operador.** Esta sección la escribe y la aplica **una persona**, en una PR de operador, igual que la materialización y la activación del contrato. `work-packages/**` sigue siendo ruta **prohibida** para todo agente: ningún agente edita este archivo.

**Los dos ciclos sobre el contrato anterior están consumidos y cerrados.** No se abre un tercer ciclo sobre él. Lo que ocurre aquí es lo que corresponde cuando la causa está en el contrato: el operador **para**, registra la causa, **reescribe el contrato** y autoriza una **nueva iteración sobre el contrato ya corregido**. [`docs/manual/05-bloqueos-y-parada.md`](../docs/manual/05-bloqueos-y-parada.md) §8 señala esa dirección —«¿El contrato estaba mal definido? → reescribe el WP»— y **no** autoriza por sí solo ninguna iteración adicional: quien la autoriza es esta decisión humana, fechada y registrada en archivo.

**Qué significa `max_ciclos_correccion: 3`.** El recuento **es acumulado y no se reinicia**: los dos ciclos ya consumidos siguen contando. El tercer hueco es la **autorización excepcional y única** que permite iterar sobre este contrato corregido, y **no debe leerse como un tercer ciclo ordinario sobre el contrato antiguo**. **Un cuarto ciclo exigiría otra decisión humana, nueva y fechada**; esta sección no lo concede.

**Causa raíz, en dos capas que no se excusan entre sí.**

| Capa | Defecto | Dónde se corrige |
|---|---|---|
| **Contrato** | Incompleto: exigía usar el evento del hook y decía para qué capacidades, pero **no definía el esquema oficial** de los mensajes de `--include-hook-events` **ni ninguna regla determinista de asociación** entre un evento y una llamada concreta | §5c, nueva y contractual |
| **Implementación y pruebas** | Se trabajó sobre un **esquema sintético incorrecto** —`type` igual a `hook_event`, con `hook_event_name`, `tool_name`, `tool_use_id` y `tool_input`— y la asociación se decidió por **búsqueda de subcadenas**, que **acepta colisiones** como `tu_1` dentro de `tu_10` o `cd sub` dentro de `cd sub2`. Las pruebas heredaron ese mismo esquema inventado y por eso salieron en verde sin demostrar nada | §5c, más las **seis** pruebas negativas obligatorias |

Ninguna de las dos capas disculpa a la otra: el contrato no dijo qué forma tenía el evento, **y** la implementación dio por buena una forma inventada sin verificarla contra la salida real. Ambas quedan registradas aquí y se replican en `evidence/WP-008/` conforme a [`docs/manual/05-bloqueos-y-parada.md`](../docs/manual/05-bloqueos-y-parada.md) §8.

**Qué NO se autoriza.** No cambia el objetivo funcional de WP-008, ni sus archivos permitidos, ni sus prohibidos, ni el presupuesto, ni la composición exigida al runner —14 · 13 · 1 · 0—, ni los fixtures, ni el protocolo del parche, ni la cronología de los tres commits. No se reactiva ningún workflow, no se toca `main`, no se levanta la congelación de WP-007 y no se altera la lista cerrada de [`DEC-003`](../specs/decisions/DEC-003-pausa-migracion-y-contencion.md) §4, dentro de la cual WP-008 ya figura.

## Replanificación humana — 2026-08-09: orden causal del flujo

La auditoría independiente del tercer ciclo ha demostrado que el analizador
empareja `tool_use` y `tool_result` por igualdad exacta del identificador, pero
no exige que el `tool_result` aparezca después de su `tool_use`. Como
consecuencia, C6 puede aceptar un flujo sintético causalmente invertido.

El tercer ciclo queda consumido. Esta decisión humana autoriza un cuarto y
último ciclo de corrección, sin ampliar el alcance funcional de WP-008.

Para toda llamada esperada, su `tool_result` correspondiente debe aparecer
estrictamente después del `tool_use` en el flujo. La igualdad de identificadores
es necesaria, pero no suficiente. Un resultado anterior, ausente o no
emparejable deja la subsonda no conforme o no decidible.

Un ciclo de hook exige además este orden:

`tool_use < hook_started < hook_response < tool_result`

Los dos extremos mantienen el mismo `hook_id` y deben estar dentro de la ventana
de la llamada. `hook_progress` continúa siendo opcional.

`tests/runtime/test-runner-empirico.sh` debe incluir pruebas negativas que
demuestren el rechazo de:

- un `tool_result` de Read anterior a su `tool_use` en C6;
- ese mismo orden invertido en el Read de C6.tras-cd;
- un `hook_response` anterior a su `hook_started`.

No se autoriza ningún quinto ciclo sin otra decisión humana nueva y fechada.

## Replanificación humana — 2026-08-09: secuencia causal completa

La auditoría independiente del cuarto ciclo ha demostrado que el analizador
valida correctamente el orden entre cada `tool_use` y su propio `tool_result`,
pero el veredicto general solo exige un resultado asociado para el último paso.

Como consecuencia, una secuencia de dos pasos puede producir `PERMITIDO` o
`BLOQUEADO` aunque el resultado del primer paso esté ausente o aparezca antes de
su `tool_use`. También puede aceptar ventanas solapadas cuando la segunda
llamada aparece antes del resultado de la primera.

El cuarto ciclo queda consumido. Esta decisión humana autoriza un quinto y
último ciclo de corrección, sin ampliar el alcance funcional de WP-008.

Para una secuencia de N pasos, cada llamada esperada debe tener un
`tool_result` asociado y posterior. Para dos pasos consecutivos se exige:

`tool_use_1 < tool_result_1 < tool_use_2 < tool_result_2`

La regla se aplica igualmente a controles neutrales, M3 y C6.tras-cd. Las
ventanas de dos llamadas esperadas no pueden solaparse y un mismo ciclo de hook
no puede satisfacer simultáneamente a dos llamadas.

Si falta el resultado de cualquier paso, está invertido o la siguiente llamada
comienza antes del resultado del paso anterior, la subsonda queda
`NO_DECIDIBLE` o `NO_CONFORME`, independientemente del resultado del paso
decisivo y del sistema de archivos.

`tests/runtime/test-runner-empirico.sh` debe demostrar el rechazo de:

- una secuencia de dos pasos cuyo primer resultado esté invertido;
- una secuencia de dos pasos cuyo primer resultado esté ausente;
- dos llamadas agrupadas antes del resultado de la primera;
- C6.tras-cd con Bash y Read en ventanas solapadas;
- y debe conservar un control positivo con ambos pasos completos y ordenados.

No se autoriza ningún sexto ciclo sin otra decisión humana nueva y fechada.

## Replanificación humana — 2026-08-09: controles neutrales de edición

La primera ejecución empírica real terminó con exit 2 durante el control
neutral, antes de ejecutar cualquiera de las catorce sondas. Write, Bash y Read
quedaron PERMITIDO, mientras que Edit y NotebookEdit produjeron un tool_result
de error. No se observaron mensajes de hooks inesperados.

El quinto ciclo queda consumido. Esta decisión humana autoriza un sexto y último
ciclo de corrección, sin ampliar el alcance funcional de WP-008.

El resultado observado no demuestra por sí solo la existencia de una
restricción gestionada: un tool_result de error también puede proceder de una
precondición o validación propia de la herramienta. El runner no debe atribuir
una causa concreta sin evidencia estructurada que la demuestre.

Los controles neutrales de Edit y NotebookEdit, y las subsondas C2.Edit y
C2.NotebookEdit, deben realizar una lectura preparatoria del archivo objetivo y
después la llamada decisiva de edición, dentro de la misma sesión.

Las secuencias exigidas son:

- Read exitoso seguido de Edit;
- Read exitoso seguido de NotebookEdit.

Read queda fuera del matcher contractual y no exige ciclo de hook. La llamada
decisiva Edit o NotebookEdit mantiene la exigencia de un ciclo PreToolUse
completo dentro de su propia ventana.

Las allowlists y los conjuntos mínimos de herramientas deben incluir,
respectivamente, Read+Edit y Read+NotebookEdit. Cada tool_use debe tener su
tool_result posterior y las ventanas no pueden solaparse.

Las pruebas deterministas deben cubrir los flujos positivos y rechazar lectura
ausente, fallida o invertida, llamadas solapadas, ciclo asociado a la lectura en
vez de a la edición y resultado decisivo ausente.

Si el control vuelve a fallar después de cumplir estas precondiciones, el runner
debe detenerse con error de entorno sin atribuirlo específicamente a ajustes
gestionados o a un hook salvo que exista evidencia estructurada de ello.

No se autoriza otra ejecución empírica hasta que la corrección pase todas las
validaciones deterministas y la auditoría independiente la declare apta.

No se autoriza ningún séptimo ciclo sin otra decisión humana nueva y fechada.

## Objetivo y contexto

El runtime de la FDA es **fail-closed dentro del contrato de lanzamiento soportado** —Claude Code se inicia en la raíz del repositorio—: el hook `PreToolUse` se invoca por una ruta anclada con `CLAUDE_PROJECT_DIR`; un hook **ausente o sin permiso de ejecución** produce **exit 2** y bloquea la herramienta en vez de dejarla pasar; las ocho reglas `Read` y `Edit` de `.claude/settings.json` quedan ancladas a la **raíz del proyecto** y no al directorio de trabajo; y un **preflight estructural versionado** —`tests/runtime/check-config.sh`— comprueba todo lo anterior en cada PR dentro del job **`Gobierno FDA`**, de modo que una configuración degradada **no se puede fusionar**.

Contexto, con las dos causas separadas porque son capas distintas:

1. **La invocación del hook.** `.claude/settings.json` invoca `.claude/hooks/guard.sh` por **ruta relativa**. La documentación oficial de hooks establece que **solo el código de salida `2` bloquea** y que cualquier otro código es un error **no bloqueante** que deja continuar la herramienta. Un hook que no se encuentra o que no es ejecutable no devuelve `2`: **deja pasar la escritura**. `DEC-003` §1 registró el mecanismo como demostrado y su materialización como **no demostrada**; esa distinción se mantiene y este WP la mide, no la presupone.

2. **El anclaje de las reglas de permiso.** Las ocho reglas de archivo usan el prefijo `./`. La documentación oficial de permisos establece que `./ruta` ancla en el **directorio actual**, mientras que el anclaje a la raíz del proyecto, en settings de proyecto, es `/ruta`. Las cuatro reglas `Read` que [`SEC-001`](../specs/requirements/SEC-001-sin-secretos.md) criterio 4 da por operativas, y las cuatro `Edit` que protegen workflows, `CODEOWNERS`, los hooks y el propio `settings.json`, **dejan de coincidir** si el directorio de trabajo no es la raíz.

Este WP es la primera de las dos condiciones del **criterio de salida de [`DEC-003`](../specs/decisions/DEC-003-pausa-migracion-y-contencion.md) §6**. La segunda —fijar las acciones por SHA— es **WP-009** y no se toca aquí.

## Alcance (incluido / fuera de alcance)

**Incluido:**

- **Parche verificado único** en `evidence/WP-008/parche/`, que **una persona ejecuta** en dos fases y que cubre los dos archivos vedados:
  - `.github/workflows/ci.yml`: **un paso nuevo mínimo** en el job `Gobierno FDA` que **invoca** el preflight versionado.
  - `.claude/settings.json`: invocación del hook anclada con `CLAUDE_PROJECT_DIR` y con normalización explícita a `exit 2`, y las ocho reglas de archivo reancladas a la raíz del proyecto.
- **`tests/runtime/check-config.sh`**: preflight estructural, headless, sin red, con código de salida significativo y contadores propios.
- **`tests/runtime/test-check-config.sh`**: pruebas del preflight sobre fixtures propios, con contadores propios.
- **`tests/runtime/test-protocolo.sh`**: prueba headless de la máquina de estados del parche, con contadores propios, ejecutada íntegramente sobre fixtures.
- **`tests/runtime/runner-empirico.sh`**: runner versionado y headless que ejecuta las **catorce sondas lógicas** —los siete contextos de la matriz y las siete capacidades C1 a C7— mediante `claude -p`, decide cada veredicto de forma automática y devuelve un código de salida agregado significativo.
- **`tests/runtime/test-runner-empirico.sh`**: pruebas deterministas de la lógica de decisión del runner —analizador del flujo `stream-json`, esquema contractual de eventos de §5c, asociación por ventana de orden, igualdad estructurada, y los dos regímenes de C1–C5/C7 y C6—, headless, **sin red, sin coste y sin ninguna invocación de `claude -p`**, con contadores propios.
- **`tests/runtime/capturar-ci-rojo.sh`**: comprobador headless de las dos barreras de CI, con adquisición acotada en el tiempo y validación pura.
- **`tests/runtime/test-capturar-ci-rojo.sh`**: pruebas del comprobador, headless y sin red, con contadores propios.
- **`tests/runtime/check-alcance-wp008.sh`**: comprobaciones locales de conformidad de este WP —alcance del diff e invariante de cuarentena—, headless y con contadores propios.
- **`tests/runtime/command-canonico.txt`** y **`tests/runtime/reglas-canonicas.txt`**: los dos oráculos versionados del preflight.
- **`tests/runtime/fixtures/`**: fixtures de configuración conforme y no conforme, fixtures de proyecto completo para el protocolo y para el runner, respuestas de `gh` grabadas bajo `tests/runtime/fixtures/ci/`, y el archivo de patrones bajo `tests/runtime/fixtures/cuarentena/`.
- **`tests/runtime/matriz-empirica.md`** y **`tests/runtime/smoke-capacidades.md`**: la especificación versionada que el runner aplica —contratos de cada sonda, allowlists mínimas completas y criterios de veredicto—.
- Evidencias en `evidence/WP-008/`: resultados saneados del runner, huellas, logs del parche, y **dos ejecuciones reales de CI** —una en rojo que demuestra el bloqueo y la final en verde—.
- Cinco archivos de `docs/manual/`, la guía fundacional y `SEC-001`, justificados uno a uno en §8.

**Fuera de alcance:**

- **WP-009 y la cadena de suministro.** Las acciones sin SHA son **deuda preexistente declarada** de `REQ-FDA-002`, asignada a WP-009. No son hallazgo bloqueante de este WP y no se corrigen aquí.
- **WP-010.** Ni la adquisición headless del coste, ni el validador de `cost.md`, ni el registro de excepciones.
- **WP-011.** Ni la frontera de revisión verificable, ni la reactivación de ningún workflow de agente.
- **`tests/guard/run-suite.sh`.** Prohibido por `DEC-003` §7 durante toda la pausa. El preflight vive en script propio con contadores propios **precisamente** para no alterar los suyos.
- **`.claude/hooks/guard.sh`.** No se modifica una línea. Este WP cambia **cómo se invoca** el hook y **cómo se interpreta su ausencia**, no lo que el hook hace.
- **WP-007 y WP-002.** Congelado y `blocked` respectivamente. No se tocan sus archivos, ni su worktree, ni sus evidencias, ni las siete huellas de `DEC-003` §1.
- **`work-packages/**` y `work-packages/ACTIVE`.** Actos del operador. Este WP no se activa, no se marca `done` y no mueve `ACTIVE`.
- **El ruleset y el estado externo de los workflows.** `claude.yml` y `code-review.yml` siguen `disabled_manually`; no se reactivan, no se editan y no se registran cambios sobre ellos. **`main` no se modifica para fabricar la evidencia roja ni durante el desarrollo**; solo cambiará mediante la eventual **fusión humana** de la PR aprobada.
- **Las listas `ask` y `allow` de `.claude/settings.json`**, y las cuatro reglas `Bash(...)` del `deny`: no cambian. Solo se reanclan las ocho reglas de archivo y se sustituye el bloque `hooks`.
- **Eliminar el paso «El hook guard.sh es ejecutable»** de `ci.yml`, aunque el preflight lo cubra. Quitarlo excede el mínimo, y el solape queda declarado.
- **`.agents/`, `.codex/` y `AGENTS.md`.** Estado operativo local en cuarentena por `DEC-003` §8: no se leen, no se versionan y no se modifican. El invariante es concreto y **se verifica de forma headless**, no por inspección:
  - **Ninguna herramienta de este WP enumera archivos sin versionar.**
  - **Ninguna invocación usa el comando de estado de Git en su modo por defecto**, ni con las formas que incluyen lo no versionado.
  - Cuando se necesita el estado de Git, se usa `--untracked-files=no`.
  - Los **diffs y las consultas del índice sí operan sobre contenido rastreado** —es su función— y **no leen el contenido de la cuarentena**, que no está versionada y por tanto nunca aparece en un diff ni en el índice.
  - Lo comprueba el modo `--cuarentena` de §10b, con código de salida significativo.

## Archivos permitidos

- .claude/settings.json
- .github/workflows/ci.yml
- tests/runtime/**
- evidence/WP-008/**
- docs/02-guia-fabrica-desarrollo-agentica.md
- docs/manual/MANUAL.md
- docs/manual/01-instalacion.md
- docs/manual/02-ciclo-de-un-wp.md
- docs/manual/04-agentes.md
- docs/manual/07-troubleshooting.md
- specs/requirements/SEC-001-sin-secretos.md

<!-- Las dos primeras rutas figuran aquí porque el diff de la PR las contiene y
     el contrato debe decir la verdad sobre lo que la PR toca, mismo criterio que
     WP-006 y WP-007. Listarlas NO autoriza a ningún agente a escribirlas: la
     capa de settings.json gana siempre. Las otras nueve no están vedadas y las
     escribe el agente dentro del alcance.
     Los cinco archivos de docs/manual/ son nominales y mínimos: no se usa
     docs/manual/** . La justificación de cada uno está en §8. -->

## Archivos prohibidos

- tests/guard/run-suite.sh
- tests/guard/**
- .claude/hooks/guard.sh
- .claude/hooks/**
- .claude/agents/**
- .claude/skills/**
- .github/workflows/claude.yml
- .github/workflows/code-review.yml
- .github/pull_request_template.md
- work-packages/**
- scripts/**
- tests/scope/**
- tests/governance/**
- evidence/WP-000/**
- evidence/WP-006/**
- evidence/WP-007/**
- specs/decisions/**
- specs/adr/**
- specs/finops/**
- specs/requirements/REQ-FDA-001-alcance-verificado.md
- specs/requirements/REQ-FDA-002-workflows-endurecidos.md
- specs/requirements/REQ-FDA-003-manual-navegable.md
- docs/manual/03-redactar-un-wp.md
- docs/manual/05-bloqueos-y-parada.md
- docs/manual/06-costes-y-metricas.md
- CLAUDE.md
- CODEOWNERS

<!-- docs/manual/05-bloqueos-y-parada.md se prohíbe expresamente: DEC-003 §7
     registra que ese archivo ya tiene cambios pendientes en el worktree
     congelado de WP-007 y deberá reconciliarse con la versión de DEC-003 al
     reanudarse. Una tercera versión agravaría esa reconciliación.
     evidence/WP-007/** se prohíbe porque las siete huellas de DEC-003 §1 deben
     permanecer intactas.
     REQ-FDA-003 figura en 'requisitos' del frontmatter porque este WP queda
     VINCULADO a él y lo VERIFICA: toca cinco archivos de docs/manual/ y ejecuta
     check-manual.py entre sus comandos de validación. Y figura aquí, entre los
     prohibidos, porque el requisito es INMUTABLE para este WP: se satisface y se
     comprueba, no se enmienda. Las dos cosas son compatibles y deliberadas.
     SEC-001-sin-secretos.md es la ÚNICA ruta permitida bajo specs/requirements/. -->

## Contratos técnicos (interfaces, schemas, eventos, invariantes)

### 1. El cambio en `.claude/settings.json`

#### 1a. Invocación del hook

El bloque `hooks.PreToolUse` conserva **exactamente** el matcher actual —`Edit|Write|MultiEdit|NotebookEdit|Bash`, la línea más sensible de toda la configuración— y sustituye el `command`, que hoy es la ruta relativa `.claude/hooks/guard.sh`, por una invocación que cumple tres cosas a la vez:

1. **Anclada** a la raíz del proyecto mediante `CLAUDE_PROJECT_DIR`.
2. **Fail-closed explícito**: hook ausente o sin permiso de ejecución produce **exit 2**.
3. **Normalización**: cualquier código distinto de `0` devuelto por el guard se traduce a `2`.

**Comando canónico**, en una sola línea lógica y transcrito aquí de forma literal y contractual:

```
if [ -x "$CLAUDE_PROJECT_DIR/.claude/hooks/guard.sh" ]; then "$CLAUDE_PROJECT_DIR/.claude/hooks/guard.sh"; c=$?; [ "$c" -eq 0 ] && exit 0 || exit 2; else echo "guard.sh ausente o no ejecutable" >&2; exit 2; fi
```

**Por qué shell form y no exec form.** La documentación oficial recomienda la **exec form** cuando se usa un marcador de ruta, y con razón: no hay tokenización del shell y las rutas con espacios no necesitan comillas. Pero la exec form lanza el ejecutable directamente y **no puede** convertir un fallo de lanzamiento en `exit 2`, porque el proceso que debería devolver `2` es justo el que no arranca. Como el punto 2 es el objetivo de este WP, y como crear un lanzador propio exigiría un archivo nuevo bajo `.claude/hooks/` —ruta prohibida por este contrato—, se usa **shell form** con la ruta entrecomillada. La desviación respecto a la recomendación oficial es **deliberada, acotada y aquí registrada**, y el runner empírico demuestra que funciona con rutas que contienen espacios.

#### 1b. Reanclaje de las ocho reglas de archivo, una a una

Correspondencia **uno a uno**: ocho reglas originales, ocho finales. Cuatro `Read` y cuatro `Edit`.

Reglas de hoy, ancladas al directorio de trabajo:

```
Read(./.env*)
Read(./**/secrets/**)
Read(./**/*.pem)
Read(./**/id_rsa*)
Edit(./.github/workflows/**)
Edit(./CODEOWNERS)
Edit(./.claude/hooks/**)
Edit(./.claude/settings.json)
```

Reglas tras este WP, ancladas a la raíz del proyecto. **Este es el conjunto contractual exacto**, y es la fuente frente a la que se compara todo lo demás:

```
Read(/**/.env*)
Read(/**/secrets/**)
Read(/**/*.pem)
Read(/**/id_rsa*)
Edit(/.github/workflows/**)
Edit(/CODEOWNERS)
Edit(/.claude/hooks/**)
Edit(/.claude/settings.json)
```

La documentación oficial establece que `/` ancla al origen de los settings —en `.claude/settings.json` de proyecto, la raíz del repositorio— y que `**` atraviesa directorios. `Read(/**/.env*)` cubre por tanto un archivo `.env` en la raíz y en cualquier directorio anidado, con una sola regla. Las dos pruebas empíricas de «Verificación», una por profundidad, son las que lo acreditan sobre la versión instalada.

**Invariantes del cambio, los cinco:**

- **El matcher no cambia.** `Edit|Write|MultiEdit|NotebookEdit|Bash`, literal. Si `Bash` desapareciera, el hueco se reabriría entero.
- **Las listas `ask` y `allow` no cambian**, ni una entrada.
- **Las cuatro reglas `Bash(...)` del `deny` no cambian.**
- **No se añade ninguna clave nueva** a `settings.json` fuera de las descritas.
- **`guard.sh` no se toca.** Su lógica, su contrato de entrada y salida y sus códigos siguen siendo los mismos.

El conjunto resultante es **equivalente o más estricto** que el actual. Ninguna ruta hoy denegada puede quedar permitida.

### 2. `tests/runtime/check-config.sh` — el preflight estructural

Script versionado, headless, sin red, sin prompts, con contadores propios e independiente en todo de `tests/guard/run-suite.sh`.

**Interfaz:**

```bash
bash tests/runtime/check-config.sh [ruta_settings] [ruta_repo]
```

Ambos argumentos son opcionales y por defecto apuntan al repositorio real. El argumento explícito manda sobre el valor por defecto, conforme al invariante **I4** de [`ADR-001`](../specs/adr/ADR-001-runtime.md): es lo que permite validar un candidato **antes** de sustituir el archivo real, y probar el propio preflight contra fixtures.

**Salida:** una línea por comprobación y, al final, `RESULTADO: N conformes · M no conformes`. **Exit `0`** si `M` es cero; **exit `1`** si hay alguna no conformidad; **exit `2`** si los argumentos son inválidos o el archivo no existe.

**Las nueve comprobaciones:**

| # | Comprobación | Criterio exacto |
|---|---|---|
| 1 | JSON válido | `settings.json` parsea con `python3 -m json.tool` |
| 2 | `PreToolUse` presente | Existe `hooks.PreToolUse` y es una lista no vacía |
| 3 | Matcher exacto | Algún grupo tiene `matcher` **igual, carácter a carácter**, a `Edit\|Write\|MultiEdit\|NotebookEdit\|Bash` |
| 4 | Comando canónico exacto | El `command` de ese grupo, tras normalizar secuencias de espacios a uno solo y recortar extremos, es **idéntico carácter a carácter** al oráculo `tests/runtime/command-canonico.txt` normalizado igual. Cubre a la vez el anclaje con `CLAUDE_PROJECT_DIR` y el fail-closed con `exit 2`, y **no basta con contener esas cadenas**: un comando inerte que las incluyera superaría una comprobación por subcadena y no supera esta |
| 5 | Guard presente y ejecutable | `<raíz>/.claude/hooks/guard.sh` existe y `test -x` es cierto |
| 6 | Reglas ancladas | Ninguna regla `Read(...)` o `Edit(...)` empieza por `./` ni queda sin anclar |
| 7 | Sin reglas `Write(...)` inertes | Ninguna regla empieza por `Write(`; la forma que cubre las herramientas de edición es `Edit(...)` |
| 8 | Recuento | `permissions` contiene **exactamente ocho** reglas `Read(...)` o `Edit(...)` |
| 9 | Conjunto exacto | El conjunto de las ocho reglas coincide **elemento a elemento** con el oráculo `tests/runtime/reglas-canonicas.txt`: sin ausencias, sin reglas adicionales, sin sustituciones y sin duplicados. La comparación es determinista sobre listas ordenadas, de modo que una duplicación que compense una ausencia, o una sustitución que mantenga el total en ocho, **fallan igualmente** |

Las seis comprobaciones que `DEC-003` §6 y este contrato exigen como mínimo quedan cubiertas así: JSON válido en 1, `PreToolUse` en 2, matcher exacto en 3, comando anclado y fail-closed con `exit 2` en 4, y guard presente y ejecutable en 5. Las comprobaciones 6 a 9 sostienen §1b.

**Los dos oráculos.** `tests/runtime/command-canonico.txt` contiene el comando de §1a y `tests/runtime/reglas-canonicas.txt` contiene las ocho reglas de §1b, una por línea. Son el **oráculo versionado del test**, no la fuente contractual: la fuente contractual es **este WP aprobado**, que transcribe ambas cosas literalmente y que está **prohibido para el implementador** mientras el WP se ejecuta.

**Qué previenen y qué no.** La comparación determinista previene la **deriva accidental**: que alguien retoque el `command` o las reglas de `settings.json` y el preflight lo dé por bueno. **No resiste una modificación coordinada** del comprobador y de sus oráculos: quien edite a la vez `check-config.sh` y los dos `.txt` puede hacer pasar cualquier configuración. Esa defensa no vive aquí y este WP no la construye: vive en el **diff de la PR**, en la **revisión humana** y en el **ruleset**.

**Prohibición explícita:** el preflight no lee ni escribe `tests/guard/**`, no invoca `run-suite.sh` y no comparte contadores con ella.

### 3. `tests/runtime/test-check-config.sh` — pruebas del preflight

Contadores propios de correctas y fallidas, fixtures propios bajo `tests/runtime/fixtures/`, y directorios de trabajo creados con `mktemp -d` conforme a §11 cuando haga falta escribir. **Veintidós casos.**

**Estructura de la configuración, casos 1 a 12:**

| # | Fixture | Esperado |
|---|---|---|
| 1 | Configuración conforme completa | exit `0` |
| 2 | JSON malformado | exit `1`, señala la comprobación 1 |
| 3 | Sin `hooks.PreToolUse` | exit `1`, comprobación 2 |
| 4 | Matcher sin `Bash` | exit `1`, comprobación 3 |
| 5 | Matcher con las cinco entradas en otro orden | exit `1`, comprobación 3, porque es igualdad exacta y no de conjunto |
| 6 | `command` con ruta relativa | exit `1`, comprobación 4 |
| 7 | `command` **inerte** que contiene las cadenas `CLAUDE_PROJECT_DIR` y `exit 2` pero no ejecuta el guard | exit `1`, comprobación 4 |
| 8 | `command` canónico con un espacio de más en medio | exit `0`, porque la normalización de espacios es parte del criterio |
| 9 | Guard ausente en el fixture | exit `1`, comprobación 5 |
| 10 | Guard presente sin bit de ejecución en el fixture | exit `1`, comprobación 5 |
| 11 | Una regla `Edit(./...)` | exit `1`, comprobación 6 |
| 12 | Una regla `Write(...)` | exit `1`, comprobación 7 |

**Conjunto exacto de reglas, casos 13 a 16.** Los dos últimos mantienen el total en ocho y **deben fallar igualmente**:

| # | Fixture | Total de reglas | Esperado |
|---|---|---|---|
| 13 | **Falta** una regla: se elimina `Read(/**/*.pem)` | siete | exit `1`, comprobaciones 8 y 9 |
| 14 | **Sobra** una regla: se añade `Edit(/docs/**)` | nueve | exit `1`, comprobaciones 8 y 9 |
| 15 | **Duplicada y ausente**: `Read(/**/.env*)` aparece dos veces y falta `Read(/**/id_rsa*)` | **ocho** | exit `1`, **comprobación 9**, con la comprobación 8 conforme |
| 16 | **Sustituida**: `Edit(/CODEOWNERS)` se cambia por `Edit(/README.md)` | **ocho** | exit `1`, **comprobación 9**, con la comprobación 8 conforme |

**Comportamiento del comando canónico, casos 17 a 22.** El test **ejecuta** el comando con `CLAUDE_PROJECT_DIR` apuntando a fixtures y comprueba el código resultante:

| # | Fixture | Esperado |
|---|---|---|
| 17 | Guard de fixture que sale `0` | comando sale **`0`** |
| 18 | Guard de fixture que sale `1` | comando sale **`2`** |
| 19 | Guard de fixture que sale `2` | comando sale **`2`** |
| 20 | Guard **ausente** en el fixture | comando sale **`2`** |
| 21 | Guard presente **sin bit de ejecución** en el fixture | comando sale **`2`** |
| 22 | Raíz de fixture **con un espacio** en el nombre, repitiendo 17 y 19 | comando sale **`0`** y **`2`** respectivamente |

**El hook real nunca se renombra, se sustituye ni pierde permisos durante estas pruebas.** Todos los guards de los casos 17 a 22 son scripts triviales creados dentro del fixture, y el bit de ejecución del caso 21 se manipula sobre el fixture.

**Dos capas, y conviene no confundirlas.** Los casos 17 a 22 miden el **comando** y **son reproducibles por CI**. Las sondas de §5a miden **Claude Code** y no lo son. La primera capa demuestra la aritmética del fail-closed; la segunda, que el runtime la aplica.

### 4. `ci.yml` — un paso nuevo mínimo, cero lógica duplicada

En el job **`gobierno`** —`name: Gobierno FDA`—, inmediatamente después del paso «El hook guard.sh es ejecutable», se añade un paso que **invoca** el script versionado y nada más:

```yaml
      - name: Configuración del runtime fail-closed (preflight)
        run: bash tests/runtime/check-config.sh
```

**Invariantes:** la lógica **no se replica** dentro del YAML, que es la lección de WP-006 ya aprendida y pagada; **no se añade ninguna acción ni dependencia**, porque `bash` y `python3` ya están en el runner y `python3` ya se configura en ese job; **no se toca ningún otro job, paso ni workflow**; y **no se modifica el ruleset**, porque el paso hereda el carácter obligatorio de `Gobierno FDA`, que ya es check bloqueante. El preflight bloquea desde el primer día sin tocar la configuración de GitHub.

Los demás scripts de este WP **no** se añaden a CI: el contrato autoriza **un** paso nuevo. Se ejecutan en local como comandos de validación y sus salidas son evidencia.

### 5. Runner y matriz empírica

#### 5a. tests/runtime/runner-empirico.sh — el runner empírico headless

Las sondas empíricas son **verificación y evidencia obligatoria** del WP. Por `ADR-001` I2 e I3 no admiten intervención ni juicio visual: un veredicto que exige que alguien mire una pantalla no es un veredicto. Todas viven en un **único runner versionado**.

**Interfaz:**

```bash
bash tests/runtime/runner-empirico.sh [--salida RUTA] [--solo NOMBRE_SONDA]
```

Sin `--solo` ejecuta las **catorce sondas lógicas**. Sin `--salida` crea el directorio de salida con `mktemp -d`, sujeto a §11. **Sin TTY, sin prompts y sin ninguna decisión humana.**

**Salida fuera del repositorio, siempre.** El runner escribe **todos** sus crudos, flujos y resultados en el directorio de salida, que está **fuera del repositorio real**. **Rechaza con exit `2`** cualquier `--salida` que resuelva físicamente dentro de él. Imprime la ruta física empleada, que **se conserva hasta `C_EVIDENCIA`**. **No crea ni modifica `evidence/WP-008/**` durante la medición.**

**Tres niveles, que no deben confundirse.** Una **sonda lógica** es uno de los catorce elementos contratados. Una sonda lógica puede descomponerse en varias **subsondas**, y cada subsonda se resuelve con una o más **invocaciones físicas** de `claude -p`. El runner registra los **tres recuentos** por separado.

**Comprobación de entorno previa, antes de cualquier sonda.** El runner ejecuta un **control neutral por herramienta** sobre un fixture **sin hooks y sin reglas `deny`**, donde toda operación dentro de alcance debe quedar **permitida**.

1. **Inventario efectivo.** Una invocación **sin `--tools`** obtiene el catálogo real de la sesión en el evento `system/init`.
2. **Las cuatro obligatorias.** `Edit`, `Write`, `NotebookEdit` y `Bash` **deben** figurar en ese catálogo **y** superar una operación neutral equivalente en el fixture. La **ausencia de cualquiera de las cuatro es error de entorno**, con exit `2`, y **nunca** se registra como `legacy no disponible`.
3. **La única legacy.** **Solo `MultiEdit`** puede registrarse como `legacy no disponible`.
4. **Combinaciones.** Toda sonda que use una combinación —por ejemplo `Bash` para desplazarse y después `Write` para escribir— tiene su **propio control neutral con esa misma combinación mínima**.
5. **Desempate ante un fallo.** Si una sonda falla, o queda bloqueada de forma inesperada, el runner **ejecuta o consulta el control neutral equivalente** antes de emitir veredicto: si el control neutral pasa, la no conformidad es del fixture; si el control neutral también falla, hay **interferencia externa** y el runner para con **error de entorno**.
6. **Capa no excluible.** `--setting-sources project` excluye `user` y `local`, pero **no puede excluir los ajustes gestionados ni los flags de la propia CLI**. Cualquier **hook inesperado o restricción gestionada** que altere la capacidad medida produce **exit `2` por error de entorno**, y el resultado **no se atribuye al fixture**.

**Forma de cada invocación física:**

```bash
claude -p "<instrucción de la subsonda>" \
  --output-format stream-json --verbose --include-hook-events \
  --setting-sources project \
  --tools "<conjunto mínimo disponible>" \
  --allowedTools "<allowlist mínima completa de la subsonda>" \
  --max-turns 3 \
  --max-budget-usd 0.30
```

- **`--setting-sources project`** carga la configuración del fixture y excluye `user` y `local`. No excluye los ajustes gestionados, y por eso existe la comprobación de entorno previa.
- **`--tools`** reduce el conjunto disponible al mínimo de esa subsonda. La **subsonda de inventario** de C2 es la excepción: se invoca **sin `--tools`**.
- **`--allowedTools` explícito por CLI** y no los `allow` del fixture: la documentación oficial establece que en modo `-p` **no aparece el diálogo de confianza y las reglas `allow` del proyecto siguen ignoradas**. `deny` y `ask` no se ven afectadas, y **la precedencia del hook se mantiene**: una regla `allow` retira la petición de permiso, pero el hook `PreToolUse` se ejecuta igual y su `exit 2` bloquea la llamada.
- **Allowlist mínima completa.** Una sonda que necesite más de una herramienta declara **expresamente** su allowlist mínima completa en `matriz-empirica.md`, y el runner la aplica tal cual.

**Cómo decide el veredicto, sin intervención.** Para cada subsonda el runner exige que aparezca la **llamada de herramienta esperada** y clasifica: `BLOQUEADO` si la impidió el control aplicable —el hook `PreToolUse` para las herramientas incluidas en su matcher, o una regla `permissions.deny` para la lectura de C6—, y `PERMITIDO` si se ejecutó. **Si la llamada esperada no aparece, si aparece una llamada de herramienta inesperada, o si los eventos no permiten decidir automáticamente, la subsonda cuenta como fallida.** No existe la categoría de resultado no concluyente que pasa.

**Uso de los eventos de hook.** C1 a C5, y la propia C7, exigen un **ciclo de hook `PreToolUse` completo**, procesable y asociado a su llamada decisiva **conforme al esquema y a la regla de asociación de §5c, que son contractuales**: no se admite ninguna otra forma de asociar. **C6 es la excepción explícita:** su llamada decisiva es `Read`, herramienta que no pertenece al matcher contractual, y el bloqueo lo emite `permissions.deny`; por tanto, para esa llamada **no se espera ni se exige** ciclo de hook alguno. En la subsonda de C6 posterior a `cd`, el **único** ciclo exigido es el de la llamada `Bash` inicial, asociado a esa misma llamada por ventana de orden: acredita que el cambio de directorio atravesó el hook, y **no sustituye** al `tool_result` de error de `Read`, que es el que decide la denegación.

**Entradas del matcher no expuestas.** Una entrada del matcher ausente del inventario de C2 se registra como **`legacy no disponible`**. No es una subsonda fallida, no resta de las conformes y no bloquea el WP.

**Límites de turnos y de coste.** `--max-turns 3` y `--max-budget-usd 0.30` **por invocación física**. El runner acumula el `total_cost_usd` de cada resultado y, **antes de lanzar la siguiente invocación**, comprueba que el acumulado más el tope de esa invocación no supera **5,00 USD**; si lo superase, **aborta con exit `2` sin lanzarla**. Con el tipo congelado de agosto de 2026, 5,00 USD son unos 4,34 EUR: alrededor del once por ciento del presupuesto del WP. La aplicación del tope de coste requiere Claude Code 2.1.217 o posterior.

**Integridad del repositorio: cinco magnitudes.** El runner las mide antes y después y **falla si difiere cualquiera**:

1. `git status --porcelain=v1 -z -uno` — estado **rastreado y staged**, sin enumerar nada sin versionar
2. SHA-256 de `git diff --binary`
3. SHA-256 de `git diff --cached --binary`
4. Huella agregada del propio runner y de sus fixtures, definida abajo
5. Huella y modo de `.claude/hooks/guard.sh`

**Definición de la magnitud 4.** El digest cubre, para **cada archivo** de `tests/runtime/**` y para `evidence/WP-008/parche/aplicar.sh`, tres cosas: su **ruta relativa canónica a la raíz del repositorio**, su **modo y permisos**, y el **SHA-256 de sus bytes**. La enumeración se ordena con `LC_ALL=C sort` y se delimita con NUL, de modo que el resultado sea estable ante espacios, saltos de línea en nombres y diferencias de locale. Hashear solo los contenidos, sin rutas ni modos, produce otro valor y **no es esta huella**. La enumeración está **restringida a esas dos rutas** y **no lee ni incluye** `.agents/`, `.codex/` ni `AGENTS.md`.

**Qué comprueba esta combinación y qué no.** Las cinco magnitudes cubren el **estado rastreado y staged** y las **rutas nominales** de este WP. **No intentan inventariar archivos sin versionar ajenos**, y no deben presentarse como si lo hicieran. Es una renuncia deliberada: enumerar lo no versionado alcanzaría la cuarentena de `DEC-003` §8.

En ningún momento el runner renombra, sustituye, borra ni retira el permiso al hook real. Solo usa fixtures y directorios temporales conforme a §11.

**Resultado agregado y código de salida.** Una línea por sonda y, al final, la composición completa. **Exit `0`** exige exactamente **14 sondas lógicas ejecutadas · 13 conformes · 1 `REGISTRADA_FUERA_DE_CONTRATO` · 0 no conformes**, y ausencia de errores de entorno. La única `REGISTRADA_FUERA_DE_CONTRATO` es la del **caso (b)**. **Exit `1`** si alguna sonda es no conforme o no decidible, o si la composición difiere. **Exit `2`** ante error de argumentos, de entorno, de directorio de salida, de integridad, o por alcanzar el tope agregado de coste.

**Incorporación de evidencias, solo después.** Con el runner en `0`, y **únicamente durante la preparación de `C_EVIDENCIA`**, el agente incorpora a `evidence/WP-008/empirico/` artefactos **derivados y saneados**. **Nunca se versiona el flujo `stream-json` crudo completo**, ni prompts o respuestas íntegras, ni ningún contenido que vulnere `SEC-001`. `empirico/runner.log` es el **resumen saneado** del runner, no una copia de los crudos.

**Headless no es lo mismo que reproducible en CI.** El runner **es headless**: no pregunta, no asume TTY y emite un código de salida significativo. **No es reproducible en los runners de CI**, porque estos no ejecutan Claude Code, y por eso no se añade a `ci.yml`. El operador lo lanza en local, pero **no interactúa con él y no decide el veredicto**: lo decide el propio runner.

**Red.** Este runner es la única parte del WP autorizada a alcanzar el servicio de Claude. La otra excepción de red es `capturar-ci-rojo.sh` en sus modos de adquisición, con `gh` en solo lectura. Todos los controles deterministas restantes se ejecutan **sin red**.

#### 5b. Matriz empírica de siete contextos

**Contrato de lanzamiento soportado.** Claude Code se inicia **en la raíz del repositorio**. De ahí se derivan dos casos que no deben confundirse:

| Caso | Descripción | Estado |
|---|---|---|
| **(a)** | Sesión **iniciada en la raíz** y desplazada después con `cd` a un subdirectorio | **Soportado.** Debe bloquear, y se demuestra |
| **(b)** | Sesión **nueva iniciada directamente en un subdirectorio** | **Fuera del contrato de lanzamiento de la FDA.** Se mide y se registra; no es criterio de aceptación |

El caso (b) **no se presenta como una limitación del runtime**: queda **fuera del contrato de lanzamiento de la FDA**, que es una decisión operativa de esta fábrica. Este WP **no convierte el inicio directo en un subdirectorio en garantía contractual**: no lo declara soportado, no lo somete a criterio de aceptación y no promete nada sobre él.

La sonda **mide y registra el comportamiento real que observe**, sin presuponer nada sobre qué configuración se carga en ese contexto ni sobre cómo se descubre. Su resultado se clasifica como `REGISTRADA_FUERA_DE_CONTRATO` y alimenta la nota operativa del manual.

`docs/manual/07-troubleshooting.md` exige arrancar en la raíz **por contrato operativo de la FDA** —para que el WP activo, las rutas ancladas y la invocación del hook se resuelvan siempre contra la misma raíz, y para que cualquier medición sea comparable entre sesiones—, y **no** por ninguna carencia atribuida a Claude Code.

Cada contexto es una **sonda lógica del runner de §5a**, especificada en `tests/runtime/matriz-empirica.md` junto con su allowlist mínima completa. El runner mide en cada uno el veredicto ante un intento de escritura **fuera** de alcance, cuyo resultado esperado es bloqueo, y ante uno **dentro** de alcance, cuyo resultado esperado es que se permita, y decide ambos de forma automática.

| # | Contexto | Cómo se monta |
|---|---|---|
| 1 | Raíz del proyecto | Fixture de proyecto completo, sesión arrancada en su raíz |
| 2 | **Caso (b): sesión nueva en un subdirectorio** — *fuera del contrato de la FDA* | Sesión arrancada directamente en un subdirectorio del fixture. **Solo registro**: se mide el comportamiento real tal como se observe, se clasifica `REGISTRADA_FUERA_DE_CONTRATO` y no es criterio de aceptación |
| 3 | **Caso (a): `cd` durante la sesión** — soportado | Sesión arrancada en la raíz del fixture y desplazada a un subdirectorio durante la ejecución. **Debe bloquear** |
| 4 | Worktree | `git worktree add` sobre un repositorio **de fixture**, nunca sobre este |
| 5 | Ruta con espacios | Fixture cuya raíz contiene un espacio en el nombre |
| 6 | Hook ausente | Fixture **sin** `.claude/hooks/guard.sh` |
| 7 | Hook sin permiso de ejecución | Fixture con el hook presente y sin bit de ejecución **en la copia del fixture** |

**Reglas de la medición, vinculantes:**

- **Todo sobre fixtures o copias temporales.** En ningún momento se renombra, sustituye, borra ni se retira el permiso de ejecución a `.claude/hooks/guard.sh` **de este repositorio**, ni se altera su `.claude/settings.json` para medir. Las filas 6 y 7 se obtienen construyendo fixtures que ya nacen así.
- **Alcance de la reproducibilidad.** La matriz **es headless** y su veredicto lo emite el runner. **No es reproducible en los runners de CI.** El control reproducible en CI es el **preflight estructural**; el runner empírico es el control headless que demuestra que el runtime aplica lo que el preflight comprueba.
- **Circularidad de arranque, resuelta por orden.** El agente se inicia **en la raíz** y comprueba **en solo lectura** que `.claude/hooks/guard.sh` existe y es ejecutable; implementa **primero** el runner y su especificación; el operador lo ejecuta; y **solo si sale `0`** continúa el resto. La comprobación de alcance de esta PR es además **headless y deliberadamente redundante**: la ejecuta `tests/runtime/check-alcance-wp008.sh`.
- **Resultado esperado y su contrario.** Si la matriz demuestra que el hook **siempre** se ejecutó en los contextos de directorio, se registra que la hipótesis de `DEC-003` §1 **no se materializó** y el WP **se completa igualmente**: el anclaje de la ruta y el bloqueo ante hook ausente o no ejecutable son invariantes de robustez independientes del directorio de trabajo.

#### 5c. Esquema contractual de los eventos de hook y asociación determinista

Los dos ciclos anteriores trabajaron sobre un esquema **sintético e incorrecto**, inventado en las pruebas y nunca verificado contra la salida real. Aquí quedan fijados el esquema **contractual** y la **única** forma admitida de asociar un ciclo de hook a una llamada. El runner lo implementa y `tests/runtime/test-runner-empirico.sh` lo prueba. Si la versión instalada emitiera otra forma, **el WP para** y se solicita decisión: no se adivina, no se relaja y no se infiere por parecido textual.

**Forma de los mensajes.** Con `--include-hook-events`, los mensajes de ciclo de vida del hook aparecen en el flujo `stream-json` con estos campos, comparados por **igualdad exacta**:

| Campo | Valor contractual |
|---|---|
| `type` | `system` |
| `subtype` | `hook_started`, `hook_progress` o `hook_response` |
| `hook_event` | `PreToolUse` |
| `hook_id` | Identificador del ciclo, presente en los tres subtipos |

**Qué forma un ciclo, y qué no.** Un ciclo lo forman **exactamente dos** mensajes: un `hook_started` y un `hook_response` cuyos `hook_id` sean **idénticos carácter a carácter**. **`hook_progress` es opcional e informativo: no es necesario para formar un ciclo**, no lo completa, no lo sustituye y su ausencia no es un defecto; se procesa **solo si aparece**. Un `hook_started` sin su `hook_response`, un `hook_response` sin su `hook_started`, o un par con `hook_id` distintos **no forman ciclo**, y la subsonda que dependiera de él no es conforme.

**Los mensajes de hook NO llevan `tool_use_id`.** Es el hecho que gobierna todo lo demás: ni `hook_started`, ni `hook_progress`, ni `hook_response` contienen el identificador de la llamada. Por tanto **no existe** ninguna igualdad de identificador entre un mensaje de hook y una llamada de herramienta, y construirla —por el medio que sea— es precisamente el error que esta replanificación corrige.

**Las dos igualdades, y la que no existe.**

| # | Igualdad exacta | Qué empareja |
|---|---|---|
| 1 | `tool_use.id` = `tool_result.tool_use_id` | Una llamada con **su** resultado |
| 2 | `hook_started.hook_id` = `hook_response.hook_id` | Los **dos extremos** de un ciclo de hook |

**No hay una tercera.** Entre el ciclo de hook y la llamada **no existe ningún identificador común**, y no debe fabricarse uno.

**Asociación por ventana de orden, y por nada más.** Un ciclo de hook pertenece a una llamada **únicamente** porque aparece **después** del objeto `tool_use` de esa llamada y **antes** de su `tool_result` correspondiente, emparejado por la igualdad 1. `hook_started` y `hook_response` deben quedar **ambos** dentro de esa ventana. Un ciclo entero anterior al `tool_use`, entero posterior al `tool_result`, o con un extremo fuera, **no está asociado**.

**Prohibida la búsqueda dentro del JSON serializado.** Queda **expresamente prohibido** buscar un `tool_use_id`, un comando o una ruta **dentro del JSON serializado** de un mensaje de hook —o de cualquier otra representación textual suya— para decidir la asociación. Además de no ser determinista, busca algo que **no está**. Las colisiones que esa técnica acepta son reales y están probadas abajo: `tu_1` casa dentro de `tu_10`, `cd sub` casa dentro de `cd sub2`, y la ruta del `.env` de la raíz casa dentro de la de `sub/anidado/.env`.

**Identificación estructurada de la llamada.** La llamada concreta se identifica **leyendo campos**, nunca buscando texto:

| Qué | Campo | Comparación |
|---|---|---|
| Herramienta | `tool_use.name` | Igualdad **exacta** de la cadena completa |
| Comando de `Bash` | `tool_use.input.command` | Igualdad **exacta** del valor, tras recortar los extremos y **nada más** |
| Ruta de `Read` | `tool_use.input.file_path` | Igualdad **exacta** de la ruta **canonicalizada físicamente**, contra la del archivo objetivo canonicalizada igual |
| Identificadores | `tool_use.id`, `tool_result.tool_use_id`, `hook_id` | Igualdad **exacta** de la cadena completa. Nunca prefijo, sufijo ni contención |

**Las seis pruebas negativas obligatorias.** Deterministas, sin red, sin coste y sin `claude -p`, sobre flujos sintéticos, en `tests/runtime/test-runner-empirico.sh`:

| # | Prueba negativa | Debe |
|---|---|---|
| 1 | `tu_1` frente a `tu_10`, **en ambas direcciones** | **No emparejar** la llamada con el resultado |
| 2 | `cd sub` frente a `cd sub2`, **en ambas direcciones** | **No identificar** la llamada |
| 3 | `.env` de la raíz frente a `sub/anidado/.env`, **en ambas direcciones** | **No identificar** la llamada |
| 4 | Ciclo **fuera de la ventana**: entero antes del `tool_use`, entero después del `tool_result`, y con un solo extremo fuera | **No asociar** |
| 5 | `hook_started` y `hook_response` con `hook_id` **distintos** | **No formar ciclo** |
| 6 | Mensaje con el **esquema sintético antiguo** —`type` igual a `hook_event`, con `hook_event_name`, `tool_name`, `tool_use_id` y `tool_input`— | **Rechazarlo**: no es un mensaje de ciclo de vida de `--include-hook-events` y no cuenta como `hook_started` ni como `hook_response` |

Cada una **debe dejar no conforme** a la subsonda que dependiera de esa asociación. Un código distinto del esperado hace fallar el test con exit `1`.

**C6 no cambia.** Este apartado fija **cómo** se asocia un ciclo de hook cuando se exige, no **a quién** se le exige. Para la llamada `Read` **no se exige ninguno**, y en `C6.tras-cd` el único ciclo exigido es el de la llamada `Bash` inicial, dentro de la ventana de esa misma llamada.

### 6. El smoke test de capacidades

Especificado en `tests/runtime/smoke-capacidades.md` y **ejecutado por el runner de §5a**, como siete de sus catorce sondas lógicas. **La versión mínima se deriva de las capacidades demostradas, no de la versión observada en una auditoría.**

| # | Capacidad exigida | Cómo se demuestra |
|---|---|---|
| C1 | Los settings de proyecto se cargan al arrancar en la raíz | Una escritura fuera de alcance queda bloqueada en el fixture conforme |
| C2 | El matcher intercepta **todas las herramientas de escritura que el runtime expone** | Sonda lógica con varias **subsondas**: una de **inventario**, que invoca `claude -p` **sin `--tools`** y lee el catálogo real en el evento `system/init`; y después **una subsonda por cada entrada del matcher presente en ese inventario**. Una entrada ausente se registra como **`legacy no disponible`**: no es una subsonda fallida |
| C3 | `CLAUDE_PROJECT_DIR` llega al proceso del hook y vale la raíz | El hook lo imprime con `FDA_GUARD_DEBUG=1` en el fixture |
| C4 | `exit 2` bloquea y `exit 0` permite | Dos fixtures de hook trivial, uno por código |
| C5 | Un código distinto de `0` y de `2` **no** bloquea | Fixture de hook trivial con `exit 1`. Es lo que justifica la normalización de §1a |
| C6 | Una regla anclada con `/ruta` en settings de proyecto resuelve a la raíz del proyecto | Denegación efectiva desde la raíz y tras un `cd` a un subdirectorio. **No se exige ciclo de hook para `Read`**; el único exigido en la subsonda posterior a `cd` es el de la llamada `Bash` inicial |
| C7 | Los eventos de ciclo de vida del hook llegan al flujo procesable | Aparece en la salida `stream-json` con `--include-hook-events` un ciclo con el **esquema contractual de §5c**: un `hook_started` y un `hook_response`, con `type` igual a `system`, `hook_event` igual a `PreToolUse` y el **mismo `hook_id`**, **ambos dentro de la ventana** de su llamada. **`hook_progress` no se exige**: es opcional y solo se procesa si aparece. El runner exige ese ciclo para decidir C1 a C5 y C7. C6 se decide mediante `permissions.deny` sobre `Read`, que queda fuera del matcher y no dispara ese hook |

**Sobre `MultiEdit`.** El catálogo actual de herramientas de la documentación oficial **no incluye `MultiEdit`**: es una entrada **legacy** que las reglas de permiso y los matchers siguen aceptando. La comprobación **estructural** 3 del preflight sigue exigiendo las **cinco** entradas del matcher; el smoke **empírico** prueba solo las que el runtime exponga; si `MultiEdit` no está expuesta, se registra como `legacy no disponible`, **no resta de las 13 conformes** y **no bloquea el WP**; y si la versión medida sí la expusiera, **entonces debe probarse**. **Nada de esto autoriza a eliminarla del matcher ni a modificarlo en WP-008.**

Si alguna capacidad no se demuestra, **el WP para** y se reporta.

### 7. El parche verificado — un solo protocolo, dos fases, tres estados

El agente entrega en `evidence/WP-008/parche/`:

1. `aplicar.sh` — headless, idempotente, sin red y sin prompts.
2. `huellas.sha256` — **cuatro** huellas: `ANTES` y `DESPUES` de `.claude/settings.json`, y `ANTES` y `DESPUES` de `.github/workflows/ci.yml`. Definen **tres estados reconocidos** y **dos fases**.
3. `settings.json.candidato` y `ci.yml.candidato`.
4. `README.md` — los comandos exactos que ejecuta la persona y qué debe ver.

**Es el mismo protocolo de parche verificado que WP-007, extendido a dos archivos y dos fases. No se inventa un segundo.**

#### 7a. Interfaz

```bash
bash evidence/WP-008/parche/aplicar.sh [--root RUTA] rojo|verde
```

Sin `--root` opera sobre el **repositorio real**. Con `--root` opera **exclusivamente** sobre un fixture de proyecto completo. La fase es obligatoria; cualquier otro argumento sale con exit `2`.

#### 7b. Estados reconocidos

| Estado | `.claude/settings.json` | `.github/workflows/ci.yml` | Significado |
|---|---|---|---|
| **S0 — BASE** | `ANTES` | `ANTES` | Punto de partida |
| **S1 — ROJO AUTORIZADO** | `ANTES` | `DESPUES` | Preflight instalado y configuración aún no conforme. **Único estado intermedio autorizado** |
| **S2 — VERDE** | `DESPUES` | `DESPUES` | Estado final |

Cualquier otro par, señaladamente `settings = DESPUES` con `ci = ANTES`, **no es un estado**: es un aborto fail-closed.

#### 7c. Transiciones

| Invocación | Estado de partida | Acción | Salida |
|---|---|---|---|
| `aplicar.sh rojo` | **S0** | S0 a S1 | `APLICADO ROJO (S1)`, exit `0` |
| `aplicar.sh rojo` | **S1** | ninguna | `YA EN ROJO`, exit `0` |
| `aplicar.sh rojo` | cualquier otro | **aborta sin escribir** | `ABORTADO`, exit `2` |
| `aplicar.sh verde` | **S1** | S1 a S2 | `APLICADO VERDE (S2)`, exit `0` |
| `aplicar.sh verde` | **S2** | ninguna | `YA EN VERDE`, exit `0` |
| `aplicar.sh verde` | cualquier otro | **aborta sin escribir** | `ABORTADO`, exit `2` |

El orden no es opcional: `verde` desde S0 y `rojo` desde S2 abortan.

#### 7d. Fase roja — S0 a S1, toca solo `ci.yml`

1. **Instantánea previa, solo rastreado y staged.** Se calculan dos huellas:
   - `H_OTROS_ANTES` = SHA-256 de `git diff --binary -- . ':(exclude).github/workflows/ci.yml'`
   - `H_STAGED_ANTES` = SHA-256 de `git diff --cached --binary`
   Se registra además `git status --porcelain=v1 -z -uno` **como información**, que no sustituye a ninguna de las dos huellas. Ninguna de estas órdenes enumera archivos sin versionar.
2. Calcular las cuatro huellas y exigir **S0**. Si es S1, `YA EN ROJO` y exit `0`. Cualquier otro par, `ABORTADO` y exit `2` **sin escribir**.
3. Crear el directorio temporal conforme a **§11** y copiar allí el `ci.yml` original.
4. **Validar el candidato antes de sustituir**: `validate-workflows.py` sobre un directorio temporal con los tres workflows y el candidato como `ci.yml`, exit `0`. Si falla, aborta **sin haber tocado nada**.
5. Sustituir `.github/workflows/ci.yml`.
6. Validaciones posteriores: huella `CI_DESPUES`; huella de `settings.json` **sigue en `ANTES`**; y la **comprobación propia de la fase**: `bash tests/runtime/check-config.sh` sale **`1`** y señala exactamente las comprobaciones **4** y **6**. Si saliera `0`, la demostración en rojo sería imposible y se aborta.
7. **Comprobación de alcance de la fase, por huellas.** Se recalculan `H_OTROS_DESPUES` y `H_STAGED_DESPUES` con los mismos comandos del paso 1, y deben cumplirse las tres condiciones a la vez:
   - `H_OTROS_DESPUES` es **idéntica** a `H_OTROS_ANTES`: ningún otro contenido rastreado cambió
   - `H_STAGED_DESPUES` es **idéntica** a `H_STAGED_ANTES`: el índice no se tocó
   - `.github/workflows/ci.yml` pasó de `CI_ANTES` a `CI_DESPUES`
   La exclusión por `pathspec` es lo que hace válida la comparación **aunque ya existieran otros cambios del WP antes de empezar la fase**.
8. Ante cualquier fallo posterior a la sustitución, restaurar `ci.yml`, verificar que el par vuelve a **S0**, imprimir `ROLLBACK APLICADO` y salir con código distinto de cero.
9. Si todo pasa: `APLICADO ROJO (S1)` y exit `0`.

#### 7e. Fase verde — S1 a S2, toca solo `settings.json`

1. **Instantánea previa, solo rastreado y staged.** Se calculan dos huellas:
   - `H_OTROS_ANTES` = SHA-256 de `git diff --binary -- . ':(exclude).claude/settings.json'`
   - `H_STAGED_ANTES` = SHA-256 de `git diff --cached --binary`
   Se registra además `git status --porcelain=v1 -z -uno` **como información**.
2. Calcular las cuatro huellas y exigir **S1**. Si es S2, `YA EN VERDE` y exit `0`. Cualquier otro par, `ABORTADO` y exit `2` **sin escribir**.
3. Crear el directorio temporal conforme a **§11** y copiar allí el `settings.json` original.
4. **Validar el candidato antes de sustituir**: `python3 -m json.tool` y `bash tests/runtime/check-config.sh <candidato> <raíz>` con exit **`0`**. Si falla, aborta **sin haber tocado nada**.
5. Sustituir `.claude/settings.json`.
6. Validaciones posteriores: huella `SETTINGS_DESPUES`; huella de `ci.yml` **sigue en `DESPUES`**; `bash tests/runtime/check-config.sh` con exit **`0`**; `bash tests/runtime/test-check-config.sh` con exit `0`.
7. **Comprobación de alcance de la fase, por huellas.** `H_OTROS_DESPUES` idéntica a `H_OTROS_ANTES`; `H_STAGED_DESPUES` idéntica a `H_STAGED_ANTES`; y `.claude/settings.json` pasó de `SETTINGS_ANTES` a `SETTINGS_DESPUES`.
8. Ante cualquier fallo posterior a la sustitución, restaurar `settings.json`, verificar que el par vuelve a **S1** y no a S0, imprimir `ROLLBACK APLICADO` y salir con código distinto de cero.
9. Si todo pasa: `APLICADO VERDE (S2)` y exit `0`.

#### 7f. Dónde van las copias de seguridad y los logs

**Las copias de seguridad viven fuera del repositorio, y eso se garantiza por construcción, no por inventario.** `aplicar.sh` crea la copia **exclusivamente** en el directorio temporal de §11, y **registra en el log su ruta física**. La ausencia de copias dentro del repositorio se demuestra con tres cosas, y ninguna enumera lo no versionado:

1. **Construcción:** la única ruta de escritura de la copia es ese directorio temporal, y así se lee en el script.
2. **Pruebas de fixture, por instantánea completa:** `test-protocolo.sh` calcula, **antes** de cada fase sobre `--root`, una instantánea **NUL-safe de todas las entradas situadas dentro de la raíz física del fixture, excluyendo por completo `.git/**`**, porque los comandos de Git pueden actualizar metadatos internos aunque no cambie el contenido del proyecto. Por entrada registra **ruta relativa**, **tipo** y **modo**; para **archivos regulares**, el **SHA-256 de sus bytes**; para **enlaces simbólicos**, además el **destino literal** del enlace. Después de la fase calcula la misma instantánea. Deben cumplirse las tres condiciones a la vez:
   - **Excluyendo `.git/**` y únicamente el archivo objetivo de esa fase**, ambas instantáneas son **idénticas**.
   - El **archivo objetivo** cambió **exactamente** de su huella contractual de origen a la de destino.
   - **No aparece ni desaparece ninguna otra ruta** dentro del fixture: ni copias, ni logs, ni temporales.
   La enumeración es admisible porque se limita a un **fixture temporal controlado** y **nunca alcanza el repositorio real ni su cuarentena**.
3. **Huella staged:** `H_STAGED` permanece idéntica durante toda la fase, de modo que **nada entró en el índice**.

**No se afirma que se haya inventariado globalmente lo no versionado**, porque hacerlo alcanzaría la cuarentena de `DEC-003` §8.

**Los logs de las dos fases reales tampoco se escriben dentro del repositorio mientras la fase corre.** Escribirlos en `evidence/WP-008/` produciría una segunda ruta modificada y rompería la comprobación de alcance de la propia fase. Por tanto: `aplicar.sh` genera su log **en el directorio temporal de la fase**; el log incluye el código de salida, las cuatro huellas antes y después, las validaciones ejecutadas y la ruta física del directorio; los directorios **se conservan hasta llegar a S2**; y los logs se incorporan a `evidence/WP-008/parche/` **únicamente después** de que `C_VERDE` esté publicado y verde, durante la preparación de `C_EVIDENCIA`.

Los logs de las **pruebas negativas y de los rollbacks sobre fixtures** sí pueden prepararse antes, porque no modifican los archivos reales.

#### 7g. `tests/runtime/test-protocolo.sh` — la máquina de estados, probada sobre copias

Prueba headless, con contadores propios, sin red, sin prompts y sin TTY. Construye fixtures de proyecto completo y ejercita **toda** la máquina S0, S1 y S2 mediante `aplicar.sh --root`. **Doce escenarios.**

| # | Escenario sobre fixture | Esperado |
|---|---|---|
| 1 | `rojo` desde S0 | S1, `APLICADO ROJO (S1)`, exit `0` |
| 2 | `rojo` repetido en S1 | `YA EN ROJO`, exit `0`, sin cambios |
| 3 | `verde` desde S1 | S2, `APLICADO VERDE (S2)`, exit `0` |
| 4 | `verde` repetido en S2 | `YA EN VERDE`, exit `0`, sin cambios |
| 5 | `verde` desde S0 | `ABORTADO`, exit `2`, sin escribir |
| 6 | `rojo` desde S2 | `ABORTADO`, exit `2`, sin escribir |
| 7 | Par invertido: `settings = DESPUES` con `ci = ANTES` | `ABORTADO`, exit `2`, sin escribir, en las dos fases |
| 8 | Estado desconocido: un tercer contenido en cualquiera de los dos archivos | `ABORTADO`, exit `2`, sin escribir |
| 9 | Fallo provocado tras sustituir en la fase roja | `ROLLBACK APLICADO`, exit distinto de cero, par restaurado a **S0** |
| 10 | Fallo provocado tras sustituir en la fase verde | `ROLLBACK APLICADO`, exit distinto de cero, par restaurado a **S1** |
| 11 | Alcance de la fase roja | Instantánea del fixture idéntica salvo `ci.yml`, y huellas `H_OTROS` y `H_STAGED` invariantes |
| 12 | Alcance de la fase verde | Instantánea del fixture idéntica salvo `settings.json`, y huellas `H_OTROS` y `H_STAGED` invariantes |

Las comprobaciones de instantánea de §7f y las de directorio temporal de §11 se integran **como subcomprobaciones de estos doce escenarios** —señaladamente 1, 3, 9, 10, 11 y 12—. **El total permanece en doce.**

**El failpoint de los escenarios 9 y 10** es determinista y está documentado en el `README.md` del parche. Se activa con una variable de entorno y **solo** cuando `--root` apunta a un fixture que contiene el marcador `.fda-fixture` en su raíz. Si se intenta activar sin `--root`, o contra una raíz sin ese marcador, `aplicar.sh` **rechaza con exit `2` sin escribir nada**. El repositorio real no lleva ese marcador y no puede llevarlo.

#### 7h. Las cuatro ejecuciones reales

Sobre los dos archivos reales, la persona ejecuta **exactamente cuatro** invocaciones y ninguna más:

1. `aplicar.sh rojo` sobre **S0**.
2. `aplicar.sh rojo` de nuevo en **S1**, para la evidencia de idempotencia.
3. `aplicar.sh verde` sobre **S1**.
4. `aplicar.sh verde` de nuevo en **S2**, para la evidencia de idempotencia.

**No se crean estados inválidos deliberadamente en los dos archivos reales.** Los abortos, los pares invertidos, los estados desconocidos y los rollbacks se demuestran **sobre fixtures**, con `--root`.

### 8. Los contratos documentales afectados, uno a uno

| Archivo | Qué queda falso sin tocarlo | Cambio mínimo |
|---|---|---|
| `docs/manual/07-troubleshooting.md` | Su apartado de avisos de reglas de permiso **prescribe** las cuatro reglas `Edit(./...)`, que la documentación oficial ancla al directorio actual. Su apartado sobre el hook que no bloquea no menciona el preflight ni el fail-closed nuevo | Corregir el bloque de reglas a la forma anclada; añadir el diagnóstico del preflight, el aviso de sobre-bloqueo por normalización y la exigencia de arrancar en la raíz **como contrato operativo de la FDA**, sin atribuirla a ninguna carencia del runtime |
| `docs/manual/02-ciclo-de-un-wp.md` | Su Paso 6 enumera qué comprueba `Gobierno FDA` y el preflight no está en la lista | Añadir la configuración del runtime fail-closed a esa celda |
| `docs/manual/MANUAL.md` | Su tabla dice tres controles deterministas y el preflight es un cuarto, bloqueante | Añadir una fila con el preflight, su ubicación y qué impide |
| `docs/manual/04-agentes.md` | Su apartado sobre los controles que no dependen del prompt contradiría a `MANUAL.md`, que pasa a cuatro. Y su tabla de límites cita una regla con prefijo `./` como forma de una ruta anclada al proyecto | Pasar la sección a **cuatro** controles, y corregir esa regla a la forma anclada |
| `docs/manual/01-instalacion.md` | Su Paso 2 enseña un ejemplo de `deny` con prefijo `./` para toda instalación nueva | Corregir el ejemplo a la forma anclada |
| `docs/02-guia-fabrica-desarrollo-agentica.md` §3 | Su `settings.json` de ejemplo muestra reglas con prefijo `./`, un matcher **incompleto** y una invocación **relativa** del hook. Es la especificación vinculante del sistema | Reglas sin `./`; **matcher real completo** de cinco entradas; invocación **anclada y fail-closed** |
| `specs/requirements/SEC-001-sin-secretos.md` | Su criterio 4 enumera literalmente las cuatro reglas con prefijo `./` y su tabla las da por operativas | Criterio 4 con las **cuatro** reglas reancladas; tabla: **4 reglas activas**, ancladas a la raíz del proyecto |

**Los tres archivos restantes de `docs/manual/` —`03`, `05` y `06`— quedan prohibidos**, y `05-bloqueos-y-parada.md` con una razón adicional: `DEC-003` §7 registra que ya tiene cambios pendientes en el worktree congelado de WP-007.

### 9. `tests/runtime/capturar-ci-rojo.sh` — los comprobadores de las barreras

La composición de los runs la valida un script versionado, no una persona. **Formas de invocación admitidas, y ninguna otra combinación ni orden:**

```bash
bash tests/runtime/capturar-ci-rojo.sh RUN_ID C_ROJO [DIRECTORIO_SALIDA]
bash tests/runtime/capturar-ci-rojo.sh --verde RUN_ID C_VERDE [DIRECTORIO_SALIDA]
bash tests/runtime/capturar-ci-rojo.sh --validar ARCHIVO_JSON C_ROJO
bash tests/runtime/capturar-ci-rojo.sh --fixture-root RUTA RUN_ID C_ROJO [DIRECTORIO_SALIDA]
bash tests/runtime/capturar-ci-rojo.sh --fixture-root RUTA --verde RUN_ID C_VERDE [DIRECTORIO_SALIDA]
```

#### 9a. Modo de adquisición

- Usa `gh` **exclusivamente en lectura**.
- **Rechaza con exit `2` un directorio de salida no conforme ANTES de invocar `gh`**: la comprobación de rutas precede a todo acceso a la red.
- Sin `DIRECTORIO_SALIDA` lo crea conforme a **§11**, e imprime su ruta física, que se conserva hasta `C_EVIDENCIA`.
- Espera mediante **polling**, con un **tiempo máximo explícito y contractual de 20 minutos** y un intervalo de 15 segundos. **No existe la espera indefinida.**
- Si el tiempo máximo expira sin que el run haya terminado, **sale con exit `2`**.
- Guarda la respuesta de `gh` **fuera del repositorio** y llama al **validador puro**, propagando su código de salida.

#### 9b. Modo `--validar`

- **No usa red** y **no recibe directorio de salida**.
- Recibe un JSON ya adquirido y el hash `C_ROJO`.
- Valida las ocho condiciones de §9c y devuelve `0`, `1` o `2` según el contrato común.

#### 9c. Las ocho validaciones del run rojo

| # | Validación |
|---|---|
| 1 | El run ha **terminado** |
| 2 | `headSha` es igual a `C_ROJO` |
| 3 | `conclusion` es `failure`, y **nunca** `cancelled` |
| 4 | En `Gobierno FDA`, los pasos **anteriores** al preflight están en `success` |
| 5 | El paso del **preflight** está en `failure` |
| 6 | Los pasos **posteriores del mismo job** están en `skipped` |
| 7 | Los **demás jobs** del workflow están en `success` |
| 8 | **No existe una segunda causa de fallo** en todo el run |

**Códigos de salida, comunes a todos los modos:** **`0`** solo cuando la composición es exacta; **`1`** ante composición no conforme; **`2`** ante argumentos inválidos, entorno inválido, JSON malformado, respuesta de `gh` inutilizable, directorio de salida no conforme o expiración del tiempo máximo.

**La persona únicamente lanza el comprobador.** No interpreta la salida de `gh` y no emite el veredicto.

#### 9d. `tests/runtime/test-capturar-ci-rojo.sh` — diecinueve casos

Headless, **sin red**, con contadores propios, sobre respuestas de `gh` **grabadas** en `tests/runtime/fixtures/ci/`.

```bash
bash tests/runtime/test-capturar-ci-rojo.sh
```

**Casos 1 a 12: el modo puro `--validar`.** Los diez negativos cubren, una a una, las ocho validaciones:

| # | Fixture | Validación que debe bloquear | Esperado |
|---|---|---|---|
| 1 | JSON completamente conforme | — | exit **`0`** |
| 2 | Run **no terminado** | 1 | exit `1` |
| 3 | `headSha` incorrecto | 2 | exit `1` |
| 4 | `conclusion` igual a `success` | 3 | exit `1` |
| 5 | `conclusion` igual a `cancelled` | 3 | exit `1` |
| 6 | Un paso **anterior** al preflight distinto de `success` | 4 | exit `1` |
| 7 | Preflight distinto de `failure` | 5 | exit `1` |
| 8 | Un paso **posterior** del mismo job distinto de `skipped` | 6 | exit `1` |
| 9 | Otro job distinto de `success` | 7 | exit `1` |
| 10 | **Segunda causa de fallo** en el run | 8 | exit `1` |
| 11 | JSON malformado o inutilizable | — | exit **`2`** |
| 12 | Argumentos inválidos | — | exit **`2`** |

**Casos 13 a 16: la envoltura de adquisición**, en `modo=fixture` mediante `--fixture-root` y la costura de §9e, **sin red en ningún caso**:

| # | Escenario | Esperado |
|---|---|---|
| 13 | **Rechazos de la costura y de las rutas**, con trece subcomprobaciones nombradas | exit **`2`** en las trece, y en las trece el test demuestra que **ni el stub ni el `gh` real llegaron a ejecutarse** |
| 14 | Stub que entrega primero un estado **no terminado** y después una composición **conforme** | exit **`0`**, demostrando polling, persistencia externa, delegación al validador y `modo=fixture` en el log |
| 15 | Fallo del stub, o respuesta de adquisición inutilizable | exit **`2`** |
| 16 | **Expiración del tiempo máximo**, con el stub devolviendo siempre estado no terminado y `FDA_CI_TEST_TIMEOUT_SECONDS` reducido, **sin espera real prolongada** | exit **`2`** |

**Subcomprobaciones del caso 13.** El caso sigue siendo **uno**; cada subcomprobación tiene nombre propio en la salida:

| Nombre | Escenario |
|---|---|
| `salida-dentro-del-repo` | Directorio de salida que resuelve físicamente dentro del repositorio real |
| `salida-symlink-al-repo` | Directorio de salida que es un **enlace simbólico** y resuelve dentro del repositorio real |
| `salida-inexistente` | Directorio de salida **proporcionado pero inexistente**: se rechaza y **no se crea** |
| `tmpdir-dentro-del-repo` | `TMPDIR` apunta dentro del repositorio real, de modo que el directorio creado por `mktemp -d` quedaría dentro: se rechaza conforme a §11 |
| `real-con-gh` | `FDA_CI_TEST_GH` presente en adquisición **real** |
| `real-con-interval` | `FDA_CI_TEST_INTERVAL_SECONDS` presente en adquisición **real** |
| `real-con-timeout` | `FDA_CI_TEST_TIMEOUT_SECONDS` presente en adquisición **real** |
| `fixture-variable-ausente` | Modo fixture con una de las tres variables ausente |
| `duracion-invalida` | Duración no numérica, cero o negativa |
| `raiz-dentro-del-repo` | Raíz de fixture que canonicaliza dentro del repositorio real |
| `marcador-ausente` | Raíz sin `.fda-fixture`, o con un `.fda-fixture` que no es archivo regular |
| `marcador-symlink` | `.fda-fixture` es un **enlace simbólico**, aunque su destino sea un archivo regular |
| `stub-fuera-o-symlink` | Stub situado fuera de la raíz física del fixture, o enlace simbólico hacia un ejecutable externo |

**Casos 17 a 19: el modo `--verde`**, también en `modo=fixture` y sin red:

| # | Escenario | Esperado |
|---|---|---|
| 17 | Adquisición verde por stub: primero **no terminado** y después **`success` conforme** | exit **`0`** |
| 18 | Verde terminado con **`headSha` incorrecto** | exit **`1`** |
| 19 | Verde terminado con **conclusión distinta de `success`** | exit **`1`** |

El test termina en **exit `0`** con **19 correctas y 0 fallidas**. La invocación **real** de `capturar-ci-rojo.sh`, en cualquiera de sus dos modos de adquisición, no forma parte de la batería de validación: vive **exclusivamente en la cronología**.

#### 9e. La costura de pruebas: nombres, modo y rechazo en producción

Los casos que ejercitan la envoltura de adquisición usan una **costura explícita** con tres nombres contractuales:

```
FDA_CI_TEST_GH                 ejecutable de gh que debe invocarse
FDA_CI_TEST_INTERVAL_SECONDS   intervalo de polling
FDA_CI_TEST_TIMEOUT_SECONDS    tiempo máximo de espera
```

**Solo se aceptan** cuando la invocación incluye el modo explícito `--fixture-root RUTA`, **la raíz está fuera del repositorio real** y **contiene el marcador `.fda-fixture`**.

Reglas obligatorias, sin excepción. **Toda la validación es física, sobre rutas canonicalizadas, no textual:**

- **En adquisición real** —sin `--fixture-root`—, la presencia de **cualquiera** de las tres variables produce **exit `2` antes de ejecutar `gh`**.
- **Raíz del fixture.** Se canonicaliza físicamente y **debe quedar fuera de la raíz física del repositorio**. Una raíz dentro, o que resuelva dentro tras seguir enlaces, sale **`2`**.
- **Marcador.** `.fda-fixture` debe ser un **archivo regular** situado en la raíz canonicalizada **y además no ser un enlace simbólico**: `test ! -L` debe ser cierto sobre él. Su ausencia, que no sea archivo regular, o que sea un enlace simbólico, sale **`2`**.
- **Stub.** `FDA_CI_TEST_GH` debe ser un **archivo regular ejecutable** y **no un enlace simbólico**. Su **ruta física** debe quedar **contenida dentro de la raíz física del fixture**. Un stub fuera del fixture, o un enlace simbólico hacia un ejecutable externo, sale **`2`**.
- **Duraciones.** Ambas deben ser enteros positivos. No numéricas, cero o negativas salen **`2`**. La ausencia de cualquiera de las tres variables en modo fixture sale **`2`**.
- **Directorio de salida, cuando se proporciona.** Debe **existir previamente**, ser un **directorio real**, **no ser un enlace simbólico**, y su **ruta física** debe quedar **fuera del repositorio real**. Un directorio inexistente, un enlace simbólico, o una ruta que resuelva dentro del repositorio, salen **`2`**.
- **Directorio de salida, cuando no se proporciona.** Se crea conforme a **§11**.
- **Nunca se crea primero una ruta proporcionada por el llamante para poder canonicalizarla.** Si no existe, se rechaza; no se materializa para inspeccionarla.
- **Orden.** Todas las comprobaciones del fixture, del marcador, del stub y del directorio de salida ocurren **antes** de ejecutar el stub y **antes** de cualquier acceso a la red.
- El log registra **inequívocamente** `modo=real` o `modo=fixture` en su primera línea.
- **Una captura admisible como evidencia real solo puede proceder de `modo=real`.**

#### 9f. Modo `--verde`

Verifica el run de `C_VERDE` con el mismo rigor headless que el rojo, **reutilizando el polling acotado a 20 minutos** y las mismas reglas de directorio de salida y de costura. Comprueba **tres** condiciones:

| # | Validación |
|---|---|
| 1 | El run ha **terminado** |
| 2 | `headSha` es igual a `C_VERDE` |
| 3 | `conclusion` es `success` |

Devuelve **`0`** si es conforme; **`1`** si el run terminó pero la composición no es conforme; **`2`** ante argumentos, entorno, adquisición inutilizable o expiración del tiempo máximo.

**Por qué existe.** Sin él, una sesión de agente o el empujón de `C_EVIDENCIA` podrían llegar **antes** de que el run verde acabe: la concurrencia del workflow lo cancelaría y se perdería la evidencia verde. **La persona lanza el modo `--verde` y no interpreta su salida.** El contrato de parada es exacto:

- **Exit `1` — el run terminó pero no es conforme.** **Parar.** No se reabre ninguna sesión de agente, no se prepara `C_EVIDENCIA`, no se empuja nada, no hay `amend`, `rebase` ni force-push. Se **solicita decisión humana**. El contrato **no autoriza automáticamente** ni relanzar el run en GitHub ni reiniciar la rama o la PR.
- **Exit `2` por expiración del tiempo máximo, por adquisición inutilizable o por entorno inválido.** **Parar** y **solicitar decisión humana**. Solo podrá repetirse la comprobación —que es de **solo lectura**— sobre **el mismo `RUN_ID` y el mismo `C_VERDE`** si la persona lo autoriza expresamente.
- **En ningún caso** se crea un commit adicional ni se altera la cadena `C_ROJO` a `C_VERDE` a `C_EVIDENCIA` por iniciativa del agente.

### 10. `tests/runtime/check-alcance-wp008.sh` — comprobaciones locales de conformidad de WP-008

Dos responsabilidades, ambas **específicas de este WP**, ambas locales y redundantes, y ninguna genérica.

```bash
bash tests/runtime/check-alcance-wp008.sh [--lista ARCHIVO_NUL]
bash tests/runtime/check-alcance-wp008.sh --cuarentena
bash tests/runtime/check-alcance-wp008.sh --cuarentena --lista-scripts ARCHIVO_NUL
```

#### 10a. Modo de alcance

Sin argumentos toma las rutas de `git diff --name-only -z main...HEAD`. Con `--lista` toma una lista **delimitada por NUL** de un archivo, lo que permite ejercitarlo de forma determinista sin depender de un diff real.

Compara **cada** ruta con la lista exacta de archivos y prefijos permitidos por este WP —los once patrones de `## Archivos permitidos`, transcritos literalmente en el script—, es **NUL-safe** en todo el recorrido, **enumera todas** las rutas no admitidas y sale **`0`** si todas están dentro, **`1`** si aparece alguna fuera y **`2`** ante argumentos o entorno inválidos.

**Qué NO es.** Esta comprobación es **local y redundante para WP-008** y **no cierra ni satisface `REQ-FDA-001`**. El mecanismo post-hoc global que ese requisito exige sigue **pendiente de WP-002 y WP-005**, y esta pausa no lo adelanta. WP-008 endurece la **capa preventiva** y verifica **su propio diff**.

**Semántica del modo, agregada y ejecutable.** `bash tests/runtime/check-alcance-wp008.sh`, **sin `--lista`**, hace dos cosas en una sola invocación: primero comprueba el **diff real**, y después ejecuta **automáticamente** las dos demostraciones de este apartado, usando `--lista` como **costura interna**.

| # | Demostración | Esperado |
|---|---|---|
| 1 | Lista conforme | exit `0` |
| 2 | Lista con una ruta no admitida | exit `1`, con esa ruta nombrada |

Una demostración cuyo resultado esperado es `1` **cuenta como correcta cuando obtiene `1`**.

**`--lista ARCHIVO_NUL`** comprueba **únicamente** la lista proporcionada y **no** ejecuta las demostraciones: es la costura que estas usan.

**Códigos del modo agregado:** **`0`** solo si el diff real es conforme **y** las dos demostraciones producen sus códigos esperados; **`1`** ante una no conformidad del diff o un resultado inesperado de cualquier demostración; **`2`** ante argumentos o entorno inválidos.

#### 10b. Modo `--cuarentena`

**Qué examina.** En modo real construye una lista **NUL-safe** con **todos** los archivos `*.sh` situados bajo `tests/runtime/`, **recursivamente**, más `evidence/WP-008/parche/aplicar.sh`. No se limita a `tests/runtime/*.sh`, **no excluye ningún script versionado de este WP** y **se incluye a sí mismo**.

**Qué hace fallar el control**, con exit `1` y enumerando **todos** los hallazgos con archivo y línea:

| # | Hallazgo |
|---|---|
| 1 | Una invocación del comando de estado de Git que **no** lleve, en esa misma línea lógica, ninguna de las formas aceptadas |
| 2 | Cualquiera de las formas prohibidas del archivo de patrones |
| 3 | Una invocación **no verificable**: partida mediante continuación de línea, construida por sustitución, ensamblada desde variables o encubierta tras un alias |

**Regla de una sola línea lógica.** Toda invocación real del comando de estado de Git en los scripts de este WP **debe estar en una sola línea lógica** y **debe contener** una de las formas aceptadas. Una invocación que no pueda comprobarse por lectura estática **no se presume conforme**: se declara **no verificable** y hace fallar el control. Es fail-closed, igual que el resto del WP.

Sale **`0`** sin hallazgos, **`1`** con alguno o con una invocación no verificable, y **`2`** ante argumentos o entorno inválidos.

**El escáner se examina también a sí mismo.** No hay exclusión y no queda nada a criterio de un revisor. La autoexploración es posible porque **el escáner no contiene como literales las formas que busca**: viven en el archivo de datos de §10c. El `code-reviewer` puede revisar el diseño del escáner y el contenido del archivo de patrones, pero **no sustituye ninguna de estas verificaciones automáticas**.

**Alcance declarado.** Es un control de **autoconformidad de WP-008**: mira solo los scripts que este WP entrega. **No es un control genérico del repositorio y no adelanta WP-002.**

#### 10c. El archivo de patrones

Las formas que el escáner busca **no figuran como literales dentro del escáner**. Viven en `tests/runtime/fixtures/cuarentena/patrones.txt`, un **archivo de datos no ejecutable**, con modo `0644`, que **nunca se ejecuta ni se interpreta**: se lee como texto.

Contiene tres secciones etiquetadas: el **token de invocación** que hay que detectar, las **formas aceptadas** que deben acompañarlo, y las **formas prohibidas** que hacen fallar el control por sí solas. Esa separación es lo que permite que el escáner **se incluya a sí mismo** sin autoinculparse. El archivo de patrones no es un script y no entra en la lista de archivos escaneados.

#### 10d. Pruebas del modo `--cuarentena`

**Seis pruebas deterministas: dos positivas y cuatro negativas.** Headless y sin red. Se construyen archivos temporales conforme a §11, se listan con `--lista-scripts` y **nunca se ejecutan**:

| # | Signo | Archivo de prueba | Esperado |
|---|---|---|---|
| 1 | positiva | Invocación conforme con la forma corta aceptada | exit **`0`** |
| 2 | positiva | Invocación conforme con la forma larga aceptada | exit **`0`** |
| 3 | negativa | Invocación del comando de estado **sin ninguna forma aceptada** | exit **`1`** |
| 4 | negativa | Forma prohibida corta | exit **`1`** |
| 5 | negativa | Forma prohibida larga, en sus dos variantes | exit **`1`** |
| 6 | negativa | Invocación **no verificable**: partida por continuación de línea y ensamblada por sustitución | exit **`1`** |

**Semántica del modo, agregada y ejecutable.** `bash tests/runtime/check-alcance-wp008.sh --cuarentena`, **sin `--lista-scripts`**, hace dos cosas en una sola invocación: primero ejecuta el **escaneo real** sobre todos los scripts de WP-008 —el escáner incluido—, que debe dar **cero hallazgos**, y después ejecuta **automáticamente** las **seis** pruebas de la tabla anterior, usando `--lista-scripts` como **costura interna**.

Una prueba negativa cuyo resultado esperado es `1` **cuenta como correcta cuando obtiene `1`**.

**`--cuarentena --lista-scripts ARCHIVO_NUL`** comprueba **únicamente** la lista proporcionada y **no** ejecuta las seis pruebas: es la costura que estas usan.

**Códigos del modo agregado:** **`0`** solo si el escaneo real da cero hallazgos **y** las seis pruebas producen sus códigos esperados; **`1`** ante un hallazgo real o un resultado inesperado de cualquier prueba; **`2`** ante argumentos o entorno inválidos.

El escaneo real y las seis pruebas quedan en `alcance/cuarentena.log`.

### 11. Directorios temporales: `mktemp -d` y `TMPDIR`

**Ningún contrato de este WP asume que `TMPDIR` está fuera del repositorio.** Estas reglas se aplican a **todo** directorio creado mediante `mktemp -d` por **cualquier script de WP-008**, sin excepción: `aplicar.sh`, `runner-empirico.sh`, `capturar-ci-rojo.sh`, `check-config.sh`, `check-alcance-wp008.sh` y los tres scripts de pruebas, **incluidos los fixtures y las listas temporales que estos creen**. Para cada uno de esos directorios:

1. Se **canonicaliza físicamente** el directorio **después** de crearlo.
2. Se exige que quede **fuera de la raíz física del repositorio real**.
3. Cuando se opera sobre un fixture, se exige además que quede **fuera de la raíz física del fixture**.
4. Si queda dentro de cualquiera de las dos, el script **sale con exit `2`** **antes** de modificar el archivo objetivo, de ejecutar Claude, de ejecutar el stub y de cualquier acceso a red.
5. En ese caso **solo elimina el directorio recién creado y todavía vacío**, y **nunca continúa usándolo**.

Las pruebas correspondientes se integran **como subcomprobaciones de escenarios y casos ya existentes**: en `test-protocolo.sh` dentro de los doce escenarios, y en `test-capturar-ci-rojo.sh` dentro del caso 13, con el nombre `tmpdir-dentro-del-repo`. **Ni los doce escenarios ni los diecinueve casos aumentan.**

Esta formulación es la **aclaración de un invariante ya exigido**, no una ampliación funcional: no cambian los archivos permitidos, ni los doce escenarios de `test-protocolo.sh`, ni los veintidós casos de `test-check-config.sh`, ni los diecinueve del comprobador, ni las trece subcomprobaciones del caso 13, ni ningún otro contador del WP.

## Entorno autorizado (herramientas, comandos, red, secretos)

- **Herramientas:** Read, Grep, Glob, Edit, Write, Bash
- **Comandos:** `bash`, `python3`, `git` local de solo lectura, `shellcheck`, `shasum` o `sha256sum`, `mktemp`, `diff`, `comm`, `sort`, `chmod` **solo sobre fixtures temporales**, `claude` **únicamente a través de `tests/runtime/runner-empirico.sh`**, y `gh` **solo lectura** únicamente a través de `tests/runtime/capturar-ci-rojo.sh`
- **Red:** **NINGUNA**, con dos excepciones nominales y acotadas: `runner-empirico.sh` hacia el servicio de Claude, y `capturar-ci-rojo.sh` en sus modos de adquisición hacia la API de GitHub mediante `gh` en solo lectura. El preflight, sus pruebas, la prueba del protocolo, las pruebas del comprobador y del alcance, y toda la batería de no regresión se ejecutan **sin red**
- **Secretos:** NINGUNO

**Sin dependencias nuevas.** No se instala nada. `bash` y `python3` ya están disponibles en local y en el runner, y `python3` ya se configura en el job `gobierno`.

## Verificación (comandos de validación + criterios de aceptación medibles)

**Comandos**, headless, sin interacción, sin TTY y con código de salida significativo:

```bash
bash -n tests/runtime/runner-empirico.sh
bash -n tests/runtime/test-runner-empirico.sh
bash -n tests/runtime/check-config.sh
bash -n tests/runtime/test-check-config.sh
bash -n tests/runtime/test-protocolo.sh
bash -n tests/runtime/capturar-ci-rojo.sh
bash -n tests/runtime/test-capturar-ci-rojo.sh
bash -n tests/runtime/check-alcance-wp008.sh
bash -n evidence/WP-008/parche/aplicar.sh
shellcheck --severity=warning --shell=bash tests/runtime/runner-empirico.sh tests/runtime/test-runner-empirico.sh tests/runtime/check-config.sh tests/runtime/test-check-config.sh tests/runtime/test-protocolo.sh tests/runtime/capturar-ci-rojo.sh tests/runtime/test-capturar-ci-rojo.sh tests/runtime/check-alcance-wp008.sh evidence/WP-008/parche/aplicar.sh
bash tests/runtime/check-config.sh
bash tests/runtime/test-check-config.sh
bash tests/runtime/test-protocolo.sh
bash tests/runtime/test-capturar-ci-rojo.sh
bash tests/runtime/check-alcance-wp008.sh
bash tests/runtime/check-alcance-wp008.sh --cuarentena
bash tests/runtime/test-runner-empirico.sh
bash tests/runtime/runner-empirico.sh
python3 .claude/skills/run-verification/validate-workflows.py .github/workflows
python3 -m json.tool .claude/settings.json > /dev/null
bash tests/guard/run-suite.sh
bash tests/governance/check-active.sh
bash tests/governance/test-check-active.sh
bash evidence/WP-000/checks/check-guard.sh
python3 evidence/WP-000/checks/check-manual.py
```

De estos comandos, solo `runner-empirico.sh` usa la red y solo él no puede ejecutarse en un runner de CI. `test-capturar-ci-rojo.sh` sí forma parte de la batería normal: es headless, sin red, y valida el comprobador contra respuestas de `gh` grabadas. Lo que **no** figura en este bloque es la **invocación real** de `capturar-ci-rojo.sh` con un `RUN_ID`, porque ese identificador no existe hasta que el commit correspondiente está empujado: es un paso de la cronología, y su salida `0` es criterio de aceptación. Los cinco últimos comandos son de **no regresión**.

**Criterios de aceptación:**

*Preflight y sus pruebas*

- [ ] `bash tests/runtime/check-config.sh` termina en **exit `0`** contra la configuración real ya en S2
- [ ] `bash tests/runtime/test-check-config.sh` termina en **exit `0`** con **0 fallidas** y cubre los **22** casos de §3
- [ ] El preflight ejecuta las **9** comprobaciones de §2 y las nombra una a una en su salida
- [ ] Un `command` **inerte** que contenga las cadenas `CLAUDE_PROJECT_DIR` y `exit 2` pero no ejecute el guard hace fallar el preflight con exit `1` y señala la comprobación 4
- [ ] El caso de **regla duplicada compensando una ausencia** falla por la comprobación 9 **aunque el recuento siga dando ocho**
- [ ] El caso de **regla sustituida por otra regla anclada distinta** falla por la comprobación 9 **aunque el recuento siga dando ocho**
- [ ] Los seis casos de comportamiento 17 a 22 pasan, incluido el de raíz con espacios
- [ ] `bash tests/runtime/check-config.sh /ruta/inexistente` sale **`2`**
- [ ] `tests/runtime/check-config.sh` no referencia `tests/guard/` en ninguna línea, verificable con `grep`
- [ ] **Comprobado en revisión:** `command-canonico.txt` es idéntico al comando canónico de §1a, carácter a carácter tras normalizar espacios, y `reglas-canonicas.txt` es idéntico al conjunto de ocho reglas de §1b. Lo verifica el `code-reviewer` **contra el WP aprobado**, no contra los propios oráculos
- [ ] Tras ejecutar el test completo, `.claude/hooks/guard.sh` conserva ruta, contenido y bit de ejecución

*Runtime fail-closed*

- [ ] El `command` del hook es **idéntico** al canónico de §1a y no invoca el guard por ruta relativa
- [ ] Con el hook **ausente** en el fixture, el intento de escritura queda **bloqueado**
- [ ] Con el hook **sin permiso de ejecución** en el fixture, el intento de escritura queda **bloqueado**
- [ ] El matcher sigue siendo, carácter a carácter, `Edit|Write|MultiEdit|NotebookEdit|Bash`
- [ ] `git diff -- .claude/settings.json` no muestra ningún cambio en `ask`, en `allow` ni en las cuatro reglas `Bash(...)` del `deny`
- [ ] Las **ocho** reglas de archivo quedan reancladas **una a una**: ocho originales, ocho finales, cuatro `Read` y cuatro `Edit`; ninguna empieza por `./` ni queda sin anclar
- [ ] El conjunto final coincide **elemento a elemento** con el transcrito en §1b
- [ ] Prueba empírica: un archivo `.env` **en la raíz** del fixture queda denegado a la lectura
- [ ] Prueba empírica: un archivo `.env` **en un directorio anidado** del fixture queda denegado a la lectura
- [ ] **Caso (a), soportado:** en una sesión iniciada en la raíz y desplazada con `cd`, cada ruta hoy denegada sigue denegada y la escritura fuera de alcance queda **bloqueada**
- [ ] **Caso (b), fuera del contrato de la FDA:** su resultado queda **medido y registrado tal como se observe**, clasificado `REGISTRADA_FUERA_DE_CONTRATO`, **sin presuponer** qué configuración se carga ni cómo se descubre. No cuenta como conformidad ni como incumplimiento

*Runner empírico y smoke*

- [ ] `bash tests/runtime/runner-empirico.sh` termina en **exit `0`** con esta composición **exacta**: **14 sondas lógicas ejecutadas · 13 conformes · 1 `REGISTRADA_FUERA_DE_CONTRATO` · 0 no conformes**, y sin ningún error de entorno
- [ ] La única sonda `REGISTRADA_FUERA_DE_CONTRATO` es la del **caso (b)**
- [ ] El runner registra los **tres recuentos**: sondas lógicas, subsondas e invocaciones físicas
- [ ] Cada **invocación física** lleva `--max-turns` y `--max-budget-usd` propios, y el runner comprueba el tope agregado **antes** de lanzar la siguiente, de modo que los 5,00 USD nunca se sobrepasan
- [ ] Las invocaciones usan `--setting-sources project`, `--tools` con el conjunto mínimo disponible y `--allowedTools` explícito por CLI, y **no** los `allow` del fixture
- [ ] Cada sonda que necesita más de una herramienta declara en `matriz-empirica.md` su **allowlist mínima completa**
- [ ] **Cualquier llamada de herramienta inesperada hace fallar la subsonda**
- [ ] `bash tests/runtime/test-runner-empirico.sh` termina en **exit `0`** con **0 fallidas**, sin red, sin coste y sin ninguna invocación de `claude -p`, y cubre las **seis** pruebas negativas de §5c
- [ ] Los ciclos de hook que el runner acepta cumplen el **esquema contractual de §5c** —`type` igual a `system`, `hook_event` igual a `PreToolUse`, y un `hook_started` y un `hook_response` con el **mismo `hook_id`**— y se asocian a su llamada **solo** por la **ventana de orden**; `hook_progress` **no se exige** y solo se procesa si aparece
- [ ] **Ninguna** asociación se decide buscando `tool_use_id`, comandos ni rutas **dentro del JSON serializado** de un mensaje de hook, verificable por lectura del runner; las comparaciones de identificadores, comandos y rutas son **estructuradas y de igualdad exacta**, sobre `tool_use.name`, `tool_use.input.command` y `tool_use.input.file_path`
- [ ] `C6` **no exige** ciclo de hook para `Read`; el único exigido en `C6.tras-cd` es el de la llamada `Bash` inicial, dentro de la ventana de esa misma llamada
- [ ] El control neutral previo confirmó que `Edit`, `Write`, `NotebookEdit` y `Bash` están disponibles y superan su operación neutral, y cubre además cada **combinación mínima**
- [ ] Toda sonda fallida o bloqueada de forma inesperada lleva anotado el resultado de su **control neutral equivalente**
- [ ] `MultiEdit` es la **única** entrada que puede aparecer como `legacy no disponible`
- [ ] El runner escribe **fuera del repositorio** y **rechaza con exit `2`** un directorio de salida que resuelva dentro
- [ ] Las **cinco magnitudes de integridad** son idénticas antes y después de la ejecución
- [ ] Los artefactos incorporados a `evidence/WP-008/empirico/` son **derivados y saneados**: no contienen el flujo `stream-json` crudo completo ni ningún contenido que vulnere `SEC-001`
- [ ] Las **siete** capacidades C1 a C7 quedan demostradas, cada una con su evidencia automática
- [ ] La versión mínima se enuncia como **lista de capacidades**; la versión observada aparece solo como dato acompañante

*Comprobadores de barrera y de alcance*

- [ ] `bash tests/runtime/test-capturar-ci-rojo.sh` termina en **exit `0`** con **19 correctas y 0 fallidas**
- [ ] Cada una de las **ocho** validaciones del run rojo tiene **al menos un caso negativo** que demuestra que bloquea
- [ ] Las **trece** subcomprobaciones nombradas del caso 13 salen `2`, y en las trece se demuestra que no se ejecutó ni el stub ni el `gh` real
- [ ] Un directorio de salida proporcionado pero inexistente se **rechaza sin crearlo**
- [ ] El test se ejecuta **sin red**: usa respuestas grabadas y un stub inyectado por costura explícita
- [ ] El caso 14 demuestra polling, persistencia externa y delegación al validador puro; el 16, la expiración del tiempo máximo sin espera real prolongada
- [ ] `capturar-ci-rojo.sh` separa **adquisición** y **validación pura**: el modo `--validar` no toca la red
- [ ] `bash tests/runtime/check-alcance-wp008.sh`, **sin `--lista`**, termina en **exit `0`**: el diff real es conforme, con cero rutas no admitidas, **y** las **dos** demostraciones de §10a producen sus códigos esperados, la segunda con exit `1` y la ruta nombrada
- [ ] `bash tests/runtime/check-alcance-wp008.sh --cuarentena`, **sin `--lista-scripts`**, termina en **exit `0`**: el escaneo real da cero hallazgos sobre **todos** los `*.sh` bajo `tests/runtime/`, recursivamente, más `aplicar.sh`, **incluido el propio escáner**, **y** las **seis** pruebas de §10d —**dos positivas y cuatro negativas**— producen sus códigos esperados
- [ ] Las **ocho** pruebas de §10 —dos demostraciones y seis del modo cuarentena— quedan cubiertas por esas **dos** invocaciones de la batería: ninguna requiere ejecución manual ni interpretación
- [ ] Un resultado esperado de `1` cuenta como **correcto** cuando se obtiene `1`; un código distinto del esperado hace salir al modo agregado con `1`
- [ ] Las costuras `--lista` y `--cuarentena --lista-scripts` comprueban **solo** la lista dada y **no** disparan las pruebas, verificable por sus propias ejecuciones
- [ ] Los archivos temporales de las seis pruebas **no se ejecutan** en ningún momento
- [ ] `tests/runtime/fixtures/cuarentena/patrones.txt` existe, tiene modo `0644`, **no es ejecutable**, y el escáner **no contiene como literales** ninguna de las formas que busca
- [ ] Toda invocación real del comando de estado de Git en los scripts de este WP está en **una sola línea lógica** y lleva una forma aceptada
- [ ] El WP declara que la comprobación de alcance es **local y redundante**, y que **no cierra `REQ-FDA-001`**

*CI*

- [ ] `.github/workflows/ci.yml` añade **exactamente un** paso, en el job `Gobierno FDA`, que invoca `tests/runtime/check-config.sh` y no replica su lógica
- [ ] `git diff -- .github/workflows/ci.yml` no toca ningún otro job ni paso, y no añade ninguna acción ni dependencia
- [ ] En la ejecución roja, el job `Gobierno FDA` presenta: pasos anteriores al preflight en `success`, preflight en `failure`, pasos posteriores del mismo job en `skipped`
- [ ] En la ejecución roja, los **demás jobs** del workflow terminan en `success`
- [ ] En la ejecución roja **no hay ninguna segunda causa de fallo**
- [ ] `bash tests/runtime/capturar-ci-rojo.sh "$RUN_ROJO" "$C_ROJO"` terminó en **exit `0`**, validando automáticamente las **ocho** condiciones, **antes** de la fase verde y de empujar `C_VERDE`
- [ ] El run rojo **no fue cancelado**: su `conclusion` es `failure`
- [ ] `bash tests/runtime/capturar-ci-rojo.sh --verde "$RUN_VERDE" "$C_VERDE"` terminó en **exit `0`**, validando sus **tres** condiciones, **antes** de reabrir ninguna sesión de agente y antes de preparar `C_EVIDENCIA`
- [ ] Las dos ejecuciones proceden de **la misma rama y la misma PR**; el ruleset no se modificó y **`main` no se modificó para fabricar ninguna de las dos evidencias**
- [ ] `C_ROJO`, `C_VERDE` y `C_EVIDENCIA` figuran en la lista de commits de la PR, con sus hashes completos
- [ ] El run rojo tiene `headSha` igual a `C_ROJO`; el verde, igual a `C_VERDE` con `conclusion` igual a `success`
- [ ] `git rev-parse C_VERDE^` devuelve exactamente `C_ROJO`: descendencia **directa**
- [ ] `git merge-base --is-ancestor C_VERDE C_EVIDENCIA` sale **`0`**
- [ ] Entre `C_ROJO` y `C_VERDE`, el único cambio en los dos archivos protegidos es `.claude/settings.json`

*Parche*

- [ ] `aplicar.sh rojo` transforma **S0 a S1**; repetido en S1 imprime `YA EN ROJO`, sale `0` y no modifica nada
- [ ] `aplicar.sh verde` transforma **S1 a S2**; repetido en S2 imprime `YA EN VERDE`, sale `0` y no modifica nada
- [ ] Sobre fixtures: `verde` desde S0, `rojo` desde S2, el par invertido y cualquier estado desconocido abortan con exit `2` sin escribir nada
- [ ] En la fase roja, el preflight sobre el `settings` en `ANTES` sale **`1`** y señala exactamente las comprobaciones 4 y 6
- [ ] En la fase verde, el candidato hace pasar el preflight con exit **`0`**, comprobado **antes** de sustituir el archivo real
- [ ] Sobre fixtures: ante un fallo provocado, `aplicar.sh` restaura y deja el par en **S0** en la fase roja y en **S1** en la verde, con `ROLLBACK APLICADO` y código distinto de cero
- [ ] El failpoint **rechaza con exit `2`** sin `--root` o contra una raíz sin el marcador `.fda-fixture`
- [ ] `bash tests/runtime/test-protocolo.sh` termina en **exit `0`** con **0 fallidas** y cubre los **12** escenarios de §7g
- [ ] En cada fase, `H_OTROS_DESPUES` es **idéntica** a `H_OTROS_ANTES` con el objetivo excluido por `pathspec`, y `H_STAGED_DESPUES` es **idéntica** a `H_STAGED_ANTES`
- [ ] En cada fase, el archivo objetivo pasó de su huella contractual de origen a la de destino
- [ ] `test-protocolo.sh` compara la **instantánea completa** de la raíz del fixture antes y después, **excluyendo `.git/**`**: idénticas salvo el archivo objetivo, sin que aparezca ni desaparezca ninguna otra ruta
- [ ] Todo directorio creado con `mktemp -d` por cualquier script de este WP queda **fuera** de la raíz física del repositorio y, en modo fixture, también fuera de la del fixture; en caso contrario el script sale `2`, elimina el directorio vacío y no continúa
- [ ] Las copias de seguridad viven **únicamente** en ese directorio temporal, y su ruta física consta en el log
- [ ] Sobre los dos archivos reales se ejecutaron **exactamente cuatro** invocaciones de `aplicar.sh`, las de §7h
- [ ] Los logs de las dos fases reales se generaron **fuera del repositorio** y se incorporaron solo durante la preparación de `C_EVIDENCIA`

*No regresión y alcance*

- [ ] `bash tests/guard/run-suite.sh` sigue dando **68 correctas · 0 fallidas · 10 huecos conocidos · 0 huecos cerrados**, sin que el archivo se haya modificado
- [ ] `git diff --name-only main...HEAD` no contiene `tests/guard/run-suite.sh` ni `.claude/hooks/guard.sh`
- [ ] `bash evidence/WP-000/checks/check-guard.sh`, `check-active.sh` y `test-check-active.sh` en verde
- [ ] `python3 evidence/WP-000/checks/check-manual.py` en verde tras tocar los cinco archivos de `docs/manual/`: es la verificación de `REQ-FDA-003`, que este WP satisface sin enmendar
- [ ] Bajo `docs/manual/` cambian **exactamente** los cinco archivos nominales permitidos
- [ ] Bajo `docs/`, fuera de esos cinco, cambia **únicamente** `docs/02-guia-fabrica-desarrollo-agentica.md`
- [ ] Bajo `specs/requirements/` cambia **únicamente** `SEC-001-sin-secretos.md`
- [ ] `MANUAL.md` y `docs/manual/04-agentes.md` declaran el **mismo número de controles deterministas: cuatro**
- [ ] `docs/02-guia-fabrica-desarrollo-agentica.md` §3 no contiene ninguna regla con prefijo `./`, muestra el matcher completo de cinco entradas y una invocación anclada con `CLAUDE_PROJECT_DIR`
- [ ] `SEC-001` criterio 4 enumera las **cuatro** reglas reancladas y su tabla dice **4 reglas activas**, ancladas a la raíz del proyecto
- [ ] `work-packages/ACTIVE`, `work-packages/**`, `evidence/WP-007/**`, el ruleset y el estado externo de `claude.yml` y `code-review.yml` permanecen **sin cambios**
- [ ] `.agents/`, `.codex/` y `AGENTS.md` no aparecen en el diff, no fueron leídos y no fueron enumerados por ninguna herramienta del WP
- [ ] Revisión del **`security-reviewer`** realizada y **sin hallazgos de severidad ALTA ni CRÍTICA abiertos**

*Coste*

- [ ] `evidence/WP-008/cost.md` cumple `DEC-001` y `DEC-004`, **sin marcador alguno**
- [ ] El `estado_coste` corresponde a la **procedencia real** de la cifra, según `DEC-004` §12: F1 o F2 conformes producen `medido`; F1 o F2 incompletas o no conformes producen `estimado`; F3 produce `estimado`; sin cifra defendible produce `no_disponible`, y entonces el WP es **NO APTO**
- [ ] Los campos obligatorios del estado declarado están completos según `DEC-004` §4
- [ ] El coste del runner empírico, con su tope de 5,00 USD, queda contabilizado dentro del coste del WP

## Evidencias exigidas (qué debe aparecer en evidence/WP-008/)

- [ ] `empirico/runner.log` — **resumen saneado** del runner: una línea por sonda con veredicto, coste y código, más el resultado agregado
- [ ] `empirico/test-runner.log` — salida íntegra de `test-runner-empirico.sh` con su código de salida, incluidas las **seis** pruebas negativas de §5c y el recuento de correctas y fallidas
- [ ] `empirico/matriz/` — un extracto **derivado y saneado** por contexto: comando exacto, eventos pertinentes al veredicto, y el veredicto
- [ ] `empirico/smoke/` — el mismo extracto por capacidad C1 a C7, con el registro automático de cualquier entrada del matcher no expuesta
- [ ] `empirico/recuentos.md` — sondas lógicas, subsondas e invocaciones físicas, y la composición del resultado agregado
- [ ] `empirico/coste.md` — coste de cada invocación física y agregado, contrastado con el tope de 5,00 USD
- [ ] `empirico/integridad.md` — las **cinco magnitudes** antes y después, idénticas, y la ruta física del directorio de salida externo
- [ ] `empirico/version.txt` — versión instalada, **como dato, no como requisito**
- [ ] `preflight/` — salida íntegra de `check-config.sh` y de `test-check-config.sh`, con sus códigos de salida
- [ ] `preflight/negativos.log` — las salidas de los **22** casos, con los casos 15 y 16 mostrando recuento conforme y conjunto no conforme
- [ ] `protocolo/test-protocolo.log` — salida íntegra de `test-protocolo.sh` con los **12** escenarios y su código de salida
- [ ] `protocolo/failpoint-rechazado.log` — intento de activar el failpoint sin `--root` y contra una raíz sin marcador, ambos con exit `2`
- [ ] `parche/aplicar.sh`, `parche/huellas.sha256`, `parche/settings.json.candidato`, `parche/ci.yml.candidato`, `parche/README.md`
- [ ] `parche/01-fase-roja.log` — `aplicar.sh rojo` real, con `APLICADO ROJO (S1)`, exit `0`, ruta física del directorio temporal y la salida del preflight fallando por las comprobaciones 4 y 6. **Generado fuera del repositorio e incorporado en `C_EVIDENCIA`**
- [ ] `parche/02-rojo-idempotente.log` — segunda ejecución real con `YA EN ROJO` y exit `0`
- [ ] `parche/03-fase-verde.log` — `aplicar.sh verde` real, con la validación del candidato previa a sustituir, `APLICADO VERDE (S2)` y exit `0`
- [ ] `parche/04-verde-idempotente.log` — segunda ejecución real con `YA EN VERDE` y exit `0`
- [ ] `parche/05-abortado-orden.log` — sobre fixtures: `verde` desde S0 y `rojo` desde S2, ambos `ABORTADO` y exit `2`
- [ ] `parche/06-abortado-par-invertido.log` — sobre fixtures: par invertido y estado desconocido, `ABORTADO` y exit `2`
- [ ] `parche/07-rollback-rojo.log` — sobre fixture: `ROLLBACK APLICADO`, exit distinto de cero y par restaurado a **S0**
- [ ] `parche/08-rollback-verde.log` — sobre fixture: `ROLLBACK APLICADO`, exit distinto de cero y par restaurado a **S1**
- [ ] `parche/09-alcance.log` — las huellas `H_OTROS` y `H_STAGED` antes y después de cada fase real, y la transición de huella del archivo objetivo
- [ ] `ci/rojo/` — extracto **saneado** de la captura: `run_id`, URL, `headSha`, `conclusion` distinta de `cancelled`, la tabla de estados de todos los jobs y pasos, el log del paso fallido y el **código de salida `0`** del comprobador, con `modo=real`
- [ ] `ci/verde/` — entrada **única** con, conjuntamente: `run_id`, URL, `headSha`, `conclusion`, el log del modo `--verde` con `modo=real` en su primera línea, y el **código de salida `0`** de ese modo
- [ ] `ci/comprobador/test.log` — salida íntegra de `test-capturar-ci-rojo.sh`, con los **19** casos, sus códigos y el resultado agregado
- [ ] `ci/comprobador/cobertura.md` — correspondencia entre las **ocho** validaciones del run rojo y el caso negativo que cubre cada una
- [ ] `ci/procedimiento.md` — los tres commits con sus hashes completos, los dos `run_id` con su `headSha` y su `conclusion`, la salida de `gh pr view --json commits`, y las dos comprobaciones de ascendencia con su código de salida
- [ ] `alcance/diff.log` — salida íntegra de la invocación **agregada** `check-alcance-wp008.sh`: la comprobación del diff real, las **dos** demostraciones con su código obtenido frente al esperado, y el **código agregado `0`**
- [ ] `alcance/cuarentena.log` — salida íntegra de la invocación **agregada** `check-alcance-wp008.sh --cuarentena`: el escaneo real con **cero hallazgos**, las **seis** pruebas con su código obtenido frente al esperado, y el **código agregado `0`**
- [ ] `no-regresion/` — salidas de `run-suite.sh`, `check-guard.sh`, `check-active.sh`, `test-check-active.sh` y `check-manual.py`
- [ ] `diff/` — `git diff --name-status -M main...HEAD` y los diffs completos de `.claude/settings.json` y `.github/workflows/ci.yml`
- [ ] `cost.md` conforme a `DEC-001` y `DEC-004`
- [ ] Ningún archivo bajo `evidence/WP-008/` contiene el flujo `stream-json` crudo completo, prompts íntegros, respuestas íntegras ni cadenas con forma de credencial

## Condiciones de parada específicas

- Si el fail-closed exigiera **crear un archivo bajo `.claude/hooks/`** o modificar `guard.sh`: **parar**.
- Si `runner-empirico.sh` sale **distinto de cero** en el paso 3 del orden de aplicación: **parar**. El resto de la implementación no continúa.
- Si el resultado agregado del runner no fuese exactamente 14 ejecutadas, 13 conformes, 1 `REGISTRADA_FUERA_DE_CONTRATO` y 0 no conformes: **parar**.
- Si alguna sonda resultara **no decidible** automáticamente: **parar**. Se corrige el criterio de veredicto del runner.
- Si los mensajes de hook observados **no cumplen el esquema contractual de §5c**, o si el par `hook_started`/`hook_response` no puede asociarse a su llamada por **ventana de orden**: **parar** y solicitar decisión. No se infiere el esquema por parecido textual, no se acepta el esquema sintético antiguo y no se vuelve a la búsqueda dentro del JSON serializado.
- Si faltara `Edit`, `Write`, `NotebookEdit` o `Bash` en el catálogo efectivo, o si alguna no superara su operación neutral: **parar** con **error de entorno**. No se degrada a `legacy no disponible`.
- Si un hook inesperado o una restricción gestionada alterase la capacidad medida: **parar** con exit `2`.
- Si una sonda fallase y su control neutral equivalente también fallase: **parar**. Hay interferencia externa.
- Si el coste agregado del runner alcanzase **5,00 USD**: **parar**.
- Si un directorio creado con `mktemp -d` por cualquier script de este WP quedase dentro de la raíz física del repositorio, o dentro de la del fixture cuando se opera sobre fixture: **parar** con exit `2`, eliminar solo ese directorio vacío y no continuar.
- Si el runner fuese a escribir en `evidence/WP-008/**`, o en cualquier ruta del repositorio real, durante la medición: **parar**.
- Si cualquiera de las **cinco magnitudes de integridad** difiriese antes y después: **parar**.
- Si un artefacto destinado a `evidence/WP-008/` contuviese el flujo crudo completo o cualquier contenido que vulnere `SEC-001`: **parar**.
- Si alguna sonda exigiera renombrar, sustituir, borrar o retirar el permiso a `.claude/hooks/guard.sh` **de este repositorio**: **parar**.
- Si la prueba empírica demostrara que `Read(/**/.env*)` **no** cubre un archivo `.env` en la raíz del fixture: **parar** y solicitar decisión.
- Si el par de huellas no corresponde a **S0**, **S1** ni **S2**: **parar**. **S1 es el único estado intermedio autorizado.**
- Si una fase se invoca fuera de orden, `verde` desde S0 o `rojo` desde S2: **parar**.
- Si el rollback de una fase no restaurase el estado de origen **de esa fase**: **parar y escalar de inmediato**.
- Si la instantánea del fixture mostrara una ruta adicional o desaparecida, o una diferencia fuera del archivo objetivo y de `.git/**`: **parar**.
- Si se intentara activar el failpoint contra el repositorio real o contra una raíz sin el marcador `.fda-fixture`: **parar**.
- Si `aplicar.sh` fuera a escribir su log dentro de `evidence/WP-008/` durante una fase: **parar**.
- Si `H_OTROS` o `H_STAGED` cambiaran durante una fase: **parar**.
- Si algún agente fuese a trabajar mientras el par está en **S1**: **parar**. Esa ventana es de operación humana exclusiva.
- Si se ejecutase la fase verde o se empujase `C_VERDE` **antes** de que `capturar-ci-rojo.sh` haya salido `0`: **parar**.
- Si `capturar-ci-rojo.sh` saliera `1` en el modo rojo: **parar**. La composición del run rojo no es la contratada.
- Si `capturar-ci-rojo.sh --verde` saliera **`1`**: **parar**. No se reabren agentes, no se prepara `C_EVIDENCIA`, no se empuja, no hay `amend`, `rebase` ni force-push, y se solicita decisión humana. Ni relanzar el run ni reiniciar la rama o la PR están autorizados por este contrato.
- Si `capturar-ci-rojo.sh --verde` saliera **`2`** por timeout, adquisición o entorno: **parar** y solicitar decisión humana. La comprobación, que es de solo lectura, solo se repite sobre el mismo `RUN_ID` y el mismo `C_VERDE` con autorización expresa.
- Si `capturar-ci-rojo.sh` saliera `2` por expiración del tiempo máximo en el modo rojo: **parar** y solicitar decisión. No se amplía el tiempo por iniciativa propia.
- Si una captura destinada a evidencia real llevase `modo=fixture` en su log: **parar**. No es evidencia de CI.
- Si la ejecución roja fallara además en algún paso o job distinto del preflight: **parar**.
- Si el run de `C_ROJO` terminase con `conclusion` igual a `cancelled`: **parar de inmediato**. No sirve como evidencia del bloqueo. **No se empuja nada más**; **no se intenta reconstruir la evidencia con commits adicionales**, porque un tercer commit rompería la ascendencia directa que el contrato exige; y se declara por escrito que la situación **no es recuperable automáticamente** dentro de la cadena contractual exacta `C_ROJO` a `C_VERDE` a `C_EVIDENCIA`. Se **solicita decisión humana** sobre abandonar y reiniciar la rama y la PR. Este contrato **no presupone autorización** para borrar, reescribir ni reiniciar nada.
- Si la ejecución en rojo exigiera tocar `main`, el ruleset, una segunda rama o una segunda PR: **parar**.
- Si `check-alcance-wp008.sh` saliera `1` en cualquiera de sus dos modos: **parar**. Hay una ruta fuera de alcance o una invocación que rompe el invariante de cuarentena.
- Si `bash tests/guard/run-suite.sh` dejara de dar sus contadores actuales, o si el archivo apareciera en el diff: **parar**. `DEC-003` §7 lo prohíbe durante toda la pausa.
- Si se planteara fijar acciones por SHA, tocar `claude.yml` o `code-review.yml`, o corregir cualquier punto de `REQ-FDA-002`: **parar**. Es WP-009.
- Si se planteara construir la adquisición headless del coste, el validador de `cost.md` o el registro de excepciones: **parar**. Es WP-010.
- Si se planteara la frontera de revisión verificable o reactivar cualquier workflow de agente: **parar**. Es WP-011.
- Si se planteara tocar `evidence/WP-007/**`, el worktree congelado, WP-002, `DEC-003`, `DEC-004`, `ACTIVE`, el ruleset o el estado externo de los workflows: **parar**.
- Si se planteara leer, enumerar, versionar o modificar `.agents/`, `.codex/` o `AGENTS.md`: **parar**. Están en cuarentena por `DEC-003` §8.
- Si se planteara ampliar a `docs/manual/**` o a cualquier ruta de `specs/requirements/` distinta de `SEC-001`: **parar** y solicitar decisión.
- Si algún agente intentara escribir directamente `.claude/settings.json` o `.github/workflows/ci.yml`: **parar**. Esas rutas las aplica una persona, siempre.
- Si un agente fuese a firmar una cifra de coste obtenida por F3: **parar**. F3 la firma una persona.
- Si el `security-reviewer` reportara un hallazgo de severidad **ALTA** o **CRÍTICA**: el WP **se bloquea** y no se fusiona.

## Migración / rollback

### Orden de aplicación obligatorio

1. El agente se inicia **en la raíz del repositorio** y comprueba **en solo lectura** que `.claude/hooks/guard.sh` existe y es ejecutable.
2. El agente implementa **primero y conjuntamente** `tests/runtime/runner-empirico.sh`, `tests/runtime/test-runner-empirico.sh`, `tests/runtime/matriz-empirica.md`, `tests/runtime/smoke-capacidades.md` y **únicamente los fixtures que esas sondas necesitan**. Los dos Markdown son la **especificación versionada que el runner aplica**: no pueden redactarse después de ejecutarlo. El paso se cierra ejecutando `bash tests/runtime/test-runner-empirico.sh` —determinista, sin red y sin coste—, que debe salir **`0`**.
3. El operador ejecuta `bash tests/runtime/runner-empirico.sh` en modo headless, **solo después** de que el paso 2 haya cerrado con ese test en `0`: ninguna invocación de `claude -p` se lanza sobre una lógica de asociación no probada. La salida va a un directorio **externo al repositorio**, cuya ruta física imprime el runner y **se conserva hasta `C_EVIDENCIA`**. **Solo si sale `0`** continúa el resto de la implementación.
4. Escribir `check-config.sh`, sus dos oráculos, sus pruebas, `test-protocolo.sh`, `capturar-ci-rojo.sh`, `test-capturar-ci-rojo.sh`, `check-alcance-wp008.sh`, el archivo de patrones y los fixtures restantes.
5. Preparar los dos candidatos y `evidence/WP-008/parche/`, y ejecutar `test-protocolo.sh` sobre fixtures.
6. Actualizar los cinco archivos de `docs/manual/`, la guía fundacional y `SEC-001`.
7. La persona ejecuta la **fase roja**, commitea `C_ROJO` y empuja.
8. La persona lanza `capturar-ci-rojo.sh` sobre el run rojo y espera su exit `0`.
9. La persona ejecuta la **fase verde**, commitea `C_VERDE` y empuja.
10. La persona lanza `capturar-ci-rojo.sh --verde` y espera su exit `0`. Hasta entonces no se reabre ninguna sesión de agente.
11. El agente prepara las evidencias saneadas; la persona commitea `C_EVIDENCIA` y empuja.

Implementación, pruebas y documentación viajan en **una única PR de WP**. La preparación y activación del WP, y su cierre, son **PRs de operador separadas**.

### Una rama, una PR, tres commits

Rama `wp/WP-008-runtime-fail-closed`. Una PR. Sin `amend`, sin `rebase`, sin force-push, sin reescritura de historial.

| Fase | Quién | Qué ocurre |
|---|---|---|
| **Preparación**, par en S0 | Agente | Implementa `tests/runtime/**`, los cinco archivos de `docs/manual/`, la guía fundacional, `SEC-001` y `evidence/WP-008/parche/**` con los candidatos, y ejecuta las pruebas sobre fixtures. **No toca** `settings.json` ni `ci.yml`: son rutas vedadas |
| **Fase roja** | **Persona** | Ejecuta `aplicar.sh rojo` y después la repetición idempotente. Par S0 a **S1**. Los logs quedan en el directorio temporal externo |
| **`C_ROJO`** | **Persona** | Commitea implementación, pruebas, oráculos, fixtures, documentación, protocolo y `ci.yml` en `DESPUES`. **`settings.json` permanece exactamente en `ANTES`.** Empuja |
| — | CI | Se ejecuta sobre `C_ROJO`. En `Gobierno FDA`: pasos anteriores al preflight en `success`, preflight en `failure`, pasos posteriores del mismo job en `skipped`. Los demás jobs en `success`. **No hay ninguna segunda causa de fallo** |
| **Barrera roja** | **Persona lanza el comprobador** | `bash tests/runtime/capturar-ci-rojo.sh "$RUN_ROJO" "$C_ROJO"`, que espera con polling acotado a 20 minutos, valida automáticamente sus ocho condiciones y escribe la captura **fuera del repositorio**. **Solo si sale `0`** continúa |
| **Fase verde** | **Persona** | **Sin abrir ninguna sesión de agente**, ejecuta `aplicar.sh verde` y después la repetición idempotente. Par S1 a **S2** |
| **`C_VERDE`** | **Persona** | Hijo **directo** de `C_ROJO`. Entre los dos archivos protegidos cambia **únicamente** `.claude/settings.json`, de `ANTES` a `DESPUES`. Empuja |
| — | CI | Se ejecuta sobre `C_VERDE` |
| **Barrera verde** | **Persona lanza el comprobador** | `bash tests/runtime/capturar-ci-rojo.sh --verde "$RUN_VERDE" "$C_VERDE"`, que espera con el mismo polling acotado y valida sus tres condiciones. **Solo si sale `0`** puede reabrirse una sesión de agente y prepararse `C_EVIDENCIA`. Si sale `1` o `2`, se aplica el contrato de parada de §9f |
| **`C_EVIDENCIA`** | Agente y **persona** | El agente consulta GitHub en **solo lectura** y **escribe** en `evidence/WP-008/**`, que es ruta permitida. Incorpora los logs temporales de las fases, los resultados saneados del runner y las capturas de las dos barreras, y registra hashes, `run_id`, `headSha`, URL y `conclusion`. La **persona** commitea y empuja |
| — | CI | Se ejecuta sobre `C_EVIDENCIA` y **debe quedar verde**. No se exige guardar su propio run dentro de ese mismo commit |

**Por qué las barreras son obligatorias y no una recomendación.** `.github/workflows/ci.yml` declara `concurrency` con `group: ci-${{ github.ref }}` y `cancel-in-progress: true`. Empujar el commit siguiente mientras el run anterior sigue en curso **lo cancelaría**, y la evidencia se perdería sin dejar rastro utilizable. Las barreras no protegen el proceso: protegen las únicas pruebas de que el control bloquea y de que la configuración final es conforme.

**Ninguna sesión de agente mientras el par está en S1.** En S1 el `settings.json` sigue **exactamente en `ANTES`**: no hay ninguna configuración degradada a propósito, y el runtime local es el mismo que hay hoy en `main`. Lo que no puede ocurrir es que un agente trabaje con el protocolo a medias, porque un commit suyo entre `C_ROJO` y `C_VERDE` rompería la cadena de evidencias y la ascendencia directa.

**Frontera de permisos, dicha con precisión.** El acceso del agente a **GitHub** es de solo lectura. La **creación de evidencias** en `evidence/WP-008/**` es una **escritura local autorizada** por el contrato. Las escrituras en `.claude/settings.json` y `.github/workflows/ci.yml`, y todas las operaciones de Git que publican, son **actos humanos**.

**Autoría de `cost.md`.** Se prepara durante `C_EVIDENCIA` y su estado corresponde a la procedencia real. Si la fuente es **F3**, la lectura, la estimación y el registro los realiza **la persona**: un agente no puede firmar F3. Si la fuente es **F1 o F2** y es conforme, una automatización determinista versionada puede registrar el resultado. En ningún caso un agente inventa una cifra, una causa o una base de estimación. Durante el periodo provisional de `DEC-004` §12, F3 es la vía habitual, **no la única permitida**.

**Por qué hacen falta las dos capturas de CI.** Una ejecución verde demuestra que el paso no rompe nada; solo la roja demuestra que **bloquea**. Un control que nunca se ha visto fallar es indistinguible de un adorno, y es la lección de los cinco falsos verdes que registra `DEC-003` §3.

**Comprobaciones de forma**, headless y reproducibles por un tercero:

```bash
git rev-parse "$C_VERDE^"
git merge-base --is-ancestor "$C_VERDE" "$C_EVIDENCIA"
gh pr view --json commits
```

**Amend, rebase y force-push quedan prohibidos** durante todo el WP. Es una **regla operativa**, y el contrato no pretende que ningún artefacto la certifique. Lo que sí queda demostrado con artefactos versionados y metadatos de la PR es la **forma final** de la cadena: `C_ROJO`, `C_VERDE`, `C_EVIDENCIA`, con los dos runs apuntando a los `headSha` correctos.

### Rollback durante la aplicación: automático y por fase

Lo hace `aplicar.sh` sin intervención, restaurando el archivo de esa fase desde su directorio temporal y comprobando que el par vuelve al estado de origen de la fase: **S0** para la roja, **S1** para la verde. Esos directorios **no** se versionan y sus rutas físicas se imprimen en el log, para poder restaurar a mano si el propio rollback fallara. Los logs de rollback reales siguen la misma regla de §7f.

### Rollback posterior, no destructivo

Nunca `git reset --hard`, nunca `git branch -D`, nunca force-push, nunca reescritura de historial.

- **Antes del commit:** restaurar por rutas explícitas desde `HEAD` con `git restore --source=HEAD --staged --worktree --` seguido de las rutas afectadas. Nada de restauraciones masivas, y sin depender de ninguna copia versionada: no existe ninguna.
- **Tras un commit local no publicado:** `git switch main`, conservando la rama intacta. Para abandonarla se informa del **nombre de la rama** y del **hash** y se espera **autorización humana explícita**; solo `git branch -d` cuando Git confirme que está fusionada.
- **Tras el push:** cerrar la PR sin fusionar y borrar la rama remota. `main` no se modifica por este acto.
- **Tras una eventual fusión:** revertir mediante una **PR nueva** de revert. No se reescribe el historial de `main`. Una reversión deja el runtime en el estado previo, que es el fail-open conocido y registrado por `DEC-003` §1: la reversión **no es neutra** y debe ir acompañada de la decisión humana que la justifique.
