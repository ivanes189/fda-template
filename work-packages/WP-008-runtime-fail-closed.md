# WP-008 — Runtime fail-closed: anclaje del hook y de las reglas, y preflight bloqueante en CI

estado: ready
prioridad: P0
agente_responsable: implementer     agente_revisor: code-reviewer
requisitos: [REQ-FDA-001, REQ-FDA-003, SEC-001]  adr: [ADR-001]
presupuesto_max_eur: 40             max_ciclos_correccion: 2

<!-- Revisores: qa (pruebas) + code-reviewer (revision de la PR) + security-reviewer
     OBLIGATORIO, porque este WP toca CI y el sistema de permisos.

     El estado 'ready' que figura arriba es la PROPUESTA del contrato.
     Materializar este contrato reducido y escribir WP-008 en
     work-packages/ACTIVE son actos del operador humano, en PRs de operador
     separadas. Este WP no se activa a si mismo.

     Edit(/.github/workflows/**) y Edit(/.claude/settings.json) estan en el deny
     de .claude/settings.json: NINGUN agente escribe esos dos archivos, tenga
     este WP el alcance que tenga. Los aplica una persona con el parche
     verificado de la seccion 5. -->

## Procedencia: qué es este contrato tras DEC-005

[`DEC-005`](../specs/decisions/DEC-005-troceado-de-wp-008-y-revision-de-la-pausa.md)
troceó WP-008 en dos encargos por **capa**:

| WP | Capa | Naturaleza |
|---|---|---|
| **WP-008**, este contrato | **Núcleo de protección**: reanclaje de `settings.json`, comando canónico fail-closed, preflight estructural, protocolo de parche y evidencia real de CI | Determinista, **reproducible en CI** |
| **WP-012** | **Capa empírica** completa | No reproducible en CI |

**Este contrato es autosuficiente.** No conserva ninguna de las diez secciones de
replanificación humana anteriores: todas gobernaban la capa empírica, y su
registro histórico vive en `DEC-005` y en las PRs de operador ya fusionadas, que
son inmutables.

**Relación con la capa empírica de WP-012.** Aquí **no se implementa, no se
ejecuta y no se usa como evidencia**; únicamente **se identifica WP-012 para
delimitar el alcance y las rutas prohibidas**. Este contrato no describe su
diseño interno, que corresponde a `DEC-005` y al futuro contrato de WP-012.

**Contabilidad de ciclos tras `DEC-006`.** Los once ciclos del contrato anterior
siguen registrados en `DEC-005`. El primer intento del contrato reducido quedó
abandonado en S1; como su recuento no era derivable de ningún archivo versionado,
el operador resolvió conservadoramente su presupuesto como **agotado: 2 / 2**.
Esa cifra es una decisión de gobierno, no un hallazgo fabricado.

[`DEC-006`](../specs/decisions/DEC-006-abandono-y-reinicio-controlado-de-wp-008.md)
concede a este contrato corregido y a la rama
`wp/WP-008-runtime-fail-closed-r2` un presupuesto **nuevo, explícito y máximo de
dos ciclos de corrección**, sin borrar ni renumerar los anteriores. El cómputo es
cerrado:

- La implementación inicial no consume ciclo.
- Se consume uno cuando, tras una pasada completa, una revisión independiente o
  una validación contractual exige cambios y la persona abre una nueva pasada de
  edición.
- Corregir y revalidar el mismo hallazgo dentro de esa pasada no abre otro.
- Una petición nueva posterior al cierre de la pasada abre el siguiente.
- Una parada de operación humana conserva su clasificación y exige decisión; no
  se recategoriza para alterar el contador.

`evidence/WP-008/cost.md` registra nominalmente la cifra final `N / 2` y la
relación de ciclos dentro de `C_EVIDENCIA`. **Un tercer ciclo exige otra decisión
humana, nueva, fechada y versionada.**

**Qué demuestra este WP y qué no.** Demuestra, de forma determinista y
reproducible en CI, tres cosas: la **aritmética del comando canónico**, la
**conformidad estructural** de la configuración, y el **bloqueo real del
preflight** en una ejecución de CI. **No demuestra que Claude Code cargue ni
aplique esa configuración**: esa afirmación corresponde exclusivamente a
**WP-012**, y `DEC-003` §6 la exige como tercera condición de salida de la pausa,
en pie de igualdad con esta. Ningún artefacto de este WP puede presentarse como
si acreditara lo que solo acredita WP-012.

**El calendario de la pausa no cambia.** `DEC-005` mantiene el punto de control
de `DEC-003` en el **2026-09-07** con la **misma semántica que ya tenía**: es la
fecha en que la pausa se revisa, no un vencimiento ni una autorización automática
de salida. Trocear WP-008 reparte el trabajo en dos capas y **no altera ninguna de
las tres condiciones de salida ni la fecha en que se revisan**.

## Objetivo y contexto

Instalar el núcleo de protección del runtime fail-closed y demostrarlo con
evidencia determinista:

1. El hook `PreToolUse` se invoca por una ruta **anclada** con
   `CLAUDE_PROJECT_DIR`, y un hook **ausente o sin permiso de ejecución** produce
   **exit 2** en lugar de dejar pasar la herramienta.
2. Las ocho reglas `Read` y `Edit` de `.claude/settings.json` quedan **ancladas a
   la raíz del proyecto** y no al directorio de trabajo.
3. Un **preflight estructural versionado** —`tests/runtime/check-config.sh`—
   comprueba ambas cosas en cada PR dentro del job **`Gobierno FDA`**, de modo que
   una configuración degradada **no se puede fusionar**.

Contexto, con las dos causas separadas porque son capas distintas:

**La invocación del hook.** `.claude/settings.json` invoca
`.claude/hooks/guard.sh` por **ruta relativa**. La documentación oficial de hooks
establece que **solo el código de salida `2` bloquea** y que cualquier otro código
es un error **no bloqueante** que deja continuar la herramienta. Un hook que no se
encuentra o que no es ejecutable no devuelve `2`. `DEC-003` §1 registró el
mecanismo como demostrado y su materialización como **no demostrada**; esa
distinción se mantiene y **este WP no la mide**.

**El anclaje de las reglas de permiso.** Las ocho reglas de archivo usan el
prefijo `./`. La documentación oficial de permisos establece que `./ruta` ancla en
el **directorio actual**, mientras que el anclaje a la raíz del proyecto, en
settings de proyecto, es `/ruta`. Las cuatro reglas `Read` que
[`SEC-001`](../specs/requirements/SEC-001-sin-secretos.md) criterio 4 da por
operativas, y las cuatro `Edit` que protegen workflows, `CODEOWNERS`, los hooks y
el propio `settings.json`, **dejan de coincidir** si el directorio de trabajo no
es la raíz.

Este WP es la **primera** de las tres condiciones del criterio de salida de
[`DEC-003`](../specs/decisions/DEC-003-pausa-migracion-y-contencion.md) §6. La
segunda es **WP-009**. La tercera es **WP-012**. Ninguna se toca aquí.

## Alcance (incluido / fuera de alcance)

**Incluido:**

- **Parche verificado único** en `evidence/WP-008/parche/`, que **una persona
  ejecuta** en dos fases y que cubre los dos archivos vedados:
  - `.github/workflows/ci.yml`: **un paso nuevo mínimo** en el job `Gobierno FDA`
    que **invoca** el preflight versionado.
  - `.claude/settings.json`: invocación del hook anclada con
    `CLAUDE_PROJECT_DIR` y con normalización explícita a `exit 2`, y las ocho
    reglas de archivo reancladas a la raíz del proyecto.
- **`tests/runtime/check-config.sh`**: preflight estructural, headless, sin red,
  con código de salida significativo y contadores propios.
- **`tests/runtime/test-check-config.sh`**: pruebas del preflight sobre fixtures
  propios, con contadores propios.
- **`tests/runtime/test-protocolo.sh`**: prueba headless de la máquina de estados
  del parche, con contadores propios, ejecutada íntegramente sobre fixtures.
- **`tests/runtime/capturar-ci-rojo.sh`**: comprobador headless de las dos
  barreras de CI, con adquisición acotada en el tiempo y validación pura.
- **`tests/runtime/test-capturar-ci-rojo.sh`**: pruebas del comprobador, headless
  y sin red, con contadores propios.
- **`tests/runtime/check-alcance-wp008.sh`**: comprobaciones locales de
  conformidad de este WP —alcance del diff e invariante de cuarentena—, headless y
  con contadores propios.
- **`tests/runtime/command-canonico.txt`** y
  **`tests/runtime/reglas-canonicas.txt`**: los dos oráculos versionados del
  preflight.
- **Fixtures propios del núcleo**, bajo cuatro prefijos disjuntos:
  `tests/runtime/fixtures/config/**` —configuración conforme y no conforme—,
  `tests/runtime/fixtures/proyecto/**` —proyecto completo para el protocolo del
  parche—, `tests/runtime/fixtures/ci/**` —respuestas de `gh` grabadas— y
  `tests/runtime/fixtures/cuarentena/**` —el archivo de patrones—.
- Evidencias en `evidence/WP-008/`: salidas de los comprobadores, logs del parche,
  y **dos ejecuciones reales de CI** —una en rojo que demuestra el bloqueo y la
  final en verde—.
- Cinco archivos de `docs/manual/`, la guía fundacional y `SEC-001`, justificados
  uno a uno en la sección 8.

**Fuera de alcance:**

- **La capa empírica, que es de WP-012.** Aquí **no se implementa, no se ejecuta y
  no se usa como evidencia**; únicamente **se identifica WP-012 para delimitar el
  alcance y las rutas prohibidas**: `tests/runtime/empirico/**` y
  `evidence/WP-012/**`. Ninguna invocación de `claude` forma parte de este WP.
- **WP-009 y la cadena de suministro.** Las acciones sin SHA son **deuda
  preexistente declarada** de `REQ-FDA-002`, asignada a WP-009. No son hallazgo
  bloqueante de este WP y no se corrigen aquí.
- **WP-010.** Ni la adquisición headless del coste, ni el validador de `cost.md`,
  ni el registro de excepciones.
- **WP-011.** Ni la frontera de revisión verificable, ni la reactivación de ningún
  workflow de agente.
- **`tests/guard/run-suite.sh`.** Prohibido por `DEC-003` §7 durante toda la
  pausa. El preflight vive en script propio con contadores propios
  **precisamente** para no alterar los suyos.
- **`.claude/hooks/guard.sh`.** No se modifica una línea. Este WP cambia **cómo se
  invoca** el hook y **cómo se interpreta su ausencia**, no lo que el hook hace.
- **WP-007 y WP-002.** Congelado y `blocked` respectivamente. No se tocan sus
  archivos, ni su worktree, ni sus evidencias, ni las siete huellas de `DEC-003`
  §1.
- **`work-packages/**` y `work-packages/ACTIVE`.** Actos del operador. Este WP no
  se activa, no se marca `done` y no mueve `ACTIVE`.
- **El ruleset y el estado externo de los workflows.** `claude.yml` y
  `code-review.yml` siguen `disabled_manually`; no se reactivan, no se editan y no
  se registran cambios sobre ellos. **`main` no se modifica para fabricar la
  evidencia roja ni durante el desarrollo**; solo cambiará mediante la eventual
  **fusión humana** de la PR aprobada.
- **Las listas `ask` y `allow` de `.claude/settings.json`**, y las cuatro reglas
  `Bash(...)` del `deny`: no cambian. Solo se reanclan las ocho reglas de archivo
  y se sustituye el bloque `hooks`.
- **Eliminar el paso «El hook guard.sh es ejecutable»** de `ci.yml`, aunque el
  preflight lo cubra. Quitarlo excede el mínimo, y el solape queda declarado.
- **`.agents/`, `.codex/` y `AGENTS.md`.** Estado operativo local en cuarentena por
  `DEC-003` §8: no se leen, no se versionan y no se modifican. El invariante es
  concreto y **se verifica de forma headless**, no por inspección:
  - **Ninguna herramienta de este WP enumera archivos sin versionar.**
  - **Ninguna invocación usa el comando de estado de Git en su modo por defecto**,
    ni con las formas que incluyen lo no versionado.
  - Cuando se necesita el estado de Git, se usa `--untracked-files=no`.
  - Los **diffs y las consultas del índice sí operan sobre contenido rastreado**
    —es su función— y **no leen el contenido de la cuarentena**, que no está
    versionada y por tanto nunca aparece en un diff ni en el índice.
  - Lo comprueba el modo `--cuarentena` de la sección 7b, con código de salida
    significativo.

## Archivos permitidos

- .claude/settings.json
- .github/workflows/ci.yml
- tests/runtime/check-config.sh
- tests/runtime/test-check-config.sh
- tests/runtime/test-protocolo.sh
- tests/runtime/capturar-ci-rojo.sh
- tests/runtime/test-capturar-ci-rojo.sh
- tests/runtime/check-alcance-wp008.sh
- tests/runtime/command-canonico.txt
- tests/runtime/reglas-canonicas.txt
- tests/runtime/fixtures/config/**
- tests/runtime/fixtures/proyecto/**
- tests/runtime/fixtures/ci/**
- tests/runtime/fixtures/cuarentena/**
- evidence/WP-008/**
- docs/02-guia-fabrica-desarrollo-agentica.md
- docs/manual/MANUAL.md
- docs/manual/01-instalacion.md
- docs/manual/02-ciclo-de-un-wp.md
- docs/manual/04-agentes.md
- docs/manual/07-troubleshooting.md
- specs/requirements/SEC-001-sin-secretos.md

<!-- VEINTIDOS patrones, lista CERRADA y disjunta de la de WP-012, conforme al
     reparto de DEC-005. No hay ningun comodin sobre tests/runtime/: cada script
     y cada oraculo se nombra, y los fixtures se acotan a cuatro prefijos
     propios. Asi ni el guard ni el escaner de cuarentena pueden alcanzar
     archivos de otro encargo.
     Las dos primeras rutas figuran aqui porque el diff de la PR las contiene y
     el contrato debe decir la verdad sobre lo que la PR toca, mismo criterio que
     WP-006 y WP-007. Listarlas NO autoriza a ningun agente a escribirlas: la
     capa de settings.json gana siempre.
     Los cinco archivos de docs/manual/ son nominales y minimos: no se usa
     docs/manual/** . La justificacion de cada uno esta en la seccion 8. -->

## Archivos prohibidos

- work-packages/**
- tests/guard/run-suite.sh
- tests/guard/**
- tests/runtime/empirico/**
- evidence/WP-012/**
- .claude/hooks/guard.sh
- .claude/hooks/**
- .claude/agents/**
- .claude/skills/**
- .github/workflows/claude.yml
- .github/workflows/code-review.yml
- .github/pull_request_template.md
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

<!-- Los dos prefijos de WP-012 se prohiben EXPRESAMENTE, no por omision.
     Prohibido gana sobre permitido, asi que ni un descuido puede alcanzarlos.
     tests/guard/run-suite.sh figura aqui porque DEC-003 §7 obliga a que los
     contratos admitidos por la pausa lo incluyan entre sus prohibidos.
     docs/manual/05-bloqueos-y-parada.md se prohibe con doble razon: DEC-003 §7
     registra que ya tiene cambios pendientes en el worktree congelado de WP-007,
     y DEC-005 lo ha vuelto a modificar. Una tercera version agravaria esa
     reconciliacion.
     evidence/WP-007/** se prohibe porque las siete huellas de DEC-003 §1 deben
     permanecer intactas.
     REQ-FDA-003 figura en 'requisitos' del frontmatter porque este WP queda
     VINCULADO a el y lo VERIFICA: toca cinco archivos de docs/manual/ y ejecuta
     check-manual.py entre sus comandos de validacion. Y figura aqui, entre los
     prohibidos, porque el requisito es INMUTABLE para este WP: se satisface y se
     comprueba, no se enmienda. Las dos cosas son compatibles y deliberadas.
     SEC-001-sin-secretos.md es la UNICA ruta permitida bajo specs/requirements/. -->

## Contratos técnicos (interfaces, schemas, eventos, invariantes)

### 1. El cambio en `.claude/settings.json`

#### 1a. Invocación del hook

El bloque `hooks.PreToolUse` conserva **exactamente** el matcher actual
—`Edit|Write|MultiEdit|NotebookEdit|Bash`, la línea más sensible de toda la
configuración— y sustituye el `command`, que hoy es la ruta relativa
`.claude/hooks/guard.sh`, por una invocación que cumple tres cosas a la vez:

1. **Anclada** a la raíz del proyecto mediante `CLAUDE_PROJECT_DIR`.
2. **Fail-closed explícito**: hook ausente o sin permiso de ejecución produce
   **exit 2**.
3. **Normalización**: cualquier código distinto de `0` devuelto por el guard se
   traduce a `2`.

**Comando canónico**, en una sola línea lógica y transcrito aquí de forma literal
y contractual:

```
if [ -x "$CLAUDE_PROJECT_DIR/.claude/hooks/guard.sh" ]; then "$CLAUDE_PROJECT_DIR/.claude/hooks/guard.sh"; c=$?; [ "$c" -eq 0 ] && exit 0 || exit 2; else echo "guard.sh ausente o no ejecutable" >&2; exit 2; fi
```

**Por qué shell form y no exec form.** La documentación oficial recomienda la
**exec form** cuando se usa un marcador de ruta, y con razón: no hay tokenización
del shell y las rutas con espacios no necesitan comillas. Pero la exec form lanza
el ejecutable directamente y **no puede** convertir un fallo de lanzamiento en
`exit 2`, porque el proceso que debería devolver `2` es justo el que no arranca.
Como el punto 2 es el objetivo de este WP, y como crear un lanzador propio
exigiría un archivo nuevo bajo `.claude/hooks/` —ruta prohibida por este
contrato—, se usa **shell form** con la ruta entrecomillada. La desviación
respecto a la recomendación oficial es **deliberada, acotada y aquí registrada**.
El **caso 22** de la sección 3 demuestra que el comando funciona con una raíz que
contiene espacios.

#### 1b. Reanclaje de las ocho reglas de archivo, una a una

Correspondencia **uno a uno**: ocho reglas originales, ocho finales. Cuatro `Read`
y cuatro `Edit`.

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

Reglas tras este WP, ancladas a la raíz del proyecto. **Este es el conjunto
contractual exacto**, y es la fuente frente a la que se compara todo lo demás:

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

La documentación oficial establece que `/` ancla al origen de los settings —en
`.claude/settings.json` de proyecto, la raíz del repositorio— y que `**` atraviesa
directorios.

**Alcance exacto de lo que este WP acredita sobre esas reglas.** El preflight
verifica que el conjunto **declarado** es exactamente el de arriba —comprobación
9, elemento a elemento— y que ninguna regla queda con prefijo `./` ni sin anclar
—comprobación 6—. Eso es **verificación estructural**. **Que el runtime resuelva
esas reglas contra la raíz del proyecto es una afirmación de comportamiento y la
acredita WP-012.** Este contrato no la da por probada.

**Invariantes del cambio, los cinco:**

- **El matcher no cambia.** `Edit|Write|MultiEdit|NotebookEdit|Bash`, literal. Si
  `Bash` desapareciera, el hueco se reabriría entero.
- **Las listas `ask` y `allow` no cambian**, ni una entrada.
- **Las cuatro reglas `Bash(...)` del `deny` no cambian.**
- **No se añade ninguna clave nueva** a `settings.json` fuera de las descritas.
- **`guard.sh` no se toca.** Su lógica, su contrato de entrada y salida y sus
  códigos siguen siendo los mismos.

El conjunto resultante es **equivalente o más estricto** que el actual. Ninguna
ruta hoy denegada puede quedar permitida.

### 2. `tests/runtime/check-config.sh` — el preflight estructural

Script versionado, headless, sin red, sin prompts, con contadores propios e
independiente en todo de `tests/guard/run-suite.sh`.

**Interfaz:**

```bash
bash tests/runtime/check-config.sh [ruta_settings] [ruta_repo]
```

Ambos argumentos son opcionales y por defecto apuntan al repositorio real. El
argumento explícito manda sobre el valor por defecto, conforme al invariante **I4**
de [`ADR-001`](../specs/adr/ADR-001-runtime.md): es lo que permite validar un
candidato **antes** de sustituir el archivo real, y probar el propio preflight
contra fixtures.

**Salida:** una línea por comprobación y, al final,
`RESULTADO: N conformes · M no conformes`. **Exit `0`** si `M` es cero; **exit `1`**
si hay alguna no conformidad; **exit `2`** si los argumentos son inválidos o el
archivo no existe.

**Las nueve comprobaciones:**

| # | Comprobación | Criterio exacto |
|---|---|---|
| 1 | JSON válido | `settings.json` parsea con `python3 -m json.tool` |
| 2 | `PreToolUse` presente | Existe `hooks.PreToolUse` y es una lista no vacía |
| 3 | Matcher exacto | Algún grupo tiene `matcher` **igual, carácter a carácter**, a `Edit\|Write\|MultiEdit\|NotebookEdit\|Bash` |
| 4 | Comando canónico exacto | El `command` de ese grupo, tras normalizar secuencias de espacios a uno solo y recortar extremos, es **idéntico carácter a carácter** al oráculo `tests/runtime/command-canonico.txt` normalizado igual. Cubre a la vez el anclaje con `CLAUDE_PROJECT_DIR` y el fail-closed con `exit 2`, y **no basta con contener esas cadenas**: un comando inerte que las incluyera superaría una comprobación por subcadena y no supera esta |
| 5 | Guard presente y ejecutable | La ruta `.claude/hooks/guard.sh` bajo la raíz existe y `test -x` es cierto |
| 6 | Reglas ancladas | Ninguna regla `Read(...)` o `Edit(...)` empieza por `./` ni queda sin anclar |
| 7 | Sin reglas `Write(...)` inertes | Ninguna regla empieza por `Write(`; la forma que cubre las herramientas de edición es `Edit(...)` |
| 8 | Recuento | `permissions` contiene **exactamente ocho** reglas `Read(...)` o `Edit(...)` |
| 9 | Conjunto exacto | El conjunto de las ocho reglas coincide **elemento a elemento** con el oráculo `tests/runtime/reglas-canonicas.txt`: sin ausencias, sin reglas adicionales, sin sustituciones y sin duplicados. La comparación es determinista sobre listas ordenadas, de modo que una duplicación que compense una ausencia, o una sustitución que mantenga el total en ocho, **fallan igualmente** |

Las seis comprobaciones que `DEC-003` §6 y este contrato exigen como mínimo quedan
cubiertas así: JSON válido en 1, `PreToolUse` en 2, matcher exacto en 3, comando
anclado y fail-closed con `exit 2` en 4, y guard presente y ejecutable en 5. Las
comprobaciones 6 a 9 sostienen la sección 1b.

**Los dos oráculos.** `tests/runtime/command-canonico.txt` contiene el comando de
la sección 1a y `tests/runtime/reglas-canonicas.txt` contiene las ocho reglas de
la sección 1b, una por línea. Son el **oráculo versionado del test**, no la fuente
contractual: la fuente contractual es **este WP aprobado**, que transcribe ambas
cosas literalmente y que está **prohibido para el implementador** mientras el WP se
ejecuta.

**Qué previenen y qué no.** La comparación determinista previene la **deriva
accidental**: que alguien retoque el `command` o las reglas de `settings.json` y el
preflight lo dé por bueno. **No resiste una modificación coordinada** del
comprobador y de sus oráculos: quien edite a la vez `check-config.sh` y los dos
`.txt` puede hacer pasar cualquier configuración. Esa defensa no vive aquí y este
WP no la construye: vive en el **diff de la PR**, en la **revisión humana** y en el
**ruleset**.

**Prohibición explícita:** el preflight no lee ni escribe `tests/guard/**`, no
invoca `run-suite.sh` y no comparte contadores con ella.

### 3. `tests/runtime/test-check-config.sh` — pruebas del preflight

Contadores propios de correctas y fallidas, fixtures propios bajo
`tests/runtime/fixtures/config/`, y directorios de trabajo creados con `mktemp -d`
conforme a la sección 9 cuando haga falta escribir. **Veintidós casos.**

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

**Conjunto exacto de reglas, casos 13 a 16.** Los dos últimos mantienen el total en
ocho y **deben fallar igualmente**:

| # | Fixture | Total de reglas | Esperado |
|---|---|---|---|
| 13 | **Falta** una regla: se elimina `Read(/**/*.pem)` | siete | exit `1`, comprobaciones 8 y 9 |
| 14 | **Sobra** una regla: se añade `Edit(/docs/**)` | nueve | exit `1`, comprobaciones 8 y 9 |
| 15 | **Duplicada y ausente**: `Read(/**/.env*)` aparece dos veces y falta `Read(/**/id_rsa*)` | **ocho** | exit `1`, **comprobación 9**, con la comprobación 8 conforme |
| 16 | **Sustituida**: `Edit(/CODEOWNERS)` se cambia por `Edit(/README.md)` | **ocho** | exit `1`, **comprobación 9**, con la comprobación 8 conforme |

**Comportamiento del comando canónico, casos 17 a 22.** El test **ejecuta** el
comando con `CLAUDE_PROJECT_DIR` apuntando a fixtures y comprueba el código
resultante:

| # | Fixture | Esperado |
|---|---|---|
| 17 | Guard de fixture que sale `0` | comando sale **`0`** |
| 18 | Guard de fixture que sale `1` | comando sale **`2`** |
| 19 | Guard de fixture que sale `2` | comando sale **`2`** |
| 20 | Guard **ausente** en el fixture | comando sale **`2`** |
| 21 | Guard presente **sin bit de ejecución** en el fixture | comando sale **`2`** |
| 22 | Raíz de fixture **con un espacio** en el nombre, repitiendo 17 y 19 | comando sale **`0`** y **`2`** respectivamente |

**El hook real nunca se renombra, se sustituye ni pierde permisos durante estas
pruebas.** Todos los guards de los casos 17 a 22 son scripts triviales creados
dentro del fixture, y el bit de ejecución del caso 21 se manipula sobre el fixture.

**Qué demuestran los casos 20 y 21, con precisión.** Demuestran la **aritmética del
fail-closed**: que el comando canónico devuelve `2` cuando el guard falta o no es
ejecutable. Es exactamente la primera cláusula del criterio de salida de `DEC-003`
§6, y es **reproducible en CI**. **No demuestran** que Claude Code invoque ese
comando ni que su matcher intercepte herramienta alguna.

### 4. `.github/workflows/ci.yml` — un paso nuevo mínimo, cero lógica duplicada

En el job **`gobierno`** —`name: Gobierno FDA`—, inmediatamente después del paso
«El hook guard.sh es ejecutable», se añade un paso que **invoca** el script
versionado y nada más:

```yaml
      - name: Configuración del runtime fail-closed (preflight)
        run: bash tests/runtime/check-config.sh
```

**Invariantes:** la lógica **no se replica** dentro del YAML, que es la lección de
WP-006 ya aprendida y pagada; **no se añade ninguna acción ni dependencia**, porque
`bash` y `python3` ya están en el runner y `python3` ya se configura en ese job;
**no se toca ningún otro job, paso ni workflow**; y **no se modifica el ruleset**,
porque el paso hereda el carácter obligatorio de `Gobierno FDA`, que ya es check
bloqueante. El preflight bloquea desde el primer día sin tocar la configuración de
GitHub.

Los demás scripts de este WP **no** se añaden a CI: el contrato autoriza **un**
paso nuevo. Se ejecutan en local como comandos de validación y sus salidas son
evidencia.

### 5. El parche verificado — un solo protocolo, dos fases, tres estados

El agente entrega en `evidence/WP-008/parche/`:

1. `aplicar.sh` — headless, idempotente, sin red y sin prompts.
2. `huellas.sha256` — **cuatro** huellas: `ANTES` y `DESPUES` de
   `.claude/settings.json`, y `ANTES` y `DESPUES` de `.github/workflows/ci.yml`.
   Definen **tres estados reconocidos** y **dos fases**.
3. `settings.json.candidato` y `ci.yml.candidato`.
4. `README.md` — los comandos exactos que ejecuta la persona y qué debe ver.

**Es el mismo protocolo de parche verificado que WP-007, extendido a dos archivos y
dos fases. No se inventa un segundo.**

#### 5a. Interfaz

```bash
bash evidence/WP-008/parche/aplicar.sh [--root RUTA] rojo|verde
```

Sin `--root` opera sobre el **repositorio real**. Con `--root` opera
**exclusivamente** sobre una **copia externa de trabajo** de un fixture de
proyecto completo. La fase es obligatoria; cualquier otro argumento sale con exit
`2`.

**Semántica única de los fixtures de proyecto**, que rige en todo este contrato y
no admite ninguna otra lectura:

1. `tests/runtime/fixtures/proyecto/**` contiene **únicamente plantillas
   versionadas e inmutables**, y **ninguna prueba las modifica jamás**, ni
   siquiera de forma temporal o reversible.
2. `test-protocolo.sh` **copia** la plantilla que necesita a una **raíz de trabajo
   externa a la raíz física del repositorio**, creada conforme a la sección 9.
3. Esa **copia externa** —y solo ella— lleva el marcador `.fda-fixture` en su
   raíz. La plantilla versionada **no lo lleva y no puede llevarlo**.
4. **`--root` recibe exclusivamente esa copia externa.** Una ruta que canonicalice
   **dentro** de la raíz física del repositorio se rechaza con exit `2` **sin
   escribir nada**, de modo que `--root` no puede apuntar nunca a la plantilla
   versionada.

Donde el resto de este contrato dice «fixture» debe entenderse **la copia externa
de trabajo**, nunca la plantilla versionada.

#### 5b. Estados reconocidos

| Estado | `.claude/settings.json` | `.github/workflows/ci.yml` | Significado |
|---|---|---|---|
| **S0 — BASE** | `ANTES` | `ANTES` | Punto de partida |
| **S1 — ROJO AUTORIZADO** | `ANTES` | `DESPUES` | Preflight instalado y configuración aún no conforme. **Único estado intermedio autorizado** |
| **S2 — VERDE** | `DESPUES` | `DESPUES` | Estado final |

Cualquier otro par, señaladamente `settings = DESPUES` con `ci = ANTES`, **no es un
estado**: es un aborto fail-closed.

#### 5c. Transiciones

| Invocación | Estado de partida | Acción | Salida |
|---|---|---|---|
| `aplicar.sh rojo` | **S0** | S0 a S1 | `APLICADO ROJO (S1)`, exit `0` |
| `aplicar.sh rojo` | **S1** | ninguna | `YA EN ROJO`, exit `0` |
| `aplicar.sh rojo` | cualquier otro | **aborta sin escribir** | `ABORTADO`, exit `2` |
| `aplicar.sh verde` | **S1** | S1 a S2 | `APLICADO VERDE (S2)`, exit `0` |
| `aplicar.sh verde` | **S2** | ninguna | `YA EN VERDE`, exit `0` |
| `aplicar.sh verde` | cualquier otro | **aborta sin escribir** | `ABORTADO`, exit `2` |

El orden no es opcional: `verde` desde S0 y `rojo` desde S2 abortan.

#### 5d. Fase roja — S0 a S1, toca solo `ci.yml`

1. **Instantánea previa, solo rastreado y staged.** Se calculan dos huellas:
   - `H_OTROS_ANTES` = SHA-256 del diff binario del árbol **excluyendo por
     pathspec** `.github/workflows/ci.yml`
   - `H_STAGED_ANTES` = SHA-256 del diff binario del índice
   Se registra además el estado de Git en su forma con `--untracked-files=no`
   **como información**, que no sustituye a ninguna de las dos huellas. Ninguna de
   estas órdenes enumera archivos sin versionar.
2. Calcular las cuatro huellas y exigir **S0**. Si es S1, `YA EN ROJO` y exit `0`.
   Cualquier otro par, `ABORTADO` y exit `2` **sin escribir**.
3. Crear el directorio temporal conforme a la **sección 9** y copiar allí el
   `ci.yml` original.
4. **Validar el candidato antes de sustituir**: `validate-workflows.py` invocado
   con **argumentos nominales** —el `ci.yml.candidato` y los otros dos workflows
   reales—, exit `0`. Si falla, aborta **sin haber tocado nada**. Es la misma
   validación que la batería A ya exigió en S0, repetida aquí como última barrera
   antes de sustituir.
5. Sustituir `.github/workflows/ci.yml`.
6. Validaciones posteriores: huella `CI_DESPUES`; huella de `settings.json`
   **sigue en `ANTES`**; y la **comprobación propia de la fase**:
   `bash tests/runtime/check-config.sh` sale **`1`** y señala exactamente las
   comprobaciones **4, 6 y 9**. La comprobación **8 permanece conforme**, porque el
   `settings.json` en `ANTES` sigue teniendo **ocho** reglas de archivo: lo que
   falla es su forma —todas con prefijo `./`— y por tanto su pertenencia al
   conjunto canónico, además del `command` no anclado. Si el preflight saliera `0`,
   la demostración en rojo sería imposible y se aborta.
7. **Comprobación de alcance de la fase, por huellas.** Se recalculan
   `H_OTROS_DESPUES` y `H_STAGED_DESPUES` con los mismos comandos del paso 1, y
   deben cumplirse las tres condiciones a la vez:
   - `H_OTROS_DESPUES` es **idéntica** a `H_OTROS_ANTES`: ningún otro contenido
     rastreado cambió
   - `H_STAGED_DESPUES` es **idéntica** a `H_STAGED_ANTES`: el índice no se tocó
   - `.github/workflows/ci.yml` pasó de `CI_ANTES` a `CI_DESPUES`
   La exclusión por pathspec es lo que hace válida la comparación **aunque ya
   existieran otros cambios del WP antes de empezar la fase**.
8. Ante cualquier fallo posterior a la sustitución, restaurar `ci.yml`, verificar
   que el par vuelve a **S0**, imprimir `ROLLBACK APLICADO` y salir con código
   distinto de cero.
9. Si todo pasa: `APLICADO ROJO (S1)` y exit `0`.

#### 5e. Fase verde — S1 a S2, toca solo `settings.json`

1. **Instantánea previa, solo rastreado y staged.** Se calculan dos huellas:
   - `H_OTROS_ANTES` = SHA-256 del diff binario del árbol **excluyendo por
     pathspec** `.claude/settings.json`
   - `H_STAGED_ANTES` = SHA-256 del diff binario del índice
   Se registra además el estado de Git con `--untracked-files=no` **como
   información**.
2. Calcular las cuatro huellas y exigir **S1**. Si es S2, `YA EN VERDE` y exit `0`.
   Cualquier otro par, `ABORTADO` y exit `2` **sin escribir**.
3. Crear el directorio temporal conforme a la **sección 9** y copiar allí el
   `settings.json` original.
4. **Validar el candidato antes de sustituir**: `python3 -m json.tool` sobre el
   candidato, y `bash tests/runtime/check-config.sh` con **los dos argumentos
   explícitos** —candidato y raíz— con exit **`0`**. Si falla, aborta **sin haber
   tocado nada**.
5. Sustituir `.claude/settings.json`.
6. Validaciones posteriores: huella `SETTINGS_DESPUES`; huella de `ci.yml` **sigue
   en `DESPUES`**; `bash tests/runtime/check-config.sh` con exit **`0`**;
   `bash tests/runtime/test-check-config.sh` con exit `0`.
7. **Comprobación de alcance de la fase, por huellas.** `H_OTROS_DESPUES` idéntica
   a `H_OTROS_ANTES`; `H_STAGED_DESPUES` idéntica a `H_STAGED_ANTES`; y
   `.claude/settings.json` pasó de `SETTINGS_ANTES` a `SETTINGS_DESPUES`.
8. Ante cualquier fallo posterior a la sustitución, restaurar `settings.json`,
   verificar que el par vuelve a **S1** y no a S0, imprimir `ROLLBACK APLICADO` y
   salir con código distinto de cero.
9. Si todo pasa: `APLICADO VERDE (S2)` y exit `0`.

#### 5f. Dónde van las copias de seguridad y los logs

**Las copias de seguridad viven fuera del repositorio, y eso se garantiza por
construcción, no por inventario.** `aplicar.sh` crea la copia **exclusivamente** en
el directorio temporal de la sección 9, y **registra en el log su ruta física**. La
ausencia de copias dentro del repositorio se demuestra con tres cosas, y ninguna
enumera lo no versionado:

1. **Construcción:** la única ruta de escritura de la copia es ese directorio
   temporal, y así se lee en el script.
2. **Pruebas de fixture, por instantánea completa:** `test-protocolo.sh` calcula,
   **antes** de cada fase sobre `--root`, una instantánea **NUL-safe de todas las
   entradas situadas dentro de la raíz física de la copia externa, excluyendo por completo
   `.git/**`**, porque los comandos de Git pueden actualizar metadatos internos
   aunque no cambie el contenido del proyecto. Por entrada registra **ruta
   relativa**, **tipo** y **modo**; para **archivos regulares**, el **SHA-256 de sus
   bytes**; para **enlaces simbólicos**, además el **destino literal** del enlace.
   Después de la fase calcula la misma instantánea. Deben cumplirse las tres
   condiciones a la vez:
   - **Excluyendo `.git/**` y únicamente el archivo objetivo de esa fase**, ambas
     instantáneas son **idénticas**.
   - El **archivo objetivo** cambió **exactamente** de su huella contractual de
     origen a la de destino.
   - **No aparece ni desaparece ninguna otra ruta** dentro del fixture: ni copias,
     ni logs, ni temporales.
   La enumeración es admisible porque se limita a una **copia externa y temporal**
   y **nunca alcanza el repositorio real, ni su cuarentena, ni la plantilla
   versionada de la que se copió**.
3. **Huella staged:** `H_STAGED` permanece idéntica durante toda la fase, de modo
   que **nada entró en el índice**.

**El árbol de plantillas versionadas queda intacto, y se demuestra con una
instantánea determinista del árbol completo, no con el hash de un archivo
suelto.** `tests/runtime/fixtures/proyecto/**` **es un árbol, no una plantilla
singular**: una comprobación que solo mirase «el SHA-256 de la plantilla» no vería
un alta, una baja ni un renombrado. `test-protocolo.sh` construye por tanto un
**manifiesto NUL-safe del árbol entero**, que registra para cada entrada:

| Campo | Qué recoge |
|---|---|
| **Ruta relativa** | Delimitada por **NUL** y ordenada de forma determinista por sus **bytes**, de modo que espacios y saltos de línea no pueden partir ni fundir entradas |
| **Tipo** | Archivo regular, directorio, enlace simbólico u otro |
| **Modo** | Permisos en octal |
| **SHA-256** | De los **bytes** de cada archivo regular |
| **Destino** | El **destino literal** de cada enlace simbólico, si lo hubiera |

El manifiesto lleva además el **conjunto exacto de rutas**, el **número de
entradas** y un **digest agregado**, que es el SHA-256 del manifiesto serializado
completo. Comparar dos digests agregados detecta en una sola operación **altas,
bajas, renombrados y cambios de tipo, de modo, de contenido o de destino de
enlace**; los campos por entrada existen para que el fallo diga **cuál** cambió y
**en qué**, y no solo que algo cambió.

**Cuándo se captura cada imagen, sin ambigüedad:**

- La **preimagen** se captura **una sola vez**, al arrancar `test-protocolo.sh`,
  **antes del primer escenario** y **antes de copiar nada**.
- Dentro de **cada escenario** se captura una **postimagen intermedia**
  **inmediatamente después** de la última invocación de `aplicar.sh` de ese
  escenario, y se compara con la preimagen.
- La **postimagen final** se captura **al terminar el último escenario**, después
  de que todas las limpiezas hayan corrido.

`test-protocolo.sh` **falla ante cualquier diferencia** entre la preimagen y
cualquiera de las postimágenes —agregada o por entrada—, **nombra la ruta y el
campo** que cambiaron y no continúa. Un árbol de plantillas alterado invalida toda
la evidencia de protocolo, de modo que este fallo no se degrada ni se ignora.

**No se afirma que se haya inventariado globalmente lo no versionado**, porque
hacerlo alcanzaría la cuarentena de `DEC-003` §8.

**Los logs de las dos fases reales tampoco se escriben dentro del repositorio
mientras la fase corre.** Escribirlos en `evidence/WP-008/` produciría una segunda
ruta modificada y rompería la comprobación de alcance de la propia fase. Por tanto:
`aplicar.sh` genera su log **en el directorio temporal de la fase**; el log incluye
el código de salida, las cuatro huellas antes y después, las validaciones
ejecutadas y la ruta física del directorio; los directorios **se conservan hasta
llegar a S2**; y los logs se incorporan a `evidence/WP-008/parche/` **únicamente
después** de que `C_VERDE` esté publicado y verde, durante la preparación de
`C_EVIDENCIA`.

Los logs de las **pruebas negativas y de los rollbacks sobre fixtures** sí pueden
prepararse antes, porque no modifican los archivos reales.

#### 5g. `tests/runtime/test-protocolo.sh` — la máquina de estados, probada sobre copias externas

Prueba headless, con contadores propios, sin red, sin prompts y sin TTY. Para cada
escenario **copia** la plantilla versionada que necesita de
`tests/runtime/fixtures/proyecto/` a una **raíz de trabajo externa** conforme a la
sección 9, añade el marcador `.fda-fixture` **a esa copia**, ejercita **toda** la
máquina S0, S1 y S2 mediante `aplicar.sh --root` sobre ella, y comprueba al
terminar que **el árbol de plantillas versionadas conserva íntegra su
instantánea**, según la sección 5f. **Doce escenarios.**

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

Las comprobaciones de instantánea de la sección 5f y las de directorio temporal de
la sección 9 se integran **como subcomprobaciones de estos doce escenarios**
—señaladamente 1, 3, 9, 10, 11 y 12—. **El total permanece en doce.**

**El failpoint de los escenarios 9 y 10** es determinista y está documentado en el
`README.md` del parche. Se activa con una variable de entorno y **solo** cuando
`--root` apunta a una copia externa que contiene el marcador `.fda-fixture` en su
raíz **y que canonicaliza fuera del repositorio**. Si se intenta activar sin
`--root`, contra una raíz sin ese marcador, o contra una raíz interna al
repositorio, `aplicar.sh` **rechaza con exit `2` sin escribir nada**. El
repositorio real no lleva ese marcador y no puede llevarlo, y la plantilla
versionada tampoco.

#### 5h. Las cuatro ejecuciones reales

Sobre los dos archivos reales, la persona ejecuta **exactamente cuatro**
invocaciones y ninguna más:

1. `aplicar.sh rojo` sobre **S0**.
2. `aplicar.sh rojo` de nuevo en **S1**, para la evidencia de idempotencia.
3. `aplicar.sh verde` sobre **S1**.
4. `aplicar.sh verde` de nuevo en **S2**, para la evidencia de idempotencia.

**No se crean estados inválidos deliberadamente en los dos archivos reales.** Los
abortos, los pares invertidos, los estados desconocidos y los rollbacks se
demuestran **sobre fixtures**, con `--root`.

### 6. `tests/runtime/capturar-ci-rojo.sh` — los comprobadores de las barreras

La composición de los runs la valida un script versionado, no una persona.
**Formas de invocación admitidas, y ninguna otra combinación ni orden:**

```bash
bash tests/runtime/capturar-ci-rojo.sh RUN_ID C_ROJO [DIRECTORIO_SALIDA]
bash tests/runtime/capturar-ci-rojo.sh --verde RUN_ID C_VERDE [DIRECTORIO_SALIDA]
bash tests/runtime/capturar-ci-rojo.sh --validar ARCHIVO_JSON C_ROJO
bash tests/runtime/capturar-ci-rojo.sh --fixture-root RUTA RUN_ID C_ROJO [DIRECTORIO_SALIDA]
bash tests/runtime/capturar-ci-rojo.sh --fixture-root RUTA --verde RUN_ID C_VERDE [DIRECTORIO_SALIDA]
```

#### 6a. Modo de adquisición

- Usa `gh` **exclusivamente en lectura**.
- La adquisición usa el conjunto exacto
  `status,conclusion,headSha,databaseId,url,event,jobs`. Tanto el run rojo como el
  verde exigen `event=pull_request`.
- **Rechaza con exit `2` un directorio de salida no conforme ANTES de invocar
  `gh`**: la comprobación de rutas precede a todo acceso a la red.
- Sin `DIRECTORIO_SALIDA` lo crea conforme a la **sección 9**, e imprime su ruta
  física, que se conserva hasta `C_EVIDENCIA`.
- Espera mediante **polling**, con un **tiempo máximo explícito y contractual de 20
  minutos** y un intervalo de 15 segundos. **No existe la espera indefinida.**
- Si el tiempo máximo expira sin que el run haya terminado, **sale con exit `2`**.
- Guarda la respuesta de `gh` **fuera del repositorio** y llama al **validador
  puro**, propagando su código de salida.

#### 6b. Modo `--validar`

- **No usa red** y **no recibe directorio de salida**.
- Recibe un JSON ya adquirido y el hash `C_ROJO`.
- Valida las ocho condiciones de la sección 6c y devuelve `0`, `1` o `2` según el
  contrato común.

#### 6c. Las ocho validaciones del run rojo

Antes de evaluar conclusiones, el validador exige una **forma cerrada**. El
conjunto de jobs debe ser exactamente, sin ausencias, extras ni duplicados:

1. `Gobierno FDA`.
2. `Lint · Shell · Tests · Manual`.
3. `Escaneo de secretos`.

Dentro de `Gobierno FDA`, el campo `number` no es contractual. Sí lo son los
nombres exactos, la unicidad y el orden relativo de estos oráculos:

**Housekeeping previo:**

- `Set up job` → `success`.

**Pasos declarados anteriores al preflight:**

1. `Run actions/checkout@v4`.
2. `Run actions/setup-python@v5`.
3. `Instalar PyYAML`.
4. `Archivos de gobierno presentes`.
5. `El hook guard.sh es ejecutable`.

**Preflight, exactamente una vez:**

- `Configuración del runtime fail-closed (preflight)` → `failure`.

**Pasos declarados posteriores al preflight:**

1. `Estado operativo coherente (ACTIVE)`.
2. `El guard bloquea fuera de alcance (suite completa)`.
3. `Workflows válidos`.
4. `Manual sin enlaces rotos`.
5. `El manual acompaña a los cambios de proceso`.

**Housekeeping posterior:**

1. `Post Run actions/setup-python@v5` → `skipped`.
2. `Post Run actions/checkout@v4` → `success`.
3. `Complete job` → `success`.

Los cinco pasos declarados anteriores deben estar en `success`; los cinco
posteriores, en `skipped`. Falta, sobra, duplicación, nombre o versión distinta,
orden relativo distinto, job desconocido o conjunto de jobs distinto producen
exit `2`: la forma del run es desconocida y no se interpreta. Una forma exacta
con una conclusión incorrecta produce exit `1`.

| # | Validación |
|---|---|
| 1 | El run ha **terminado** |
| 2 | `headSha` es igual a `C_ROJO` |
| 3 | `event` es `pull_request`; `conclusion` es `failure`, y **nunca** `cancelled` |
| 4 | El housekeeping previo y los cinco pasos declarados anteriores tienen sus conclusiones exactas |
| 5 | El único paso del **preflight** y el job `Gobierno FDA` están en `failure` |
| 6 | Los cinco pasos declarados posteriores y el housekeeping posterior tienen sus conclusiones exactas |
| 7 | Los otros dos jobs exactos del workflow están en `success` |
| 8 | **No existe una segunda causa de fallo** en todo el run |

**Códigos de salida, comunes a todos los modos:** **`0`** solo cuando la
composición es exacta; **`1`** ante composición no conforme; **`2`** ante
argumentos inválidos, entorno inválido, JSON malformado, respuesta de `gh`
inutilizable, **forma desconocida**, directorio de salida no conforme o expiración
del tiempo máximo.

Todo exit `2` imprime exactamente una línea estable `motivo=VALOR`. El conjunto
cerrado es `forma_desconocida`, `argumentos`, `entorno`, `json_inutilizable`,
`adquisicion`, `salida_no_conforme` y `timeout`. La barrera conserva esa línea:
una persona puede distinguir un cambio de forma de un problema operativo sin
interpretar el JSON ni convertir el resultado en verde.

En modo `--verde`, `event` es una **puerta de procedencia de la adquisición**,
común al modo real y al fixture, no una cuarta condición de composición de la
sección 6f. Ausente produce exit `2` con `motivo=forma_desconocida`; presente pero
distinto de `pull_request`, exit `1`. Las tres condiciones de 6f permanecen
terminación, `headSha` y `conclusion`.

La condición 8 recorre todos los pasos de todos los jobs, incluido el
housekeeping, y excluye únicamente el objeto exacto del preflight. La clasificación
de housekeeping no puede ocultar una segunda causa de fallo.

El fixture conforme reproduce sintéticamente esta forma real, con `run_id`, URL y
hashes de prueba. La captura del run abandonado no se copia como fixture: se
conserva únicamente como evidencia histórica conforme a `DEC-006`.

**La persona únicamente lanza el comprobador.** No interpreta la salida de `gh` y
no emite el veredicto.

#### 6d. `tests/runtime/test-capturar-ci-rojo.sh` — treinta y dos casos

Headless, **sin red**, con contadores propios, sobre respuestas de `gh` **grabadas**
en `tests/runtime/fixtures/ci/`.

```bash
bash tests/runtime/test-capturar-ci-rojo.sh
```

**Casos 1 a 12: el modo puro `--validar`.** El conforme y los negativos se
reexpresan con la forma sintética real y cubren, una a una, las ocho validaciones:
las dos variantes del caso 7 se derivan determinísticamente del fixture conforme
dentro del temporal externo y no exigen otro fixture versionado.

| # | Fixture | Validación que debe bloquear | Esperado |
|---|---|---|---|
| 1 | JSON sintético de forma real completamente conforme | — | exit **`0`** |
| 2 | Run **no terminado** | 1 | exit `1` |
| 3 | `headSha` incorrecto | 2 | exit `1` |
| 4 | `conclusion` igual a `success` | 3 | exit `1` |
| 5 | `conclusion` igual a `cancelled` | 3 | exit `1` |
| 6 | Un paso **anterior** al preflight distinto de `success` | 4 | exit `1` |
| 7 | Preflight o conclusión del job `Gobierno FDA` distintos de `failure` | 5 | dos subcomprobaciones, ambas exit `1` |
| 8 | Un paso **posterior** del mismo job distinto de `skipped` | 6 | exit `1` |
| 9 | Otro job distinto de `success` | 7 | exit `1` |
| 10 | **Segunda causa de fallo** en el run | 8 | exit `1` |
| 11 | JSON malformado o inutilizable | — | exit **`2`** |
| 12 | Argumentos inválidos | — | exit **`2`** |

**Casos 13 a 16: la envoltura de adquisición**, en `modo=fixture` mediante
`--fixture-root` y la costura de la sección 6e, **sin red en ningún caso**:

| # | Escenario | Esperado |
|---|---|---|
| 13 | **Rechazos de la costura y de las rutas**, con trece subcomprobaciones nombradas | exit **`2`** en las trece, y en las trece el test demuestra que **ni el stub ni el `gh` real llegaron a ejecutarse** |
| 14 | Stub que entrega primero un estado **no terminado** y después una composición **conforme** | exit **`0`**, demostrando polling, persistencia externa, delegación al validador y `modo=fixture` en el log |
| 15 | Fallo del stub, o respuesta de adquisición inutilizable | exit **`2`** |
| 16 | **Expiración del tiempo máximo**, con el stub devolviendo siempre estado no terminado y `FDA_CI_TEST_TIMEOUT_SECONDS` reducido, **sin espera real prolongada** | exit **`2`** |

**Subcomprobaciones del caso 13.** El caso sigue siendo **uno**; cada
subcomprobación tiene nombre propio en la salida:

| Nombre | Escenario |
|---|---|
| `salida-dentro-del-repo` | Directorio de salida que resuelve físicamente dentro del repositorio real |
| `salida-symlink-al-repo` | Directorio de salida que es un **enlace simbólico** y resuelve dentro del repositorio real |
| `salida-inexistente` | Directorio de salida **proporcionado pero inexistente**: se rechaza y **no se crea** |
| `tmpdir-dentro-del-repo` | `TMPDIR` apunta dentro del repositorio real, de modo que el directorio creado por `mktemp -d` quedaría dentro: se rechaza conforme a la sección 9 |
| `real-con-gh` | `FDA_CI_TEST_GH` presente en adquisición **real** |
| `real-con-interval` | `FDA_CI_TEST_INTERVAL_SECONDS` presente en adquisición **real** |
| `real-con-timeout` | `FDA_CI_TEST_TIMEOUT_SECONDS` presente en adquisición **real** |
| `fixture-variable-ausente` | Modo fixture con una de las tres variables ausente |
| `duracion-invalida` | Duración no numérica, cero o negativa |
| `raiz-dentro-del-repo` | Raíz de fixture que canonicaliza dentro del repositorio real. Como aserción subordinada, una raíz hermana externa que solo comparte su prefijo textual y carece de `.fda-fixture` sale `2` con `motivo=entorno` por marcador ausente, **nunca por contención**; ni el stub ni el `gh` real se ejecutan |
| `marcador-ausente` | Raíz sin `.fda-fixture`, o con un `.fda-fixture` que no es archivo regular |
| `marcador-symlink` | `.fda-fixture` es un **enlace simbólico**, aunque su destino sea un archivo regular |
| `stub-fuera-o-symlink` | Stub situado fuera de la raíz física del fixture, o enlace simbólico hacia un ejecutable externo |

**Casos 17 a 19: el modo `--verde`**, también en `modo=fixture` y sin red:

| # | Escenario | Esperado |
|---|---|---|
| 17 | Adquisición verde por stub: primero **no terminado** y después **`success` conforme** | exit **`0`** |
| 18 | Verde terminado con **`headSha` incorrecto** | exit **`1`**, validación 2 |
| 19 | Verde sin `event`, con evento distinto o con conclusión distinta de `success` | tres subcomprobaciones: exit `2` con `motivo=forma_desconocida`, exit `1` por puerta de procedencia y exit `1` por validación 3 |

**Casos 20 a 32: forma real cerrada y conclusiones del housekeeping.** Las
variaciones se derivan determinísticamente del fixture conforme dentro del
temporal externo del test; no copian la captura real ni crean evidencia.

| # | Variación | Esperado |
|---|---|---|
| 20 | Falta `event`, o es distinto de `pull_request` | dos subcomprobaciones: exit `2` con `motivo=forma_desconocida` y exit `1` por validación 3 |
| 21 | Falta un paso declarado anterior | exit `2`, `motivo=forma_desconocida` |
| 22 | Falta un paso declarado posterior | exit `2`, `motivo=forma_desconocida` |
| 23 | Falta un paso de housekeeping | exit `2`, `motivo=forma_desconocida` |
| 24 | Aparece un paso desconocido | exit `2`, `motivo=forma_desconocida` |
| 25 | Cambia la versión de una acción declarada o de su post-paso | exit `2`, `motivo=forma_desconocida` |
| 26 | Cambia el orden relativo contratado | exit `2`, `motivo=forma_desconocida` |
| 27 | Se duplica un paso declarado | exit `2`, `motivo=forma_desconocida` |
| 28 | `Set up job` no está en `success` | exit `1`, validación 4 |
| 29 | `Post Run actions/setup-python@v5` no está en `skipped` | exit `1`, validación 6 |
| 30 | `Post Run actions/checkout@v4` no está en `success` | exit `1`, validación 6 |
| 31 | `Complete job` no está en `success` | exit `1`, validación 6 |
| 32 | Falta o sobra un job | dos subcomprobaciones, ambas exit `2` con `motivo=forma_desconocida` |

El test termina en **exit `0`** con **32 correctas y 0 fallidas**. La invocación
**real** de `capturar-ci-rojo.sh`, en cualquiera de sus dos modos de adquisición, no
forma parte de la batería de validación: vive **exclusivamente en la cronología**.

#### 6e. La costura de pruebas: nombres, modo y rechazo en producción

Los casos que ejercitan la envoltura de adquisición usan una **costura explícita**
con tres nombres contractuales:

```
FDA_CI_TEST_GH                 ejecutable de gh que debe invocarse
FDA_CI_TEST_INTERVAL_SECONDS   intervalo de polling
FDA_CI_TEST_TIMEOUT_SECONDS    tiempo maximo de espera
```

**Solo se aceptan** cuando la invocación incluye el modo explícito
`--fixture-root RUTA`, **la raíz está fuera del repositorio real** y **contiene el
marcador `.fda-fixture`**.

Reglas obligatorias, sin excepción. **Toda la validación es física, sobre rutas
canonicalizadas, no textual:**

- **En adquisición real** —sin `--fixture-root`—, la presencia de **cualquiera** de
  las tres variables produce **exit `2` antes de ejecutar `gh`**.
- **Raíz del fixture.** Se canonicaliza físicamente y **debe quedar fuera de la
  raíz física del repositorio**. Una raíz dentro, o que resuelva dentro tras seguir
  enlaces, sale **`2`**.
- **Marcador.** `.fda-fixture` debe ser un **archivo regular** situado en la raíz
  canonicalizada **y además no ser un enlace simbólico**: `test ! -L` debe ser
  cierto sobre él. Su ausencia, que no sea archivo regular, o que sea un enlace
  simbólico, sale **`2`**.
- **Stub.** `FDA_CI_TEST_GH` debe ser un **archivo regular ejecutable** y **no un
  enlace simbólico**. Su **ruta física** debe quedar **contenida dentro de la raíz
  física del fixture**. Un stub fuera del fixture, o un enlace simbólico hacia un
  ejecutable externo, sale **`2`**.
- **Duraciones.** Ambas deben ser enteros positivos. No numéricas, cero o negativas
  salen **`2`**. La ausencia de cualquiera de las tres variables en modo fixture
  sale **`2`**.
- **Directorio de salida, cuando se proporciona.** Debe **existir previamente**,
  ser un **directorio real**, **no ser un enlace simbólico**, y su **ruta física**
  debe quedar **fuera del repositorio real**. Un directorio inexistente, un enlace
  simbólico, o una ruta que resuelva dentro del repositorio, salen **`2`**.
- **Directorio de salida, cuando no se proporciona.** Se crea conforme a la
  **sección 9**.
- **Nunca se crea primero una ruta proporcionada por el llamante para poder
  canonicalizarla.** Si no existe, se rechaza; no se materializa para
  inspeccionarla.
- **Orden.** Todas las comprobaciones del fixture, del marcador, del stub y del
  directorio de salida ocurren **antes** de ejecutar el stub y **antes** de
  cualquier acceso a la red.
- El log registra **inequívocamente** `modo=real` o `modo=fixture` en su primera
  línea.
- **Una captura admisible como evidencia real solo puede proceder de `modo=real`.**

#### 6f. Modo `--verde`

Verifica el run de `C_VERDE` con el mismo rigor headless que el rojo,
**reutilizando el polling acotado a 20 minutos** y las mismas reglas de directorio
de salida y de costura. Comprueba **tres** condiciones:

| # | Validación |
|---|---|
| 1 | El run ha **terminado** |
| 2 | `headSha` es igual a `C_VERDE` |
| 3 | `conclusion` es `success` |

Devuelve **`0`** si es conforme; **`1`** si el run terminó pero la composición no es
conforme o si la puerta de procedencia de la sección 6c recibe un `event` presente
distinto de `pull_request`; **`2`** ante argumentos, entorno, adquisición
inutilizable, expiración del tiempo máximo o forma desconocida por `event` ausente.

**Por qué existe.** Sin él, una sesión de agente o el empujón de `C_EVIDENCIA`
podrían llegar **antes** de que el run verde acabe: la concurrencia del workflow lo
cancelaría y se perdería la evidencia verde. **La persona lanza el modo `--verde` y
no interpreta su salida.** El contrato de parada es exacto:

- **Exit `1` — el run terminó pero no es conforme.** **Parar.** No se reabre ninguna
  sesión de agente, no se prepara `C_EVIDENCIA`, no se empuja nada, no hay `amend`,
  `rebase` ni force-push. Se **solicita decisión humana**. El contrato **no autoriza
  automáticamente** ni relanzar el run en GitHub ni reiniciar la rama o la PR. El
  mismo protocolo se aplica si `event` está presente pero no es `pull_request`.
- **Exit `2` con `motivo=forma_desconocida` por `event` ausente.** **Parar** y
  **solicitar decisión humana**. No se repite la consulta, no se amplía el oráculo
  por patrón y no se interpreta el JSON manualmente.
- **Exit `2` por expiración del tiempo máximo, por adquisición inutilizable o por
  entorno inválido.** **Parar** y **solicitar decisión humana**. Solo podrá
  repetirse la comprobación —que es de **solo lectura**— sobre **el mismo `RUN_ID`
  y el mismo `C_VERDE`** si la persona lo autoriza expresamente.
- **En ningún caso** se crea un commit adicional ni se altera la cadena `C_ROJO` a
  `C_VERDE` a `C_EVIDENCIA` por iniciativa del agente.

### 7. `tests/runtime/check-alcance-wp008.sh` — comprobaciones locales de conformidad

Dos responsabilidades, ambas **específicas de este WP**, ambas locales y
redundantes, y ninguna genérica.

```bash
bash tests/runtime/check-alcance-wp008.sh [--lista ARCHIVO_NUL]
bash tests/runtime/check-alcance-wp008.sh --cuarentena
bash tests/runtime/check-alcance-wp008.sh --cuarentena --lista-scripts ARCHIVO_NUL
```

#### 7a. Modo de alcance

Sin argumentos toma las rutas del diff de la rama contra `main` en su forma
delimitada por NUL. Con `--lista` toma una lista **delimitada por NUL** de un
archivo, lo que permite ejercitarlo de forma determinista sin depender de un diff
real.

Compara **cada** ruta con la lista exacta de archivos y prefijos permitidos por
este WP —los **veintidós** patrones de `## Archivos permitidos`, transcritos
literalmente en el script—, es **NUL-safe** en todo el recorrido, **enumera todas**
las rutas no admitidas y sale **`0`** si todas están dentro, **`1`** si aparece
alguna fuera y **`2`** ante argumentos o entorno inválidos.

**Qué NO es.** Esta comprobación es **local y redundante para WP-008** y **no cierra
ni satisface `REQ-FDA-001`**. El mecanismo post-hoc global que ese requisito exige
sigue **pendiente de WP-002 y WP-005**, y esta pausa no lo adelanta. WP-008
endurece la **capa preventiva** y verifica **su propio diff**.

**Semántica del modo, agregada y ejecutable.** `bash tests/runtime/check-alcance-wp008.sh`,
**sin `--lista`**, hace dos cosas en una sola invocación: primero comprueba el
**diff real**, y después ejecuta **automáticamente** las dos demostraciones de este
apartado, usando `--lista` como **costura interna**.

| # | Demostración | Esperado |
|---|---|---|
| 1 | Lista conforme, con rutas de las veintidós permitidas | exit `0` |
| 2 | Lista con una ruta no admitida bajo `tests/runtime/empirico/`, que pertenece a WP-012 | exit `1`, con esa ruta nombrada |

Una demostración cuyo resultado esperado es `1` **cuenta como correcta cuando
obtiene `1`**.

**`--lista ARCHIVO_NUL`** comprueba **únicamente** la lista proporcionada y **no**
ejecuta las demostraciones: es la costura que estas usan.

**Códigos del modo agregado:** **`0`** solo si el diff real es conforme **y** las
dos demostraciones producen sus códigos esperados; **`1`** ante una no conformidad
del diff o un resultado inesperado de cualquier demostración; **`2`** ante
argumentos o entorno inválidos.

**Alcance temporal del modo diff.** Antes del primer commit de la rama el diff está
vacío y la comprobación es trivialmente conforme; su valor probatorio aparece a
partir de `C_ROJO` y se recoge en la evidencia de `C_EVIDENCIA`. Las **dos
demostraciones**, en cambio, son significativas desde el primer momento.

#### 7b. Modo `--cuarentena`

**Qué examina.** En modo real construye una lista **NUL-safe** con la **lista
cerrada de scripts de este WP**, y nada más:

```
tests/runtime/check-config.sh
tests/runtime/test-check-config.sh
tests/runtime/test-protocolo.sh
tests/runtime/capturar-ci-rojo.sh
tests/runtime/test-capturar-ci-rojo.sh
tests/runtime/check-alcance-wp008.sh
evidence/WP-008/parche/aplicar.sh
```

**Siete scripts, enumerados nominalmente dentro del propio escáner.** **No recorre
`tests/runtime/` de forma recursiva** y **no usa ningún comodín sobre ese árbol**,
porque contiene también rutas de **WP-012**, que tienen su propio control
equivalente. La lista **incluye al propio escáner** y **no excluye ningún script
versionado de este WP**.

**Qué hace fallar el control**, con exit `1` y enumerando **todos** los hallazgos
con archivo y línea:

| # | Hallazgo |
|---|---|
| 1 | Una invocación del comando de estado de Git que **no** lleve, en esa misma línea lógica, ninguna de las formas aceptadas |
| 2 | Cualquiera de las formas prohibidas del archivo de patrones |
| 3 | Una invocación **no verificable**: partida mediante continuación de línea, construida por sustitución, ensamblada desde variables o encubierta tras un alias |

**Regla de una sola línea lógica.** Toda invocación real del comando de estado de
Git en los scripts de este WP **debe estar en una sola línea lógica** y **debe
contener** una de las formas aceptadas. Una invocación que no pueda comprobarse por
lectura estática **no se presume conforme**: se declara **no verificable** y hace
fallar el control. Es fail-closed, igual que el resto del WP.

Sale **`0`** sin hallazgos, **`1`** con alguno o con una invocación no verificable,
y **`2`** ante argumentos o entorno inválidos.

**El escáner se examina también a sí mismo.** No hay exclusión y no queda nada a
criterio de un revisor. La autoexploración es posible porque **el escáner no
contiene como literales las formas que busca**: viven en el archivo de datos de la
sección 7c. El `code-reviewer` puede revisar el diseño del escáner y el contenido
del archivo de patrones, pero **no sustituye ninguna de estas verificaciones
automáticas**.

**Alcance declarado.** Es un control de **autoconformidad de WP-008**: mira solo los
siete scripts que este WP entrega. **No es un control genérico del repositorio, no
adelanta WP-002 y no alcanza ninguna ruta de WP-012.**

#### 7c. El archivo de patrones

Las formas que el escáner busca **no figuran como literales dentro del escáner**.
Viven en `tests/runtime/fixtures/cuarentena/patrones.txt`, un **archivo de datos no
ejecutable**, con modo `0644`, que **nunca se ejecuta ni se interpreta**: se lee
como texto.

Contiene tres secciones etiquetadas: el **token de invocación** que hay que
detectar, las **formas aceptadas** que deben acompañarlo, y las **formas
prohibidas** que hacen fallar el control por sí solas. Esa separación es lo que
permite que el escáner **se incluya a sí mismo** sin autoinculparse. El archivo de
patrones no es un script y no entra en la lista de archivos escaneados.

#### 7d. Pruebas del modo `--cuarentena`

**Seis pruebas deterministas: dos positivas y cuatro negativas.** Headless y sin
red. Se construyen archivos temporales conforme a la sección 9, se listan con
`--lista-scripts` y **nunca se ejecutan**:

| # | Signo | Archivo de prueba | Esperado |
|---|---|---|---|
| 1 | positiva | Invocación conforme con la forma corta aceptada | exit **`0`** |
| 2 | positiva | Invocación conforme con la forma larga aceptada | exit **`0`** |
| 3 | negativa | Invocación del comando de estado **sin ninguna forma aceptada** | exit **`1`** |
| 4 | negativa | Forma prohibida corta | exit **`1`** |
| 5 | negativa | Forma prohibida larga, en sus dos variantes | exit **`1`** |
| 6 | negativa | Invocación **no verificable**: partida por continuación de línea y ensamblada por sustitución | exit **`1`** |

**Semántica del modo, agregada y ejecutable.**
`bash tests/runtime/check-alcance-wp008.sh --cuarentena`, **sin `--lista-scripts`**,
hace dos cosas en una sola invocación: primero ejecuta el **escaneo real** sobre los
**siete** scripts de la lista cerrada —el escáner incluido—, que debe dar **cero
hallazgos**, y después ejecuta **automáticamente** las **seis** pruebas de la tabla
anterior, usando `--lista-scripts` como **costura interna**.

Una prueba negativa cuyo resultado esperado es `1` **cuenta como correcta cuando
obtiene `1`**.

**`--cuarentena --lista-scripts ARCHIVO_NUL`** comprueba **únicamente** la lista
proporcionada y **no** ejecuta las seis pruebas: es la costura que estas usan.

**Códigos del modo agregado:** **`0`** solo si el escaneo real da cero hallazgos
**y** las seis pruebas producen sus códigos esperados; **`1`** ante un hallazgo real
o un resultado inesperado de cualquier prueba; **`2`** ante argumentos o entorno
inválidos.

El escaneo real y las seis pruebas quedan en `alcance/cuarentena.log`.

### 8. Los contratos documentales afectados, uno a uno

| Archivo | Qué queda falso sin tocarlo | Cambio mínimo |
|---|---|---|
| `docs/manual/07-troubleshooting.md` | Su apartado de avisos de reglas de permiso **prescribe** las cuatro reglas `Edit(./...)`, que la documentación oficial ancla al directorio actual. Su apartado sobre el hook que no bloquea no menciona el preflight ni el fail-closed nuevo | Corregir el bloque de reglas a la forma anclada; añadir el diagnóstico del preflight, el aviso de sobre-bloqueo por normalización y la exigencia de arrancar en la raíz **como contrato operativo de la FDA**, sin atribuirla a ninguna carencia del runtime y **sin invocar ninguna medición de comportamiento** |
| `docs/manual/02-ciclo-de-un-wp.md` | Su Paso 6 enumera qué comprueba `Gobierno FDA` y el preflight no está en la lista | Añadir la configuración del runtime fail-closed a esa celda |
| `docs/manual/MANUAL.md` | Su tabla dice tres controles deterministas y el preflight es un cuarto, bloqueante | Añadir una fila con el preflight, su ubicación y qué impide |
| `docs/manual/04-agentes.md` | Su apartado sobre los controles que no dependen del prompt contradiría a `MANUAL.md`, que pasa a cuatro. Y su tabla de límites cita una regla con prefijo `./` como forma de una ruta anclada al proyecto | Pasar la sección a **cuatro** controles, y corregir esa regla a la forma anclada |
| `docs/manual/01-instalacion.md` | Su Paso 2 enseña un ejemplo de `deny` con prefijo `./` para toda instalación nueva | Corregir el ejemplo a la forma anclada |
| `docs/02-guia-fabrica-desarrollo-agentica.md` | Su `settings.json` de ejemplo muestra reglas con prefijo `./`, un matcher **incompleto** y una invocación **relativa** del hook. Es la especificación vinculante del sistema | Reglas sin `./`; **matcher real completo** de cinco entradas; invocación **anclada y fail-closed** |
| `specs/requirements/SEC-001-sin-secretos.md` | Su criterio 4 enumera literalmente las cuatro reglas con prefijo `./` y su tabla las da por operativas sin distinguir declaración de resolución | Criterio 4 con las **cuatro reglas reancladas**, y una distinción explícita en dos niveles: **(a) declaradas y verificadas estructuralmente por WP-008** —conjunto exacto y anclaje, comprobaciones 6 y 9 del preflight, reproducibles en CI—; **(b) resolución real por el runtime, que acreditará WP-012**. La tabla dice **4 reglas declaradas y verificadas estructuralmente**, y **no** afirma prueba de comportamiento |

**SEC-001 permanece en el alcance de WP-008** por decisión humana: dejarlo sin tocar
lo mantendría afirmando cuatro reglas con prefijo `./`, que es sencillamente falso
tras este WP. Lo que cambia respecto al contrato anterior es el **alcance de lo que
SEC-001 puede afirmar**: declaración y verificación estructural aquí, resolución en
ejecución en WP-012.

**Los tres archivos restantes de `docs/manual/` —`03`, `05` y `06`— quedan
prohibidos**, y `05-bloqueos-y-parada.md` con dos razones adicionales: `DEC-003` §7
registra que ya tiene cambios pendientes en el worktree congelado de WP-007, y
`DEC-005` lo ha modificado de nuevo.

### 9. Directorios temporales: `mktemp -d` y `TMPDIR`

**Ningún contrato de este WP asume que `TMPDIR` está fuera del repositorio.** Estas
reglas se aplican a **todo** directorio creado mediante `mktemp -d` por **cualquier
script de WP-008**, sin excepción: `aplicar.sh`, `capturar-ci-rojo.sh`,
`check-config.sh`, `check-alcance-wp008.sh` y los tres scripts de pruebas,
**incluidos los fixtures y las listas temporales que estos creen**. Para cada uno de
esos directorios:

1. Se **canonicaliza físicamente** el directorio **después** de crearlo.
2. Se exige que quede **fuera de la raíz física del repositorio real**.
3. Cuando se opera sobre una copia externa de fixture, se exige además que quede
   **fuera de la raíz física de esa copia**.
4. Si queda dentro de cualquiera de las dos, el script **sale con exit `2`**
   **antes** de modificar el archivo objetivo, de ejecutar el stub y de cualquier
   acceso a red.
5. En ese caso **solo elimina el directorio recién creado y todavía vacío**, y
   **nunca continúa usándolo**.

Toda comparación de contención física es **con límite de componente**: una ruta
`A` está dentro de `B` solo si `A == B` o si empieza por `B/`. Una ruta hermana
cuyo nombre solo comparte el prefijo textual —por ejemplo, un respaldo llamado
`fda-template-respaldo-*` junto a `fda-template`— sigue siendo externa. Se prohíbe
una comparación de prefijo simple.

Las pruebas correspondientes se integran **como subcomprobaciones de escenarios y
casos ya existentes**: en `test-protocolo.sh` dentro de los doce escenarios, y en
`test-capturar-ci-rojo.sh` dentro del caso 13, con el nombre
`tmpdir-dentro-del-repo`. La corrección de `DEC-006` eleva el comprobador a
treinta y dos casos; esta subcomprobación sigue dentro del caso 13 y no añade otro.

Esta formulación es la **aclaración de un invariante ya exigido**, no una ampliación
funcional: no cambian los archivos permitidos, ni los doce escenarios de
`test-protocolo.sh`, ni los veintidós casos de `test-check-config.sh`, ni los
treinta y dos del comprobador, ni las trece subcomprobaciones del caso 13, ni ningún
otro contador del WP.

## Entorno autorizado (herramientas, comandos, red, secretos)

- **Herramientas:** Read, Grep, Glob, Edit, Write, Bash
- **Comandos:** `bash`, `python3`, `git` local de solo lectura, `shellcheck`,
  `shasum` o `sha256sum`, `mktemp`, `diff`, `comm`, `sort`, `chmod` **solo sobre
  copias externas de fixture**, y `gh` **solo lectura** únicamente en las tres
  operaciones nominales que enumera el punto siguiente
- **`claude` NO está autorizado.** Este WP no lo invoca en ningún punto.
- **Red:** **NINGUNA**, salvo **tres operaciones de evidencia, nominales, acotadas
  y de solo lectura**:

  | # | Operación | Cuándo |
  |---|---|---|
  | 1 | `capturar-ci-rojo.sh RUN_ID` — **captura roja** | Tras el run de `C_ROJO` |
  | 2 | `capturar-ci-rojo.sh --verde RUN_ID` — **captura verde** | Tras el run de `C_VERDE` |
  | 3 | `gh pr view PR_NUMERO --json commits` | **Antes** de crear `C_EVIDENCIA`, esperando entonces **exactamente dos** commits: `C_ROJO` y `C_VERDE`, en ese orden |

  Los **push** de la persona son operaciones de **publicación**, no consultas de
  evidencia, y **no cuentan en esta enumeración**. Cualquier comprobación remota de
  la PR **posterior** a `C_EVIDENCIA` pertenece a la **revisión final** y no a este
  contrato. El preflight, sus pruebas, la prueba del protocolo, las pruebas del
  comprobador y del alcance, y toda la batería de no regresión se ejecutan **sin
  red**
- **Secretos:** NINGUNO

**Sin dependencias nuevas.** No se instala nada. `bash` y `python3` ya están
disponibles en local y en el runner, y `python3` ya se configura en el job
`gobierno`.

## Verificación (comandos de validación + criterios de aceptación medibles)

El orden causal importa y se separa en dos baterías. **La batería final no puede
declararse verde antes de aplicar la fase verde**, porque
`bash tests/runtime/check-config.sh` **debe fallar** contra la configuración real
mientras el par esté en S0 o en S1: ese fallo es precisamente la evidencia que este
WP necesita.

### A. Validación preparatoria, con el par en S0

Todo lo que puede y debe estar en verde **antes** de tocar los archivos reales.
Headless, sin interacción, sin TTY y con código de salida significativo:

```bash
bash -n tests/runtime/check-config.sh
bash -n tests/runtime/test-check-config.sh
bash -n tests/runtime/test-protocolo.sh
bash -n tests/runtime/capturar-ci-rojo.sh
bash -n tests/runtime/test-capturar-ci-rojo.sh
bash -n tests/runtime/check-alcance-wp008.sh
bash -n evidence/WP-008/parche/aplicar.sh
shellcheck --severity=warning --shell=bash tests/runtime/check-config.sh tests/runtime/test-check-config.sh tests/runtime/test-protocolo.sh tests/runtime/capturar-ci-rojo.sh tests/runtime/test-capturar-ci-rojo.sh tests/runtime/check-alcance-wp008.sh evidence/WP-008/parche/aplicar.sh
bash tests/runtime/test-check-config.sh
bash tests/runtime/test-protocolo.sh
bash tests/runtime/test-capturar-ci-rojo.sh
bash tests/runtime/check-alcance-wp008.sh
bash tests/runtime/check-alcance-wp008.sh --cuarentena
python3 -m json.tool evidence/WP-008/parche/settings.json.candidato > /dev/null
bash tests/runtime/check-config.sh evidence/WP-008/parche/settings.json.candidato .
python3 .claude/skills/run-verification/validate-workflows.py .github/workflows
python3 .claude/skills/run-verification/validate-workflows.py evidence/WP-008/parche/ci.yml.candidato .github/workflows/claude.yml .github/workflows/code-review.yml
bash tests/guard/run-suite.sh
bash tests/governance/check-active.sh
bash tests/governance/test-check-active.sh
bash evidence/WP-000/checks/check-guard.sh
python3 evidence/WP-000/checks/check-manual.py
```

Dos observaciones sobre esta batería:

- **`check-config.sh` se invoca con los DOS argumentos explícitos**, apuntando al
  **candidato**, no a la configuración real. Es el invariante **I4** de `ADR-001` en
  uso: valida el candidato **antes** de sustituir nada, y debe salir **`0`**.
- **`check-config.sh` sin argumentos NO se ejecuta aquí.** Contra el
  `settings.json` real en `ANTES` debe fallar, y hacerlo pasar sería falsear la
  premisa del WP.
- La validación del `ci.yml.candidato` la realiza `validate-workflows.py` con
  **argumentos nominales**: el candidato y los otros dos workflows reales. El
  validador acepta archivos además de directorios, de modo que el candidato queda
  validado **en S0, antes de que la persona ejecute `aplicar.sh rojo`**, y no
  después de haberlo escrito. La validación **por directorio** se mantiene en la
  batería B sobre el estado ya instalado, y `aplicar.sh` repite la validación
  nominal en el paso 4 de la sección 5d como última barrera antes de sustituir.

### B. Validación final, con el par en S2

Solo después de la fase verde. Reproducible por un tercero y sin red, salvo la
captura verde:

```bash
bash tests/runtime/check-config.sh
bash tests/runtime/test-check-config.sh
bash tests/runtime/test-protocolo.sh
bash tests/runtime/test-capturar-ci-rojo.sh
bash tests/runtime/check-alcance-wp008.sh
bash tests/runtime/check-alcance-wp008.sh --cuarentena
python3 .claude/skills/run-verification/validate-workflows.py .github/workflows
python3 -m json.tool .claude/settings.json > /dev/null
bash tests/guard/run-suite.sh
bash tests/governance/check-active.sh
bash tests/governance/test-check-active.sh
bash evidence/WP-000/checks/check-guard.sh
python3 evidence/WP-000/checks/check-manual.py
```

Aquí sí, `check-config.sh` **sin argumentos** debe salir **`0`** contra la
configuración real ya en S2. Los cinco últimos comandos son de **no regresión**.

Lo que **no** figura en ninguna de las dos baterías es la **invocación real** de
`capturar-ci-rojo.sh` con un `RUN_ID`, porque ese identificador no existe hasta que
el commit correspondiente está empujado: es un paso de la cronología, y su salida
`0` es criterio de aceptación.

### Criterios de aceptación

*Preflight y sus pruebas*

- [ ] Con el par en **S0**, `bash tests/runtime/check-config.sh evidence/WP-008/parche/settings.json.candidato .` termina en **exit `0`**
- [ ] Con el par en **S2**, `bash tests/runtime/check-config.sh` termina en **exit `0`** contra la configuración real
- [ ] `bash tests/runtime/test-check-config.sh` termina en **exit `0`** con **0 fallidas** y cubre los **22** casos de la sección 3
- [ ] El preflight ejecuta las **9** comprobaciones de la sección 2 y las nombra una a una en su salida
- [ ] Un `command` **inerte** que contenga las cadenas `CLAUDE_PROJECT_DIR` y `exit 2` pero no ejecute el guard hace fallar el preflight con exit `1` y señala la comprobación 4
- [ ] El caso de **regla duplicada compensando una ausencia** falla por la comprobación 9 **aunque el recuento siga dando ocho**
- [ ] El caso de **regla sustituida por otra regla anclada distinta** falla por la comprobación 9 **aunque el recuento siga dando ocho**
- [ ] Los seis casos de comportamiento 17 a 22 pasan, incluido el de raíz con espacios
- [ ] `bash tests/runtime/check-config.sh /ruta/inexistente` sale **`2`**
- [ ] `tests/runtime/check-config.sh` no referencia `tests/guard/` en ninguna línea, verificable con `grep`
- [ ] **Comprobado en revisión:** `command-canonico.txt` es idéntico al comando canónico de la sección 1a, carácter a carácter tras normalizar espacios, y `reglas-canonicas.txt` es idéntico al conjunto de ocho reglas de la sección 1b. Lo verifica el `code-reviewer` **contra el WP aprobado**, no contra los propios oráculos
- [ ] Tras ejecutar el test completo, `.claude/hooks/guard.sh` conserva ruta, contenido y bit de ejecución

*Núcleo fail-closed, capa determinista*

- [ ] El `command` del hook es **idéntico** al canónico de la sección 1a y no invoca el guard por ruta relativa
- [ ] Con el guard de fixture **ausente**, el comando canónico sale **`2`** —caso 20—
- [ ] Con el guard de fixture **sin permiso de ejecución**, el comando canónico sale **`2`** —caso 21—
- [ ] El matcher sigue siendo, carácter a carácter, `Edit|Write|MultiEdit|NotebookEdit|Bash`
- [ ] El diff de `.claude/settings.json` no muestra ningún cambio en `ask`, en `allow` ni en las cuatro reglas `Bash(...)` del `deny`
- [ ] Las **ocho** reglas de archivo quedan reancladas **una a una**: ocho originales, ocho finales, cuatro `Read` y cuatro `Edit`; ninguna empieza por `./` ni queda sin anclar
- [ ] El conjunto final coincide **elemento a elemento** con el transcrito en la sección 1b
- [ ] **Declarado expresamente:** ningún criterio de este WP afirma que Claude Code cargue los settings, que el matcher intercepte herramienta alguna ni que una regla anclada resuelva a la raíz en ejecución. Esas afirmaciones son de **WP-012**

*Comprobadores de barrera y de alcance*

- [ ] `bash tests/runtime/test-capturar-ci-rojo.sh` termina en **exit `0`** con **32 correctas y 0 fallidas**
- [ ] Cada una de las **ocho** validaciones del run rojo tiene **al menos un caso negativo** que demuestra que bloquea
- [ ] El fixture rojo conforme es sintético, contiene `event=pull_request` y reproduce los tres jobs y la secuencia completa de pasos de la sección 6c
- [ ] El conjunto de jobs y los oráculos de pasos se comparan positivamente: falta, sobra, duplicación, nombre, versión u orden relativo distintos salen `2`
- [ ] El campo `number` de los pasos no interviene en ninguna decisión
- [ ] Toda comparación de contención usa rutas físicas y límites de componente; la aserción subordinada del caso 13 usa una raíz hermana externa sin `.fda-fixture`, obtiene exit `2` con `motivo=entorno` por marcador ausente —nunca por contención— y demuestra que ni el stub ni el `gh` real se ejecutaron
- [ ] Los cuatro pasos de housekeeping se exigen con sus conclusiones exactas y la condición 8 sigue alcanzándolos
- [ ] Los casos 20 a 32 cubren evento, ausencias, extras, versión, orden, duplicación, conjunto de jobs y las cuatro conclusiones de housekeeping
- [ ] `tests/runtime/fixtures/ci/README.md` declara **quince respuestas versionadas**, todas sintéticas; documenta la adquisición exacta `--json status,conclusion,headSha,databaseId,url,event,jobs`; la captura real abandonada no figura como fixture
- [ ] Todo exit `2` emite exactamente un `motivo=` del conjunto cerrado de la sección 6c; los tests comprueban el valor, incluido `forma_desconocida`
- [ ] El modo `--verde` exige `event=pull_request` como puerta de procedencia de adquisición; el caso 19 cubre evento ausente, evento distinto y conclusión no conforme sin alterar sus tres condiciones de composición
- [ ] Las **trece** subcomprobaciones nombradas del caso 13 salen `2`, y en las trece se demuestra que no se ejecutó ni el stub ni el `gh` real
- [ ] Un directorio de salida proporcionado pero inexistente se **rechaza sin crearlo**
- [ ] El test se ejecuta **sin red**: usa respuestas grabadas y un stub inyectado por costura explícita
- [ ] El caso 14 demuestra polling, persistencia externa y delegación al validador puro; el 16, la expiración del tiempo máximo sin espera real prolongada
- [ ] `capturar-ci-rojo.sh` separa **adquisición** y **validación pura**: el modo `--validar` no toca la red
- [ ] `bash tests/runtime/check-alcance-wp008.sh`, **sin `--lista`**, termina en **exit `0`**: el diff real es conforme, con cero rutas no admitidas, **y** las **dos** demostraciones de la sección 7a producen sus códigos esperados, la segunda con exit `1` y la ruta nombrada
- [ ] `bash tests/runtime/check-alcance-wp008.sh --cuarentena`, **sin `--lista-scripts`**, termina en **exit `0`**: el escaneo real da cero hallazgos sobre los **siete** scripts de la lista cerrada, **incluido el propio escáner**, **y** las **seis** pruebas de la sección 7d —**dos positivas y cuatro negativas**— producen sus códigos esperados
- [ ] El escáner de cuarentena **no recorre `tests/runtime/` recursivamente**, **no usa ningún comodín sobre ese árbol** y **no alcanza ninguna ruta de WP-012**, verificable por lectura del script
- [ ] Las **ocho** pruebas de la sección 7 —dos demostraciones y seis del modo cuarentena— quedan cubiertas por esas **dos** invocaciones: ninguna requiere ejecución manual ni interpretación
- [ ] Un resultado esperado de `1` cuenta como **correcto** cuando se obtiene `1`; un código distinto del esperado hace salir al modo agregado con `1`
- [ ] Las costuras `--lista` y `--cuarentena --lista-scripts` comprueban **solo** la lista dada y **no** disparan las pruebas, verificable por sus propias ejecuciones
- [ ] Los archivos temporales de las seis pruebas **no se ejecutan** en ningún momento
- [ ] `tests/runtime/fixtures/cuarentena/patrones.txt` existe, tiene modo `0644`, **no es ejecutable**, y el escáner **no contiene como literales** ninguna de las formas que busca
- [ ] Toda invocación real del comando de estado de Git en los scripts de este WP está en **una sola línea lógica** y lleva una forma aceptada
- [ ] El WP declara que la comprobación de alcance es **local y redundante**, y que **no cierra `REQ-FDA-001`**

*CI*

- [ ] `.github/workflows/ci.yml` añade **exactamente un** paso, en el job `Gobierno FDA`, que invoca `tests/runtime/check-config.sh` y no replica su lógica
- [ ] El diff de `.github/workflows/ci.yml` no toca ningún otro job ni paso, y no añade ninguna acción ni dependencia
- [ ] La ejecución roja tiene `event=pull_request` y el conjunto exacto de tres jobs de la sección 6c
- [ ] `Gobierno FDA` presenta los oráculos completos, únicos y en orden: housekeeping previo y declarados anteriores conformes, preflight en `failure`, declarados posteriores en `skipped` y housekeeping posterior con su mapa exacto
- [ ] Los otros dos jobs exactos terminan en `success`
- [ ] En la ejecución roja **no hay ninguna segunda causa de fallo**
- [ ] La barrera roja terminó en **exit `0`**, validando automáticamente las **ocho** condiciones, **antes** de la fase verde y de empujar `C_VERDE`
- [ ] El run rojo **no fue cancelado**: su `conclusion` es `failure`
- [ ] La barrera verde terminó en **exit `0`**, validando sus **tres** condiciones, **antes** de reabrir ninguna sesión de agente y antes de preparar `C_EVIDENCIA`
- [ ] Las dos ejecuciones proceden de **la misma rama y la misma PR**; el ruleset no se modificó y **`main` no se modificó para fabricar ninguna de las dos evidencias**
- [ ] `C_ROJO`, `C_VERDE` y `C_EVIDENCIA` figuran en la lista de commits de la PR, con sus hashes completos
- [ ] El run rojo tiene `headSha` igual a `C_ROJO`; el verde, igual a `C_VERDE` con `conclusion` igual a `success`
- [ ] `C_VERDE` es descendiente **directo** de `C_ROJO`, y `C_VERDE` es ancestro de `C_EVIDENCIA`
- [ ] Entre `C_ROJO` y `C_VERDE`, el único cambio en los dos archivos protegidos es `.claude/settings.json`

*Parche*

- [ ] `aplicar.sh rojo` transforma **S0 a S1**; repetido en S1 imprime `YA EN ROJO`, sale `0` y no modifica nada
- [ ] `aplicar.sh verde` transforma **S1 a S2**; repetido en S2 imprime `YA EN VERDE`, sale `0` y no modifica nada
- [ ] Sobre fixtures: `verde` desde S0, `rojo` desde S2, el par invertido y cualquier estado desconocido abortan con exit `2` sin escribir nada
- [ ] En la fase roja, el preflight sobre el `settings` en `ANTES` sale **`1`** y señala exactamente las comprobaciones **4, 6 y 9**, con la comprobación **8 conforme**
- [ ] En la fase verde, el candidato hace pasar el preflight con exit **`0`**, comprobado **antes** de sustituir el archivo real
- [ ] Sobre fixtures: ante un fallo provocado, `aplicar.sh` restaura y deja el par en **S0** en la fase roja y en **S1** en la verde, con `ROLLBACK APLICADO` y código distinto de cero
- [ ] El failpoint **rechaza con exit `2`** sin `--root` o contra una raíz sin el marcador `.fda-fixture`
- [ ] `bash tests/runtime/test-protocolo.sh` termina en **exit `0`** con **0 fallidas** y cubre los **12** escenarios de la sección 5g
- [ ] En cada fase, `H_OTROS_DESPUES` es **idéntica** a `H_OTROS_ANTES` con el objetivo excluido por pathspec, y `H_STAGED_DESPUES` es **idéntica** a `H_STAGED_ANTES`
- [ ] En cada fase, el archivo objetivo pasó de su huella contractual de origen a la de destino
- [ ] `test-protocolo.sh` compara la **instantánea completa** de la raíz de la **copia externa** antes y después, **excluyendo `.git/**`**: idénticas salvo el archivo objetivo, sin que aparezca ni desaparezca ninguna otra ruta
- [ ] Todo directorio creado con `mktemp -d` por cualquier script de este WP queda **fuera** de la raíz física del repositorio y, en modo fixture, también fuera de la de la **copia externa**; en caso contrario el script sale `2`, elimina el directorio vacío y no continúa
- [ ] Las copias de seguridad viven **únicamente** en ese directorio temporal, y su ruta física consta en el log
- [ ] Sobre los dos archivos reales se ejecutaron **exactamente cuatro** invocaciones de `aplicar.sh`, las de la sección 5h
- [ ] Los logs de las dos fases reales se generaron **fuera del repositorio** y se incorporaron solo durante la preparación de `C_EVIDENCIA`
- [ ] **Árbol de plantillas intacto:** el **digest agregado** de la instantánea de `tests/runtime/fixtures/proyecto/**` es **idéntico** en la preimagen y en todas las postimágenes; ninguna prueba modificó lo versionado, ni siquiera de forma temporal
- [ ] La instantánea registra, por entrada, **ruta relativa NUL-safe, tipo, modo, SHA-256 de los bytes de cada archivo regular y destino literal de cada enlace simbólico**, más el **conjunto exacto de rutas** y el **número de entradas**
- [ ] El orden de las rutas en la instantánea es **determinista por bytes**, de modo que dos ejecuciones sobre el mismo árbol producen el **mismo digest agregado**
- [ ] La instantánea detecta **altas, bajas, renombrados y cambios de tipo, de modo, de contenido y de destino de enlace**, demostrado con al menos un caso por familia sobre una copia externa
- [ ] La **preimagen** se captura antes del primer escenario y antes de copiar nada; hay una **postimagen intermedia** por escenario y una **postimagen final** tras las limpiezas
- [ ] Ante cualquier diferencia, `test-protocolo.sh` **falla**, nombra la **ruta** y el **campo** que cambiaron y no continúa
- [ ] `aplicar.sh --root` **rechaza con exit `2`, sin escribir**, cualquier ruta que canonicalice dentro de la raíz física del repositorio
- [ ] **A8 en S0:** `validate-workflows.py` valida el `ci.yml.candidato` con **argumentos nominales**, junto a `claude.yml` y `code-review.yml`, con exit `0` y **antes** de la primera invocación real de `aplicar.sh rojo`
- [ ] **B6 en S2:** `validate-workflows.py` valida **por directorio** el estado ya instalado, con exit `0`
- [ ] **Orden de trabajo:** la batería A se ejecutó **después** de terminar los cinco archivos de `docs/manual/`, la guía fundacional y `SEC-001`, y la evidencia lo acredita con marcas de tiempo coherentes
- [ ] **Red:** se registraron **exactamente tres** operaciones de red, todas de solo lectura y todas nominales: captura roja, captura verde y `gh pr view PR_NUMERO --json commits`. Los push no cuentan como consultas de evidencia
- [ ] La consulta `gh pr view` previa a `C_EVIDENCIA` observó **exactamente dos** commits, `C_ROJO` y `C_VERDE`, en ese orden, y **ningún artefacto exige que `C_EVIDENCIA` contenga su propio hash**
- [ ] **Alcance antes del commit:** consta la salida de `check-alcance-wp008.sh --lista ARCHIVO_NUL` sobre la lista staged real de `C_ROJO`, con exit `0`, fechada antes del commit
- [ ] **Alcance antes del push:** consta la salida de `check-alcance-wp008.sh` sin argumentos sobre `main...HEAD`, con exit `0`, fechada después de crear `C_ROJO` y antes de empujarlo
- [ ] **Los dos registros se generaron fuera del repositorio durante S1**, y su ruta física y su SHA-256 de entonces constan en la evidencia
- [ ] **La lista staged se revalidó por hash** en el paso 6, inmediatamente antes de crear `C_ROJO`, y resultó **idéntica** a la validada en el paso 3
- [ ] **`C_ROJO` no contiene ninguna ruta bajo `evidence/WP-008/**`**, verificable con `git show --name-only` sobre ese commit
- [ ] **`C_EVIDENCIA` contiene las copias finales** de ambos registros, cada una con su SHA-256 de S1 y el hash completo de `C_ROJO`, de modo que la correlación es verificable
- [ ] Ni `git add .` ni `git add -A` aparecen en ningún procedimiento, script ni evidencia de este WP

*No regresión y alcance*

- [ ] `bash tests/guard/run-suite.sh` sigue dando **68 correctas · 0 fallidas · 10 huecos conocidos · 0 huecos cerrados**, sin que el archivo se haya modificado
- [ ] El diff de la rama contra `main` no contiene `tests/guard/run-suite.sh` ni `.claude/hooks/guard.sh`
- [ ] El diff de la rama contra `main` **no contiene ninguna ruta de WP-012**: ni bajo `tests/runtime/empirico/**` ni bajo `evidence/WP-012/**`
- [ ] `bash evidence/WP-000/checks/check-guard.sh`, `check-active.sh` y `test-check-active.sh` en verde
- [ ] `python3 evidence/WP-000/checks/check-manual.py` en verde tras tocar los cinco archivos de `docs/manual/`: es la verificación de `REQ-FDA-003`, que este WP satisface sin enmendar
- [ ] Bajo `docs/manual/` cambian **exactamente** los cinco archivos nominales permitidos
- [ ] Bajo `docs/`, fuera de esos cinco, cambia **únicamente** `docs/02-guia-fabrica-desarrollo-agentica.md`
- [ ] Bajo `specs/requirements/` cambia **únicamente** `SEC-001-sin-secretos.md`
- [ ] `MANUAL.md` y `docs/manual/04-agentes.md` declaran el **mismo número de controles deterministas: cuatro**
- [ ] `docs/02-guia-fabrica-desarrollo-agentica.md` no contiene ninguna regla con prefijo `./`, muestra el matcher completo de cinco entradas y una invocación anclada con `CLAUDE_PROJECT_DIR`
- [ ] `SEC-001` criterio 4 enumera las **cuatro** reglas reancladas, distingue **declaración y verificación estructural por WP-008** de **resolución real por el runtime, que acreditará WP-012**, y **no** afirma prueba de comportamiento
- [ ] `work-packages/ACTIVE`, `work-packages/**`, `evidence/WP-007/**`, el ruleset y el estado externo de `claude.yml` y `code-review.yml` permanecen **sin cambios**
- [ ] `.agents/`, `.codex/` y `AGENTS.md` no aparecen en el diff, no fueron leídos y no fueron enumerados por ninguna herramienta del WP
- [ ] Revisión del **`security-reviewer`** realizada y **sin hallazgos de severidad ALTA ni CRÍTICA abiertos**

*Coste*

- [ ] `evidence/WP-008/cost.md` cumple `DEC-001` y `DEC-004`, **sin marcador alguno**, y contiene la fila nominal `Ciclos de corrección | N / 2` con la relación de las pasadas consumidas
- [ ] El `estado_coste` corresponde a la **procedencia real** de la cifra, según `DEC-004` §12: F1 o F2 conformes producen `medido`; F1 o F2 incompletas o no conformes producen `estimado`; F3 produce `estimado`; sin cifra defendible produce `no_disponible`, y entonces el WP es **NO APTO**
- [ ] Los campos obligatorios del estado declarado están completos según `DEC-004` §4

## Evidencias exigidas (qué debe aparecer en evidence/WP-008/)

Todas las evidencias de este WP son **deterministas o capturas reales de CI**.
Ninguna evidencia de comportamiento del runtime corresponde a este WP: esa vive
bajo `evidence/WP-012/**`.

- [ ] `preflight/` — salida íntegra de `check-config.sh` y de `test-check-config.sh`, con sus códigos de salida, en las dos baterías: la preparatoria sobre el candidato y la final sobre la configuración real
- [ ] `preflight/negativos.log` — las salidas de los **22** casos, con los casos 15 y 16 mostrando recuento conforme y conjunto no conforme
- [ ] `protocolo/test-protocolo.log` — salida íntegra de `test-protocolo.sh` con los **12** escenarios y su código de salida
- [ ] `protocolo/failpoint-rechazado.log` — intento de activar el failpoint sin `--root` y contra una raíz sin marcador, ambos con exit `2`
- [ ] `parche/aplicar.sh`, `parche/huellas.sha256`, `parche/settings.json.candidato`, `parche/ci.yml.candidato`, `parche/README.md`
- [ ] `parche/01-fase-roja.log` — `aplicar.sh rojo` real, con `APLICADO ROJO (S1)`, exit `0`, ruta física del directorio temporal y la salida del preflight fallando por las comprobaciones **4, 6 y 9**, con la **8 conforme**. **Generado fuera del repositorio e incorporado en `C_EVIDENCIA`**
- [ ] `parche/02-rojo-idempotente.log` — segunda ejecución real con `YA EN ROJO` y exit `0`
- [ ] `parche/03-fase-verde.log` — `aplicar.sh verde` real, con la validación del candidato previa a sustituir, `APLICADO VERDE (S2)` y exit `0`
- [ ] `parche/04-verde-idempotente.log` — segunda ejecución real con `YA EN VERDE` y exit `0`
- [ ] `parche/05-abortado-orden.log` — sobre fixtures: `verde` desde S0 y `rojo` desde S2, ambos `ABORTADO` y exit `2`
- [ ] `parche/06-abortado-par-invertido.log` — sobre fixtures: par invertido y estado desconocido, `ABORTADO` y exit `2`
- [ ] `parche/07-rollback-rojo.log` — sobre fixture: `ROLLBACK APLICADO`, exit distinto de cero y par restaurado a **S0**
- [ ] `parche/08-rollback-verde.log` — sobre fixture: `ROLLBACK APLICADO`, exit distinto de cero y par restaurado a **S1**
- [ ] `parche/09-alcance.log` — las huellas `H_OTROS` y `H_STAGED` antes y después de cada fase real, y la transición de huella del archivo objetivo
- [ ] `ci/rojo/` — extracto **saneado** de la captura: `run_id`, URL, `headSha`, `conclusion` distinta de `cancelled`, la tabla de estados de todos los jobs y pasos, el log del paso fallido y el **código de salida `0`** del comprobador, con `modo=real`
- [ ] `ci/verde/` — entrada **única** con, conjuntamente: `run_id`, URL, `event=pull_request`, `headSha`, `conclusion`, el log del modo `--verde` con `modo=real` en su primera línea, y el **código de salida `0`** de ese modo
- [ ] `ci/comprobador/test.log` — salida íntegra de `test-capturar-ci-rojo.sh`, con los **32** casos, sus códigos y el resultado agregado
- [ ] `ci/comprobador/cobertura.md` — correspondencia entre las **ocho** validaciones del run rojo y el caso negativo que cubre cada una
- [ ] `ci/procedimiento.md` — los hashes completos de `C_ROJO` y `C_VERDE`, los dos `run_id` con su `headSha` y su `conclusion`, la salida de `gh pr view PR_NUMERO --json commits` previa a `C_EVIDENCIA` mostrando **exactamente esos dos commits en ese orden**, y las dos comprobaciones de ascendencia con su código de salida. **No registra el hash de `C_EVIDENCIA`**: un commit no puede contener su propio hash, y la forma final de tres commits se comprueba con **Git local antes del push** y, ya publicada, en la **revisión de la PR**
- [ ] `historico/intento-1-abandonado.md` — referencia a `DEC-006`, PR #24, `C_ROJO=f745b5d15b269f2dbc34b9716a07eea9cf4a7dd0`, run `33246993973`, digest del respaldo estable, las huellas de `ACTO1_OK`, `barrera-roja.salida.txt`, `run-rojo.json` y `registro.log`, y la relación cronológica cerrada de las sesiones S1 de auditoría hasta materializar A. No incorpora ni reutiliza lanzadores `.command`, prompts íntegros ni respuestas íntegras
- [ ] `alcance/staged-C_ROJO.log` — la salida de `check-alcance-wp008.sh --lista ARCHIVO_NUL` sobre la lista staged real de `C_ROJO`, con **exit `0`**, fechada **antes** del commit. **Generado en un temporal externo al repositorio durante S1** e incorporado aquí; conserva su **ruta física de origen**, su **SHA-256 de S1** y el **hash completo de `C_ROJO`**
- [ ] `alcance/diff-post-commit-C_ROJO.log` — la salida de `check-alcance-wp008.sh` sin argumentos sobre `main...HEAD` **después** de crear `C_ROJO` y **antes** de empujarlo, con **exit `0`**. **También generado fuera del repositorio durante S1** e incorporado aquí, con los mismos tres datos de correlación
- [ ] `alcance/revalidacion-staged.log` — la lista NUL del área staged y su SHA-256 calculados en el **paso 2** y de nuevo en el **paso 6**, con la constatación de que **son idénticos**
- [ ] `protocolo/plantillas-intactas.txt` — la **instantánea completa** del árbol `tests/runtime/fixtures/proyecto/**` en su **preimagen** y en su **postimagen final**: conjunto de rutas, número de entradas, tipo, modo, SHA-256 por archivo regular, destino por enlace, y el **digest agregado** de cada imagen, con la constatación de que **ambos digests coinciden**
- [ ] `protocolo/instantanea-deteccion.log` — la demostración, sobre una copia externa, de que la instantánea detecta **alta, baja, renombrado, cambio de tipo, cambio de modo, cambio de contenido y cambio de destino de enlace**, con el digest agregado difiriendo en cada caso
- [ ] `workflows/validate-candidato-S0.log` — la salida de la validación **nominal** del `ci.yml.candidato` junto a `claude.yml` y `code-review.yml`, con exit `0`, fechada **antes** de la primera invocación real de `aplicar.sh rojo`
- [ ] `alcance/diff.log` — salida íntegra de la invocación **agregada** de `check-alcance-wp008.sh`: la comprobación del diff real, las **dos** demostraciones con su código obtenido frente al esperado, y el **código agregado `0`**
- [ ] `alcance/cuarentena.log` — salida íntegra de la invocación **agregada** `--cuarentena`: el escaneo real de los **siete** scripts con **cero hallazgos**, las **seis** pruebas con su código obtenido frente al esperado, y el **código agregado `0`**
- [ ] `no-regresion/` — salidas de `run-suite.sh`, `check-guard.sh`, `check-active.sh`, `test-check-active.sh` y `check-manual.py`
- [ ] `diff/` — el diff por nombre y estado de la rama contra `main`, y los diffs completos de `.claude/settings.json` y `.github/workflows/ci.yml`
- [ ] `cost.md` conforme a `DEC-001` y `DEC-004`, con la fila nominal y la relación de ciclos exigidas por `DEC-006`
- [ ] Ningún archivo bajo `evidence/WP-008/` contiene prompts íntegros, respuestas íntegras ni cadenas con forma de credencial

## Condiciones de parada específicas

- Si el fail-closed exigiera **crear un archivo bajo `.claude/hooks/`** o modificar `guard.sh`: **parar**.
- Si se planteara implementar, ejecutar o usar como evidencia **cualquier artefacto de la capa empírica**: **parar**. Es WP-012, y aquí solo se identifica para delimitar alcance y rutas prohibidas.
- Si se planteara **invocar `claude`** en cualquier punto: **parar**. Este WP no tiene capa empírica.
- Si aparecieran en el diff rutas bajo `tests/runtime/empirico/**` o `evidence/WP-012/**`: **parar**.
- Si el escáner de cuarentena fuese a recorrer `tests/runtime/` de forma recursiva, o a usar un comodín sobre ese árbol, y alcanzase rutas de WP-012: **parar**. Su lista es cerrada y nominal.
- Si `check-config.sh` **sin argumentos** saliera `0` con el par en S0 o en S1: **parar**. La demostración en rojo sería imposible y la premisa del WP estaría rota.
- Si en la fase roja el preflight no señalara exactamente las comprobaciones **4, 6 y 9**, o la comprobación **8** no quedara conforme: **parar** y analizar, porque el `settings.json` de partida no es el que este contrato describe.
- Si la batería final se declarase verde antes de aplicar la fase verde: **parar**. El orden causal de la sección de Verificación es contractual.
- Si un directorio creado con `mktemp -d` por cualquier script de este WP quedase dentro de la raíz física del repositorio, o dentro de la del fixture cuando se opera sobre fixture: **parar** con exit `2`, eliminar solo ese directorio vacío y no continuar.
- Si un artefacto destinado a `evidence/WP-008/` contuviese cualquier contenido que vulnere `SEC-001`: **parar**.
- Si alguna prueba exigiera renombrar, sustituir, borrar o retirar el permiso a `.claude/hooks/guard.sh` **de este repositorio**: **parar**.
- Si el par de huellas no corresponde a **S0**, **S1** ni **S2**: **parar**. **S1 es el único estado intermedio autorizado.**
- Si una fase se invoca fuera de orden, `verde` desde S0 o `rojo` desde S2: **parar**.
- Si el rollback de una fase no restaurase el estado de origen **de esa fase**: **parar y escalar de inmediato**.
- Si la instantánea de la copia externa mostrara una ruta adicional o desaparecida, o una diferencia fuera del archivo objetivo y de `.git/**`: **parar**.
- Si el **digest agregado** de la instantánea de `tests/runtime/fixtures/proyecto/**` difiriera entre preimagen y cualquier postimagen: **parar**. Algo escribió sobre lo versionado —un alta, una baja, un renombrado o un cambio de tipo, modo, contenido o destino— y ninguna evidencia de protocolo es fiable.
- Si la instantánea no fuese reproducible, es decir, si dos ejecuciones sobre el mismo árbol produjeran digests agregados distintos: **parar**. Una instantánea no determinista no demuestra nada.
- Si `aplicar.sh --root` aceptara una ruta que canonicaliza dentro del repositorio: **parar**. Es un fallo de contención, no un fallo de prueba.
- Si la validación **nominal** del `ci.yml.candidato` fallara en S0: **parar**. No se instala el candidato y no se ejecuta la fase roja.
- Si la batería A se ejecutara antes de terminar la documentación y `SEC-001`: **parar**. Habría verificado un estado distinto del que se commitea.
- Si hiciera falta una **cuarta** operación de red, sea cual sea el motivo: **parar**. El contrato autoriza exactamente tres, todas de solo lectura.
- Si algún artefacto pretendiera registrar el hash de `C_EVIDENCIA` dentro del propio `C_EVIDENCIA`, o observar tres commits en la PR antes de crearlo: **parar**. Es una cronología imposible.
- Si se fuera a preparar el índice con `git add .` o `git add -A`: **parar**. Enumeran la cuarentena de `DEC-003` §8.
- Si `check-alcance-wp008.sh --lista` no rechazara una lista staged con una ruta prohibida: **parar**. La barrera previa al commit no existiría.
- Si `C_ROJO` se empujara sin haber ejecutado la comprobación de alcance sobre `main...HEAD` posterior al commit: **parar**.
- Si durante **S1** se escribiera cualquier ruta bajo `evidence/WP-008/`: **parar**. La validación del índice quedaría obsoleta en el mismo acto.
- Si la lista NUL del área staged o su SHA-256 recalculados en el paso 6 **no fueran idénticos** a los validados en el paso 3: **parar** y volver al paso 1. Algo entró o salió del índice después de la comprobación.
- Si `C_ROJO` contuviese alguna ruta bajo `evidence/WP-008/**`: **parar**. Esa evidencia viaja en `C_EVIDENCIA`.
- Si un registro incorporado en `C_EVIDENCIA` no conservara su SHA-256 de S1, o no permitiera relacionarlo con el hash de `C_ROJO`: **parar**. Una evidencia que no se puede correlacionar no prueba nada.
- Si se intentara activar el failpoint contra el repositorio real o contra una raíz sin el marcador `.fda-fixture`: **parar**.
- Si `aplicar.sh` fuera a escribir su log dentro de `evidence/WP-008/` durante una fase: **parar**.
- Si `H_OTROS` o `H_STAGED` cambiaran durante una fase: **parar**.
- Mientras S1 esté **operativo**, si se abre cualquier sesión de agente: **parar**. Esa ventana es de operación humana exclusiva.
- Si un lanzador o una barrera deja S1 **detenido**, la cadena queda congelada. Se permiten auditorías de agente solo de lectura para explicar la parada y preparar una decisión humana, pero no escrituras, red, Git mutable, ejecución de `.command`, fase verde ni reanudación automática. Cualquiera de esas operaciones: **parar**.
- Si se ejecutase la fase verde o se empujase `C_VERDE` **antes** de que la barrera roja haya salido `0`: **parar**.
- Si la forma del run fuese desconocida —exit `2` del validador por job, paso, nombre, versión, unicidad u orden—: **parar**. No se amplía el oráculo por patrón ni se interpreta a mano.
- Si la barrera roja saliera `1`: **parar**. La composición del run rojo no es la contratada.
- Si la barrera verde saliera **`1`**: **parar**. No se reabren agentes, no se prepara `C_EVIDENCIA`, no se empuja, no hay `amend`, `rebase` ni force-push, y se solicita decisión humana.
- Si la barrera verde saliera **`2`** por timeout, adquisición o entorno: **parar** y **solicitar decisión humana**.
- Si la barrera roja saliera `2` por expiración del tiempo máximo: **parar** y solicitar decisión. No se amplía el tiempo por iniciativa propia.
- Si una captura destinada a evidencia real llevase `modo=fixture` en su log: **parar**. No es evidencia de CI.
- Si la ejecución roja fallara además en algún paso o job distinto del preflight: **parar**.
- Si el run de `C_ROJO` terminase con `conclusion` igual a `cancelled`: **parar de inmediato**. No sirve como evidencia del bloqueo. **No se empuja nada más**; **no se intenta reconstruir la evidencia con commits adicionales**, porque un cuarto commit rompería la cadena exacta; y se declara por escrito que la situación **no es recuperable automáticamente** dentro de `C_ROJO` a `C_VERDE` a `C_EVIDENCIA`. Se solicita decisión humana sobre abandonar la rama y la PR.
- Si la ejecución en rojo exigiera tocar `main`, el ruleset, otra rama u otra PR además de la única rama y PR vivas autorizadas por `DEC-006`: **parar**. La excepción `-r2` no se puede repetir por analogía.
- Si `check-alcance-wp008.sh` saliera `1` en cualquiera de sus dos modos: **parar**. Hay una ruta fuera de alcance o una invocación que rompe el invariante de cuarentena.
- Si `bash tests/guard/run-suite.sh` dejara de dar sus contadores actuales, o si el archivo apareciera en el diff: **parar**. `DEC-003` §7 lo prohíbe durante toda la pausa.
- Si se planteara fijar acciones por SHA, tocar `claude.yml` o `code-review.yml`, o corregir cualquier punto de `REQ-FDA-002`: **parar**. Es WP-009.
- Si se planteara construir la adquisición headless del coste, el validador de `cost.md` o el registro de excepciones: **parar**. Es WP-010.
- Si se planteara la frontera de revisión verificable o reactivar cualquier workflow de agente: **parar**. Es WP-011.
- Si se planteara tocar `evidence/WP-007/**`, el worktree congelado, WP-002, `DEC-003`, `DEC-004`, `DEC-005`, `ACTIVE`, el ruleset o el estado externo de los workflows: **parar**.
- Si se planteara leer, enumerar, versionar o modificar `.agents/`, `.codex/` o `AGENTS.md`: **parar**. Están en cuarentena por `DEC-003` §8.
- Si se planteara ampliar a `docs/manual/**` o a cualquier ruta de `specs/requirements/` distinta de `SEC-001`: **parar** y solicitar decisión.
- Si `SEC-001` fuese a afirmar que las reglas ancladas resuelven a la raíz en ejecución: **parar**. Ese enunciado es de WP-012.
- Si algún agente intentara escribir directamente `.claude/settings.json` o `.github/workflows/ci.yml`: **parar**. Esas rutas las aplica una persona, siempre.
- Si un agente fuese a firmar una cifra de coste obtenida por F3: **parar**. F3 la firma una persona.
- Si el `security-reviewer` reportara un hallazgo de severidad **ALTA** o **CRÍTICA**: el WP **se bloquea** y no se fusiona.
- Si se alcanzase el **tercer ciclo de corrección de `-r2`**: **parar**. El presupuesto nuevo concedido por `DEC-006` es de **dos** ciclos y el tercero exige otra decisión humana, nueva, fechada y versionada.

## Migración / rollback

### Precondiciones de activación

**Este contrato no se activa a sí mismo.** Su activación exige, en este orden y como
actos del operador:

1. Este contrato reducido **materializado, validado y aprobado** en una PR de
   operador que modifique **exactamente un archivo**.
2. El **aislamiento de `DEC-005` §9 completamente terminado**.
3. La rama `wp/WP-008-runtime-fail-closed-r2` creada desde el `origin/main`
   posterior a la PR de contrato y **exactamente igual al `origin/main` de ese
   momento**: `git rev-parse HEAD` y `git rev-parse origin/main` devuelven el mismo
   hash. Tras la PR de activación se restablece y vuelve a demostrar esa igualdad
   por fast-forward antes de iniciar trabajo.
4. Un **acto humano posterior** que escriba `WP-008` en `work-packages/ACTIVE`,
   conforme al paso 2 de la secuencia de `DEC-003` §2.

Mientras las precondiciones 1, 2 y 3 en su estado inicial no se cumplan, `ACTIVE`
permanece en **reposo** y ningún agente escribe. La precondición 4 es la PR C que
sale de ese reposo; tras ella se restablece la igualdad final de la precondición 3
antes de iniciar trabajo.

### Orden de aplicación obligatorio

1. El agente se inicia **en la raíz del repositorio** y comprueba **en solo
   lectura** que `.claude/hooks/guard.sh` existe y es ejecutable.
2. Escribir `check-config.sh`, sus dos oráculos, `test-check-config.sh`,
   `test-protocolo.sh`, `capturar-ci-rojo.sh`, `test-capturar-ci-rojo.sh`,
   `check-alcance-wp008.sh`, el archivo de patrones y los fixtures de los cuatro
   prefijos propios.
3. Preparar los dos candidatos y `evidence/WP-008/parche/`.
4. Actualizar los cinco archivos de `docs/manual/`, la guía fundacional y
   `SEC-001`. **Toda la documentación queda terminada aquí.**
5. Ejecutar la **batería preparatoria A** completa sobre el **estado definitivo de
   preparación** —con el código escrito y la documentación ya actualizada—, que
   debe salir **`0`** en todos sus comandos, incluida la validación del candidato
   con argumentos explícitos y la validación **nominal** del `ci.yml.candidato`.
   **Adelantar la batería A a un estado con la documentación sin terminar la
   invalida**, porque habría verificado un estado distinto del que se commitea.
6. La persona ejecuta la **fase roja** y después **la secuencia de ocho pasos**
   hasta empujar `C_ROJO`.
7. La persona abre la **única PR de implementación**, como borrador, contra
   `main`. Comprueba que el run de `C_ROJO` nace con `event=pull_request`.
8. La persona lanza la **barrera roja** y espera su exit `0`.
9. La persona ejecuta la **fase verde**, commitea `C_VERDE` y empuja.
10. La persona lanza la **barrera verde** y espera su exit `0`. Hasta entonces no se
   reabre ninguna sesión de agente.
11. Con el par ya en **S2**, se ejecuta la **batería final B** completa y se
    prepara la evidencia saneada; la persona ejecuta la **tercera y última
    operación de red**, commitea `C_EVIDENCIA` y empuja.

**No hay ninguna barrera de comportamiento en este orden.** El contrato anterior
situaba una medición como paso bloqueante; esa barrera pertenece ahora a WP-012 y
**no condiciona la instalación del núcleo**.

Implementación, pruebas y documentación viajan en **una única PR de WP**. La
preparación y activación del WP, y su cierre, son **PRs de operador separadas**.

### La secuencia de ocho pasos entre la fase roja y el push de `C_ROJO`

La ejecuta **la persona**, no el agente, y **ningún paso puede saltarse**. Es la
barrera que impide que una ruta fuera de alcance entre en un commit o en el push:

1. Preparar en el índice **solo rutas nominales**, una por una, tomadas de
   `## Archivos permitidos`. **Quedan prohibidos `git add .` y `git add -A`**, sin
   excepción: enumerarían la cuarentena de `DEC-003` §8 y podrían preparar alguno
   de los candidatos.
2. Volcar la lista preparada a un archivo temporal **externo al repositorio**,
   conforme a la sección 9, con `git diff --cached --name-only -z`. El separador
   **NUL** es obligatorio: una ruta con espacios o saltos de línea no puede
   partirse ni colarse entera.
3. Ejecutar `bash tests/runtime/check-alcance-wp008.sh --lista ARCHIVO_NUL`.
4. Si sale **`1`**, retirar del índice **cada ruta infractora impresa** con
   `git restore --staged` y volver al paso 1. **No se continúa con una infracción
   pendiente.**
5. Si sale **`0`**, guardar la salida en un **archivo temporal externo al
   repositorio**, conforme a la sección 9, con el nombre lógico
   `staged-C_ROJO.log`. **Durante S1 no se escribe absolutamente nada bajo
   `evidence/WP-008/`**: hacerlo añadiría una ruta al árbol después de haber
   validado el índice. Se anotan su **ruta física** y su **SHA-256**.
6. **Revalidar que la lista no ha quedado obsoleta.** Volver a calcular la lista
   NUL del área staged con `git diff --cached --name-only -z` y su **SHA-256**, y
   exigir que **ambos sean idénticos** a los del paso 2 que se validaron en el
   paso 3. Si difieren, algo entró o salió del índice después de la comprobación:
   volver al paso 1. **Solo con la identidad demostrada** se crea `C_ROJO` **en
   local**, todavía sin empujar.
7. Ejecutar `bash tests/runtime/check-alcance-wp008.sh` **sin argumentos** contra
   `main...HEAD`, ahora que el diff real ya existe, y **exigir exit `0`**. Su
   salida se guarda **también fuera del repositorio**, con el nombre lógico
   `diff-post-commit-C_ROJO.log`, y se anotan su ruta física y su SHA-256.
8. **Solo entonces** empujar `C_ROJO`.

Los pasos 3 y 7 son **dos comprobaciones distintas y ninguna sustituye a la otra**:
la primera mira **lo preparado** cuando deshacerlo todavía es trivial; la segunda
mira **lo commiteado** cuando aún no se ha publicado. El paso 6 cierra la rendija
que quedaba entre ambas. Entre los tres queda cubierta la ventana entera en la que
una ruta fuera de alcance podría escaparse.

**Dónde viven los dos registros, y por qué no en `C_ROJO`.** Cuatro afirmaciones,
todas contractuales y todas verificables:

1. **`C_ROJO` no contiene ninguna ruta bajo `evidence/WP-008/**`.** Ni los dos
   registros de alcance, ni el parche, ni ninguna otra evidencia. Escribir
   evidencia durante **S1** añadiría rutas **después** de haber validado el índice
   y dejaría obsoleta, en el mismo acto, la comprobación del paso 3.
2. **La validación del staged no queda obsoleta por escrituras posteriores**,
   porque el **paso 6** recalcula la lista NUL y su SHA-256 y exige identidad
   **inmediatamente antes** de crear el commit. Cualquier escritura intermedia
   rompe esa identidad y devuelve la secuencia al paso 1.
3. **`C_EVIDENCIA` contiene las copias finales** de los dos registros externos, en
   `evidence/WP-008/alcance/`, junto con el resto de la evidencia real y con el
   parche.
4. **El contenido permite relacionarlos con `C_ROJO`.** Cada registro incorporado
   lleva su **ruta física de origen**, su **SHA-256** —idéntico al anotado durante
   S1, lo que prueba que no se regeneró después— y el **hash completo de `C_ROJO`**
   contra el que se ejecutó. La correspondencia es así verificable sin depender del
   orden de los archivos ni de la palabra de nadie.

### Una rama, una PR, tres commits

Rama `wp/WP-008-runtime-fail-closed-r2`. Una PR viva. Sin `amend`, sin `rebase`, sin
force-push, sin reescritura de historial.

| Fase | Quién | Qué ocurre |
|---|---|---|
| **Preparación**, par en S0 | Agente | Implementa los seis scripts, los dos oráculos, los fixtures de los cuatro prefijos, los cinco archivos de `docs/manual/`, la guía fundacional, `SEC-001` y `evidence/WP-008/parche/**` con los candidatos, y ejecuta la **batería A**. `evidence/WP-008/**` queda **en el árbol de trabajo y fuera del índice**: viaja en `C_EVIDENCIA`, no en `C_ROJO`. **No toca** `settings.json` ni `ci.yml`: son rutas vedadas |
| **Fase roja** | **Persona** | Ejecuta `aplicar.sh rojo` y después la repetición idempotente. Par S0 a **S1**. Los logs quedan en el directorio temporal externo |
| **`C_ROJO`** | **Persona** | Commitea implementación, pruebas, oráculos, fixtures, documentación y `ci.yml` en `DESPUES` siguiendo **la secuencia de ocho pasos**: alcance validado sobre la **lista staged antes del commit**, lista **revalidada por hash** justo antes de commitear, y **diff comprobado después del commit y antes del push**. **`C_ROJO` no contiene ninguna ruta bajo `evidence/WP-008/**`.** **`settings.json` permanece exactamente en `ANTES`.** Empuja |
| **PR en borrador** | **Persona** | Abre la única PR viva después del push de `C_ROJO`; su evento `pull_request` dispara el run contractual |
| — | CI | Se ejecuta sobre `C_ROJO`. La forma, los jobs, los oráculos declarados y el housekeeping coinciden exactamente con la sección 6c. **No hay ninguna segunda causa de fallo** |
| **Barrera roja** | **Persona lanza el comprobador** | Espera con polling acotado a 20 minutos, valida automáticamente sus ocho condiciones y escribe la captura **fuera del repositorio**. **Solo si sale `0`** continúa |
| **Fase verde** | **Persona** | Con S1 operativo y **sin abrir ninguna sesión de agente**, ejecuta `aplicar.sh verde` y después la repetición idempotente. Par S1 a **S2** |
| **`C_VERDE`** | **Persona** | Hijo **directo** de `C_ROJO`. Entre los dos archivos protegidos cambia **únicamente** `.claude/settings.json`, de `ANTES` a `DESPUES`. Empuja |
| — | CI | Se ejecuta sobre `C_VERDE` |
| **Barrera verde** | **Persona lanza el comprobador** | **Solo si sale `0`** puede reabrirse una sesión de agente, ejecutarse la **batería B** y prepararse `C_EVIDENCIA`. Si sale `1` o `2`, se aplica el contrato de parada de la sección 6f |
| **Antes de `C_EVIDENCIA`** | **Persona** | Ejecuta `gh pr view PR_NUMERO --json commits` y comprueba que la PR contiene **exactamente dos** commits, `C_ROJO` y `C_VERDE`, **en ese orden**. Es la tercera y última operación de red de este contrato |
| **`C_EVIDENCIA`** | Agente y **persona** | El agente **escribe** en `evidence/WP-008/**`, que es ruta permitida, a partir de las capturas ya adquiridas. Incorpora el parche, los logs temporales de las fases, **los dos registros de alcance generados fuera del repositorio durante S1**, la batería B y las capturas de las dos barreras, y registra hashes, `run_id`, `headSha`, URL y `conclusion`. Cada registro incorporado conserva su **SHA-256 de S1** y el **hash de `C_ROJO`** contra el que se ejecutó. La **persona** commitea **en local**, comprueba **con Git local** que la rama tiene ya la forma de **tres commits** en el orden contratado, y solo entonces empuja |
| — | CI | Se ejecuta sobre `C_EVIDENCIA` y **debe quedar verde** |

**Por qué las barreras son obligatorias y no una recomendación.**
`.github/workflows/ci.yml` declara `concurrency` con cancelación de runs en curso.
Empujar el commit siguiente mientras el run anterior sigue vivo **lo cancelaría**, y
la evidencia se perdería sin dejar rastro utilizable. Las barreras no protegen el
proceso: protegen las únicas pruebas de que el control bloquea y de que la
configuración final es conforme.

**Ninguna sesión de agente mientras S1 esté operativo.** En S1 el `settings.json`
sigue **exactamente en `ANTES`**: no hay ninguna configuración degradada a
propósito, y el runtime local es el mismo que hay hoy en `main`. Lo que no puede
ocurrir es que un agente trabaje con el protocolo a medias, porque un commit suyo
entre `C_ROJO` y `C_VERDE` rompería la cadena de evidencias y la ascendencia
directa.

Si un lanzador o barrera declara `PARADA`, S1 pasa a **detenido** y la cadena se
congela. Solo entonces se permiten auditorías de agente de solo lectura bajo las
restricciones de las condiciones de parada. Ninguna auditoría reanuda la cadena.

**Frontera de permisos, dicha con precisión.** El acceso del agente a **GitHub** es
de solo lectura. La **creación de evidencias** en `evidence/WP-008/**` es una
**escritura local autorizada** por el contrato. Las escrituras en
`.claude/settings.json` y `.github/workflows/ci.yml`, y todas las operaciones de Git
que publican, son **actos humanos**.

**Autoría de `cost.md`.** Se prepara durante `C_EVIDENCIA`, incluye la fila
`Ciclos de corrección | N / 2` y la relación nominal de las pasadas, y su estado corresponde a
la procedencia real. Si la fuente es **F3**, la lectura, la estimación y el registro
los realiza **la persona**: un agente no puede firmar F3. Si la fuente es **F1 o F2**
y es conforme, una automatización determinista versionada puede registrar el
resultado. En ningún caso un agente inventa una cifra, una causa o una base de
estimación.

**Por qué hacen falta las dos capturas de CI.** Una ejecución verde demuestra que el
paso no rompe nada; solo la roja demuestra que **bloquea**. Un control que nunca se
ha visto fallar es indistinguible de un adorno, y es la lección de los cinco falsos
verdes que registra `DEC-003` §3.

**Amend, rebase y force-push quedan prohibidos** durante todo el WP. Es una **regla
operativa**, y el contrato no pretende que ningún artefacto la certifique. Lo que sí
queda demostrado con artefactos versionados y metadatos de la PR es la **forma
final** de la cadena: `C_ROJO`, `C_VERDE`, `C_EVIDENCIA`, con los dos runs apuntando
a los `headSha` correctos.

### Rollback durante la aplicación: automático y por fase

Lo hace `aplicar.sh` sin intervención, restaurando el archivo de esa fase desde su
directorio temporal y comprobando que el par vuelve al estado de origen de la fase:
**S0** para la roja, **S1** para la verde. Esos directorios **no** se versionan y sus
rutas físicas se imprimen en el log, para poder restaurar a mano si el propio
rollback fallara.

### Rollback posterior, no destructivo

Nunca reinicio duro del árbol, nunca borrado forzado de la rama, nunca force-push,
nunca reescritura de historial.

- **Antes del commit:** restaurar por rutas explícitas desde `HEAD`, nombrando cada
  ruta afectada. Nada de restauraciones masivas, y sin depender de ninguna copia
  versionada: no existe ninguna.
- **Tras un commit local no publicado:** cambiar a `main` conservando la rama
  intacta. Para abandonarla se informa del **nombre de la rama** y del **hash** y se
  espera **autorización humana explícita**; solo se borra la rama local cuando Git
  confirme que está fusionada.
- **Tras el push:** cerrar la PR sin fusionar y conservar rama, commits y custodia
  hasta que una decisión humana, nueva y registrada, determine su retención. No se
  borra automáticamente la rama remota y `main` no se modifica por este acto. La
  conservación de la primera rama abandonada está autorizada nominalmente por
  `DEC-006`; cualquier abandono posterior exige su propia decisión.
- **Tras una eventual fusión:** revertir mediante una **PR nueva** de revert. No se
  reescribe el historial de `main`. Una reversión deja el runtime en el estado
  previo, que es el fail-open conocido y registrado por `DEC-003` §1: la reversión
  **no es neutra** y debe ir acompañada de la decisión humana que la justifique.
