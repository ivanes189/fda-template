[← Manual](MANUAL.md)

# 04 — Los agentes: quién, cuándo y con qué permisos

Cinco agentes, uno por archivo en `.claude/agents/`. Cada uno tiene su propia allowlist de herramientas, modelo y criterio de parada.

## Tabla de decisión

| Situación | Agente |
|---|---|
| Tengo un encargo y no sé si es un WP válido | `planner` |
| El WP está en `ready` y hay que implementarlo | `implementer` |
| Hay que ejecutar la batería y ampliar pruebas | `qa` |
| El WP toca auth, secretos, red, entrada de usuario, migraciones o dependencias | `security-reviewer` |
| Hay una PR que revisar | `code-reviewer` |

## Ficha de cada agente

### `planner` — valida y descompone

| | |
|---|---|
| **Herramientas** | `Read, Grep, Glob, Bash` |
| **Denegadas** | `Edit, Write, NotebookEdit` |
| **Modelo** | premium (`opus`) — planificar es arquitectura |
| **maxTurns** | 30 |

**Hace:** verifica la Definition of Ready punto por punto, trocea WPs grandes, declara dependencias entre WPs, rechaza encargos ambiguos.

**No hará nunca:** escribir código, modificar archivos, decidir por ti ante una ambigüedad, aprobar un WP al que le falte cualquiera de los 5 elementos de la DoR.

### `implementer` — implementa un WP

| | |
|---|---|
| **Herramientas** | `Read, Grep, Glob, Edit, Write, Bash` |
| **Modelo** | estándar (`sonnet`) |
| **maxTurns** | 60 |
| **Aislamiento** | `isolation: worktree` — copia aislada del repo |

**Hace:** implementa el alcance mínimo que satisface los criterios, escribe pruebas de toda función nueva, ejecuta la validación del WP, guarda evidencias.

**No hará nunca:** fusionar, desplegar, tocar secretos, modificar CI/CD o `CODEOWNERS`, salirse de los archivos permitidos, ni ampliar el alcance por su cuenta.

### `qa` — verifica y amplía pruebas

| | |
|---|---|
| **Herramientas** | `Read, Grep, Glob, Bash, Edit, Write` |
| **Modelo** | estándar (`sonnet`) |
| **maxTurns** | 40 |

**Hace:** ejecuta cada comando tal cual, captura salidas con su código de salida, evalúa criterios uno a uno, añade pruebas donde falta cobertura, emite APTO / NO APTO.

**No hará nunca:** arreglar código de producción (reporta, no arregla), relajar una prueba para que pase, ni añadir `skip`, `xfail` o bajar umbrales de cobertura.

> ⚠️ **Cómo se hace cumplir «solo escribe en pruebas».** El `qa` tiene `Edit` y `Write` porque necesita crear tests; la allowlist de herramientas no distingue rutas. El límite real es la sección `## Archivos permitidos` del WP, que aplica `guard.sh`.
> **En un WP de QA, esa lista debe contener solo rutas de pruebas.** Si contiene rutas de producción, el límite desaparece — y sería un fallo de redacción del WP, no del agente.

### `security-reviewer` — revisión de seguridad

| | |
|---|---|
| **Herramientas** | `Read, Grep, Glob, Bash` |
| **Denegadas** | `Edit, Write, NotebookEdit` |
| **Modelo** | premium (`opus`) |
| **maxTurns** | 30 |

**Hace:** busca secretos, fallos de autorización, inyección, criptografía débil, dependencias vulnerables, exposición de datos y riesgos de migración. Informe con severidad, archivo:línea, escenario de explotación y arreglo concreto.

**No hará nunca:** modificar código, abrir PRs, ni dar por bueno un hallazgo CRÍTICO o ALTO. Ante uno, el WP se bloquea.

**Convócalo siempre que** el cambio toque auth, secretos, red, entrada de usuario no confiable, migraciones, permisos de CI/CD o dependencias nuevas.

### `code-reviewer` — revisión independiente

| | |
|---|---|
| **Herramientas** | `Read, Grep, Glob, Bash` |
| **Denegadas** | `Edit, Write, NotebookEdit` |
| **Modelo** | premium (`opus`) |
| **maxTurns** | 30 |

**Hace:** revisa con contexto limpio, en este orden: cumplimiento del contrato → criterios de aceptación contra la evidencia → corrección → pruebas → deuda declarada.

**No hará nunca:** modificar código (si lo arreglara, dejaría de ser un control independiente), fusionar, aprobar formalmente la PR, ni bloquear por preferencias de estilo que el linter no marca.

---

## Los cuatro controles que no dependen del prompt

La separación de funciones se garantiza **por construcción**, no por obediencia:

1. **GitHub** — branch protection impide que el implementador fusione. No es una norma de su prompt: es que no tiene el permiso.
2. **Allowlists de herramientas** — el `code-reviewer` no tiene `Edit`. Aunque decidiera arreglar el código, la herramienta no está disponible.
3. **`guard.sh`** — bloquea escrituras fuera del WP activo con un código de salida, sin consultar al modelo.
4. **Preflight de configuración** — `tests/runtime/check-config.sh`, dentro del job `Gobierno FDA`, comprueba en cada PR que la propia configuración de permisos y hooks sigue siendo la contratada. Un control que se degrada en silencio deja de ser un control, y este es el que impide fusionar esa degradación.

## Límites conocidos de los controles

Conviene saber qué **no** cubren, para no confiar de más:

| Límite | Alcance real | Red de seguridad |
|---|---|---|
| El analizador de `Bash` de `guard.sh` es *best-effort* | Detecta `>`, `>>`, `tee`, `sed -i`, `cp`, `mv`, `rm`, `dd of=`… pero no `python -c "open(...,'w')"`, `eval` ni `base64 -d` | CI (`Gobierno FDA`) + revisión del diff + branch protection |
| Las allowlists son por herramienta, no por ruta | `qa` puede escribir fuera de `tests/` si el WP lo permite | Redacción correcta del WP + revisión |
| `permissions.deny` cubre las herramientas de edición, no el shell | Un `deny` de `Edit(/x)` no impide `echo > x`; ahí quien manda es `guard.sh` | El propio `guard.sh`, que sí analiza Bash |

> El matcher de `.claude/settings.json` es `Edit|Write|MultiEdit|NotebookEdit|Bash`. **Si alguien quita `Bash` de esa lista, el hueco vuelve a abrirse entero.** Es la línea más sensible de toda la configuración.

Ninguno de estos huecos permite **fusionar** nada: todo cambio pasa por PR, CI y revisión humana. Esa es la capa que sí es hermética.

## Cómo lanzarlos

```
> Usa el agente planner para validar la DoR de WP-014.
> Usa el agente implementer para implementar WP-014.
> Usa el agente qa para ejecutar la verificación de WP-014.
> Usa el agente security-reviewer para revisar el diff de esta rama.
> Usa el agente code-reviewer para revisar la PR #42.
```

En CI, `claude.yml` y `code-review.yml` los invocan con `claude_args` (`--max-turns`, `--model`). Cargan exactamente el mismo gobierno porque vive en archivos del repositorio.

## Modificar un agente

Editar `.claude/agents/*.md` es un **cambio de proceso**: requiere su propio WP, y `docs/manual/` se actualiza en la misma PR. El job `Gobierno FDA` lo comprueba y falla si no lo hiciste.
