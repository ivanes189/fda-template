# WP-002 — `check-scope`: verificación determinista de alcance

estado: draft
prioridad: P0
agente_responsable: implementer     agente_revisor: code-reviewer
requisitos: [REQ-FDA-001]           adr: []
presupuesto_max_eur: 40             max_ciclos_correccion: 2

<!-- Revisores: qa (pruebas) + code-reviewer (revisión de la PR). -->

## Objetivo y contexto

`scripts/check_scope.py` existe y, dados un WP-ID y un rango git, devuelve código de salida distinto de cero si el diff toca algún archivo fuera de la sección `## Archivos permitidos` de ese WP, enumerando todas las violaciones. Acompañado de pruebas.

Contexto: es la pieza que cierra por construcción la clase de fallo **B2** del diagnóstico. El hook `guard.sh` es preventivo y su cobertura sobre `Bash` es best-effort —el shell admite vías no enumerables (`python -c "open(...,'w')"`, `eval`, `git apply`)—. La verificación post-hoc sobre el diff mide el **resultado**, no el método: sobre el diff de una PR no hay bypass posible.

Las dos capas son complementarias, no redundantes: el hook evita el error mientras se trabaja; este script lo hace imposible de fusionar. WP-005 lo integrará en CI como check obligatorio.

## Alcance (incluido / fuera de alcance)

**Incluido:**
- `scripts/check_scope.py` con interfaz de línea de comandos: WP-ID y rango git como argumentos.
- Parseo de `## Archivos permitidos` y `## Archivos prohibidos` del WP, con la semántica documentada en `_TEMPLATE.md`.
- Pruebas en `tests/scope/` que cubren los casos mínimos listados en Verificación.

**Fuera de alcance:**
- Integrar el script en CI (eso es WP-005).
- Modificar `guard.sh` o su suite.
- Unificar el parseo con el de `guard.sh` en una librería común: deseable, pero es refactor y no entra aquí.
- Cualquier cambio en workflows.

## Archivos permitidos

- scripts/**
- tests/**

## Archivos prohibidos

- .github/**
- .claude/**
- work-packages/**

<!-- Prohibidos para ESCRITURA. La lectura de work-packages/ es necesaria y está
     permitida: el script debe leer el WP para conocer su alcance. -->

## Contratos técnicos (interfaces, schemas, eventos, invariantes)

**Interfaz:**

```bash
python3 scripts/check_scope.py <WP-ID> <rango-git>
# ejemplo: python3 scripts/check_scope.py WP-014 main...HEAD
```

- **Exit 0:** todos los archivos del diff están dentro del alcance.
- **Exit ≠ 0:** hay al menos una violación. La salida enumera **todas**, no solo la primera, indicando archivo y motivo (fuera de permitidos / coincide con prohibidos).

**Semántica de patrones:** exactamente la documentada en `work-packages/_TEMPLATE.md`, sección «Archivos permitidos». En particular: `*` no cruza `/`, `**` sí, las rutas son relativas a la raíz, prohibidos gana sobre permitidos, y los symlinks no amplían el alcance.

**Invariante crítico:** `check_scope.py` y `guard.sh` deben coincidir en su interpretación de los patrones. Una divergencia entre ambos produciría el peor resultado posible: un cambio que el hook permite y el CI rechaza, o al revés.

## Entorno autorizado (herramientas, comandos, red, secretos)

- Herramientas: Read, Grep, Glob, Edit, Write, Bash
- Comandos: `python3`, `pytest`, `git` (local, solo lectura de diffs)
- Red: NINGUNA
- Secretos: NINGUNO

## Verificación (comandos de validación + criterios de aceptación medibles)

**Comandos:**

```bash
pytest tests/scope/ -v
python3 scripts/check_scope.py WP-002 main...HEAD
```

**Casos mínimos que deben cubrir las pruebas:**

- [ ] Archivo **permitido** por coincidencia literal
- [ ] Archivo **no permitido** (fuera de todos los patrones)
- [ ] Coincidencia por **glob** (`*` y `**`, comprobando que `*` no cruza `/`)
- [ ] **Archivo nuevo** (añadido en el diff)
- [ ] **Symlink** cuyo destino real cae fuera del alcance
- [ ] Archivo **renombrado**

**Criterios de aceptación:**

- [ ] `pytest tests/scope/` en verde: **100 %** de los casos pasan
- [ ] Ante una violación, la salida **enumera todas** las violaciones con archivo y motivo
- [ ] Ante una violación, el código de salida es **≠ 0**
- [ ] Sin violaciones, el código de salida es **0**
- [ ] Ejecución de ejemplo con violación simulada, capturada como evidencia

## Evidencias exigidas (qué debe aparecer en evidence/WP-002/)

- [ ] Log completo de `pytest tests/scope/ -v` con su código de salida
- [ ] Ejecución de ejemplo con una violación simulada, mostrando la salida y el exit ≠ 0
- [ ] `cost.md` con el formato de DEC-001

## Condiciones de parada específicas

- Ambigüedad en la semántica de los globs. No debería darse: la convención quedó fijada en el Paso 0, en `_TEMPLATE.md`. Si aun así aparece un caso no cubierto por esa convención, **parar**: resolverlo por cuenta propia produciría divergencia con `guard.sh`, que es el fallo más grave que puede introducir este WP.
- Si al implementar se descubre que `guard.sh` interpreta algún patrón de forma distinta a lo documentado: parar y reportar. Es un hallazgo, no algo que arreglar aquí.

## Migración / rollback

No aplica: script nuevo, sin consumidores todavía. Rollback = revertir el commit. Ningún proceso depende de él hasta que WP-005 lo integre en CI.
