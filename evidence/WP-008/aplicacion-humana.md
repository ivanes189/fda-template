# WP-008 — Aplicación humana del paquete protegido

```text
operador: Iván
fecha_registro_utc: 2026-09-15T12:15:11Z
worktree: dedicado WP-008 D6-A
rama: wp/WP-008-runtime-fail-closed-d6
head_aprobado: 321dc5ab05a419d4c052888e1c6c9286c8a0b099
base_git: dfc8a1fd8b6392e64313f0be72998ed9d96257b8
manifest_sha256: cdd4aeb1f0d238b24697837874373d1290e6a41dc4a3ba4cd99ed2c49f6e0161
aplicador_exit: 0
resultado: APLICACIÓN HUMANA COMPLETA Y VERIFICADA
```

## Atestación del operador

Iván ejecutó personalmente el bloque de precomprobación y aplicación autorizado
en el worktree dedicado. El agente no ejecutó el aplicador contra la FDA real.

La salida comunicada por el operador acredita:

- `PRECHECK OK` para `settings` y `ci`;
- `PRECHECK COMPLETO: APTO PARA APLICAR`;
- creación y verificación de ambos respaldos contra sus preimágenes;
- instalación y verificación de ambos objetivos con modo `644`;
- `APPLY_EXIT=0`;
- `POSTCHECK OK` para ambos objetivos; y
- `APLICACIÓN HUMANA COMPLETA Y VERIFICADA`.

## Huellas acreditadas

| Objetivo | Preimagen SHA-256 | Postimagen SHA-256 | Modo final |
|---|---|---|---:|
| `.claude/settings.json` | `d57679a3c075a68742befc91f0f092dfda5bf66f0cffd7682a41835bf29f32d8` | `60495d3656e1093dd0472548f9b6b132ea3cc4d005b71c072181a7914d5ba957` | `644` |
| `.github/workflows/ci.yml` | `1ce105f5ea6780868861baf3ea1d2de47d95f0205af0406b3f8b2f25c7453953` | `069286aeab49f0aca11f777081cb559abf539eabcd6a1d207e391f3da82fbf10` | `644` |

Sol volvió a calcular las postimágenes desde el worktree después de recibir la
atestación y obtuvo exactamente las dos huellas declaradas por el manifiesto.
El diff observado contiene únicamente los cambios protegidos preparados:
anclaje de ocho reglas y comando fail-closed en `settings.json`, más el paso de
preflight en `ci.yml`.

## Estado posterior inmediato

Los dos protegidos quedaron modificados respecto de `origin/main`, como exige
la postimagen, y ningún otro archivo estaba modificado. La batería posterior y
el humo real aún no habían sido ejecutados al registrar esta evidencia.
