# WP-014 — Aplicación humana del parche protegido

## Identidades confirmadas

```text
fecha_confirmacion_utc: 2026-09-13T20:32:08Z
PATCH_COMMIT: 6d5d29f44643b7386d79068093b1fe0978345b61
PATCH_BLOB: 8c6b1d7c5ca9bd6c35458dcbb537de250d7c03b4
PRE_APPLY_HEAD: bf56641bfaa4107e23533dbb0f94d490d6ef793d
actor: operador humano
```

El operador humano ejecutó desde la raíz del worktree dedicado la secuencia
protegida del contrato. El uso de `set -euo pipefail` y la llegada al final del
bloque acreditan que se cumplieron, en orden, estas condiciones:

- índice y árbol limpios antes de comenzar;
- `PATCH_COMMIT` era ancestro de `PRE_APPLY_HEAD`;
- `PATCH_BLOB` era un objeto Git de tipo `blob`;
- el parche de `PATCH_COMMIT` y el de `PRE_APPLY_HEAD` resolvían al mismo blob;
- `git apply --check --index -` terminó en cero y dejó el árbol limpio;
- `git apply --index -` terminó en cero sobre los mismos bytes;
- el resultado quedó limitado a los tres workflows previstos, en el índice.

## Intento detenido y recuperación

Un primer intento se detuvo antes de las dos órdenes `git apply`. En `zsh`, la
forma no delimitada `$PATCH_COMMIT:evidence/...` fue interpretada mediante el
modificador de nombre de archivo `:e`, produjo la ruta inválida
`vidence/WP-014/parche/workflows-actions-sha.patch` y terminó con error. Todas
las órdenes anteriores eran de lectura, por lo que no hubo modificación que
revertir.

Tras preservar el diagnóstico, la repetición usó llaves —
`${PATCH_COMMIT}:evidence/...` y `${PRE_APPLY_HEAD}:evidence/...`— para delimitar
las variables sin cambiar las identidades, el blob ni las operaciones
autorizadas. La secuencia corregida terminó satisfactoriamente. Este hallazgo de
portabilidad del bloque contractual se conserva para revisión; no se modifica
el contrato desde la propia implementación.

## Postimagen inmediata

La inspección posterior del índice registró exactamente:

```text
M  .github/workflows/ci.yml
M  .github/workflows/claude.yml
M  .github/workflows/code-review.yml
```

El diff aplicado contiene diez eliminaciones y diez adiciones, exclusivamente
las diez sustituciones de la matriz cerrada. No se usaron `--reject`, `--3way`,
`--unsafe-paths`, `--force` ni mecanismos alternativos.
