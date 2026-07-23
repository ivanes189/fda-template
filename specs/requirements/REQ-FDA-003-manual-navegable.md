# REQ-FDA-003 — El manual es navegable y no tiene enlaces rotos

**Id:** REQ-FDA-003 · **Categoría:** NFR (mantenibilidad, operabilidad) · **Estado:** activo · **Fecha:** 2026-07-23

## Texto

Todo enlace interno de `docs/manual/**` y de `CLAUDE.md` debe resolver a un archivo existente del repositorio. Cada documento del manual debe ser alcanzable desde `docs/manual/MANUAL.md` en un número finito de saltos.

Un enlace roto en el manual es un defecto que bloquea la PR, no una errata cosmética.

## Justificación

La FDA se apoya en un principio explícito: **debe poder operarse sin memoria conversacional**. Todo el conocimiento operativo vive en el manual, y los agentes son remitidos a él desde `CLAUDE.md` y desde sus propias definiciones.

Un enlace roto en ese sistema no es un inconveniente estético: es conocimiento operativo inaccesible en el momento en que alguien —persona o agente— lo necesita. Si `05-bloqueos-y-parada.md` no se alcanza, la condición de parada correspondiente deja de estar documentada en la práctica, aunque el archivo exista.

## Criterio de verificación

1. `python3 evidence/WP-000/checks/check-manual.py` devuelve código de salida `0`.
2. Cero enlaces internos rotos entre los archivos analizados (`docs/manual/*.md` y `CLAUDE.md`).
3. Todo archivo de `docs/manual/` está enlazado desde `MANUAL.md`, directa o indirectamente.
4. La comprobación se ejecuta en el job `Gobierno FDA` de CI y es bloqueante.

Quedan excluidos de la comprobación los enlaces `http(s)://` y las anclas puras (`#seccion`): los primeros exigirían red, y los segundos no son verificables sin analizar la estructura de encabezados.

## Verificación actual

| Punto | Estado |
|---|---|
| Enlaces internos | Cumplido — 30 comprobados, 0 rotos |
| Alcanzabilidad desde `MANUAL.md` | Cumplido — los 7 capítulos están en el índice |
| Ejecución bloqueante en CI | Cumplido — paso «Manual sin enlaces rotos» del job `gobierno` |

## Deuda declarada

El índice definitivo del manual (16 capítulos) está propuesto en `FDA-diagnostico-y-plan-fase1.md` §6. Hoy existen 8 de esos documentos. Los capítulos ausentes se redactarán en WPs de documentación posteriores a la calibración; el glosario (`14-glosario.md`) lo siembra WP-001.

Mientras tanto, este requisito exige que **lo que existe** esté íntegro y navegable, no que exista todo lo planeado.

## Trazabilidad

- Implementa: WP-001 (glosario y saneado de enlaces), WP-004 (actualización de avisos)
- Origen: `FDA-diagnostico-y-plan-fase1.md` §6
- Relacionado: [`CLAUDE.md`](../../CLAUDE.md) (regla de documentación)
