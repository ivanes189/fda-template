# Coste — Paso 0 de la Fase 1

Formato según [`DEC-001`](../../../specs/decisions/DEC-001-divisa-costes.md).

```
coste_usd: 31.03            # crudo, inmutable
tipo_eurusd: 1.1383         # specs/finops/fx-rates.md → 2026-07
fuente: BCE ref. 2026-07-01
coste_eur: 27.26
presupuesto_eur: 75
consumo: 36 %
```

Medición: `/cost` el 2026-07-23T15:08:46Z.

| Concepto | Valor |
|---|---|
| Coste total (registro) | **$31,03 USD** |
| Coste total (gobierno) | **27,26 €** |
| Presupuesto | 75,00 € (umbral objetivo por WP) |
| Consumo sobre presupuesto | 36 % |
| Ciclos de corrección | 0 / 2 |
| Modelo principal | Opus 4.8 (`claude-opus-4-8`) |
| Tiempo de API | 33 min |
| Tiempo total (reloj) | 43 min |

## Consumo de tokens

| Concepto | Cantidad |
|---|---|
| Entrada (sin caché) | 986 |
| Salida | 4.900 |
| Lectura de caché | 140.700.000 |
| Escritura de caché | 3.200.000 |

**140,7 M de tokens leídos de caché frente a 986 de entrada real.** La proporción confirma lo observado en la sesión de bootstrap: el coste de una sesión agéntica larga lo domina la relectura de contexto cacheado, no el texto nuevo. Refuerza el diseño «un WP = una rama = una sesión».

## Consumo de plan

| Límite | Consumido |
|---|---|
| Sesión | 16 % (ventana reiniciada a las 14:29Z) |
| Semanal (todos los modelos) | 11 % |

## ⚠️ Ambigüedad en el acumulado de WP-000

Los dos informes de `/cost` de WP-000 son **mutuamente inconsistentes** sobre si la cifra es acumulada o por ventana:

| Métrica | Informe 1 (13:02Z) | Informe 2 (15:08Z) | Qué sugiere |
|---|---|---|---|
| Coste | 15,14 $ | 31,03 $ | acumulado (≈ ×2) |
| Lectura de caché | 36,6 M | 140,7 M | acumulado |
| Tiempo de API | 44 min | **33 min** | **por ventana** |
| Ventana de sesión | 55 %, reset 14:29Z | 16 %, reset 19:29Z | la ventana se reinició en medio |

El coste y los tokens crecen como si fueran acumulados; los tiempos **decrecen**, que solo tiene sentido si son por ventana. No se puede resolver desde dentro de la sesión.

Conforme a DEC-001 —el USD crudo es el registro inmutable y no se infiere—, **no se elige una lectura**. Las dos posibilidades para el total de WP-000:

| Lectura | USD | EUR (tipo 2026-07) |
|---|---|---|
| **A — las cifras son por sesión** (se suman) | 46,17 | 40,56 |
| **B — la segunda ya incluye la primera** | 31,03 | 27,26 |

En ambos casos WP-000 queda **por debajo del umbral de 75 €**, así que la ambigüedad no afecta a ninguna decisión de gobierno. Sí afecta a la línea base de la métrica técnica, y conviene resolverla antes de cerrar la Fase 1 —por ejemplo, anotando el coste al inicio y al final de cada sesión de WP-001.

## Nota para la calibración

**Esta sesión no es representativa** y no debe entrar en la media de «coste por WP aceptado»:

1. Es preparación de la fábrica, no uso de la fábrica.
2. Incluyó cinco ciclos de depuración contra el CI real y seis *hand-offs* manuales por denegación de permisos — trabajo que no se repetirá.
3. Incluyó decisiones de gobierno de una sola vez: divisa, criterios del ADR, visibilidad del repositorio, anonimización del historial.
4. Los cinco defectos encontrados por los linters se pagaron aquí y no volverán a pagarse.

**La línea base empieza en WP-001**, cuyo presupuesto es 10 € — dos órdenes de magnitud por debajo de esta sesión, precisamente porque el trabajo es otro.
