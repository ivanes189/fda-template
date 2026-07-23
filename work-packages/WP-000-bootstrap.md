# WP-000 — Bootstrap de la plantilla fda-template (Fase 0)

estado: in_progress
prioridad: P0
agente_responsable: implementer     agente_revisor: code-reviewer
requisitos: []                      adr: [ADR-001]
presupuesto_max_eur: 75             max_ciclos_correccion: 2

## Objetivo y contexto

El repositorio plantilla `fda-template` existe, está documentado y es SDK-ready: contiene la estructura del §2 de la guía, los 5 agentes del §3, las 3 skills, el hook determinista `guard.sh`, las plantillas de WP y PR, los 3 workflows y un manual de usuario que permite operar la FDA sin memoria conversacional.

Contexto: Fase 0 del plan de implantación (§7 de `docs/02-guia-fabrica-desarrollo-agentica.md`). Este WP es el único que se ejecuta sin un WP previo que lo autorice, por ser el que crea el propio sistema de gobierno.

## Alcance (incluido / fuera de alcance)

**Incluido:**
- Estructura de directorios y archivos del §2 de la guía.
- Los 5 agentes del §3 con frontmatter válido.
- `settings.json` con permisos y hook `PreToolUse`; `guard.sh` funcional y fail-closed.
- Las 3 skills: `new-work-package`, `run-verification`, `prepare-pr`.
- `work-packages/_TEMPLATE.md`, este WP y `work-packages/ACTIVE`.
- `specs/` con `ADR-001-runtime.md`.
- `.github/` con plantilla de PR y los 3 workflows.
- `docs/manual/` completo (8 archivos) y la guía fundacional versionada.
- Evidencias de la verificación de Fase 0 en `evidence/WP-000/`.

**Fuera de alcance:**
- Cualquier configuración en GitHub remoto (branch protection, secretos, Dependabot). Queda documentada en `docs/manual/01-instalacion.md` para ejecución humana.
- Crear el remoto, hacer push o abrir PRs.
- Código de aplicación de cualquier tipo. Esto es infraestructura de gobierno, no producto.
- Los WPs de calibración de la Fase 1: se proponen al final, no se ejecutan.

## Archivos permitidos

- CLAUDE.md
- CODEOWNERS
- .gitignore
- FDA-diagnostico-y-plan-fase1.md
- .claude/**
- docs/**
- specs/**
- work-packages/**
- evidence/**
- tests/**
- .github/**

<!-- AMPLIACIÓN DE ALCANCE — 2026-07-23, Paso 0 de la Fase 1.
     Añadidos `tests/**` y `FDA-diagnostico-y-plan-fase1.md` por decisión humana
     explícita, para alojar la suite adversarial del guard (tarea 6 del Paso 0)
     y versionar el plan vinculante de la Fase 1.
     Ampliación consciente y con rastro, conforme a docs/manual/05-bloqueos-y-parada.md. -->


## Archivos prohibidos

- .env*
- **/secrets/**
- **/*.pem

## Contratos técnicos (interfaces, schemas, eventos, invariantes)

**Contrato del hook `guard.sh`** (lo consume Claude Code, no puede cambiar sin romper la FDA):

- Entrada: JSON por stdin con `.tool_name`, `.tool_input.file_path`, `.cwd`.
- Salida: código de salida `0` = permitir, `2` = bloquear (stderr se devuelve al agente).
- Invariante **fail-closed**: ante ausencia de `ACTIVE`, WP ilegible o sección `## Archivos permitidos` vacía, deniega. Nunca deja pasar por error.
- Precedencia: `## Archivos prohibidos` gana sobre `## Archivos permitidos`.

**Contrato de `work-packages/ACTIVE`**: archivo de texto; primera línea no vacía y no comentada (`#`) es el WP-ID en curso. Es el único estado operativo mutable, y vive en el repo, no en la sesión.

**Sintaxis de globs**: `*` no cruza `/`; `**` sí. Un patrón terminado en `/` cubre todo su contenido.

## Entorno autorizado (herramientas, comandos, red, secretos)

- Herramientas: Read, Grep, Glob, Edit, Write, Bash.
- Comandos: `git` (local: init, add, commit, status, diff, log), `bash`, `python3`, `jq`, `find`, `grep`, `awk`, `sed`.
- Red: NINGUNA. La verificación de Fase 0 se ejecuta íntegra offline.
- Secretos: NINGUNO.

## Verificación (comandos de validación + criterios de aceptación medibles)

**Comandos** (headless, sin interacción, código de salida significativo):

```bash
# 1. Estructura contra el §2 de la guía
bash evidence/WP-000/checks/check-structure.sh

# 2. Agentes y skills cargables (frontmatter válido y rutas correctas)
python3 evidence/WP-000/checks/check-agents-skills.py

# 3. El hook bloquea fuera de alcance y permite dentro
bash evidence/WP-000/checks/check-guard.sh

# 4. Workflows válidos sintáctica y estructuralmente
python3 .claude/skills/run-verification/validate-workflows.py .github/workflows

# 5. Manual sin enlaces rotos y con los 3 placeholders presentes
python3 evidence/WP-000/checks/check-manual.py
```

**Criterios de aceptación:**

- [ ] La estructura resultante contiene todos los archivos y directorios del §2, sin elementos no pactados.
- [ ] Los 5 agentes y las 3 skills tienen frontmatter válido y están en las rutas que lee Claude Code.
- [ ] `guard.sh` deniega (exit 2) una escritura fuera de las rutas permitidas y permite (exit 0) una escritura dentro.
- [ ] `guard.sh` deniega también si falta `ACTIVE`, si está vacío o si el WP no declara rutas permitidas (fail-closed demostrado).
- [ ] Los 3 workflows parsean como YAML válido y declaran `name`, `on` y `jobs` con `runs-on` y `steps`.
- [ ] Todos los enlaces internos del manual resuelven a archivos existentes.
- [ ] Los 3 placeholders (`{{COMANDOS_VALIDACION}}`, `{{PROPIEDAD_COMPONENTES}}`, `{{PRESUPUESTOS_Y_MODELOS}}`) aparecen en `docs/manual/01-instalacion.md`.
- [ ] `evidence/WP-000/cost.md` existe y registra el coste de la sesión.

## Evidencias exigidas (qué debe aparecer en evidence/WP-000/)

- [ ] `01-estructura.md` — listado comentado contra el §2.
- [ ] `02-agentes-skills.md` — resultado de la carga de agentes y skills.
- [ ] `03-bloqueo-hook.md` — salida literal del hook denegando, incluidos los casos fail-closed.
- [ ] `04-workflows.md` — validación de los 3 workflows.
- [ ] `05-manual.md` — enlaces y placeholders.
- [ ] `cost.md` — coste de la sesión.
- [ ] `checks/` — los scripts ejecutables que producen lo anterior (reproducibles en headless).

## Condiciones de parada específicas

- Si la estructura del §2 y este prompt se contradicen en algún punto no resuelto por la regla de precedencia: parar y preguntar.
- Si `guard.sh` no consigue bloquear de forma determinista: parar. Sin ese control, la FDA es prosa y no gobierno.
- Si una verificación requiere red o interacción humana: parar y rediseñarla headless.

## Migración / rollback

No aplica: es la creación inicial del repositorio. Rollback = `git reset --hard` al commit anterior, o borrar la carpeta. No hay datos que migrar ni consumidores externos.
