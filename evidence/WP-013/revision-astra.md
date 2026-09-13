# Revisión independiente final — WP-013

- Revisor: GPT-6 Astra
- Razonamiento: Alto
- Contexto: nuevo
- Modo: solo lectura
- Base: `074dfcbff426fb85685ae97746d1b5e0fe679b0b`
- Candidato: `89bd374015a5a28e673d4653a9f45493bf21d74e`
- Fecha: 2026-09-13
- Alcance: una revisión completa combinada de código y seguridad T3

El revisor recibió normas, contrato, candidato y pruebas. No recibió como
premisa el APTO ni la conclusión del implementador. No modificó el repositorio.

## Hallazgos bloqueantes

### F1 — ALTO — rollback automático falso

En `scripts/materialize-protected.py:866`, el destino se incorpora a
`committed` después de comprobar la postimagen. Un fallo de lectura inyectado
tras el `rename` produjo salida 3, dejó la postimagen aplicada y generó un
recibo `fallo_restaurado` que declaraba preimagen. Debe registrarse toda
sustitución antes de cualquier comprobación posterior y verificarse la
restauración completa; una discrepancia debe escalar como rollback incompleto.

### F2 — ALTO — éxito con destino manipulado

En `scripts/materialize-protected.py:863`, las preimágenes no se revalidan
inmediatamente antes de cada reemplazo ni se comprueba el conjunto completo
antes del éxito. Con dos destinos, la alteración del primero durante el segundo
reemplazo terminó con salida 0 y recibo `exito`. Deben revalidarse identidad,
tipo, enlaces, modo y huella antes de cada reemplazo y todas las postimágenes
antes del recibo terminal.

### F3 — MEDIO — fallo del recibo terminal sin recuperación

En `scripts/materialize-protected.py:897`, un `ENOSPC` al persistir el recibo de
éxito dejó el destino aplicado y el recibo en `iniciado`, sin rollback ni
`ESCALAR DE INMEDIATO`. La persistencia terminal debe formar parte del protocolo
transaccional y los fallos de registro deben tener diagnóstico independiente.

### F4 — MEDIO — errores de sincronización silenciados

En `scripts/materialize-protected.py:436`, se suprime cualquier `OSError` de
`fsync(dir_fd)`. Un `EIO` inyectado devolvió éxito. Solo pueden tolerarse errores
documentados como no soportados; los errores reales de E/S deben activar
recuperación o escalado. También deben sincronizarse directorios de estado,
backups y recibos.

### F5 — MEDIO — inputs y backups sin anclaje seguro

En `scripts/materialize-protected.py:790`, `lstat` queda separado del `open()`
posterior por ruta. Sustituir el manifiesto por un symlink tras validarlo fue
aceptado; sustituir `backups/` por un symlink permitió leer un respaldo externo.
Inputs, estado y backups deben resolverse por descriptores con `O_NOFOLLOW` y
validarse mediante `fstat` sobre el mismo objeto consumido.

### F6 — MEDIO — rollback ignora deriva de permisos

En `scripts/materialize-protected.py:952`, basta que coincidan los bytes. Tras
cambiar una postimagen de modo 0644 a 0600, rollback devolvió 0 y la hizo 0644.
Debe validar conjuntamente bytes y modo y definir transiciones válidas según el
resultado del recibo.

### F7 — MEDIO — FIFO bloquea la ejecución headless

En `scripts/materialize-protected.py:389`, el destino se abre en modo bloqueante
antes de comprobar su tipo. Un FIFO sin escritor bloqueó hasta timeout. Debe
abrirse sin bloqueo, comprobarse de inmediato con `fstat`, rechazarse todo tipo
no regular y aplicarse límites de tamaño.

### F8 — MEDIO — cobertura adversarial insuficiente

En `tests/materializer/test_apply_failures.py:193`, el token fijo se consume al
crear la transacción y no provoca la colisión del temporal de destino que la
prueba dice verificar. La suite tampoco cubre F1–F7; todos se reprodujeron con
78/78 pruebas existentes en verde. Deben añadirse reproducciones deterministas
con oráculos de código, recibo, huellas, modos y árbol afectado.

## Comprobaciones sin hallazgos

Pasaron las 78 pruebas y los controles de integridad del diff, alcance,
workflows, ayuda y `ACTIVE: WP-013`. El diff no incorpora WP-009. El coste
registrado y su huella concuerdan: `9.1971 EUR`, clasificado `estimado`.

## Veredictos

- Code review: rechazado.
- Security review: rechazado.
- Veredicto único: **NO APTO**.

Los ocho hallazgos son incumplimientos contractuales, no mejoras laterales. El
expediente registra 2/2 ciclos consumidos; esta revisión no autoriza un tercero.
