# Coste — WP-014

Formato según DEC-001 (divisa) y DEC-004 (estados y adquisición).

```text
estado_coste: medido
coste_usd: 2.5364507
fuente_coste: F1
fecha_medicion: 2026-09-13
operador: Codex (coordinador, captura F1)
instrumento: claude-code 2.1.220
wp_id: WP-014
artefacto: evidence/WP-014/coste-f1.md
artefacto_sha256: f3dba4f1e712bca838418d64baae4715e4bdacd9b168778d6dc582bf9efdfba3
tipo_eurusd: 1.1590
fuente: BCE ref. 2026-09-01
coste_eur: 2.19
presupuesto_eur: 12
consumo: 18 %
```

| Concepto | Valor |
|---|---:|
| Coste total registrado | 2,5364507 USD |
| Coste de gobierno | 2,19 EUR |
| Presupuesto máximo | 12,00 EUR |
| Consumo | 18 % |
| Invocaciones F1 agregadas | 1 |
| Ciclos de corrección | 0 / 2 |
| Modelo principal | claude-sonnet-5 |

La conversión usa el tipo mensual congelado de septiembre de 2026:
`2.5364507 / 1.1590 = 2.18848205`, redondeado a 2,19 EUR. El coste está dentro
del presupuesto contractual. El artefacto asociado es un extracto derivado y
saneado; no se versiona el JSON crudo.
