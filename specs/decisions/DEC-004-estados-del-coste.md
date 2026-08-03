# DEC-004 — Estados del coste y adquisición verificable

**Estado:** aceptada · **Fecha:** 2026-08-03 · **Ámbito:** el registro de coste de todo work package —`evidence/WP-XXX/cost.md`— en todos los proyectos que instalen `fda-template`
**Origen:** contradicción entre decisiones aceptadas —[`DEC-001`](DEC-001-divisa-costes.md) §1 exige una adquisición que [`ADR-001`](../adr/ADR-001-runtime.md) I2/I3 prohíbe—, materializada en `evidence/WP-006/cost.md`; contradicción aritmética interna de `DEC-001` entre §5 y §6; y decisión humana expresa del operador del 2026-08-03 sobre la composición de esta PR. Admitida por [`DEC-003`](DEC-003-pausa-migracion-y-contencion.md) §4.

## Problema

Tres normas vigentes a la vez no pueden cumplirse las tres.

1. `DEC-001` §1 exige registrar el coste en USD y define ese valor como «el valor crudo que devuelve `/cost`».
2. `ADR-001`, invariantes **I2** e **I3**, prohíbe que ninguna verificación dependa de una sesión interactiva: sin TTY, sin humano delante, con código de salida significativo.
3. `.claude/skills/run-verification/SKILL.md` §5 materializa la contradicción: instruye `/cost` y `$EDITOR`, que exigen exactamente la sesión que I2/I3 prohíbe.

No es un fallo de disciplina, es de diseño, y tiene una consecuencia observable: `evidence/WP-006/cost.md` conserva `coste_usd: TODO-COSTE` y `coste_eur: TODO-CALCULAR` en un WP cuyo `estado` es `done`. Un marcador ocupando el campo que la decisión llama «el dato auditable» es una violación de la Definition of Done que nadie detectó porque nada la comprobaba.

De ahí los tres fallos que esta decisión cierra:

- **Un marcador se lee como un valor.** `TODO-COSTE` ocupa el sitio de una cifra sin declarar que no hay cifra.
- **No existe estado para «no se pudo medir».** Sin él, la ausencia y la medición se confunden, y la agregación mensual suma sobre un conjunto que no sabe cuál es.
- **La tentación de rellenar.** Cuando un campo obligatorio no puede llenarse y el sistema exige llenarlo, la salida barata es inventar. Una cifra inventada es peor que una ausente: la ausente se ve.

A ello se suma un cuarto defecto, detectado al redactar esta decisión: **`DEC-001` se contradice a sí misma en la aritmética de conversión.**

## Decisión

### 1. Enmienda de `DEC-001` §§1, 5 y 6

`DEC-001` **no queda superada**. Sigue `aceptada` y vigente. Esta decisión la enmienda **por declaración**: el archivo de `DEC-001` **no se edita**, y sus §§1, 5 y 6 se leen en adelante a través de esta cláusula.

**Se preserva sin un matiz de cambio:** USD como moneda de **registro**, EUR como moneda de **gobierno**, el tipo de referencia del BCE, la **congelación** de un tipo por mes natural en [`specs/finops/fx-rates.md`](../finops/fx-rates.md), la comparación sin red, la agregación mensual, las dos vistas —contable y técnica— y la aplicación retroactiva a WP-000. Los cuatro umbrales —75 / 100 / 150 € por WP y 750 €/mes— permanecen intactos.

**§1 — adquisición.** Queda sustituida la cláusula «el valor crudo que devuelve `/cost`». La adquisición pasa a regirse por las fuentes **F1**, **F2** y **F3** de §§5–7. Lo demás de §1 se lee así: **cuando existe una cifra defendible, el valor original en USD se almacena y nunca se modifica** — es el dato auditable. `estado_coste: no_disponible` declara precisamente que esa cifra **no existe**, y por tanto **prohíbe** `coste_usd`. «Se almacena siempre» nunca significó «invéntate uno».

**§5 — aritmética de comparación.** `DEC-001` §5 ordena comparar `coste_usd_actual × tipo_del_mes` contra `presupuesto_max_eur`, mientras `DEC-001` §6 y `fx-rates.md` regla 5 dividen. Multiplicar y dividir no pueden ser ambos correctos. Con el tipo expresado como **USD por 1 EUR** —`fx-rates.md` regla 4—, la operación correcta es la **división**. Queda enmendado:

> `coste_eur = coste_usd / tipo_eurusd`, y la comparación durante la ejecución es `coste_usd / tipo_del_mes` contra `presupuesto_max_eur`.

Con el tipo de julio de 2026 (1,1383), multiplicar en vez de dividir infla el resultado alrededor de un 30 %. El signo del error depende del tipo y no debe enunciarse como invariante.

**§6 — bloque de registro.** `DEC-001` §6 define **seis** campos: `coste_usd`, `tipo_eurusd`, `fuente`, `coste_eur`, `presupuesto_eur` y `consumo`. Los seis se conservan con su nombre y su significado; **ninguno se renombra**. Esta decisión **añade** campos, según §4.

### 2. Enmienda de `DEC-003` §4 — composición autorizada de esta PR

`DEC-003` §4 enumera «`DEC-004` — Estados del coste. Decisión sola, sin implementación» dentro de una **lista cerrada**. Por **decisión humana expresa del operador del 2026-08-03**, esta decisión **enmienda** esa entrada, que pasa a leerse:

> `DEC-004` — Estados del coste. Su PR es **atómica** y comprende **exclusivamente** estos cinco archivos:
>
> 1. `specs/decisions/DEC-004-estados-del-coste.md`
> 2. `docs/manual/02-ciclo-de-un-wp.md`
> 3. `docs/manual/06-costes-y-metricas.md`
> 4. `docs/02-guia-fabrica-desarrollo-agentica.md`
> 5. `specs/finops/fx-rates.md`
>
> **Sin implementación** conserva su significado y se refuerza: ninguna skill, ningún hook, ningún script, ningún workflow, `settings.json`, test, plantilla de WP ni evidencia.

**Razón de cada archivo.** Los tres documentos (2, 3 y 4) entran porque `CLAUDE.md` § Documentación es vinculante —«Todo cambio de proceso, contrato o agente actualiza `docs/manual/` en la misma PR. Manual desactualizado = PR incompleta»— y esta decisión cambia el proceso de registro de coste. El quinto entra porque `DEC-001` § Mantenimiento exige la línea del mes en curso en `fx-rates.md` y su ausencia bloquea el registro de coste de todo WP cerrado en agosto de 2026, incluido el criterio de salida de `DEC-003` §6.

Esta enmienda **no amplía la lista cerrada de `DEC-003` §4 en ningún otro punto**, no altera su §2 (secuencia de `ACTIVE`), su §3 (estado externo de los workflows), su §5 (fecha de revisión), su §6 (criterio de salida) ni su §7 (prohibición sobre `tests/guard/run-suite.sh`). No autoriza `specs/finops/excepciones-coste.md`, ninguna skill, ningún WP y ningún hito nuevo.

`work-packages/ACTIVE` **no se toca**: permanece en reposo. No hay transición de operador asociada a esta PR.

### 3. Conjunto cerrado de estados

```
estado_coste: medido | estimado | no_disponible
```

**Tres valores. Ni uno más.** Cualquier otro valor, o un valor vacío, hace el archivo inválido — no dudoso: inválido.

| Estado | Definición exacta |
|---|---|
| `medido` | **Estimación del cliente** obtenida mediante **captura instrumental automática** conforme a **F1** o **F2**. Clasifica **procedencia**; no afirma exactitud, ni validación, ni facturación |
| `estimado` | Cifra obtenida por **F3**, o procedente de una captura instrumental **incompleta o no conforme** con F1/F2 |
| `no_disponible` | **No existe cifra defendible.** No se inventa ninguna |

`estado_coste` clasifica **una sola cosa: de dónde viene la cifra**. No se introduce ahora ningún campo separado de validación.

### 4. Campos del registro

`fuente` **conserva su significado de `DEC-001`**: procedencia del **tipo de cambio**. Para la procedencia del **importe en USD** se añade un campo nuevo, `fuente_coste`, que es a la vez el identificador del método (`F1`, `F2` o `F3`). No hay dos campos para lo mismo.

| Campo | `medido` | `estimado` | `no_disponible` | Regla |
|---|---|---|---|---|
| `estado_coste` | obligatorio | obligatorio | obligatorio | Uno de los tres valores del conjunto cerrado |
| `causa` | ausente | **obligatorio** | **obligatorio** | Concreta y verificable. «pendiente» no es una causa |
| `coste_usd` | obligatorio | obligatorio | **prohibido** | Decimal con punto, ≥ 0. Ausente, no cero ni marcador |
| `fuente_coste` | obligatorio | obligatorio | ausente | `F1`, `F2` o `F3` |
| `base_estimacion` | ausente | **obligatorio** | ausente | Base concreta y reconstruible (§7) |
| `fecha_medicion` | obligatorio | obligatorio | ausente | `AAAA-MM-DD` |
| `operador` | obligatorio | obligatorio | obligatorio | **Actor que registra la entrada** (nota 1) |
| `instrumento` | obligatorio | si aplica | ausente | Nombre y **versión exacta**, p. ej. `claude-code 2.1.220` |
| `wp_id` | **obligatorio** | **obligatorio** | **obligatorio** | WP-ID declarado. Debe coincidir con el WP de la carpeta |
| `artefacto` · `artefacto_sha256` | obligatorios | **condicionales** (nota 2) | ausentes | Ruta del extracto y SHA-256 sobre sus bytes finales |
| `excepcion` | ausente | ausente | **opcional** (nota 3) | Si está, debe resolver contra el registro versionado |
| `tipo_eurusd` · `fuente` · `coste_eur` · `consumo` | obligatorios | obligatorios | ausentes | Según `DEC-001`, con la aritmética enmendada en §1 |
| `presupuesto_eur` | obligatorio | obligatorio | obligatorio | El del contrato del WP |

**Nota 1 — `operador`.** Es el **actor que registra la entrada**: una **persona** o una **automatización determinista versionada**. Vale para los tres estados: `medido`, `estimado` y `no_disponible`.

- **F3 exige persona.** Descansa en un juicio humano y no puede firmarlo una automatización.
- **`no_disponible` puede producirlo el capturador headless** cuando determina que no existe cifra defendible. En ese caso registra la **causa técnica** concreta —qué falló y en qué punto— y el resultado es **NO APTO**. Que lo emita una máquina no lo hace menos válido ni más apto.
- **Solo conceder una `excepcion` exige al operador humano propietario** de `/specs/decisions/` en `CODEOWNERS`. Es el único acto de este capítulo reservado a una persona nombrada.

**Nota 2 — artefacto en `estimado`.** Si `fuente_coste` es `F1` o `F2` y **existe** extracto, `artefacto` y `artefacto_sha256` son **obligatorios**: la captura fue instrumental aunque no llegara a conforme. Si el defecto fue **precisamente que el extracto no pudo producirse**, ambos deben estar **ausentes** y `causa` debe declararlo con ese detalle. Con `fuente_coste: F3` ambos están ausentes siempre.

**Nota 3 — `excepcion`.** Es **opcional**. Su ausencia **no invalida el registro**: el `cost.md` es estructuralmente válido y el WP queda **NO APTO**. Su presencia exige que el identificador resuelva contra una entrada del registro versionado (§11).

**Compatibilidad de archivos anteriores.** Los `cost.md` creados antes de esta decisión —`evidence/WP-000/cost.md` y `evidence/WP-006/cost.md`— **no contienen los campos nuevos**, y eso es lo esperado: se escribieron bajo `DEC-001` sola. No se les exige `estado_coste` ni ningún campo de §4, y su `fuente` significa lo que siempre significó, la procedencia del tipo. Como **ningún campo se ha renombrado**, no hay migración que hacer y no se altera ninguna cifra histórica. La obligatoriedad de §4 rige para todo `cost.md` creado o reescrito a partir de la fusión de esta decisión.

### 5. F1 — captura del JSON estructurado

> `total_cost_usd` es una **estimación del cliente** correspondiente a **una invocación** (`claude -p`, una llamada `query()`). **No es un total de sesión y no es facturación autoritativa.**

- **Suma de invocaciones.** Si un WP consume varias invocaciones, el coste del WP es la **suma de todas**. Nunca la última, nunca la mayor. La documentación oficial establece que, con varias llamadas en una misma sesión, cada resultado refleja solo el coste de esa llamada.
- **WP-ID explícito.** El WP-ID se pasa **como argumento al capturador**. Nunca se infiere de `work-packages/ACTIVE`, ni de la sesión, ni de una ventana temporal. Es la aplicación directa de `ADR-001` **I4**.
- **Versión del instrumento.** Se registra la versión exacta. **F1 no queda sujeta al suelo de versión de F2**: la documentación oficial no acredita que el defecto de doble conteo de telemetría alcanzara al JSON, y esta decisión no impone una restricción que la fuente no sostiene.
- **Resultados de error.** Un resultado con `subtype` de error que lleve `total_cost_usd` **se incluye** en la suma: los tokens se consumieron igual.
- **Subagentes.** `total_cost_usd` **incluye** la actividad de subagentes; el campo `usage` la excluye. La cifra del WP es `total_cost_usd`.

### 6. F2 — agregación OpenTelemetry

Para que F2 sostenga `medido` deben cumplirse **todas** estas condiciones. Si falla una, el estado es `estimado`.

- **Claude Code ≥ 2.1.214.** Por debajo, la telemetría de coste y tokens sobrecontaba en flujos con múltiples `message_delta` acumulativos, según el CHANGELOG oficial.
- **Temporality efectiva obligatoriamente `delta`** (`OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE=delta`, que es además el valor por defecto). Con `delta` se **suman** los puntos del intervalo. Sumar puntos `cumulative` es el doble conteo de manual, y por eso `cumulative` no sostiene `medido`.
- **`OTEL_RESOURCE_ATTRIBUTES` incluye un atributo explícito `fda.wp.id=WP-XXX` desde el lanzamiento**, y **`OTEL_METRICS_INCLUDE_RESOURCE_ATTRIBUTES=true`** para que se emita. Lo inyecta el capturador en cada lanzamiento y nunca se fija globalmente.
- **`session.id` no sustituye al WP-ID.** Es configurable, puede no emitirse, una sesión puede abarcar varios WPs y un WP varias sesiones. Nunca es la clave de atribución.
- **Suma sobre las tres procedencias.** Se suman **todos** los puntos de `claude_code.cost.usage` del WP para `query_source` = `main`, `subagent` y `auxiliary`.
- **Importe no atribuible.** Cualquier importe no atribuible **mayor que cero degrada el estado completo a `estimado`**. No existe umbral tolerado ni pendiente de fijar. El importe no atribuible se registra; nunca se resta ni se omite en silencio.
- **Atribución retrospectiva por horario.** Nunca produce `medido`. Puede sostener `estimado` si se declara y se motiva.

**Sesiones que abarcan varios WPs.** Esta decisión **no las normaliza**: no define reparto, ni prorrateo, ni criterio de corte. Dedicar la sesión a un solo WP es **recomendable**, pero **nunca sustituye al WP-ID explícito** del atributo de recurso.

**Se registra en el artefacto:** intervalo de exportación, ventana en UTC, versión del instrumento, WP-ID y suma desglosada por `query_source`.

### 7. F3 — estimación humana

Bases admitidas, **todas del mismo WP** y todas concretas y reconstruibles:

1. **Lectura final fechada de `/usage`** —o de su alias `/cost`—, con fecha, hora y valor mostrado.
2. **Una única lectura final por cada `session.id` distinto** del WP.
3. **Captura instrumental del mismo WP** que no pudo conservarse como artefacto conforme, **explicando el defecto** concreto.

Queda **prohibido**:

- **Extrapolar desde WP-000 o desde cualquier otro WP.** `evidence/WP-000/cost.md` se declara a sí mismo no representativo y pide expresamente no entrar en la media; usarlo de base contradiría su propia advertencia y la prohibición 3 de §10.
- **Sumar varias lecturas acumulativas de la misma sesión**: la lectura es acumulada, sumarlas la duplica.
- **«Entrada humana», «aproximado», «estimación del operador»** o equivalentes sin base: son etiquetas, no bases.
- **Presentar F3 como adquisición headless.** No lo es: es la lectura de un panel por una persona.

`/cost` **existe** y está documentado como **alias de `/usage`**. Esta decisión no afirma lo contrario. Sirve como **base F3 humana** y **nunca** como adquisición F1 o F2: muestra un panel de sesión, no devuelve un valor legible por máquina con código de salida.

### 8. Artefactos de captura

Dos esquemas **distintos**, porque F1 y F2 no miden lo mismo:

| | **Artefacto F1** | **Artefacto F2** |
|---|---|---|
| Unidad | **una entrada por invocación**, más la **suma** | **puntos `delta`** y su **agregación por `query_source`** |
| Campos propios | índice de invocación · `total_cost_usd` de cada una · suma · `num_turns` · `duration_ms` · `subtype`/`is_error` | temporality efectiva · intervalo de exportación · ventana UTC · suma por `main`, `subagent` y `auxiliary` · importe no atribuible |
| Comunes | WP-ID declarado · identificador de sesión **en SHA-256, cuando la fuente lo emite** · modelos · recuentos de tokens · marca de tiempo UTC · instrumento y versión exacta |

**El identificador de sesión es opcional.** Si la fuente no lo emite —`OTEL_METRICS_INCLUDE_SESSION_ID` puede suprimirlo— se omite, y el artefacto sigue siendo conforme. **Nunca es clave de atribución:** la atribución es `fda.wp.id` en F2 y el argumento explícito del capturador en F1.

Ambos son **extractos derivados y saneados**. **Nunca** se versiona el JSON crudo, los logs, los spans ni las cargas OTLP.

**El artefacto no contiene su propio SHA-256.** El resumen lo registra `evidence/WP-XXX/cost.md`, con: **ruta** del artefacto · **SHA-256** calculado sobre sus **bytes finales** · **instrumento y versión** · **WP-ID** · **método** (`fuente_coste`: `F1` o `F2`).

### 9. Seguridad y minimización de identidad

Dos normas distintas, y conviene no fundirlas:

**Ya vinculante — deriva de [`SEC-001`](../requirements/SEC-001-sin-secretos.md).** Su § Texto prohíbe secretos en las salidas versionadas, incluidos los archivos de `evidence/**`, y su § Criterio de verificación, punto 5, exige higiene de evidencias. De ahí que el artefacto no contenga credenciales, claves, tokens, cabeceras `Authorization` ni endpoints con credencial incrustada. Esto no necesita decisión nueva.

**Política nueva, aprobada por esta decisión.** La **minimización de identidad y telemetría** no deriva de `SEC-001`: los datos que siguen no son secretos. Se prohíbe versionarlos porque el repositorio es **público** y porque una evidencia de coste no los necesita para nada:

> No se versionan: correo electrónico, identificadores de usuario, de cuenta ni de organización, tipo de terminal, endpoints, cabeceras, prompts, resultados, contenido de entradas o salidas de herramientas, ni crudos OTel.
>
> **El identificador de sesión se registra como SHA-256, nunca en claro.**

Conservar el crudo **fuera del repositorio** es **opcional**. No es estado operativo obligatorio y **no es fuente de verdad**: la fuente de verdad es el artefacto saneado versionado, conforme a `CLAUDE.md` § Fuente de verdad y a `ADR-001` I1.

### 10. Prohibiciones absolutas del registro

En los **valores** del bloque normativo de `cost.md`:

1. **Marcadores de cualquier forma:** `TODO`, `TODO-COSTE`, `TBD`, `FIXME`, `XXX`, `pendiente`, `?`, `-`, o el valor vacío.
2. **Ceros de relleno.** Un `0` que significa «no lo sé» es un marcador disfrazado, y peor, porque agrega.
3. **Cifras sin origen.** Toda cifra procede de F1, F2 o F3. Una cifra de memoria, redondeada por parecido o derivada de otro WP no es ninguna de las tres.
4. **Causas genéricas.** Una causa dice **qué** impidió medir y **cuándo**.

La prohibición alcanza a los valores del bloque, no a la prosa del resto del archivo.

### 11. `no_disponible`, aptitud y excepciones

**Escribir `no_disponible` no exige ninguna excepción.** Es una declaración legítima y estructuralmente válida: dice que no hay cifra defendible y dice por qué. La excepción no autoriza a escribirla; autoriza a **cerrar el WP** pese a ella.

Tres situaciones, y conviene no confundirlas:

| Situación | Validez del registro | Aptitud del WP |
|---|---|---|
| `no_disponible` **sin** `excepcion` | **Válido** | **NO APTO** |
| `no_disponible` **con** `excepcion` que resuelve contra el registro | **Válido** | El operador **puede autorizar el cierre** |
| `no_disponible` con `excepcion` que no resuelve | **Inválido** | **NO APTO** |

La excepción la concede el **operador humano propietario de `/specs/decisions/` en `CODEOWNERS`** —hoy `@ivanes189`—, nunca un agente ni un revisor automático. Nombra **un solo WP**, lleva identificador, causa, fecha y operador. Una excepción concedida en un comentario de PR o en una conversación **no existe**.

**Mecanismo único: `specs/finops/excepciones-coste.md`**, append-only, con las mismas reglas que `fx-rates.md`. **Lo creará WP-010.** No existe hoy, esta PR **no lo crea** y esta decisión **no autoriza materializarlo ahora**. No hay ningún segundo mecanismo: el futuro validador **leerá el registro** y no llevará lista incrustada de casos tolerados. Dos implementaciones de la misma norma acaban divergiendo — es la lección de `DEC-002`.

**Consecuencia durante la pausa, declarada y asumida.** Mientras `DEC-003` esté vigente y el registro no exista, **solo puede darse la primera situación de la tabla**: un WP puede registrar `no_disponible` con toda validez, y queda **NO APTO** sin remedio disponible. No es que el registro sea inválido; es que no hay forma de autorizar el cierre.

### 12. Procedimiento provisional y estado headless real

**Hasta la fusión de WP-010:**

- El estado se asigna **por procedencia y conformidad**, en este orden exacto: **F1 o F2 conformes con todos sus requisitos → `medido`; F1 o F2 incompletas o no conformes → `estimado`; F3 → `estimado`; sin cifra defendible → `no_disponible`.** La ausencia de validador **no degrada el estado**: lo que degrada es que la propia captura incumpla un requisito de §5 o §6.
- **La adquisición por F3 sigue siendo un acto humano previo** al cierre del WP, realizado por el operador y nunca delegado en un agente.
- **Ningún `cost.md` está validado**, tenga el estado que tenga: no existe validador. La conformidad descansa en la atestación del operador.

**Esta decisión define el contrato objetivo. No convierte el sistema en headless.** Como el procedimiento provisional sigue necesitando intervención humana para F3, **la divergencia con `ADR-001` I2/I3 permanece abierta**. La cierra **WP-010**, mediante adquisición, validación y **códigos de salida headless**. Ningún documento debe citar `DEC-004` como si la divergencia ya estuviera resuelta.

### 13. WP-006 es un caso histórico irrecuperable

`evidence/WP-006/cost.md` registra `TODO-COSTE` en un WP `done`. El dato **se perdió**: la sesión terminó, no hubo captura, y no existe artefacto del que reconstruirlo.

1. **No se inventa cifra.** Ni estimada, ni interpolada, ni derivada de otro WP.
2. **Esta PR no toca `evidence/`.** El archivo queda exactamente como está.
3. **Se declara caso histórico irrecuperable**, con causa conocida: la adquisición dependía de una sesión interactiva y el WP nació como reparación urgente sin medición previa.
4. **La corrección formal la hará WP-010**, reescribiendo ese archivo conforme a §4. No sienta precedente: ningún WP posterior puede alegar WP-006 para cerrarse sin coste.

**La no retroactividad protege las cifras, no la forma.** No se recalcula ningún coste histórico, no se convierte con otro tipo y no se inventa ninguna cifra ausente; sí puede corregirse la forma de un registro para que declare lo que de verdad ocurrió, porque eso no altera ningún número.

### 14. Inventario documental y deuda declarada

Esta PR alinea tres documentos. Quedan desalineados, y su reparación corresponde a **WP-010**, que sucede después de la pausa:

| Documento | Qué queda pendiente |
|---|---|
| `.claude/skills/run-verification/SKILL.md` §5 | Sustituir `/cost` y `$EDITOR` por la captura F1/F2 y la validación headless |
| `.claude/skills/prepare-pr/SKILL.md` | Su precondición sobre `cost.md` es ciega a los estados de §3 |
| `work-packages/_TEMPLATE.md` | Su evidencia exige `cost.md` «con el coste de la sesión»; debe alinearse con el coste por WP, los estados de §3 y la posible agregación de varias sesiones o invocaciones |
| `evidence/WP-006/cost.md` | Corrección formal (§13) |
| `specs/finops/excepciones-coste.md` | Creación del registro (§11) |
| `FDA-diagnostico-y-plan-fase1.md` §2.1 | Documento histórico, no normativo. No requiere acción |

**Las skills no son ruta vedada.** `.claude/settings.json` deniega `Edit` sobre `.github/workflows/**`, `CODEOWNERS`, `.claude/hooks/**` y `.claude/settings.json`; **no** sobre `.claude/skills/**`. WP-010 las modificará dentro de su propio contrato, sin parche humano por esta causa.

Esta decisión **no crea ningún WP, hito ni archivo adicional**, y no reparte esta deuda entre WP-008 ni WP-009.

## Consecuencias

**A favor.** Desaparece el marcador como forma de registro: o hay cifra con origen declarado, o hay una ausencia con causa. La ausencia deja de ser gratis, porque bloquea el APTO. **DEC-004 introduce rutas de adquisición headless** —F1 y F2— y las convierte en la vía normal, pero **no elimina todavía la dependencia provisional de F3**, que sigue exigiendo una lectura humana. Esa dependencia la elimina **WP-010**, y es WP-010 quien cierra la divergencia con `ADR-001` I2/I3. La contradicción aritmética de `DEC-001` queda resuelta en un único sitio. Y `DEC-001` sobrevive entera: nadie tiene que releer la convención de divisa.

**En contra.** Hasta WP-010 el estado habitual será `estimado`, y la agregación mensual heredará esa incertidumbre. Se acepta: un `estimado` con base reconstruible vale más que un `medido` que nadie comprueba. Además, `estado_coste` es un campo nuevo que hoy nadie valida: durante la ventana provisional su cumplimiento depende de la disciplina del operador, que es justamente el punto débil que WP-010 cierra.

**Riesgo declarado y no resuelto aquí.** Si un WP termina en `no_disponible` mientras dura la pausa, no hay excepción posible (§11). Es una consecuencia de la lista cerrada de `DEC-003`, no de esta decisión, y se registra para que nadie la descubra tarde.

**Mantenimiento.** Al fusionarse WP-010, el régimen provisional de §12 caduca por cumplimiento y `medido` pasa a ser el estado normal. La PR de WP-010 debe registrar ese tránsito aquí.

## Referencias

- [`DEC-001`](DEC-001-divisa-costes.md) — vigente; enmendada por declaración en §§1, 5 y 6
- [`DEC-003`](DEC-003-pausa-migracion-y-contencion.md) — su §4 queda enmendado por §2 de esta decisión, y solo en ese punto
- [`ADR-001`](../adr/ADR-001-runtime.md) — invariantes I1, I2, I3 e I4
- [`SEC-001`](../requirements/SEC-001-sin-secretos.md) — secretos en evidencias
- [`specs/finops/fx-rates.md`](../finops/fx-rates.md) — tipos congelados, append-only
- [`docs/manual/06-costes-y-metricas.md`](../../docs/manual/06-costes-y-metricas.md) — operativa
- `evidence/WP-006/cost.md` — caso histórico, sin modificar
- https://code.claude.com/docs/en/headless — `--output-format json` y `total_cost_usd`
- https://code.claude.com/docs/en/agent-sdk/cost-tracking — carácter estimado, granularidad por llamada, subagentes
- https://code.claude.com/docs/en/monitoring-usage — `claude_code.cost.usage`, `query_source`, temporality, atributos de recurso
- https://code.claude.com/docs/en/commands — `/cost` como alias de `/usage`
- https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml — referencia diaria del BCE
