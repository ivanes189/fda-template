# Manifiesto de la candidata C5 — WP-008 D6-A

**Etiqueta obligatoria:** CANDIDATA HISTÓRICA NO CONFORME — NO EJECUTAR

- Base: `dfc8a1fd8b6392e64313f0be72998ed9d96257b8`.
- Rama local: `wp/WP-008-runtime-fail-closed-d6`.
- HEAD preservado: `4dc200c56d14eecfc1ef8ea5c86007ec612643f4`.
- Árbol de HEAD: `e6d83aea5d64078d0b60da7a3b312ae001029c81`.
- Candidato de código revisado por el último Astra:
  `0776010bdb766f1f4a6e8213424992be7881e1eb`.
- Estado Git observado: limpio.
- SHA-256 del estado Git vacío:
  `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`.
- Magnitud frente a la base: `78 files changed, 12598 insertions(+), 28 deletions(-)`.
- SHA-256 del diff binario base..HEAD:
  `2c9be69f17a70611f4713bb42e346b1f949c6d00e40ce8fc38053b8245994982`.
- SHA-256 de la lista ordenada por Git de rutas modificadas:
  `0c4d17cbd358d63a04cb4100e81a8e61ab15dbaf724b074ab990140b3706e615`.
- Protegido `.claude/settings.json`:
  `60495d3656e1093dd0472548f9b6b132ea3cc4d005b71c072181a7914d5ba957`.
- Protegido `.github/workflows/ci.yml`:
  `069286aeab49f0aca11f777081cb559abf539eabcd6a1d207e391f3da82fbf10`.

El HEAD final añade solo el registro de parada sobre el candidato de código
`0776010`; no corrige el hallazgo MEDIO. La revisión final se practicó sobre ese
candidato y el intento posterior no modificó archivos.

La rama y el worktree se preservan fuera de la PR. Este manifiesto no autoriza
ejecutarlos, publicarlos, corregirlos, fusionarlos, copiarlos, limpiarlos ni
usarlos como guía. De las 78 rutas candidatas, la PR de cierre redacta de nuevo
`cost.md` y copia exactamente ocho evidencias textuales; las otras 69 rutas
quedan fuera y no se importa la implementación.
