# ADR-001 — Runtime de agentes de la FDA

**Estado:** accepted · **Fecha:** 2026-07-23 · **Ámbito:** transversal a todos los proyectos que instalen `fda-template`
**Criterios de activación del harness SDK:** aprobados (D2 del plan de Fase 1, §2.2). Revisión: al cerrar la Fase 2.

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

### I4 — El WP-ID se pasa como argumento explícito

Skills y scripts aceptan el WP-ID como **parámetro**, no solo leyendo `work-packages/ACTIVE` de forma implícita. `ACTIVE` sigue siendo el estado operativo y el respaldo por defecto, pero nunca la única vía.

*Por qué es un invariante y no un detalle:* un runner del SDK procesa una cola de WPs y necesita invocar la verificación de `WP-014` mientras `ACTIVE` apunta a otro, o sin que `ACTIVE` exista. Si las skills solo leen `ACTIVE`, el harness obliga a mutar estado global antes de cada invocación — una carrera garantizada en cuanto haya concurrencia, y un rediseño de contratos el día de la migración.

*Consecuencia práctica:* incorporado en el Paso 0 de la Fase 1. Con esto, el runner futuro invoca las skills tal cual y no hay que rehacer contratos, agentes, hooks, evidencias ni workflows.

## Consecuencias

**A favor:** arranque inmediato sin construir infraestructura; la integración con GitHub Actions ya existe (`claude-code-action@v1`); el gobierno es portable tal cual; si el SDK no llega a hacer falta, no se ha perdido nada.

**En contra:** la orquestación programática (varios WPs en paralelo dirigidos por código, reintentos automáticos, políticas de coste dinámicas) no está disponible hasta activar el harness. Se acepta: durante calibración la supervisión humana es deliberada, no un límite técnico.

**Riesgo asumido y su mitigación:** que los invariantes I1–I3 se erosionen sin que nadie lo note, y que la migración al SDK acabe siendo un rediseño. Mitigación: el job `gobierno` de `ci.yml` verifica el estado en archivos en cada PR, y `guard.sh` es headless por construcción.

## Qué resolvería realmente un harness propio

Y **solo** esto:

- Ejecución desatendida **en lote** (una cola de WPs sin humano delante).
- **Orquestación entre ejecuciones**: prioridades, dependencias entre WPs, paralelismo con límites globales.
- **Políticas programáticas en vivo**: presupuesto agregado, kill-switch, reintentos idempotentes.
- Coordinación **multi-proyecto**.

## Qué ya da Claude Code sin construir nada

Verificado en documentación oficial: el agent loop completo; subagentes con permisos, modelo, turnos y aislamiento por worktree; hooks; ejecución headless scriptable (`claude -p`, invocable desde cron o CI); ejecución remota por evento (`claude-code-action@v1` — un `@claude implementa WP-014` en un issue **ya es ejecución desatendida**); y coste por sesión más telemetría OTel.

**Conclusión que gobierna esta decisión:** el «desatendido» básico **ya existe**. El harness solo aporta valor cuando se necesita *orquestación entre ejecuciones*, no ejecución.

## Criterios de activación del harness SDK

Aprobados en el plan de Fase 1 (§2.2). Sustituyen a los umbrales provisionales anteriores, que tenían un defecto de diseño: **el volumen por sí solo** puede disparar el harness con un proceso aún inmaduro —se automatizarían los errores— y **la calidad por sí sola** no justifica construir infraestructura.

Se exige **M1 y M2 y M3 simultáneamente**, más el veto:

### M1 — Madurez

- **≥ 15 WPs completados**
- **≥ 75 %** de aceptación a la primera
- **≤ 1** ciclo medio de corrección

Todo ello en las **últimas 4 semanas**.

### M2 — Dolor

Al menos **una** de estas señales, **documentada con evidencia** (tiempos medidos o intento fallido registrado):

- Lanzar y supervisar ejecuciones manualmente consume **> 2–3 h/semana** en pura operación.
- Hay WPs independientes esperando por falta de paralelismo gestionado, y **el cuello de botella es lanzarlos**, no la revisión humana.
- Se necesita una política que Actions no expresa: presupuesto agregado en vivo entre ejecuciones concurrentes, o dependencias entre WPs de repositorios distintos.
- Hay **≥ 2 proyectos FDA activos** simultáneos y la coordinación manual empieza a producir errores.
- Se intentó resolver una necesidad concreta con `claude -p` + Actions y **está documentado por qué no llegó**.

### M3 — Economía

Coste estimado de **construir + mantener** el harness **≤ ahorro operativo esperado en 3 meses**.

### Veto

**Nunca antes de completar la Fase 2** (primer proyecto real), se cumplan o no M1–M3.

## Componentes mínimos cuando toque (y nada más)

Un **runner**: script TS/Python sobre el Agent SDK con `settingSources: ['project']`, que hereda tal cual `CLAUDE.md`, agentes, settings y hooks. Toma un WP en `ready` de una cola simple (una carpeta o issues etiquetados), lo ejecuta con los límites del WP, escribe evidencias y abre PR.

Más un **scheduler trivial** (cron) y **límites globales** (presupuesto diario, concurrencia máxima).

## Qué NO construir todavía, en ningún caso

Panel o UI · base de datos propia · colas distribuidas (Redis y similares) · multi-tenant · meta-agente que redacta WPs por su cuenta · orquestación entre repositorios.

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
