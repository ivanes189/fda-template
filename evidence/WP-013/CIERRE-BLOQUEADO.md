# Cierre bloqueado — WP-013

Fecha: 2026-09-13

Resultado: **bloqueado; no entregado**

Ciclos: **C1, C2 y C3 excepcional consumidos; C4 no autorizado**

## Motivo

La revisión independiente completa rechazó el candidato por F1–F8. Después de
C3, una única revisión enfocada volvió a rechazarlo por H1–H4: recuperación que
puede declarar una preimagen inexistente (ALTO), escalado dependiente de poder
persistir el recibo, reapertura insegura del parche por Git y rollback sin
validación de transiciones por resultado.

Las 89 pruebas verdes no reproducen esos cuatro fallos. Por tanto no existe
base para declarar el materializador seguro ni para usarlo sobre rutas
protegidas.

## Resultado administrativo

- El contrato pasa a `estado: blocked`, nunca `done`.
- `ACTIVE` vuelve a reposo en el mismo diff.
- La candidata queda fuera del cierre, preservada y marcada **CANDIDATA
  HISTÓRICA NO CONFORME — NO EJECUTAR**.
- No se abre C4, no se crea ni activa WP-014 y no se modifican workflows.
- DEC-008 retira la dependencia de un materializador general y limita la ruta
  futura a un parche Git exacto de los diez pins, aplicado humanamente en un
  worktree limpio y dedicado, sujeto a contrato y autorizaciones posteriores.

## Evidencia

- Revisión completa: `revision-astra.md` — **NO APTO**.
- Revisión enfocada C3: `revision-astra-enfocada-c3.md` — **NO APTO**.
- Coste: `cost.md` — `16.6085 EUR / 20 EUR`.
- Identidad de la candidata: `MANIFIESTO-CANDIDATA-C3.md`.

Este cierre no afirma que Git sea un sandbox ni una transacción general. El
único uso futuro admitido es el cambio cerrado de diez referencias y su
recuperación por descarte y recreación del worktree dedicado; cualquier fallo
del repositorio compartido o del almacenamiento exige parada y escalado.
