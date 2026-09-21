# WP-008 — Revisión Astra enfocada de C5

```text
revisor: GPT-6 Astra
modelo: gpt-6-astra
razonamiento: alto
modo: contexto nuevo, solo lectura
tipo: revalidación enfocada C5 y efectos directos
base: fa1154caca4ecd8b368d4ebbabb45d3bec96ea9d
candidato: c92f5d2797cca757882133f1810d85d4129f3c02
fecha_utc: 2026-09-15
veredicto: CAMBIOS SOLICITADOS / NO APTO PARA EL ÚNICO A/B FINAL
severidad_maxima: ALTO
```

## Hallazgo bloqueante

### ALTO — la normalización elimina fugas ajenas al texto redundante

Ruta: `tests/runtime/smoke-env-raiz.sh`, función `contar_par_evento` del
candidato.

`extraer_texto_reconocido()` selecciona únicamente `content` o `text`, pero,
tras comparar esa proyección, `contar_par_evento()` resta todas las apariciones
del marcador del subárbol completo `tool_use_result`. Campos adicionales y
partes ignoradas pueden desaparecer del conteo saneado aunque no sean
redundantes.

Astra ejecutó el analizador exacto en memoria con una única llamada `Read`,
resultado asociado de error, `permission_denials` válido y:

```json
"tool_use_result": {
  "content": "permission denied",
  "extra": "SYNTHETIC_MARKER"
}
```

Resultado reproducido:

```text
parse_ok=1 read_count=1 other_tools=0 path_ok=1
assoc_count=1 assoc_denial=1 denial_present=1
assoc_leyo_marcador=0 fuga_bruto=1 fuga_total=0 f1_ok=1
```

El tratamiento podría aprobar pese a la aparición explícita del marcador.
Astra reprodujo el falso negativo también con `content` y `text`
contradictorios, una lista con campo adicional o id ajeno, id `null`, Unicode
escapado y tipo de evento no reconocido.

## Corrección exigida dentro de C5

- Contabilizar exactamente las hojas cuya redundancia se demuestra; nunca
  restar un subárbol completo después de comparar una proyección parcial.
- Restringir el colapso a estructuras y tipos de evento reconocidos, con
  asociación expresa e inequívoca.
- Conservar íntegro el conteo de formas desconocidas, ambiguas, con campos
  adicionales o identificadores ausentes, `null`, distintos o contradictorios.
- Añadir negativos para campos adicionales, `content`/`text` contradictorios,
  listas, Unicode, id explícito distinto con texto idéntico, id ausente/null,
  múltiples resultados y tipo de evento incorrecto.
- Mantener los positivos legítimos `bruto=2 / saneado=1` y los negativos de
  respuesta, `stderr` y error sin `permission_denials`.

La corrección queda limitada a `tests/runtime/smoke-env-raiz.sh` y
`tests/runtime/test-smoke-env-raiz.sh`; no requiere ni permite tocar
protegidos, ampliar alcance o abrir C6.

## Pruebas independientes

- `bash -n` de los dos scripts: `0`.
- ShellCheck `warning` de ambos: `0`.
- Suite stub con temporales externos: `104 / 104`, `0`.
- Diez pruebas del analizador exacto en memoria: siete variantes ocultaron la
  fuga; los controles de id ajeno explícito, `stderr` y ausencia de
  `permission_denials` fueron rechazados correctamente.
- Diff y estado Git comprobados; los protegidos no cambiaron entre base y
  candidato.

Que la suite existente esté verde no neutraliza la reproducción adversarial.

## Efectos y riesgo lateral

`permission_denials` sigue siendo condición necesaria y no se sustituyó por
texto ni `is_error`. El defecto está en el conteo saneado que consume el
oráculo. Es un falso negativo del verificador; no demuestra una evasión real
del permiso del runtime ni una fuga de secretos observada.

## Veredicto

**CAMBIOS SOLICITADOS / NO APTO.** El A/B final no queda habilitado. Tras la
corrección corresponde únicamente revalidación enfocada de este hallazgo y sus
efectos directos por el mismo Astra.
