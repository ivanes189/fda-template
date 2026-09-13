# Revisión independiente enfocada — C3 de WP-013

- Revisor: GPT-6 Astra
- Razonamiento: Alto
- Contexto: nuevo
- Modo: solo lectura
- Base de corrección: `e59661e7e60976aa8bcc406ec7188edd6e9dfd42`
- Candidato: `f3925e5f1b3b37a03ec6cddc98f594cd912e1347`
- Fecha: 2026-09-13
- Alcance: correcciones C3 de F1–F8 y sus efectos directos

El revisor no realizó una segunda revisión general, no tomó como premisa el
APTO del implementador o coordinador y no modificó el repositorio. Las
reproducciones se ejecutaron sobre árboles sintéticos temporales.

## Hallazgos bloqueantes

### H1 — ALTO — recuperación vuelve a declarar preimágenes inexistentes

En `scripts/materialize-protected.py:984` —con interacción en las líneas
509–510, 992 y 1024–1041—, `write_and_replace()` hace el rename y después
sincroniza el directorio. Si `fsync` falla, no retorna y el destino nunca entra
en `committed`; la recuperación solo comprueba esa lista.

Con un único `EIO` después del rename, la reproducción devolvió código 3, dejó
la postimagen y generó recibo `fallo_restaurado` / `preimagen`. Otra
reproducción alteró el segundo destino durante la sustitución del primero: se
detectó la deriva, pero se declararon ambos en preimagen mientras el segundo
contenía `drift`.

Corrección exigida: registrar la sustitución inmediatamente después del rename,
antes de cualquier operación falible, y comprobar todo el conjunto antes de
declarar restauración. Toda discrepancia debe escalar como estado incompleto sin
sobrescribir destinos no sustituidos por la herramienta.

### H2 — MEDIO — fallo al guardar recuperación impide el escalado

En `scripts/materialize-protected.py:1030` y 1188, el diagnóstico de rollback
incompleto se emite después de persistir su recibo. Con `ENOSPC` durante commit
y recuperación, quedó la postimagen, el recibo anterior siguió en `iniciado` /
`preimagen`, escapó un `OSError` y no apareció `ESCALAR DE INMEDIATO`.

Corrección exigida: proteger también los recibos de recuperación y emitir un
diagnóstico independiente aunque falle su escritura, conservando causa, rutas
afectadas y ubicación del estado.

### H3 — MEDIO — Git reabre un parche distinto del validado

En `scripts/materialize-protected.py:932`, también líneas 557 y 569, el
preflight lee el parche por descriptor, pero Git vuelve a abrir la ruta
original. Sustituirla después por un symlink a otro parche produjo código 0,
recibo `exito` y un `extra.txt` en scratch; sustituirla por FIFO bloqueó
`git apply --check` hasta timeout.

Corrección exigida: suministrar a ambas invocaciones Git los mismos bytes ya
validados mediante stdin o una copia exclusiva dentro del estado privado. No
reabrir la entrada externa.

### H4 — MEDIO — rollback no valida transiciones por resultado

En `scripts/materialize-protected.py:1152`, se admite indistintamente preimagen
o postimagen sin consultar `resultado`. Tras una aplicación de dos destinos con
recibo `exito`, devolver manualmente el primero a preimagen hizo que rollback lo
omitiera, modificara el segundo y terminara con código 0 / `restaurado`.

Corrección exigida: validar el conjunto completo antes de escribir. Para
`exito`, exigir todas las postimágenes y modos; distinguir una repetición
idempotente acreditada de estados incompletos que requieren recuperación humana.

## Estado enfocado de F1–F8

| Hallazgo | Estado tras C3 |
|---|---|
| F1 | Parcial; el caso original pasa, pero H1 mantiene rollback falso. |
| F2 | Parcial; detecta la manipulación original, pero recupera mal en H1. |
| F3 | Parcial; protege recibo de éxito, no recibos de recuperación (H2). |
| F4 | Parcial; propaga EIO, pero tras rename provoca H1. |
| F5 | Parcial; mejora manifiesto/backups, pero Git reabre el parche (H3). |
| F6 | Parcial; comprueba modo, pero no transiciones por resultado (H4). |
| F7 | Parcial; rechaza FIFO de destino, no el reabierto por Git (H3). |
| F8 | Parcial; corrige la colisión, pero no cubre H1–H4. |

## Comprobaciones verdes

La suite ejecutó 89/89 pruebas. Pasaron `git diff --check` y los controles de
alcance y workflows. Estos resultados no reproducen ni cierran H1–H4.

## Veredictos

- Revisión enfocada de código: rechazada.
- Revisión enfocada de seguridad: rechazada; H1 ALTO sigue abierto.
- Veredicto único: **NO APTO**.

C3 no autoriza C4.
