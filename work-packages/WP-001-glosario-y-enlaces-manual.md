# WP-001 — Glosario semilla y saneado de enlaces del manual

estado: draft
prioridad: P2
agente_responsable: implementer     agente_revisor: code-reviewer
requisitos: [REQ-FDA-003]           adr: []
presupuesto_max_eur: 10             max_ciclos_correccion: 2

## Objetivo y contexto

`docs/manual/14-glosario.md` existe con al menos 15 términos de la FDA, cada uno explicado en 3 líneas o menos, y el manual no tiene ningún enlace interno roto.

Contexto: primer WP de calibración de la Fase 1. Su función es **recorrer el ciclo completo** —WP → rama → PR → CI → revisión → merge— con riesgo casi nulo, para fijar el coste y la fricción de referencia contra los que se compararán los demás. El valor del glosario es real pero secundario; lo que se está midiendo aquí es la mecánica.

El índice definitivo del manual (`FDA-diagnostico-y-plan-fase1.md` §6) reserva el número 14 para el glosario. Este WP lo siembra; el resto de capítulos ausentes se redactarán después de la calibración.

## Alcance (incluido / fuera de alcance)

**Incluido:**
- Crear `docs/manual/14-glosario.md` con ≥15 términos, cada uno de ≤3 líneas.
- Enlazar el glosario desde el índice de `docs/manual/MANUAL.md`.
- Corregir enlaces internos rotos del manual, si el link-check detecta alguno.

**Fuera de alcance:**
- Redactar cualquier otro capítulo del índice propuesto en §6.
- Reorganizar o renumerar los capítulos existentes.
- Modificar el contenido de los capítulos existentes salvo para arreglar un enlace roto.
- Cualquier cambio fuera de `docs/manual/`.

## Archivos permitidos

- docs/manual/**
- evidence/WP-001/**

## Archivos prohibidos

- CLAUDE.md
- .claude/**
- work-packages/**
- .github/**

## Contratos técnicos (interfaces, schemas, eventos, invariantes)

- Cada entrada del glosario: un encabezado de tercer nivel (`###`) con el término, y debajo su definición en 3 líneas físicas no vacías o menos (las líneas en blanco no cuentan).
- El glosario queda enlazado desde `MANUAL.md`, de modo que sea alcanzable navegando desde el índice (REQ-FDA-003).
- Los enlaces internos son relativos y resuelven a archivos existentes.
- No cambia ningún contrato de la FDA: es documentación.

## Entorno autorizado (herramientas, comandos, red, secretos)

- Herramientas: Read, Grep, Glob, Edit, Write, Bash
- Comandos: `python3`, `git` (local), `grep`, `find`
- Red: NINGUNA
- Secretos: NINGUNO

## Verificación (comandos de validación + criterios de aceptación medibles)

**Comandos** (headless, sin interacción, código de salida significativo):

```bash
python3 evidence/WP-000/checks/check-manual.py
git diff --name-only main...HEAD
test "$(grep -c '^### ' docs/manual/14-glosario.md)" -ge 15        # exit 0 si el glosario tiene ≥15 términos
grep -q '14-glosario\.md' docs/manual/MANUAL.md                    # exit 0 si el glosario está enlazado desde el índice
! git diff --name-only main...HEAD | grep -vE '^(docs/manual/|evidence/WP-001/)'   # exit 0 si no hay rutas fuera de alcance
```

**Criterios de aceptación:**

- [ ] `docs/manual/14-glosario.md` existe y contiene **≥ 15** términos
- [ ] Ninguna entrada del glosario supera las **3 líneas** de definición
- [ ] `check-manual.py` devuelve exit 0 (0 enlaces rotos y los 3 placeholders de instalación presentes)
- [ ] El glosario está enlazado desde `docs/manual/MANUAL.md`
- [ ] `git diff --name-only main...HEAD` devuelve **únicamente** rutas bajo `docs/manual/` o `evidence/WP-001/`
- [ ] CI en verde sobre la PR (lo verifica el humano en el paso 6 del ciclo)

## Evidencias exigidas (qué debe aparecer en evidence/WP-001/)

- [ ] Salida íntegra de `check-manual.py` con su código de salida
- [ ] Salida de `git diff --name-only main...HEAD`
- [ ] `cost.md` con el formato de DEC-001 (USD crudo, tipo del mes, EUR)

## Condiciones de parada específicas

- Cualquier necesidad de tocar un archivo fuera de `docs/manual/`.
- Si el link-check revela enlaces rotos que apuntan a capítulos aún no redactados: parar y consultar, porque la solución podría ser crear documentos fuera del alcance de este WP.
- Si el enlace roto está en `CLAUDE.md`: parar y consultar — es un archivo prohibido para este WP.

## Migración / rollback

No aplica: solo documentación. Rollback = revertir el commit o cerrar la PR sin fusionar.
