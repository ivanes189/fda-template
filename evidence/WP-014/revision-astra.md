# WP-014 — Revisión independiente completa de Astra

```text
revisor: GPT-6 Astra
razonamiento: alto
contexto: nuevo
modo: solo lectura
base: 1feb66554c8754e586a1089822e1ab5a6edae900
candidato: c306e2b3d8d9fef902168bcfa0942b482d8aab74
veredicto: NO APTO — cambios solicitados
```

La revisión se realizó sin red ni mutaciones. El revisor recibió normas,
contrato, candidato y pruebas, pero no recibió como premisa ningún APTO o
conclusión del autor o del coordinador.

## Hallazgos

### F1 — Bloqueante: operador no admitido en el registro de coste

Ubicación: `evidence/WP-014/cost.md`, campo `operador`.

`operador: Codex (coordinador, captura F1)` no satisface DEC-004 §4, nota 1:
el actor que registra debe ser una persona o una automatización determinista
versionada. El expediente no identifica tal automatización y Codex es un
agente. Durante el régimen provisional, DEC-004 §12 deja la conformidad en la
atestación del operador. La cifra F1, su SHA-256 y su conversión son correctos,
pero el criterio «`cost.md` conforme» queda incumplido.

Corrección mínima: el operador humano comprueba y atesta la entrada real, y el
expediente registra ese acto sin alterar la procedencia F1 ni los importes. No
se crean herramientas FinOps.

### F2 — Importante: el manifiesto niega cambios que el candidato contiene

Ubicación: `evidence/WP-014/manifest.md`, sección «Tipos y modos».

La frase «no se modifican en este commit ni en ningún commit de este WP» es
verdadera únicamente para la preparación previa, pero falsa para el candidato
final: el commit humano de aplicación modifica los tres workflows.

Corrección mínima: acotar la afirmación al estado y revisión de preparación,
remitir a `PRE_APPLY_HEAD` y al commit de aplicación y conservar la invariancia
de tipo `blob` y modo `100644`, que sí está demostrada.

### F3 — Importante: salida atribuida incorrectamente al bloque contractual

Ubicación: `evidence/WP-014/verification.md`, verificación completa.

La evidencia afirma que el bloque se ejecutó «sin alterar ni reordenar», pero
atribuye a ese bloque cuatro líneas que no imprime: `postimages_ok counts`,
`WP014_BASE`, `WP014_HEAD` y `VERIFICATION_EXIT`. El revisor ejecutó literalmente
el bloque contractual y confirmó que termina en cero sin esas líneas.

Corrección mínima: distinguir las salidas reales de la instrumentación
diagnóstica añadida por el coordinador, documentar el envoltorio utilizado y no
presentar texto añadido como salida del bloque intacto.

## Comprobaciones independientes

- Bloque contractual completo sobre el candidato limpio: código `0`.
- `actionlint`, validador de workflows y manual: sin errores.
- Diff limitado a los seis patrones permitidos.
- Exactamente diez postimágenes, distribución `5/2/1/2`, sin alteración
  funcional adicional; objetos `blob`, modos `100644` y archivos regulares.
- `PATCH_COMMIT` contiene solo el parche, es ancestro de `PRE_APPLY_HEAD` y
  este del candidato; `PATCH_BLOB` coincide en las revisiones verificadas.
- Parche y diff aplicado contienen las mismas diez bajas y diez altas.
- Higiene local sin coincidencias; no se observaron secretos ni datos
  prohibidos en el extracto F1.
- SHA-256 del extracto correcto; `2.5364507 / 1.1590 = 2.188482053… EUR`,
  aproximadamente el `18.237 %` del presupuesto.
- Causa y recuperación del fallo inicial de expansión `zsh :e` reproducidas y
  coherentes; no se ejecutó ninguna variante de `git apply` en la revisión.

## Criterios

| Criterio | Resultado |
|---|---|
| Comandos locales, validadores y `ACTIVE` | Cumplido |
| Diez pins, versiones y única modificación funcional | Cumplido |
| Criterio 2 vacío y sin construcciones prohibidas | Cumplido |
| Parche, blob y aplicación humana | Cumplido por objetos y atestación |
| Alcance final | Cumplido |
| Coste dentro de 12 EUR | Importe cumplido; conformidad no cumplida por F1 |
| Revisión sin bloqueos | No cumplido mientras F1 siga abierto |
| Job remoto de secretos | No evaluable antes de la PR; pendiente posterior |

## Riesgos laterales, no incorporados al alcance

- No se reconsultó la correspondencia remota tag/SHA ni se auditó el código
  interno de los cuatro repositorios; se usa la matriz cerrada del contrato.
- Git demuestra identidades y postimágenes, no quién pulsó ejecutar; la autoría
  humana se sustenta en la confirmación saneada versionada.
- El escaneo local no sustituye el job remoto sobre el HEAD de la futura PR.
- El defecto de expansión zsh está declarado; no exige cambiar workflows ni
  ampliar alcance.

El candidato funcional no necesita cambios. Las tres correcciones exigidas se
limitan a evidencias permitidas por WP-014.
