# ADR-001 — Runtime de agentes de la FDA

**Estado:** aceptado · **Fecha:** 2026-07-23 · **Ámbito:** transversal a todos los proyectos que instalen `fda-template`
**Umbrales de activación del harness SDK:** ⚠️ **PENDIENTE DE APROBACIÓN HUMANA** (ver §Criterios)

## Contexto

La FDA necesita un runtime que ejecute agentes especializados con herramientas, permisos, modelo y criterios de parada propios. Las opciones reales en 2026:

1. **Claude Code (CLI)** — subagentes por archivo, hooks, aislamiento por git worktree, ejecución headless, integración nativa con GitHub Actions.
2. **Claude Agent SDK (Python/TS)** — el mismo agent loop, las mismas herramientas y la misma gestión de contexto que Claude Code, expuestos como librería para orquestación programática propia.
3. Construir orquestación propia sobre la API — descartado: reimplementar el agent loop antes de haber agotado lo que ya existe es uno de los anti-patrones que la guía rechaza explícitamente (§7).

El dato que hace reversible esta decisión: **Claude Code y el Agent SDK comparten motor**. El SDK *es* ese harness como librería. En consecuencia, el gobierno —que es lo valioso y lo que cuesta construir— no vive en el runtime sino en archivos versionados del repositorio: `CLAUDE.md`, `.claude/agents/`, `.claude/settings.json`, `work-packages/`, `specs/`.

## Decisión

**Runtime actual: Claude Code (CLI).** El harness sobre Claude Agent SDK se activará más adelante, cuando se cumplan los criterios medibles de la sección siguiente, y **sin retrabajo del gobierno**.

Para garantizar que esa activación no obligue a rehacer nada, son vinculantes desde ahora tres invariantes de arquitectura:

### I1 — Todo el estado operativo vive en archivos del repositorio

`work-packages/ACTIVE`, el estado de cada WP en su frontmatter, y las evidencias en `evidence/`. Nunca en la sesión ni en memoria conversacional. Un harness distinto debe poder reconstruir el estado completo leyendo el repositorio y nada más.

*Consecuencia práctica:* cualquier agente que necesite saber «en qué punto estamos» lo averigua leyendo archivos, no recordando.

### I2 — Toda verificación es ejecutable en headless

Sin interacción humana, sin TTY, con código de salida significativo. Un comando de validación que exige que alguien mire una pantalla no es un comando de validación.

*Consecuencia práctica:* la batería de la Fase 0 se ejecuta íntegra con `bash` y `python3`, sin red.

### I3 — Nada asume sesión interactiva

Ni agentes, ni skills, ni hooks. `guard.sh` recibe JSON por stdin y responde con un código de salida; no pregunta nada. Las skills documentan comandos, no clics.

## Consecuencias

**A favor:** arranque inmediato sin construir infraestructura; la integración con GitHub Actions ya existe (`claude-code-action@v1`); el gobierno es portable tal cual; si el SDK no llega a hacer falta, no se ha perdido nada.

**En contra:** la orquestación programática (varios WPs en paralelo dirigidos por código, reintentos automáticos, políticas de coste dinámicas) no está disponible hasta activar el harness. Se acepta: durante calibración la supervisión humana es deliberada, no un límite técnico.

**Riesgo asumido y su mitigación:** que los invariantes I1–I3 se erosionen sin que nadie lo note, y que la migración al SDK acabe siendo un rediseño. Mitigación: el job `gobierno` de `ci.yml` verifica el estado en archivos en cada PR, y `guard.sh` es headless por construcción.

## Criterios de activación del harness SDK

⚠️ **Umbrales propuestos, PENDIENTES DE APROBACIÓN.** Son la primera propuesta sobre datos que todavía no existen: la Fase 1 es calibración y no se sacan conclusiones con n=1. Revisar al terminar la Fase 2 con métricas reales.

Se activa el harness cuando se cumpla **al menos uno** de los tres disparadores, y **siempre** la condición de estabilidad:

| # | Disparador | Umbral propuesto | Ventana | Fuente del dato |
|---|---|---|---|---|
| D1 | Volumen sostenido | **≥ 8 WPs aceptados/semana** | 3 semanas consecutivas | PRs fusionadas con evidencias |
| D2 | Calidad estable | **≥ 80 % de WPs aceptados a la primera** | 2 semanas consecutivas | PRs sin ciclo de corrección / total |
| D3 | Necesidad real de ejecución desatendida | **≥ 3 WPs/semana** que deban ejecutarse sin humano delante | 2 semanas | Registro de WPs pospuestos por falta de operador |

**Condición de estabilidad (obligatoria en todos los casos):**

- Ciclos de corrección medios **≤ 1,2** por WP aceptado.
- Coste por WP aceptado con variación **< 20 %** respecto a la media de las 4 semanas previas.
- **Cero** incidentes de gobierno abiertos (fusión con CI rojo, edición fuera de alcance no detectada, secreto expuesto).

**Anti-disparadores** — motivos que NO justifican activar el harness: curiosidad técnica; que el SDK sea nuevo; querer paralelizar antes de que un solo WP secuencial funcione de forma fiable; sustituir supervisión humana que todavía está encontrando fallos reales.

## Notas de implementación para el harness futuro

Cuando llegue el momento, el harness debe fijar **explícitamente** el origen de configuración para cargar el gobierno del repositorio:

- TypeScript: `settingSources: ['project']`
- Python: `setting_sources=['project']`

Controla la carga de `CLAUDE.md`, `.claude/agents/` y `.claude/settings.json` desde el sistema de archivos. **Verificar el valor por defecto de la versión instalada en ese momento**: si el default cambiara y no se fijara explícitamente, el harness ejecutaría agentes sin constitución, sin allowlists y sin hooks — es decir, sin ninguna de las garantías de la FDA, y en silencio.

## Referencias

- `docs/02-guia-fabrica-desarrollo-agentica.md` §1 (stack), §3 (agentes y hooks), §7 (fases)
- `CLAUDE.md` — invariante I1 (fuente de verdad) e I3 (ejecución headless)
- https://platform.claude.com/docs/en/agent-sdk/overview
- https://code.claude.com/docs/en/agent-sdk/claude-code-features
- https://code.claude.com/docs/en/sub-agents
