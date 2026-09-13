# WP-014 — Manifiesto del parche protegido

## Identidades

BASE_SHA: `1feb66554c8754e586a1089822e1ab5a6edae900`

- `main` remoto consultado por Codex, como coordinador, mediante
  `git fetch origin main` inmediatamente antes de crear la rama y el
  worktree dedicados de WP-014.
- Instante UTC de la consulta: `2026-09-13T20:06:51Z`.
- Coincide con el commit inicialmente extraído por este worktree (verificado
  con `git log --format=%H -1 1feb665` → `1feb66554c8754e586a1089822e1ab5a6edae900`).

PATCH_COMMIT: `6d5d29f44643b7386d79068093b1fe0978345b61`

- Commit que añade, en solitario, el archivo del parche unificado.
- Ancestro de `HEAD` en el momento de escribir este manifiesto.

PATCH_PATH: `evidence/WP-014/parche/workflows-actions-sha.patch`

PATCH_BLOB: `8c6b1d7c5ca9bd6c35458dcbb537de250d7c03b4`

- Obtenido con un comando permitido (`git diff --cached --raw --abbrev=40`)
  antes del commit, sobre el archivo recién añadido al índice:

  ```
  git add evidence/WP-014/parche/workflows-actions-sha.patch
  git diff --cached --raw --abbrev=40 -- evidence/WP-014/parche/workflows-actions-sha.patch
  :000000 100644 0000000000000000000000000000000000000000 8c6b1d7c5ca9bd6c35458dcbb537de250d7c03b4 A	evidence/WP-014/parche/workflows-actions-sha.patch
  ```
- Es un OID Git hexadecimal de 40 caracteres, de tipo `blob` (columna de modo
  `100644` en la salida `--raw`), no un nombre simbólico ni un revspec.
- El manifiesto no contiene el SHA de su propio commit: `PATCH_BLOB` es el
  OID del blob del archivo del parche, no de `PATCH_COMMIT`.

## Tipos y modos

- El archivo del parche es un blob regular, modo `100644` (columna de modo en
  la salida `--raw` de más arriba: `100644` tanto en la entrada nueva como en
  el árbol final).
- Durante toda la preparación de Claude Code, hasta e incluyendo
  `PRE_APPLY_HEAD` (`bf56641bfaa4107e23533dbb0f94d490d6ef793d`), los tres
  workflows objetivo (`.github/workflows/ci.yml`, `claude.yml`,
  `code-review.yml`) no se modifican en ningún commit preparado por este
  agente: siguen siendo blobs regulares `100644` idénticos a `BASE_SHA`, tal
  como exige el contrato (edición denegada a Claude Code por
  `.claude/settings.json` y reservada al acto humano de Iván).
- El commit que registra la aplicación humana,
  `3a0fbf6d7ffba29dce7caa7c938ee871e702d53e`, es posterior a
  `PRE_APPLY_HEAD` y sí modifica los tres workflows: contiene exactamente las
  diez sustituciones de la matriz cerrada que el operador aplicó conforme al
  punto de parada. Esa modificación queda fuera de lo que este manifiesto
  certifica como preparación de Claude Code, pero no debe negarse: está
  documentada en `evidence/WP-014/aplicacion-humana.md` y verificada en
  `evidence/WP-014/verification.md`.
- Lo que sí está demostrado y se conserva sin cambios en ambos estados
  (preparación y tras la aplicación humana) es la invariancia de tipo
  (`blob`) y modo (`100644`) de los tres archivos: ningún acto de este WP
  altera su tipo, su modo ni su condición de archivo regular.

## Procedencia del contenido del parche

El parche se construyó a mano, sin ejecutar `git apply` en ninguna de sus
variantes (ambas están reservadas a Iván tras el punto de parada del
contrato). El contenido se derivó leyendo los tres workflows tal como están en
este `HEAD` y sustituyendo, exactamente, las diez líneas `uses:` que fija la
matriz cerrada del contrato de WP-014, sin tocar ninguna otra línea.

Verificación de cardinalidad y contenido: ver `evidence/WP-014/verification.md`.

## Advertencia sobre el punto de parada

Ni `git apply --check --index -` ni `git apply --index -` se ejecutaron para
producir ni para validar este parche: el contrato de WP-014 reserva ambas
órdenes a Iván, desde la raíz de este mismo worktree, tras autorización
separada. Este manifiesto documenta el blob preparado; no certifica que el
parche aplique limpiamente, porque esa comprobación es exactamente la primera
orden protegida.
