# Análisis de las cinco conversaciones con IAs — síntesis y veredictos

> **Nota (2026-09-01):** el 01-09 se realizó una segunda revisión con material nuevo (investigación de Leandro + línea base independiente). Los veredictos de este documento **se mantienen**; los ajustes y ampliaciones están en [`05-analisis-investigacion-leandro-y-revalidacion.md`](05-analisis-investigacion-leandro-y-revalidacion.md).

**Fecha:** 2026-08-30 · **Complemento de:** [`03-hoja-de-ruta.md`](03-hoja-de-ruta.md) · **Método:** cada conversación se leyó completa; sus propuestas se contrastaron con el estado real del repositorio y con fuentes externas fiables. Cada tema termina en un veredicto: **acepto**, **acepto con matices** o **rebato**, siempre con el porqué. Donde una conversación ya corrigió a otra, se señala.

## Las cinco conversaciones, en una línea cada una

| # | Conversación (archivo del operador) | Tesis central |
|---|---|---|
| C1 | *AI Agent OS — Full Conversation* | Arquitectura de un agent platform serio (planos de control/ejecución, workflows durables, tool gateway, políticas, evals, observabilidad); tres capas FDA / Agent OS / agentes de dominio; monolito modular primero |
| C2 | *Conversación completa sobre fda-template* (auditoría + escalado) | Auditoría honesta (≈6,8/10 actual, 8–9 potencial) con hallazgos concretos; luego, catálogo de ~40 agentes especializados y orquestador para escalar |
| C3 | *FDA, AI Comercial y arquitectura multisector* | Agencia = plataforma común + packs verticales + configuración por cliente; arquitectura de datos de nivel empresa (PostgreSQL+RLS, RAG como índice derivado, outbox, warehouse, constitución de datos) |
| C4 | *fda-template y automatización total* | Añadir a la FDA un plano de operaciones: observabilidad universal, detectores deterministas, diagnóstico y remediación por runbooks, escala de autonomía A0–A5, SLOs de agentes |
| C5 | *FDA, Agent OS y compañía agéntica* | Construir la FDA es lo difícil; los agentes después son configuración. Organigrama de una compañía agéntica (~120–200 capacidades). **Aviso clave: riesgo de sobre-gobernanza; WP-008 ya era demasiado grande** |

## Veredictos por tema

### T1 — Tres capas: FDA construye, el Agent OS ejecuta, los agentes de negocio operan → **ACEPTO**

Las cinco conversaciones convergen y el análisis del repo lo confirma: `fda-template` es un plano de control del *desarrollo*, no el runtime del producto. Mezclar ambos crearía una clase universal de «agente» que no sirve bien a ninguno (C1 y C5 lo advierten expresamente). La hoja de ruta lo consagra como principio P7.

### T2 — «Empieza simple: monolito modular, contratos antes que infraestructura» → **ACEPTO**

C1 y C3 lo recomiendan; [Anthropic](https://www.anthropic.com/engineering/building-effective-agents) lo formula como regla general (la solución más simple que funcione; complejidad solo si mejora resultados medidos); y la propia guía fundacional del repo lista como anti-patrón construir orquestación antes de agotar lo existente. Consecuencia práctica: Etapas 4–5 de la hoja de ruta extraen el Agent OS de `AI-Comercial-System` en vez de diseñarlo en abstracto.

### T3 — Catálogo de ~40 agentes (C2) y organigrama de ~200 capacidades (C5) → **REBATO como siguiente paso; acepto como mapa lejano**

Por qué lo rebato ahora: (1) el coste real del multi-agente es enorme — la experiencia publicada por Anthropic con su sistema de investigación multi-agente: ~15× los tokens de un chat, y solo compensa en tareas genuinamente paralelizables; (2) C2 se contradice a sí misma en su cierre («no midas el progreso por el número de agentes instalados») y C5 lo resuelve bien: **composición** (rol × especialidad × skills × políticas), no proliferación; (3) el cuello de botella demostrado de esta fábrica no es falta de agentes: es que los cinco que hay apenas han podido trabajar. Añadir 40 agentes a un proceso atascado multiplica el atasco, no la producción. Qué acepto: la taxonomía como **mapa de largo plazo** (Etapa 6) y dos incorporaciones tempranas concretas cuando la Etapa 4 las pida (cartógrafo de repositorio y diseñador de pruebas, los dos de mayor valor/coste de C2).

### T4 — «Más contrato, más custodia, más verificación = más robustez» (patrón implícito en las auditorías que llevaron a WP-008) → **REBATO**

Es el punto donde esta hoja de ruta corrige el rumbo con más firmeza, y no por opinión: (1) [DORA](https://dora.dev/capabilities/streamlining-change-approval/) — los procesos de aprobación pesados no reducen la tasa de fallo y multiplican por 2,6 la probabilidad de bajo rendimiento; lo eficaz es revisión entre pares + automatización; (2) el experimento natural del propio repo: 11 ciclos + 10 replanificaciones + 1 intento abandonado sobre WP-008, con contratos de 1.800+ líneas y custodias con manifiestos SHA-256 para copias de carpetas — y el control concluyente (check de alcance en CI) sigue sin existir; (3) C5 lo había avisado textualmente («el principal riesgo que veo en tu FDA es sobre-gobernanza… muchas reglas deberían pasar de Markdown interpretado a schemas y enforcement determinista»). La respuesta no es quitar controles: es **proporcionarlos al riesgo** (reforma §6 de la hoja de ruta) y convertir prosa en código (verificaciones deterministas pequeñas, no contratos enciclopédicos).

### T5 — «El RAG como cerebro para gastar cada vez menos tokens» (idea inicial del operador) → **MATIZO (como ya hizo C3)**

C3 lo corrigió bien y lo suscribo: el RAG no sustituye al modelo — selecciona qué poco contexto enviarle; los datos estructurados (precios, citas, estados) van en PostgreSQL y se consultan con herramientas, no se «recuerdan» en vectores; el ahorro real viene, por orden, de: no llamar al modelo cuando basta código, recuperar solo cuando hace falta, contexto mínimo, resúmenes, caché de prompts y enrutado de modelos por tarea. El RAG es un **índice derivado y reconstruible**, nunca la fuente de verdad. Todo esto queda incorporado a la Etapa 5.

### T6 — «Hazlo multi-motor ya (runners OpenAI/Gemini)» → **REBATO ahora; acepto el diseño portable**

C3 ya lo aclaró: el gobierno de la FDA es portable (contratos, decisiones, evidencias), el runtime actual es deliberadamente Claude Code (ADR-001, decisión correcta: comparte motor con el Agent SDK, así el runner futuro hereda el gobierno sin retrabajo). Construir adaptadores multi-proveedor hoy sería infraestructura sin necesidad demostrable — el mismo anti-patrón de T2. Lo que sí: los contratos de la Etapa 4 (AgentDefinition, ToolDefinition, ModelGateway) se escriben neutrales al proveedor, que es lo que hace posible el adaptador el día que haga falta. Para el producto (`AI-Comercial-System`) la abstracción de proveedor ya existe parcialmente y se conserva.

### T7 — Plano de operaciones: observabilidad, detectores, runbooks, autonomía A0–A5, SLOs de agentes (C4) → **ACEPTO como Etapa 6, no como presente**

La visión de C4 es la mejor descripción disponible del destino («100 % de observabilidad y trazabilidad; automatizar las decisiones reversibles; al humano solo las excepciones») y sus piezas son sensatas: detectores deterministas antes que juicio de LLM, remediación solo por runbooks cerrados, autonomía por acción y no por agente, contratos de salida validados por schema (esto último entra antes: es el WP-011 de la Etapa 3, porque el falso verde ya ocurrió aquí). Pero exige un producto en producción que hoy no existe. Secuencia correcta: producto primero (Etapas 4–5), operaciones después (Etapa 6).

### T8 — La prueba empírica del runtime (WP-012) → **mi análisis, decisión del operador el 07-09**

C4 y C5 empujan (con razón) a no fiarse de que un job verde signifique trabajo hecho. Pero la materialización elegida —un runner de 14 sondas que demuestre que Claude Code aplica su configuración— prueba el producto del proveedor, no el gobierno propio, y lleva 11 ciclos sin una medición válida. Mi recomendación (D1 de la hoja de ruta): sustituirlo por una prueba de humo manual documentada + el check de alcance en CI, que atrapa el resultado final haga lo que haga el hook. El operador decidió el 2026-08-30 resolverlo en el punto de control del 07-09; ambas ramas están preparadas en el Anexo A.

### T9 — Arquitectura de datos «nivel multinacional» (C3: tenancy+RLS, outbox, warehouse, clasificación, retención, DATA-001…015) → **ACEPTO para la fase de plataforma**

Es la mejor pieza técnica de las cinco conversaciones y se adopta casi íntegra… en su momento (Etapa 5), guiada por sus propias reglas de oro: cada dato con una única fuente de verdad; el aislamiento por tenant en la base de datos (RLS), no en la disciplina del programador; eventos con outbox transaccional; analítica separada de operación; nada de `if cliente == X` en el núcleo; y RGPD como restricción de diseño (minimización y retención definidas, no «guardarlo todo para siempre»). Adoptarla hoy, con el producto parado, sería construir catedral sin feligreses.

### T10 — «Compañía operada por 1–3 humanos» → **REBATO la cifra; acepto la dirección**

C5 da la corrección honesta: 1–3 humanos es un punto único de fallo humano y hoy tendría ~15–30 % de probabilidad; el objetivo profesional es **máximo trabajo autónomo fiable por humano**, con 8–12 personas para una gran compañía (capital, arquitectura, seguridad, evals, producto, finanzas, aseguramiento independiente). También adopto su regla de puntuación: la nota global del sistema es el **mínimo** de sus dimensiones (seguridad 6 ⇒ sistema 6), no la media — por eso la hoja de ruta usa gates, no promedios.

### T11 — Los hallazgos de auditoría de C2 (julio) → **ACEPTO los 4 aún vigentes**

De su lista: el check de alcance post-hoc (→ Etapa 2.4), acciones por SHA (→ WP-009), autorización de actores en `claude.yml` (→ Etapa 3, prerrequisito de reactivación), README/LICENSE/separación plantilla-sandbox (→ Etapa 3). El resto (reposo válido, revisión rota) ya se resolvió o quedó contenido por DEC-003.

## Lo que ninguna conversación vio (aportación propia de este análisis)

1. **El experimento natural ya ocurrió.** Las conversaciones razonan sobre riesgos futuros; el repositorio ya contiene 5 semanas de datos reales sobre qué pasa cuando toda ceremonia es máxima. Ese dato pesa más que cualquier opinión — incluida la mía.
2. **La calibración era la vacuna y no se administró.** Los 5 WPs de Fase 1 existían precisamente para medir el coste del proceso antes de perfeccionarlo. Recuperarlos (Etapa 3) es más urgente que cualquier agente nuevo.
3. **La vía de escritura por API queda fuera del guard local** — declarada y con su cierre definido (hoja de ruta §9.1): el juez final es el diff en CI, no el hook.

## Fuentes externas citadas

- Anthropic — [Building effective agents](https://www.anthropic.com/engineering/building-effective-agents) · [Claude Code best practices](https://code.claude.com/docs/en/best-practices)
- DORA — [Streamlining change approval](https://dora.dev/capabilities/streamlining-change-approval/)
- OWASP GenAI — [Agentic AI: Threats and Mitigations](https://genai.owasp.org/resource/agentic-ai-threats-and-mitigations/)
- GitHub — [Spec Kit (spec-driven development)](https://github.com/github/spec-kit)
