# Extracto F1 saneado — WP-009

Generado por `evidence/WP-009/checks/registrar-coste-f1.py` (DEC-004 §9).
NO copia basenames externos, prompts, resultados, correo, UUID ni datos de
organización: cada invocación se identifica por un índice neutro, no por el
nombre ni la ruta del archivo JSON de origen. La marca UTC es el `mtime` del
archivo fuente (dato de sistema de archivos, no inventado).

**Clasificación de cierre:** captura F1 agregada incompleta. La invocación 1 no
incluye modelos ni recuentos de tokens exigidos por DEC-004 §8; por tanto el
coste total se registra como `estimado`, aunque la suma USD sí es reproducible.

| # | total_cost_usd | num_turns | duration_ms | subtype | is_error | session_id (SHA-256) | modelos | tokens | marca UTC (mtime fuente) |
|---:|---:|---:|---:|---|---|---|---|---:|---|
| 1 | 0.0000000 | 1 | 2359 | success | True | 7a7991f4088190764c2a2da1a7389aee9135b8644285b3d4ce51d3c41888065e | no_provisto | no_provisto | 2026-09-09T21:15:53Z |
| 2 | 2.0981845 | 38 | 343692 | success | False | 0af08f60fcb610de9ab65fd4074b9d5a34c94db560a34ee96e8c34fb5240dab4 | claude-opus-5 | 23970 | 2026-09-09T21:24:50Z |
| 3 | 19.4746029 | 285 | 2216953 | success | False | 185240623c5ac39b1d06af673b2a82c7688cdfe2c46303be7ee0f3c966cc77b8 | claude-sonnet-5 | 166846 | 2026-09-12T09:58:56Z |
| 4 | 7.6185093 | 96 | 1726124 | success | True | 20a769e4ced8ca50d0e1046c354ac290c4fb12c6e5a6efa33e4f0ce2c32e5602 | claude-haiku-4-5-20251001;claude-sonnet-5 | 155210 | 2026-09-12T10:47:31Z |
| 5 | 1.9827648 | 5 | 52780 | success | False | 20a769e4ced8ca50d0e1046c354ac290c4fb12c6e5a6efa33e4f0ce2c32e5602 | claude-sonnet-5 | 3285 | 2026-09-13T08:17:42Z |
| 6 | 3.3466402 | 51 | 909604 | success | False | c46eb11fc9e2817bedbfd9691bc37e92afc1add91f288268bcbba91cbc4396b2 | claude-sonnet-5;claude-haiku-4-5-20251001 | 62922 | 2026-09-13T08:36:53Z |
| 7 | 11.0982170 | 126 | 1602890 | success | False | f3df4e67f5ca39c93c63295f924be30a4e2c9194e3cea1be15e93f9fd4bdc8df | claude-haiku-4-5-20251001;claude-sonnet-5 | 138814 | 2026-09-13T09:39:33Z |

## Totales

- Invocaciones agregadas: 7
- Coste total (USD): 45.6189187
