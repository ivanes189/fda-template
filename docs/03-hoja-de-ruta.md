# Hoja de ruta — de la FDA al AI Agent Operating System

**Fecha:** 2026-08-30 · **Estado:** preparada para el punto de control del **2026-09-07**; pasa a ser vinculante cuando el operador la fusione en `main` (ver Anexo A) · **Ámbito:** `fda-template` y los proyectos que gobernará, empezando por `AI-Comercial-System` y el futuro Agent OS.

**Procedencia.** Este documento se elaboró leyendo: (1) las cinco conversaciones del operador con otras IAs — síntesis y veredictos razonados en [`04-analisis-conversaciones-ia.md`](04-analisis-conversaciones-ia.md)—; (2) el repositorio completo: constitución, manual, los nueve work packages, DEC-001…DEC-006, ADR-001, requisitos, guard, CI y el historial de PRs; (3) el estado real de los demás repositorios de la cuenta; y (4) fuentes externas fiables, citadas donde se usan. Lo redactó y materializó una sesión de Claude Code por encargo directo del operador, como acto de operador (§9).

---

## 0. Si eres un agente de IA, empieza por aquí

1. **Orden de lectura:** `CLAUDE.md` → este documento → [`manual`](manual/MANUAL.md) → las decisiones vigentes (`specs/decisions/`, en orden numérico) → el WP activo, si lo hay.
2. **No re-litigues decisiones cerradas.** Si crees que una decisión es errónea, prepáralo como propuesta para el siguiente punto de control o como borrador de DEC en solo lectura. No lo «arregles» por tu cuenta.
3. **Ceremonia proporcional al riesgo** (§6). Antes de proponer un control o proceso nuevo, responde por escrito tres preguntas: ¿qué fallo real y observado previene? ¿qué capa existente lo cubre ya total o parcialmente? ¿cuánto cuesta mantenerlo? Si no puedes responder las tres, no lo propongas.
4. **La fábrica existe para fabricar producto.** El éxito se mide en software útil entregado (§7), no en controles añadidos ni en número de agentes.
5. Las ocho condiciones de parada de `CLAUDE.md` y del manual siguen vigentes. Este documento no las cambia.

---

## 1. Dónde estamos de verdad (verificado sobre el repositorio, 2026-08-30)

| Elemento | Estado |
|---|---|
| Fase 0 (bootstrap, WP-000) | Cerrada. Coste registrado: 15,14 USD |
| Calibración de Fase 1 (WP-001…WP-005) | **Sin ejecutar.** WP-001, 003, 004 y 005 en `draft`; WP-002 `blocked` |
| WP-006 (estado de reposo) | Cerrado |
| WP-007 (traversal del guard) | `ready`, **congelado** por DEC-003, con trabajo candidato sin versionar |
| WP-008 (runtime fail-closed, núcleo) | **Activo** (`ACTIVE` → WP-008), reintento `-r2` autorizado por DEC-006 |
| WP-009 / WP-010 / WP-011 / WP-012 | Reservados; sin contrato redactado |
| Pausa de gobierno (DEC-003) | **Vigente desde el 2026-08-03**. Punto de control: **2026-09-07** |
| `claude.yml` y `code-review.yml` | Desactivados manualmente (el revisor automático nunca llegó a revisar: 5/5 falsos verdes) |
| `AI-Comercial-System` + 4 repos satélite | **Sin actividad desde febrero de 2026** (~6 meses) |

**Tres verdades incómodas, dichas sin dramatismo y con los datos delante:**

1. **En cinco semanas la fábrica solo ha producido meta-trabajo.** ~27 PRs fusionadas y todas son gobierno del gobierno: decisiones, contratos, replanificaciones, custodias. Cero páginas de producto. El contrato vigente de WP-008 tiene 1.862 líneas para un cambio que, en esencia, ancla la invocación de un hook y ocho reglas de permisos.
2. **El control concluyente sigue sin construirse.** El diseño original (diagnóstico de Fase 1, B2) ya lo decía: el hook es preventivo y evitable; la verificación definitiva es el **check de alcance sobre el diff de la PR en CI** (WP-002 + WP-005). Cinco semanas de endurecimiento se han invertido en la capa débil mientras la capa fuerte sigue en `draft`/`blocked`.
3. **El producto real está parado.** `AI-Comercial-System` —el activo que las cinco conversaciones coinciden en señalar como banco de pruebas imprescindible— lleva medio año sin un commit.

Nada de esto significa que el trabajo hecho sea malo. Significa que el rumbo necesita corrección: es exactamente la situación que la causa raíz n.º 2 del manual (§8 de [05-bloqueos-y-parada](manual/05-bloqueos-y-parada.md)) enseña a detectar, aplicada esta vez al proceso entero y no a un WP.

## 2. Lo que está bien y se conserva

La base conceptual de la FDA es sólida y **no se toca**. Las cinco conversaciones coinciden, y la práctica externa lo valida:

- **Contratos ejecutables por tarea** (work packages con alcance, verificación y criterios medibles). Es el mismo patrón que la industria ha adoptado como *spec-driven development* ([GitHub Spec Kit](https://github.com/github/spec-kit): Spec → Plan → Tasks → Implement).
- **La seguridad no depende de que el modelo obedezca**: permisos de GitHub, allowlists, hook, CI bloqueante, fusión humana. Coincide con las mitigaciones de [OWASP para IA agéntica](https://genai.owasp.org/resource/agentic-ai-threats-and-mitigations/): mínimo privilegio, identidades acotadas, aprobación humana para acciones de alto impacto.
- **El estado vive en archivos versionados**, nunca en la conversación (ADR-001, invariantes I1–I4). Esto es lo que hará posible el runner desatendido sin rediseñar nada.
- **Fusión humana y decisiones escritas.** El registro DEC-001…006 es un activo: se sabe por qué se decidió cada cosa.
- **Parar ante ambigüedad es el sistema funcionando.** Los bloqueos de WP-003/004 (cuando se ejecuten) y la barrera roja que detuvo la cadena de WP-008 demuestran que los frenos frenan.

## 3. Diagnóstico: por qué la fábrica se atascó

**Causa 1 — Ceremonia única para todo riesgo.** Hoy un glosario y un cambio de CI/permisos pagan el mismo proceso completo. La investigación empírica de referencia ([DORA — Streamlining change approval](https://dora.dev/capabilities/streamlining-change-approval/)) muestra que los procesos de aprobación pesados **no reducen la tasa de fallo** y hacen 2,6 veces más probable el bajo rendimiento; lo que funciona es revisión entre pares + automatización. La primera conversación con IA ya lo avisó («sin niveles de proceso por riesgo, la fábrica será segura pero lenta») y la quinta lo nombró: **sobre-gobernanza**.

**Causa 2 — La espiral de auditoría.** Cada auditoría independiente encuentra defectos reales pero menores; cada defecto reescribe el contrato; el contrato crece; más superficie, más hallazgos. Once ciclos de WP-008 fueron exactamente esto. Ninguna auditoría tenía el mandato de preguntar «¿compensa?» — solo «¿es perfecto?». Un sistema optimizado para ser inauditable no es lo mismo que un sistema útil.

**Causa 3 — Calibración invertida.** La Fase 1 se diseñó para medir el proceso con 5 WPs pequeños ANTES de sacar conclusiones. En su lugar, el proceso empezó a perfeccionarse a sí mismo sin datos de base, y el perfeccionamiento no tiene final natural.

**Causa 4 — Una prueba desproporcionada (WP-012).** Demostrar empíricamente, con un runner de 14 sondas dentro del repo, que Claude Code aplica su propia configuración de hooks es **testear el producto del proveedor**, no el gobierno propio. Su valor marginal es bajo porque el control concluyente (Causa 1 de §1: el diff en CI) atrapa cualquier escritura fuera de alcance *aunque el hook no funcionara en absoluto*. Once ciclos sin una medición válida son el dato.

## 4. Principios de la ruta

- **P1. El control concluyente es el diff de la PR en CI.** El hook es defensa en profundidad, valiosa pero secundaria. Prioridad de construcción en consecuencia.
- **P2. Ceremonia proporcional al riesgo** (§6). Lo barato de revertir se procesa barato.
- **P3. La fábrica existe para el producto.** El meta-trabajo se raciona (§6) y se mide (§7).
- **P4. Gates por evidencia, no por calendario.** Cada etapa define su criterio de salida medible; no se avanza sin cumplirlo (los umbrales M1/M2/M3 de ADR-001 siguen vigentes para el harness).
- **P5. Lo más simple que funcione, primero.** Es la recomendación explícita de [Anthropic — Building effective agents](https://www.anthropic.com/engineering/building-effective-agents): empezar por la solución más simple y añadir complejidad solo cuando mejora resultados medidos. También la de la propia guía fundacional (§7, anti-patrones).
- **P6. Multi-agente solo cuando la tarea lo pide.** La experiencia publicada por Anthropic con su sistema multi-agente de investigación: ~15× más tokens que un chat; solo compensa en tareas realmente paralelizables. Los agentes se añaden por **composición** (rol + especialidad + herramientas + políticas), no por catálogo.
- **P7. Los agentes de desarrollo y los de negocio son productos distintos.** FDA construye software; el Agent OS ejecutará agentes de negocio. Comparten filosofía, no clase universal.
- **P8. Git guarda la verdad normativa; la telemetría vive fuera.** Contratos, decisiones y evidencias derivadas en Git; trazas, métricas y logs masivos en su sistema propio (se materializa en la Etapa 5).

## 5. La ruta

### Etapa 0 — Hoy → 2026-09-07: cerrar WP-008 y preparar el punto de control

**Objetivo:** terminar lo empezado, sin abrir nada nuevo.

1. **Ejecutar WP-008-r2 según su contrato vigente** (pasos 8–13 de DEC-006): implementación, batería A, fase roja, PR en borrador, barrera roja, fase verde, evidencia, revisión y fusión humana. Decisión tomada en esta hoja de ruta con mandato del operador: es la última milla de un trabajo pagado y su recuperación ya está montada; recortarlo ahora costaría más gobierno del que ahorraría.
2. **No abrir ningún otro frente** antes del 07-09.

**Criterio de salida:** WP-008 fusionado con su evidencia roja/verde de CI, `ACTIVE` en reposo.

### Etapa 1 — 2026-09-07: el punto de control (la cita que ya existía)

DEC-003 §5 y DEC-005 §8 exigen en esa fecha revisión y análisis por escrito. Este documento y su anexo son ese material, preparado con antelación. Decisiones a tomar por el operador ese día (el Anexo A trae el borrador de DEC-007 listo):

| # | Decisión | Recomendación razonada |
|---|---|---|
| **D1** | **WP-012**: ¿mantener el runner empírico como 3ª condición de salida de la pausa, o sustituirlo? | **Sustituir** por: (a) prueba de humo manual documentada (~30 min: verificar con el guard real que una escritura fuera de alcance se bloquea en sesión viva, capturando la salida como evidencia) + (b) prioridad absoluta al check de alcance en CI (Etapa 2). Motivo: causa 4 del §3. Mantenerlo es legítimo, pero si no converge en sus 2 ciclos costará ~1 mes más. Ambas ramas quedan escritas en el Anexo A |
| **D2** | **Reforma del proceso** (§6): ¿adoptarla? | **Adoptar.** Fundamento: §3 causas 1–3, evidencia DORA, aviso explícito de dos de las cinco conversaciones |
| **D3** | **Esta hoja de ruta**: ¿fusionarla como rumbo vinculante? | **Fusionar**, admitiéndola formalmente en DEC-003 §4 mediante el mecanismo atómico ya usado por DEC-005 y DEC-006 (Anexo A) |

### Etapa 2 — Cierre de la pausa (estimación: 1–3 semanas tras el 07-09)

En este orden, siguiendo la secuencia de `ACTIVE` de DEC-003 §2 (ajustada según D1):

1. **WP-009 — acciones fijadas por SHA.** Pequeño y ya definido por REQ-FDA-002: fijar las 4 acciones de los workflows por SHA completo y endurecer el validador para que una etiqueta `@vN` sea error. Contrato ≤ 150 líneas.
2. **WP-012 o su sustituto**, según D1.
3. **WP-007 — descongelar, reconciliar y cerrar** (la huella de 7 magnitudes de DEC-003 §1 se verifica antes de tocar nada; el manual se reconcilia como su contrato exige).
4. **WP-002 + WP-005 — `check_scope` sobre el diff de la PR, en CI.** El control concluyente. Incluye resolver la deuda declarada de las ramas `ops/*`. Con esto, un cambio fuera de contrato no puede llegar a `main` use el agente la herramienta que use — incluida la clase de hueco descrita en §9.

**Criterio de salida:** pausa cerrada por PR de operador (DEC-003 marcada `superada`, arrastrando el registro de sus workflows §3) **y** check de alcance bloqueante en el ruleset.

**Qué NO hacer:** añadir agentes; tocar `tests/guard/run-suite.sh` fuera de WP-007; abrir el harness SDK.

### Etapa 3 — Calibración exprés e higiene (≈ 2 semanas)

La Fase 1 original, por fin, con su propósito original: **medir**.

1. **WP-001** (glosario) — el positivo trivial: fija coste y fricción de referencia.
2. **WP-003 y WP-004** (los encargos-trampa) — validan que planner e implementer paran cuando deben.
3. **Higiene de plantilla**, como WPs ligeros bajo la reforma (si D2 se aprueba): `README.md` raíz, `LICENSE`, autorización explícita de actores en `claude.yml` antes de reactivarlo, y guía de separación plantilla/sandbox. Son los 4 hallazgos aún vigentes de la auditoría externa de julio.
4. **WP-011 — frontera de revisión verificable**: salida estructurada del revisor validada por schema (un `verdict` exigible, no un job verde vacío) y reactivación de `code-review.yml`. Cierra la clase «falso verde» detectada en DEC-003 (5/5).

**Criterio de salida:** métricas base de ADR-001 registradas (coste/WP, % aceptación a la primera, ciclos medios, tiempo humano/WP) sobre ≥ 5 WPs reales.

### Etapa 4 — Fase 2 real: la fábrica trabaja sobre el producto (≈ 4–8 semanas)

Instalar la FDA en **`AI-Comercial-System`** y ejecutar tres programas de WPs pequeños. La plataforma no se diseña en abstracto: se extrae de un sistema real exigente — el consejo unánime de las conversaciones 1, 3 y 5.

1. **Programa INV (inventario):** higiene del repo (hoy versiona `.venv/`, `__pycache__/` y `logs/`; sin README); mapa de módulos; línea base de tests y de comportamiento (las evaluaciones de conducta del agente de voz ANTES de refactorizar).
2. **Programa CONTRACTS:** definir en `specs/` los contratos del futuro Agent OS — `AgentDefinition`, `AgentRun` + eventos, `ToolDefinition`, interfaz `ModelGateway`, `PolicyDecision`/`ApprovalRequest`. Solo esquemas, ejemplos y tests; nada de infraestructura.
3. **Programa MIG (envolver sin cambiar comportamiento):** el agente eléctrico pasa a describirse con esos contratos (su configuración como `AgentDefinition`, su calculadora como `ToolDefinition`, sus llamadas LLM tras el `ModelGateway`, su estado de ventas como `domain_state`). Criterio duro: **cero cambio de comportamiento observable**; la línea base de INV lo verifica.

**Criterio de salida:** el sistema real funciona a través de los contratos, con sus tests en verde.

### Etapa 5 — El Agent OS emerge (estrangulamiento progresivo)

Con contratos probados por un sistema real, se construye el **kernel mínimo** como monolito modular (PostgreSQL como fuente de verdad operacional; Redis como caché): registro de agentes y herramientas, *tool gateway* con validación/permisos/auditoría, persistencia de runs y eventos, frontera de políticas, aprobaciones con pausa/reanudación. Después: **el segundo agente genuinamente distinto** (p. ej. investigación interna o soporte) — la prueba de generalidad: si obliga a tocar el núcleo, la abstracción aún no es general. Después: plataforma de evaluaciones y ejecución durable. La arquitectura de datos multi-tenant (RLS, outbox, warehouse, packs verticales) entra aquí, guiada por la síntesis de la conversación 3 (ver documento 04, T9).

**Criterio de salida:** dos agentes distintos sobre el mismo kernel sin modificaciones del núcleo; evaluaciones automáticas por versión.

### Etapa 6 — Escalar: orquestación, operaciones y la organización agéntica

- **Harness SDK** cuando —y solo cuando— se cumplan M1+M2+M3 de ADR-001 (madurez + dolor + economía; veto hasta cerrar la Etapa 4). Runner mínimo: cola simple, límites globales, `settingSources: ['project']`.
- **Plano de operaciones:** OpenTelemetry, lineage, detectores deterministas, runbooks cerrados de remediación y **escala de autonomía A0–A5 por acción** (no por agente), tal y como propuso la conversación 4 — aceptada como fase, no como presente.
- **Agentes por composición** (P6): rol × especialidad × herramientas × políticas; el organigrama de ~200 capacidades de la conversación 5 es el mapa de largo plazo, nunca el backlog inmediato.
- **La agencia comercial** (plataforma común + packs verticales + configuración por cliente) se apoya en el Agent OS de la Etapa 5.

## 6. La reforma del proceso — PROPUESTA (se decide el 07-09, D2)

El operador ha decidido (2026-08-30) **documentarla sin adoptarla todavía**. Texto completo listo para materializar en `_TEMPLATE.md` y el manual si D2 la aprueba:

| Nivel | Superficie | Proceso |
|---|---|---|
| **T1 — ligero** | Solo `docs/**`, `tests/**`, `evidence/**` (sin tocar gobierno ni CI) | Contrato de 1 página (objetivo, permitidos, verificación, aceptación); revisión = 1 pasada de code-reviewer; sin security-reviewer |
| **T2 — estándar** | Código de producto, `scripts/**`, specs | El ciclo actual completo del manual |
| **T3 — sensible** | `.claude/**`, `.github/**`, permisos, secretos, migraciones, `CODEOWNERS` | Ciclo completo + security-reviewer + parche verificado aplicado por persona (como hoy) |

Límites transversales propuestos: contrato de WP ≤ 300 líneas (si necesita más, el troceado está mal — lección literal de DEC-005); ≤ 1 de cada 3 WPs puede tener a la propia FDA como objeto una vez cerrada la pausa; las auditorías clasifican por severidad y **solo los hallazgos bloqueantes detienen** (el resto nace como backlog, no como replanificación); un tercer ciclo dispara siempre la pregunta «¿pártelo?» antes que «¿reescríbelo?».

## 7. Métricas (se registran desde la Etapa 3)

Las cuatro vigentes (coste por WP aceptado; % a la primera; ciclos medios; regresiones) más: **minutos humanos por WP**, **% de WPs de producto vs meta**, y —desde la Etapa 5— tasa de resolución autónoma y tasa de escalada humana. Objetivo de la calibración: ≥ 75 % a la primera y ≤ 1 ciclo medio (umbral M1 de ADR-001).

## 8. Riesgos principales y sus señales

| Riesgo | Señal de alarma | Respuesta |
|---|---|---|
| Recaer en la espiral de meta-trabajo | 2 WPs seguidos sobre la FDA, o un contrato > 300 líneas | Aplicar §6; punto de control extraordinario |
| WP-012 no converge (si D1 = mantener) | 2 ciclos agotados | Activar la rama «sustituir» del Anexo A sin nueva deliberación |
| El producto sigue parado | Etapa 4 sin empezar 8 semanas después de cerrar la pausa | El operador repriorizará: el producto pasa por delante de cualquier mejora de plantilla |
| Prompt injection al reactivar `claude.yml` | Reactivación sin autorización de actores | Vetado: la autorización explícita es prerrequisito (Etapa 3.3) |
| Dependencia de un solo humano | — | Se acepta por ahora; la conversación 5 fija el objetivo realista (8–12 personas para una gran compañía), no 1–3 |

## 9. Huecos de gobierno conocidos (transparencia)

1. **Las herramientas de escritura vía API (MCP de GitHub) no pasan por el guard local.** Este documento se materializó por esa vía, por encargo directo del operador, sobre una rama de sesión y sin tocar `main` — exactamente la clase de «acto de operador preparado por agente» que el repo ya practica. El hueco queda declarado: el cierre definitivo no es ampliar el guard (siempre habrá vías), sino el **check de alcance en CI** (Etapa 2.4), que juzga el diff resultante venga de donde venga. Hasta entonces, esta vía queda reservada a actos de operador explícitamente encargados.
2. **Plantilla y sandbox mezclados** en el mismo repo (valores instanciados + evidencias de calibración). Se resuelve con la guía de separación de la Etapa 3.3.
3. **`claude.yml` sin autorización explícita de actores** — desactivado hoy; prerrequisito antes de reactivar (Etapa 3.3).
4. **Adaptaciones locales de otros runtimes** (`.agents/`, `.codex/`, `AGENTS.md`) siguen sin versionar y fuera de gobierno (DEC-003 §8); cualquier uso de otro runtime como implementador exige su DEC propia.

---

## Anexo A — Borrador de DEC-007 para el punto de control (2026-09-07)

Texto preparado para que el operador lo apruebe, ajuste o rechace ese día. Su materialización debe viajar en un único diff atómico que: (1) cree `specs/decisions/DEC-007-punto-de-control-y-rumbo.md` con las decisiones D1–D3 tal y como queden; (2) añada a la lista cerrada de DEC-003 §4 las entradas `DEC-007` y `docs/03 + docs/04` (mecanismo de admisión atómica ya usado por DEC-005 y DEC-006); (3) si D1 = sustituir, enmiende DEC-003 §6 reemplazando la tercera condición por: «prueba de humo manual documentada en `evidence/` + check de alcance de PR bloqueante en CI (WP-002/WP-005 fusionados)», liberando la reserva de WP-012; (4) si D2 = adoptar, registre la reforma de §6 y encargue su materialización (manual + `_TEMPLATE.md`) como primera PR de operador tras la pausa; y (5) fusione esta hoja de ruta a `main` como rumbo vinculante. Si el operador prefiere mantener WP-012 o rechazar la reforma, las ramas alternativas quedan igualmente válidas escribiéndolo así en DEC-007: lo que no puede pasar es que el 07-09 termine sin decisión escrita — eso repetiría el patrón que DEC-005 ya tuvo que corregir.

## Anexo B — Glosario mínimo (para lectura no técnica)

- **FDA**: la «fábrica» — reglas, contratos y agentes con los que la IA desarrolla software de forma controlada. No es el producto; es cómo se fabrica el producto.
- **Agent OS**: el producto futuro — la plataforma que ejecutará agentes de negocio (ventas, soporte…) con permisos, aprobaciones y auditoría.
- **WP (work package)**: un encargo pequeño con contrato: qué se hace, qué archivos se pueden tocar, cómo se verifica.
- **Guard / hook**: el programa que bloquea en el momento cualquier intento de escribir fuera del contrato. Preventivo, no infalible.
- **Check de alcance en CI**: la comprobación en GitHub que revisa el resultado final (el diff) contra el contrato. Es la barrera definitiva.
- **Pausa (DEC-003)**: freno de emergencia activado el 03-08 al descubrir que el guard podía fallar en abierto; se sale de ella cumpliendo condiciones medibles.
- **PR de operador**: cambio del andamiaje (contratos, estados, decisiones) aprobado por ti; distinto de una PR de implementación.
- **Meta-trabajo**: trabajo de la fábrica sobre sí misma, en vez de sobre el producto.
