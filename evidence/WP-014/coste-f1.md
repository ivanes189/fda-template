# WP-014 — Extracto saneado de coste F1

Fuente: mensaje `result` estructurado de la invocación headless de Claude Code
usada expresamente para ejecutar WP-014. Este extracto omite prompt, resultado,
contenido de herramientas, datos personales, cabeceras, endpoints y cualquier
otro contenido no necesario para gobernar el coste.

```text
wp_id: WP-014
fuente_coste: F1
instrumento: claude-code 2.1.220
capturado_utc: 2026-09-13T20:23:22Z
session_id_sha256: 0ae105163dcdd6271d678d924b53f1abd20de004b6697f6ffb5b847de438b6ae
invocaciones: 1

invocacion_1:
  total_cost_usd: 2.5364507
  num_turns: 58
  duration_ms: 531468
  subtype: success
  is_error: false
  modelos:
    - claude-sonnet-5
    - claude-haiku-4-5
  tokens_claude_sonnet_5:
    input: 90
    cache_creation_input: 121002
    cache_read_input: 3604179
    output: 48529
  tokens_claude_haiku_4_5:
    input: 870
    cache_creation_input: 0
    cache_read_input: 0
    output: 22

total_cost_usd: 2.5364507
```

El valor es una estimación del cliente por invocación, no facturación
autoritaria. La suma coincide con `total_cost_usd` del resultado F1 y comprende
el uso de los modelos declarado por esa misma salida.
