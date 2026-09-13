# WP-014 — Corrección C1/2 (F2, F3 de la revisión Astra)

Ámbito: `evidence/WP-014/revision-astra.md`, hallazgos F2 y F3 únicamente.
F1 (operador no admitido en `cost.md`) queda explícitamente fuera de esta
corrección: requiere atestación humana y agregación de esta invocación por el
coordinador, y no se suplanta aquí.

## F2 — manifest.md

Se corrigió la sección «Tipos y modos» de `evidence/WP-014/manifest.md` para
no afirmar que los tres workflows «no se modifican en este commit ni en
ningún commit de este WP». Ahora se distingue:

- la preparación de Claude Code, hasta e incluyendo `PRE_APPLY_HEAD`
  (`bf56641bfaa4107e23533dbb0f94d490d6ef793d`): los tres workflows no se
  modifican en ningún commit preparado por el agente;
- el commit humano de aplicación
  (`3a0fbf6d7ffba29dce7caa7c938ee871e702d53e`), posterior a `PRE_APPLY_HEAD`,
  que sí modifica los tres workflows aplicando las diez sustituciones.

Se conserva, porque está demostrada en ambos estados, la invariancia de tipo
(`blob`) y modo (`100644`) de los tres archivos.

## F3 — verification.md

Se corrigió la sección 11 de `evidence/WP-014/verification.md` para no
presentar como salida literal del bloque contractual las cuatro líneas que el
bloque, tal como está escrito en el contrato, no imprime: `postimages_ok
counts`, `WP014_BASE`, `WP014_HEAD` y `VERIFICATION_EXIT` (así como el
encabezado `fecha_utc` / `WP014_BASE` / `WP014_HEAD` / `estado_inicial` que ya
figuraba antes de la salida). Ahora el documento aclara que esas líneas son
instrumentación diagnóstica añadida por el coordinador alrededor de la
invocación del bloque, no texto emitido por las órdenes del contrato en sí.
No se afirma que el bloque instrumentado sea literal o inalterado; se afirma
que las órdenes del contrato se ejecutaron literalmente, y se separa esa
afirmación de la instrumentación añadida.

## Comprobaciones locales ejecutadas tras la corrección

Todas con código de salida `0`:

- `bash tests/governance/check-active.sh` → primera línea `ACTIVO: WP-014`
  (salida en `evidence/WP-014/correccion-c1/check-active.txt`).
- `actionlint -color .github/workflows/*.yml` → sin salida, sin errores
  (`evidence/WP-014/correccion-c1/actionlint.txt`, vacío).
- `python3 .claude/skills/run-verification/validate-workflows.py
  .github/workflows` → `RESULTADO: 0 errores, 0 avisos`
  (`evidence/WP-014/correccion-c1/validate-workflows.txt`).
- `python3 evidence/WP-000/checks/check-manual.py` → `RESULTADO: 0 fallos`
  (`evidence/WP-014/correccion-c1/check-manual.txt`).

No se ejecutó ninguna variante de `git apply`, no hubo acceso de red y no se
leyó ni imprimió ningún secreto. No se tocó ningún archivo fuera de
`evidence/WP-014/manifest.md`, `evidence/WP-014/verification.md` y esta
carpeta de evidencia de la corrección.

## Riesgos y deuda

- Ninguna deuda nueva introducida. Los cambios son exclusivamente
  documentales, sobre evidencia ya generada; no alteran el candidato
  funcional (los tres workflows, `manifest.md` fuera de la sección corregida,
  y el resto de evidencias permanecen intactos).
- F1 sigue abierto y pendiente de la atestación humana y agregación de coste
  de esta misma invocación, a cargo del coordinador.
- La revisión Astra enfocada de esta corrección (máximo dos ciclos según el
  contrato) queda pendiente, a cargo del revisor externo.
