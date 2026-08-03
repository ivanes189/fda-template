[← Manual](MANUAL.md)

# 06 — Costes y métricas

**Métrica principal: coste por WP integrado y aceptado.** No coste por sesión, ni por token, ni por hora. Un WP que costó 40 € pero necesitó tres ciclos y acabó revertido costó mucho más de 40 €.

> Los **primeros 5 WPs son calibración**. No saques conclusiones con n=1: medirás la curva de aprendizaje del sistema, no su rendimiento.

> **Periodo provisional.** F1 y F2 son fuentes admitidas y técnicamente headless, pero hasta WP-010 no están integradas ni validadas como vía operativa normal. Durante este periodo la vía habitual seguirá siendo F3, que exige una lectura humana y, por tanto, sostiene `estimado`; además, ningún `cost.md` se valida automáticamente. El estado se asigna por procedencia y conformidad: F1/F2 conformes → `medido`; F1/F2 incompletas o no conformes → `estimado`; F3 → `estimado`; sin cifra defendible → `no_disponible`. Este capítulo describe el contrato objetivo y el régimen provisional; el sistema no será headless de extremo a extremo hasta WP-010.

## Registrar el coste de un WP

Dos normas vinculantes gobiernan este apartado y mandan sobre este capítulo si alguna vez divergen:

- [DEC-001](../../specs/decisions/DEC-001-divisa-costes.md) — divisa: **USD es el registro, EUR es el gobierno, el tipo se congela** por mes natural.
- [DEC-004](../../specs/decisions/DEC-004-estados-del-coste.md) — **estados del coste y adquisición**: qué fuentes valen, qué declara cada `cost.md` y cuándo un WP no puede ser APTO. Enmienda `DEC-001` §§1, 5 y 6 por declaración.

### 1. Adquirir la cifra

Tres fuentes admitidas, y **solo** estas tres:

| # | Fuente | Qué es | Estado que sostiene |
|---|---|---|---|
| **F1** | **JSON estructurado** | `total_cost_usd` del mensaje `result` de `claude -p --output-format json` | `medido` |
| **F2** | **OpenTelemetry** | suma de los puntos de `claude_code.cost.usage` (USD) del WP | `medido` |
| **F3** | **Estimación humana** | cifra anotada por el operador sobre una base concreta y reconstruible | `estimado` |

> **Límite declarado.** `total_cost_usd` y `claude_code.cost.usage` son **estimaciones del cliente**, calculadas en local con una tabla de precios empaquetada en la versión instalada. No son datos de facturación. Sirven para gobernar el presupuesto interno de la FDA —para lo que la propia documentación las recomienda— y para nada más. La fuente autorizada de facturación es la Usage & Cost API o la consola.
>
> Documentación oficial: [ejecución programática](https://code.claude.com/docs/en/headless) · [seguimiento de coste](https://code.claude.com/docs/en/agent-sdk/cost-tracking) · [OpenTelemetry](https://code.claude.com/docs/en/monitoring-usage).

**F1, en concreto.** `total_cost_usd` es el coste de **una invocación**, no de una sesión: si un WP consume varias, **se suman todas**. Incluye la actividad de **subagentes** —el campo `usage` no la incluye, así que sumarlo a mano subestima—. Un resultado de error que lleve `total_cost_usd` **cuenta**: los tokens se gastaron igual. El **WP-ID se pasa explícitamente al capturador**; no se deduce de `ACTIVE`, ni de la sesión, ni de un horario ([ADR-001](../../specs/adr/ADR-001-runtime.md) I4).

**F2, en concreto.** Requisitos en la sección de telemetría, más abajo. Todos, sin excepción, o el estado baja a `estimado`.

**`/cost` existe** y está documentado como **alias de `/usage`**, que muestra métricas de uso y estimación de coste de la sesión en curso. Sirve como **base F3 humana**, con fecha y hora. **Nunca** es adquisición F1 ni F2: muestra un panel, no devuelve un valor legible por máquina con código de salida.

En CI la adquisición sería la misma, F1 o F2. Hoy es teórica: los dos workflows de agente están **desactivados** por [DEC-003](../../specs/decisions/DEC-003-pausa-migracion-y-contencion.md) §3.

### 2. Volcarlo a `evidence/WP-XXX/cost.md`

Un archivo por WP, versionado. Empieza **siempre** por el bloque normativo:

`````markdown
# Coste — WP-014

Formato según DEC-001 (divisa) y DEC-004 (estados y adquisición).

```
estado_coste: medido
coste_usd: 12.40
fuente_coste: F1
fecha_medicion: 2026-08-05
operador: @ivanes189
instrumento: claude-code 2.1.220
wp_id: WP-014
artefacto: evidence/WP-014/coste-f1.md
artefacto_sha256: 0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef
tipo_eurusd: 1.1535
fuente: BCE ref. 2026-08-03
coste_eur: 10.75
presupuesto_eur: 20
consumo: 54 %
```

| Concepto | Valor |
|---|---|
| Coste total (registro, USD) | $12,40 |
| Coste total (gobierno, EUR) | 10,75 € |
| Presupuesto del WP | 20,00 € |
| Consumo sobre presupuesto | 54 % |
| Invocaciones agregadas | 3 |
| Ciclos de corrección | 1 / 2 |
| Modelo principal | opus |
| Aceptado a la primera | no |

## Notas

El ciclo de corrección vino de un criterio de aceptación ambiguo sobre el
importe cero. Causa raíz: contrato, no implementación.
`````

El ejemplo va en valla de cinco acentos graves porque contiene una de tres. En el `cost.md` real, el bloque normativo lleva su propia valla de tres. **El `artefacto_sha256` de arriba es ilustrativo**: tiene la forma correcta —64 caracteres hexadecimales— pero no corresponde a ningún archivo. En un `cost.md` real se sustituye por el SHA-256 calculado sobre los **bytes finales** del artefacto.

**Campos obligatorios por estado:**

| Campo | `medido` | `estimado` | `no_disponible` |
|---|---|---|---|
| `estado_coste` | sí | sí | sí |
| `causa` | — | **sí** | **sí** |
| `coste_usd` | sí | sí | **prohibido** |
| `fuente_coste` | sí (`F1`/`F2`) | sí (`F1`/`F2`/`F3`) | — |
| `base_estimacion` | — | **sí** | — |
| `fecha_medicion` | sí | sí | — |
| `operador` | sí | sí | sí |
| `instrumento` | sí | si aplica | — |
| `wp_id` | **sí** | **sí** | **sí** |
| `artefacto` · `artefacto_sha256` | sí | **condicional** | — |
| `excepcion` | — | — | **opcional** |
| `tipo_eurusd` · `fuente` · `coste_eur` · `consumo` | sí | sí | — |
| `presupuesto_eur` | sí | sí | sí |

**`operador`.** Es el **actor que registra la entrada**: una **persona** o una **automatización determinista versionada**. Vale para los tres estados: `medido`, `estimado` y `no_disponible`.

- **F3 exige persona.** Descansa en un juicio humano y no puede firmarlo una automatización.
- **`no_disponible` puede producirlo el capturador headless** cuando determina que no existe cifra defendible. En ese caso registra la **causa técnica** concreta —qué falló y en qué punto— y el resultado es **NO APTO**. Que lo emita una máquina no lo hace menos válido ni más apto.
- **Solo conceder una `excepcion` exige al operador humano propietario** de `/specs/decisions/` en `CODEOWNERS`. Es el único acto de este capítulo reservado a una persona nombrada.

**`artefacto` en `estimado` es condicional.** Si la fuente fue F1 o F2 y **hay** extracto, se registran ruta y `sha256`. Si el defecto fue **que el extracto no pudo producirse**, ambos van **ausentes** y `causa` lo dice con ese detalle. Con F3, ausentes siempre.

**`excepcion` es opcional.** Sin ella, el `cost.md` es **válido** y el WP queda **NO APTO**. Con ella, debe resolver contra el registro versionado.

**`fuente` no cambia de significado:** sigue siendo la procedencia del **tipo de cambio**, como en `DEC-001`. La procedencia del **importe** es `fuente_coste`. Ningún campo se ha renombrado, así que los `cost.md` anteriores a DEC-004 —WP-000 y WP-006— siguen leyéndose bajo `DEC-001` sin conversión ninguna: no llevan los campos nuevos, y no se les exigen.

**Prohibido como valor en ese bloque:** `TODO`, `TBD`, `FIXME`, `XXX`, `pendiente`, un guion, un interrogante, un valor vacío, un cero de relleno — y cualquier cifra que no venga de F1, F2 o F3. Un coste inventado es peor que un coste ausente: el ausente se ve.

**Cuando no hay cifra.** `estado_coste: no_disponible` es una declaración **válida**: no hace falta ninguna excepción para escribirla. Lo que hace es dejar el WP **NO APTO**. La excepción no autoriza el registro —ya es válido—, autoriza el **cierre**: la concede el operador propietario de `/specs/decisions/` en `CODEOWNERS` y vivirá en el registro append-only `specs/finops/excepciones-coste.md`, que **creará WP-010**. Hoy no existe, así que **mientras dure la pausa de DEC-003 un `no_disponible` es siempre NO APTO**, por mucho que su registro sea impecable.

### 3. Convertir a euros

El tipo es el **congelado del mes** en [`specs/finops/fx-rates.md`](../../specs/finops/fx-rates.md), expresado como **USD por 1 EUR**. La conversión es una **división**:

```
coste_eur = coste_usd / tipo_eurusd
```

`DEC-001` §5 decía multiplicar y su §6 dividir. **DEC-004 §1 resolvió la contradicción a favor de la división**, que es la coherente con el sentido del tipo. No lo deduzcas del contexto: es norma.

Si falta la línea del mes en curso en `fx-rates.md`, el registro de coste queda **bloqueado** hasta añadirla. Es intencionado: es preferible parar a inventar un tipo.

## Umbrales

| Umbral | Valor | Qué ocurre |
|---|---|---|
| Objetivo por WP | 75 € | Valor esperado |
| Aviso por WP | 100 € | Se registra y se revisa el troceado |
| Aprobación por WP | 150 € | El agente **para** y pide autorización |
| Aviso mensual | 750 € | Revisión de la política de modelos |

Superar el umbral casi siempre significa **WP mal troceado**, no presupuesto corto. Antes de subir el techo, comprueba si el paquete se puede partir.

## Política de modelos por tipo de tarea

| Tarea | Modelo | Por qué |
|---|---|---|
| Arquitectura, seguridad, revisión crítica | premium (`opus`) | Un fallo aquí se propaga a todo lo demás |
| Implementación, QA | estándar (`sonnet`) | El contrato acota el problema; no hace falta más |
| Scaffolding, documentación | económico (`haiku`) | Tarea mecánica y verificable |

Se aplica en tres sitios: `model` en `.claude/agents/*.md`, `--model` en los `claude_args` de los workflows, y `maxTurns` como tope duro por agente.

`maxTurns` es un **criterio de parada por coste**, no una sugerencia: un agente que se atasca consume presupuesto sin producir nada.

## Telemetría OpenTelemetry (fuente F2)

F1 da el coste de **una invocación**. Para agregar por WP, semana y agente, activa la telemetría del CLI:

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
export OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE=delta
export OTEL_METRICS_INCLUDE_RESOURCE_ATTRIBUTES=true
export OTEL_RESOURCE_ATTRIBUTES=fda.wp.id=WP-014
```

**Regla de configuración, que no es una recomendación.** **WP-010 versionará los parámetros estáticos no secretos** —activación de la telemetría, exportador, protocolo, temporality e inclusión de atributos de recurso— en el propio capturador o en la configuración del proyecto, de modo que sean reproducibles por un tercero. **Los secretos y los valores dependientes del entorno** —endpoint, credenciales, cabeceras— **se inyectan en ejecución**, conforme a [SEC-001](../../specs/requirements/SEC-001-sin-secretos.md): nunca se versionan.

El perfil personal del shell **no es fuente normativa ni configuración reproducible**: lo que solo existe en la máquina de alguien no existe para el sistema.

**`fda.wp.id=WP-XXX` se inyecta obligatoriamente en cada lanzamiento** y **nunca** se fija globalmente. Un `fda.wp.id` global etiquetaría con el WP equivocado la siguiente sesión que alguien abriera — la atribución silenciosa a otro WP que F2 existe para impedir.

**Para que F2 sostenga `medido` hacen falta todas estas condiciones** (DEC-004 §6). Si falla una, el estado baja a `estimado`:

| Condición | Por qué |
|---|---|
| Claude Code **≥ 2.1.214** | Por debajo, la telemetría de coste y tokens sobrecontaba en flujos con múltiples `message_delta` acumulativos |
| Temporality efectiva **`delta`** | Con `delta` se **suman** los puntos. Sumar puntos `cumulative` es doble conteo |
| `fda.wp.id=WP-XXX` en `OTEL_RESOURCE_ATTRIBUTES`, desde el lanzamiento | El WP-ID se declara, no se infiere |
| `OTEL_METRICS_INCLUDE_RESOURCE_ATTRIBUTES=true` | Sin esto el atributo no se emite |
| Suma de **`main` + `subagent` + `auxiliary`** | Filtrar por `main` subestima; esta fábrica usa subagentes por diseño |
| Importe no atribuible **igual a cero** | Cualquier importe no atribuible mayor que cero degrada el estado. No hay umbral tolerado |

**`session.id` no sustituye al WP-ID.** Es configurable, puede no emitirse, una sesión puede abarcar varios WPs y un WP varias sesiones. Dedicar la sesión a un solo WP es recomendable, pero **nunca** reemplaza el atributo explícito. La atribución retrospectiva por horario **nunca** produce `medido`.

> ⚠️ No metas credenciales de telemetría en `settings.json` si el archivo está versionado. Usa variables de entorno del sistema o `settings.local.json` (ignorado por git).

## Artefactos de captura

Cada `medido` va acompañado de un **extracto derivado y saneado** en `evidence/WP-XXX/`. Nunca se versiona el JSON crudo, los logs, los spans ni las cargas OTLP.

| | **Artefacto F1** | **Artefacto F2** |
|---|---|---|
| Unidad | una entrada **por invocación**, más la suma | puntos **`delta`** y agregación por `query_source` |
| Propios | índice · `total_cost_usd` de cada invocación · suma · `num_turns` · `duration_ms` · `subtype`/`is_error` | temporality · intervalo de exportación · ventana UTC · suma por `main`/`subagent`/`auxiliary` · importe no atribuible |
| Comunes | WP-ID declarado · identificador de sesión **en SHA-256, si la fuente lo emite** · modelos · tokens · marca UTC · instrumento y versión |

El identificador de sesión es **opcional** y **nunca** es clave de atribución: si la telemetría no lo emite, se omite sin más. La atribución es `fda.wp.id` en F2 y el argumento explícito del capturador en F1.

El artefacto **no lleva su propio SHA-256**: lo registra `cost.md`, junto con la ruta, el instrumento, el WP-ID y el método.

**Dos normas de higiene, que no son la misma:**

- **[SEC-001](../../specs/requirements/SEC-001-sin-secretos.md) ya prohíbe** credenciales, claves, tokens, cabeceras `Authorization` y endpoints con credencial en cualquier archivo de `evidence/**`.
- **DEC-004 §9 añade** la minimización de identidad: no se versionan correo, identificadores de usuario, cuenta u organización, tipo de terminal, endpoints, cabeceras, prompts, resultados, contenido de herramientas ni crudos OTel. **El identificador de sesión se registra como SHA-256, nunca en claro.** No son secretos: es que el repositorio es público y una evidencia de coste no los necesita.

Conservar el crudo fuera del repositorio es **opcional**. No es estado operativo obligatorio y no es fuente de verdad: la fuente de verdad es el artefacto saneado versionado.

## Las cuatro métricas que miras

| Métrica | Cómo se calcula | Qué te dice |
|---|---|---|
| **Coste por WP aceptado** | € totales del WP ÷ 1 (solo si se fusionó) | La métrica principal. Los WPs revertidos cuentan su coste y no cuentan como entregados |
| **% aceptado a la primera** | WPs sin ciclo de corrección ÷ WPs totales | Calidad de tus **contratos**, no del modelo. Bajo % = WPs mal escritos |
| **Ciclos de corrección medios** | Σ ciclos ÷ WPs aceptados | Objetivo ≤ 1,2. Si sube, revisa la redacción de criterios |
| **Regresiones por agente** | Fallos en producción atribuibles a un WP ÷ WPs de ese agente | El coste real de ir rápido |

### Cómo leerlas

- **Coste alto + aceptación alta** → los WPs son demasiado grandes. Trocea.
- **Coste bajo + aceptación baja** → los contratos son ambiguos. El agente adivina barato y falla.
- **Ciclos altos concentrados en un tipo de WP** → falta un ADR o un requisito en esa área.
- **Regresiones con CI en verde** → el problema es la cobertura de la verificación, no el agente.

## Inventario semanal

Estos comandos **listan; no agregan ni validan**. `grep` no suma importes, y no comprueba que un `excepcion:` resuelva contra el registro versionado — registro que, además, no existirá hasta WP-010.

```bash
# Inventario de costes registrados (registro USD)
grep -h '^coste_usd:' evidence/*/cost.md

# Reparto de estados
grep -h '^estado_coste:' evidence/*/cost.md | sort | uniq -c

# WPs sin cifra: para cerrar cada uno hace falta una excepción versionada
grep -l '^estado_coste: no_disponible' evidence/*/cost.md

# WPs aceptados a la primera
grep -l "Aceptado a la primera | sí" evidence/*/cost.md | wc -l
```

Anota la conclusión en `specs/decisions/` si cambias algo de la política. Una decisión que solo existe en tu cabeza no es una decisión del sistema.

## Relación con el harness SDK

Estas métricas son las que disparan la activación del harness sobre Claude Agent SDK. Los umbrales concretos —y su estado de aprobación— están en [ADR-001](../../specs/adr/ADR-001-runtime.md).
