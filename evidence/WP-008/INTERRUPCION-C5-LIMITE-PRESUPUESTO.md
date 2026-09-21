# WP-008 — Interrupción definitiva de C5 antes del A/B

```text
wp_id: WP-008
fecha_utc: 2026-09-15T21:26:41Z
ciclo: C5 excepcional (5 / 2)
head_intacto: 39d298e794ac9c8f46d864725d529993f12509d0
invocacion_claude: 15
subtype: error_max_turns
is_error: true
coste_invocacion_usd: 0.5192944
coste_c5_acumulado_usd: 6.1255166
coste_c5_provisional_eur: 5.29
presupuesto_c5_max_eur: 6
reserva_a_b_usd: 0.60
resultado: DETENER; PREPARAR CIERRE BLOCKED; SIN C6
```

## Hecho verificable

Tras el veredicto `NO APTO` de
`revision-astra-enfocada-c5-correccion-2.md`, Sol lanzó una corrección mínima
con Claude Code, máximo `0.70 USD` y veinte turnos. La invocación terminó por
`error_max_turns` en 21 turnos, consumió `0.5192944 USD` y no modificó ningún
archivo: el worktree quedó limpio en `39d298e`.

C5 acumula `5.29 EUR`; quedan `0.71 EUR`. El único A/B contractual requiere
reservar hasta `0.60 USD` (`0.52 EUR`). El margen restante después de esa
reserva es aproximadamente `0.19 EUR`, insuficiente para otra ejecución de
Claude y sin autorización para ampliar presupuesto.

## Estado técnico

- El ALTO de cancelación mediante texto fabricado está cerrado en `0776010`.
- Permanece abierto el MEDIO reproducido por Astra: una lista dentro de
  `tool_use_result.content` puede declarar id ajeno y colapsar indebidamente.
- Las dos regresiones de cancelación no reproducen todavía la clave dinámica
  real y no detectan la mutación original.
- El candidato no es apto para humo real. El A/B final no se ejecutó.
- Los protegidos conservan sus huellas y no se modificaron en C5.

## Parada

No se lanza otra invocación, no se abre C6, no se ejecuta el A/B, no se publica
la rama y no se cambia `ACTIVE`. Conforme a la autorización humana C5, Sol
prepara fuera del repositorio el cierre `blocked`, preservando íntegramente la
candidata para diagnóstico.
