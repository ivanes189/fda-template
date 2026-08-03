# Guía de implantación — Fábrica de Desarrollo Agéntica (FDA)

**Fecha:** 2026-07-23 · **Ámbito:** infraestructura transversal, independiente de cualquier proyecto concreto · **Uso previsto:** arrancar la FDA en un hilo y espacio de trabajo nuevos

> Este documento es autocontenido: puedes usarlo como documento fundacional del nuevo hilo. Al final se incluye el prompt de arranque sugerido.

---

## 1. Qué es la FDA y qué no es

La FDA es el sistema con el que agentes de IA especializados implementan software en tus proyectos mediante tareas pequeñas, contratos explícitos, ramas aisladas, PRs, CI bloqueante y supervisión humana. Es la implementación práctica del contrato que ya definiste en content-factory (DEC-019: hojas de encargo, separación de funciones, context packs, condiciones de parada), pero desacoplada: la FDA es una **plantilla reutilizable** que se instala en cada proyecto, no un módulo de ninguno de ellos.

No es un producto que debas construir desde cero. En 2026 el runtime ya existe: **GitHub** (issues, PRs, Actions, rulesets) como plano de control y auditoría, y **Claude Code** como runtime de agentes (subagentes con herramientas, modelo, permisos y hooks propios; ejecución headless; integración nativa con GitHub Actions; aislamiento por git worktree). Tu trabajo es la capa de gobierno: los archivos de configuración, contratos y políticas que se versionan en Git. Eso hace la FDA portable: si mañana cambias de runtime, el gobierno (que es lo valioso) sobrevive.

**Decisión recomendada de stack:** GitHub + Claude Code (CLI) para el trabajo diario, `claude-code-action@v1` para automatización en CI, y Claude Agent SDK solo si más adelante necesitas orquestación programática propia. Alternativas (otros copilotos/agentes) quedan como benchmark posterior; no bloquean el arranque porque el gobierno vive en archivos del repo.

---

## 2. Anatomía: el repo plantilla `fda-template`

Crea un repositorio plantilla (GitHub "template repository") con esta estructura. Instalarlo en un proyecto = copiar estos archivos y ajustar 3 valores.

```
fda-template/
├── CLAUDE.md                        # Constitución: normas que todo agente carga siempre
├── CODEOWNERS                       # Propiedad por componente (revisión obligatoria)
├── .claude/
│   ├── settings.json                # Permisos (allow/deny/ask), hooks globales
│   ├── agents/
│   │   ├── planner.md               # Valida DoR, descompone, no toca código
│   │   ├── implementer.md           # Implementa 1 WP; nunca fusiona
│   │   ├── qa.md                    # Ejecuta y amplía pruebas; solo lee código fuente
│   │   ├── security-reviewer.md     # Revisión de seguridad; solo lectura
│   │   └── code-reviewer.md         # Revisión independiente de la PR
│   ├── hooks/
│   │   └── guard.sh                 # PreToolUse: bloquea rutas protegidas y comandos vetados
│   └── skills/
│       ├── new-work-package/        # Genera WP desde plantilla y valida el contrato
│       ├── run-verification/        # Ejecuta la batería de validación y compila evidencias
│       └── prepare-pr/              # Abre PR con plantilla y evidencias adjuntas
├── specs/
│   ├── decisions/                   # DEC-xxx.md (registro de decisiones, una por archivo)
│   ├── adr/                         # ADR-xxx.md
│   └── requirements/                # REQ por categoría (FR, NFR, SEC, ...)
├── work-packages/
│   ├── _TEMPLATE.md                 # Contrato de hoja de encargo (ver §4)
│   └── WP-000-bootstrap.md
├── evidence/                        # Evidencias por WP (logs, resultados, costes)
└── .github/
    ├── pull_request_template.md     # Checklist de evidencias obligatorias
    └── workflows/
        ├── ci.yml                   # CI bloqueante: lint, tipos, tests, secretos, SAST
        ├── claude.yml               # @claude en issues/PRs (claude-code-action@v1)
        └── code-review.yml          # Revisión automática de cada PR
```

Configuración de GitHub por proyecto (una vez): branch protection/ruleset sobre `main` (PR obligatoria, status checks obligatorios, al menos 1 revisión, prohibido force-push), secret scanning + push protection, Dependabot, y secreto `ANTHROPIC_API_KEY` para los workflows.

---

## 3. Los agentes: mapeo directo de tu contrato DEC-019

Cada agente es un archivo Markdown con frontmatter YAML en `.claude/agents/`. El frontmatter soporta exactamente los controles que tu contrato exige: `tools` (allowlist de herramientas), `disallowedTools`, `model`, `permissionMode`, `maxTurns` (criterio de parada), `hooks` (guardas propias) e `isolation: worktree` (copia aislada del repo). Ejemplo completo del implementador:

```markdown
---
name: implementer
description: Implementa un único work package cerrado. Usar cuando exista un WP aprobado con DoR completa.
tools: Read, Grep, Glob, Edit, Write, Bash
model: sonnet
maxTurns: 60
isolation: worktree
memory: project
---

Eres el agente implementador de la FDA. Reglas no negociables:
1. Trabajas sobre UN work package (WP) cada vez. Si no te han dado un WP-ID, detente y pídelo.
2. Lee primero: el WP completo, sus requisitos y ADR vinculados, y CLAUDE.md.
3. Modifica solo los archivos listados en "Archivos permitidos" del WP. Si necesitas tocar otro, DETENTE y solicita decisión.
4. Toda función nueva lleva pruebas. Ejecuta los comandos de validación del WP antes de dar nada por terminado.
5. Nunca haces merge, nunca despliegas, nunca tocas secretos ni CI/CD salvo que el WP lo autorice.
6. Condiciones de parada obligatoria: requisito ambiguo, contradicción entre requisitos, cambio de ADR necesario,
   migración con riesgo de pérdida de datos, vulnerabilidad detectada, pruebas inejacutables, coste fuera de presupuesto.
7. Al terminar: resumen de cambios, riesgos, deuda introducida y evidencias en evidence/WP-XXX/.
```

Los otros cuatro agentes siguen el mismo patrón con menos permisos: `planner`, `qa`, `security-reviewer` y `code-reviewer` llevan `tools: Read, Grep, Glob, Bash` (sin Edit/Write, salvo qa sobre `tests/`), y el revisor usa modelo premium (`model: opus`) porque tu política ya autoriza modelos premium para revisión crítica, seguridad y arquitectura.

**Separación de funciones (tu §14.1):** se garantiza por construcción — el implementador no tiene permisos de merge (branch protection lo impide a nivel de GitHub, no de prompt), la revisión la hace un agente distinto con contexto limpio, y la fusión es humana durante la calibración. La seguridad no depende de que el modelo obedezca instrucciones: depende de permisos de GitHub, allowlists de herramientas y hooks.

**Guardas deterministas (hooks).** `settings.json` define permisos y hooks globales:

```json
{
  "permissions": {
    "deny": [
      "Read(./.env*)", "Read(./**/secrets/**)",
      "Bash(git push --force*)", "Bash(rm -rf /*)",
      "Edit(./.github/workflows/**)", "Edit(./CODEOWNERS)"
    ],
    "ask": ["Bash(git push*)", "Bash(docker*)"],
    "allow": ["Bash(pytest*)", "Bash(ruff*)", "Bash(mypy*)", "Bash(npm test*)"]
  },
  "hooks": {
    "PreToolUse": [
      { "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": ".claude/hooks/guard.sh" }] }
    ]
  }
}
```

`guard.sh` recibe la llamada de herramienta en JSON y devuelve un código de salida que bloquea la operación si la ruta está fuera del alcance del WP activo (lee `work-packages/ACTIVE` para saber qué WP está en curso y qué rutas permite). Esto convierte "límites de modificación por componente" de prosa a código.

---

## 4. El contrato de work package (hoja de encargo)

Tu contrato de DEC-019 se conserva casi literal. Plantilla `work-packages/_TEMPLATE.md` (compacta; los campos son los tuyos):

```markdown
# WP-XXX — <título>
estado: draft | ready | in_progress | in_review | done | blocked
prioridad: P0 | P1 | P2
agente_responsable: implementer     agente_revisor: code-reviewer
requisitos: [REQ-...]               adr: [ADR-...]
presupuesto_max_eur: 75             max_ciclos_correccion: 2

## Objetivo y contexto
## Alcance (incluido / fuera de alcance)
## Archivos permitidos          ← el hook lo hace cumplir
## Archivos prohibidos
## Contratos técnicos (interfaces, schemas, eventos, invariantes)
## Entorno autorizado (herramientas, comandos, red, secretos: NINGUNO salvo lista)
## Verificación (comandos de validación + criterios de aceptación medibles)
## Evidencias exigidas (qué debe aparecer en evidence/WP-XXX/)
## Condiciones de parada específicas
## Migración / rollback
```

**Definition of Ready:** un WP no pasa a `ready` sin objetivo, alcance, archivos permitidos, comandos de validación y criterios de aceptación. **Definition of Done:** CI en verde, evidencias en `evidence/`, revisión del agente revisor + humana si el riesgo lo exige, y coste registrado.

---

## 5. El ciclo operativo

1. **PO/tú:** creas el WP (skill `new-work-package`) → el `planner` valida DoR y lo trocea si es grande.
2. **Implementación:** `implementer` en worktree aislado y rama `wp/WP-XXX-descripcion`. Un WP = una rama = una PR.
3. **Verificación local:** skill `run-verification` ejecuta la batería del WP y guarda salidas en `evidence/`.
4. **PR:** skill `prepare-pr` abre la PR con la plantilla (qué, por qué, evidencias, riesgos, deuda, rollback).
5. **CI bloqueante:** lint, tipos, tests, cobertura del código modificado, secret scanning, SAST. Rojo = no se fusiona; no hay excepciones conversacionales.
6. **Revisión:** `code-reviewer` (y `security-reviewer` si el WP toca auth/secretos/red/migraciones) comenta la PR. En CI, `code-review.yml` hace esto automáticamente en cada PR.
7. **Fusión:** humana durante la calibración. Más adelante, auto-merge solo para clases de WP de bajo riesgo con historial limpio (tu escala A0–A5 aplicada al desarrollo).
8. **Ciclos de corrección:** máximo 2 ordinarios (tu política). Al tercero: parada, análisis de causa, replanificación.

Dos modos de ejecución, mismos contratos: **interactivo** (tú en Claude Code lanzando los agentes, recomendado para calibración) y **CI** (`@claude implementa WP-014` en un issue; `claude-code-action@v1` lo ejecuta en un runner de GitHub con `--max-turns`, modelo y herramientas limitadas vía `claude_args`). Empieza en interactivo; pasa a CI cuando los contratos estén rodados.

---

## 6. Costes y métricas

Aplica tus umbrales ya decididos (75 € objetivo / 100 € aviso / 150 € aprobación por paquete; 750 € aviso mensual) así: política de modelos por tipo de tarea (premium para arquitectura, seguridad, migraciones, revisión crítica; estándar para implementación; económico para scaffolding y documentación), `maxTurns` por agente, y registro por WP en `evidence/WP-XXX/cost.md`. La convención de divisa está fijada en `specs/decisions/DEC-001-divisa-costes.md` —USD es el registro, EUR el gobierno, el tipo se congela por mes natural— y la adquisición y los estados del coste en `specs/decisions/DEC-004-estados-del-coste.md`: tres fuentes admitidas (F1, JSON estructurado con `total_cost_usd`; F2, agregación de la métrica OpenTelemetry `claude_code.cost.usage`; F3, estimación humana con base concreta y reconstruible), un conjunto cerrado de estados (`medido | estimado | no_disponible`) y ningún marcador en el registro. Métrica principal, como ya definiste: **coste por WP integrado y aceptado**, con % aceptado a la primera, ciclos de corrección medios y regresiones por agente. Los primeros 5 WPs son calibración: no saques conclusiones antes.

---

## 7. Plan de implantación

**Fase 0 — Bootstrap (medio día).** Crear `fda-template` con la estructura del §2: CLAUDE.md, 3 agentes mínimos (implementer, qa, code-reviewer), settings.json con denies básicos, plantillas de WP y PR, ci.yml esqueleto. Configurar branch protection. Criterio de salida: el repo plantilla existe y un `claude` interactivo carga los agentes.

**Fase 1 — Calibración (1 semana).** Proyecto sandbox pequeño (o el propio fda-template). Ejecutar 3–5 WPs reales de principio a fin: uno trivial, uno con pruebas, uno diseñado para fallar (verificar que hooks, condiciones de parada y CI bloquean lo que deben). Registrar coste por WP. Criterio de salida: 3 PRs mergeadas con evidencias completas + 1 bloqueo demostrado.

**Fase 2 — Primer proyecto real.** Instalar la plantilla en `content-factory` y ejecutar en este orden: WP-000 (materializar la baseline v1 como specs-as-code), INF-DISC-001 (inventario solo lectura), CORE-STAB-001/002, SEC-001, CI-001. Estos paquetes ya están definidos en tu baseline; solo hay que volcarlos a la plantilla de WP.

**Fase 3 — Ampliación por evidencia.** Solo con métricas de la Fase 2: `@claude` en issues para clases de WP rodadas, revisión automática en todas las PRs, planner+implementers en paralelo (agent teams / varios worktrees) cuando haya WPs independientes, y subida gradual de autonomía de fusión (A1→A2) por clase de riesgo.

**Anti-patrones que la FDA debe rechazar:** encargos ambiguos ("mejora el backend"), WPs sin comandos de validación, agentes con acceso total "para ir más rápido", fusionar con CI rojo "por esta vez", conclusiones de coste con n=1, y construir orquestación propia antes de haber agotado lo que GitHub + Claude Code ya dan hecho.

---

## 8. Prompt de arranque para el hilo nuevo

> Vas a ayudarme a implantar mi Fábrica de Desarrollo Agéntica siguiendo el documento adjunto `02-guia-fabrica-desarrollo-agentica.md`, que es la especificación vinculante. Empieza por la Fase 0: crea el repo plantilla `fda-template` completo (estructura del §2, agentes del §3, settings del §3, plantillas del §4, workflows del §5). Trabaja en una carpeta local que te montaré. No inventes campos nuevos en los contratos sin proponérmelo. Al terminar la Fase 0, prepara el plan de los 3–5 WPs de calibración de la Fase 1 y espera mi aprobación.

Con la carpeta del proyecto montada en Cowork (o el repo clonado y abierto en Claude Code), ese prompt basta para arrancar sin contexto adicional.

---

## Apéndice — CLAUDE.md de partida (constitución)

```markdown
# Constitución de la FDA
- Fuente de verdad: este repositorio (specs/, work-packages/, ADR). La memoria conversacional no lo es.
- Un agente trabaja sobre un único WP aprobado. Sin WP, no hay cambios.
- Solo se modifican los archivos permitidos por el WP activo.
- Todo cambio lleva pruebas y pasa los comandos de validación del WP.
- Nunca: exponer secretos, tocar CI/CD o permisos, fusionar PRs propias, borrar historial, deuda no declarada.
- Ante ambigüedad, contradicción o riesgo: detenerse y solicitar decisión humana.
- Convenciones: ramas wp/WP-XXX-*, commits "WP-XXX: <cambio>", evidencias en evidence/WP-XXX/.
```
