# Cierre bloqueado de WP-009

Fecha: 2026-09-13
Decisión: `DEC-008`
Estado contractual final: `blocked`
Ciclos consumidos: `2 / 2`
Resultado: **NO APTO; no existe C3**

## Hechos de cierre

- No se aplicó el parche humano de workflows.
- No se creó commit ni PR de implementación.
- `.github/workflows/ci.yml`, `claude.yml` y `code-review.yml` permanecen en sus
  preimágenes versionadas.
- El aplicador candidato no se versiona ni se ejecuta.
- La candidata local se preserva sin modificar, como histórica no conforme,
  conforme a `MANIFIESTO-CANDIDATA-C2.md`.
- `ACTIVE` vuelve a reposo en el mismo diff que marca este contrato `blocked`.

## Hallazgos que impiden entregar WP-009

La revisión de seguridad concluyó **NO APTO** por un hallazgo ALTO: el temporal
predecible `${destino}.wp009-tmp.$$` puede seguir un enlace simbólico y escribir
fuera de los tres workflows antes del renombrado; el rollback no cubre esa
escritura. Registró además un hallazgo MEDIO de saneamiento F1 para
identificadores con forma de URL sin esquema.

La revisión de código concluyó **CAMBIOS SOLICITADOS — NO APTO** por cuatro
pendientes: clasificación F1 incompleta, comparación BCE después de redondear,
pruebas unitarias acopladas a la red y expediente final incompleto.

Revisiones externas de solo lectura preservadas por el coordinador:

| Revisión | SHA-256 |
|---|---|
| `REVISION-CODIGO-C2-ENFOCADA.md` | `dba38576957b775036e324107e1de51f63d8ff30f3303e62ac85252a53e17942` |
| `REVISION-SEGURIDAD-C2-ENFOCADA.md` | `f6950e3d7059eadbc05311527cbf2461b293ba8fa838c0b96a550990ab2ec517` |

Los documentos externos explican el dictamen; este archivo registra en el
repositorio los hechos y hallazgos necesarios para auditar el cierre, sin
incorporar herramientas peligrosas ni el expediente candidato completo.

## Preservación y coste

- Manifiesto versionado:
  `evidence/WP-009/MANIFIESTO-CANDIDATA-C2.md`.
- SHA-256 del manifiesto:
  `819fbca1525bb487eb66b409804b21e607d0da2bdf814aa9d71abb899a93e6b3`.
- Huella NUL del estado Git candidato:
  `1719ed24af6392e712addb17fbe15b5cf6818985cbe3c4c87e4fc36b431d2ad6`.
- Huella del diff binario candidato:
  `6ddb18cab5a14977d7536303cc8c09f05e7067acfb043743a3e5ca67bec45975`.
- Coste: `45.6189187 USD / 1.1590 = 39.3606 EUR`, clasificado `estimado`
  por la captura F1 incompleta y dentro del máximo de 43 EUR.

## Trabajo sucesor

DEC-008 separa lo pendiente en futuros contratos independientes:

1. WP-013: materializador seguro de parches sobre rutas protegidas, sin cambios
   de workflows.
2. WP-014: diez pins exactos por SHA, mediante parche aplicado por una persona y
   usando el materializador de WP-013 ya fusionado.

Esta PR no crea, activa ni ejecuta esos paquetes. La separación no reinicia el
contador de WP-009 ni renombra un tercer ciclo.
