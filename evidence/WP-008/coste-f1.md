# WP-008 — Extracto saneado de coste F1

Fuente: mensaje `result` estructurado de la invocación headless de Claude Code
usada para la implementación inicial C0 de WP-008 D6-A. Este extracto omite
prompt, resultado, cargas de herramientas, datos personales, cabeceras,
endpoints y cualquier contenido innecesario para gobernar el coste.

```text
wp_id: WP-008
fuente_coste: F1
instrumento: claude-code 2.1.220; C5 ejecutada con 2.1.272
captura_1_utc: 2026-09-14T17:29:19Z
invocaciones: 15

invocacion_1:
  fase: implementacion_inicial_C0
  session_id_sha256: b1505d2c06a67308177db589f021910ca45839189d4097566d21abb5a7a7e64d
  total_cost_usd: 11.5487715
  num_turns: 146
  duration_ms: 1468313
  subtype: success
  is_error: false
  modelos:
    - claude-sonnet-5
    - claude-haiku-4-5
  tokens_claude_sonnet_5:
    input: 250
    cache_creation_input: 287205
    cache_read_input: 25463595
    output: 145600
  tokens_claude_haiku_4_5:
    input: 1588
    cache_creation_input: 0
    cache_read_input: 0
    output: 25

captura_2_utc: 2026-09-14T18:00:18Z
invocacion_2:
  fase: correccion_C1_interrumpida_por_limite_plataforma
  session_id_sha256: bf1b02675546beb515a2dd8a87c1573e882799fa3a9ea62e0c00fe5d6cac8c91
  total_cost_usd: 2.6959661
  num_turns: 34
  duration_ms: 764449
  subtype: success
  is_error: true
  terminal_reason: api_error
  api_error_status: 429
  modelos:
    - claude-sonnet-5
    - claude-haiku-4-5
  tokens_claude_sonnet_5:
    input: 54
    cache_creation_input: 134741
    cache_read_input: 2577237
    output: 74147
  tokens_claude_haiku_4_5:
    input: 1857
    cache_creation_input: 0
    cache_read_input: 0
    output: 25

captura_3_utc: 2026-09-15T11:06:23Z
invocacion_3:
  fase: correccion_C1_reanudada_y_completada
  session_id_sha256: 361a40becd5152d60919f363877d822c2122a7bf9cfe33705a3b1b02e033afd1
  total_cost_usd: 5.2061050
  num_turns: 73
  duration_ms: 1067905
  subtype: success
  is_error: false
  modelos:
    - claude-sonnet-5
    - claude-haiku-4-5
  tokens_claude_sonnet_5:
    input: 132
    cache_creation_input: 184839
    cache_read_input: 8956740
    output: 93860
  tokens_claude_haiku_4_5:
    input: 1603
    cache_creation_input: 0
    cache_read_input: 0
    output: 30

captura_4_utc: 2026-09-15T11:41:53Z
invocacion_4:
  fase: correccion_C2_completada
  session_id_sha256: 46a763eba29354b9814835c68c64ca032cf459c5ad91b2f85b8ee9515514079f
  total_cost_usd: 10.1214120
  num_turns: 117
  duration_ms: 1381824
  subtype: success
  is_error: false
  modelos:
    - claude-sonnet-5
    - claude-haiku-4-5
  tokens_claude_sonnet_5:
    input: 228
    cache_creation_input: 281342
    cache_read_input: 21683390
    output: 128352
  tokens_claude_haiku_4_5:
    input: 2239
    cache_creation_input: 0
    cache_read_input: 0
    output: 28

captura_5_utc: 2026-09-15T12:03:06Z
invocacion_5:
  fase: correccion_excepcional_C3_completada
  session_id_sha256: 755980a575ded7c4ca9dcbc8b67fc40abe668e07cb08f553dafb350a2ea6009e
  total_cost_usd: 3.3772883
  num_turns: 50
  duration_ms: 460476
  subtype: success
  is_error: false
  modelos:
    - claude-sonnet-5
    - claude-haiku-4-5
  tokens_claude_sonnet_5:
    input: 78
    cache_creation_input: 182638
    cache_read_input: 5465031
    output: 42627
  tokens_claude_haiku_4_5:
    input: 2162
    cache_creation_input: 0
    cache_read_input: 0
    output: 30

captura_6_utc: 2026-09-15T12:17:49Z
invocacion_6:
  fase: humo_real_control_intento_1_inconcluso
  session_id_sha256: fa8b9b8136f08052923c93982c267cf750a4d6b35ee289f63ca40c2828364063
  total_cost_usd: 0.0426595
  num_turns: 2
  duration_ms: 3029
  subtype: success
  is_error: false
  modelos:
    - claude-haiku-4-5-20251001
    - claude-sonnet-5
  tokens_claude_haiku_4_5:
    input: 548
    cache_creation_input: 0
    cache_read_input: 0
    output: 13
  tokens_claude_sonnet_5:
    input: 4
    cache_creation_input: 5906
    cache_read_input: 14645
    output: 147

captura_7_utc: 2026-09-15T12:17:49Z
invocacion_7:
  fase: humo_real_tratamiento_intento_1_inconcluso
  session_id_sha256: 958d24bb6adffdcb77d21af8d3c6d866cc7734c0f4d07693871d830347b13ed5
  total_cost_usd: 0.0111976
  num_turns: 2
  duration_ms: 6390
  subtype: success
  is_error: false
  modelos:
    - claude-haiku-4-5-20251001
    - claude-sonnet-5
  tokens_claude_haiku_4_5:
    input: 548
    cache_creation_input: 0
    cache_read_input: 0
    output: 16
  tokens_claude_sonnet_5:
    input: 4
    cache_creation_input: 248
    cache_read_input: 20332
    output: 198

captura_8_utc: 2026-09-15T12:41:15Z
invocacion_8:
  fase: correccion_excepcional_C4_interrumpida_por_limite_de_sesion
  session_id_sha256: 4f89cef20f6d39a7df48227f5dfb05057f632793112392b7419d08e7f3ff68d1
  total_cost_usd: 1.1926675
  num_turns: 32
  duration_ms: 183090
  subtype: success
  is_error: true
  modelos:
    - claude-haiku-4-5-20251001
    - claude-sonnet-5
  tokens_claude_haiku_4_5:
    input: 1255
    cache_creation_input: 0
    cache_read_input: 0
    output: 24
  tokens_claude_sonnet_5:
    input: 54
    cache_creation_input: 77054
    cache_read_input: 1652055
    output: 15546

captura_9_utc: 2026-09-15T19:55:07Z
invocacion_9:
  fase: continuacion_C4_interrumpida_por_tope_de_turnos
  session_id_sha256: 1e59b7e5c4eeb3ba145e159a0486efa10710164ddeeb3c8fe01ebc365dc1cf49
  total_cost_usd: 1.5705939
  num_turns: 26
  duration_ms: 283834
  subtype: error_max_turns
  is_error: true
  modelos:
    - claude-haiku-4-5-20251001
    - claude-sonnet-5
  tokens_claude_haiku_4_5:
    input: 1277
    cache_creation_input: 0
    cache_read_input: 0
    output: 29
  tokens_claude_sonnet_5:
    input: 50
    cache_creation_input: 92114
    cache_read_input: 1784843
    output: 32059

captura_10_utc: 2026-09-15T20:00:42Z
invocacion_10:
  fase: humo_real_control_intento_2_inconcluso
  session_id_sha256: c7f0e7d2e74ecf12b25733a22691e2a3e9c93824991fca39551e5803b23a53ba
  total_cost_usd: 0.0435631
  num_turns: 2
  duration_ms: 3110
  subtype: success
  is_error: false
  modelos:
    - claude-haiku-4-5-20251001
    - claude-sonnet-5
  tokens_claude_haiku_4_5:
    input: 548
    cache_creation_input: 0
    cache_read_input: 0
    output: 13
  tokens_claude_sonnet_5:
    input: 4
    cache_creation_input: 6016
    cache_read_input: 14707
    output: 162

captura_11_utc: 2026-09-15T20:00:42Z
invocacion_11:
  fase: humo_real_tratamiento_intento_2_inconcluso
  session_id_sha256: de78b1b864abb4428cc5d6a7e83eab58449f797e1571bd8b55939e5bafaa352d
  total_cost_usd: 0.0425845
  num_turns: 2
  duration_ms: 3209
  subtype: success
  is_error: false
  modelos:
    - claude-haiku-4-5-20251001
    - claude-sonnet-5
  tokens_claude_haiku_4_5:
    input: 548
    cache_creation_input: 0
    cache_read_input: 0
    output: 13
  tokens_claude_sonnet_5:
    input: 4
    cache_creation_input: 5886
    cache_read_input: 14645
    output: 150

captura_12_utc: 2026-09-15T20:32:31Z
invocacion_12:
  fase: correccion_excepcional_C5_completada
  instrumento: claude-code 2.1.272
  session_id_sha256: 6f26f476eeaabdd7aecf800fc6737607a1075d9933a716585a036c45c58a74de
  total_cost_usd: 1.8811836
  num_turns: 48
  duration_ms: 513149
  subtype: success
  is_error: false
  modelos:
    - claude-haiku-4-5-20251001
    - claude-sonnet-5
  tokens_claude_haiku_4_5:
    input: 1440
    cache_creation_input: 0
    cache_read_input: 0
    output: 26
  tokens_claude_sonnet_5:
    input: 84
    cache_creation_input: 133721
    cache_read_input: 4174008
    output: 50976

captura_13_utc: 2026-09-15T20:53:49Z
invocacion_13:
  fase: correccion_hallazgo_alto_misma_C5
  instrumento: claude-code 2.1.272
  session_id_sha256: 8b1dfda54ee82b5223c97e41851b75405bbd02961ef0d0d234937873e20b4ad1
  total_cost_usd: 1.5863032
  num_turns: 37
  duration_ms: 630765
  subtype: success
  is_error: false
  modelos:
    - claude-haiku-4-5-20251001
    - claude-sonnet-5
  tokens_claude_haiku_4_5:
    input: 1417
    cache_creation_input: 0
    cache_read_input: 0
    output: 30
  tokens_claude_sonnet_5:
    input: 62
    cache_creation_input: 124152
    cache_read_input: 3021521
    output: 48370

captura_14_utc: 2026-09-15T21:16:36Z
invocacion_14:
  fase: segunda_correccion_enfocada_misma_C5
  instrumento: claude-code 2.1.272
  session_id_sha256: ee68fcbabd0466dc3545bb0edac2569e6d0cbfd81bebff4cf7ca1fb33328c4b8
  total_cost_usd: 2.1387354
  num_turns: 42
  duration_ms: 674403
  subtype: success
  is_error: false
  modelos:
    - claude-haiku-4-5-20251001
    - claude-sonnet-5
  tokens_claude_haiku_4_5:
    input: 1473
    cache_creation_input: 0
    cache_read_input: 0
    output: 24
  tokens_claude_sonnet_5:
    input: 80
    cache_creation_input: 170171
    cache_read_input: 4455392
    output: 56522

captura_15_utc: 2026-09-15T21:26:41Z
invocacion_15:
  fase: correccion_minima_final_C5_interrumpida_por_turnos
  instrumento: claude-code 2.1.272
  session_id_sha256: c1bb3ce60336408920701e6ca032c5906b5abdf5c2b466b446b8a25134994007
  total_cost_usd: 0.5192944
  num_turns: 21
  duration_ms: 220332
  subtype: error_max_turns
  is_error: true
  modelos:
    - claude-haiku-4-5-20251001
    - claude-sonnet-5
  tokens_claude_haiku_4_5:
    input: 1284
    cache_creation_input: 0
    cache_read_input: 0
    output: 21
  tokens_claude_sonnet_5:
    input: 40
    cache_creation_input: 47252
    cache_read_input: 501337
    output: 22855

total_cost_usd: 41.9783256
```

El valor es una estimación del cliente por invocación, no facturación
autoritaria. La suma coincide con los quince `total_cost_usd` de los resultados
F1. No hubo solicitudes de WebSearch ni WebFetch. La segunda invocación se
incluye aunque terminó por `429`: consumió tokens y DEC-004 obliga a agregar
resultados de error. La tercera reanudó y cerró C1; la cuarta ejecutó C2; la
quinta ejecutó C3 excepcional por `3.3772883 USD`, equivalentes a `2.91 EUR`,
dentro de los `13 EUR` adicionales autorizados. Las invocaciones sexta y
séptima son las fases control y tratamiento del primer humo real: se incluyen
aunque el veredicto conductual fue inconcluso, porque consumieron tokens y
produjeron F1 conforme. La octava invocación abrió C4 y dejó el cambio candidato,
pero terminó por el límite de sesión con `is_error: true`; se agrega porque el
coste se consumió. La novena continuó la misma C4 y terminó por el tope de turnos
con `is_error: true`; también se agrega. Las invocaciones décima y undécima son
las dos fases del único reintento real posterior a C4; ambas terminaron
inconclusas y se agregan. La duodécima ejecutó C5 con Claude Code `2.1.272` y
consumió `1.8811836 USD`, equivalentes provisionalmente a `1.62 EUR`, dentro de
los `6 EUR` adicionales autorizados. La decimotercera corrigió dentro de la
misma C5 el hallazgo ALTO de Astra por `1.5863032 USD`. La decimocuarta
corrigió dentro de C5 sus efectos directos ALTO y MEDIO por `2.1387354 USD`.
C5 acumula `5.6062222 USD`, equivalentes provisionalmente a `4.84 EUR`. La
decimoquinta intentó la corrección mínima restante, terminó por tope de turnos
sin cambios y agrega `0.5192944 USD`. C5 acumula finalmente `6.1255166 USD`,
equivalentes provisionalmente a `5.29 EUR`. El total provisional equivale a
`36.22 EUR` al tipo congelado. C4 ha
consumido `2.46 EUR` de los `8 EUR` adicionales autorizados; quedan `5.54 EUR`
en esa excepción. En C5 quedan `0.71 EUR` y en el WP quedan `3.78 EUR`; el A/B
no se ejecuta porque el candidato permanece NO APTO. El coste final y la
atestación se materializarán antes de cualquier eventual presentación.
