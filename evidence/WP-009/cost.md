# Coste de cierre — WP-009

estado_coste: estimado
causa: captura F1 agregada incompleta; la invocación 1 no contiene modelos ni recuentos de tokens exigidos por DEC-004 §8
coste_usd: 45.6189187
fuente_coste: F1
base_estimacion: suma de total_cost_usd de las siete invocaciones F1 preservadas
fecha_medicion: 2026-09-13
operador: @ivanes189
instrumento: claude-code 2.1.220
wp_id: WP-009
artefacto: evidence/WP-009/coste-f1.md
artefacto_sha256: 4fbb0f5f70c0e65606f8e4a734b996d0737f576e2a2944813f526979aac855ba
tipo_eurusd: 1.1590
fuente: BCE, referencia 2026-09-01
coste_eur: 39.3606
presupuesto_eur: 43
consumo: 91.5%

## Cálculo

`45.6189187 USD / 1.1590 = 39.3606 EUR` (redondeo final a cuatro
decimales). El importe queda por debajo del máximo contractual de 43 EUR. La
clasificación es `estimado`, no `medido`, porque la captura agregada carece de
campos obligatorios en una de sus siete invocaciones; el total numérico no se
rellena ni se altera para ocultar esa carencia.
