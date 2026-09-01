# 05 — Segunda revisión (2026-09-01): investigación de Leandro, línea base independiente y revalidación de la hoja de ruta

**Fecha:** 2026-09-01 · **Tipo:** documento de evidencia y razonamiento (foto fija; no se mantiene al día — la fuente de verdad viva es [`03-hoja-de-ruta.md`](03-hoja-de-ruta.md)) · **Encargo:** segunda revisión estratégica, técnica y arquitectónica solicitada por el operador el 2026-09-01.

**Método y anti-anclaje.** Para evitar el sesgo de anclaje señalado por el operador, la investigación externa independiente se realizó y se registró con fecha **antes** de leer los documentos de Leandro (nota de trabajo del 01-09, 08:40 UTC; su síntesis es el §3). Después se leyeron íntegros los 4 documentos, se verificaron sus afirmaciones externas más decisivas contra fuentes primarias, y solo entonces se emitieron veredictos. Jerarquía de evidencia aplicada: comportamiento observado del propio sistema → decisiones vinculantes → evidencia empírica externa → documentación oficial → experiencias comparables → razonamiento → opiniones de IAs → intuición. Marcado: **[HECHO]** comprobado directamente · **[INFERENCIA]** conclusión razonada · **[RECOMENDACIÓN]** · **[HIPÓTESIS]** requiere experimento.

---

## 1. Estado real del repositorio a 2026-09-01 [HECHO, verificado hoy]

- `origin/main` = `41d7ffc` — **sin un solo commit desde el 2026-08-29**. Sin PRs abiertas.
- `ACTIVE` → WP-008; la rama `wp/WP-008-runtime-fail-closed-r2` que exige DEC-006 (paso 4) **no existe**: la implementación del reintento **no ha empezado**. Esto cambia un supuesto del análisis del 30-08 («última milla en curso»): hoy no hay ninguna implementación hundida, solo el contrato.
- La rama abandonada `wp/WP-008-runtime-fail-closed` se conserva en `f745b5d` como ordena DEC-006. Quedan 22 ramas `ops/*` fusionadas sin borrar (higiene menor).
- La hoja de ruta del 30-08 sigue en la rama de sesión, sin fusionar. Punto de control **2026-09-07** vigente.
- Demás repositorios: sin cambios (AI-Comercial-System y satélites parados desde feb-2026).

## 2. Qué contienen los cuatro documentos de Leandro (resumen fiel)

1. **«Aprendizajes externos sobre desarrollo agéntico»** — síntesis de dos fuentes de experiencia real: *540* (Gorka Moreno, CTO, 6 meses build-in-public, equipo ~32 devs) y *HumanLayer/ACE-FCA* (Dex Horthy). Aporta: harness > modelo; flujo Research→Plan→Implement y su **mea culpa** (RPI→CRISPY: el 10× no existió, 2–3× sostenible leyendo código; el apalancamiento humano va **antes** del plan); guardarraíles deterministas («lo determinista, determinista», arquitectura como linters, clasificación de PRs por *blast radius* con script); revisor que **nunca** comparte modelo/contexto con el implementador; `CLAUDE.md` mínimo (el autogenerado es peor que nada); hooks casi ausentes salvo la intercepción determinista de permisos (exactamente lo que hace nuestro guard); 11 errores documentados que no repetir.
2. **«Feedback IA sobre el repo FDA…»** — 12 deltas (Δ1–Δ12) propuestos por una IA al plan de Leandro: métricas desde el día 0 (ccusage), re-auditoría del harness en cada salto de modelo, `gotchas.md`, anti-error-masking (semgrep), output mínimo en verificaciones, blast radius determinista, parada dura de coste, independencia de modelo del revisor como regla dura, «prueba de salida» trimestral en vez de construir portabilidad, cautela con hooks nuevos, fase de preguntas antes del WP, `progress.md` de traspaso multi-sesión. Más una lista de **qué no construir**.
3. **«Investigación web ago-2025→ago-2026»** — revisión seria del estado del arte: canon de Anthropic Engineering (context engineering, harnesses de larga duración, planner/generator/evaluator, «las asunciones del harness caducan»), Böckeler/Thoughtworks, Osmani, Ralph loop, 12-factor agents, el debate SDD (overhead ~4:1; Thoughtworks lo pone en *Assess*), METR completo (con su corrección de 2026), GitClear (duplicación +81 %, error masking +47 %), y 8 patrones transversales en los que todas las fuentes convergen.
4. **`FDAdiagrama.drawio` («Plan Maestro v2»)** — el hallazgo estratégico: no es una propuesta de cambios a este repo, sino el plan de una **segunda instancia de la FDA**: clonar `fda-template`, borrar la historia (`rm -rf .git`), repo privado propio, **Kimi K3 como implementer** vía endpoint compatible (con go/no-go en su Fase 2 y regla Δ8), numeración de WPs propia (WP-001…009 ≠ los nuestros), decisiones propias (su «DEC-003 origen», «ADR-002 modelos») y proyecto de calibración propio: **«Document AI»** (monorepo gateway·converter·ocr·llm-extractor·validation), con lista anti-backlog vinculante.

**Referencias no disponibles [HECHO]:** los documentos citan `PLAN-MAESTRO-FDA.md` (el texto completo del plan, con sus bloques A–E) y un PDF de 540 sobre organización de proyectos que el propio Leandro marca como corrupto. **Esta revisión evalúa lo entregado**; el diagrama + los deltas permiten reconstruir el plan con confianza razonable, pero si `PLAN-MAESTRO-FDA.md` está disponible conviene adjuntarlo: podría matizar los veredictos 4.1–4.3.

## 3. Línea base independiente (fijada antes de leer los documentos)

Resumen de la nota registrada el 01-09 a las 08:40 UTC; fuentes al pie del documento.

- **H1 [HECHO]** Los tres sistemas comparables reales (GitHub Copilot coding agent, OpenAI Codex, Claude Code) aplican el aislamiento en la frontera **SO + red**, deny-by-default (sandbox de kernel, firewall de egreso con allowlist, push restringido por plataforma). Ninguno confía en parsear comandos de shell. **H2 [INFERENCIA]** Nuestro `guard.sh` pertenece a una clase superada: se conserva como feedback rápido, pero la frontera correcta es sandbox + diff en CI + protección de rama.
- **H3 [HECHO]** METR 2026: horizonte de fiabilidad 50 % ≈ 2h17m de tarea humana; se duplica cada ~7 meses → WPs pequeños validados; autonomía por gates de evidencia.
- **H4 [HECHO]** Veracode 2025-26: ~45 % del código IA introduce vulnerabilidades OWASP, sin mejora entre ciclos → el suelo automático de seguridad es **uniforme** en todos los niveles de ceremonia.
- **H5 [HECHO]** *Slopsquatting* (paquetes alucinados registrados por atacantes) es un vector real → lockfiles con hashes + gate para dependencias nuevas de agentes.
- **H6 [HECHO]** DORA 2025 (IA): los amplificadores son lotes pequeños, control de versiones fuerte, política clara, plataforma interna — lo que la FDA ya es; el cuello de botella al paralelizar es **la revisión humana**.
- **H7 [HECHO]** Claude Code ya trae orquestación nativa (subagentes con worktree, Agent Teams) → reevaluar los disparadores del harness SDK de ADR-001.
- **H8–H10 [HECHO]** Context engineering (contratos cortos benefician también al modelo); ejecución durable (Temporal/DBOS/Restate) para la fase Agent OS; NIST AI RMF/ISO 42001 avalan la gobernanza proporcional al riesgo.
- **H11 [INFERENCIA]** La esencia legítima de WP-012 («verifica que tus controles disparan») tiene versión proporcional: canario de 1 sonda + garantía trasladada al kernel y al diff.
- **H12 [RECOMENDACIÓN]** Candidatas propias: sandbox nativo para el implementer; política anti-slopsquatting; simulacro periódico con defecto sembrado; merge queue al concurrir WPs; medir minutos humanos por resultado desde ya.

**Convergencia notable [HECHO]:** sin haberse leído mutuamente, la línea base y los documentos de Leandro coinciden en ≥ 8 puntos (deterministas, revisor independiente, estado en archivos, métricas tempranas, WPs cortos, cautela con hooks, anti-backlog, done verificable). Donde coinciden fuentes independientes con evidencia distinta, la confianza sube. Donde solo hay opinión repetida, no (§6).

## 4. Veredictos sobre las aportaciones de Leandro

### 4.1 La segunda instancia («clonar y borrar historia») → **ADOPTAR CON MODIFICACIONES: convertir el conflicto en diseño (upstream/downstream)**

**Problema que resuelve:** iterar rápido sin cargar con la pausa y la historia de gobierno de este repo; privacidad; libertad de numeración. **¿Es real?** [HECHO] Sí: 27 PRs de meta-trabajo y una pausa de 4 semanas están documentadas aquí. **¿Ya cubierto?** Parcialmente — y esto es lo decisivo: **la guía fundacional (§2) define `fda-template` como plantilla que se INSTALA en proyectos**. Una instancia nueva no es una traición al proyecto: es **la primera instalación real**, el mejor test que puede tener una plantilla. Lo que NO existe hoy es el canal de retorno (el capítulo «actualizar la plantilla en proyectos instalados» ya figuraba como ausente en el diagnóstico de julio, §6). **Riesgos del plan tal cual:** divergencia permanente (dos gobiernos que dejan de parecerse), pérdida de trazabilidad del origen, y re-descubrir defectos ya corregidos aquí. **Modificaciones que lo arreglan:** (1) la instancia registra en un archivo `INSTALL.md` el commit exacto de la plantilla del que parte; (2) `fda-template` sigue siendo el **upstream** canónico del gobierno (conserva historia y decisiones); (3) las mejoras probadas en la instancia (Δ3–Δ7, guard.py…) **vuelven como PRs al upstream**; (4) la numeración de WPs/DECs es local de cada repo (sin conflicto al ser repos distintos); (5) K3 y Document AI viven en la instancia hasta pasar sus gates. **Fase:** decisión D5 del punto de control 07-09. **Por qué:** convierte «dos planes rivales» en **dos carriles del mismo sistema** — carril A (upstream + Agent OS/AI-Comercial, ámbito de Iván) y carril B (instancia + Document AI, ámbito de Leandro) — sin perder ni la velocidad que Leandro busca ni el activo de gobierno acumulado aquí.

### 4.2 Kimi K3 como implementer → **DEJAR COMO EXPERIMENTO GATEADO EN EL CARRIL B; NO adoptar como default del upstream**

**Problema:** coste (los revisores premium + implementación barata). Real [HECHO]: la economía del token importa (540: los planes subvencionan 4–13× el uso API). **Viabilidad [HECHO, verificado]:** Claude Code puede apuntar al endpoint Anthropic-compatible de Moonshot con 3 variables de entorno. **Riesgos verificados:** (a) *compatible ≠ idéntico* — funciones que se rompen (tool search, WebFetch, imágenes); (b) **los datos del código viajan a infraestructura del proveedor fuera de la UE** → para código de clientes es una cuestión RGPD que hay que evaluar antes, no después; (c) el harness de Claude Code está afinado para modelos Claude — el propio doc de Leandro documenta ese acoplamiento (sesgo a grep por harness+post-training); las asunciones del harness con otro modelo son exactamente la clase de cosa que «caduca» (Δ2); (d) acoplarse a una capa de compatibilidad de terceros es primo del error 10 de su propia lista (APIs no públicas). **Lo que el plan de Leandro ya hace bien:** el go/no-go de su Fase 2 y la regla Δ8 (revisores SIEMPRE de otro modelo). **Modificaciones:** el experimento debe (1) comparar K3 contra una línea base Claude (mismos WPs, métricas de §8-E1) y no solo «funcionar»; (2) resolver la pregunta RGPD por escrito; (3) fijar versión de CC y del endpoint; (4) mantenerse fuera del carril A hasta pasar el gate. **Por qué no default upstream:** el objetivo de coste se logra en gran parte con tiering dentro de la familia soportada (implementer en modelo estándar, revisores premium — política que la guía §6 ya fija) sin asumir riesgos (a)-(d).

### 4.3 Document AI como proyecto de calibración → **ADOPTAR EN EL CARRIL B; el carril A mantiene AI-Comercial-System**

**A favor [HECHO externo]:** la evidencia ACE-FCA es explícita: las herramientas agénticas rinden mucho mejor en greenfield que en brownfield — para *calibrar la fábrica*, un proyecto nuevo y verificable (pipeline documental) da señal más limpia que migrar un sistema legado. **A favor del statu quo:** el objetivo declarado del operador (Agent OS) pasa por AI-Comercial-System, y la Etapa 4 ya mitiga el riesgo brownfield con el programa INV (caracterización antes de tocar). **Veredicto:** no es o/o — con dos carriles, cada uno calibra con su proyecto y los aprendizajes se cruzan por el upstream. **Decisión de negocio para el operador (D5):** prioridad comercial entre Document AI y AI-Comercial/Agent OS, y dónde vive el repo de la instancia. Nota técnica: el extractor documental de Document AI y la knowledge-base del AI-Comercial se solapan — conviene vigilar la convergencia para no construirlo dos veces.

### 4.4 Blast radius determinista (Δ6) → **ADOPTAR, fusionado con la reforma T1/T2/T3**

La reforma del 30-08 definía niveles por tabla; el patrón de 540/Leandro los hace **ejecutables**: un script decide el nivel a partir de las rutas declaradas y del diff (toca `.claude/**`, `.github/**`, migraciones, contratos, IaC → T3; solo docs/tests → T1; resto → T2), y el mismo criterio fija la profundidad de revisión. Un criterio, dos usos, cero duplicación, y elimina la discusión humana por WP. Se integra en el borrador de DEC-007 (D2) y, en implementación, en la misma librería de matching de 4.5. **[HECHO externo de refuerzo:** Veracode — el suelo de seguridad automatizado no se rebaja en ningún nivel; los niveles modulan ceremonia y revisión, nunca SAST/secretos/tests.]

### 4.5 `guard.py` portable + librería única de matching (su WP-002/C2) → **ADOPTAR CON MODIFICACIONES (secuenciación)**

**Problema real [HECHO propio]:** la divergencia de semántica entre `guard.sh` y lo documentado ya nos costó DEC-002, el bloqueo de WP-002 y el WP-007 — mantener DOS implementaciones de la misma semántica (bash y python) en paridad eterna es un generador estructural de ese tipo de fallo. **La propuesta correcta:** una sola librería Python de matching, usada por el check del diff en CI **y** por el hook (guard delgado que la invoca), con suite pytest única. **Cuidados:** (1) tocar `.claude/hooks/**` es carril T3 con parche aplicado por persona; (2) DEC-003 §7 prohíbe tocar `tests/guard/run-suite.sh` durante la pausa — por tanto esto se decide en el punto de control (cabe en DEC-007) y se ejecuta en el cierre de la pausa, no antes; (3) el candidato congelado de WP-007 se preserva como evidencia histórica se gún DEC-003 §1. **Opciones honestas:** (a) mantener secuencia vigente (parche bash de WP-007 → check_scope aparte) — menor coste de decisión, deuda de paridad permanente; (b) **[RECOMENDACIÓN]** en DEC-007: librería + check_scope primero, guard delgado sobre la librería después (parche humano), WP-007 se cierra como superado — una decisión más ahora, mantenimiento menor para siempre. Solo si va **empaquetado en el único punto de control** (evitar el patrón replanificador).

### 4.6 El paquete de deltas Δ y demás propuestas — matriz

| # | Propuesta | ¿Problema real aquí? | ¿Cubierto hoy? | Veredicto | Fase/carril |
|---|---|---|---|---|---|
| Δ1 | ccusage + rollup de métricas desde día 0 | Sí [HECHO]: coste por F3 manual; sin telemetría | No (WP-010 reservado, sin contrato) | **ADOPTAR** (hábito ya; WP-010 lo formaliza) | Ya + Etapa 3, ambos carriles |
| Δ2 | Re-auditoría del harness por salto de modelo | Sí [HECHO externo: managed-agents] | No | **ADOPTAR** (ítem fijo de retro en manual 06) | Etapa 3 |
| Δ3 | `gotchas.md` podado (≤30 líneas) | Sí: los aprendizajes viven en DECs largos | Parcial (evidence/postmortems) | **ADOPTAR** (con la cautela AGENTS.md: mínimo, a mano, medido) | Etapa 3 |
| Δ4 | Semgrep anti-error-masking | Sí [HECHO externo: GitClear +47 %] | No | **ADOPTAR** cuando haya código Python/producto en CI | Etapa 2-3 |
| Δ5 | Verificación con output mínimo (detalle a log) | Sí (context rot) | Parcial (evidence ya loguea) | **ADOPTAR** (línea en `_TEMPLATE` + manual) | Etapa 3 |
| Δ6 | Blast radius por script | Sí | No (reforma era por tabla) | **ADOPTAR** (→ §4.4) | DEC-007 (D2) |
| Δ7 | Parada dura de coste ejecutable | Sí [HECHO externo: jams/Ralph] | Parcial (presupuesto declarativo) | **ADOPTAR** dentro de WP-010 (v1 en run-verification; sin hook nuevo) | Etapa 3 |
| Δ8 | Revisor de modelo distinto, regla dura | Sí [HECHO externo: unánime] | Parcial (agentes/contexto separados; modelos por política) | **ADOPTAR** (premium≠implementer ya cumple; obligatorio si K3 implementa; 2º revisor de otro proveedor: DEJAR a Etapa 3+) | DEC-007 nota |
| Δ9 | «Prueba de salida» trimestral (portabilidad) | Sí (lock-in no medido) | No | **ADOPTAR** (experimento E3, §8) | Trimestral desde Etapa 3 |
| Δ10 | No añadir hooks post-edit | — (preventivo) | Sí (solo guard PreToolUse) | **YA CUBIERTO** — y refuerza no invertir más en parsing (→ sandbox §5.1) | — |
| Δ11 | Fase de preguntas concretas antes del WP | Sí [HECHO externo: CRISPY] | Parcial (planner valida DoR, no pregunta antes) | **ADOPTAR** (sección en manual 03) | Etapa 3 |
| Δ12 | `progress.md` de traspaso multi-sesión | Sí [HECHO externo: Anthropic long-running] | Parcial (repo-como-estado, sin traspaso por WP) | **ADOPTAR** (opcional por WP en `evidence/WP-XXX/`) | Etapa 3 |
| L17 | Deny IaC/datos + agente infra-engineer | Futuro (sin IaC aún) | No | Deny: **ADOPTAR** al existir esas rutas · agente: **DEJAR** (anti-backlog) | Etapa 4+ |
| L18 | `specs/contracts/` de datos, 1ª clase | Sí para producto | Previsto (Etapa 4 CONTRACTS) | **YA CUBIERTO**, adoptando su regla «breaking = DEC + migración» | Etapa 4 |
| L19 | Lista anti-backlog vinculante | Sí | Parcial («qué NO hacer» por etapa) | **ADOPTAR** (fusionada en 03 §5) | Ya |
| L21 | RTK (filtrado de output) | Aún no (poco volumen) | Δ5 cubre lo esencial | **DEJAR** (radar; medir si duele) | — |
| — | Su Fase 2 «prueba en seco» adversarial | Sí | Parcial (WP-003/004 son 2 de las 5 sondas) | **ADOPTAR** fusionada con el simulacro §5.4 | Etapa 3 |
| — | Ralph loop / ejecución en bucle | Futuro | ADR-001 lo regula (harness) | **DEJAR** (cuando haya cola de WPs; con parada dura Δ7 como prerrequisito) | Etapa 6 |
| — | Spec Kit / OpenSpec como capa | — | El WP ya es la spec proporcional | **RECHAZAR como capa adicional** (overhead ~4:1; Thoughtworks *Assess*) — coincide con su propio anti-backlog | — |

## 5. Nuevos hallazgos de esta revisión (aportaciones que no proceden de los documentos entregados)

1. **Sandbox nativo de Claude Code para el implementer [RECOMENDACIÓN, evidencia H1].** Bash sandboxeado con bloqueo de escritura a nivel de kernel fuera del área de trabajo y egreso de red por allowlist. Es la respuesta estructural a la carrera armamentística del guard (los 11 ciclos de WP-008 fueron síntoma de pelear en la capa equivocada) y converge con cómo operan Copilot y Codex. El guard queda como feedback de contrato por WP; el sandbox aporta la garantía dura. Entra como WP T3 en el cierre de la pausa (tocar settings es parche humano). Además reduce el valor marginal restante de WP-012 aún más: la garantía pasa a ser del kernel, no del comportamiento del hook.
2. **Política anti-slopsquatting [RECOMENDACIÓN, evidencia H5].** Nadie (ni las 5 conversaciones ni los 4 documentos) cubre el vector de dependencias alucinadas: lockfiles con hashes verificados en CI, dependencias nuevas de agentes solo vía gate (existencia, edad, mantenedor), regla en la constitución de instalaciones con código de producto. Barato y con ataques reales documentados.
3. **El contrato upstream/downstream (§4.1)** como mecanismo — la reformulación del fork como «primera instalación + canal de retorno» no aparece en ningún documento previo y disuelve el conflicto estratégico sin perdedor.
4. **Simulacro con defecto sembrado [RECOMENDACIÓN].** Extensión del «fire drill» a todo el canal: además de las sondas de alcance/presupuesto (Fase 2 de Leandro, WP-003/004 nuestros), una PR con defecto plantado debe ser cazada por la cadena de revisión; si pasa, el hallazgo es del canal, no del código. Trimestral, barato.
5. **Merge queue de GitHub** cuando haya WPs concurrentes (evita el baile de rebases entre agentes); y **minutos humanos por resultado** como métrica desde ya (H6: la revisión será el cuello de botella).
6. **Sin más añadidos.** Se evaluó y descartó proponer: orquestador propio (lo nativo llega antes), OPA/policy-engine formal (sobredimensionado hoy), SLSA completo (WP-009 basta ahora). No he encontrado ninguna otra incorporación cuyo beneficio justifique su coste hoy.

## 6. Red team de la estrategia actual (incluida mi propia recomendación del 30-08)

- **RT1 — WP-008-r2 [CORRECCIÓN PROPIA].** El 30-08 recomendé «terminarlo tal cual» por ser «última milla pagada». Hecho nuevo: **no se ha empezado** — no hay implementación hundida, solo contrato. Evidencia nueva: el sandbox de kernel da una garantía superior a la que el protocolo rojo/verde del contrato pretende demostrar. Recomendación corregida (decisión D6 del operador): **núcleo mínimo** — parche de settings (comando canónico + 8 reglas) + preflight + su suite, **sin** la maquinaria de captura de CI rojo/verde (el bloqueo del preflight lo demuestra su propia suite y una PR-sonda de 10 minutos); el resto del contrato se archiva como superado vía DEC-007. Alternativa válida: ejecutarlo tal cual (cero decisiones nuevas, ~2-4 sesiones más de trabajo). Lo único indefendible es un tercer camino: seguir sin ejecutar ni decidir.
- **RT2 — Mi §6 del 30-08 (niveles por tabla) era medio control:** sin script que decida el nivel, la clasificación habría dependido de juicio por WP. Corregido con Δ6 (§4.4).
- **RT3 — Punto único de fallo humano:** todo acto de operador pasa por una persona no técnica. La llegada de Leandro lo mitiga de facto; formalizarlo (accesos, CODEOWNERS, quién puede fusionar en cada carril) es decisión de negocio pendiente (D5).
- **RT4 — El punto de control puede convertirse en otra espiral:** seis decisiones (D1–D6) en una sola cita, con borradores preparados y regla explícita: lo que no se decida el 07-09 queda en la opción por defecto escrita, no en re-deliberación.
- **RT5 — Riesgo del carril B:** K3 + endpoint compatible concentra riesgo de compatibilidad y de datos (RGPD) en el carril de menos gobierno. Mitigado con el gate 4.2; sin resolver del todo hasta el experimento.
- **RT6 — Sesgo de mis fuentes:** mi línea base se apoya en vendors (Anthropic, GitHub, OpenAI) para la arquitectura de enforcement; contrapeso: DORA/METR/GitClear (independientes) sostienen las conclusiones de proceso. Las cifras de 540 son experiencia de un solo equipo [no HECHO general].
- **RT7 — Sigue abierto:** `claude.yml` sin autorización de actores (desactivado; prerrequisito antes de reactivar); coste sin telemetría hasta Δ1/WP-010; evals de agentes inexistentes hasta el simulacro de Etapa 3.

## 7. Steelman — lo que NO hay que tocar

[HECHO: convergencia de todas las fuentes independientes] (1) **Estado en archivos versionados** — Ralph, Anthropic (feature-list/progress), ACE-FCA: todos redescubren el principio que la FDA tiene desde el día 1. (2) **Generador ≠ evaluador** — unánime; la FDA lo tiene por construcción (agentes, herramientas, worktrees). (3) **Lo determinista, determinista** — el guard como intercepción de permisos es exactamente la «excepción validada» de 540 a su regla anti-hooks. (4) **WP = spec proporcional breve** — CRISPY (<40 instrucciones/etapa) y la crítica a SDD validan el formato contrato-breve frente a planes de mil líneas. (5) **Fusión humana + CI bloqueante + evidencia**. (6) **Las paradas** — la barrera roja que abortó la cadena de WP-008 y los 5/5 falsos verdes cazados son el sistema funcionando; ninguna fuente externa tiene un mecanismo mejor. (7) **ADR-001 (invariantes I1–I4 y gates M1–M3)** — solo necesita añadir «lo nativo primero» (Agent Teams) a M2. Y (8) **la pausa misma fue correcta**: paró sobre un guard que fallaba en abierto y una revisión que no revisaba — el error no fue parar, fue el tamaño de la reparación.

## 8. Experimentos definidos (cuando el análisis no basta)

- **E1 — K3 go/no-go (carril B).** Hipótesis: K3 implementa WPs T1/T2 con ≥ mismo first-pass y ≤ 50 % del coste que la línea base Claude estándar. Medida: % a la primera, ciclos, €/WP, minutos humanos, violaciones de alcance. Procedimiento: 5 WPs idénticos por modelo en el proyecto juguete. Coste ≈ ≤50. Éxito: no-inferioridad en calidad y ahorro ≥ 30 %. Abandono: cualquier violación de alcance no detectada o >2 fallos de compatibilidad del harness. Desbloquea: ADR-002 del carril B.
- **E2 — Sandbox en seco (carril A).** Hipótesis: el sandbox nativo bloquea los vectores de la suite adversarial con ≤ fricción que el guard actual. Medida: sondas bloqueadas/pasadas, falsos positivos por sesión. Procedimiento: WP juguete con sandbox activado, re-ejecutar la suite del guard como sondas vivas. Coste ≈ ≤10. Desbloquea: el WP T3 de adopción y la democión formal del parsing de Bash a mejor-esfuerzo.
- **E3 — Prueba de salida trimestral (Δ9).** Hipótesis: el coste de portar un WP a otro harness/modelo se mantiene < 1 día. Procedimiento: 1 WP pequeño, otro runner, anotar roturas. Si duele, C1 (separar política/mecánica) pasa de «elegante» a «necesaria».

## 9. Revalidación de la hoja de ruta, etapa a etapa

| Etapa (30-08) | Veredicto | Cambio |
|---|---|---|
| 0 — Terminar WP-008 antes del 07-09 | **REVISADA** | La realidad la invalidó (no empezó). Nueva Etapa 0: congelar inicio de implementación hasta D6; preparar el punto de control (hecho: este documento) |
| 1 — Punto de control 07-09 | **SE MANTIENE, AMPLIADA** | De D1–D3 a **D1–D6** (+ deltas Leandro, + carriles, + WP-008 mínimo). Regla anti-espiral: defaults escritos |
| 2 — Cierre de pausa | **SE MANTIENE, REORDENADA** | WP-009 → núcleo mínimo WP-008 (según D6) → humo/WP-012 (según D1) → check_scope + librería única (4.5) → guard delgado (parche humano) → WP-007 cierra (ejecutado o superado) → **sandbox (E2→WP T3)** |
| 3 — Calibración + higiene | **SE MANTIENE, ENRIQUECIDA** | + paquete Δ (métricas/gotchas/output-mín/preguntas/progress/parada dura vía WP-010) + simulacro adversarial completo (5 sondas). Sigue capada: producto antes que perfección |
| 4 — Fase 2 real (AI-Comercial) | **SE MANTIENE en el carril A** | El carril B calibra con Document AI (D5). El programa INV absorbe la advertencia brownfield de ACE-FCA |
| 5 — Agent OS emerge | **SE MANTIENE** | + 12-factor agents como checklist de diseño; + opciones de ejecución durable (DBOS/Restate/Temporal) al llegar |
| 6 — Escalar | **SE MANTIENE, MATIZADA** | Antes del harness propio: capacidades nativas (Agent Teams, subagentes worktree). M2 de ADR-001 se evalúa contra lo nativo primero |

Ningúna etapa se elimina; ninguna se adelanta salvo el sandbox (nuevo, Etapa 2); nada se añade que no tenga señal. Los gates siguen siendo de evidencia, no de calendario (las fechas de 03 son orientativas; los criterios de salida, vinculantes).

## 10. Qué ha cambiado respecto al análisis del 2026-08-30 (clasificado)

| Cambio | Origen |
|---|---|
| WP-008-r2: de «terminarlo tal cual» a «núcleo mínimo, resto superado» (D6) | Cambio del repositorio (no se empezó) + nueva evidencia externa (sandbox) + corrección de mi análisis |
| Enforcement descrito como TRES capas (plataforma + sandbox SO + diff CI), hook demovido a feedback | Investigación externa (línea base H1/H2) |
| Reforma T1/T2/T3: de tabla a script de blast radius | Aportación de Leandro (Δ6) |
| Punto de control ampliado D1→D6 con defaults escritos | Aportación de Leandro + este análisis |
| Dos carriles upstream/downstream; K3 y Document AI gateados en el B | Aportación de Leandro (plan v2) + aportación propia (contrato de retorno) |
| Paquete Δ adoptado (métricas día 0, gotchas, output-mín, preguntas previas, progress.md, parada dura, re-auditoría por modelo) | Aportación de Leandro, corroborada por fuentes primarias |
| Anti-slopsquatting y simulacro con defecto sembrado añadidos | Investigación externa propia |
| Métrica «minutos humanos por resultado» desde ya | Investigación externa (DORA/540) |
| METR citado con su corrección de feb-2026 (−19 % → ≈−4 %, IC −15/+9) | Verificación de fuentes (rigor) |
| Todo lo demás de 03/04 | **Se mantiene** — revalidado, no protegido |

## 11. Registro de cambios documentales de esta revisión

- **Creado** `docs/05-analisis-investigacion-leandro-y-revalidacion.md` (este documento): evidencia y razonamiento, foto fija del 01-09.
- **Modificado** `docs/03-hoja-de-ruta.md`: registro de revisiones; procedencia ampliada; actualización de estado (§1); principio P1 reescrito a tres capas y P9 (medir) añadido; Etapas 0–1 reescritas (realidad + D1–D6); Etapas 2–6 ajustadas según §9; reforma §6 con blast radius ejecutable; métricas §7 y riesgos §8 ampliados; Anexo A (borrador DEC-007) reescrito a D1–D6. Las secciones se actualizaron **en su sitio** para que no queden contradicciones; la fecha de creación original se conserva.
- **Modificado** `docs/04-analisis-conversaciones-ia.md`: una línea de remisión a este documento. Sus veredictos se mantienen.
- Nada se ha fusionado a `main`; nada modifica decisiones, contratos ni controles vigentes. Todo queda en la rama de sesión para revisión del operador y decisión el 07-09.

## 12. Autoauditoría final (14 preguntas del encargo)

Complejidad sin problema real: lo más pesado propuesto (librería única, sandbox) **reduce** complejidad neta; el resto son líneas en plantillas. · Riesgo crítico sin cubrir: RGPD del carril K3 queda señalado y gateado, no resuelto — explícito. · Opinión repetida como evidencia: las cifras de 540 se marcan como experiencia de un equipo; lo decisivo se apoya en METR/DORA/GitClear/vendors verificados. · Sesgo de confirmación: dos recomendaciones propias del 30-08 corregidas (RT1, RT2). · Agentes antes de necesitarlos: cero agentes nuevos; infra-engineer diferido. · Solución más simple: adoptada donde existe (sandbox vs más parsing; script vs deliberación). · Documentación mantenible: 05 es foto fija; 03 única fuente viva. · Verificabilidad determinista: niveles por script, paradas por ccusage, sandbox por kernel, alcance por diff. · Evolución sin reescrituras: upstream/downstream + gates. · Orientación a producto: cupo de meta-trabajo intacto; dos productos reales en los carriles. · Cada capa justifica su coste: matriz §4. · Un agente nuevo sabría qué hacer: orden de lectura en 03 §0. · El operador puede reconstruir qué pasó: este documento + changelog. · Métricas que demuestren mejora: Δ1 + §7 de 03.

## Fuentes externas de esta revisión (adicionales a las de 03/04)

- Sandboxing: [Claude Code — sandboxing](https://code.claude.com/docs/en/sandboxing) · [anthropic-experimental/sandbox-runtime](https://github.com/anthropic-experimental/sandbox-runtime) · [Copilot cloud agent — uso responsable](https://docs.github.com/en/copilot/responsible-use/copilot-cloud-agent) y [firewall](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/customize-the-agent-firewall) · [OpenAI Codex — approvals & security](https://developers.openai.com/codex/agent-approvals-security)
- Evidencia empírica: [METR — time horizons](https://metr.org/time-horizons/) · [METR — cambio de diseño del RCT (feb-2026)](https://metr.org/blog/2026-02-24-uplift-update/) · [Veracode — GenAI code security (2026)](https://www.veracode.com/blog/spring-2026-genai-code-security/) · [DORA — State of AI-assisted software development](https://dora.dev/dora-report-2025/) · GitClear — The Maintainability Gap (citado por Leandro, coherente con lo anterior)
- Supply chain: [Snyk — slopsquatting](https://snyk.io/articles/slopsquatting-mitigation-strategies/) · [Endor Labs](https://www.endorlabs.com/learn/slopsquatting-when-ai-agents-hallucinate-malicious-packages)
- Orquestación nativa y contexto: [Agent Teams](https://code.claude.com/docs/en/agent-teams) · [Effective context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- K3/portabilidad: [Kimi — Claude Code guía oficial](https://platform.kimi.ai/docs/guide/claude-code-kimi) y análisis de límites de compatibilidad citados en el análisis 4.2
- Ejecución durable: [DBOS vs Temporal](https://tiarebalbi.com/en/blog/dbos-vs-temporal-postgres-durable-execution) · 12-factor agents: [humanlayer/12-factor-agents](https://github.com/humanlayer/12-factor-agents)
