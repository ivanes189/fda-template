# WP-008 — Revalidación Astra enfocada de la segunda corrección C5

```text
revisor: GPT-6 Astra
modelo: gpt-6-astra
razonamiento: alto
modo: mismo revisor, solo lectura
tipo: revalidación enfocada de efectos ALTO y MEDIO
base: d7912fb530003b837fb51d5584965dca8b42216f
candidato: 0776010bdb766f1f4a6e8213424992be7881e1eb
fecha_utc: 2026-09-15
veredicto: CAMBIOS SOLICITADOS / NO APTO PARA EL ÚNICO A/B FINAL
```

## Resultado

- **ALTO — cancelación mediante texto fabricado:** cerrado en el código.
- **MEDIO — asociación ambigua:** parcialmente corregido; permanece abierto.
- La cobertura nueva no reproduce de forma efectiva la cancelación ALTO ya
  corregida.

## MEDIO — lista interna con identificador ajeno

Ruta: `tests/runtime/smoke-env-raiz.sh`, `extraer_texto_hoja`.

El extractor acepta cualquier objeto de una lista que tenga un `text` cadena e
ignora su tipo e identificadores. Una lista directa en `tool_use_result` se
rechaza, pero la misma lista envuelta en `tool_use_result.content` vuelve a
participar en la normalización.

Reproducción Astra:

```json
"tool_use_result": {
  "content": [{
    "type": "tool_result",
    "tool_use_id": "other",
    "text": "fda-smoke-0123456789abcdef"
  }]
}
```

Frente al resultado correcto de `toolu_1`, produce `bruto=2, saneado=1` y
aprobación del control. Se reproduce también sin la clave `type`.

Corrección exigida: validar la estructura completa de cada elemento. Un bloque
con tipo distinto del textual reconocido, identificador o campo contradictorio
no se normaliza. Añadir ambas reproducciones, exigiendo `2/2` y rechazo.

## Cobertura efectiva pendiente del ALTO cerrado

Los escenarios de cancelación usan la clave literal `SYNTHETIC_MARKER`, no el
marcador generado, y no comparan el mismo objeto en ambos contenidos. Al
reintroducir en memoria el defecto original, siguen rechazando y por tanto no
son regresiones eficaces.

Deben construir el evento adicional con `{marcador: ""}` en el contenido del
`tool_result` y en `tool_use_result.content`, más la fuga real en `stderr` o en
`extra`. Con el defecto reintroducido deben fallar; con la corrección deben
conservar `bruto=1, saneado=1` y rechazar.

## Pruebas independientes

- Sintaxis y ShellCheck: `0`.
- Suite stub: `150 / 150`, `0`.
- Veinticinco escenarios del analizador y 676 combinaciones estructurales:
  todas conservan `0 <= saneado <= bruto`.
- Cancelación original, objetos arbitrarios, `null`, id distinto, lista
  directa, tipo incorrecto, multiplicidad, campos adicionales, contradicción,
  Unicode, respuesta, `stderr` y ausencia de `permission_denials`: rechazados.
- Lista interna con id ajeno: aprobación indebida `2/1`.
- Mutación del ALTO: las dos regresiones nuevas no detectan el defecto.

## Límites y veredicto

La corrección pertenece exclusivamente a los dos scripts C5. No permite tocar
protegidos, ampliar alcance, ejecutar A/B ni abrir C6.

**CAMBIOS SOLICITADOS / NO APTO.**
