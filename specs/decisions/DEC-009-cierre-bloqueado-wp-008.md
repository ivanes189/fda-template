# DEC-009 — Cierre bloqueado de WP-008 D6-A y parada de la secuencia

**Estado:** aceptada · **Fecha:** 2026-09-21 · **Ámbito:** cierre
administrativo bloqueado de WP-008 D6-A, transición de `ACTIVE` a reposo y
suspensión de la secuencia posterior hasta decisión nueva

**Origen:** revisión Astra C5 `NO APTO`, C5 sin margen suficiente para otra
corrección y el A/B reservado, y autorización humana que prohíbe C6 y ordena el
cierre `blocked` si C5 no queda revalidado.

## Problema

WP-008 D6-A debía entregar conjuntamente el núcleo fail-closed y un humo A/B
seguro y atribuible. Los cambios estructurales y sus pruebas deterministas
avanzaron, y los protegidos se aplicaron humanamente en el worktree dedicado,
pero el oráculo del humo siguió produciendo falsos negativos adversariales.

Tras C5, Astra cerró el hallazgo ALTO anterior, pero mantuvo abierto un hallazgo
MEDIO: una lista dentro de `tool_use_result.content` puede declarar un
identificador ajeno y colapsar indebidamente dos apariciones a una. También
demostró que dos regresiones añadidas no reproducen la mutación original. El
último intento de corrección acabó por límite de turnos sin cambios. No hay A/B
final apto, no hay C6 autorizado y el contrato prohíbe cerrar como `done` con
ese estado.

## Decisión

1. **WP-008 queda `blocked`, no entregado.** El contrato pasa de `ready` a
   `blocked`; registra `5 / 2`, preservando C3–C5 como excepciones humanas y sin
   renumerarlas. No se declara cumplido ningún criterio de salida que dependía
   de WP-008.
2. **`ACTIVE` vuelve a reposo en el mismo diff.** Es un cierre administrativo
   solidario, no una fusión de implementación ni una rehabilitación del
   runtime.
3. **La candidata queda preservada fuera de la PR.** Rama, worktree, commits,
   implementación, protegidos y paquete no se importan, publican, ejecutan,
   corrigen, reutilizan ni eliminan. Se etiquetan **CANDIDATA HISTÓRICA NO
   CONFORME — NO EJECUTAR**. Solo se incorporan las evidencias textuales de la
   composición cerrada.
4. **No se ejecuta el A/B final y no existe C6.** Los dos humos previos siguen
   siendo inconclusos; ninguno se transforma en éxito por declaración.
5. **La secuencia se detiene en reposo.** DEC-003 y la hoja de ruta suponían
   que WP-008 se fusionaría antes de WP-002. Este cierre no satisface esa
   precondición y no autoriza preparar, corregir, activar ni ejecutar WP-002,
   WP-005, WP-007, E2, WP-012 u otro sucesor. Continuar exige una decisión
   humana nueva, preparada y revisada desde reposo, que elija recuperación,
   sustitución o cambio de secuencia.
6. **La pausa DEC-003 continúa.** Solo la condición de los diez pins permanece
   cumplida por WP-014. Las condiciones de runtime fail-closed y control de
   alcance/sandbox siguen pendientes.

## Enmienda declarativa de la secuencia

Esta decisión enmienda por declaración la continuidad desde el paso 4 de la
secuencia vigente de DEC-003 y su reproducción en la hoja de ruta. Los textos
históricos de DEC-005, DEC-006 y DEC-007 permanecen intactos.

Los pasos anteriores:

> 4. WP-008 núcleo según D6.
> 5. Humo seguro dentro de WP-008; si falla, WP-008 no se cierra.

se sustituyen en el estado actual por:

1. **O/T** — esta PR de operador registra WP-008 D6-A como `blocked` y escribe
   reposo en `ACTIVE` en el mismo diff, sin importar la candidata;
2. **PARADA** — ninguna transición posterior de `ACTIVE` hasta que una decisión
   humana nueva y revisada resuelva el rumbo.

“Cerrar bloqueado” significa terminar el intento administrativo sin entregarlo;
no contradice la regla “si falla el humo, WP-008 no se cierra” en su sentido de
aceptación: WP-008 nunca se marca `done`, nunca se fusiona y nunca satisface el
criterio de salida.

## Composición atómica

Esta decisión se admite modificando DEC-003 en el mismo diff y no se
autoautoriza. Los siguientes **dieciocho archivos** viajan juntos o ninguno:

1. `specs/decisions/DEC-009-cierre-bloqueado-wp-008.md`
2. `specs/decisions/DEC-003-pausa-migracion-y-contencion.md`
3. `docs/03-hoja-de-ruta.md`
4. `docs/manual/05-bloqueos-y-parada.md`
5. `work-packages/WP-008-runtime-fail-closed.md`
6. `work-packages/ACTIVE`
7. `evidence/WP-008/CIERRE-BLOQUEADO.md`
8. `evidence/WP-008/MANIFIESTO-CANDIDATA-C5.md`
9. `evidence/WP-008/cost.md`
10. `evidence/WP-008/atestacion-coste.md`
11. `evidence/WP-008/coste-f1.md`
12. `evidence/WP-008/aplicacion-humana.md`
13. `evidence/WP-008/actualizacion-humana-c5.md`
14. `evidence/WP-008/revision-astra.md`
15. `evidence/WP-008/revision-astra-enfocada-c5.md`
16. `evidence/WP-008/revision-astra-enfocada-c5-correccion-1.md`
17. `evidence/WP-008/revision-astra-enfocada-c5-correccion-2.md`
18. `evidence/WP-008/INTERRUPCION-C5-LIMITE-PRESUPUESTO.md`

De las 78 rutas candidatas, esta composición redacta de nuevo `cost.md` y copia
exactamente ocho evidencias textuales. Las otras 69 rutas quedan fuera; no se
importa la implementación.

## Coste

Las quince invocaciones F1 suman `41.9783256 USD`. Al tipo mensual congelado
`1.1590 USD/EUR`, el coste es `36.22 EUR`, consumo `90.5 %` del máximo
contractual de `40 EUR`. La cifra incluye resultados con error y las cuatro
intentos de humo; no incluye un A/B final inexistente. Iván
atestiguó expresamente el registro agregado antes de autorizar esta
materialización.

## Consecuencias y límites

- Se evita seguir gastando en un verificador no apto y se conserva la historia
  reproducible del intento.
- `main` no recibe el núcleo, el preflight, el humo, los protegidos ni ninguna
  afirmación de seguridad del candidato.
- El coste es hundido y WP-008 no cuenta como WP aceptado.
- No se deduce que las reglas del runtime sean inseguras; lo demostrado es que
  el verificador candidato puede aceptar una salida sintética ambigua.
- No se autoriza por analogía la candidata R2, WP-012 ni otra implementación.

## Verificación

- `git diff --check`
- diff limitado a los dieciocho archivos de la composición
- `bash tests/governance/check-active.sh` → reposo y salida `0`
- WP-008 declara `blocked`, no `done`, y `5 / 2`
- las condiciones primera y tercera de DEC-003 siguen sin marcar
- ningún workflow, protegido, R2, WP-012, WP-002, WP-005, WP-007 o ruleset se
  modifica
- hashes de las ocho copias textuales y del manifiesto coinciden
