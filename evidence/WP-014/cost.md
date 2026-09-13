# Coste — WP-014

Formato según DEC-001 (divisa) y DEC-004 (estados y adquisición).

```text
estado_coste: medido
coste_usd: 3.1601409
fuente_coste: F1
fecha_medicion: 2026-09-13
operador: Iván (operador humano; atestación versionada)
instrumento: claude-code 2.1.220
wp_id: WP-014
artefacto: evidence/WP-014/coste-f1.md
artefacto_sha256: a9c9c8e265bc62b2c8a97b1981f9dd488046ed6626f09887ae56c9f079531b45
tipo_eurusd: 1.1590
fuente: BCE ref. 2026-09-01
coste_eur: 2.73
presupuesto_eur: 12
consumo: 23 %
```

| Concepto | Valor |
|---|---:|
| Coste total registrado | 3,1601409 USD |
| Coste de gobierno | 2,73 EUR |
| Presupuesto máximo | 12,00 EUR |
| Consumo | 23 % |
| Invocaciones F1 agregadas | 2 |
| Ciclos de corrección | 1 / 2 |
| Modelo principal | claude-sonnet-5 |

La conversión usa el tipo mensual congelado de septiembre de 2026:
`3.1601409 / 1.1590 = 2.72660992`, redondeado a 2,73 EUR. El coste está dentro
del presupuesto contractual. El artefacto asociado es un extracto derivado y
saneado; no se versiona el JSON crudo.

La comprobación y atestación del operador humano están registradas en
`evidence/WP-014/atestacion-coste.md`. Codex compiló el extracto técnico F1,
pero no figura como operador del registro.
