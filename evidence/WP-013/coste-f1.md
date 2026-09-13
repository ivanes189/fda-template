# Extracto F1 saneado — WP-013

Generado a partir de los resultados JSON estructurados de las cuatro invocaciones
headless de Claude Code atribuidas explícitamente a WP-013. No contiene prompts,
resultados, rutas externas, correo, UUID de invocación ni identificadores en
claro. El identificador de sesión se conserva solo como SHA-256.

**Clasificación:** captura F1 agregada incompleta. Los resultados no aportan una
marca UTC por invocación, exigida por DEC-004 §8. La cifra USD y el resto de
campos sí proceden directamente de los JSON F1; por ello se registra como
`estimado`, sin descartar ni alterar el coste observado.

Instrumento: `claude-code 2.1.220`
WP-ID declarado: `WP-013`
Fecha de captura: `2026-09-13`
Session ID (SHA-256):
`98a2b48cbaadbc8c510ee87beb2422894a7ccddb2599153c67761b6aed15e7bb`

| # | total_cost_usd | num_turns | duration_ms | is_error | terminal_reason | api_error | modelos | input | output | cache_creation | cache_read | marca UTC |
|---:|---:|---:|---:|---|---|---:|---|---:|---:|---:|---:|---|
| 1 | 2.6851943 | 29 | 704322 | false | completed | — | claude-sonnet-5; claude-haiku-4-5 | 1094 | 72237 | 155831 | 2219151 | no_provisto |
| 2 | 0.0000000 | 1 | 1384 | true | api_error | 429 | no_provisto | 0 | 0 | 0 | 0 | no_provisto |
| 3 | 7.9742508 | 96 | 778658 | false | completed | — | claude-sonnet-5 | 148 | 76392 | 281757 | 17124616 | no_provisto |
| 4 | 8.5897824 | 68 | 936998 | false | completed | — | claude-sonnet-5 | 114 | 86702 | 147920 | 21337968 | no_provisto |

## Totales

- Invocaciones agregadas: 4
- Coste total (USD): `19.2492275`
- Input tokens: `1356`
- Output tokens: `235331`
- Cache creation input tokens: `585508`
- Cache read input tokens: `40681735`
- Solicitudes web declaradas por F1: `0`

La invocación 1 diseñó la solución pero no pudo escribir por una configuración
`dontAsk`; no modificó archivos. La invocación 2 fue el reintento previo al
restablecimiento y terminó con HTTP 429, sin coste ni tokens. La invocación 3
materializó la implementación inicial con `acceptEdits`, sin desactivar hooks ni
permisos Bash. Ninguna de las dos primeras invocaciones constituye un ciclo de
corrección porque no existía candidato materializado.

La invocación 4 materializó el ciclo extraordinario C3 autorizado para corregir
F1–F8. Su coste fue `8.5897824 USD`, equivalente a `7.4114 EUR` con el tipo
congelado `1.1590 USD/EUR`; registró cero solicitudes web.
