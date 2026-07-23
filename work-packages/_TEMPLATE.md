# WP-XXX — <título>

estado: draft | ready | in_progress | in_review | done | blocked
prioridad: P0 | P1 | P2
agente_responsable: implementer     agente_revisor: code-reviewer
requisitos: [REQ-...]               adr: [ADR-...]
presupuesto_max_eur: 75             max_ciclos_correccion: 2

<!--
CÓMO USAR ESTA PLANTILLA
- Copia a work-packages/WP-XXX-descripcion.md y rellena TODAS las secciones.
- Definition of Ready: sin objetivo, alcance, archivos permitidos, comandos de
  validación y criterios de aceptación, el WP NO pasa a 'ready'.
- La sección "Archivos permitidos" la aplica .claude/hooks/guard.sh de forma
  determinista: lo que no esté listado, no se puede escribir. No es una
  recomendación.
- Guía para redactar un buen WP: docs/manual/03-redactar-un-wp.md
-->

## Objetivo y contexto

<!-- Una frase con el ESTADO FINAL, no la actividad.
     Bien: "El endpoint /pagos rechaza importes negativos con HTTP 400."
     Mal:  "Mejorar la validación de pagos."
     Debajo, el contexto mínimo para entenderlo sin preguntar. -->

## Alcance (incluido / fuera de alcance)

**Incluido:**
-

**Fuera de alcance:**
<!-- Explícito. Lo que no se escribe aquí acaba implementándose "de propina". -->
-

## Archivos permitidos

<!-- Rutas o globs concretos, uno por línea, con guion. Los aplica guard.sh.
     Sintaxis:  *  = cualquier cosa salvo /     **  = cualquier cosa incluido /
     "Todo el repo" NO es una lista válida. -->
-

## Archivos prohibidos

<!-- Prohibición explícita: gana sobre "permitidos". Útil cuando un glob amplio
     debe tener excepciones. Escribe "ninguno" si no aplica. -->
- ninguno

## Contratos técnicos (interfaces, schemas, eventos, invariantes)

<!-- Firmas, tipos, formatos de evento, invariantes que deben seguir siendo
     ciertos después del cambio. Si el WP no cambia contratos, dilo. -->

## Entorno autorizado (herramientas, comandos, red, secretos)

- Herramientas:
- Comandos:
- Red: NINGUNA salvo lista explícita
- Secretos: NINGUNO salvo lista explícita

## Verificación (comandos de validación + criterios de aceptación medibles)

**Comandos** (ejecutables en headless, sin interacción, código de salida significativo):

```bash
```

**Criterios de aceptación** (verificables por un tercero, sin interpretar):

- [ ]

## Evidencias exigidas (qué debe aparecer en evidence/WP-XXX/)

- [ ] Salida íntegra de cada comando de validación, con su código de salida
- [ ] `cost.md` con el coste de la sesión
- [ ]

## Condiciones de parada específicas

<!-- Además de las generales de CLAUDE.md, las propias de este WP. -->
-

## Migración / rollback

<!-- Cómo se revierte si sale mal. Si no hay migración, escribe "no aplica". -->
