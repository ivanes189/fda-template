# Constitución de la FDA

Normas que todo agente carga siempre. Son vinculantes y no se negocian en conversación.
Documento fundacional: [`docs/02-guia-fabrica-desarrollo-agentica.md`](docs/02-guia-fabrica-desarrollo-agentica.md).
Manual de operación: [`docs/manual/MANUAL.md`](docs/manual/MANUAL.md).

## Fuente de verdad

- La fuente de verdad es **este repositorio** (`specs/`, `work-packages/`, `specs/adr/`). La memoria conversacional no lo es.
- Todo el estado operativo vive en archivos versionados: `work-packages/ACTIVE`, estado de cada WP en su frontmatter, evidencias en `evidence/`. Nada de estado en la sesión.
- Si un dato no está en un archivo del repo, no existe. No lo asumas: pídelo.

## Alcance del trabajo

- Un agente trabaja sobre **un único WP aprobado**. Sin WP, no hay cambios.
- Solo se modifican los archivos permitidos por el WP activo (`## Archivos permitidos`). El hook `.claude/hooks/guard.sh` lo hace cumplir de forma determinista.
- Si necesitas tocar un archivo fuera de esa lista: **detente y solicita decisión**. No amplíes el alcance por tu cuenta.

## Calidad

- Todo cambio lleva pruebas. Toda función nueva lleva pruebas.
- Antes de dar nada por terminado, ejecuta los comandos de validación del WP y guarda las salidas en `evidence/WP-XXX/`.
- La deuda técnica se declara explícitamente. Deuda no declarada = trabajo no entregado.

## Prohibiciones absolutas

Nunca: exponer o leer secretos; modificar CI/CD, `CODEOWNERS` o permisos; fusionar tus propias PRs; hacer force-push; borrar historial; introducir deuda no declarada; desactivar o eludir hooks, linters o pruebas para que algo pase.

## Condiciones de parada obligatoria

Detente y solicita decisión humana ante: requisito ambiguo, contradicción entre requisitos, cambio de ADR necesario, migración con riesgo de pérdida de datos, vulnerabilidad detectada, pruebas inejecutables, coste fuera de presupuesto, o tercer ciclo de corrección.
Detalle y protocolo de cada una: [`docs/manual/05-bloqueos-y-parada.md`](docs/manual/05-bloqueos-y-parada.md).

## Ejecución headless

Nada en agentes, skills o hooks puede asumir una sesión interactiva. Todo comando de verificación debe poder ejecutarse sin humano delante (sin prompts, sin TTY, con código de salida significativo). Ver [`specs/adr/ADR-001-runtime.md`](specs/adr/ADR-001-runtime.md).

## Documentación

Todo cambio de proceso, contrato o agente actualiza `docs/manual/` en la misma PR. Manual desactualizado = PR incompleta.

## Convenciones

- Ramas: `wp/WP-XXX-descripcion` · Un WP = una rama = una PR.
- Commits: `WP-XXX: <cambio>` en imperativo, pequeños y atómicos.
- Evidencias: `evidence/WP-XXX/`. Coste: `evidence/WP-XXX/cost.md`.
- Decisiones: `specs/decisions/DEC-xxx.md` · Arquitectura: `specs/adr/ADR-xxx.md` · Requisitos: `specs/requirements/`.
