# DEC-007 — Punto de control de la pausa y rumbo v2

**Estado:** aceptada · **Fecha de decisión:** 2026-09-09 ·
**Preparada:** 2026-09-03 · **Ratificada:** 2026-09-09 ·
**Ámbito:** punto de control de [`DEC-003`](DEC-003-pausa-migracion-y-contencion.md), decisiones D1–D6 de la hoja de ruta
v2, secuencia de cierre de la pausa, dos carriles de producto y tratamiento de
la candidata local de WP-008-r2

**Condición de vigencia.** El punto de control previsto para el 2026-09-07 se
resuelve mediante esta decisión fechada el 2026-09-09. D1, D2, D3, D4 y D6
quedan ratificadas; D5 queda resuelta por su default, sin acuerdo formal. La
decisión entra en vigor únicamente cuando esta PR de operador se fusione en
`main`. Hasta ese acto no modifica `ACTIVE`, no reduce ningún contrato, no
abre ninguna pasada y no autoriza por sí misma Git mutable, red, implementación
ni una transición de operador.

**Composición de la PR.** D3 queda ratificada; por tanto, la composición cerrada
es de **nueve archivos** (§ Condición de admisibilidad y composición). La variante
de tres archivos correspondiente al default de D3 no aplica.

## Fuentes y foto corregida

La orientación elegida por la persona es la revisión v2 del commit
`a45228ee1185fc409a7f7cd565a353950f50ecd8`:

- [`docs/03-hoja-de-ruta.md`](../../docs/03-hoja-de-ruta.md), SHA-256 de origen
  `e5c9b266f4839556681db592d18e94106087ebaf023e18ff0e085478fa3d5735`;
- [`docs/04-analisis-conversaciones-ia.md`](../../docs/04-analisis-conversaciones-ia.md), SHA-256
  `c832715e55188ffb94d0f5c107066528e080b895cee9b04ee1929ac95304dbe9`;
- [`docs/05-analisis-investigacion-leandro-y-revalidacion.md`](../../docs/05-analisis-investigacion-leandro-y-revalidacion.md), SHA-256 de origen
  `29cd58531a45276775b34ecb906011294677ea50c0e116080482c149f8ae4b5e`.

La fuente no era vinculante mientras se preparaba el punto de control. Esta PR
incorpora los tres documentos y los admite atómicamente en `DEC-003` §4. El
documento 04 entra **byte a byte** desde el commit citado; 03 y 05 entran con la
corrección de foto que esta decisión exige, por lo que su huella de destino
difiere de la de origen y se verifica en el diff de la PR.

La foto de esos documentos necesitaba una corrección antes de fusionarse. En
GitHub no existían rama R2, implementación publicada ni PR; localmente sí
existían trabajo y coste hundidos:

| Magnitud al 2026-09-03 | Estado verificado |
|---|---|
| Worktree | worktree local de la rama `wp/WP-008-runtime-fail-closed-r2` (ruta absoluta deliberadamente no versionada) |
| Rama | `wp/WP-008-runtime-fail-closed-r2`, no publicada |
| Base | `HEAD = main = origin/main = 41d7ffcb25e5283f1ff04cc516211ce9549caa66` |
| Candidata física | 72 regulares: 46 `tests/runtime/` + 26 `evidence/WP-008/` |
| Batería | A completa, 22/22; ciclos 1 y 2 cerrados |
| Revisiones (preparación externa, Nota 49) | QA, code review y security review exigen cambios; los seis defectos quedan definidos en § Registro cerrado de hallazgos de WP-008 como `WP008-F1`–`WP008-F6` |
| Historia publicada | cero commit de implementación, cero PR y cero fase real |
| Digest de los 72 | `9460ac80183745bc496e80464641adc59f8737dbc699ff8bca89fc82aa092969` |
| Digest de los otros 71 | `22fd0119d745e773603949d2f61f279162afc76cdf45eab2a4342eb66ce69cf3` |
| Flujo NUL de rutas | `2abd93d5d33b557d8c6a5714528565117abec2f838f5f89ac0e8b3b9f14341d8` |

**Sobre la fila de revisiones.** Los tres dictámenes —QA, code review y security
review— proceden de la **preparación externa registrada en la Nota 49**, que
**no es un expediente versionado en este repositorio** y cuyo soporte es
efímero. Por eso esta decisión **no depende de ellos**: los seis defectos a los
que se refieren se definen íntegramente, con ruta, defecto y razón, en
§ **Registro cerrado de hallazgos de WP-008**, dentro de este mismo archivo.
Quien lea únicamente el repositorio dispone del conjunto completo y puede
distinguir un hallazgo del conjunto de uno nuevo sin consultar ninguna fuente
externa. La Nota 49 se cita como procedencia histórica, nunca como norma.

Las demás filas de esta tabla son magnitudes medidas directamente sobre el
worktree y recalculables en solo lectura, sin escribir nada.

La recomendación de reducir WP-008 se mantiene por coste futuro, superficie de
fallo y por la **arquitectura objetivo** de enforcement en tres capas —de la que
hoy solo está **parcialmente materializada la primera**, ver D1 y `docs/03` P1—.
No se justifica con la inexistencia del trabajo local ni se borra ese trabajo de
la historia.

**Estado real de la capa de plataforma, en cinco niveles que no deben fundirse:**

1. **Impuesto técnicamente por el ruleset:** pull request obligatoria; los tres
   checks bloqueantes; `non_fast_forward` y `deletion` bloqueados. **Esas cuatro
   reglas son todo lo acreditado por el expediente actual**, que **no incluye un
   inventario exhaustivo del ruleset**: **no se ha acreditado ninguna regla del
   ruleset que impida la autofusión** y, con `required_approving_review_count: 0`
   y `require_code_owner_review: false`, **las vías observadas no la impiden por
   sí solas**. **Esta decisión no atribuye al ruleset esa imposibilidad.**
2. **Práctica del operador, no impuesta por el ruleset:** la lectura del diff y
   la fusión humana. Son disciplina, no barrera automática.
3. **Política vigente, no impuesta técnicamente:** `CLAUDE.md` prohíbe que un
   agente fusione su propia PR. Es norma escrita, no control de plataforma.
4. **Restricciones operativas actuales:** las allowlists de herramientas de
   `.claude/agents/*.md` y los workflows de agente desactivados (`DEC-003` §3).
   Reducen la superficie efectiva, pero **no son garantía universal**: no se han
   auditado todos los actores ni todas las credenciales, y `DEC-003` §4 registra
   que el job de agente concedía `contents: write` y `pull-requests: write`.
5. **Declarado necesario y todavía NO impuesto técnicamente:** al menos una
   aprobación humana y la revisión de `CODEOWNERS`. Hoy el ruleset registra
   `required_approving_review_count: 0` y `require_code_owner_review: false`;
   `DEC-003` lo consigna como **riesgo abierto y no aprobado**, con destino
   **WP-011**.

**Riesgo pendiente.** Con cero aprobaciones exigidas, el ruleset **no impide por
sí solo** que el autor de una PR la fusione si tiene permisos suficientes. Ningún
texto de gobierno puede presentar la imposibilidad de autofusión como impuesta
por el ruleset.

**La protección de rama no comprueba el alcance del WP.** Ese control es
`check_scope`, que todavía no existe. Hasta entonces la revisión del diff es una
**práctica humana**, no una barrera automática ni una exigencia del ruleset.

## Problema

La pausa de `DEC-003` llegó a su segundo punto de control sin cumplir el criterio
de salida. El bloqueo es de dirección, no de calendario:

1. el guard es feedback best-effort y se intentó endurecer como si fuera una
   frontera de seguridad;
2. el check concluyente del diff en CI sigue pendiente;
3. un sandbox del sistema operativo **ofrecería** una barrera más fuerte que
   seguir ampliando el parser del guard **si E2 supera su gate y el WP T3 lo
   adopta efectivamente**; hoy **no está instalado**;
4. una ceremonia única produjo una espiral de auditoría y contratos
   desproporcionados;
5. la fábrica lleva demasiado tiempo sin entregar producto;
6. existe ya una segunda instalación potencial que exige separar upstream y
   downstream sin bifurcar la verdad normativa.

La persona pidió seguir las recomendaciones de la hoja de ruta. Esta decisión
recoge las elecciones ratificadas el 2026-09-09; la fusión humana de esta PR
las convierte en decisiones versionadas.

## Condición de admisibilidad y composición

`DEC-007` no puede admitirse a sí misma. La PR de operador del punto de control
solo es admisible si contiene en el mismo diff atómico todas las rutas necesarias
para que la decisión y el manual no se contradigan.

**Composición cerrada de la variante D3 ratificada: nueve archivos.** No es una
cardinalidad decidida de antemano: es la que resulta de exigir que ningún texto
vinculante quede contradiciendo a otro dentro de `main`. Cada ruta se justifica
por una necesidad normativa concreta, no por simetría.

**Las seis que materializan la decisión y el rumbo:**

1. [`specs/decisions/DEC-003-pausa-migracion-y-contencion.md`](DEC-003-pausa-migracion-y-contencion.md) — admite
   `DEC-007`, `docs/03–05` y las tres rutas de gobierno; registra el resultado del
   punto de control; actualiza la secuencia de `ACTIVE` y el criterio de salida
   conforme a D1–D6. **`DEC-007` no puede admitirse a sí misma**: sin esta ruta la
   admisión sería circular;
2. `specs/decisions/DEC-007-punto-de-control-y-rumbo.md` — crea esta decisión;
3. [`docs/03-hoja-de-ruta.md`](../../docs/03-hoja-de-ruta.md) — incorpora la hoja de ruta v2, corrige su foto de
   WP-008-r2 y separa arquitectura objetivo de estado materializado;
4. [`docs/04-analisis-conversaciones-ia.md`](../../docs/04-analisis-conversaciones-ia.md) — incorpora el análisis y su remisión
   a la revisión 05. Entra **byte a byte**;
5. [`docs/05-analisis-investigacion-leandro-y-revalidacion.md`](../../docs/05-analisis-investigacion-leandro-y-revalidacion.md) — incorpora la
   revisión y corrige las afirmaciones de que R2 no existía, no había empezado y
   no existía coste hundido;
6. [`docs/manual/05-bloqueos-y-parada.md`](../../docs/manual/05-bloqueos-y-parada.md) — incorpora `DEC-007` y `docs/03–05` a
   la pausa y refleja la secuencia y el criterio de salida nuevos. `CLAUDE.md`
   obliga a actualizar `docs/manual/` **en la misma PR** que cambia el proceso.

**Las tres de gobierno, sin las cuales la PR crearía normas contradictorias.**
D3 convierte `docs/03` en rumbo vinculante, y su principio P1 describe el hook
como feedback preventivo *best-effort* y no como capa de enforcement. Tres textos
vinculantes afirman hoy lo contrario **sin salvedad alguna**, y dejarlos intactos
dispararía la condición de parada «contradicción entre requisitos» de `CLAUDE.md`
en la primera lectura de cualquier agente:

7. [`CLAUDE.md`](../../CLAUDE.md) — dice que el hook «lo hace cumplir de forma
   determinista». **Segundo motivo, independiente:** el orden de lectura
   obligatorio arranca en la constitución, y hoy `CLAUDE.md` **no nombra**
   `docs/03`; sin ese enlace el rumbo vinculante sería indescubrible sin memoria
   conversacional, que es exactamente lo que el manual promete evitar;
8. [`docs/manual/MANUAL.md`](../../docs/manual/MANUAL.md) — su modelo de controles presenta «tres controles
   deterministas» con el hook impidiendo la escritura fuera de alcance, y su
   regla 2 dice «lo demás lo bloquea el hook»; y su **mapa del repositorio** abrevia
   `CODEOWNERS` como «revisión obligatoria» y `guard.sh` como «bloquea escrituras
   fuera del alcance», contradiciendo el cuerpo del propio archivo. **Segundo motivo,
   independiente:** «Documentos fundacionales» y el mapa del repositorio deben listar
   `docs/03`, `docs/04` y `docs/05` —con su estatus distinguido— para que el rumbo
   sea navegable desde el índice;
9. [`docs/02-guia-fabrica-desarrollo-agentica.md`](../../docs/02-guia-fabrica-desarrollo-agentica.md) — el propio manual la
   declara «la especificación vinculante del sistema». Dice «Guardas deterministas
   (hooks)», «`guard.sh` … bloquea la operación», «la seguridad … depende de …
   hooks» y «`## Archivos permitidos` ← el hook lo hace cumplir»; su **mapa de §2**
   abrevia `CODEOWNERS` como «revisión obligatoria» y `guard.sh` como «bloquea rutas
   protegidas y comandos vetados» —deny que en realidad vive en `permissions.deny` de
   `settings.json`—; y atribuye a **branch protection** la imposibilidad de autofusión.
   Con `docs/03` vinculante habría **dos especificaciones vinculantes en contradicción
   directa sobre el mismo control**.

**Qué NO se amplía.** No entran `docs/manual/04-agentes.md` —ya contiene el matiz
correcto: analizador de `Bash` *best-effort* y capa hermética en PR, CI y revisión
humana— ni los capítulos 01, 02, 03, 06 y 07 del manual, cuyas descripciones
siguen siendo operativamente válidas una vez corregidos los literales de `ACTIVE`.
Tampoco `ACTIVE`, `DEC-005`, `DEC-006`, el contrato de WP-008, `work-packages/**`,
implementación ni evidencia. Las decisiones anteriores se conservan como historia
y quedan superadas solo en las cláusulas que `DEC-007` identifica expresamente.

**Cardinalidad condicionada a D3, escrita de antemano** —igual que las dos ramas
de D6, y por la misma regla anti-espiral:

| Resultado de D3 | Composición | Nota |
|---|---|---|
| **Ratificada** (recomendada) | **nueve** rutas, las de arriba | Es la variante preparada |
| **Default** (`docs/03–05` siguen en rama, no vinculantes) | **tres** rutas: `DEC-003`, `DEC-007` y `docs/manual/05-bloqueos-y-parada.md` | Sin rumbo vinculante no nace la contradicción del hook, y `docs/03–05` no se fusionan ni se admiten en §4 |

**No se extraen selectivamente tres archivos de los nueve.** La variante de tres
rutas exige textos propios —`DEC-003` §4 no admitiría `docs/03–05`, y `DEC-007`
no podría remitirse a un rumbo no fusionado—, de modo que es una preparación
distinta y todavía no realizada.

Si una auditoría demuestra que una décima ruta es normativa y materialmente
necesaria, se corrige esta composición **antes** de materializarla. No se amplía
por simetría, conveniencia ni documentación deseable.

## Decisión: D1–D6

La persona resuelve las seis decisiones de forma explícita. No queda ninguna
celda pendiente ni se retrotrae la fecha al punto de control previsto.

| # | Resolución efectiva |
|---|---|
| D1 | **Ratificada.** Sustituir WP-012 por humo documentado + check de alcance **ejecutándose en CI e incorporado a `required_status_checks`** + experimento/adopción gateada del sandbox |
| D2 | **Ratificada con la precisión de D2.** Adoptar T1/T2/T3 decididos por clasificador ejecutable de blast radius, con suelo automático común |
| D3 | **Ratificada.** Fusionar 03–05: `docs/03` como hoja de ruta normativa; `docs/04` y `docs/05` como procedencia, análisis y fotos fijas, con la foto local corregida |
| D4 | **Ratificada.** Adoptar únicamente los elementos marcados `ADOPTAR`, en sus etapas |
| D5 | **Default: sin acuerdo formal por ahora.** El modelo de dos carriles se conserva como propuesta; no se asignan responsabilidades, productos, repositorios ni accesos |
| D6 | **Ratificada.** Reducir WP-008-r2 al núcleo mínimo |

Las ramas alternativas se conservan como explicación de los defaults y de sus
efectos; no describen la resolución elegida.

### D1 — Sustituir WP-012

La tercera condición de salida de `DEC-003` deja de exigir el runner empírico de
WP-012 y pasa a titularse **«Control de alcance concluyente y resolución del gate
del sandbox»**, exigiendo conjuntamente:

1. **un humo seguro documentado, que pertenece a `WP-008`.** No es una actividad
   suelta ni un estado de `ACTIVE`: entra en el alcance del contrato reducido o
   íntegro de WP-008 según la rama de D6 resuelta, **se ejecuta antes de cerrar
   WP-008** y su salida se registra en `evidence/WP-008/`. Verifica que el runtime
   carga la configuración y resuelve, como mínimo, el caso de cero segmentos
   `Read(/**/.env*)` frente a `.env` en la raíz del proyecto. **Si falla, WP-008
   no se cierra**: se trata como cualquier otro criterio de aceptación incumplido
   y se aplica el presupuesto de ciclos vigente de su contrato, sin abrir ninguno
   nuevo ni reabrir un WP ya cerrado.

   **Condiciones de seguridad del humo, vinculantes y no negociables.** El ensayo
   se monta **sobre un proyecto desechable y aislado**, creado para la ocasión y
   situado **físicamente fuera de la raíz de FDA**; el archivo de prueba es un
   **`.env` sintético con contenido marcador y cero secretos reales**; queda
   **prohibido crear, leer o modificar cualquier `.env`, secreto o archivo real
   de FDA**; la **evidencia se registra saneada**, sin contenido sensible ni
   volcados del archivo de prueba; y la **limpieza se limita exclusivamente a los
   recursos propios del ensayo**, sin tocar nada del repositorio. Un humo que no
   cumpla estas condiciones **no es admisible como evidencia** de esta condición
   de salida;
2. **el check de alcance del diff de PR**, basado en una única librería de
   matching. Lo construyen `WP-002` y `WP-005`, **secuencialmente**, cada uno con
   su contrato, su rama y su PR.

   **Tres estados distintos, que esta decisión nunca funde:**

   | # | Estado | Quién lo produce | Qué puede y qué no |
   |---|---|---|---|
   | 1 | **`check_scope` ejecutable local** | `WP-002` | Lo invocan a mano el operador y los revisores. **No es check de GitHub y no bloquea ninguna fusión** |
   | 2 | **Job integrado y ejecutándose en CI** | `WP-005` | **Se ejecuta en CI** y puede ponerse rojo, pero **todavía no es requerido**: **no impide fusionar** |
   | 3 | **Check incorporado a `required_status_checks`** | **Una persona**, por mutación del ruleset | Desde ese momento **bloquea la fusión** |

   **Esta condición exige los estados 2 y 3**: job **ejecutándose en CI** y check
   **incorporado a `required_status_checks`**. La expresión «bloqueante para la
   fusión» queda reservada **en exclusiva** al estado 3; para el estado 2 se dice
   **«ejecutándose en CI»**. **Hoy no existe ninguno de los tres.**

   La incorporación del estado 3 **no crea un quinto tipo de regla**: el ruleset
   acredita **cuatro tipos** —`deletion`, `non_fast_forward`, `pull_request` y
   `required_status_checks`— y lo que se añade es una **cuarta comprobación
   requerida dentro de `required_status_checks`**, que hoy contiene tres;
3. **el experimento E2 del sandbox ejecutado y su resultado registrado por
   escrito.** Lo que esta parte acredita es **la resolución del gate**, no una
   garantía. **Si E2 supera el gate**, se exige su **adopción efectiva mediante el
   futuro WP de nivel T3**. **Si no lo supera**, el gate queda **resuelto
   negativamente** y la pausa puede cumplir esta condición con las dos primeras
   partes. **Ni E2 ni ese WP T3 tienen hoy identificador reservado, y esta
   decisión no se lo inventa**: antes de ejecutarlos hará falta una decisión o
   enmienda posterior que asigne el identificador exacto, apruebe su contrato y lo
   admita en la lista cerrada de `DEC-003` §4. Hasta entonces `ACTIVE` permanece
   en reposo y su ejecución no está autorizada.

**Qué significa exactamente un E2 negativo, y qué no.** Resolver negativamente E2
**no materializa ninguna garantía del sistema operativo**. La **arquitectura
objetivo de tres capas continúa incompleta**; la **garantía del kernel solo
existe después de la adopción efectiva** del sandbox; y **cerrar la pausa tras un
E2 negativo no permite describir la capa 2 como conseguida** en ningún texto de
gobierno. Lo único que se acredita es que la pregunta se resolvió y se registró.

Ninguna de las tres demuestra la semántica general del runtime, y esta decisión
no lo afirma: se sustituye una demostración empírica por un control del
resultado. Tampoco son tres cosas ya existentes: **la 1 es alcance de un WP
todavía no reactivado, la 2 no está implementada y la 3 es un gate todavía sin
resolver.** WP-012 queda liberado como condición de salida y se conserva como
identificador histórico; no se ejecuta su runner por analogía.

**Si D1 queda resuelta por su default**, esta sección **no entra en vigor**: el
humo seguro **no se ejecuta como sustituto**, la tercera condición de salida
sigue siendo `WP-012` fusionado conforme a `DEC-005`/`DEC-006`, y rige la
secuencia separada que `DEC-003` §2 escribe expresamente para ese caso.

### D2 — Reforma proporcional y ejecutable

Se adopta la clasificación por superficie real:

- T1: documentación, datos de prueba y evidencia no ejecutable que no alteren
  controles, permisos, autorizaciones, contratos de seguridad ni el significado
  de una verificación;
- T2: código de producto, `scripts/**` y specs, salvo que cumplan un criterio
  de T3;
- T3: `.claude/**`, `.github/**`, permisos, secretos, migraciones, IaC,
  contratos de datos y `CODEOWNERS`; también cualquier archivo ejecutable o
  parche bajo `tests/**` o `evidence/**` que implemente, aplique o modifique
  un control, y cualquier cambio que altere la semántica de un control de
  seguridad o gobierno.

El nivel lo decide un script sobre rutas declaradas y diff, usando la misma
librería que `check_scope`; no lo decide el implementador. Todos los niveles
mantienen el mismo suelo automatizado de pruebas, secretos y controles de
**T3 prevalece** cuando un cambio coincide con más de un nivel. El clasificador
mantiene una lista versionada y probada de rutas sensibles; un cambio en esa
lista es T3. La PR que materialice D2 debe incluir casos negativos que demuestren
que mover un control a `tests/**` o `evidence/**` no rebaja su nivel.
seguridad. El nivel modula contrato y revisores, no el suelo.

La materialización —manual, `_TEMPLATE.md` y clasificador— es una PR de operador
posterior, separada y auditada. Esta decisión no la implementa.

### D3 — Hoja de ruta v2 vinculante

Se incorporan `docs/03`, `docs/04` y `docs/05` como orientación versionada. La
hoja 03 es la fuente viva; 04 y 05 conservan procedencia y razonamiento. Las
afirmaciones históricas sobre WP-008 se corrigen en 03 y 05 antes de fusionar:

- la rama existía localmente, no remotamente;
- había 72 archivos candidatos y batería cerrada;
- no había commit, PR ni fase real;
- el núcleo mínimo se elige por coste futuro y por la **arquitectura objetivo** de
  enforcement, no porque el trabajo previo no existiera.

**Qué se hace vinculante y qué no.** `docs/03` es la **hoja de ruta normativa si D3
se ratifica**: vinculan su **dirección**, sus principios, su secuencia de etapas y
sus criterios de salida. `docs/04` y `docs/05` se fusionan como **procedencia,
análisis y fotos fijas**, y **no gobiernan por sí solos el estado actual**. Los tres
**no son normas de estado igualmente vinculantes** y **no deben citarse en bloque**
como si lo fueran.

**No** se hace vinculante ninguna afirmación de estado que la propia hoja de ruta
corrige: `docs/03` P1 describe una arquitectura de **tres capas objetivo**
—plataforma, sandbox del sistema operativo y comprobación del diff de la PR en CI—
de la que **hoy solo está parcialmente materializada la primera**. Las otras dos son
gates futuros y esta decisión no las presenta como existentes.

**Regla de prevalencia temporal.** Cuando una descripción temporal de `docs/04` o de
`docs/05` contradiga el estado explícito de `docs/03` P1 —señaladamente cualquier
presente indicativo sobre `check_scope`, sobre el diff en CI como juez final o sobre
el sandbox—, **manda `docs/03` P1 y el glosario de su Anexo B**. `docs/04` entra
**byte a byte** desde el commit de origen y por eso **no se corrige en su texto**: la
prevalencia se resuelve aquí. Se citan expresamente `docs/04` § «Lo que ninguna
conversación vio», punto 3 —«el juez final es el diff en CI»— y su veredicto **T8**
—«el check de alcance en CI, que atrapa el resultado final»—: ambos describen la
**arquitectura objetivo**, no un control existente.

**`docs/05` recibe dos correcciones editoriales mínimas, y ninguna más.** A
diferencia de `docs/04`, este documento **no entra byte a byte**: se le aplican
*(i)* la **minimización de la ruta personal absoluta** de su tabla de estado
verificado y *(ii)* una **corrección de terminología** en §9, fila «2 — Cierre de
pausa», donde `WP-005` figuraba abreviado con una fórmula que **fundía los estados
2 y 3** y ahora dice «job ejecutándose en CI; bloqueante para la fusión solo tras
incorporarse a `required_status_checks`». **No era una descripción temporal, sino
terminología técnica**, de modo que subordinarla por prevalencia habría conservado
la categoría equivocada: se corrige en origen. Su **contenido
analítico y sus veredictos permanecen intactos**, y **la regla de prevalencia
sigue aplicándose íntegramente** a las demás fotografías temporales de `docs/04` y
`docs/05`.

**Coherencia con los textos vinculantes anteriores.** Hacer vinculante `docs/03`
obliga a alinear en el mismo diff `CLAUDE.md`, `docs/02` y `docs/manual/MANUAL.md`,
que hoy describen el hook como control determinista que hace cumplir el alcance.
Sin esa alineación quedarían dos normas vinculantes en contradicción sobre el
mismo control. Las tres rutas van en la composición y **solo** se tocan en las
frases afectadas por este conflicto y en los enlaces que hacen descubrible el
rumbo.

### D4 — Paquete adoptado, sin anti-backlog

Se adoptan con su fase y gate propios:

- Δ1–Δ9, Δ11 y Δ12;
- de L17, únicamente reglas deny para IaC/datos cuando existan esas rutas;
- L19, lista anti-backlog vinculante;
- la prueba en seco adversarial, fusionada con el simulacro de Etapa 3.

No se añaden: el agente `infra-engineer` de L17, RTK/L21, Ralph loop,
Spec Kit/OpenSpec como capa ni un orquestador propio. Δ10 se registra como ya
cubierto. L18 también se registra como **YA CUBIERTO** en el sentido del
análisis 05 §4.6: no por una norma vigente, sino porque el programa
**CONTRACTS** de la Etapa 4 de la hoja de ruta ya prevé los contratos de datos y
su regla «breaking = DEC + migración». No existe hoy ningún archivo
`CONTRACTS.md`; la regla se conserva como criterio de la Etapa 4, no como
adopción nueva de este punto de control ni como capa duplicada.

### D5 — Sin acuerdo formal por ahora

D5 queda resuelta por su default. El modelo de dos carriles de la hoja de ruta y
del análisis 05 §4.1–4.3 se conserva como propuesta futura, pero esta decisión no
lo activa ni asigna a Leandro un repositorio, un producto, responsabilidades,
accesos o capacidad de fusión. Tampoco fija prioridad comercial entre
`AI-Comercial-System`/Agent OS y Document AI.

El carril A puede continuar cuando la pausa y los WPs que la gobiernan lo
permitan. El carril B requiere una decisión humana posterior, fechada y
versionada, que identifique responsables y repositorio, registre el commit de
plantilla de origen, defina el retorno de mejoras y resuelva accesos y
`CODEOWNERS`. Kimi K3 continúa siendo únicamente un experimento propuesto y no
toca código de cliente sin sus gates de compatibilidad, calidad, coste y datos.

### D6 — Dos ramas cerradas

#### D6-A — núcleo mínimo, resolución recomendada

Una PR de operador posterior y de un solo archivo reduce
[`work-packages/WP-008-runtime-fail-closed.md`](../../work-packages/WP-008-runtime-fail-closed.md) a:

1. parche humano de `settings.json` con comando canónico y ocho reglas;
2. preflight estructural;
3. suite determinista del preflight;
4. criterios y evidencia proporcionales al alcance restante.

La maquinaria roja/verde de captura de CI y su protocolo de doce escenarios se
declaran superados. Antes de modificar o retirar la candidata local, una
operación humana separada crea una custodia externa persistente con manifiesto de
rutas, tipos, modos y SHA-256. La custodia y cada artefacto peligroso se marcan
**CANDIDATA HISTÓRICA NO CONFORME — NO EJECUTAR**, nombrando `WP008-F1`,
`WP008-F2`, `WP008-F4` o `WP008-F5` cuando corresponda. No se fusiona ese código
como entregable ni se reutiliza como guía operativa.

Antes de autorizar esa operación, la persona fija por escrito el destino
persistente —nunca `/private/tmp`—, el soporte y su durabilidad, el modo y la
propiedad del árbol, el formato verificable del manifiesto y el periodo de
retención. Esta decisión exige esos datos; no autoriza copiar, mover ni borrar.

El tratamiento de cada uno de los seis hallazgos bajo esta rama está en
§ **Registro cerrado de hallazgos de WP-008**, columna «Tratamiento bajo D6-A».

**Contabilidad del contrato reducido.** Reducir el contrato no abre un ciclo de
corrección de la implementación retirada. El contrato reducido nace con
`max_ciclos_correccion: 2` y una cuenta propia desde `0 / 2`.

**Quién concede ese presupuesto: esta decisión.** La concesión es un acto propio
de `DEC-007`, y solo surte efecto cuando esta decisión se fusione. La razón de
que no pueda apoyarse en una concesión anterior es aritmética y está verificada
en la foto de §1:

- [`DEC-006`](DEC-006-abandono-y-reinicio-controlado-de-wp-008.md) §3 concedió «al contrato corregido y a la rama
  `wp/WP-008-runtime-fail-closed-r2` un presupuesto nuevo, explícito y máximo de
  dos ciclos de corrección». **Ese presupuesto es exactamente el de R2, y quedó
  agotado en `2 / 2`**: los ciclos 1 y 2 están cerrados;
- por eso `DEC-006` **no es autoridad directa** de un `0 / 2` nuevo. Invocarla
  para reiniciar la cuenta sería usar dos veces la misma concesión;
- la propia `DEC-006` lo cierra en los dos sentidos: §3 exige que «el tercer
  ciclo vuelva a requerir otra decisión humana, **nueva, fechada y versionada**»,
  y su § «Qué no autoriza» n.º 7 dice «no permite un tercer ciclo del contrato
  corregido». **`DEC-007` es esa decisión nueva, fechada y versionada**, y por
  eso puede conceder;
- `DEC-006` §3 y [`DEC-005`](DEC-005-troceado-de-wp-008-y-revision-de-la-pausa.md) §10 —que dotó a WP-012 de presupuesto propio al
  trocear— se citan como **precedentes del mecanismo «contrato nuevo, cuenta
  propia»**, no como la autorización actual.

**Qué no hace esta concesión.** No borra ni renumera los ciclos 1 y 2 de R2 ni
los once ciclos históricos que registra `DEC-005`: siguen contados donde están.
No es una medición: es una decisión de gobierno sobre un contrato nuevo. Y **un
tercer ciclo del contrato reducido volvería a exigir otra decisión humana nueva,
fechada y versionada**, exactamente igual que ahora.

##### Prueba proporcional del parche bajo D6-A

D6-A **conserva** el parche humano de `settings.json` y, con `WP008-F1`
corregido, ese parche debe verificar respaldo, sustitución y restauración. Un
comportamiento exigido sin prueba sería exactamente la clase de afirmación no
acreditada que esta decisión combate, y `CLAUDE.md` obliga a que todo cambio lleve
pruebas. Por eso el núcleo reducido **conserva también una prueba determinista
proporcional de ese comportamiento**.

**Lo que NO se restaura, y sigue declarado superado:** la maquinaria roja/verde de
captura de CI; el protocolo completo de doce escenarios; la batería A completa; y
`test-protocolo.sh` como maquinaria íntegra. Esta sección **no reabre** nada de
eso ni convierte `WP008-F2` en trabajo del núcleo reducido.

**Lo que sí se exige:** una prueba **mínima, aislada y que no toque el FDA real**
—copias externas desechables, fuera de la raíz física del repositorio, como ya
hace el resto del WP—, que cubra **como mínimo** estos seis casos:

1. **respaldo creado y con huella correcta** antes de sustituir;
2. **fallo en la creación del respaldo: no se sustituye** el archivo objetivo;
3. **sustitución realizada y huella final** del objetivo verificada;
4. **rollback correcto**: el par vuelve al estado de origen de la fase;
5. **fallo de restauración**: salida **distinta de cero**, estado declarado
   **como no restaurado** y **`ESCALAR DE INMEDIATO`** emitido;
6. **ausencia de `ROLLBACK APLICADO` antes de acreditar el resultado** de la
   restauración.

**Esta decisión no fija ahora nombre de archivo ni interfaz.** El contrato
reducido posterior los fijará **dentro de su propia allowlist** y manteniendo el
núcleo proporcional: seis casos deterministas, no un protocolo.

**Esto no es un séptimo hallazgo.** La necesidad de esta prueba forma parte del
**tratamiento correcto de `WP008-F1`**; el conjunto `WP008-F1`–`WP008-F6` sigue
siendo cerrado y de seis.

#### D6-B — contrato íntegro, valor predeterminado

Si D6 no se ratifica o la persona elige el contrato íntegro, esta decisión
concede expresamente el **tercer y último ciclo de corrección** de WP-008-r2 para
`WP008-F1`–`WP008-F6`. También aquí la autoridad es `DEC-007`: `DEC-006` §3
agotó su concesión en `2 / 2` y remitió el tercer ciclo a una decisión humana
nueva, fechada y versionada. Términos:

1. al fusionarse `DEC-007`, la contabilidad pasa de `2 / 2` a `2 / 3`;
2. una autorización humana posterior abre la pasada `3 / 3`;
3. corregir y revalidar **el mismo hallazgo** dentro de esa pasada no abre otro
   ciclo; un hallazgo nuevo **ajeno al conjunto `WP008-F1`–`WP008-F6`** exige
   parada. El conjunto es cerrado y está definido íntegramente en este archivo,
   de modo que la distinción se resuelve leyendo solo el repositorio;
4. no existe cuarto ciclo implícito;
5. una PR de operador de un solo archivo actualiza el contrato con el presupuesto
   y los seis hallazgos antes de reanudar la candidata;
6. la allowlist se deriva de `WP008-F1`–`WP008-F6` y de las fuentes vigentes, sin
   heredarla del borrador temporal desaparecido;
7. cualquier cambio de código o pruebas obliga a repetir la batería A completa
   desde el comando 01, regenerar solidariamente los dieciséis logs y las tres
   evidencias nominales y reconstruir el índice conservando su historia;
8. el cierre exige QA, code review y security review en tres tareas realmente
   separadas y sin compartir dictámenes, por la exigencia de revisión
   independiente del contrato y la regla Δ8 de la v2.

La rama D6-B evita que el default deje WP-008 detenido y fuerce una nueva
deliberación. Recupera `WP008-F1`–`WP008-F6`, nunca el objeto, texto,
cardinalidad o allowlist del borrador desaparecido. El tratamiento de cada
hallazgo bajo esta rama está en § **Registro cerrado de hallazgos de WP-008**,
columna «Tratamiento bajo D6-B».

## Registro cerrado de hallazgos de WP-008

**Por qué este registro existe.** Ambas ramas de D6 dependen de poder distinguir
un hallazgo del conjunto de uno nuevo: D6-B exige **parada** ante «un hallazgo
nuevo ajeno al conjunto» y deriva de él la allowlist del tercer ciclo. Esa
distinción tiene que poder hacerse **leyendo únicamente el repositorio**, sin
Nota 49, sin adendas, sin los originales desaparecidos y sin memoria
conversacional. Por eso el conjunto se define aquí, entero, en el archivo que la
PR versiona.

**Nomenclatura.** Los seis defectos se identifican **`WP008-F1`–`WP008-F6`**. Se
abandona la denominación `H1`–`H6` usada en la preparación externa porque colisiona
con los hallazgos de investigación **`H1`–`H12`** de
[`docs/05`](../../docs/05-analisis-investigacion-leandro-y-revalidacion.md) §3, que
son un conjunto distinto, sobre otra materia, y que **no se renombran**. Un lector
que encuentre `H4` en `docs/05` está leyendo la evidencia Veracode; un lector que
encuentre `WP008-F4` está leyendo un defecto de la candidata de WP-008.

**Procedencia y estatus.** Los seis los señalaron QA, code review y security
review durante la preparación externa registrada en la Nota 49. Esa nota **no es
norma ni expediente versionado**, y su soporte es efímero: lo que gobierna es este
registro. El conjunto es **cerrado**: no se amplía sin otra decisión.

**Tres propiedades distintas, que no deben confundirse.**

| Propiedad | Estado |
|---|---|
| **Definición normativa autosuficiente** | **Sí, y vive aquí.** Identificador, ruta, defecto exacto, razón y tratamiento bajo ambas ramas de D6 están en este archivo, que la PR versiona. **La aplicación normativa del conjunto es posible leyendo el repositorio**: identificar un miembro, distinguirlo de un hallazgo nuevo y derivar la allowlist de D6-B no requiere ninguna fuente externa |
| **Reproducción técnica desde `main`** | **No es posible para `WP008-F1`–`WP008-F5`.** Sus cinco artefactos —`evidence/WP-008/parche/aplicar.sh`, `tests/runtime/test-protocolo.sh`, `tests/runtime/fixtures/config/README.md`, `tests/runtime/fixtures/cuarentena/patrones.txt` y `evidence/WP-008/parche/README.md`— **no están versionados en `main`**. Solo `WP008-F6` señala un artefacto que sí lo está |
| **Comprobación técnica** | Se hace **hoy sobre la candidata local** y, **bajo D6-A**, sobre su **futura custodia externa persistente**, todavía no autorizada |

**Esta decisión no afirma que `WP008-F1`–`WP008-F5` puedan reproducirse
técnicamente desde `main`.** Lo que garantiza es lo que las dos ramas de D6
necesitan: que el conjunto se pueda **aplicar** leyendo el repositorio.

### `WP008-F1` — el parche no verifica sus propios pasos

- **Ruta afectada:** `evidence/WP-008/parche/aplicar.sh`.
- **Defecto exacto:** crea el respaldo, sustituye el archivo y restaura mediante
  `cp` **sin comprobar** ninguno de los tres resultados; además puede imprimir
  `ROLLBACK APLICADO` **antes** de acreditar que la restauración ocurrió.
- **Alcance exacto del defecto, sin exagerarlo.** Es el artefacto que **ejecuta
  una persona a mano** sobre `.claude/settings.json`, ruta vedada a los agentes,
  de modo que su fiabilidad importa más que la de ningún otro. Lo que falla y lo
  que no:
  - **la creación del respaldo no se valida antes de sustituir**: no se comprueba
    que el archivo exista ni que su huella coincida con el original;
  - si el respaldo falla y **no** ocurre después ningún otro fallo, el script
    puede **terminar en `0` con el archivo de destino correcto pero sin capacidad
    de recuperación**. Ese es el riesgo real: no un estado erróneo, sino la
    pérdida silenciosa de la vía de vuelta;
  - **si se ejecuta el rollback, el script termina siempre en `3`**, nunca en `0`;
  - **el estado posterior sí se verifica**: se recalcula desde las huellas reales
    de los dos archivos y, si no coincide con el estado de origen de la fase, se
    imprime **`ESCALAR DE INMEDIATO`**;
  - **el literal `ROLLBACK APLICADO` se imprime antes de acreditar el resultado**
    de la restauración. Es **engañoso para quien lea solo esa línea**, y por eso
    debe corregirse, pero **no constituye un éxito global del script**: el código
    de salida y las dos líneas siguientes dicen la verdad.
- **Tratamiento bajo D6-A:** **se corrige**, porque el parche humano de
  `settings.json` **permanece** en el núcleo reducido. El parche que sobreviva
  debe **verificar la creación y la huella del respaldo antes de sustituir**
  —comprobación hoy ausente—, conservar la verificación de la huella resultante
  que ya realiza, acreditar la restauración con su huella final, y **no imprimir
  `ROLLBACK APLICADO` antes de acreditar el resultado**. Ese comportamiento
  corregido exige la **prueba determinista proporcional** de la sección
  «Prueba proporcional del parche bajo D6-A».
- **Tratamiento bajo D6-B:** **se corrige** con la misma exigencia, dentro del
  tercer y último ciclo, y su corrección obliga a repetir la batería A completa.

### `WP008-F2` — falta la postimagen intermedia del escenario 12

- **Ruta afectada:** `tests/runtime/test-protocolo.sh`.
- **Defecto exacto:** falta exactamente **`comprobar_plantillas e12`**. Existen
  **once** postimágenes intermedias contractuales del árbol de plantillas
  versionadas —una por cada escenario del 1 al 11— para **doce** escenarios.
- **Alcance exacto del defecto, sin exagerarlo.** El escenario 12 **sí** captura
  sus propias imágenes, `IMG_12_ANTES` e `IMG_12_DESPUES`, y **es falsable**:
  comprueba el código de salida, el número y la identidad de las rutas
  modificadas —debe cambiar solo `.claude/settings.json`— y la invariancia de
  `H_OTROS` y `H_STAGED`. Y la **postimagen final**, posterior a las limpiezas,
  **sigue acreditando la integridad final** del árbol versionado contra la
  preimagen, por digest agregado y número de entradas.
- **Por qué exige cambio:** el defecto es el **incumplimiento literal de la
  sección 5f del contrato**, que exige una postimagen intermedia **por cada uno
  de los doce escenarios**, y la consiguiente falta de acreditación de **tres
  cosas**: el **instante intermedio** posterior al escenario 12 y anterior a la
  limpieza; la **atribución** de una eventual divergencia al escenario 12 frente
  a la limpieza; y el **número contractual de doce comparaciones**. Lo que **no**
  se pierde es la validez de la medición ni la integridad final.
- **Tratamiento bajo D6-A:** **se archiva con el protocolo retirado.** El
  escenario 12 pertenece al protocolo de doce escenarios de la captura roja/verde,
  que D6-A declara superado; el artefacto sale del contrato y el defecto queda
  **declarado en la custodia histórica**, no corregido. Retirar ese protocolo
  **no** deja sin prueba al parche humano: su cobertura proporcional la fija la
  sección «Prueba proporcional del parche bajo D6-A».
- **Tratamiento bajo D6-B:** **se corrige**, porque el protocolo permanece: se
  añade `comprobar_plantillas e12` antes de la limpieza, completando las doce
  postimágenes intermedias, y entra en la evidencia regenerada.

### `WP008-F3` — el inventario de fixtures de configuración es falso

- **Ruta afectada:** `tests/runtime/fixtures/config/README.md`.
- **Defecto exacto:** declara **doce** fixtures cuando existen **catorce**.
- **Alcance exacto del defecto:** es **exclusivamente documental**. La primera
  frase dice **doce**; la **tabla enumera catorce** filas, una por fixture; y el
  directorio contiene **catorce archivos JSON** cuyos nombres coinciden uno a uno
  con esa tabla. **La tabla permite verificar la completitud**, de modo que un
  alta o una baja sí se detectarían contra ella. **No hay efecto conductual
  alguno**: ningún consumidor lee esa cifra.
- **Por qué exige cambio:** un inventario que se contradice a sí mismo en su
  primera línea no puede fusionarse como documentación de una suite de control.
  La cifra correcta es catorce. *(La mención a las **nueve comprobaciones** de
  `check-config.sh` es correcta y no se toca: hay nueve comprobaciones y
  dieciséis casos repartidos sobre catorce fixtures.)*
- **Tratamiento bajo D6-A:** **se corrige.** El preflight y sus **catorce**
  fixtures permanecen en el núcleo reducido, así que el inventario tiene que
  cuadrar.
- **Tratamiento bajo D6-B:** **se corrige** por la misma razón, dentro del tercer
  ciclo.

### `WP008-F4` — el inventario de patrones de cuarentena es falso

- **Ruta afectada:** `tests/runtime/fixtures/cuarentena/patrones.txt`.
- **Defecto exacto:** declara **cuatro** secciones cuando existen **cinco**.
- **Alcance exacto del defecto:** el **comentario** de cabecera declara cuatro
  secciones etiquetadas y existen **cinco**. La quinta **está documentada en el
  propio archivo**, con su propósito y con la razón de evaluarse solo sobre líneas
  que no contienen el token literal. Y el **consumidor la lee nominalmente**:
  `check-alcance-wp008.sh` extrae las **cinco** por nombre y **exige que las cinco
  estén pobladas**, abortando con exit `2` si alguna quedara vacía. Por tanto **no
  es comportamiento no documentado ni oculto**.
- **Por qué exige cambio:** el **único** defecto es el **numeral falso del
  comentario**. Se corrige porque un archivo de datos de un mecanismo de
  contención no debe declarar un recuento que su propio contenido desmiente.
- **Tratamiento bajo D6-A:** **se corrige si la cuarentena permanece** en el
  alcance restante; si el núcleo reducido no la conserva, el defecto queda
  **declarado en la custodia histórica** y no se corrige.
- **Tratamiento bajo D6-B:** **se corrige**, porque el contrato íntegro conserva
  la cuarentena.

### `WP008-F5` — la guía del parche se contradice a sí misma

- **Ruta afectada:** `evidence/WP-008/parche/README.md`.
- **Defecto exacto:** el inciso final **«nunca S0»** tiene **alcance ambiguo**.
  Leído sobre toda la enumeración —«S0 para la roja, S1 para la verde, nunca
  S0»— se contradice con su propio primer término; leído solo sobre la rama
  verde, es correcto y útil.
- **Alcance exacto del defecto, sin exagerarlo.** El párrafo es **descriptivo, no
  una orden**: explica lo que `aplicar.sh` hace por sí solo y sin intervención,
  de modo que no hay nada que el operador deba cumplir en esa frase. Las
  **instrucciones operativas del mismo documento son inequívocas** —exigen ver el
  par S0 antes de empezar y detenerse si no lo es, y su tabla de transiciones dice
  que `verde` desde S0 y `rojo` desde S2 abortan—. Y el propio `aplicar.sh`
  **rechaza un estado fuera de orden antes de escribir nada**. El riesgo es por
  tanto **posible, no demostrado**.
- **Por qué exige cambio:** **aun así se corrige.** Una guía de una operación
  humana sensible, sobre una ruta vedada a los agentes, no debe contener una
  ambigüedad que bajo una de sus dos lecturas se contradice.
- **Tratamiento bajo D6-A:** **la guía defectuosa no se publica como instrucción
  vigente.** Va a la custodia histórica marcada **CANDIDATA HISTÓRICA NO CONFORME
  — NO EJECUTAR**. Si el núcleo reducido necesita guía de parche, se **redacta de
  nuevo**; no se hereda esta.
- **Tratamiento bajo D6-B:** **se corrige** — se reescribe de modo que S0 y S1
  queden inequívocos — y se revalida dentro de la pasada.

### `WP008-F6` — el contrato afirma una equivalencia que no midió

- **Ruta afectada:** `work-packages/WP-008-runtime-fail-closed.md`.
- **Defecto exacto:** el contrato afirma, **sin cualificar y sin medirla**, que
  «el conjunto resultante es equivalente o más estricto que el actual» y que
  «ninguna ruta hoy denegada puede quedar permitida». El caso crítico es el de
  cero segmentos: `Read(/**/.env*)` frente a `.env` en la **raíz** del proyecto.
  *(El mismo contrato **sí** declara expresamente, unas líneas antes, que la
  resolución real de las reglas por el runtime es una afirmación de comportamiento
  que él no da por probada. El defecto está en la afirmación de relación de
  conjuntos, no en aquella cautela.)*
- **Por qué exige cambio:** una relación de conjuntos presentada como establecida
  sin haberla medido es exactamente la clase de afirmación que la pausa de
  `DEC-003` existe para impedir. Y el caso crítico no es marginal: es el que
  decide si el reanclaje **conserva o reduce** el alcance real de las ocho
  reglas, porque si `/**/` no cubriera el caso de cero segmentos, una ruta hoy
  denegada quedaría permitida y la frase sería falsa.

**Tratamiento: las cuatro combinaciones de D1 y D6, escritas por separado.** D1 y
D6 se resuelven de forma independiente, así que las cuatro celdas existen y
ninguna puede quedar sin tratamiento:

| Celda | Tratamiento |
|---|---|
| **D6-A + D1 ratificada** | Se **retira del contrato la afirmación semántica no medida**. El caso `.env` de raíz se verifica mediante el **humo seguro de WP-008**, dentro de su alcance, **antes de cerrarlo**, con evidencia saneada en `evidence/WP-008/`. Si el humo falla, WP-008 no se cierra |
| **D6-A + D1-default** | Se **retira igualmente la afirmación**. **No se ejecuta el humo**: bajo el default de D1 esa prueba no está en vigor. `DEC-007` **exige** que el **futuro contrato de `WP-012`** incorpore **nominalmente** este caso como subcomprobación **antes de aprobarse** |
| **D6-B + D1 ratificada** | Se **retira la afirmación**. El caso queda cubierto por el **humo seguro dentro de WP-008**, antes de su cierre |
| **D6-B + D1-default** | Se **retira la afirmación**. El **futuro contrato de `WP-012`** debe incorporar **nominalmente** este caso |

**Qué no se afirma aquí, y por qué.** Ni `DEC-005` ni `DEC-006` asignan hoy este
caso a `WP-012`: `DEC-005` fija **catorce sondas** y la composición
**14 · 13 · 1 · 0** sin nombrar `.env` ni el caso de cero segmentos, `DEC-006` no
lo menciona, y **no existe todavía contrato versionado de `WP-012`**. Por eso la
exigencia se dirige al **contrato futuro**, no a una asignación que ninguna norma
vigente contiene.

**Cómo debe incorporarlo ese contrato futuro.** Si el caso se integra **como
subcomprobación de las catorce sondas** y no como sonda nueva, el contrato debe
**decir expresamente en cuál se integra** y **preservar de forma justificada la
contabilidad `14 · 13 · 1 · 0`**, explicando por qué el reparto no cambia. Esta
decisión **no inventa ahora la sonda concreta** ni altera esa composición.

En las cuatro celdas, el contrato de WP-008 se limita a **no afirmar** lo que no
ha medido.

**Dónde vive cada cosa, sin exagerar la propagación.** Las **cuatro celdas están
íntegramente aquí** y en ningún otro archivo. `DEC-003` §2.b y
`docs/manual/05-bloqueos-y-parada.md` recogen las **consecuencias operativas** de
las dos ramas de D1 —retirada de la afirmación, humo si D1 se ratifica, exigencia
al futuro contrato de `WP-012` si queda en su default—, no la matriz completa.
`docs/03` **resume y remite** a esta sección y **no reproduce** la matriz. Ninguna
ruta debe afirmar que las cuatro celdas se reproducen en cuatro archivos.

### Regla de cierre del conjunto

Un defecto que no figure en este registro es un **hallazgo nuevo**. Bajo D6-B
obliga a **parada** y no puede tratarse dentro del tercer ciclo. Bajo D6-A obliga
a evaluar si el núcleo reducido sigue siendo el alcance correcto antes de
continuar. Ampliar el conjunto exige una decisión posterior, nueva, fechada y
versionada.

## Secuencia de ejecución posterior al punto de control

La PR de esta decisión **no modifica `ACTIVE`**. Después de fusionarla, cada paso
sigue siendo un acto humano separado. La tabla normativa vive en `DEC-003` §2;
aquí se enumera con el **tipo** de cada paso, porque confundirlos es lo que
produjo la secuencia inejecutable que esta versión corrige.

**Los cuatro tipos, y por qué no se mezclan:**

| Marca | Tipo | Qué es | Efecto sobre `ACTIVE` |
|---|---|---|---|
| **T** | **Transición de `ACTIVE`** | El operador escribe reposo o un `WP-NNN` existente en `work-packages/ACTIVE` | **Cambia `ACTIVE`.** Es el **único** tipo que lo hace |
| **O** | **Acto de operador** | PR de operador, parche humano sobre ruta vedada, custodia externa | Ninguno. `ACTIVE` se mantiene donde esté |
| **W** | **Trabajo de un WP** | Implementación, verificación, revisión y fusión bajo un contrato activo | Ninguno. Ocurre **entre** dos transiciones |
| **F** | **Hito futuro no autorizado** | Actividad prevista por la hoja de ruta sin identificador ni contrato aprobado | Ninguno. **`ACTIVE` permanece en reposo** y su ejecución no está autorizada |

**Los dos tipos compuestos, definidos antes de usarse:**

| Marca | Tipo | Qué es | Efecto sobre `ACTIVE` |
|---|---|---|---|
| **W/O** | **Trabajo de un WP con parche humano dentro** | Trabajo bajo un contrato activo que incluye un **parche sobre ruta protegida preparado por el agente y aplicado por una persona**, dentro de la rama y la PR de ese mismo WP | **Ninguno.** `ACTIVE` se mantiene en el WP durante todo el paso |
| **O/T** | **Acto de operador con transición solidaria** | **PR de operador sin implementación** que **registra un acto externo** —una mutación de la plataforma— y **ejecuta una transición de `ACTIVE`** en el **mismo diff atómico** | **Cambia `ACTIVE`**, y solo junto con el registro y el cambio de estado contractual que van en ese mismo diff |

**Por qué `O/T` no contradice la regla de que `T` es el único tipo que cambia
`ACTIVE`.** `O/T` **contiene** una transición: no es un acto `O` que además mueva
`ACTIVE` por su cuenta, sino un diff único en el que la transición y el registro
son **inseparables**. Un acto tipado **solo** como `O` **nunca** cambia `ACTIVE`.

**`O/T` se usa exactamente una vez** en toda la secuencia: en el **paso 19**. Su
condición de uso es estricta: el registro y la transición deben ser inseparables
**dentro de un mismo diff**. Una resolución que necesite **dos transiciones
separadas con trabajo en medio** **no es `O/T`** y **no puede tiparse así**: se
escribe como la secuencia de actos que realmente es (paso 21-B). Y un acto que
**no mueve `ACTIVE`** tampoco es `O/T`: es `O` (paso 21-A).

**Secuencia bajo D1 y D6 ratificadas:**

1. **O** — custodiar la candidata local no conforme en una custodia externa
   persistente, **antes** de cualquier limpieza, reutilización o modificación.
   `ACTIVE` no se toca;
2. **T** — `WP-008` → **reposo**. Suspensión autorizada por este cambio de rumbo,
   **no** cierre ni abandono;
3. **O** — redactar, validar y aprobar el contrato breve de `WP-009`;
4. **T** — reposo → `WP-009`;
5. **W** — implementar, verificar, revisar y fusionar `WP-009`;
6. **T** — `WP-009` → **reposo**;
7. **O** — PR de operador de **un solo archivo** con el contrato de `WP-008`
   según la rama de D6 resuelta. Ese contrato incorpora en su alcance el humo
   seguro de D1 y retira la equivalencia semántica no medida de `WP008-F6`;
8. **T** — reposo → `WP-008`;
9. **W** — implementar `WP-008` y **ejecutar el humo seguro antes de
   cerrarlo**, con su salida en `evidence/WP-008/`. **Si el humo falla, WP-008 no
   se cierra**: se aplica el presupuesto de ciclos vigente de su contrato. Cerrar
   y fusionar solo con el humo en verde;
10. **T** — `WP-008` → **reposo**;
11. **O** — PR de operador que **corrige el contrato de `WP-002`** para sacarlo de
    `blocked`, lo valida y lo aprueba. Sin este paso `WP-002` no puede activarse;
12. **T** — reposo → `WP-002`. Librería única de matching y `check_scope`;
13. **W** — implementar, revisar y fusionar `WP-002`;
14. **T** — `WP-002` → **reposo**;
15. **O** — PR de operador que **corrige integralmente** el contrato de `WP-005` y
    lo deja `ready`. **No basta con cambiar el estado**: debe resolver antes las
    cuatro precondiciones de `DEC-003` §2.d —parche humano de `ci.yml` por ruta
    protegida; `evidence/WP-005/**` en su allowlist; política elegida para las
    ramas `ops/*`; y ruleset expresamente fuera del alcance del WP—. **Sin esta
    corrección el paso 16 no puede iniciarse**;
16. **T** — reposo → `WP-005`;
17. **W/O** — el agente prepara un **parche verificable** de
    `.github/workflows/ci.yml` y **una persona lo aplica** dentro de la rama y la
    PR de `WP-005`, **con `ACTIVE` en `WP-005`** y **sin relajar
    `permissions.deny`**. El job queda **ejecutándose en CI como check todavía NO
    requerido**: se capturan el caso rojo, el verde, las validaciones y las
    revisiones. **Se fusiona la PR de implementación**, y `WP-005` **no se marca
    `done`** ni `ACTIVE` vuelve a reposo;
18. **O** — con el job **ya reportando desde `main`**, **una persona modifica la
    regla `required_status_checks` existente** para añadir `check_scope` como
    **cuarta comprobación requerida**. **Es mutación humana de GitHub, no código de
    ningún WP.** Este paso **no incluye la PR de cierre** y **no cambia ningún
    estado versionado**: `ACTIVE` **continúa en `WP-005`** y el WP **todavía no
    está `done`**;
19. **O/T** — **PR de operador de cierre**, sin implementación, que en un **único
    diff atómico**: *(a)* **registra la evidencia del ruleset** conforme al
    contrato de § *Evidencia de la mutación del ruleset*; *(b)* **acredita que la
    política elegida para las ramas `ops/*` permite fusionar esa propia PR**;
    *(c)* **marca `WP-005` `done`**; y *(d)* **escribe reposo en `ACTIVE`**.
    **Antes de fusionarla**, `WP-005` sigue **abierto y activo**, con alcance
    declarado; **después**, quedan **solidariamente** `WP-005` `done` y `ACTIVE`
    en reposo. **Los apartados (c) y (d) no pueden viajar en diffs distintos**: un
    diff intermedio dejaría versionado un `ACTIVE` apuntando a un WP ya cerrado, y
    `tests/governance/check-active.sh` **no lo detectaría** —solo valida que el WP
    exista y declare alcance, no su estado—. **Esta es la única transición
    `WP-005` → reposo de toda la secuencia.** Solo desde aquí puede decirse que
    `check_scope` **bloquea la fusión**. **Esta PR registra y referencia hechos ya
    producidos, y no se usa como prueba de sí misma:** la **evidencia de la
    política `ops/*`** procede de las **ejecuciones roja y verde anteriores**,
    capturadas durante `WP-005` con el job todavía **no requerido**; la
    **evidencia del cambio del ruleset** procede del **acto humano del paso 18**;
    y **su propia fusión no acredita que ella misma fuese fusionable**. Lo que
    debe cumplirse antes de fusionarla es una **condición externa que conserva
    GitHub**: el **check requerido de su `HEAD` final reporta terminalmente
    conforme**. **No se exige que este diff contenga el `HEAD SHA`, el
    identificador de ejecución ni la conclusión del check sobre su propio `HEAD`
    final**, que cambiarían al añadirlos. **Esto no crea otro paso ni otra
    transición de `ACTIVE`**;
20. **O** — **parche humano del guard delgado** sobre la librería única. Es carril
    T3 y toca `.claude/hooks/**`, ruta vedada a los agentes: lo aplica una
    persona. **La librería y `check_scope` preceden a este parche**, nunca al
    revés;
21. **Resolución de `WP-007`: dos ramas excluyentes.** `WP-007` está congelado
    por `DEC-003` §1 y su resolución es un **acto humano separado y expresamente
    registrado**. Se resuelve por **una** de estas dos vías, y **cuál de las dos
    se elige debe constar por escrito antes de ejecutarla**:

    **Precondición común a las dos ramas, antes de levantar la congelación.**
    Ninguna de las dos vías puede iniciarse hasta que se hayan cumplido, en este
    orden y en **solo lectura** hasta el punto 5:

    1. **recalcular las siete magnitudes** de la huella de congelación de
       `DEC-003` §1, **sin escribir nada**;
    2. **compararlas exactamente** con la huella registrada;
    3. si **cualquiera difiere**, **parada y análisis**, **sin actualizar la
       huella**: la congelación se ha roto y eso es un hallazgo, no un trámite;
    4. **comprobar además cardinalidad, tipos y modos** de los archivos sin
       versionar, que la huella histórica **expresamente no cubre**;
    5. **crear una custodia externa persistente de la candidata completa** —rama
       y `HEAD`, estado Git en formato `NUL`, diff binario, rutas rastreadas y no
       rastreadas, tipos, modos, tamaños, **`SHA-256` por archivo** y **digest
       agregado**— **antes** de modificarla, limpiarla o descartarla, con
       **propietario**, **política de acceso**, **soporte y durabilidad**,
       **ubicación lógica —nunca `/private/tmp`—**, **retención**,
       **procedimiento de recuperación** y **auditabilidad**;
    6. **marcar la custodia** como
       **`CANDIDATA HISTÓRICA NO CONFORME — NO EJECUTAR`**;
    7. **el descarte no puede destruir la única fuente**: una decisión de
       descarte solo puede recaer sobre el **worktree original** y **solo
       después** de que la custodia esté acreditada.

    **Sin estos siete puntos, la congelación no se levanta y ninguna de las dos
    ramas empieza.**

    - **21-A · Superación — `O`.** Una **PR de operador** registra la decisión
      humana de **superar** `WP-007`, **levanta la congelación** de `DEC-003` §1
      y **determina expresamente su estado final**. Con **`ACTIVE` en reposo**,
      esa PR:
      1. escribe **`estado: done`** en
         `work-packages/WP-007-semantica-de-traversal.md`;
      2. añade un bloque inequívoco **«Cerrado por superación»**;
      3. **identifica la decisión versionada** que autoriza la superación;
      4. declara que **sus criterios de aceptación originales no fueron
         ejecutados**;
      5. declara que el contrato **queda retirado de la cola ejecutable**;
      6. **prohíbe su reactivación** sin otra **decisión humana nueva, fechada y
         versionada**;
      7. **remite a la custodia ya acreditada** por la precondición común y
         declara que **la candidata se conserva en ella**. La decisión escrita de
         **descartar el worktree original** solo cabe **después** de esa
         custodia; **nunca antes**, y **nunca sobre la única fuente**.

      **No hay transición y el WP no se ejecuta**: `ACTIVE` permanece en reposo
      de principio a fin. **No se crea ningún estado nuevo**: el vocabulario
      admitido de `work-packages/_TEMPLATE.md` sigue siendo
      `draft | ready | in_progress | in_review | done | blocked`, y la **causa**
      del cierre la distingue el **bloque textual**, no un valor inventado. La
      secuencia continúa en el paso 22.
    - **21-B · Ejecución — cuatro actos separados, no un tipo compuesto.** Se
      escribe entera porque **`T` + `W` + `T` no cabe en un diff único** y **no
      es `O/T`**:
      1. **O** — **PR de operador que corrige integralmente el contrato de
         `WP-007`**. **No basta con descongelarlo**: el contrato vigente **no es
         ejecutable en el orden nuevo**. Esa PR debe *(a)* **corregir
         íntegramente** `work-packages/WP-007-semantica-de-traversal.md`;
         *(b)* **levantar expresamente** su congelación de `DEC-003` §1;
         *(c)* dejarlo literalmente en **`estado: ready`**, conforme a
         `docs/manual/02-ciclo-de-un-wp.md`, que reserva a la firma humana el
         paso a `ready` y exige que se implemente dentro del alcance de un WP
         `ready`;
         *(d)* **retirar o sustituir su PR 4 histórica —la «PR-4» de `DEC-002`—**, que hoy ordena marcar
         `WP-007` `done`, `WP-002` `ready` y **`ACTIVE` ← `WP-002`** —transición
         **obsoleta**, porque `WP-002` habrá quedado `done` en el paso 14 y esa
         orden reescribiría hacia atrás su estado contractual—; *(e)* **adaptar
         su orden de trabajo** a la realidad posterior a `WP-002` y `WP-005`
         —**primero** la librería única y `check_scope`, **después** el guard
         delgado—, sustituyendo la premisa contraria del contrato original;
         *(f)* **preservar** la revisión humana que su contrato exige, la
         **reconciliación de corpus** de `DEC-003` §7 y el **tratamiento de la
         candidata local**; *(g)* **actualizar** condiciones de parada, criterios
         de aceptación y referencias afectadas; *(h)* **no reactivar `WP-002` ni
         `WP-005`**, que permanecen `done`; e *(i)* **no activar `WP-007`** hasta
         que el contrato corregido esté **aprobado**. **Esta PR previa debe estar
         fusionada en `main` antes de activar `WP-007`**: un contrato que aún no
         gobierna no puede regir el trabajo del acto 3. **Sin esta corrección
         aprobada y fusionada, el acto 2 no puede iniciarse**;
      2. **T** — reposo → `WP-007`;
      3. **W** — ejecución, verificación, revisión y **fusión de la PR de
         implementación gobernada por el contrato ya corregido**. **No es una
         segunda fusión del contrato**, que ya se fusionó en el acto 1;
      4. **T** — `WP-007` → **reposo**, mediante una **PR final de operador** que
         en un **único diff atómico** *(a)* **marca `WP-007` `done`**, *(b)*
         **escribe reposo en `ACTIVE`** y *(c)* **registra el resultado de la
         ejecución**. Sigue tipada **`T`**, pero **los tres apartados no pueden
         viajar en diffs distintos**: un diff intermedio dejaría versionada una
         preimagen con `ACTIVE` apuntando a un WP **ya cerrado**, y
         `tests/governance/check-active.sh` **no lo detectaría**, porque solo
         valida que el WP exista y declare alcance, **no su estado**. **Esta es
         la única transición `WP-007` → reposo de la rama.**

      **Cuatro cosas distintas, que esta rama no debe confundir:** *(1)* la
      **preimagen original custodiada** por la precondición común, que **no se
      modifica nunca**; *(2)* la **candidata usada como punto de partida** del
      trabajo, que sí se modifica; *(3)* la **reconciliación** con el corpus
      procedente de `DEC-003` §7, que es un acto explícito y no una resolución
      automática de conflicto; y *(4)* el **resultado finalmente versionado** por
      la PR de implementación. **Solo (1) acredita qué había antes**, y por eso
      su custodia es precondición y no consecuencia.

    **Ninguna de las dos ramas se tipa `O/T`**: la superación **no cambia
    `ACTIVE`** y la ejecución **lo cambia dos veces**, en actos separados y con
    trabajo en medio. **Ninguna de las dos reactiva `WP-002` ni `WP-005`.** La
    rama elegida determina también el alcance de la única excepción de
    `DEC-003` §7 sobre `tests/guard/run-suite.sh`;
22. **F** — **experimento E2 del sandbox** y, solo si supera su gate, su adopción
    mediante un WP de nivel T3. **Ninguno de los dos tiene identificador
    reservado y esta decisión no se lo asigna.** Antes de ejecutarlos hace falta
    una decisión o enmienda posterior que fije el identificador exacto, apruebe el
    contrato y lo admita en la lista cerrada de `DEC-003` §4. Hasta entonces
    `ACTIVE` permanece en **reposo**;
23. **O** — **cerrar la pausa** mediante PR de operador, con `ACTIVE` en
    **reposo**, cuando el criterio de salida y el ruleset estén efectivamente
    conformes. El cierre de la pausa **nunca es un valor de `ACTIVE`**.

**Si D1 queda resuelta por su default**, los pasos 7 a 10 mantienen `WP-008` sin
el humo seguro, y entre los pasos 10 y 11 se intercala la secuencia de
`WP-012` que fijan `DEC-005` y `DEC-006` —contrato aprobado, `ACTIVE` ← `WP-012`,
implementación, autorización humana separada de la ejecución empírica, fusión y
vuelta a reposo—. `DEC-003` §2 escribe esa variante por separado y de forma
explícita, para que no haya que deducirla.

**Invariantes de `ACTIVE`, vinculantes en toda la secuencia.** `ACTIVE` solo puede
estar **en reposo** o **apuntando a un único identificador existente con forma
`WP-NNN`**. Nunca contiene texto descriptivo, actividades, identificadores
provisionales ni combinaciones de dos WPs. Nunca hay dos WPs activos. Entre WPs,
reposo. Cada transición es un acto del operador, documentado y **no combinable con
implementación**.

La suspensión de WP-008 no es abandono, cierre ni autorización para borrar su
worktree.

## Política de `ops/*`: contrato medible, sin elegir todavía

Cuando `check_scope` sea un check requerido, **toda PR debe producir ese check**,
identificado por el **par `{context, integration_id}`** y no por su nombre a
secas. Las ramas `ops/*` son las que legítimamente tocan `work-packages/` y
el job las haría fallar hoy. Esta decisión **no elige la política**: la elige la
PR de operador que corrija `WP-005` (`DEC-003` §2.d, punto 3). Lo que sí fija es
el **contrato que cualquier política admisible debe cumplir**, y es verificable:

1. **Ejecución incondicional del job requerido.** **Toda PR `ops/*` ejecuta
   siempre** el job que emite el **check exacto** incorporado a
   `required_status_checks`. **No se admite ningún mecanismo que impida su
   creación o su ejecución**: ni filtros de workflow, ni condiciones de job, ni
   ninguna construcción equivalente. Y, **expresamente**, porque es la vía menos
   evidente:

   - un job con **`needs:`** **puede saltarse** si una dependencia **falla o se
     salta**, y **un job saltado se presenta como satisfactorio**;
   - por eso el job que produce el contexto requerido **no depende de otro job**,
     **o** usa **`if: ${{ always() }}`** —o mecanismo equivalente— **y evalúa por
     sí mismo todos los resultados requeridos**;
   - la **ausencia, el fallo o el salto de una dependencia produce `failure`**,
     nunca omisión;
   - el **verificador usa `continue-on-error: false`**;
   - **ningún step posterior puede convertir su fallo en `success`**;
   - existe **un único gate terminal** que **agrega el resultado completo** y
     **falla cerrado**;
   - **un job saltado no cumple este contrato aunque GitHub lo presente como
     satisfactorio**.
2. **Conclusiones, clasificadas de forma cerrada.** Tres categorías y ninguna
   más:

   - **única conclusión conforme:** **`success` tras verificación completa** de
     una autorización **vigente y aplicable al `HEAD` actual**;
   - **conclusión funcional negativa esperada:** **`failure`**, cuando la
     autorización **falta**, está **caducada**, **corresponde a otro `HEAD`**,
     **no puede verificarse** o **se produce un error** de verificación;
   - **cualquier otro estado o conclusión** —incluidos `queued`, `requested`,
     `in_progress`, `waiting`, `action_required`, `cancelled`, `neutral`,
     `skipped`, `stale`, `timed_out`, `startup_failure`, **ausente** y
     **pendiente**— **impide cerrar `WP-005`**.

   La conformidad de la plataforma y la de este contrato **no coinciden**:
   GitHub acepta como satisfactorias para fusionar conclusiones que este contrato
   **no acepta**, y manda este contrato. **No se exige, en cambio, transformar
   artificialmente en `failure` los fallos de infraestructura que nadie
   controla**: basta con que sean **no conformes** y **bloqueen el cierre**.
3. **Condiciones de step, acotadas.** Una condición a nivel de **step** solo es
   admisible si **no evita ejecutar el verificador** ni **impide emitir la
   conclusión terminal** del check requerido. Cualquier condición que pueda
   saltarse la verificación **está prohibida**, y el **gate terminal único** del
   apartado 1 debe **agregar todos los resultados**, de modo que **ningún step
   con `if:` pueda dejar el job en `success` con el verificador fallado o no
   ejecutado**.
4. **Reconocimiento acreditado del operador.** **El prefijo `ops/*` no basta**: la
   política debe acreditar, por un **mecanismo verificable**, que la PR es
   realmente de operador. Un nombre de rama es texto elegido por quien la crea.
5. **Fail-closed para `wp/*`.** Las ramas `wp/*` **conservan íntegro** el
   comportamiento fail-closed del control de alcance.
6. **Prueba roja y prueba verde, falsables.** La política se acredita con **dos
   ejecuciones reales**, definidas de forma que puedan fallar:

   - **Caso rojo.** PR en rama `ops/*` con autorización **inexistente, inválida,
     caducada o asociada a otro `HEAD`**. **El job se crea y se ejecuta**, y el
     **check exacto termina en `failure`**. **Nunca `skipped`, `neutral`, ausente
     ni pendiente.**
   - **Caso verde.** PR en rama `ops/*` con autorización **vigente para su `HEAD`
     actual**. **El job se crea y se ejecuta**, **verifica la fuente de confianza
     definida por el futuro contrato**, y el **check exacto termina en
     `success`**. **Nunca `skipped`, `neutral`, ausente ni pendiente.**

   Cada una registra, **como mínimo**: la **PR**; el **`HEAD SHA` exacto** sobre
   el que se evaluó; el **par `{context, integration_id}`**; el **identificador
   real de la ejecución** —`run_id`, `check_run_id` o el equivalente que exponga
   el endpoint utilizado—; la **conclusión final**; el **instante UTC**; y la
   **fuente de confianza evaluada** con la **prueba de que era vigente para ese
   `HEAD`** (apartado 10). Una captura de pantalla o una nota en prosa **no
   cumplen este apartado**. La evidencia **no publica secretos ni datos
   personales innecesarios**, y **no se inventan aquí valores vivos**: los captura
   quien ejecuta las pruebas.
7. **Fallo cerrado.** Un error, un dato ausente o la imposibilidad de verificar
   producen **fallo**, nunca omisión ni éxito por defecto.
8. **Prohibidos los filtros que suprimen el contexto.** Además del apartado 1, se
   recuerda expresamente por qué: un filtro de workflow —`branches-ignore`,
   `paths-ignore` o equivalente— que **evite por completo la emisión del check
   requerido** dejaría la PR **pendiente para siempre**, y el ruleset **no
   registra actores de excepción** que pudieran desbloquearla.
9. **Identidad del productor, no solo el nombre.** El check requerido se
   identifica por el **par `{context, integration_id}`** —o la representación
   equivalente que exponga el **endpoint autoritativo del ruleset**—, donde
   `context` es el **nombre exacto, carácter a carácter**, e `integration_id`
   identifica al **productor esperado**. **Un contexto homónimo publicado por
   otro productor no satisface el requisito**: sin productor fijado, el nombre es
   una cadena que puede publicar cualquier workflow o aplicación con permiso para
   escribir estados, y este ruleset **no registra actores de excepción** que
   permitan corregirlo después. `integration_id` es el campo de la **API de
   rulesets** y **no debe confundirse con el `app_id`** de los endpoints clásicos
   de protección de rama. Una configuración **«cualquier productor»**
   —`integration_id` sin fijar— **no es el valor por defecto admisible**: solo
   cabe por **decisión humana explícita** que declare sus **controles
   compensatorios**.
10. **Vigencia de la autorización.** Cualquiera que sea la fuente de confianza
    —aprobación, revisión, etiqueta, pertenencia u otro acto equivalente—, la
    política debe: *(a)* **vincularla al `HEAD SHA` exacto y vigente** de la PR;
    *(b)* **invalidarla** en cuanto cambie el **diff**, el **SHA** o la **propia
    fuente de confianza**; *(c)* **provocar una nueva evaluación** ante **todos
    los eventos relevantes para el mecanismo elegido**; y *(d)* **fallar cerrado**
    si su vigencia **no puede demostrarse**. GitHub ya exige que un check
    requerido corresponda al **último commit**; lo que este apartado cierra es
    distinto y complementario: que la **lógica interna de reconocimiento del
    operador**, **al reejecutarse sobre ese nuevo commit**, **no acepte una
    aprobación, etiqueta o autorización obsoleta**. **Esta decisión no congela una
    lista universal de eventos de GitHub**, porque la política todavía no está
    elegida: **exige** que el **futuro contrato de `WP-005`** *(i)* **enumere
    nominalmente** los eventos necesarios para **su** fuente de confianza
    concreta, *(ii)* fije los **activadores y los permisos exactos** del workflow,
    y *(iii)* **pruebe** que **ningún cambio relevante conserva indebidamente un
    verde anterior**.

**Esta decisión no elige ahora la fuente concreta de autorización humana.** Fija
qué debe cumplir cualquiera que se elija.

**Activadores y permisos, sea cual sea la política elegida.** El futuro contrato
de `WP-005` fija los **activadores exactos** del workflow y sus **permisos
mínimos**, y **acredita** que con ellos el check requerido se **crea y se
ejecuta** en **toda** PR `ops/*` y se **reevalúa** conforme al apartado 10. Ningún
apartado de este contrato se satisface con la **mera intención**.

**Si se elige la aprobación humana verificable**, el contrato debe fijar además:
la **fuente de confianza**; la **consulta exacta** que la comprueba; los
**permisos mínimos** que exige, incluido `pull-requests: read` si procede; la
**identidad estable** de la revisión o aprobación en que se apoya **y su
vinculación al `HEAD SHA` vigente**, conforme al apartado 10; el **tratamiento
fail-closed** de errores, indisponibilidad y respuestas ambiguas; y la
**ausencia de secretos**, conforme a `SEC-001` y al entorno autorizado del
propio WP.

**Antes de activar `WP-005`, la política debe estar definida en un contrato
aprobado y verificable.** Su implementación y las pruebas roja y verde se
producen durante `WP-005`; hasta que estén en verde no se incorpora el check al
ruleset ni se cierra el WP. Esta separación evita una precondición circular.

## Evidencia de la mutación del ruleset

La mutación del ruleset es **el único acto de toda la secuencia que cambia el
control técnico del repositorio** y no deja rastro en el árbol por sí misma. Su
registro, exigido en el **paso 19**, debe ser **reproducible, comparable y
verificable por un tercero**, con el mismo rigor que esta decisión ya exige a la
custodia externa de la candidata local.

**Esta sección es la fuente normativa detallada.** `DEC-003` §2.d y
`docs/manual/05-bloqueos-y-parada.md` **resumen el resultado y remiten aquí
nominalmente**; no reproducen esta tabla.

### Esquema del registro

**Grupo A · Identidad de la captura**

| # | Campo | Contenido |
|---|---|---|
| 1 | Repositorio y rama objetivo | Identificación del repositorio y de la rama protegida |
| 2 | `ruleset_id` | Identificador estable del ruleset, no solo su nombre |
| 3 | Endpoint autoritativo y API | **Endpoint exacto** del que se obtiene el estado y **versión de la API** empleada |
| 4 | Instantes UTC | Momento **UTC** de cada captura: preimagen, mutación, postimagen, entrada de historia y, si lo hubiera, rollback |

**Credencial: qué fija el futuro contrato de `WP-005`.** El **actor que consulta
es el operador humano**, nunca un agente. El contrato fija el **endpoint y la
versión de API**, el **tipo de credencial** y su **permiso mínimo documentado**:
**hoy el endpoint de versión concreta exige permiso de repositorio
`Administration: write`**. Queda **prohibido entregar la credencial al agente y
prohibido versionarla**; se **almacena de forma segura y fuera de la custodia de
evidencias**, para que quien pueda leer la evidencia no obtenga por ello la
capacidad de mutar. **Si el permiso o el endpoint no están disponibles, se para
antes de mutar.** Cuando corresponda, la credencial se **revoca o se trata**
según la política que ese contrato fije. **Esta decisión no inventa tokens,
identificadores ni valores vivos.**

**Grupo B · Versiones y direccionamiento**

| # | Campo | Contenido |
|---|---|---|
| 5 | `version_id` anterior | Versión **inmediatamente anterior** a la mutación |
| 6 | `version_id` posterior | Versión **inmediatamente posterior** a la mutación |
| 7 | `updated_at` | El de ambas versiones |
| 8 | Captura de la respuesta de historia | **Respuesta de historia que contiene la mutación, capturada después de mutar junto con la referencia que la direcciona. Su captura es obligatoria para cerrar `WP-005`; no es una precondición temporalmente imposible de la propia mutación.** |

**Tres endpoints distintos, que no se confunden.** El futuro contrato debe
nombrarlos uno a uno en el campo 3:

| Endpoint | Qué devuelve | Para qué sirve aquí |
|---|---|---|
| `GET …/rulesets/{ruleset_id}` | **Estado actual** del ruleset | Preimagen y postimagen **actuales** |
| `GET …/rulesets/{ruleset_id}/history` | **Listado**: `version_id`, **actor** y `updated_at` | **Localizar** la versión anterior y la nueva |
| `GET …/rulesets/{ruleset_id}/history/{version_id}` | Una **versión concreta**, con **`state` completo** | Obtener el **estado completo** de esa versión |

**El listado NO devuelve `state` completo.** Atribuírselo sería falso: el estado
completo lo devuelve **únicamente** el endpoint de versión concreta. El grupo B
se apoya en el listado para **localizar**, y en el endpoint de versión para
**obtener**.

**Horizonte de visibilidad, sin convertirlo en garantía.** GitHub **documenta una
ventana visible de historia de 180 días en la interfaz de gestión**. **De ahí no
se infiere** que esa cifra sea una **garantía contractual de retención del
endpoint REST**, y esta decisión **no se la atribuye**. La consecuencia no cambia:
**la custodia externa del grupo J sigue siendo obligatoria**.

Sentado eso, **qué acredita y qué no debe separarse con precisión**:

- **Hecho acreditable:** una respuesta de historia **puede ser direccionable
  mediante `version_id`** —o identificador equivalente— **en el momento de la
  captura**.
- **Hecho NO acreditado:** **GitHub no promete aquí retención indefinida ni
  disponibilidad futura** de esa entrada. **Esta decisión no afirma que sea
  inmutable** ni que su conservación esté garantizada.
- **Consecuencia:** **el identificador remoto es direccionamiento, no custodia.**
  Por sí solo **no acredita nada a largo plazo**: si la entrada dejara de estar
  disponible, una referencia sin respaldo resolvería a nada. Por eso el campo 8
  exige **capturar la respuesta**, no solo apuntar a ella, y el **grupo J** exige
  **custodia externa persistente** de las representaciones completas.

**Grupo C · Estado completo**

| # | Campo | Contenido |
|---|---|---|
| 9 | **Preimagen** | **Estado semántico completo** del ruleset antes de la mutación |
| 10 | **Postimagen** | **Estado semántico completo** del ruleset después de la mutación |

Ambas deben contener, **sin omitir ninguno**: **nombre e identificador**;
**origen y tipo de origen**; **destino**; **`enforcement`**; **condiciones**;
**`bypass_actors`**; **lista completa de reglas**; **todos los parámetros de cada
regla** —incluida la política estricta o exigencia de rama al día de
`required_status_checks`—; y los **checks requeridos como pares
`{context, integration_id}`**.

**Grupo D · Proyecciones declaradas**

| # | Campo | Contenido |
|---|---|---|
| 11 | Checks requeridos **antes** | **Lista ordenada** y completa de **pares `{context, integration_id}`** |
| 12 | Checks requeridos **después** | **Lista ordenada** y completa de **pares `{context, integration_id}`** |
| 13 | Par añadido | El **`{context, integration_id}`** esperado, con `context` **carácter a carácter** |
| 14 | *Bypass actors* | **Ausencia declarada o inventario completo**, antes y después |

**Los campos 11 a 14 son proyecciones de los campos 9 y 10 y no los sustituyen.**
Un registro que traiga solo listas resumidas **no cumple esta sección**: no puede
probar la invariancia de lo que no captura.

**Grupo E · Delta admisible**

| # | Campo | Contenido |
|---|---|---|
| 15 | Proyección semántica del delta | Diferencia entre los campos 9 y 10 que debe reducirse **exactamente** a la **incorporación del par esperado** dentro de `required_status_checks` |

**Cualquier otra diferencia invalida la mutación** y obliga a detener y escalar:
`enforcement`, condiciones, destino, política estricta, cualquier otro parámetro,
cualquier otra regla o los *bypass actors*.

**Grupo F · Canonicalización y huellas**

| # | Campo | Contenido |
|---|---|---|
| 16 | Esquema de la proyección | **Identificador y versión** del esquema de proyección semántica empleado |
| 17 | Normalización de colecciones | **Claves compuestas declaradas** con las que se ordena cada colección **cuyo orden no tenga significado** |
| 18 | Arrays con orden significativo | **Enumerados nominalmente**, con su **orden preservado** y no normalizado |
| 19 | Canonicalización JSON | **RFC 8785 (JCS)** aplicada a la proyección ya normalizada |
| 20 | Huellas | **SHA-256 de los bytes JCS exactos**, sin transformación posterior, de preimagen, postimagen y —si lo hubiera— postimagen del rollback |
| 21 | Canonicalizador | **Implementación y versión exactas** empleadas |

**Por qué 17 y 18 no son redundantes con 19.** RFC 8785 **ordena las propiedades
de los objetos, pero no reordena los arrays**: su texto exige que las propiedades
se ordenen recursivamente y que **el orden de los elementos de un array NO se
cambie**. Si una colección devuelta por el endpoint no tuviera orden
significativo, JCS por sí solo la dejaría tal cual y dos capturas del mismo estado
podrían dar huellas distintas. Por eso la **normalización semántica del campo 17
es previa y obligatoria**, y el campo 18 **enumera lo que no se toca**.

**Clasificación obligatoria de cada campo recibido.** La proyección clasifica
**cada campo** de la respuesta como exactamente uno de:

| Clase | Tratamiento |
|---|---|
| **Semántico** | Entra en la proyección y se compara |
| **Identidad o direccionamiento** | Se conserva declarado, no se compara como estado |
| **Dependiente del lector** | **Se excluye declarándolo**: rompería la reproducibilidad |
| **Transporte o hipermedia** | **Se excluye declarándolo** |
| **Desconocido** | **Detiene la canonicalización** |

**Un campo desconocido detiene el proceso y nunca se descarta en silencio.**
Campos como `current_user_can_bypass`, `node_id` o `_links`, **si aparecen**,
**se clasifican expresamente**; esta decisión **no afirma que aparezcan
necesariamente en todos los endpoints**.

**Colecciones: una por una, con justificación.** **Cada colección se analiza
individualmente** y **no se presupone sin fuente que su orden carezca de
significado**. Si se normaliza, **debe constar la justificación**. La **clave de
ordenación debe ser inyectiva** sobre esa colección; **una colisión detiene el
proceso**, y **duplicados y multiplicidad se conservan**: normalizar **nunca**
puede borrar una diferencia real bajo apariencia de reordenación. **JCS se aplica
después** de la proyección y la normalización declaradas, y **se hashean
exactamente los bytes JCS**.

**Herramienta.** Producir esta representación **exige una herramienta
versionada** de **proyección, normalización, JCS y hashing**, no una
normalización a mano. El **futuro contrato de `WP-005`** debe **aportarla y
versionarla**, con sus pruebas. **Esta decisión no la implementa, no la
especifica línea a línea y no añade ninguna ruta** a la composición para ella.

**Presupuesto y ciclos: decisión expresa antes de `ready`.** La PR de operador
que corrija `WP-005` debe **decidir expresamente, antes de dejarlo `ready`**, si
su presupuesto vigente de **60 EUR** y sus **dos ciclos de corrección** siguen
bastando para el conjunto acumulado: **librería e integración**; **parche humano
de `ci.yml`**; **política `ops/*`**; **pruebas roja y verde**; **gate terminal**;
**herramienta versionada** de proyección, normalización, JCS y hashing; y
**evidencia y custodia del ruleset**. **Solo son admisibles dos salidas:**

1. **presupuesto y ciclos reajustados** mediante **decisión humana explícita**; o
2. **segregación de la herramienta a un WP futuro con contrato propio**.

**Esta decisión no asigna ahora el identificador de ese WP futuro.** Si se
segrega, la **secuencia de `DEC-003` §2 y su lista cerrada de §4 deben enmendarse
antes de activar `WP-005`**, por el mismo mecanismo atómico que esta decisión ya
exige para cualquier entrada nueva.

**Grupo G · Actor verificable sin publicar identidad**

| # | Campo | Contenido |
|---|---|---|
| 22 | Rol público del actor | **«operador humano»**, como **descripción del rol** |
| 23 | Tipo de actor | El que devuelva la entrada de historial |
| 24 | Referencia opaca | **Referencia verificable a la entrada del historial** que contiene el actor real, por su **identificador** |

**El literal «operador humano» se conserva como descripción pública del rol, pero
no basta como prueba**: por sí solo es una **autoafirmación** y no distingue a la
persona autorizada de cualquier actor con permiso administrativo —riesgo abierto
cuyo destino es la auditoría de actores de **WP-011**—. La prueba la aportan los
campos 5 a 8 y 23 a 24 **respaldados por la custodia externa del grupo J**: la
respuesta de historia **capturada y custodiada** conserva el actor real, y el
registro versionado publica **solo** una **referencia opaca y su huella**.

**En el repositorio basta «operador humano» más referencia opaca y huella.**
**Cualquier dato personal necesario queda exclusivamente en la custodia
protegida**, nunca versionado.

**No se usa una huella con sal de un nombre o de una cuenta**: no demuestra quién
ejecutó la mutación, solo que alguien escribió un nombre.

**La prueba no puede descansar en la permanencia remota.** Como la retención de
la entrada de historia **no está acreditada** (grupo B), la referencia del campo
24 **solo acredita al actor mientras la custodia del grupo J conserve la
respuesta capturada**. **Una autoafirmación no es alternativa válida.**

**Qué impide mutar y qué impide cerrar, sin confundirlos.** La **custodia
acreditada** y las **capturas previas** son **precondición de mutar**. La
**captura de la entrada de historia** solo puede obtenerse **después** de mutar,
y por eso **no impide mutar**: **impide cerrar `WP-005`**. Si no puede obtenerse,
rige el § *Indisponibilidad posterior de la historia*.

**Grupo H · Concurrencia de la mutación**

| # | Campo | Contenido |
|---|---|---|
| 25 | Comprobación de no deriva | Constancia de que, **justo antes de mutar**, la versión vigente **seguía siendo** la del campo 5 |
| 26 | Comprobación del delta | Constancia de que, **inmediatamente después**, el delta del campo 15 era **exactamente** el autorizado |

**Procedimiento vinculante.** Se captura la versión **inmediatamente anterior**;
se **comprueba que sigue siendo la última** justo antes de mutar; **si hay
deriva, se aborta** y se reinicia desde una **nueva preimagen**; se captura
**inmediatamente** la versión posterior; y **si el delta no es exactamente el
autorizado, se detiene y se escala**.

**Grupo I · Rollback**

| # | Campo | Contenido |
|---|---|---|
| 27 | Procedimiento | **Rollback mínimo**: retirar **solo** el par `{context, integration_id}` del campo 13 |
| 28 | Condición verificable | Condición **comprobable**, no solo descrita, de que el rollback dejó el ruleset **semánticamente coincidente** con la preimagen en **todo lo relevante** |
| 29 | Postimagen del rollback | Nueva versión capturada **después** del rollback, con su `version_id`, su estado completo y su huella JCS |

**Vinculante.** **Nunca se reescribe ciegamente la preimagen completa.** Antes de
revertir se **verifica que el estado vigente sigue siendo exactamente la
postimagen esperada**; **si aparece cualquier cambio concurrente, se detiene y se
escala**, y **no se sobrescribe trabajo ajeno**. Después se captura la nueva
versión y se **demuestra semánticamente** —no por mera coincidencia de la lista
de contextos— que coincide con la preimagen en todo lo relevante.

**Grupo J · Custodia externa de las capturas**

| # | Campo | Contenido |
|---|---|---|
| 30 | Propietario de la custodia | **Persona o función responsable**, nombrada por su **rol**, de conservarla y dar acceso |
| 31 | Política de acceso | **Quién puede leerla y bajo qué condición**, incluido el acceso del **auditor autorizado** |
| 32 | Soporte y ubicación lógica | **Soporte**, su **durabilidad** y la **ubicación lógica** del árbol de custodia. **Nunca `/private/tmp`** ni ningún destino volátil |
| 33 | Retención | **Periodo explícito por escrito** y qué ocurre al vencer |
| 34 | Procedimiento de recuperación | **Cómo se recupera y se verifica** la representación custodiada |
| 35 | Auditabilidad futura | **Cómo comprueba después un auditor autorizado** la correspondencia entre la referencia opaca versionada y la respuesta custodiada |
| 36 | Huella de la custodia | **SHA-256 de los bytes JCS** de cada representación custodiada, publicable en el repositorio |

**Qué se custodia.** Las **representaciones completas y saneadas**: preimagen,
postimagen, respuesta de historia capturada y, si lo hubiera, postimagen del
rollback.

**Qué se versiona en el repositorio.** **Solo identificadores opacos, huellas y
hechos no personales.** Nada de correo, usuario local, identificador de cuenta ni
ninguna otra identidad personal.

**Parada previa, acotada a lo que sí puede existir antes.** **Si la custodia de
este grupo, las credenciales y endpoints del grupo A o las capturas de los grupos
B y C anteriores a la mutación no pueden acreditarse, el procedimiento se detiene
antes de mutar.** No se muta el ruleset sin poder demostrar después qué había
antes. **La entrada de historia del campo 8 no entra en esta parada previa**: no
existe todavía.

### Orden vinculante del procedimiento

Se escribe **una sola vez y aquí**, para que no haya que deducirlo:

| # | Paso | Momento |
|---|---|---|
| 1 | **Seleccionar y acreditar de antemano la custodia externa** (grupo J) | Antes |
| 2 | **Verificar que están disponibles las credenciales y los endpoints** necesarios | Antes |
| 3 | **Capturar el estado vigente** y la **última versión anterior** | Antes |
| 4 | **Custodiar y hashear la preimagen** | Antes |
| 5 | **Comprobar la no deriva** inmediatamente antes de mutar | Antes |
| 6 | **Realizar la única mutación autorizada** | **La mutación** |
| 7 | **Capturar inmediatamente el estado actual posterior** | Después |
| 8 | **Verificar que el delta es exactamente el par añadido** | Después |
| 9 | **Localizar la nueva versión en la historia** (endpoint de listado) | Después |
| 10 | **Obtener su estado completo** por el endpoint de versión concreta | Después |
| 11 | **Custodiar** respuesta de listado, respuesta de versión y postimagen | Después |
| 12 | **Registrar** identificadores y huellas | Después |
| 13 | **Solo entonces**, permitir la PR de cierre del paso 19 | Después |

**Las cuatro distinciones, expresas:**

- **Debe existir antes de mutar:** custodia acreditada, credenciales y endpoints
  disponibles, estado vigente y versión anterior capturados y hasheados, no
  deriva comprobada.
- **Solo puede capturarse después:** postimagen, delta, nueva entrada de
  historia, estado completo de esa versión.
- **Impide mutar:** que falle cualquiera de los pasos 1 a 5.
- **Impide cerrar `WP-005`:** que falle cualquiera de los pasos 7 a 12.

### Indisponibilidad posterior de la historia

El **futuro contrato de `WP-005`** debe fijar **antes de ejecutarse**: el
**número máximo de intentos**, el **plazo máximo**, el **backoff**, los **códigos
y respuestas reintentables** y el **registro UTC de cada intento**.

Si, tras una mutación **cuyo estado actual demuestra exactamente el delta
autorizado**, la nueva entrada histórica **no aparece o no puede leerse**:

1. **no se afirma que la mutación carezca de efecto**: el estado actual ya
   demuestra el delta;
2. **se conserva provisionalmente la mutación**, que es la situación **más
   restrictiva** —el check queda requerido—;
3. **`WP-005` permanece abierto y activo**, sin marcarse `done`;
4. **no se presenta la PR de cierre** del paso 19;
5. se **registran externamente** los intentos, sus respuestas y sus instantes
   UTC;
6. **se detiene y se escala**;
7. **ninguna autoafirmación del actor sustituye a la evidencia**.

**No se ordena rollback automático por la sola indisponibilidad histórica.**
Revertir un control que ya está en vigor, y hacerlo sin evidencia, empeoraría el
estado en lugar de mejorarlo.

**Si una decisión humana posterior ordena rollback:** se **comprueba antes** que
el estado vigente **sigue coincidiendo con la postimagen esperada**; se **retira
únicamente el par añadido**; se **captura el nuevo estado**; se **intenta
capturar también su versión histórica**; la **autorización humana del rollback
queda registrada en la custodia protegida**; si la historia del rollback
**tampoco aparece**, **`WP-005` continúa abierto** y **la evidencia se declara
incompleta**; y **nunca se sobrescribe una mutación concurrente**.

**Si el delta posterior no es exactamente el autorizado**, se aplica el rollback
condicional del grupo I; y si lo que aparece es **deriva concurrente**, **parada
y escalado**, sin sobrescribir trabajo ajeno.

### Saneado

Una representación es **saneada** si **excluye expresamente** tokens, cabeceras
de autenticación, credenciales, cookies, URLs firmadas y **cualquier dato
personal innecesario**. Sin saneado, el registro publicaría material que
`SEC-001` prohíbe versionar. El saneado **se aplica antes** de la normalización y
la canonicalización, y **lo que excluye se declara nominalmente**, para que la
huella siga siendo reproducible.

### Qué debe demostrar el registro

Comparada con la preimagen, la postimagen debe acreditar que **solo se añadió el
par previsto** y que **no cambiaron** otras reglas, otros parámetros de
`required_status_checks` —política estricta, exigencia de rama al día—,
`enforcement`, las condiciones, el destino ni los *bypass actors*. Un registro
que no permita esa comparación **no cumple esta sección**.

**Esta decisión no inventa identificadores ni valores vivos.** Fija el **contrato
de evidencia**; los valores los captura la persona que ejecuta la mutación, en el
momento de ejecutarla.

## Consecuencias y fronteras

**A favor.** El control concluyente **pasará** al diff en CI cuando `WP-002` y
`WP-005` lo construyan; el sandbox **aportaría** la frontera del sistema operativo
**si E2 supera su gate y se adopta**; el guard vuelve a su papel proporcional;
WP-009 atiende primero la cadena de suministro; se desbloquea el producto y se
conserva la trazabilidad de la candidata local. **Ninguna de las dos primeras
ventajas está disponible hoy**, y esta decisión no las cuenta como logradas: son
el motivo de la secuencia, no su resultado.

**Costes aceptados.** Hay que corregir 03 y 05 antes de fusionarlos, custodiar
trabajo temporal y materializar varias transiciones humanas separadas. La
reducción del núcleo renuncia a perfeccionar una maquinaria ya construida.

**Fronteras.** Esta decisión no demuestra semántica del runtime, no instala el
sandbox, no implementa `check_scope`, no reactiva los workflows de agente, no
concede accesos, no abre repositorios y no autoriza datos de cliente en K3.

## Qué no autoriza

1. No modifica ahora `ACTIVE` ni inicia WP-009.
2. No materializa el contrato reducido ni abre el ciclo `3 / 3`.
3. No autoriza borrar, ejecutar o presentar como conforme la candidata local.
4. No ejecuta batería, fase roja/verde, pruebas, scripts ni red operativa.
5. No autoriza Git mutable antes de la operación humana que materialice esta
   decisión.
6. No activa `claude.yml` ni `code-review.yml`.
7. No permite un cuarto ciclo.
8. No adopta elementos marcados `DEJAR`, `RECHAZAR` o solo `YA CUBIERTO` como
   trabajo nuevo.
9. No convierte una fecha orientativa en sustituto de un criterio de salida.
10. **No autoriza escribir en `ACTIVE` ningún valor que no sea reposo o un
    `WP-NNN` existente.** Ni actividades, ni descripciones, ni combinaciones de
    dos WPs, ni identificadores provisionales.
11. **No reserva ni inventa identificadores** para el experimento E2 del sandbox
    ni para el WP T3 de adopción, y **no autoriza ejecutarlos**: hace falta una
    decisión o enmienda posterior que asigne el identificador exacto, apruebe el
    contrato y lo admita en `DEC-003` §4.
12. **No activa `WP-002` ni `WP-005`.** `WP-002` sigue `blocked` y `WP-005`
    `draft` hasta que sendas PRs de operador corrijan y aprueben sus contratos.
13. **No levanta la congelación de `WP-007`** de `DEC-003` §1 ni cambia su estado
    contractual `ready`.
14. **No presenta `check_scope` ni el sandbox como existentes**, ni declara
    completada la democión formal del parser del guard antes de que E2 y su gate
    se resuelvan.
15. **No amplía el conjunto `WP008-F1`–`WP008-F6`**, que es cerrado. La prueba
    proporcional del parche que D6-A exige es **tratamiento** de `WP008-F1`, no un
    séptimo hallazgo.
16. **No permite presentar un E2 negativo como garantía del sistema operativo**,
    ni describir la capa 2 como conseguida sin adopción efectiva del sandbox.
17. **No permite un humo sobre archivos reales de FDA.** El ensayo es sintético,
    aislado y fuera de la raíz del repositorio; crear, leer o modificar un `.env`,
    un secreto o cualquier archivo real de FDA queda prohibido.
18. **No declara materializada la revisión humana ni la de `CODEOWNERS`**: siguen
    sin imponerse técnicamente y su destino es WP-011.
19. **No afirma que `WP008-F1`–`WP008-F5` puedan reproducirse técnicamente desde
    `main`**: sus artefactos no están versionados.
20. **No restaura** la captura roja/verde, el protocolo de doce escenarios, la
    batería A completa ni `test-protocolo.sh` como maquinaria íntegra.
21. **No autoriza dar por impuesta por el ruleset la imposibilidad de autofusión.**
    Lo acreditado del ruleset son PR obligatoria, los tres checks bloqueantes,
    `non_fast_forward` y `deletion`. **La política de `CLAUDE.md` prohíbe la
    autofusión** y las **restricciones operativas** conocidas —allowlists de
    herramientas y workflows de agente desactivados— **reducen la superficie**,
    **pero no se ha acreditado una imposibilidad técnica universal ni se han
    auditado todos los actores y credenciales**. Norma, restricción operativa y
    comportamiento empírico son tres planos distintos: el tercero **no está
    medido**.
22. **No trata `docs/03`, `docs/04` y `docs/05` como normas de estado
    equiparables.** `docs/03` es la hoja de ruta normativa; `docs/04` y `docs/05`
    entran como procedencia y fotos fijas y no gobiernan el estado actual.
23. **No autoriza activar `WP-005` con su contrato actual.** Ese contrato **no es
    ejecutable tal como está redactado**: declara `agente_responsable: implementer`
    sobre una ruta que `permissions.deny` veda a las herramientas de edición, exige
    evidencia en `evidence/WP-005/` sin tenerla en su allowlist, y haría fallar
    toda rama `ops/*`. Su PR de operador **debe corregirlo íntegramente** conforme a
    `DEC-003` §2.d. **Esta PR del punto de control no modifica
    `work-packages/WP-005-check-scope-en-ci.md`**, que no está en la lista cerrada
    de `DEC-003` §4 como ruta editable de este diff.
24. **No autoriza a ningún agente a escribir en `.github/workflows/**`, ni a
    relajar `permissions.deny`.** El cambio sobre `ci.yml` es un **parche
    verificable preparado por el agente y aplicado por una persona**, dentro de la
    PR de `WP-005` y con `ACTIVE` en `WP-005`.
25. **No autoriza cerrar `WP-005` en dos diffs.** Marcar el WP `done` y escribir
    reposo en `ACTIVE` **viajan juntos o no viajan**: un diff intermedio dejaría
    versionado un `ACTIVE` apuntando a un WP ya cerrado, y
    `tests/governance/check-active.sh` **no lo detectaría**, porque solo valida que
    el WP exista y declare alcance, no su estado. **`ACTIVE` cambia exactamente una
    vez en todo el cierre**, y **ningún acto tipado solo como `O` lo cambia**.
26. **No autoriza una política de `ops/*` que deje el check requerido ausente o
    pendiente**, ni que reconozca al operador **solo por el nombre de la rama**, ni
    que abra ante un fallo de verificación: **cierra**. **Tampoco autoriza
    identificar el check solo por su nombre** —se identifica por el par
    `{context, integration_id}`— ni **aceptar una autorización que no esté
    vinculada al `HEAD SHA` vigente** de la PR. **Ni que el job requerido pueda
    saltarse** por una dependencia `needs:` fallida o saltada, por
    `continue-on-error`, o por un step que convierta un fallo en `success`:
    **cualquier conclusión distinta de `success` tras verificación completa o de
    `failure` impide cerrar `WP-005`**.
27. **No autoriza registrar la mutación del ruleset sin el contrato de evidencia**
    de § «Evidencia de la mutación del ruleset», ni **versionar identidad
    personal** en ese registro: el actor se publica como rol —**«operador
    humano»**— y su prueba es la **referencia opaca al historial protegido**.
    **Tampoco autoriza** dar por probada la mutación con **listas resumidas** en
    lugar del **estado completo**, ni **mutar o revertir sin las comprobaciones
    de deriva** de los grupos H e I, ni **mutar sin custodia externa acreditada
    de antemano**, ni **cerrar `WP-005` sin la entrada de historia** del campo 8.
    **Tampoco autoriza revertir automáticamente por la sola indisponibilidad
    histórica**, ni **atribuir al endpoint de listado un `state` completo que no
    devuelve**, ni **presentar la ventana de 180 días de la interfaz como
    garantía de retención del endpoint REST**.
28. **No autoriza mutar el ruleset ni declarar `check_scope` bloqueante para la
    fusión.** Incorporar el check a `required_status_checks` es **acto humano sobre
    GitHub**, posterior a que el job **reporte desde `main`**, y exige el registro
    versionado del **paso 19** —el paso 18 **no versiona nada**—. **Tampoco crea un quinto tipo de regla**: añade una
    **cuarta comprobación requerida** dentro de la regla `required_status_checks`
    ya existente.
29. **No autoriza activar `WP-007` con su contrato actual.** Ese contrato **no es
    ejecutable en el orden nuevo**: su **PR 4 histórica** ordena marcar `WP-007`
    `done`, `WP-002` `ready` y **`ACTIVE` ← `WP-002`** —la **PR-4** de `DEC-002`—,
    transición **obsoleta** tras el paso 14, y su premisa de que el hook precede al reinicio de `WP-002`
    queda **invertida** por el paso 20. Bajo la rama de **ejecución** debe
    **corregirse íntegramente en una PR de operador previa** (paso 21-B, acto 1);
    bajo la rama de **superación** **no se ejecuta**, y `WP-007` se cierra con
    `estado: done` y bloque **«Cerrado por superación»** (paso 21-A). **Tampoco
    autoriza levantar la congelación sin la precondición común del paso 21**:
    recálculo de las siete magnitudes, parada si alguna difiere, y **custodia
    externa acreditada de la candidata antes de modificarla, limpiarla o
    descartarla**. **Un descarte antes de esa custodia queda prohibido.** **Esta
    PR del punto de control no modifica
    `work-packages/WP-007-semantica-de-traversal.md`**, que no está en la lista
    cerrada de `DEC-003` §4 como ruta editable de este diff.

## Criterio documental de aprobación de esta decisión

La PR del punto de control solo es apta cuando cumple las condiciones
documentales de esta lista. Las obligaciones sobre WP-007, la política `ops/*`
y la evidencia del ruleset quedan definidas aquí para sus pasos futuros: **no se
exige haberlas ejecutado para fusionar esta decisión**, ni se marcan como hechos
ya producidos.

- D1–D6 tienen un resultado explícito —ratificado o default—;
- `DEC-003`, la hoja de ruta y el manual describen la misma secuencia y criterio
  de salida;
- 03 y 05 contienen la foto local corregida y distinguen arquitectura objetivo de
  estado materializado;
- la composición corresponde al resultado de D3: **nueve** archivos si se ratifica,
  o la variante separada de **tres** si queda en su default, sin extraer
  selectivamente archivos de la otra;
- todos los valores de `ACTIVE` que aparezcan en cualquiera de los textos son
  reposo o un `WP-NNN` existente;
- ninguna ruta atribuye a `DEC-006` la autoridad directa del presupuesto nuevo;
- el conjunto `WP008-F1`–`WP008-F6` está definido íntegramente en esta decisión y
  no colisiona con los `H1`–`H12` de investigación de `docs/05` §3, y las **cuatro
  combinaciones de D1 y D6** tienen tratamiento escrito para `WP008-F6`;
- ninguna ruta atribuye a `DEC-005` ni a `DEC-006` la asignación del caso `.env`,
  ni presenta un E2 negativo como garantía del sistema operativo;
- la capa de plataforma se describe como **parcialmente materializada** —nunca
  como completa— con sus **niveles distinguidos y no fundidos** —los tres
  originales más los dos que la reclasificación de la autofusión obliga a
  separar: **política vigente** y **restricción operativa**— en `CLAUDE.md`,
  `docs/02`, `docs/03`, `MANUAL.md` y esta decisión;
- **ninguna ruta atribuye al ruleset la imposibilidad de autofusión.** El ruleset
  acredita PR obligatoria, los tres checks bloqueantes, `non_fast_forward` y
  `deletion`; el expediente actual **no acredita más y no incluye un inventario
  exhaustivo** del ruleset; la prohibición es **política** de `CLAUDE.md`, las
  allowlists y la automatización desactivada son **restricciones operativas** que
  **no son garantía universal**, y el **riesgo pendiente** tiene destino WP-011;
- **ningún mapa resumido de `docs/02` ni de `MANUAL.md` contradice el cuerpo
  detallado del mismo archivo**, señaladamente en `CODEOWNERS` —revisión
  obligatoria como norma, no impuesta técnicamente— y en `guard.sh` —best-effort,
  deniega lo que reconoce, falla abierto, y el deny de rutas protegidas y
  comandos vetados no es suyo—;
- **ninguna ruta presenta `check_scope`, el diff en CI o el sandbox como controles
  locales existentes**: todo enunciado sobre ellos queda condicionado a
  materialización (`WP-002` + `WP-005`) o a **adopción efectiva** (E2 + WP T3);
- **los tres estados de `check_scope` están distinguidos y no fundidos** en
  `DEC-003`, en esta decisión, en `docs/03` y en `manual/05`: ejecutable local,
  job **ejecutándose en CI** todavía no requerido, y check **incorporado a
  `required_status_checks`**, único estado que se describe como **bloqueante para
  la fusión**; y **ninguna ruta afirma que esa incorporación cree un quinto tipo de
  regla**;
- **`ACTIVE` cambia exactamente una vez al cerrar `WP-005`**, en el **mismo diff
  atómico** que lo marca `done`; **ningún acto tipado solo como `O` cambia
  `ACTIVE`**; y los tipos compuestos **`W/O` y `O/T` están definidos antes de
  usarse**, con **`O/T` empleado exactamente una vez** (paso 19);
- **la resolución de `WP-007` está escrita en dos ramas excluyentes y
  correctamente tipadas**: **superación** como acto `O` con `ACTIVE` en reposo y
  **sin transición**, que deja **`estado: done`** más bloque **«Cerrado por
  superación»**; y **ejecución** como secuencia **`O` + `T` + `W` + `T`**,
  **nunca como un `O/T` único**, cuyo primer acto **corrige íntegramente el
  contrato**, **retira o sustituye su PR 4 histórica**, lo deja literalmente en
  **`estado: ready`** y **queda fusionado antes de activarlo**, y cuyo último
  acto **marca `done`, escribe reposo y registra el resultado en un único diff**.
  **Ninguna condición exige `WP-007` resuelto antes de poder ejecutarlo**, y
  **ninguna rama reactiva `WP-002` ni `WP-005`**;
- **la resolución futura de `WP-007` queda condicionada** al recálculo en solo
  lectura de las **siete magnitudes**, **parada y análisis** si alguna difiere,
  comprobación de **cardinalidad, tipos y modos** no cubiertos por la huella, y
  **custodia externa persistente de la candidata completa antes de modificarla,
  limpiarla o descartarla**, marcada **`CANDIDATA HISTÓRICA NO CONFORME — NO
  EJECUTAR`**; esta PR no ejecuta la custodia y ningún descarte la precede;
- **la política futura de `ops/*` queda especificada por este contrato medible**
  y deberá probarse durante `WP-005` antes de tocar el ruleset: el job requerido
  **se crea y se ejecuta siempre**, sin filtros de workflow, condiciones de job ni
  dependencias `needs:` que puedan saltarlo, con **`always()` o independencia de
  otros jobs**, **`continue-on-error: false`** y un **gate terminal único que
  agrega y falla cerrado**; **única conclusión conforme `success` tras
  verificación completa**, **negativa esperada `failure`**, y **cualquier otro
  estado o conclusión impide cerrar `WP-005`**; condiciones de step **solo** si
  no evitan ejecutar el verificador; check identificado por el par
  `{context, integration_id}` con **productor fijado**; reconocimiento del
  operador **no basado solo en el nombre de rama**; `wp/*` **fail-closed**;
  **casos rojo y verde falsables**, ambos con el job **ejecutado**; y
  **autorización vinculada al `HEAD SHA` vigente** que se **reevalúa** ante los
  eventos que el contrato de `WP-005` enumere;
- **el registro futuro de la mutación del ruleset queda obligado a cumplir el
  esquema completo** —grupos A a J—, después de esa mutación y no antes, con
  **estado completo** de preimagen y postimagen, **delta semántico
  admisible único**, **normalización declarada más canonicalización RFC 8785
  (JCS)** y sus huellas, **actor verificable por referencia opaca respaldada por
  custodia externa** sin publicar identidad, **comprobación de deriva**,
  **rollback mínimo con condición verificable** y **custodia externa con
  propietario, acceso, soporte, retención, recuperación, auditabilidad y
  huella**; **orden vinculante escrito en un solo lugar**, con lo que debe existir
  **antes de mutar** separado de lo que solo puede capturarse **después**;
  **procedimiento fail-closed de indisponibilidad histórica** con estado
  posterior definido —mutación conservada, `WP-005` abierto, sin PR de cierre y
  sin rollback automático—; **tres endpoints distinguidos**, sin atribuir `state`
  completo al de listado; y **ninguna ruta afirma que una entrada de historia sea
  inmutable ni que su retención futura esté garantizada**: `version_id` es
  **direccionamiento, no custodia**, y la ventana de **180 días** es
  **visibilidad documentada de la interfaz**, no garantía del endpoint REST;
- **la cadena `WP-005` → workflow → ruleset tiene propietario, orden y evidencia**:
  corrección íntegra del contrato antes de activar; parche humano de `ci.yml` dentro
  de la PR del WP; job no requerido con su rojo y su verde capturados; mutación
  humana del ruleset **después** de que el job reporte desde `main`; y registro
  versionado —preimagen, postimagen, nombre del check, rollback y política `ops/*`
  acreditada— **antes** de marcar `WP-005` `done` y devolver `ACTIVE` a reposo, de
  modo que **nunca se ordena escribir evidencia sobre un WP ya cerrado**;
- **ninguna ruta versionada publica una ruta absoluta de máquina**: la localización
  del worktree de la candidata local se describe de forma estable y su ruta exacta
  queda **solo** en el manifiesto externo no fusionable;
- `docs/03` es la **hoja de ruta normativa** y `docs/04` y `docs/05` son
  **procedencia y fotos fijas**, con la **regla de prevalencia temporal** escrita;
- toda definición normativa del humo trae su **envolvente completa** o una
  **remisión inequívoca** a `DEC-003` §6 y a D1 de esta decisión, `docs/03`
  incluida;
- toda definición normativa del humo exige ensayo **sintético, aislado y sin
  secretos reales**;
- D6-A conserva una **prueba determinista proporcional** del parche sin reactivar
  el protocolo completo;
- no cambia `ACTIVE`, `DEC-005`, `DEC-006`, contratos, implementación ni
  evidencia;
- los enlaces internos y la documentación pasan sus verificaciones aplicables;
- una revisión independiente confirma que ninguna rama de D6 deja WP-008 sin
  salida ni abre un cuarto ciclo.

## Referencias

- [`CLAUDE.md`](../../CLAUDE.md) — constitución; ruta de la composición
- [`docs/02-guia-fabrica-desarrollo-agentica.md`](../../docs/02-guia-fabrica-desarrollo-agentica.md) — especificación vinculante; ruta de la composición
- [`docs/03-hoja-de-ruta.md`](../../docs/03-hoja-de-ruta.md) — rumbo vinculante propuesto por D3
- [`docs/manual/MANUAL.md`](../../docs/manual/MANUAL.md) — índice y modelo de controles del manual; ruta de la composición
- [`specs/decisions/DEC-003-pausa-migracion-y-contencion.md`](DEC-003-pausa-migracion-y-contencion.md)
- [`specs/decisions/DEC-005-troceado-de-wp-008-y-revision-de-la-pausa.md`](DEC-005-troceado-de-wp-008-y-revision-de-la-pausa.md)
- [`specs/decisions/DEC-006-abandono-y-reinicio-controlado-de-wp-008.md`](DEC-006-abandono-y-reinicio-controlado-de-wp-008.md)
- [`work-packages/WP-008-runtime-fail-closed.md`](../../work-packages/WP-008-runtime-fail-closed.md)
- [`docs/manual/05-bloqueos-y-parada.md`](../../docs/manual/05-bloqueos-y-parada.md)
- hoja de ruta v2, análisis 04 y revisión 05 del commit
  `a45228ee1185fc409a7f7cd565a353950f50ecd8`
- Nota 49 y Adendas 50–51, preparación externa — **procedencia histórica, no
  norma**: soporte efímero, no versionado. El conjunto `WP008-F1`–`WP008-F6`
  se define íntegramente en este archivo y no depende de ellas
