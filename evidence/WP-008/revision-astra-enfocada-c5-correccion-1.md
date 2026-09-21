# WP-008 — Revalidación Astra enfocada de la primera corrección C5

```text
revisor: GPT-6 Astra
modelo: gpt-6-astra
razonamiento: alto
modo: mismo revisor, solo lectura
tipo: revalidación enfocada del hallazgo ALTO C5 y efectos directos
candidato_anterior: c92f5d2797cca757882133f1810d85d4129f3c02
candidato_corregido: d7912fb530003b837fb51d5584965dca8b42216f
fecha_utc: 2026-09-15
veredicto: CAMBIOS SOLICITADOS / NO APTO PARA EL ÚNICO A/B FINAL
severidad_maxima: ALTO
```

## Resultado

El caso original de `revision-astra-enfocada-c5.md` queda corregido, pero el
hallazgo ALTO no se cierra: la corrección introduce un falso negativo directo
en el mismo cálculo. Permanece además una asociación ambigua de severidad
MEDIA. El A/B final sigue prohibido.

## ALTO — texto fabricado genera conteos negativos que cancelan fugas

Ruta: `tests/runtime/smoke-env-raiz.sh`, cálculo de descuento en
`contar_par_evento`.

`texto_tur` no siempre representa una hoja textual real.
`texto_contenido()` convierte objetos arbitrarios mediante `str()`, incluyendo
claves que el contador bruto —que recorre valores— nunca contabilizó. La resta
puede descontar una aparición inexistente.

Con un `tool_result` ajeno y su `tool_use_result` que contienen
`{"SYNTHETIC_MARKER": ""}`, Astra reprodujo por evento
`bruto=0, saneado=-1`. Al añadir una aparición real en `stderr` o en un campo
adicional, el total queda `bruto=1, saneado=0` y el tratamiento puede aprobar.

Corrección exigida:

- descontar solo apariciones en hojas textuales reales identificadas y
  verificadas; nunca usar texto fabricado por `str()`;
- las estructuras no reconocidas no se normalizan;
- imponer por evento `0 <= saneado <= bruto`; una anomalía bloquea, nunca
  compensa otra aparición;
- añadir regresiones de cancelación contra `stderr` y contra campo adicional.

## MEDIO — asociaciones ambiguas con lista e identificador `null`

Ruta: `tests/runtime/smoke-env-raiz.sh`, validación de `tool_use_id`.

Cualquier lista se trata como representación sin identificador y un
`tool_use_id: null` se equipara a clave ausente. Astra reprodujo aprobación
indebida `bruto=2, saneado=1` tanto con una lista que declara id ajeno como con
un objeto que declara `null`; el objeto directo con id ajeno sí se rechaza.

Corrección exigida:

- definir y validar las formas admitidas antes de extraer texto;
- diferenciar clave ausente admitida de `null` explícito;
- rechazar identificadores ajenos u ocultos dentro de listas;
- aislar en las pruebas el predicado: el marcador debe estar en el propio
  texto cuya normalización depende de id, tipo o multiplicidad, no solo en un
  campo adicional.

## Pruebas independientes

- Sintaxis y ShellCheck de ambos scripts: `0`.
- Suite determinista: `128 / 128`, `0`.
- Veinte reproducciones del analizador exacto en memoria.
- El caso original, campos adicionales, contradicción `content/text`, Unicode,
  tipo incorrecto, múltiples resultados, respuesta, `stderr` aislado y error
  sin `permission_denials` se rechazaron correctamente.
- Fallaron los casos de texto fabricado con fuga compensada, lista con id ajeno
  y objeto con id `null` cuando el marcador está en el texto comparado.

Que la suite esté verde no cubre estos falsos negativos.

## Límites

Los defectos pertenecen a la misma normalización C5. La corrección se limita a
los dos scripts de humo y sus evidencias; no permite protegidos, otro alcance,
C6 ni A/B real. No se demuestra una evasión real del runtime, sino falsos
negativos del verificador con entradas sintéticas.

## Veredicto

**CAMBIOS SOLICITADOS / NO APTO.** El único A/B final no queda habilitado.
