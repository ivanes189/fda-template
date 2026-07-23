# Evidencia 5 — Manual: enlaces y placeholders

**WP:** WP-000 · **Fecha:** 2026-07-23 · **Comando:** `python3 evidence/WP-000/checks/check-manual.py`
**Resultado: 0 fallos (exit 0)**

## Enlaces internos

```
--- Enlaces internos (9 archivos) ---
  OK    docs/manual/01-instalacion.md
  OK    docs/manual/02-ciclo-de-un-wp.md
  OK    docs/manual/03-redactar-un-wp.md
  OK    docs/manual/04-agentes.md
  OK    docs/manual/05-bloqueos-y-parada.md
  OK    docs/manual/06-costes-y-metricas.md
  OK    docs/manual/07-troubleshooting.md
  OK    docs/manual/MANUAL.md
  OK    CLAUDE.md

  Enlaces internos comprobados: 30
```

**30 enlaces internos, 0 rotos.** Cada destino relativo resuelve a un archivo existente. Se excluyen enlaces `http(s)://` y anclas puras (`#...`), que no se pueden verificar sin red.

## Placeholders de instalación

```
--- Placeholders en docs/manual/01-instalacion.md ---
  OK    {{COMANDOS_VALIDACION}}
  OK    {{PROPIEDAD_COMPONENTES}}
  OK    {{PRESUPUESTOS_Y_MODELOS}}

--- Placeholders en los archivos parametrizados ---
  OK    CODEOWNERS                         {{PROPIEDAD_COMPONENTES}}
  OK    .github/workflows/ci.yml           {{COMANDOS_VALIDACION}}
  OK    .github/workflows/claude.yml       {{PRESUPUESTOS_Y_MODELOS}}
  OK    .github/workflows/code-review.yml  {{PRESUPUESTOS_Y_MODELOS}}
```

### Dónde vive cada placeholder y por qué

| Placeholder | Forma en el repo | Decisión de diseño |
|---|---|---|
| `{{PROPIEDAD_COMPONENTES}}` | **Literal** en `CODEOWNERS` | El archivo es 100 % específico del proyecto; cualquier valor por defecto sería activamente incorrecto |
| `{{COMANDOS_VALIDACION}}` | **Marcador en comentario** en `ci.yml`, con defaults funcionales | Un `{{...}}` literal en un `run:` dejaría el CI de la plantilla roto de fábrica y haría inservible la Fase 1 sobre el propio repo |
| `{{PRESUPUESTOS_Y_MODELOS}}` | **Marcador en comentario** en `claude.yml` y `code-review.yml`; valores reales en `_TEMPLATE.md` y agentes | Igual: los agentes deben ser cargables desde el primer minuto |

Los tres aparecen **literalmente** en `docs/manual/01-instalacion.md`, con una tabla de qué archivo toca cada uno y el `sed` de sustitución. El comando para localizarlos todos:

```bash
grep -rn "{{COMANDOS_VALIDACION}}\|{{PROPIEDAD_COMPONENTES}}\|{{PRESUPUESTOS_Y_MODELOS}}" . --exclude-dir=.git
```

Los cuatro archivos parametrizados se comprueban ahora de forma automática. `check-manual.py` exige el marcador `{{PRESUPUESTOS_Y_MODELOS}}` en `claude.yml` y `code-review.yml` desde que ambos existen: si alguien los reescribe sin él, la verificación 5 falla y el job `Gobierno FDA` bloquea la PR.

## Contenido del manual

| Archivo | Cubre |
|---|---|
| `MANUAL.md` | Índice, mapa del repo, los 3 controles deterministas |
| `01-instalacion.md` | Copia, los 3 valores, checklist de GitHub, verificación, errores frecuentes |
| `02-ciclo-de-un-wp.md` | Los 8 pasos con comandos exactos + los dos modos de ejecución |
| `03-redactar-un-wp.md` | 1 ejemplo bueno comentado + 1 malo con 8 anotaciones de por qué fallaría |
| `04-agentes.md` | Tabla de decisión, ficha por agente, qué no harán nunca, límites conocidos |
| `05-bloqueos-y-parada.md` | Las 8 condiciones de parada, una a una, con protocolo |
| `06-costes-y-metricas.md` | `/cost`, formato de `cost.md`, telemetría OTel, las 4 métricas y cómo leerlas |
| `07-troubleshooting.md` | Hook, CI, agentes que no cargan, el hueco de Bash, el bootstrap bloqueado |

Requisito cubierto: la FDA se puede operar sin memoria conversacional.
