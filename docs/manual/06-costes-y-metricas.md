[← Manual](MANUAL.md)

# 06 — Costes y métricas

**Métrica principal: coste por WP integrado y aceptado.** No coste por sesión, ni por token, ni por hora. Un WP que costó 40 € pero necesitó tres ciclos y acabó revertido costó mucho más de 40 €.

> Los **primeros 5 WPs son calibración**. No saques conclusiones con n=1: medirás la curva de aprendizaje del sistema, no su rendimiento.

## Registrar el coste de un WP

### 1. Obtener el coste de la sesión

En Claude Code:

```
/cost
```

En CI, el coste sale del resumen de ejecución de `claude-code-action`.

### 2. Volcarlo a `evidence/WP-XXX/cost.md`

Un archivo por WP, versionado. Formato:

```markdown
# Coste — WP-014

| Concepto | Valor |
|---|---|
| Coste total | 38,20 € |
| Presupuesto del WP | 75,00 € |
| Consumo sobre presupuesto | 51 % |
| Sesiones | 2 |
| Ciclos de corrección | 1 / 2 |
| Modelo principal | sonnet |
| Aceptado a la primera | no |

## Desglose por sesión

| Sesión | Fecha | Agente | Modelo | Coste |
|---|---|---|---|---|
| 1 | 2026-07-20 | implementer | sonnet | 24,10 € |
| 2 | 2026-07-21 | implementer (correcciones) | sonnet | 9,40 € |
| 3 | 2026-07-21 | code-reviewer | opus | 4,70 € |

## Notas

El ciclo de corrección vino de un criterio de aceptación ambiguo sobre el
importe cero. Causa raíz: contrato, no implementación.
```

Ese último apartado es el que hace útil el registro. Un número sin causa no mejora nada.

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

## Telemetría OpenTelemetry (agregación)

`/cost` da el dato de una sesión. Para agregar por WP, semana y agente, activa la telemetría del CLI:

```bash
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=grpc
export OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
```

Para que sea persistente, ponlo en `.claude/settings.json` bajo `env`, o en el perfil de tu shell. Vuélcalo donde ya midas el resto.

> ⚠️ No metas credenciales de telemetría en `settings.json` si el archivo está versionado. Usa variables de entorno del sistema o `settings.local.json` (ignorado por git).

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

## Revisión semanal

```bash
# Coste agregado de todos los WPs registrados
grep -h "Coste total" evidence/*/cost.md

# WPs aceptados a la primera
grep -l "Aceptado a la primera | sí" evidence/*/cost.md | wc -l
```

Anota la conclusión en `specs/decisions/` si cambias algo de la política. Una decisión que solo existe en tu cabeza no es una decisión del sistema.

## Relación con el harness SDK

Estas métricas son las que disparan la activación del harness sobre Claude Agent SDK. Los umbrales concretos —y su estado de aprobación— están en [ADR-001](../../specs/adr/ADR-001-runtime.md).
