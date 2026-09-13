# Coste — WP-013

estado_coste: estimado
causa: las capturas F1 no aportan la marca UTC de inicio por invocacion exigida por DEC-004 §8
coste_usd: 19.2492275
fuente_coste: F1
base_estimacion: suma de total_cost_usd de las cuatro invocaciones F1 con consumo de WP-013; la invocacion HTTP 429 tuvo coste cero
fecha_medicion: 2026-09-13
operador: @ivanes189
instrumento: claude-code 2.1.220
wp_id: WP-013
artefacto: evidence/WP-013/coste-f1.md
artefacto_sha256: 7bf58225d85b3268757c11a23908dc80650aa1f6d2e7bbb2eed3c91941c413d8
tipo_eurusd: 1.1590
fuente: BCE, referencia 2026-09-01
coste_eur: 16.6085
presupuesto_eur: 20
consumo: 83.0%

## Calculo

`(10.6594451 + 8.5897824) USD / 1.1590 = 16.6085 EUR`, redondeado a
cuatro decimales solo al final. C3 consumió `7.4114 EUR`, dentro de su máximo
adicional de 10 EUR. El acumulado queda dentro del máximo contractual de 20 EUR.

La clasificación `estimado` describe una captura instrumental F1 incompleta;
no convierte la cifra en una estimación de memoria ni oculta la invocación sin
coste que terminó con HTTP 429.
