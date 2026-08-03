# Tipos de cambio EUR/USD — registro append-only

Un tipo por mes natural. Rige la conversión de **todos** los costes de WPs cerrados en ese mes.

Convención definida en [`specs/decisions/DEC-001-divisa-costes.md`](../decisions/DEC-001-divisa-costes.md).

## Reglas de este archivo

1. **Append-only.** Se añaden líneas al final. **Nunca** se modifica ni se borra una línea existente: hacerlo alteraría costes ya registrados y rompería la auditabilidad.
2. **Una línea por mes natural.** Se añade el primer día hábil del mes.
3. **Fuente:** tipo de referencia diario EUR/USD del **BCE**, del primer día hábil del mes.
4. El tipo se expresa como **USD por 1 EUR** (p. ej. `1.1383` = 1 € vale 1,1383 $).
5. Conversión: `coste_eur = coste_usd / tipo_eurusd`.

## Cómo obtener el tipo del mes

```bash
# Sustituye AAAA-MM-DD por el primer día hábil del mes
curl -s "https://api.frankfurter.dev/v1/2026-07-01?base=EUR&symbols=USD"
```

Si la fecha solicitada no es día hábil, la API devuelve el dato del día hábil anterior disponible; usa **la fecha que devuelve la respuesta**, no la que pediste, y anótala en la columna «Fecha BCE».

## Registro

| Mes | Tipo EUR/USD | Fecha BCE | Fuente | Añadido |
|---|---|---|---|---|
| 2026-07 | 1.1383 | 2026-07-01 | BCE vía frankfurter.dev | 2026-07-23 |
| 2026-08 | 1.1535 | 2026-08-03 | BCE — eurofxref-daily (corrob. frankfurter.dev) | 2026-08-03 |

<!--
Formato de nuevas entradas (añadir al final de la tabla, nunca en medio):
| AAAA-MM | X.XXXX | AAAA-MM-DD | BCE vía frankfurter.dev | AAAA-MM-DD |
-->

## Notas

**2026-07** — Primera entrada del registro. El 1 de julio de 2026 fue día hábil y el BCE publicó referencia, así que la fecha solicitada y la devuelta coinciden. Este tipo rige WP-000 (conversión reconstruida) y todos los WPs de calibración de la Fase 1 que se cierren en julio de 2026.
