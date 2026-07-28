# Coste — WP-006

Formato según [`DEC-001`](../../specs/decisions/DEC-001-divisa-costes.md).

```
coste_usd: TODO-COSTE       # ejecuta /cost al cerrar y anótalo aquí
tipo_eurusd: 1.1383         # specs/finops/fx-rates.md → 2026-07
fuente: BCE ref. 2026-07-01
coste_eur: TODO-CALCULAR    # coste_usd / 1.1383
presupuesto_eur: 25
consumo: TODO-CALCULAR
```

| Concepto | Valor |
|---|---|
| Coste total (registro, USD) | ⏸ pendiente de `/cost` |
| Presupuesto | 25,00 € |
| Ciclos de corrección | 0 / 2 |
| Modelo principal | Opus 4.8 (`claude-opus-4-8`) |

## Medición pendiente

`/cost` es un comando de la sesión interactiva y no puede invocarlo un agente desde dentro de la propia sesión. Se anota al cerrar el WP.

## Nota metodológica: resolver la ambigüedad acumulado/ventana

`evidence/WP-000/fase1-prep/cost.md` dejó abierta una contradicción: coste y tokens crecían como si las cifras fueran acumuladas, pero el tiempo de API decrecía, lo que solo tiene sentido si son por ventana de sesión.

**WP-006 es la primera oportunidad de zanjarlo con datos**, porque es un WP corto y acotado. Procedimiento:

1. Anotar `/cost` **al empezar** el WP (valor V0).
2. Anotar `/cost` **al cerrarlo** (valor V1).
3. Si `V1 − V0` se aproxima al trabajo real de este WP → las cifras son **acumuladas**.
4. Si `V1` por sí solo se aproxima a ese trabajo → son **por ventana**.

Anotar aquí la conclusión, y trasladarla a `docs/manual/06-costes-y-metricas.md` como método estándar de medición por WP.

| Momento | Valor `/cost` |
|---|---|
| V0 (inicio de WP-006) | no registrado — el WP surgió como reparación urgente, sin medición previa |
| V1 (cierre de WP-006) | ⏸ pendiente |

> V0 se perdió porque WP-006 nació de una incidencia, no de una planificación. Es en sí mismo un dato de calibración: **los WPs reactivos escapan a la instrumentación** salvo que medir al inicio sea un paso obligatorio del ciclo. Para WP-001, que sí está planificado, V0 se registrará antes de activar.

## Nota para la calibración

WP-006 **no entra** en la media de «coste por WP aceptado»: es mantenimiento del propio gobierno, no uso de la fábrica. Su valor está en las métricas de fiabilidad —cuántos defectos encuentra el sistema sobre sí mismo—, no en las de rendimiento.
