# Coste — Paso 0 de la Fase 1

Formato según [`DEC-001`](../../../specs/decisions/DEC-001-divisa-costes.md).

```
coste_usd: TODO-COSTE       # ejecuta /cost en la sesión y anótalo aquí
tipo_eurusd: 1.1383         # specs/finops/fx-rates.md → 2026-07
fuente: BCE ref. 2026-07-01
coste_eur: TODO-CALCULAR    # coste_usd / 1.1383
presupuesto_eur: 75
consumo: TODO-CALCULAR
```

| Concepto | Valor |
|---|---|
| Coste total (registro, USD) | ⏸ **pendiente** de `/cost` |
| Coste total (gobierno, EUR) | ⏸ pendiente |
| Presupuesto | 75,00 € (umbral objetivo por WP) |
| Sesión | 2.ª de WP-000 (la 1.ª fue el bootstrap de Fase 0: 15,14 USD / 13,30 €) |
| Ciclos de corrección | 0 / 2 |
| Modelo principal | Opus 4.8 (`claude-opus-4-8`) |

## Por qué está pendiente

`/cost` es un comando de la sesión interactiva de Claude Code. **Un agente no puede ejecutarlo ni leer su salida desde dentro de la propia sesión.** Anotar una cifra estimada contaminaría la primera medición real de la métrica principal de la FDA, que es precisamente lo que la Fase 1 va a calibrar.

Para completarlo, escribe `/cost` en la sesión y sustituye los tres `TODO-`.

## Acumulado de WP-000

WP-000 abarca el bootstrap completo de la Fase 0 más este Paso 0. Al cerrarlo, el coste total es la suma de ambas sesiones:

| Sesión | Alcance | USD | EUR (tipo 2026-07) |
|---|---|---|---|
| 1 | Bootstrap de la Fase 0 | 15,14 | 13,30 |
| 2 | Paso 0 de la Fase 1 | TODO | TODO |
| **Total** | | **TODO** | **TODO** |

## Nota para la calibración

Igual que la primera, **esta sesión no es representativa** y no debe entrar en la media de «coste por WP aceptado»:

1. Es preparación de la fábrica, no uso de la fábrica.
2. Incluyó cinco ciclos de depuración contra el CI real y cinco *hand-offs* manuales por denegación de permisos — trabajo que no se repetirá en los WPs de calibración.
3. Incluyó decisiones de gobierno (divisa, ADR, visibilidad del repositorio) que se toman una sola vez.

**La línea base empieza en WP-001.** Con n=5 se lee la tendencia, no el valor.
