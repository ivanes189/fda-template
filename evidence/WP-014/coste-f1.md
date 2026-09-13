# WP-014 — Extracto saneado de coste F1

Fuente: mensaje `result` estructurado de la invocación headless de Claude Code
usada expresamente para ejecutar WP-014. Este extracto omite prompt, resultado,
contenido de herramientas, datos personales, cabeceras, endpoints y cualquier
otro contenido no necesario para gobernar el coste.

```text
wp_id: WP-014
fuente_coste: F1
instrumento: claude-code 2.1.220
captura_1_utc: 2026-09-13T20:23:22Z
invocaciones: 2

invocacion_1:
  session_id_sha256: 0ae105163dcdd6271d678d924b53f1abd20de004b6697f6ffb5b847de438b6ae
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

captura_2_utc: 2026-09-13T20:46:43Z
invocacion_2:
  session_id_sha256: 17dd0adb5b485af25dc3f6360c1d580fc19744405a3f080c786c340244e7c967
  total_cost_usd: 0.6236902
  num_turns: 43
  duration_ms: 145683
  subtype: success
  is_error: false
  modelos:
    - claude-sonnet-5
    - claude-haiku-4-5
  tokens_claude_sonnet_5:
    input: 42
    cache_creation_input: 40476
    cache_read_input: 722044
    output: 10869
  tokens_claude_haiku_4_5:
    input: 935
    cache_creation_input: 0
    cache_read_input: 0
    output: 25

total_cost_usd: 3.1601409
```

El valor es una estimación del cliente por invocación, no facturación
autoritaria. La suma coincide con `total_cost_usd` del resultado F1 y comprende
el uso de los modelos declarado por esa misma salida.
