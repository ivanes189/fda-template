# Fixtures de CI — respuestas de `gh` grabadas

Catorce respuestas versionadas con la forma exacta de
`gh run view RUN_ID --json status,conclusion,headSha,databaseId,url,jobs`.
**Ninguna procede de una ejecución real de este repositorio**: son entradas de
prueba, con `run_id` y URL inventados, y por eso ninguna es admisible como
evidencia. La evidencia real solo puede proceder de `modo=real`.

Los dos hashes de prueba son `1111…1111` para `C_ROJO` y `2222…2222` para
`C_VERDE`.

| Fixture | Caso | Validación que debe bloquear |
|---|---|---|
| `rojo-conforme.json` | 1, 14 | — (exit 0) |
| `rojo-no-terminado.json` | 2, 14, 16 | 1 · el run no ha terminado |
| `rojo-headsha-incorrecto.json` | 3 | 2 |
| `rojo-conclusion-success.json` | 4 | 3 |
| `rojo-conclusion-cancelled.json` | 5 | 3 · `cancelled` nunca vale |
| `rojo-paso-anterior-no-success.json` | 6 | 4 |
| `rojo-preflight-no-failure.json` | 7 | 5 |
| `rojo-paso-posterior-no-skipped.json` | 8 | 6 |
| `rojo-otro-job-no-success.json` | 9 | 7 |
| `rojo-segunda-causa.json` | 10 | 8 |
| `json-malformado.json` | 11, 15 | — (exit 2) |
| `verde-conforme.json` | 17 | — (exit 0) |
| `verde-no-terminado.json` | 17 | primera respuesta del polling verde |
| `verde-headsha-incorrecto.json` | 18 | 2 del modo `--verde` |
| `verde-conclusion-distinta.json` | 19 | 3 del modo `--verde` |

El **stub** de `gh`, el marcador `.fda-fixture` y las raíces de fixture **no se
versionan**: `test-capturar-ci-rojo.sh` los crea con `mktemp -d` fuera de la raíz
física del repositorio. Ninguna prueba usa la red.
