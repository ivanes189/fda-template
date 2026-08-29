[← Manual](MANUAL.md)

# 05 — Bloqueos y condiciones de parada

**Que un agente se detenga es el sistema funcionando, no fallando.** El fallo sería que continuara inventando una interpretación.

Cuando un agente para, produce tres cosas: qué le bloquea, qué necesita para seguir, y qué ha hecho hasta ese punto. Tu trabajo es decidir, no reiniciarlo esperando otro resultado.

## Las ocho condiciones de parada

| # | Condición | Quién decide |
|---|---|---|
| 1 | Requisito ambiguo | Tú |
| 2 | Contradicción entre requisitos | Tú |
| 3 | Cambio de ADR necesario | Tú |
| 4 | Migración con riesgo de pérdida de datos | Tú |
| 5 | Vulnerabilidad detectada | Tú, con el `security-reviewer` |
| 6 | Pruebas inejecutables | Tú |
| 7 | Coste fuera de presupuesto | Tú |
| 8 | Tercer ciclo de corrección | Tú |

---

### 1. Requisito ambiguo

**Síntoma:** «el WP dice *validar el importe* pero no especifica si 0 es válido».

**Qué NO hacer:** responder «tú decide, usa el sentido común». Eso traslada una decisión de producto a un modelo y la entierra en el código.

**Qué hacer:** decidir tú, y **escribirlo en el WP**, no en el chat. Luego reanudar.

```bash
# Añade el criterio al WP y confírmalo
sed -n '/## Verificación/,/^## /p' work-packages/WP-014-*.md
git add work-packages/ && git commit -m "WP-014: precisar criterio de importe cero"
```

Si la ambigüedad se repite en varios WPs, el problema está en `specs/requirements/`: arréglalo ahí, no WP a WP.

### 2. Contradicción entre requisitos

**Síntoma:** REQ-FR-023 exige rechazar importes ≤ 0; REQ-FR-031 exige aceptar devoluciones con importe negativo.

**Qué hacer:** no la resuelvas en el WP. Resuélvela en `specs/requirements/`, registra la decisión en `specs/decisions/DEC-xxx.md`, y **después** actualiza el WP. Un WP no puede sobrescribir un requisito en silencio.

### 3. Cambio de ADR necesario

**Síntoma:** el WP no se puede implementar sin contradecir una decisión de arquitectura.

**Qué hacer:** para el WP. Escribe un ADR nuevo que supersede al anterior (contexto, decisión, consecuencias) o rechaza el cambio. **Nunca** dejes que un WP erosione un ADR sin registro: en seis meses nadie sabrá por qué el código contradice la arquitectura documentada.

```bash
cp specs/adr/ADR-001-runtime.md specs/adr/ADR-00X-titulo.md   # como referencia de formato
```

### 4. Migración con riesgo de pérdida de datos

**Síntoma:** el cambio implica `DROP COLUMN`, `ALTER` destructivo, reescritura de datos o borrado.

**Qué hacer:** el WP se divide en tres, siempre en este orden:

1. Migración **aditiva** (añadir sin quitar) + doble escritura
2. Backfill verificable, con conteos antes/después como evidencia
3. Retirada de lo viejo, en un WP posterior y con rollback probado

Ningún agente ejecuta una migración destructiva. Ni con aprobación conversacional.

### 5. Vulnerabilidad detectada

**Síntoma:** el `security-reviewer` reporta un hallazgo **CRÍTICO** o **ALTO**.

**Qué hacer:** el WP se bloquea. No se fusiona. El arreglo va en su propio WP con alcance propio y su propia revisión. No hay «se arregla en el siguiente» salvo decisión humana explícita **registrada en la PR**.

Si el hallazgo es MEDIO o BAJO: puede fusionarse declarándolo como deuda en la PR y abriendo el WP de arreglo. Deuda declarada, no deuda escondida.

### 6. Pruebas inejecutables

**Síntoma:** el entorno está roto, faltan dependencias, o los resultados varían entre ejecuciones.

**Qué NO hacer:** marcar la prueba como `skip` para avanzar. Eso convierte un problema visible en uno invisible.

**Qué hacer:** arreglar el entorno en un WP propio. Si las pruebas son no deterministas, eso **es** el hallazgo: una prueba que a veces pasa no verifica nada.

### 7. Coste fuera de presupuesto

**Síntoma:** el WP supera su `presupuesto_max_eur`.

| Umbral | Acción |
|---|---|
| > 100 € | Aviso: registra y revisa el troceado |
| > 150 € | **Parada**: el agente pide autorización |
| > 750 €/mes | Revisión de la política de modelos |

**Qué hacer:** casi siempre el WP estaba mal troceado, no mal presupuestado. Antes de subir el presupuesto, pregúntate si se puede partir en dos. Ver [06 — Costes y métricas](06-costes-y-metricas.md).

### 8. Tercer ciclo de corrección

**Síntoma:** el `code-reviewer` pide cambios por tercera vez.

**Qué hacer:** **no abras el tercer ciclo.** Para, y busca la causa raíz, que casi nunca es el código:

- ¿El contrato estaba mal definido? → reescribe el WP
- ¿El alcance estaba mal troceado? → pártelo
- ¿El requisito era ambiguo? → arréglalo en `specs/`
- ¿Faltaban criterios de aceptación? → añádelos y reinicia

Registra la causa en `evidence/WP-XXX/`. Los terceros ciclos son la señal más valiosa que da el sistema sobre cómo estás escribiendo los contratos.

---

## Cuando el bloqueo es del hook

Si `guard.sh` bloquea una escritura, el mensaje dice qué ruta y qué permite el WP:

```
BLOQUEADO por la FDA (.claude/hooks/guard.sh)
Ruta fuera del alcance de WP-014: src/pagos/servicio.py
Rutas permitidas por el WP activo:
  - src/pagos/schemas.py
  - src/pagos/endpoints.py
```

Tres respuestas posibles, en orden de preferencia:

1. **El agente se estaba saliendo del alcance** → correcto, que siga sin tocar ese archivo.
2. **El WP estaba mal definido** → amplía `## Archivos permitidos` **conscientemente**, con commit propio que deja rastro de por qué.
3. **Nunca:** vaciar `ACTIVE`, ampliar a `**` o desactivar el hook para «desatascar». Eso no desatasca: apaga el control.

## Cuando el propio gobierno queda bloqueado por el fail-closed

Caso especial y desconcertante la primera vez: **hay que reparar el sistema de control, pero el sistema de control impide repararlo.** Ocurre cuando la fábrica está en reposo (`ACTIVE` vacío) y el arreglo exige escribir archivos — pero en reposo no hay ninguna ruta autorizada.

No es un fallo: es el fail-closed haciendo exactamente lo que debe. Tampoco es un callejón sin salida. Protocolo, en este orden:

**1. ¿El cambio no commiteado es el problema?** Si el estado bloqueante viene de una modificación sin guardar, descártala y vuelves al último estado válido:

```bash
git checkout -- work-packages/ACTIVE
```

Esto no elude nada: deshace algo que nunca llegó a formar parte del historial.

**2. Abre un WP de mantenimiento con alcance mínimo.** No reabras un WP cerrado —y menos el de bootstrap, cuyo alcance es enorme—. Crea uno nuevo que liste **solo** los archivos que la reparación necesita, y actívalo. Ambos actos son del operador humano.

**3. Si el arreglo toca rutas vedadas por `settings.json`** (`.github/workflows/**`, `.claude/hooks/**`, `.claude/settings.json`, `CODEOWNERS`), ningún agente podrá aplicarlo, tenga el WP el alcance que tenga. Son dos capas distintas: el WP dice *qué es del encargo*, y `settings.json` dice *qué no toca ninguna máquina*.

La vía correcta es que el agente **prepare un script de parche verificado** —con copia de seguridad previa, validaciones posteriores y comprobación por huella de que no toca nada más— y que **una persona lo ejecute**. Queda auditable, es reversible, y la decisión sigue siendo humana.

**4. Nunca:** desactivar el hook, vaciar el deny de `settings.json`, ampliar un WP a `**`, ni reescribir un comando para evadir la detección. Si te ves haciendo cualquiera de esas cosas, el problema es el contrato, no el control.

> **Lección aprendida (2026-07-23).** Este protocolo existe porque pasó de verdad: vaciar `ACTIVE` era lo correcto, pero el CI trataba el reposo como error. Como ese job era check obligatorio, la reparación quedó bloqueada por el propio control que había que reparar. Se resolvió con un WP de mantenimiento de 5 rutas y un parche aplicado por el humano. Ver `WP-006`.

## Pausa activa: la migración de DEC-002 (desde 2026-08-03)

La migración de DEC-002 está **pausada tras PR-2** por [DEC-003](../../specs/decisions/DEC-003-pausa-migracion-y-contencion.md), revisada y prorrogada por [DEC-005](../../specs/decisions/DEC-005-troceado-de-wp-008-y-revision-de-la-pausa.md). [DEC-006](../../specs/decisions/DEC-006-abandono-y-reinicio-controlado-de-wp-008.md) registra el abandono y reintento limpio de la primera cadena del núcleo. WP-007 sigue **oficialmente `ready`** y WP-002 sigue `blocked`. Solo pueden progresar DEC-004, DEC-005, DEC-006, WP-008, WP-009, WP-012 y las transiciones de operador que las decisiones enumeran. **Punto de control: 2026-09-07.**

### La revisión del 2026-08-10 y el troceado de WP-008

En su fecha de revisión, el criterio de salida **no estaba cumplido y no podía estarlo**: WP-009 no tenía contrato redactado, y la secuencia impone un WP activo cada vez. DEC-005 registró el análisis de causa que DEC-003 §5 exige.

**La causa raíz no fue la calidad del trabajo.** Los once ciclos de corrección de WP-008 cerraron defectos reales —unos del contrato, otros de la implementación—, y la auditoría independiente los detectó todos antes de cualquier fusión. Lo que falló fue sistémico: tras varios ciclos consecutivos sobre la misma capa, **nadie reevaluó el troceado**. Las diez replanificaciones eligieron siempre la primera causa raíz de este capítulo —«¿El contrato estaba mal definido? → reescribe el WP»— y ninguna evaluó la segunda: **«¿El alcance estaba mal troceado? → pártelo.»**

De ahí el troceado, por **capa** y no por sondas:

| WP | Qué contiene | Naturaleza |
|---|---|---|
| **WP-008** (núcleo) | Reanclaje de `settings.json`, comando canónico fail-closed, preflight estructural, protocolo de parche y evidencia real de CI | Determinista, reproducible en CI |
| **WP-012** (instrumento) | El runner empírico íntegro: catorce sondas y su motor de adquisición, análisis, instantáneas, reintentos y diagnósticos | Empírico, no reproducible en CI |

**El contrato actual de WP-008 queda congelado** hasta que su versión reducida esté materializada, validada y aprobada. Sus alcances y sus evidencias son **físicamente disjuntos** de los de WP-012: nada de `tests/runtime/**` ni de `evidence/` se comparte entre ambos.

**Lo que la evidencia del núcleo no demuestra.** Los casos deterministas del preflight acreditan el comportamiento del **comando canónico**; el preflight acredita que la **configuración** es la contratada; y la ejecución roja de CI acredita que el **preflight bloquea**. Ninguno de los tres demuestra que **Claude Code aplique realmente esa configuración**: eso lo demuestra WP-012, y por eso es condición de salida y no un requisito informal.

### La cadena roja de WP-008 abandonada el 2026-08-29

La primera cadena del núcleo llegó a `C_ROJO` y se detuvo correctamente en la
barrera roja. El run real contenía pasos internos de GitHub que el contrato y sus
fixtures no distinguían de los pasos declarados. No se fabricó el marcador de la
barrera, no se ejecutó la fase verde y no se añadió ningún commit.

DEC-006 conserva la PR #24, su commit y su custodia como intento abandonado,
devuelve `ACTIVE` a reposo y autoriza un único reintento limpio sobre la rama
`wp/WP-008-runtime-fail-closed-r2`. La recuperación exige, en orden: PR de
decisión y reposo; cierre sin fusión de la PR fallida; PR de contrato de un solo
archivo; rama nueva desde `origin/main`; PR separada de activación; fast-forward
e igualdad; y solo después implementación y nueva cadena de tres commits.

Mientras una cadena esté en S1 y operativa no se abre ninguna sesión de agente.
Si el paquete se detiene, la cadena queda congelada: pueden abrirse auditorías de
agente **solo de lectura** para explicar la parada y preparar una decisión humana,
pero no para escribir, usar Git mutable, ejecutar la fase verde ni reanudar por su
cuenta. Una salida `1` o `2` no se interpreta conversacionalmente ni se convierte
en verde.

### WP-007 está congelado, no detenido antes de empezar

Existe en un worktree separado una **implementación candidata de WP-007, aplicada localmente y sin versionar**. No es un WP terminado, ni revisado, ni APTO: le faltan `cost.md`, la evidencia postcommit, la revisión que exige su contrato, y reconciliar su `PENDIENTE-HUMANO.md` con los logs 15–22.

Mientras dure la pausa, sobre ese trabajo **no** se hace ninguna edición nueva, ni `git add`, `commit`, `stash`, `checkout`, `restore`, cambio de rama, `push`, apertura de PR ni fusión. Levantarlo exige una decisión humana posterior y separada.

La congelación es **verificable, no solo declarada**: DEC-003 §1 registra una huella de **siete magnitudes** —`HEAD`, índice limpio, 3 archivos rastreados modificados, 32 archivos de evidencia, dos SHA-256 de contenido y **35 entradas Git visibles con su propio SHA-256**— recalculable con comandos de solo lectura. La séptima detecta la aparición, desaparición, staging o cambio de clasificación de cualquier ruta Git visible, también fuera de `evidence/WP-007/`; las de contenido detectan lo que `git status` por sí solo no ve. «0 commits» y «sin PR» no bastan: ninguno observa el árbol de trabajo.

Conviene no confundir dos líneas base de la suite del guard: la **versionada** en `main` es `68 · 0 · 10 · 0`; la **candidata local** de WP-007 es `75 · 0 · 10 · 0`. Ninguna acción admitida por la pausa modifica `tests/guard/run-suite.sh`.

Cuando WP-007 se reanude, su versión de este capítulo **no sobrescribe** la que introdujeron DEC-003 y DEC-005: tendrá que **reconciliarse con ella y preservar ambos contenidos**.

### El trabajo candidato de WP-012

Los trece archivos sin versionar del undécimo ciclo de WP-008 —cuatro principales y nueve fixtures— son **trabajo candidato de WP-012** y **no se revierten**. Antes de que el núcleo empiece a escribir en `tests/runtime/`, se aíslan mediante **respaldo externo recuperable y worktree independiente**, con un manifiesto que registra y verifica **conjunto de rutas, tipo, modo —incluido el bit ejecutable— y SHA-256**. El procedimiento está en DEC-005 §9 y es un acto humano en tres fases.

### El ciclo de `ACTIVE` durante la pausa

`ACTIVE` empieza en reposo y **no se queda vacío toda la pausa**. Cada transición es un acto del operador humano:

| Paso | `ACTIVE` | Condición |
|---|---|---|
| 1 | Reposo | Al materializar DEC-005 |
| 2 | `WP-008` (núcleo) | Contrato reducido, validado y aprobado, y aislamiento completado |
| 3 | Reposo | Cierre de WP-008 |
| 4 | `WP-009` | Contrato completo, validado y aprobado |
| 5 | Reposo | Cierre de WP-009 |
| 6 | `WP-012` | Contrato completo, validado y aprobado, y precondiciones verificadas |
| 7 | Reposo | Cierre de WP-012 |
| 8 | `WP-007` | Solo al cumplirse las **tres** condiciones de salida; cierra la pausa |

Un WP activo cada vez. Entre WPs, reposo. Mientras `ACTIVE` esté vacío no hay ninguna ruta autorizada.

El **criterio de salida tiene tres condiciones**: WP-008 fusionado —protección instalada con su ejecución roja de CI—, WP-009 fusionado —acciones fijadas por SHA— y WP-012 fusionado —runner empírico en exit `0` con la composición 14 · 13 · 1 · 0—.

El **WP de mantenimiento de alcance mínimo** descrito más arriba sigue siendo el protocolo general y legítimo para reparar el gobierno cuando el fail-closed lo bloquea. **Para esta pausa concreta, el operador ha decidido no emplear esa vía** y ha elegido **preparación en solo lectura más materialización humana**: los contratos de los WPs admitidos se redactan sin escribir en el repositorio, y los materializa y activa el operador.

## Qué hacer con un WP bloqueado

```bash
sed -i '' 's/^estado: .*/estado: blocked/' work-packages/WP-014-*.md
```

Documenta el bloqueo en el propio WP —qué lo bloquea y qué se necesita— y deja constancia en `evidence/WP-014/`. El estado vive en archivos: si solo está en el chat, se pierde.
