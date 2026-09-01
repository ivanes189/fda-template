# Hoja de ruta — de la FDA al AI Agent Operating System

**Creada:** 2026-08-30 · **Última revisión: 2026-09-01** (v2 — ver Registro de revisiones) · **Estado:** preparada para el punto de control del **2026-09-07**; pasa a ser vinculante cuando el operador la fusione en `main` (ver Anexo A) · **Ámbito:** `fda-template` (carril A) y su primera instalación externa (carril B), y los proyectos que gobernarán: `AI-Comercial-System`/Agent OS y Document AI.

**Procedencia.** v1 (30-08): las cinco conversaciones del operador con otras IAs — síntesis en [`04-analisis-conversaciones-ia.md`](04-analisis-conversaciones-ia.md)—, el repositorio completo, el estado de los demás repos y fuentes externas. v2 (01-09): además, los **cuatro documentos de investigación de Leandro** y una **línea base de investigación independiente registrada antes de leerlos** — análisis completo, veredictos y red team en [`05-analisis-investigacion-leandro-y-revalidacion.md`](05-analisis-investigacion-leandro-y-revalidacion.md). Lo redactaron y materializaron sesiones de Claude Code por encargo directo del operador, como actos de operador (§9).

## Registro de revisiones

| Fecha | Qué cambió | Dónde está el razonamiento |
|---|---|---|
| 2026-08-30 | Versión inicial | [04](04-analisis-conversaciones-ia.md) |
| 2026-09-01 | Enforcement en tres capas (P1); reforma con blast radius ejecutable; punto de control ampliado a D1–D6; dos carriles upstream/downstream; paquete de mejoras de Leandro incorporado; Etapas 0–1 reescritas al estado real; métricas y riesgos ampliados | [05](05-analisis-investigacion-leandro-y-revalidacion.md) §9–§10 |

---

## 0. Si eres un agente de IA, empieza por aquí

1. **Orden de lectura:** `CLAUDE.md` → este documento → [`manual`](manual/MANUAL.md) → decisiones vigentes (`specs/decisions/`, en orden) → [05](05-analisis-investigacion-leandro-y-revalidacion.md) si necesitas el porqué de la v2 → el WP activo, si lo hay.
2. **No re-litigues decisiones cerradas.** Si crees que una decisión es errónea, prepáralo como propuesta para el siguiente punto de control o como borrador de DEC en solo lectura.
3. **Ceremonia proporcional al riesgo** (§6). Antes de proponer un control o proceso nuevo, responde por escrito: ¿qué fallo real y observado previene? ¿qué capa existente lo cubre ya? ¿cuánto cuesta mantenerlo? Si no puedes responder las tres, no lo propongas.
4. **La fábrica existe para fabricar producto.** El éxito se mide en software útil entregado (§7), no en controles añadidos ni en número de agentes.
5. Las ocho condiciones de parada de `CLAUDE.md` y del manual siguen vigentes. Este documento no las cambia.

---

## 1. Dónde estamos de verdad

### Foto del 30-08 (verificada sobre el repositorio)

| Elemento | Estado |
|---|---|
| Fase 0 (bootstrap, WP-000) | Cerrada. Coste registrado: 15,14 USD |
| Calibración de Fase 1 (WP-001…WP-005) | **Sin ejecutar.** WP-001, 003, 004 y 005 en `draft`; WP-002 `blocked` |
| WP-006 (estado de reposo) | Cerrado |
| WP-007 (traversal del guard) | `ready`, **congelado** por DEC-003, con trabajo candidato sin versionar |
| WP-008 (runtime fail-closed, núcleo) | **Activo** (`ACTIVE` → WP-008), reintento `-r2` autorizado por DEC-006 |
| WP-009 / WP-010 / WP-011 / WP-012 | Reservados; sin contrato redactado |
| Pausa de gobierno (DEC-003) | **Vigente desde el 2026-08-03**. Punto de control: **2026-09-07** |
| `claude.yml` y `code-review.yml` | Desactivados manualmente (5/5 falsos verdes del revisor automático) |
| `AI-Comercial-System` + 4 repos satélite | **Sin actividad desde febrero de 2026** |

**Actualización 2026-09-01 [verificada]:** `main` sigue en `41d7ffc` — ni un commit desde el 29-08; **la implementación de WP-008-r2 no ha empezado** (su rama no existe); no hay PRs abiertas. Además, existe un segundo plan en el equipo: el **Plan Maestro v2 de Leandro** (segunda instancia de la FDA con Kimi K3 y el proyecto Document AI) — integrado en esta v2 como «carril B» (§5, D5).

**Tres verdades incómodas, con los datos delante:**

1. **En cinco semanas la fábrica solo ha producido meta-trabajo.** ~27 PRs fusionadas y todas son gobierno del gobierno. El contrato vigente de WP-008 tiene 1.862 líneas para un cambio que, en esencia, ancla la invocación de un hook y ocho reglas de permisos.
2. **El control concluyente sigue sin construirse.** El diseño original (diagnóstico de Fase 1, B2) ya lo decía: el hook es preventivo y evitable; la verificación definitiva es el **check de alcance sobre el diff de la PR en CI** (WP-002 + WP-005). Cinco semanas de endurecimiento se invirtieron en la capa débil mientras la capa fuerte sigue en `draft`/`blocked`.
3. **El producto real está parado.** `AI-Comercial-System` lleva medio año sin un commit.

Nada de esto significa que el trabajo hecho sea malo. Significa que el rumbo necesita corrección: es la causa raíz n.º 2 del manual (§8 de [05-bloqueos-y-parada](manual/05-bloqueos-y-parada.md)) aplicada al proceso entero.

## 2. Lo que está bien y se conserva

La base conceptual de la FDA es sólida y **no se toca**. Las cinco conversaciones coinciden, los cuatro documentos de Leandro convergen en lo mismo desde fuentes distintas, y la práctica externa lo valida:

- **Contratos ejecutables por tarea** (work packages con alcance, verificación y criterios medibles) — el mismo patrón que la industria adopta como *spec-driven development* ([GitHub Spec Kit](https://github.com/github/spec-kit)), en su versión proporcional: el WP breve gana a los planes de mil líneas (evidencia CRISPY, [05](05-analisis-investigacion-leandro-y-revalidacion.md) §7).
- **La seguridad no depende de que el modelo obedezca**: permisos de GitHub, allowlists, hook, CI bloqueante, fusión humana — alineado con [OWASP para IA agéntica](https://genai.owasp.org/resource/agentic-ai-threats-and-mitigations/).
- **El estado vive en archivos versionados** (ADR-001, I1–I4) — todas las fuentes externas de 2025-26 redescubren este principio.
- **Fusión humana y decisiones escritas.**
- **Parar ante ambigüedad es el sistema funcionando** — incluida la pausa de DEC-003: paró sobre fallos reales (guard fallando en abierto, 5/5 falsos verdes). El error no fue parar; fue el tamaño de la reparación.

## 3. Diagnóstico: por qué la fábrica se atascó

**Causa 1 — Ceremonia única para todo riesgo.** [DORA — Streamlining change approval](https://dora.dev/capabilities/streamlining-change-approval/): los procesos de aprobación pesados no reducen la tasa de fallo y hacen 2,6× más probable el bajo rendimiento; funciona revisión entre pares + automatización.

**Causa 2 — La espiral de auditoría.** Cada auditoría encuentra defectos reales pero menores; cada defecto reescribe el contrato; el contrato crece; más superficie, más hallazgos. Once ciclos de WP-008 fueron esto. Ninguna auditoría tenía mandato de preguntar «¿compensa?».

**Causa 3 — Calibración invertida.** La Fase 1 existía para medir el proceso ANTES de perfeccionarlo; el proceso empezó a perfeccionarse sin datos.

**Causa 4 — Una prueba desproporcionada (WP-012).** Demostrar empíricamente que Claude Code aplica su configuración es testear el producto del proveedor. El control concluyente (diff en CI) atrapa cualquier escritura fuera de alcance aunque el hook no funcionara; y desde la v2, el **sandbox de kernel** añade una garantía superior a la que WP-012 pretendía demostrar ([05](05-analisis-investigacion-leandro-y-revalidacion.md) §5.1).

## 4. Principios de la ruta

- **P1. El enforcement tiene tres capas; el hook no es ninguna de ellas.** (v2) Capa 1: **plataforma** — protección de rama, permisos, CODEOWNERS, fusión humana. Capa 2: **sistema operativo** — sandbox con escritura restringida a nivel de kernel y egreso de red por allowlist (así operan Copilot, Codex y el Bash sandboxeado de Claude Code). Capa 3: **el diff de la PR en CI** contra el contrato del WP — el juez final, venga la escritura de donde venga. El guard queda como **feedback rápido de contrato**, valioso pero best-effort: no se invierte más en endurecer su parsing.
- **P2. Ceremonia proporcional al riesgo, decidida por script** (§6). Lo barato de revertir se procesa barato; el suelo de seguridad automatizado (SAST, secretos, tests, lockfiles) es uniforme en todos los niveles.
- **P3. La fábrica existe para el producto.** El meta-trabajo se raciona y se mide.
- **P4. Gates por evidencia, no por calendario.** Las fechas orientan; los criterios de salida vinculan (ADR-001 M1–M3 vigentes).
- **P5. Lo más simple que funcione, primero** ([Anthropic — Building effective agents](https://www.anthropic.com/engineering/building-effective-agents); anti-patrones de la guía §7).
- **P6. Multi-agente solo cuando la tarea lo pide; capacidades nativas antes que runner propio.** (v2) Claude Code ya trae subagentes con worktree y [Agent Teams](https://code.claude.com/docs/en/agent-teams); el harness SDK de ADR-001 se evalúa contra lo nativo primero. Los agentes se añaden por composición, no por catálogo.
- **P7. Los agentes de desarrollo y los de negocio son productos distintos.**
- **P8. Git guarda la verdad normativa; la telemetría vive fuera.**
- **P9. Medir desde el día 0.** (v2) La percepción de productividad engaña (METR: brecha de decenas de puntos entre percepción y medición; su RCT corregido en feb-2026 pasó de −19 % a ≈−4 % [IC −15/+9] — ni milagro ni desastre: **hay que medir**). ccusage y minutos humanos por WP desde ya; el detalle en §7.
- **P10. Las asunciones del harness caducan.** (v2) Cada salto de modelo dispara una re-auditoría ligera del template (ítem fijo de retro): qué piezas existen por limitaciones que ya no existen.

## 5. La ruta

**Dos carriles desde la v2 (pendiente de D5):** **Carril A** — este repositorio como plantilla/upstream + el camino Agent OS vía AI-Comercial-System (ámbito de Iván). **Carril B** — la primera instalación externa de la plantilla (plan de Leandro): repo propio, Kimi K3 **como experimento gateado**, proyecto Document AI. Contrato entre carriles: la instalación registra el commit de plantilla del que parte; las mejoras probadas en B vuelven al upstream como PRs; K3 y sus datos no entran en el carril A sin pasar su gate (RGPD incluido). Detalle y veredictos: [05](05-analisis-investigacion-leandro-y-revalidacion.md) §4.1–4.3.

### Etapa 0 — Hoy → 2026-09-07: preparar el punto de control (revisada en v2)

1. **No iniciar la implementación de WP-008-r2** hasta decidir D6 — no hay trabajo hundido que proteger y el contrato puede simplificarse en la misma cita. `ACTIVE` no se toca (sigue siendo acto de operador).
2. Material del punto de control: esta hoja de ruta v2 + [05](05-analisis-investigacion-leandro-y-revalidacion.md) + Anexo A. **Hecho.**
3. **No abrir ningún otro frente.**

### Etapa 1 — 2026-09-07: el punto de control (ampliado en v2)

DEC-003 §5 y DEC-005 §8 exigen en esa fecha revisión y análisis por escrito; este documento y el 05 son ese material. **Regla anti-espiral: cada decisión tiene default escrito; lo que no se decida ese día queda en su default, sin re-deliberación posterior.** El Anexo A trae el borrador de DEC-007.

| # | Decisión | Recomendación (default en cursiva) |
|---|---|---|
| **D1** | **WP-012**: ¿mantener el runner empírico como condición de salida, o sustituirlo? | **Sustituir** por prueba de humo documentada + check de alcance en CI (+ sandbox, que da garantía de kernel superior). *Default si no se decide: mantener secuencia DEC-005/006 tal cual* |
| **D2** | **Reforma del proceso**: ¿adoptarla, ahora con niveles decididos por script (blast radius)? | **Adoptar** (§6). *Default: solo documentada, como hoy* |
| **D3** | **Esta hoja de ruta v2**: ¿fusionarla como rumbo vinculante? | **Fusionar**, admitiéndola en DEC-003 §4 por el mecanismo atómico ya usado. *Default: sigue en rama, no vinculante* |
| **D4** | **Paquete de mejoras de Leandro** (Δ1–Δ12 según matriz de [05](05-analisis-investigacion-leandro-y-revalidacion.md) §4.6) | **Adoptar el paquete marcado ADOPTAR** e incorporarlo a Etapas 2–3. *Default: nada se adopta* |
| **D5** | **Dos carriles (upstream/downstream)**: instalación de Leandro como carril B con contrato de retorno; prioridad de producto; accesos/CODEOWNERS | **Aprobar el modelo de dos carriles** con las modificaciones de [05](05-analisis-investigacion-leandro-y-revalidacion.md) §4.1–4.2 (INSTALL.md, retorno vía PRs, K3 gateado con evaluación RGPD). *Default: sin acuerdo formal — riesgo de divergencia* — **decisión en parte de negocio: es tuya** |
| **D6** | **WP-008-r2**: ¿ejecutar el contrato íntegro o reducirlo al núcleo mínimo? | **Núcleo mínimo**: parche de settings (comando canónico + 8 reglas) + preflight + suite, sin la maquinaria roja/verde de captura de CI (una PR-sonda de 10 min demuestra el bloqueo); el resto se archiva como superado vía DEC-007. *Default: ejecutar el contrato vigente íntegro* |

### Etapa 2 — Cierre de la pausa (estimación orientativa: 1–3 semanas tras el 07-09)

Secuencia (ajustada por D1/D6; cada transición de `ACTIVE` sigue siendo acto de operador):

1. **WP-009 — acciones fijadas por SHA** (pequeño, REQ-FDA-002; contrato ≤150 líneas).
2. **WP-008 núcleo** según D6 (mínimo recomendado o íntegro por default).
3. **Prueba de humo o WP-012**, según D1.
4. **WP-002+005 — `check_scope` sobre el diff de la PR en CI**, implementado sobre una **librería única de matching** con suite pytest; después, **guard delgado sobre la misma librería** (parche aplicado por persona, carril T3), y **WP-007 se cierra** — ejecutado o superado según lo decidido, preservando su candidato congelado como evidencia ([05](05-analisis-investigacion-leandro-y-revalidacion.md) §4.5).
5. **Sandbox nativo (nuevo en v2):** experimento E2 y, si pasa, WP T3 que activa el Bash sandboxeado (escritura kernel-restringida + egreso por allowlist) para el implementer.

**Criterio de salida:** pausa cerrada por PR de operador (DEC-003 `superada`, arrastrando el registro de §3) **y** check de alcance bloqueante en el ruleset.

**Qué NO hacer:** añadir agentes; tocar `tests/guard/run-suite.sh` fuera de lo decidido en DEC-007; abrir el harness SDK; adoptar Spec Kit/OpenSpec como capa; construir dashboards.

### Etapa 3 — Calibración exprés, medición e higiene (≈ 2 semanas)

La Fase 1 original con su propósito original — **medir** —, más el paquete Δ adoptado en D4 (todo T1/T2, contratos breves):

1. **WP-001** (glosario) — fija coste y fricción de referencia. **WP-003 y WP-004** (encargos-trampa) — validan las paradas.
2. **WP-010 ampliado — coste y métricas**: adquisición headless (ccusage/OTel), rollup por WP, y **parada dura de coste** (Δ7) en `run-verification`. ccusage como hábito ya desde hoy (Δ1).
3. **Plantilla y manual**: output mínimo en verificaciones (Δ5), `gotchas.md` podado (Δ3), fase de preguntas concretas pre-WP (Δ11, manual 03), `progress.md` de traspaso opcional (Δ12), ítem de retro «re-auditoría por salto de modelo» (Δ2, manual 06).
4. **Simulacro adversarial completo** (fusión de la «prueba en seco» de Leandro y el fire-drill propio): fuera-de-alcance · bypass por Bash · symlink · parada por presupuesto · **PR con defecto sembrado que la cadena de revisión debe cazar**. Trimestral desde entonces.
5. **Higiene de plantilla** (T1/T2): `README.md`, `LICENSE`, autorización de actores en `claude.yml` antes de reactivarlo, guía de separación plantilla/sandbox, semgrep anti-error-masking cuando haya Python en CI (Δ4), política anti-slopsquatting para instalaciones con dependencias ([05](05-analisis-investigacion-leandro-y-revalidacion.md) §5.2).
6. **WP-011 — frontera de revisión verificable**: veredicto estructurado validado por schema y reactivación de `code-review.yml`. Regla Δ8: el revisor nunca comparte modelo ni contexto con el implementador.

**Criterio de salida:** métricas base de ADR-001 sobre ≥ 5 WPs reales (coste/WP, % a la primera, ciclos, **minutos humanos/WP**).

### Etapa 4 — Fase 2 real: la fábrica trabaja sobre el producto (≈ 4–8 semanas)

**Carril A:** instalar la FDA en **`AI-Comercial-System`** — programas **INV** (higiene: hoy versiona `.venv/`, `__pycache__/`, `logs/`; mapa de módulos; línea base de tests y de comportamiento ANTES de refactorizar — mitiga la advertencia brownfield de ACE-FCA), **CONTRACTS** (`AgentDefinition`, `AgentRun`+eventos, `ToolDefinition`, `ModelGateway`, `PolicyDecision`/`ApprovalRequest`; regla «breaking = DEC + migración») y **MIG** (envolver sin cambiar comportamiento; la línea base de INV lo verifica). **Carril B:** Document AI como calibración greenfield, con sus gates propios (E1 de K3 incluido). Aprendizajes cruzados vía upstream.

**Criterio de salida (A):** el sistema real funciona a través de los contratos, con sus tests en verde.

### Etapa 5 — El Agent OS emerge (estrangulamiento progresivo)

Kernel mínimo como monolito modular (PostgreSQL fuente de verdad operacional; Redis caché): registro de agentes y herramientas, *tool gateway* con validación/permisos/auditoría, persistencia de runs y eventos, frontera de políticas, aprobaciones con pausa/reanudación. **Checklist de diseño: [12-factor agents](https://github.com/humanlayer/12-factor-agents)** (v2). Ejecución durable al necesitarla: DBOS/Restate (sin infra nueva, sobre Postgres) o Temporal si el caso lo exige (v2). Después: el **segundo agente genuinamente distinto** (prueba de generalidad), plataforma de evaluaciones, arquitectura de datos multi-tenant (RLS, outbox, warehouse — doc 04, T9).

**Criterio de salida:** dos agentes distintos sobre el mismo kernel sin modificar su núcleo; evaluaciones automáticas por versión.

### Etapa 6 — Escalar: orquestación, operaciones y la organización agéntica

- **Primero lo nativo** (v2): subagentes con worktree y Agent Teams cubren paralelismo coordinado en una máquina; **harness SDK propio solo si M1+M2+M3 de ADR-001 se cumplen contra lo nativo** (M2 se reevalúa: «lo que Actions/Teams no expresa»). Merge queue de GitHub al concurrir WPs.
- **Plano de operaciones:** OpenTelemetry, lineage, detectores deterministas, runbooks cerrados, autonomía A0–A5 **por acción**.
- **Agentes por composición** (rol × especialidad × herramientas × políticas); el organigrama de ~200 capacidades es mapa, no backlog.
- **La agencia comercial** (plataforma + packs verticales + tenants) sobre el Agent OS.

**Qué NO construir hasta que su señal aparezca** (lista fusionada v2, vinculante como criterio): Grafana/dashboards (hasta escala de equipo) · marketplace de plugins · orquestación sobre APIs no públicas · Spec Kit/OpenSpec como capa · búsqueda semántica en el flujo diario · MCPs wrapper de CLIs · hooks de validación post-edit · panel/BD/colas distribuidas/multi-tenant del harness · meta-agente que redacta WPs solo.

## 6. La reforma del proceso — PROPUESTA v2 (se decide el 07-09, D2)

Niveles **decididos por script** (blast radius sobre rutas declaradas y diff; misma librería que `check_scope`), no por juicio por WP:

| Nivel | Superficie (la decide el clasificador) | Proceso |
|---|---|---|
| **T1 — ligero** | Solo `docs/**`, `tests/**`, `evidence/**` | Contrato de 1 página; 1 pasada de code-reviewer; sin security-reviewer |
| **T2 — estándar** | Código de producto, `scripts/**`, specs | Ciclo completo del manual |
| **T3 — sensible** | `.claude/**`, `.github/**`, permisos, secretos, migraciones, IaC, contratos de datos, `CODEOWNERS` | Ciclo completo + security-reviewer + parche aplicado por persona |

**Suelo innegociable en TODOS los niveles** (v2; evidencia Veracode: ~45 % del código IA introduce vulnerabilidades, sin mejora entre ciclos): SAST/semgrep cuando aplique, escaneo de secretos, tests, lockfiles verificados. Los niveles modulan ceremonia y profundidad de revisión, **nunca** el suelo.

Límites transversales: contrato ≤ 300 líneas (si necesita más, el troceado está mal); ≤ 1 de cada 3 WPs sobre la propia FDA tras la pausa; auditorías clasifican por severidad y solo lo bloqueante detiene; tercer ciclo dispara «¿pártelo?» antes que «¿reescríbelo?»; el revisor nunca comparte modelo ni contexto con el implementador (Δ8).

## 7. Métricas (v2: desde hoy, no desde la Etapa 3)

**Desde ya (coste cero):** ccusage por sesión; **minutos humanos por WP** (cronómetro manual); % WPs de producto vs meta. **Desde la Etapa 3 (WP-010):** coste/WP validado headless, % a la primera, ciclos medios, regresiones, resultado de simulacros. **Objetivo de calibración:** ≥ 75 % a la primera y ≤ 1 ciclo medio (M1 de ADR-001). **Desde la Etapa 5:** tasa de resolución autónoma, tasa de escalada humana, coste por resultado útil. Razón de fondo (P9): la percepción engaña; solo lo medido cuenta.

## 8. Riesgos principales y sus señales

| Riesgo | Señal de alarma | Respuesta |
|---|---|---|
| Recaer en la espiral de meta-trabajo | 2 WPs seguidos sobre la FDA, o un contrato > 300 líneas | Aplicar §6; punto de control extraordinario |
| El punto de control se convierte en re-deliberación | El 07-09 acaba sin decisiones escritas | Defaults del Anexo A entran en vigor tal cual |
| **Divergencia de carriles** (v2) | La instalación B deja de reportar origen o de devolver mejoras | Reactivar el contrato upstream/downstream (D5) o declarar el fork explícitamente |
| **K3: datos y compatibilidad** (v2) | Código de clientes viajando al endpoint sin evaluación RGPD; roturas del harness | El gate E1 es prerrequisito; sin él, K3 no toca código real |
| El producto sigue parado | Etapa 4 sin empezar 8 semanas tras cerrar la pausa | Repriorización del operador: producto por delante |
| Prompt injection al reactivar `claude.yml` | Reactivación sin autorización de actores | Vetado: la autorización explícita es prerrequisito (Etapa 3.5) |
| Dependencia de un solo humano | — | Mitigado en parte por el carril B; formalizar accesos en D5 |

## 9. Huecos de gobierno conocidos (transparencia)

1. **Las herramientas de escritura vía API no pasan por el guard local.** Los documentos de esta rama se materializaron por esa vía, por encargo directo del operador, sin tocar `main`. Cierre definitivo: el check de alcance en CI (Etapa 2.4) + sandbox (Etapa 2.5), que juzgan el resultado venga de donde venga. Hasta entonces, esta vía queda reservada a actos de operador explícitamente encargados.
2. **Plantilla y sandbox mezclados** en el mismo repo → guía de separación (Etapa 3.5); el modelo upstream/downstream de D5 lo vuelve urgente y útil.
3. **`claude.yml` sin autorización explícita de actores** — desactivado hoy; prerrequisito antes de reactivar.
4. **Adaptaciones locales de otros runtimes** (`.agents/`, `.codex/`, `AGENTS.md`) sin versionar y fuera de gobierno (DEC-003 §8); cualquier uso como implementador exige su DEC propia — aplica también al endpoint K3 en el carril A.

---

## Anexo A — Borrador de DEC-007 para el punto de control (2026-09-07) — v2

Un único diff atómico de operador que: (1) cree `specs/decisions/DEC-007-punto-de-control-y-rumbo.md` con las decisiones **D1–D6** tal como queden (con sus defaults si alguna no se decide); (2) añada a la lista cerrada de DEC-003 §4 las entradas `DEC-007` y `docs/03–05` (mecanismo atómico de DEC-005/006); (3) si D1 = sustituir: enmiende DEC-003 §6 — tercera condición → «prueba de humo documentada en `evidence/` + check de alcance bloqueante en CI», liberando WP-012; (4) si D2 = adoptar: registre la reforma §6 y encargue su materialización (manual + `_TEMPLATE.md` + clasificador) como primera PR de operador tras la pausa; (5) si D4 = adoptar: enumere los Δ adoptados y su destino (Etapas 2–3); (6) si D5 = aprobar: registre el contrato entre carriles (INSTALL.md con commit de origen, retorno vía PRs, gates de K3 con evaluación RGPD, numeración local por repo) — los aspectos de negocio (prioridad de producto, accesos) los fija el operador en la propia DEC; (7) si D6 = núcleo mínimo: autorice la reducción del contrato de WP-008-r2 en PR de operador de un solo archivo (patrón PR B de DEC-006), declarando superadas las secciones de captura roja/verde, y mantenga el resto de DEC-006 intacto; y (8) fusione esta hoja de ruta v2 como rumbo vinculante. **Lo que no puede pasar es que el 07-09 termine sin decisión escrita**: para eso están los defaults.

## Anexo B — Glosario mínimo (para lectura no técnica)

- **FDA**: la «fábrica» — reglas, contratos y agentes con los que la IA desarrolla software de forma controlada.
- **Agent OS**: el producto futuro — la plataforma que ejecutará agentes de negocio con permisos, aprobaciones y auditoría.
- **WP (work package)**: un encargo pequeño con contrato: qué se hace, qué archivos se pueden tocar, cómo se verifica.
- **Guard / hook**: el programa que avisa y bloquea en el momento escrituras fuera del contrato. Feedback rápido, no garantía.
- **Sandbox**: jaula a nivel de sistema operativo — el agente físicamente no puede escribir fuera de su carpeta ni salir a internet salvo a dominios permitidos.
- **Check de alcance en CI**: la comprobación en GitHub que revisa el resultado final (el diff) contra el contrato. El juez final.
- **Blast radius**: «radio de impacto» de un cambio; un script lo calcula y decide cuánta ceremonia y revisión necesita.
- **Upstream / downstream (carriles A/B)**: la plantilla canónica y sus instalaciones; las mejoras probadas abajo vuelven arriba.
- **Pausa (DEC-003)**: freno de emergencia del 03-08; se sale cumpliendo condiciones medibles.
- **PR de operador**: cambio del andamiaje aprobado por ti; distinto de una PR de implementación.
- **Meta-trabajo**: trabajo de la fábrica sobre sí misma, en vez de sobre el producto.
