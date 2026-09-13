# WP-014 — Revalidación Astra enfocada de C1

```text
revisor: GPT-6 Astra
razonamiento: alto
modo: solo lectura
revision_original: c306e2b3d8d9fef902168bcfa0942b482d8aab74
candidato_corregido: 4e15557288c6191d06713222308abc01b2f3b70b
ciclo: C1 de 2
veredicto_enfocado: APTO
```

La revalidación se limitó a los tres hallazgos de la revisión completa y a los
efectos de su corrección. No repitió la auditoría general, no usó red, no
modificó el candidato y no ejecutó ninguna variante de `git apply`.

| Hallazgo | Resultado | Evidencia |
|---|---|---|
| F1 — operador del coste | **CORREGIDO** | `cost.md` identifica al operador humano; `atestacion-coste.md` registra su comprobación y atestación. Codex queda como compilador técnico, no como operador. |
| F2 — manifiesto contradictorio | **CORREGIDO** | `manifest.md` limita la invariancia de contenido a la preparación hasta `PRE_APPLY_HEAD`, reconoce el commit que registra la aplicación y conserva la invariancia real de tipos y modos. |
| F3 — salida atribuida incorrectamente | **CORREGIDO** | `verification.md` declara la instrumentación añadida y distingue las salidas reales de validadores del `print` y `printf` diagnósticos. |

## Comprobaciones enfocadas independientes

- Suma F1: `2.5364507 + 0.6236902 = 3.1601409 USD`.
- Conversión: `3.1601409 / 1.1590 = 2.726609922… EUR`, registrada como
  `2.73 EUR`; consumo redondeado `23 %`, dentro de `12 EUR`.
- SHA-256 del extracto F1:
  `a9c9c8e265bc62b2c8a97b1981f9dd488046ed6626f09887ae56c9f079531b45`,
  coincidente en coste y atestación.
- Delta de C1 limitado a seis archivos bajo `evidence/WP-014/`, sin cambios
  funcionales, de permisos, tipos ni modos.
- `git diff --check` sin errores; higiene contractual sin coincidencias;
  worktree limpio.
- Los cinco archivos redundantes de `correccion-c1/**` desaparecen del
  candidato final, aunque permanecen recuperables en el commit histórico
  `327832f`; ninguna evidencia final los referencia.

La ejecución literal del bloque contractual sobre el candidato corregido fue
aportada por el coordinador con código `0`; Astra la aceptó como evidencia y no
la presentó como ejecución propia.

**Conclusión:** no quedan hallazgos bloqueantes ni regresiones causadas por C1.
El job remoto de secretos continúa pendiente hasta la PR y este dictamen no lo
da por acreditado. No se abre C2.
