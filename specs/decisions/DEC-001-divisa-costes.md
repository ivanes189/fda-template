# DEC-001 — Convención de divisa para el registro de costes

**Estado:** aceptada · **Fecha:** 2026-07-23 · **Ámbito:** todos los proyectos que instalen `fda-template`
**Origen:** `FDA-diagnostico-y-plan-fase1.md` §2.1 (decisión D1), aprobada por el responsable.

## Problema

Claude Code reporta el coste de sesión en **USD**. Los presupuestos de la FDA están definidos en **EUR** (75 / 100 / 150 € por WP; 750 €/mes). Mezclar ambas divisas sin convención produce tres fallos: comparaciones inválidas entre WPs, presupuestos que se cumplen o se incumplen según el día, y un histórico irreproducible cuando alguien recalcula con el tipo de hoy.

## Decisión

**«USD es el registro, EUR es el gobierno, el tipo se congela.»**

### 1. Moneda de registro (fuente de verdad): USD

El valor crudo que devuelve `/cost`. Se almacena **siempre** y **nunca se modifica**. Es el dato auditable.

### 2. Moneda de gobierno: EUR

Presupuestos, avisos y límites permanecen en euros:

| Umbral | Valor |
|---|---|
| Objetivo por WP | 75 € |
| Aviso por WP | 100 € |
| Aprobación por WP | 150 € |
| Aviso mensual | 750 € |

### 3. Tipo de cambio: referencia diaria EUR/USD del BCE

Fuente oficial, gratuita, con histórico público auditable. Consultable vía `frankfurter.dev`, que expone los datos del BCE:

```bash
curl -s "https://api.frankfurter.dev/v1/AAAA-MM-DD?base=EUR&symbols=USD"
```

### 4. Congelación: un tipo por mes natural

Se usa el tipo de referencia del BCE del **primer día hábil del mes**, registrado en [`specs/finops/fx-rates.md`](../finops/fx-rates.md) — archivo **append-only**, una línea por mes con tipo, fecha y fuente.

Todos los WPs cerrados en ese mes convierten con ese tipo. **Nunca se recalcula retrospectivamente:** una variación posterior del cambio no altera costes ya registrados.

### 5. Comparación durante la ejecución

El agente compara `coste_usd_actual × tipo_del_mes` contra `presupuesto_max_eur`. Determinista y **sin red**: el tipo ya está en el repositorio.

### 6. Registro por WP

En `evidence/WP-XXX/cost.md`, con este bloque exacto:

```markdown
coste_usd: 12.40          # crudo, inmutable
tipo_eurusd: 1.0850       # specs/finops/fx-rates.md → 2026-08
fuente: BCE ref. 2026-08-03
coste_eur: 11.43
presupuesto_eur: 40
consumo: 29 %
```

`coste_eur = coste_usd / tipo_eurusd` (el tipo se expresa como USD por 1 EUR).

### 7. Agregación mensual

Suma de `coste_eur` de todos los WPs cerrados en el mes —todos con el mismo tipo, luego coherente— contra el límite de 750 €.

### 8. Comparación histórica: dos vistas

| Vista | Divisa | Para qué |
|---|---|---|
| **Contable** | EUR congelado | Gobierno de presupuesto, agregación mensual, cumplimiento de umbrales |
| **Técnica** | USD crudo | Comparar eficiencia entre WPs y entre periodos |

La vista técnica es **la correcta para métricas**: elimina el ruido cambiario. Un WP que costó lo mismo en USD costó lo mismo en trabajo, aunque el euro se moviera.

## Consecuencias

**A favor:** auditable (fuente, fecha y valor original quedan registrados); inmutable (el histórico no cambia bajo los pies); la conversión está definida en un único sitio; el agente no necesita red para comprobar su presupuesto.

**En contra:** el tipo congelado se desvía del real dentro del mes. Aceptado: la alternativa —tipo diario— haría que dos WPs idénticos consumieran presupuestos distintos por el día en que se cerraron, que es peor para gobernar.

**Mantenimiento:** el primer día hábil de cada mes hay que añadir una línea a `fx-rates.md`. Si falta la del mes en curso, el registro de coste queda bloqueado hasta añadirla — es intencionado: es preferible parar a inventar un tipo.

## Aplicación retroactiva

**WP-000** (bootstrap, 15,14 USD) recibe conversión con el tipo del mes en curso, anotada explícitamente como **reconstruida**. Ver `evidence/WP-000/cost.md`.

## Referencias

- `FDA-diagnostico-y-plan-fase1.md` §2.1
- [`specs/finops/fx-rates.md`](../finops/fx-rates.md) — registro append-only de tipos
- [`docs/manual/06-costes-y-metricas.md`](../../docs/manual/06-costes-y-metricas.md) — operativa
