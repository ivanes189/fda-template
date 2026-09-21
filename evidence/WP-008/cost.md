# Coste — WP-008 D6-A

Formato según DEC-001 y DEC-004.

```text
estado_coste: medido
coste_usd: 41.9783256
fuente_coste: F1
fecha_medicion: 2026-09-15
operador: Iván (operador humano; atestación versionada)
instrumento: claude-code 2.1.220 y 2.1.272
wp_id: WP-008
artefacto: evidence/WP-008/coste-f1.md
artefacto_sha256: ca8757d2c3f60aa3a01a1a410c7a0f6c15fe12a59aa87f9d7ea07223d178c41b
tipo_eurusd: 1.1590
fuente: BCE ref. 2026-09-01
coste_eur: 36.22
presupuesto_eur: 40
consumo: 90.5 %
```

| Concepto | Valor |
|---|---:|
| Coste total registrado | 41.9783256 USD |
| Coste de gobierno | 36.22 EUR |
| Presupuesto máximo | 40 EUR |
| Consumo | 90.5 % |
| Invocaciones F1 agregadas | 15 |
| Ciclos de corrección | 5 / 2 |

Las quince invocaciones F1 suman `41.9783256 USD`; se incluyen las que
terminaron con error y las cuatro fases de los dos intentos de humo. La
conversión es `41.9783256 / 1.1590 = 36.2194354 EUR`, redondeada a `36.22 EUR`
solo al final. C5 suma `6.1255166 USD = 5.29 EUR`, dentro de sus `6 EUR`. El A/B
final no se ejecutó y no genera coste. C1 y C2 fueron ordinarios; C3, C4 y C5
fueron excepciones humanas expresas; C6 no está autorizado.

El artefacto es un extracto derivado y saneado, no facturación autoritativa. La
atestación humana se conserva en `evidence/WP-008/atestacion-coste.md`.
