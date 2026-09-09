# Hoja de ruta — de la FDA al AI Agent Operating System

**Creada:** 2026-08-30 · **Última revisión: 2026-09-09** (ratificación de D3 y precisión de D2 — ver Registro de revisiones) · **Estado:** **VIGENTE** desde la fusión en `main` de DEC-007; D5 queda sin acuerdo formal y el carril B continúa como propuesta, no como asignación activa · **Ámbito:** `fda-template` (carril A) y su primera instalación externa propuesta (carril B), y los proyectos que gobernarían: `AI-Comercial-System`/Agent OS y Document AI.

**Procedencia.** v1 (30-08): las cinco conversaciones del operador con otras IAs — síntesis en [`04-analisis-conversaciones-ia.md`](04-analisis-conversaciones-ia.md)—, el repositorio completo, el estado de los demás repos y fuentes externas. v2 (01-09): además, los **cuatro documentos de investigación de Leandro** y una **línea base de investigación independiente registrada antes de leerlos** — análisis completo, veredictos y red team en [`05-analisis-investigacion-leandro-y-revalidacion.md`](05-analisis-investigacion-leandro-y-revalidacion.md). Lo redactaron y materializaron sesiones de Claude Code por encargo directo del operador, como actos de operador (§9).

## Registro de revisiones

| Fecha | Qué cambió | Dónde está el razonamiento |
|---|---|---|
| 2026-08-30 | Versión inicial | [04](04-analisis-conversaciones-ia.md) |
| 2026-09-01 | Enforcement en tres capas (P1); reforma con blast radius ejecutable; punto de control ampliado a D1–D6; dos carriles upstream/downstream; paquete de mejoras de Leandro incorporado; Etapas 0–1 reescritas al estado real; métricas y riesgos ampliados | [05](05-analisis-investigacion-leandro-y-revalidacion.md) §9–§10 |
| 2026-09-03 (preparado para el punto de control del 2026-09-07) | **Corrección de foto local**: la rama `-r2` existe en local y no está publicada; 72 archivos candidatos, batería 22/22 y ciclos 1 y 2 cerrados; cero commit de implementación, cero PR y cero fase real. Etapa 0 extiende «no iniciar» a «no continuar» como inferencia declarada. Anexo A pasa a traer las dos ramas de D6 y el tratamiento de la candidata local. **Las recomendaciones y defaults D1–D6 no cambian** | [05](05-analisis-investigacion-leandro-y-revalidacion.md) §1-bis y §6 · `DEC-007` |
| 2026-09-09 | D1, D2, D3, D4 y D6 ratificadas; D5 resuelta por su default. D2 eleva cambios que alteran controles aunque vivan bajo `tests/**` o `evidence/**` | `DEC-007` |

---

## 0. Si eres un agente de IA, empieza por aquí

1. **Orden de lectura:** `CLAUDE.md` → este documento → [`manual`](manual/MANUAL.md) → decisiones vigentes (`specs/decisions/`, en orden) → [05](05-analisis-investigacion-leandro-y-revalidacion.md) si necesitas el porqué de la v2 → el WP activo, si lo hay.
2. **No re-litigues decisiones cerradas.** Si crees que una decisión es errónea, prepáralo como propuesta para el siguiente punto de control o como borrador de DEC en solo lectura.
3. **Ceremonia proporcional al riesgo** (§6). Antes de proponer un control o proceso nuevo, responde por escrito: ¿qué fallo real y observado previene? ¿qué capa existente lo cubre ya? ¿cuánto cuesta mantenerlo? Si no puedes responder las tres, no lo propongas.
4. **La fábrica existe para fabricar producto.** El éxito se mide en software útil entregado (§7), no en controles añadidos ni en número de agentes.
5. Las ocho condiciones de parada de `CLAUDE.md` y del manual siguen vigentes. Este documento no las cambia.
6. **Estatus normativo de 03, 04 y 05.** Este documento es la **hoja de ruta normativa** si D3 se ratifica. [`04`](04-analisis-conversaciones-ia.md) y [`05`](05-analisis-investigacion-leandro-y-revalidacion.md) se fusionan como **procedencia, análisis y fotos fijas**: **no gobiernan por sí solos el estado actual** y **no son normas de estado equiparables** a este documento. Cuando una descripción temporal de 04 o de 05 contradiga el estado explícito del principio **P1** de §4 —presentes indicativos sobre `check_scope`, sobre el diff en CI como juez final o sobre el sandbox—, **manda P1 y el glosario del Anexo B** (`DEC-007`, D3, «Regla de prevalencia temporal»). No cites «03–05» en bloque como si los tres fijaran estado.

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

**Actualización 2026-09-01 [verificada sobre GitHub]:** `main` sigue en `41d7ffc` — ni un commit desde el 29-08; **en GitHub no existían rama `-r2`, implementación publicada ni PR abierta**; no hay PRs abiertas. Además, existe un segundo plan en el equipo: el **Plan Maestro v2 de Leandro** (segunda instancia de la FDA con Kimi K3 y el proyecto Document AI) — integrado en esta v2 como «carril B» (§5, D5).

**Corrección de foto (2026-09-07) [verificada en local, solo lectura].** La observación del 01-09 alcanzaba únicamente a lo publicado y de ella se infirió que la implementación no había empezado. El estado local es distinto y se incorpora antes de fusionar:

| Magnitud local | Estado verificado |
|---|---|
| Worktree | worktree local de la rama `wp/WP-008-runtime-fail-closed-r2` (ruta absoluta deliberadamente no versionada) |
| Rama `wp/WP-008-runtime-fail-closed-r2` | **Existe en local; no publicada** |
| Base | `HEAD = main = origin/main = 41d7ffcb25e5283f1ff04cc516211ce9549caa66` |
| Candidata física | **72 archivos regulares**: 46 bajo `tests/runtime/` + 26 bajo `evidence/WP-008/` |
| Batería A | **22/22, cerrada**; ciclos de corrección **1 y 2 cerrados** (`2 / 2`) |
| Revisiones | QA, code review y security review exigen cambios: los seis defectos `WP008-F1`–`WP008-F6`, definidos en `DEC-007` |
| Historia publicada | **cero commit de implementación, cero PR y cero fase real** |

Por tanto **sí existe trabajo y coste hundidos en local**, aunque no haya historia publicada. Esto **no cambia la recomendación de D6**, pero sí su fundamento: el núcleo mínimo se recomienda por **coste futuro**, **proporcionalidad de la ceremonia** y las **tres capas de enforcement** de P1 —no porque el trabajo previo no exista—. La candidata local se preserva como evidencia histórica no conforme (Anexo A); no se borra de la historia ni se presenta como conforme.

**Tres verdades incómodas, con los datos delante:**

1. **En cinco semanas la fábrica solo ha producido meta-trabajo.** ~27 PRs fusionadas y todas son gobierno del gobierno. El contrato vigente de WP-008 tiene 1.862 líneas para un cambio que, en esencia, ancla la invocación de un hook y ocho reglas de permisos.
2. **El control concluyente sigue sin construirse.** El diseño original (diagnóstico de Fase 1, B2) ya lo decía: el hook es preventivo y evitable; la verificación definitiva es el **check de alcance sobre el diff de la PR en CI** (WP-002 y después WP-005, dos WPs secuenciales). Cinco semanas de endurecimiento se invirtieron en la capa débil mientras la capa fuerte sigue en `draft`/`blocked`.
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

**Causa 4 — Una prueba desproporcionada (WP-012).** Demostrar empíricamente que Claude Code aplica su configuración es testear el producto del proveedor. El control concluyente **previsto** —`check_scope` sobre el diff de la PR en CI— **atraparía** cualquier escritura fuera de alcance aunque el hook no funcionara, **cuando `WP-002` y `WP-005` lo materialicen**; y desde la v2, el **sandbox de kernel aportaría** una garantía de kernel superior a la que WP-012 pretendía demostrar, **solo si E2 supera su gate y el WP T3 lo adopta efectivamente** ([05](05-analisis-investigacion-leandro-y-revalidacion.md) §5.1). **Ninguno de los dos existe hoy:** `check_scope` no está implementado y el sandbox no está instalado (P1). El argumento de esta causa es de **arquitectura objetivo y coste futuro**, no de control disponible.

## 4. Principios de la ruta

- **P1. El enforcement debe tener tres capas, y el hook no es ninguna de ellas.** (v2) Es la **arquitectura objetivo**, no la foto actual. Capa 1: **plataforma** — protección de rama, permisos, CODEOWNERS, fusión humana. Capa 2: **sistema operativo** — sandbox con escritura restringida a nivel de kernel y egreso de red por allowlist (así operan Copilot, Codex y el Bash sandboxeado de Claude Code). Capa 3: **el diff de la PR en CI** contra el contrato del WP — el juez final, venga la escritura de donde venga.

  **Estado de materialización, que no debe confundirse con la dirección:**

  | Capa | Estado hoy |
  |---|---|
  | 1 · Plataforma | **Parcialmente materializada.** Es lo único que hoy funciona como frontera, pero **no entera**: ver el desglose en cinco niveles justo debajo |
  | 2 · Sandbox del SO | **No instalado.** Gate futuro: depende del experimento E2 (§5, Etapa 2). Mientras no se instale y se mida, **no aporta ninguna garantía efectiva** y no puede contarse como control |
  | 3 · `check_scope` sobre el diff en CI | **No implementado.** Lo construyen WP-002 (`blocked`) y WP-005 (`draft`), en ese orden. **Tres estados que no deben fundirse:** *(1)* **ejecutable local** de `WP-002`, que no bloquea nada; *(2)* **job ejecutándose en CI** por `WP-005`, **todavía no requerido**; *(3)* **check incorporado a `required_status_checks`** por una persona, único estado **bloqueante para la fusión**. **Hoy no existe ninguno de los tres** |

  **Desglose de la capa 1, en cinco niveles que no deben fundirse:**

  1. **Impuesto técnicamente por el ruleset:** PR obligatoria; los tres checks bloqueantes; `non_fast_forward` y `deletion` bloqueados. **Esas cuatro reglas son todo lo acreditado por el expediente actual**, que **no incluye un inventario exhaustivo del ruleset**: no se ha acreditado ninguna regla del ruleset que impida la autofusión; con `required_approving_review_count: 0` y `require_code_owner_review: false`, las vías observadas no la impiden por sí solas.
  2. **Práctica del operador, no impuesta por el ruleset:** la lectura del diff y la fusión humana.
  3. **Política vigente, no impuesta técnicamente:** `CLAUDE.md` prohíbe que un agente fusione su propia PR.
  4. **Restricciones operativas actuales:** las allowlists de herramientas de `.claude/agents/*.md` y los workflows de agente desactivados (`DEC-003` §3). Reducen la superficie, pero **no son garantía universal**: no se han auditado todos los actores ni todas las credenciales.
  5. **Declarado necesario y todavía NO impuesto técnicamente:** al menos una aprobación humana y la revisión de `CODEOWNERS`. El ruleset registra hoy `required_approving_review_count: 0` y `require_code_owner_review: false`; `DEC-003` lo consigna como **riesgo abierto y no aprobado**, con destino **WP-011**. **Riesgo pendiente:** con cero aprobaciones exigidas, el ruleset no impide por sí solo que el autor de una PR la fusione si tiene permisos suficientes.

  **La protección de rama no comprueba el alcance del WP.** Ese control es `check_scope`, que no existe todavía; hasta entonces la revisión del diff es una **práctica humana**, no una barrera automática ni obligatoria del ruleset. **Dos cosas distintas, que no deben fundirse:** `check_scope` es **código que se ejecutaría en CI**, y su carácter **bloqueante para la fusión** dependería de que ese check se **incorpore como *required status check* del ruleset**. **Hoy no existe ninguna de las dos.** Y esa incorporación **no crearía un quinto tipo de regla**: el ruleset acredita **cuatro tipos** —`deletion`, `non_fast_forward`, `pull_request` y `required_status_checks`—, y añadir `check_scope` significa **añadir una cuarta comprobación requerida dentro de la regla `required_status_checks` ya existente**, que hoy contiene tres.

  El **guard** es hoy **feedback preventivo best-effort**: deniega en el momento lo que reconoce, falla abierto si no es ejecutable o no llega a invocarse, y su analizador de `Bash` tiene huecos documentados. Sigue siendo obligatorio. **Dirección aprobada:** no invertir más en endurecer su parsing, porque el retorno está en las capas 2 y 3. **Lo que esta dirección todavía NO hace:** declarar consumada la democión formal y definitiva de ese parser. Esa democión se declara cuando **E2 se resuelva y su gate quede decidido** —así lo condiciona [05](05-analisis-investigacion-leandro-y-revalidacion.md) §8—, no antes. Hasta entonces el guard conserva su papel y su mantenimiento correctivo.
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

**Dos carriles propuestos desde la v2 (D5 resuelta sin acuerdo formal):** **Carril A** — este repositorio como plantilla/upstream + el camino Agent OS vía AI-Comercial-System (ámbito de Iván). **Carril B propuesto, todavía no asignado ni autorizado** — la primera instalación externa de la plantilla (plan de Leandro): repo propio, Kimi K3 como experimento gateado y proyecto Document AI. Antes de activar B, una decisión humana posterior debe fijar responsables, repositorio, origen, retorno, accesos y gates de datos. Detalle y veredictos: [05](05-analisis-investigacion-leandro-y-revalidacion.md) §4.1–4.3.

### Etapa 0 — Hoy → 2026-09-07: preparar el punto de control (revisada en v2)

1. **No iniciar la implementación de WP-008-r2** hasta decidir D6 — el contrato puede simplificarse en la misma cita. `ACTIVE` no se toca (sigue siendo acto de operador).
2. **No continuar tampoco la candidata local** — *inferencia derivada de la foto corregida, no cita literal de la fuente*. El literal de la v2 decía «no iniciar», porque partía de la premisa —hoy corregida— de que no existía trabajo empezado. Incorporada la foto local, la misma finalidad de esta etapa alcanza a **no continuar**: seguir invirtiendo esfuerzo en maquinaria que D6 puede retirar frustraría el punto de control. La distinción entre el literal y esta extensión se declara expresamente y no se presenta como cita.
3. Material del punto de control: esta hoja de ruta v2 + [05](05-analisis-investigacion-leandro-y-revalidacion.md) + Anexo A. **Hecho.**
4. **No abrir ningún otro frente.**

### Etapa 1 — Punto de control resuelto el 2026-09-09

DEC-003 §5 y DEC-005 §8 exigían revisión y análisis. DEC-007 registra el resultado efectivo; la fecha prevista del 07-09 queda como antecedente histórico y no activa defaults por sí sola.

| # | Resultado efectivo |
|---|---|
| **D1** | **Ratificada:** humo seguro en WP-008 + `check_scope` en CI y requerido + resolución de E2 |
| **D2** | **Ratificada con precisión:** clasificador ejecutable, suelo común y prevalencia T3 |
| **D3** | **Ratificada:** esta hoja es normativa; 04/05 son procedencia y fotos fijas |
| **D4** | **Ratificada:** solo los elementos marcados ADOPTAR, en sus etapas |
| **D5** | **Default:** sin acuerdo formal; el carril B no se asigna ni activa |
| **D6** | **Ratificada:** WP-008 se reduce al núcleo mínimo con cuenta nueva `0 / 2` |

### Etapa 2 — Cierre de la pausa (estimación orientativa: 1–3 semanas tras el 07-09)

Secuencia (ajustada por D1/D6; cada transición de `ACTIVE` sigue siendo acto de operador):

1. **WP-009 — acciones fijadas por SHA** (pequeño, REQ-FDA-002; contrato ≤150 líneas).
2. **WP-008 núcleo** según D6 (mínimo recomendado o íntegro por default).
3. **Humo seguro dentro de WP-008**, conforme a D1 ratificada. No es un paso propio ni un estado de `ACTIVE`: se ejecuta antes de cerrar WP-008 y deja evidencia saneada en `evidence/WP-008/`. Usa un proyecto desechable fuera de la raíz FDA y un `.env` sintético sin secretos reales; queda prohibido tocar `.env`, secretos o archivos reales de FDA. Si falla, WP-008 no se cierra. WP-012 deja de ser condición de salida.
4. **WP-002, y después WP-005 — `check_scope` sobre el diff de la PR en CI.** Son **dos WPs secuenciales**, nunca uno solo: cada uno con su contrato, su rama y su PR, y nunca activos a la vez. **WP-002** construye la **librería única de matching** y `check_scope` con suite pytest; requiere antes una PR de operador que corrija su contrato y lo saque de `blocked`. **WP-005** lo integra en `ci.yml` y lo deja **ejecutándose en CI**; requiere antes una PR de operador que **corrija integralmente su contrato** —hoy **no es ejecutable**— y lo lleve de `draft` a `ready`, conforme a `DEC-003` §2.d: **parche humano de `ci.yml`** porque la ruta está en `permissions.deny`, **`evidence/WP-005/**` en su allowlist**, y **política elegida para las ramas `ops/*`**, que hoy el job haría fallar —cualquiera que se elija debe garantizar que el **contexto requerido siempre reporta una conclusión terminal**, que el **nombre de rama no basta** para reconocer al operador, que `wp/*` **sigue fail-closed** y que un fallo de verificación **cierra**—. **Convertirlo en bloqueante para la fusión no es trabajo de WP-005**: es una **mutación humana del ruleset** posterior a que el job reporte desde `main`, y se registra, conforme al contrato de evidencia canónica de `DEC-007`, en una **PR de operador de cierre** que en un **único diff atómico** marca `WP-005` `done` **y** escribe reposo en `ACTIVE` —nunca en diffs separados—. Solo **después** llega el **guard delgado sobre esa misma librería** (parche aplicado por persona, carril T3), y por último **WP-007 se cierra** —ejecutado o superado según lo decidido, en acto separado y expresamente registrado—, preservando su candidato congelado como evidencia ([05](05-analisis-investigacion-leandro-y-revalidacion.md) §4.5, que recomienda exactamente esta secuencia y no una fusión).
5. **Sandbox nativo (nuevo en v2):** experimento E2 y, si pasa, un WP de nivel T3 que activa el Bash sandboxeado (escritura kernel-restringida + egreso por allowlist) para el implementer. **Ninguno de los dos tiene identificador reservado**: antes de ejecutarlos hace falta una decisión o enmienda que fije su `WP-NNN`, apruebe el contrato y lo admita en la lista cerrada de DEC-003 §4. Mientras tanto `ACTIVE` permanece en reposo.

**Criterio de salida:** pausa cerrada por PR de operador (DEC-003 `superada`, arrastrando el registro de §3) **y** check de alcance ejecutándose en CI **e incorporado como *required status check* del ruleset**, que es lo que lo haría bloqueante para la fusión.

**Qué NO hacer:** añadir agentes; tocar `tests/guard/run-suite.sh` fuera de lo decidido en DEC-007; abrir el harness SDK; adoptar Spec Kit/OpenSpec como capa; construir dashboards.

### Etapa 3 — Calibración exprés, medición e higiene (≈ 2 semanas)

La Fase 1 original conserva su propósito —**medir**— y añade el paquete Δ adoptado en D4. Cada cambio se clasifica por superficie y efecto; T3 prevalece y no hay una etiqueta global T1/T2 para la etapa.

1. **WP-001** (glosario) — fija coste y fricción de referencia. **WP-003 y WP-004** (encargos-trampa) — validan las paradas.
2. **WP-010 ampliado — coste y métricas**: adquisición headless (ccusage/OTel), rollup por WP, y **parada dura de coste** (Δ7) en `run-verification`. ccusage como hábito ya desde hoy (Δ1).
3. **Plantilla y manual**: output mínimo en verificaciones (Δ5), `gotchas.md` podado (Δ3), fase de preguntas concretas pre-WP (Δ11, manual 03), `progress.md` de traspaso opcional (Δ12), ítem de retro «re-auditoría por salto de modelo» (Δ2, manual 06).
4. **Simulacro adversarial completo** (fusión de la «prueba en seco» de Leandro y el fire-drill propio): fuera-de-alcance · bypass por Bash · symlink · parada por presupuesto · **PR con defecto sembrado que la cadena de revisión debe cazar**. Trimestral desde entonces.
5. **Higiene de plantilla**: `README.md`, `LICENSE`, autorización de actores en `claude.yml` antes de reactivarlo, guía de separación plantilla/sandbox, semgrep anti-error-masking cuando haya Python en CI (Δ4), política anti-slopsquatting para instalaciones con dependencias ([05](05-analisis-investigacion-leandro-y-revalidacion.md) §5.2). El clasificador decide cada nivel; autorización de actores y cambios semánticos de controles son T3.
6. **WP-011 — frontera de revisión verificable**: veredicto estructurado validado por schema y reactivación de `code-review.yml`. Regla Δ8: el revisor nunca comparte modelo ni contexto con el implementador.

**Criterio de salida:** métricas base de ADR-001 sobre ≥ 5 WPs reales (coste/WP, % a la primera, ciclos, **minutos humanos/WP**).

### Etapa 4 — Fase 2 real: la fábrica trabaja sobre el producto (≈ 4–8 semanas)

**Carril A:** instalar la FDA en **`AI-Comercial-System`** — programas **INV** (higiene: hoy versiona `.venv/`, `__pycache__/`, `logs/`; mapa de módulos; línea base de tests y de comportamiento ANTES de refactorizar — mitiga la advertencia brownfield de ACE-FCA), **CONTRACTS** (`AgentDefinition`, `AgentRun`+eventos, `ToolDefinition`, `ModelGateway`, `PolicyDecision`/`ApprovalRequest`; regla «breaking = DEC + migración») y **MIG** (envolver sin cambiar comportamiento; la línea base de INV lo verifica). **Carril B:** propuesta futura para Document AI; D5 no lo asigna ni autoriza. Solo una decisión humana posterior puede activarlo y fijar responsables, repositorio, retorno, accesos y gates.

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

## 6. La reforma del proceso — ADOPTADA en DEC-007; implementación pendiente

Niveles **decididos por script** (blast radius sobre rutas declaradas y diff; misma librería que `check_scope`), no por juicio por WP:

| Nivel | Superficie (la decide el clasificador) | Proceso |
|---|---|---|
| **T1 — ligero** | Documentación, datos de prueba y evidencia no ejecutable que no alteren controles, permisos, autorizaciones, contratos de seguridad ni el significado de una verificación | Contrato de 1 página; 1 pasada de code-reviewer; sin security-reviewer |
| **T2 — estándar** | Código de producto, `scripts/**`, specs, salvo criterio de T3 | Ciclo completo del manual |
| **T3 — sensible** | `.claude/**`, `.github/**`, permisos, secretos, migraciones, IaC, contratos de datos, `CODEOWNERS`; ejecutables/parches en `tests/**` o `evidence/**` que implementen o apliquen controles; cualquier cambio semántico de un control | Ciclo completo + security-reviewer + parche aplicado por persona |

**Suelo innegociable en TODOS los niveles** (v2; evidencia Veracode: ~45 % del código IA introduce vulnerabilidades, sin mejora entre ciclos): SAST/semgrep cuando aplique, escaneo de secretos, tests, lockfiles verificados. Los niveles modulan ceremonia y profundidad de revisión, **nunca** el suelo.
**Prevalencia:** T3 gana ante cualquier coincidencia múltiple. El clasificador mantiene una lista versionada y probada de rutas sensibles; modificar esa lista es T3.


Límites transversales: contrato ≤ 300 líneas (si necesita más, el troceado está mal); ≤ 1 de cada 3 WPs sobre la propia FDA tras la pausa; auditorías clasifican por severidad y solo lo bloqueante detiene; tercer ciclo dispara «¿pártelo?» antes que «¿reescríbelo?»; el revisor nunca comparte modelo ni contexto con el implementador (Δ8).

## 7. Métricas (v2: desde hoy, no desde la Etapa 3)

**Desde ya (coste cero):** ccusage por sesión; **minutos humanos por WP** (cronómetro manual); % WPs de producto vs meta. **Desde la Etapa 3 (WP-010):** coste/WP validado headless, % a la primera, ciclos medios, regresiones, resultado de simulacros. **Objetivo de calibración:** ≥ 75 % a la primera y ≤ 1 ciclo medio (M1 de ADR-001). **Desde la Etapa 5:** tasa de resolución autónoma, tasa de escalada humana, coste por resultado útil. Razón de fondo (P9): la percepción engaña; solo lo medido cuenta.

## 8. Riesgos principales y sus señales

| Riesgo | Señal de alarma | Respuesta |
|---|---|---|
| Recaer en la espiral de meta-trabajo | 2 WPs seguidos sobre la FDA, o un contrato > 300 líneas | Aplicar §6; punto de control extraordinario |
| El punto de control se convierte en re-deliberación | Se reabre D1–D6 sin un incumplimiento concreto | Mantener el resultado fechado de DEC-007 |
| **Divergencia de carriles** (v2) | Se activa una instalación B sin decisión, origen o retorno | Parar; D5 quedó sin acuerdo formal y exige otra decisión |
| **K3: datos y compatibilidad** (v2) | Código de clientes viajando al endpoint sin evaluación RGPD; roturas del harness | El gate E1 es prerrequisito; sin él, K3 no toca código real |
| El producto sigue parado | Etapa 4 sin empezar 8 semanas tras cerrar la pausa | Repriorización del operador: producto por delante |
| Prompt injection al reactivar `claude.yml` | Reactivación sin autorización de actores | Vetado: la autorización explícita es prerrequisito (Etapa 3.5) |
| Dependencia de un solo humano | Ausencia o indisponibilidad del operador | Registrar el riesgo; D5 no asigna otro responsable |
| **Pérdida de la candidata local de WP-008-r2** | Limpieza, reutilización o borrado del worktree antes de custodiarla | Custodia externa persistente con manifiesto previa a cualquier operación (Anexo A) |

## 9. Huecos de gobierno conocidos (transparencia)

1. **Las herramientas de escritura vía API no pasan por el guard local.** Los documentos de esta rama se materializaron por esa vía, por encargo directo del operador, sin tocar `main`. Cierre definitivo: el check de alcance en CI (Etapa 2.4) + sandbox (Etapa 2.5), que juzgan el resultado venga de donde venga. Hasta entonces, esta vía queda reservada a actos de operador explícitamente encargados.
2. **Plantilla y sandbox mezclados** en el mismo repo → guía de separación (Etapa 3.5); cualquier carril B futuro requiere antes otra decisión.
3. **`claude.yml` sin autorización explícita de actores** — desactivado hoy; prerrequisito antes de reactivar.
4. **Adaptaciones locales de otros runtimes** (`.agents/`, `.codex/`, `AGENTS.md`) sin versionar y fuera de gobierno (DEC-003 §8); cualquier uso como implementador exige su DEC propia — aplica también al endpoint K3 en el carril A.

---

## Anexo A — Antecedente de DEC-007 y ramas consideradas

Este anexo conserva las alternativas escritas antes del punto de control. El resultado efectivo está en DEC-007: D1, D2, D3, D4 y D6 ratificadas; D5 en su default. Solo la rama correspondiente a ese resultado es ejecutable.

### Ramas históricas de D6, redactadas antes de la decisión

Se conservan para explicar el default sin reabrir la deliberación. **La rama efectiva es D6-A; D6-B no está autorizada.**

- **D6-A — núcleo mínimo (resolución recomendada).** Una PR de operador posterior y de un solo archivo reduce el contrato a: parche humano de `settings.json` (comando canónico + ocho reglas), preflight estructural, suite determinista del preflight y criterios y evidencia proporcionales al alcance restante. La maquinaria roja/verde de captura de CI y el protocolo de doce escenarios se declaran superados. El contrato reducido nace con `max_ciclos_correccion: 2` y cuenta propia desde `0 / 2`, **presupuesto que concede la propia `DEC-007`**: la concesión de `DEC-006` §3 era la de R2 y **quedó agotada en `2 / 2`**, y esa misma decisión remitió el tercer ciclo a «otra decisión humana, nueva, fechada y versionada». `DEC-006` §3 y `DEC-005` §10 son **precedentes del mecanismo «contrato nuevo, cuenta propia»**, no la autorización actual. No se borran los ciclos 1 y 2 de R2 ni los once históricos de `DEC-005`, y un tercer ciclo del contrato reducido volvería a exigir otra decisión humana nueva, fechada y versionada.
- **D6-B — contrato íntegro (valor predeterminado).** Si D6 no se ratifica, `DEC-007` concede expresamente —también por autoridad propia— el **tercer y último ciclo** de corrección de WP-008-r2 para los seis hallazgos `WP008-F1`–`WP008-F6`, definidos íntegramente en su § Registro cerrado de hallazgos de WP-008: la contabilidad pasa de `2 / 2` a `2 / 3` al fusionarse y a `3 / 3` con una autorización humana posterior; no existe cuarto ciclo implícito; cualquier cambio de código o pruebas obliga a repetir la batería A completa desde el comando 01 y a reconstruir su índice conservando la historia; el cierre exige QA, code review y security review en tres tareas realmente separadas (Δ8).

D6-B permanece únicamente como explicación histórica del default; no concede un tercer ciclo a R2 bajo la resolución efectiva.

### Tratamiento de la candidata local de WP-008-r2

Con la foto corregida de §1, la candidata local **existe** y su tratamiento forma parte de la decisión, no de una limpieza informal:

1. antes de cualquier limpieza, reutilización o modificación, una **operación humana separada** crea una **custodia externa persistente** con manifiesto de rutas, tipos, modos y SHA-256;
2. la persona fija por escrito, antes de autorizarla, el destino persistente —**nunca `/private/tmp`**—, el soporte y su durabilidad, el modo y la propiedad del árbol, el formato verificable del manifiesto y el periodo de retención;
3. la custodia y cada artefacto peligroso se marcan **CANDIDATA HISTÓRICA NO CONFORME — NO EJECUTAR**, nombrando `WP008-F1`, `WP008-F2`, `WP008-F4` o `WP008-F5` cuando corresponda —los identificadores de `DEC-007`, que no deben confundirse con los hallazgos de investigación H1–H12 de [05](05-analisis-investigacion-leandro-y-revalidacion.md) §3—;
4. ese código no se fusiona como entregable ni se reutiliza como guía operativa;
5. `DEC-007` **exige** estos datos; no autoriza por sí misma copiar, mover ni borrar nada.

## Anexo B — Glosario mínimo (para lectura no técnica)

- **FDA**: la «fábrica» — reglas, contratos y agentes con los que la IA desarrolla software de forma controlada.
- **Agent OS**: el producto futuro — la plataforma que ejecutará agentes de negocio con permisos, aprobaciones y auditoría.
- **WP (work package)**: un encargo pequeño con contrato: qué se hace, qué archivos se pueden tocar, cómo se verifica.
- **Guard / hook**: el programa que avisa y deniega en el momento las escrituras fuera del contrato que reconoce. **Feedback rápido, no garantía**: falla abierto si no es ejecutable o no llega a invocarse, y no cubre todos los vectores de shell.
- **Sandbox**: jaula a nivel de sistema operativo — el agente físicamente no podría escribir fuera de su carpeta ni salir a internet salvo a dominios permitidos. **Todavía no está instalado**: es un gate futuro (experimento E2), y hasta que se instale y se mida no aporta ninguna protección real.
- **Check de alcance en CI** (`check_scope`): la comprobación en GitHub que revisará el resultado final (el diff) contra el contrato. **Se ejecutaría en CI**, y **solo sería bloqueante para la fusión una vez incorporado como *required status check* del ruleset**. Es el **juez final previsto** y **todavía no existe**, como tampoco esa incorporación: lo construyen WP-002 y después WP-005.
- **Blast radius**: «radio de impacto» de un cambio; un script lo calcula y decide cuánta ceremonia y revisión necesita.
- **Upstream / downstream (carriles A/B)**: la plantilla canónica y sus instalaciones; las mejoras probadas abajo vuelven arriba.
- **Pausa (DEC-003)**: freno de emergencia del 03-08; se sale cumpliendo condiciones medibles.
- **PR de operador**: cambio del andamiaje aprobado por ti; distinto de una PR de implementación.
- **Meta-trabajo**: trabajo de la fábrica sobre sí misma, en vez de sobre el producto.
- **Candidata histórica no conforme**: trabajo real que no se fusiona ni se ejecuta; se conserva con manifiesto y advertencia para no perder trazabilidad.
