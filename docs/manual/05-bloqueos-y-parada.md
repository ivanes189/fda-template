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

**Síntoma:** la revalidación enfocada posterior a C2 sigue en `NO APTO`.

**Qué hacer:** **no abras el tercer ciclo.** Preserva el candidato y el
expediente, y elige mediante decisión humana entre cierre `blocked`, división o
replanteamiento del contrato. Busca la causa raíz, que casi nunca es solo el
código:

- ¿El contrato estaba mal definido? → reescribe el WP
- ¿El alcance estaba mal troceado? → pártelo
- ¿El requisito era ambiguo? → arréglalo en `specs/`
- ¿Faltaban criterios de aceptación? → corrige el contrato mediante un acto
  humano; no renombres los ciclos consumidos

La cuenta vive en `evidence/WP-XXX/ciclos.md`. Antes de cada C1/C2, la fila con
el número, candidato/revisión de origen, hallazgos, fecha y estado `abierto`
debe quedar **versionada en la rama candidata**. Si no puede versionarse, la
pasada no empieza. Una invocación fallida, interrumpida o sin cambios consume
el ciclo y actualiza la misma fila; una revalidación sin nueva pasada del autor
no consume otro. Al reanudar una sesión se consulta ese registro, nunca la
memoria del chat.

**Excepción no predeterminada.** C3 solo puede existir mediante una decisión
humana nueva, previa, fechada y versionada que identifique el WP, los hallazgos
cerrados que puede tratar, el alcance exacto, el presupuesto adicional y el
techo final. No reinicia ni renombra la cuenta y no autoriza C4. Conceder una
excepción sucesiva exige otra decisión; no es continuidad automática.

Registra la causa en `evidence/WP-XXX/`. Los terceros ciclos son una señal sobre
la calidad del contrato o del troceado, no una invitación a seguir insistiendo.
Ver [DEC-010](../../specs/decisions/DEC-010-separacion-autor-revisor-y-ciclos.md).

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

**3. Si el arreglo toca rutas vedadas por `settings.json`** (`.github/workflows/**`, `.claude/hooks/**`, `.claude/settings.json`, `CODEOWNERS`), **ningún agente está autorizado a aplicarlo**, tenga el WP el alcance que tenga. Separa la **norma** del **mecanismo**: las **herramientas de edición** están denegadas por `permissions.deny`; las **escrituras mediante shell** reciben el **feedback preventivo best-effort del guard**, que **no es una garantía universal**. La **vía autorizada es un parche verificado aplicado por una persona**. Y son dos capas distintas: el WP dice *qué es del encargo*, y `settings.json` dice *qué no está autorizado a tocar ninguna máquina*.

La vía correcta es que el agente **prepare un script de parche verificado** —con copia de seguridad previa, validaciones posteriores y comprobación por huella de que no toca nada más— y que **una persona lo ejecute**. Queda auditable, es reversible, y la decisión sigue siendo humana.

**4. Nunca:** desactivar el hook, vaciar el deny de `settings.json`, ampliar un WP a `**`, ni reescribir un comando para evadir la detección. Si te ves haciendo cualquiera de esas cosas, el problema es el contrato, no el control.

> **Lección aprendida (2026-07-23).** Este protocolo existe porque pasó de verdad: vaciar `ACTIVE` era lo correcto, pero el CI trataba el reposo como error. Como ese job era check obligatorio, la reparación quedó bloqueada por el propio control que había que reparar. Se resolvió con un WP de mantenimiento de 5 rutas y un parche aplicado por el humano. Ver `WP-006`.

## Pausa activa: la migración de DEC-002 (desde 2026-08-03)

La migración de DEC-002 sigue **pausada tras PR-2**. DEC-007 registra el
2026-09-09 el punto de control previsto para el 07-09 y reordena la pausa sin
terminarla. DEC-008 registra el 2026-09-13 los cierres bloqueados de WP-009 y
WP-013. WP-014 se completó después: PR #40 fusionada, contrato `done` y
`ACTIVE` de nuevo en reposo. Con ello queda satisfecha solo la segunda condición
de salida de DEC-003 §6. WP-007 sigue `ready`, WP-002 `blocked`, WP-005 `draft`
y WP-008 suspendido hasta una transición humana separada. D3 hace normativa
`docs/03`; `docs/04` y `docs/05` quedan como procedencia y fotos fijas. La lista
cerrada y las transiciones siguen en DEC-003.

### La revisión del 2026-08-10 y el troceado de WP-008

En su fecha de revisión, el criterio de salida **no estaba cumplido y no podía estarlo**: WP-009 no tenía contrato redactado, y la secuencia impone un WP activo cada vez. DEC-005 registró el análisis de causa que DEC-003 §5 exige.

**La causa raíz no fue la calidad del trabajo.** Los once ciclos de corrección de WP-008 cerraron defectos reales —unos del contrato, otros de la implementación—, y la auditoría independiente los detectó todos antes de cualquier fusión. Lo que falló fue sistémico: tras varios ciclos consecutivos sobre la misma capa, **nadie reevaluó el troceado**. Las diez replanificaciones eligieron siempre la primera causa raíz de este capítulo —«¿El contrato estaba mal definido? → reescribe el WP»— y ninguna evaluó la segunda: **«¿El alcance estaba mal troceado? → pártelo.»**

De ahí el troceado, por **capa** y no por sondas:

| WP | Qué contiene | Naturaleza |
|---|---|---|
| **WP-008** (núcleo) | Reanclaje de `settings.json`, comando canónico fail-closed, preflight estructural, protocolo de parche y evidencia real de CI | Determinista, reproducible en CI |
| **WP-012** (instrumento) | El runner empírico íntegro: catorce sondas y su motor de adquisición, análisis, instantáneas, reintentos y diagnósticos | Empírico, no reproducible en CI |

**El contrato actual de WP-008 queda congelado** hasta que su versión reducida esté materializada, validada y aprobada. Sus alcances y sus evidencias son **físicamente disjuntos** de los de WP-012: nada de `tests/runtime/**` ni de `evidence/` se comparte entre ambos.

**Lo que la evidencia del núcleo no demuestra.** Los casos deterministas acreditan el comando y el preflight, pero no la semántica general de Claude Code. D1 ratificada libera WP-012 como condición de salida y exige el humo seguro de WP-008, `check_scope` y resolver E2. Un E2 negativo resuelve el gate sin aportar garantía de kernel; esa garantía solo existiría tras una adopción efectiva del sandbox.

### El punto de control resuelto el 2026-09-09

El criterio de salida no estaba cumplido. DEC-007 registra estas resoluciones efectivas:

| # | Resultado efectivo |
|---|---|
| D1 | **Ratificada:** humo seguro en WP-008, `check_scope` en CI y requerido, y resolución de E2 |
| D2 | **Ratificada con precisión:** clasificador ejecutable, suelo común y prevalencia T3 |
| D3 | **Ratificada:** 03 normativa; 04/05 como procedencia y fotos fijas |
| D4 | **Ratificada:** solo elementos ADOPTAR, en sus etapas |
| D5 | **Default:** sin acuerdo formal; el carril B no se asigna ni activa |
| D6 | **Ratificada:** núcleo mínimo |

La regla anti-espiral conserva estos resultados. D2 y D4 requieren implementación posterior. D5 exige una decisión humana nueva antes de crear un carril B, asignar responsables, repositorio, producto, accesos o retorno.

### Cierre bloqueado de WP-009 el 2026-09-13

WP-009 agotó sus dos ciclos con un hallazgo ALTO abierto en el aplicador humano y defectos funcionales y probatorios abiertos. No se aplicó el parche, no cambiaron los workflows, no se creó commit de implementación y el contrato queda `blocked`, no `done`. La candidata C2 se preserva como material histórico no conforme; no se ejecuta ni se incorpora en bloque a un sucesor.

La versión inicial de DEC-008 dividió el trabajo pendiente entre WP-013 y
WP-014. La enmienda de recuperación que se documenta a continuación conserva
esa historia, pero sustituye la dependencia del materializador. Los cierres de
WP-009 y WP-013 son actos `O/T`; junto con el cierre futuro de WP-005, `O/T`
aparece tres veces en la secuencia vigente.

### Cierre bloqueado de WP-013 el 2026-09-13

WP-013 consumió C1, C2 y un C3 autorizado excepcionalmente. La revisión
enfocada de C3 mantuvo H1 ALTO y H2–H4 MEDIOS pese a 89/89 pruebas verdes; no
hay C4 autorizado. El contrato queda `blocked`, la candidata se preserva fuera
del cierre como **CANDIDATA HISTÓRICA NO CONFORME — NO EJECUTAR** y `ACTIVE`
vuelve a reposo en el mismo diff. La composición no importa el materializador
ni modifica workflows.

La enmienda de recuperación de DEC-008 retiró WP-013 como dependencia. **En el
momento de aquel cierre**, WP-014 seguía reservado, no creado ni activo. Su
contrato posterior solo podía abarcar
los diez pins exactos y los mismos bytes de parche entregados por `stdin` a
`git apply --check --index -` y `git apply --index -`; una persona los aplica
en un worktree limpio y dedicado y comprueba el diff exacto. Git no es un
sandbox ni una transacción general. La recuperación ordinaria consiste en
descartar y recrear ese worktree; cualquier fallo del repositorio compartido o
del almacenamiento obliga a parar y escalar.

### Cierre de WP-014 el 2026-09-13

WP-014 cumplió el contrato limitado de DEC-008. Iván aplicó personalmente el
blob Git preparado; el diff de implementación cambió solo diez líneas `uses:`
de los tres workflows y dejó la distribución `5 checkout / 2 setup-python / 1
gitleaks / 2 claude-code-action`. La PR #40 fue revisada sobre
`d1ae1b86fbe3114cf583ddc9ff73c90d758ad526` y fusionada mediante
`ea004919b661baf206257952f2fd5ca7bfad2c05`, con los tres checks en `SUCCESS`.

La revisión completa de Astra pidió tres correcciones de evidencia; Claude las
resolvió en C1 y Astra emitió `APTO` en la revalidación enfocada. El contador
final es `1 / 2` y el coste medido `2,73 EUR / 12 EUR`. No quedan hallazgos ALTOS
o CRÍTICOS abiertos en el entregable ni en el procedimiento aplicado de
WP-014. El contrato queda `done` y `ACTIVE` vuelve a reposo en el mismo diff de
operador. La evidencia reconstruible está en `evidence/WP-014/CIERRE.md`.

El primer intento del bloque humano reveló una expansión no delimitada que
`zsh` interpretaba como modificador `:e`; se detuvo antes de `git apply`. La
ejecución correcta usó `${VARIABLE}:ruta`, quedó registrada y el cierre corrige
las dos líneas del contrato. La recuperación por recreación del worktree sigue
siendo una regla contingente: no fue necesario ejecutarla.

### D6-A efectiva y contabilidad de ciclos

Una PR de operador de un solo archivo redujo el contrato de WP-008 al núcleo.
El contrato reducido recibió de DEC-007 una cuenta propia `0 / 2`; R2 conserva
`2 / 2` agotado y los once ciclos anteriores no se renombran. D6-A consumió C1
y C2 ordinarios y C3–C5 autorizados excepcionalmente: contador final `5 / 2`.
C6 no está autorizado.

**Nada de esto borra historia.** Los once ciclos registrados por DEC-005 y los
ciclos 1 y 2 de la rama `-r2` se conservan tal cual. La cuenta propia de D6-A
fue un presupuesto nuevo para un contrato nuevo, no una renumeración de lo ya
gastado. C3, C4 y C5 existen únicamente por sus autorizaciones humanas expresas;
no reinician el contador ni crean precedente para C6.

### Cierre bloqueado de WP-008 D6-A el 2026-09-21

Astra cerró el hallazgo ALTO previo del normalizador, pero su última
revalidación mantuvo un MEDIO reproducido: una representación con identificador
ajeno podía colapsar dos apariciones a una. También acreditó que dos regresiones
no reproducían la mutación original. La última invocación Claude terminó por
límite de turnos sin cambios y el único A/B final no se ejecutó.

DEC-009 registra el resultado como `blocked`, nunca `done`; devuelve `ACTIVE` a
reposo en el mismo diff y preserva la rama y el worktree D6-A como **CANDIDATA
HISTÓRICA NO CONFORME — NO EJECUTAR**. La implementación, los protegidos y los
scripts candidatos no se importan a `main`. Las pruebas deterministas verdes no
neutralizan el dictamen del oráculo.

El cierre administrativo termina el intento sin aceptarlo. Por eso no
contradice “si falla el humo, WP-008 no se cierra” en su significado de entrega:
WP-008 no queda `done`, no se fusiona y no satisface el criterio de salida. La
secuencia queda detenida en reposo; WP-002 y cualquier otro sucesor requieren
una decisión humana nueva antes de siquiera preparar su transición.

### La candidata local de WP-008-r2: suspensión, no cierre

Existe en el worktree `wp/WP-008-runtime-fail-closed-r2` una **candidata local no publicada**: 72 archivos regulares —46 bajo `tests/runtime/` y 26 bajo `evidence/WP-008/`—, con la batería A cerrada 22/22 y los ciclos 1 y 2 consumidos. No hay commit de implementación, ni PR, ni fase real.

Devolver `ACTIVE` a reposo **no cierra ni abandona WP-008**: es una suspensión autorizada por el cambio de rumbo. No se retira su identificador, no se borra su worktree y **esta decisión no autoriza copiar, mover ni borrar la candidata**.

Antes de cualquier limpieza, reutilización o modificación, una **operación humana separada** debe crear una **custodia externa persistente** con manifiesto de rutas, tipos, modos y SHA-256. La persona fija antes por escrito el destino persistente —**nunca `/private/tmp`**—, el soporte y su durabilidad, el modo y la propiedad del árbol, el formato verificable del manifiesto y el periodo de retención. La custodia y cada artefacto peligroso se marcan **CANDIDATA HISTÓRICA NO CONFORME — NO EJECUTAR**, nombrando el hallazgo que conservan. Ese código no se fusiona como entregable ni se usa como guía operativa.

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

Conviene no confundir dos líneas base de la suite del guard: la **versionada** en `main` es `68 · 0 · 10 · 0`; la **candidata local** de WP-007 es `75 · 0 · 10 · 0`. Ninguna acción admitida por la pausa modifica `tests/guard/run-suite.sh`. **La única excepción posible es la rama en la que WP-007 se resuelve por ejecución**, una vez **levantada expresamente la congelación** y **durante el trabajo autorizado de su contrato**. **La superación de WP-007 no autoriza modificar `run-suite.sh`.** La excepción se define por su **contenido**, no por un número de paso (DEC-003 §7).

Cuando WP-007 se reanude, su versión de este capítulo **no sobrescribe** la que introdujeron DEC-003 y DEC-005: tendrá que **reconciliarse con ella y preservar ambos contenidos**.

### El trabajo candidato de WP-012

Los trece archivos sin versionar del undécimo ciclo de WP-008 —cuatro principales y nueve fixtures— son **trabajo candidato de WP-012** y **no se revierten**. Antes de que el núcleo empiece a escribir en `tests/runtime/`, se aíslan mediante **respaldo externo recuperable y worktree independiente**, con un manifiesto que registra y verifica **conjunto de rutas, tipo, modo —incluido el bit ejecutable— y SHA-256**. El procedimiento está en DEC-005 §9 y es un acto humano en tres fases.

### El ciclo de `ACTIVE` durante la pausa

`ACTIVE` empieza en reposo y **no se queda vacío toda la pausa**. Cada transición es un acto del operador humano.

**Lo primero, porque de ello depende todo lo demás.** `ACTIVE` solo admite **reposo** —vacío o solo comentarios— o **un único `WP-NNN` existente**. Cualquier otro contenido —una actividad, una descripción, un identificador provisional, dos WPs juntos— es un **estado incoherente**: `check-active.sh` devuelve exit `1`, el job `Gobierno FDA` se pone rojo y, por ser obligatorio, **bloquea toda fusión, incluida la que lo arreglaría**. Por eso las tablas de abajo solo contienen reposo y `WP-NNN`, y las actividades que no son WPs viven fuera de la columna `ACTIVE`.

**Secuencia bajo D1 y D6 ratificadas** (DEC-003 §2.a):

| Paso | `ACTIVE` | Qué ocurre mientras | Condición |
|---|---|---|---|
| 1 | Reposo | Suspensión de WP-008-r2; custodia externa de la candidata local; contrato breve de WP-009 | Contrato de WP-009 aprobado |
| 2 | `WP-009` | PR de operador de `DEC-008`: registra el bloqueo tras 2/2 ciclos, preserva la candidata, marca el contrato `blocked` y escribe reposo en `ACTIVE` | WP-009 cerrado como bloqueado y `ACTIVE` en reposo |
| 2.a | `WP-013` | Cierre atómico bloqueado tras C3 excepcional, preservación de candidata y vuelta a reposo | WP-013 `blocked` y reposo restablecido |
| 2.b | Reposo | **Completado:** acto de operador que creó y aprobó el contrato limitado de **WP-014** | **Cumplida:** contrato de WP-014 aprobado |
| 2.c | `WP-014` | **Completado:** preparación de los mismos bytes de parche, comprobación y aplicación humana por `stdin`, pruebas, revisión y fusión | **Cumplida por PR #40 y el cierre:** WP-014 fusionado y reposo restablecido |
| 2.d | Reposo | La recuperación por recreación del worktree permanece como regla contingente; no fue necesaria en WP-014 | **Cumplida:** cadena de suministro acreditada sin WP-013 |
| 3 | Reposo | PR de operador con el contrato de WP-008 según la rama de D6 resuelta | Contrato aprobado |
| 4 | `WP-008` | Núcleo **y humo seguro antes del cierre**, con evidencia en `evidence/WP-008/`. **Si el humo falla, WP-008 no se cierra** | Cierre con el humo en verde |
| 5 | Reposo | PR de operador que saca a **WP-002** de `blocked` | Contrato de WP-002 aprobado |
| 6 | `WP-002` | Librería única de matching y `check_scope` | Cierre de WP-002 |
| 7 | Reposo | PR de operador que **corrige integralmente** el contrato de **WP-005** y lo deja `ready`. **No basta con cambiar el estado**: ver «Por qué WP-005 no es hoy ejecutable», más abajo | Contrato de WP-005 **ejecutable** y aprobado |
| 8 | `WP-005` | El agente prepara el **parche verificable** de `.github/workflows/ci.yml` y **una persona lo aplica** dentro de la PR del WP, con `ACTIVE` en `WP-005` y **sin relajar `permissions.deny`**. El job queda **ejecutándose en CI, todavía NO requerido**: rojo, verde, validaciones y revisiones capturados. Se fusiona la PR de implementación; **WP-005 no se marca `done`** | PR de implementación fusionada y el job reportando desde `main` |
| 9 | `WP-005` (sigue activo hasta el final del paso) | **Una persona** añade `check_scope` a `required_status_checks` como **cuarta comprobación**; ese acto no cambia estado versionado. Después, **PR de operador de cierre** que, en un **único diff atómico**, registra la evidencia canónica del ruleset, acredita la **política `ops/*`**, marca WP-005 `done` **y** escribe reposo en `ACTIVE`. **Los dos últimos van juntos o no van**: un diff intermedio dejaría `ACTIVE` apuntando a un WP cerrado, y `check-active.sh` no lo detecta | Check **requerido**, registro completo, y `done` + reposo **en el mismo diff** |
| 10 | Reposo | **Parche humano del guard delgado** (carril T3). Después, **precondición común**: recalcular en solo lectura las **siete magnitudes**, **parar si alguna difiere**, comprobar cardinalidad, tipos y modos, y **custodiar externamente la candidata completa antes de tocarla**. Solo entonces, **decisión humana registrada sobre WP-007** entre **superación** y **ejecución**, que levanta la congelación y, en ejecución, **corrige íntegramente su contrato en una PR de operador previa** | **Superación:** WP-007 queda resuelto con **`estado: done`** y bloque **«Cerrado por superación»**, con `ACTIVE` en reposo y **sin transición**; se pasa al 12. **Ejecución:** el contrato corregido está **aprobado y fusionado** y WP-007 queda en **`estado: ready`**; se pasa al 11 |
| 11 | `WP-007` **solo en la rama de ejecución** | Ejecución, verificación, revisión y **fusión de la PR de implementación** gobernada por el contrato ya corregido —**no** una segunda fusión del contrato— | **PR final de operador** que, en un **único diff atómico**, marca WP-007 `done`, **escribe reposo en `ACTIVE`** y registra el resultado |
| 12 | Reposo | Estado desde el que se resuelve E2 y desde el que se cierra la pausa | Criterio de salida cumplido |

**Las dos ramas son excluyentes, y el paso 10 nunca exige WP-007 resuelto antes de poder ejecutarlo.** Si se resuelve **por superación**, el paso 11 no existe y se pasa del 10 al 12: superar el WP es un **acto de operador** que **no mueve `ACTIVE`**. Si se resuelve **por ejecución**, el paso 10 exige la congelación **levantada** y el **contrato corregido aprobado**, y la resolución llega **al final** del paso 11. DEC-007 las tipa así: **superación = `O`** (sin transición) y **ejecución = `O` + `T` + `W` + `T`** (dos transiciones con trabajo en medio). **Nunca es un único acto compuesto.**

**Antes de descongelar: recomprobar y custodiar.** Sea cual sea la rama, primero se **recalculan en solo lectura las siete magnitudes** de DEC-003 §1 y se **comparan exactamente** con la huella: **si alguna difiere, parada y análisis**, sin actualizar la huella. Se comprueban además **cardinalidad, tipos y modos** de los archivos sin versionar, que la huella **no cubre**. Y se crea una **custodia externa persistente de la candidata completa** —rama y `HEAD`, estado Git `NUL`, diff binario, rutas rastreadas y no rastreadas, tipos, modos, tamaños, `SHA-256` por archivo y digest agregado—, con **propietario, acceso, soporte, ubicación —nunca `/private/tmp`—, retención, recuperación y auditabilidad**, marcada **`CANDIDATA HISTÓRICA NO CONFORME — NO EJECUTAR`**. **El descarte nunca precede a la custodia**: solo cabe sobre el worktree original y solo después. En la rama de ejecución no se confunden **la preimagen custodiada**, **la candidata usada como punto de partida**, **la reconciliación** y **el resultado versionado**.

**Por qué el contrato de WP-007 no es activable tal como está.** Su **PR-4 histórica** ordena marcar WP-007 `done`, devolver **WP-002 a `ready`** y escribir **`ACTIVE` ← WP-002**. Esa transición es **obsoleta**: WP-002 habrá quedado `done` en el paso 6, y ejecutarla reescribiría hacia atrás su estado contractual. Además, el contrato original razonaba que el hook se corregía **antes** de reiniciar WP-002, y el orden nuevo lo **invierte**. Por eso la rama de ejecución exige **antes** una PR de operador que **corrija íntegramente el contrato**: retirar o sustituir la PR-4, adaptar el orden —**primero** librería y `check_scope`, **después** guard delgado—, preservar la revisión humana, la **reconciliación de corpus** y el tratamiento de la candidata local, actualizar paradas y criterios, y **no reactivar WP-002 ni WP-005**. La **historia se conserva etiquetada como historia** (DEC-003 §1); lo que deja de estar vigente es la secuencia.

**Qué queda escrito al superar WP-007.** La PR de operador escribe **`estado: done`** —único valor del vocabulario de `_TEMPLATE.md` que significa «no se vuelve a activar»— **más** un bloque **«Cerrado por superación»** que identifica la decisión versionada que lo autoriza, declara que **sus criterios de aceptación no se ejecutaron**, que el contrato **queda retirado de la cola ejecutable**, que **no puede reactivarse sin otra decisión humana nueva, fechada y versionada**, y que **la candidata local se preserva** hasta que una persona decida por escrito su custodia o su descarte. **No se inventa ningún estado nuevo:** la causa del cierre la distingue el bloque, no el valor.

**Una sola transición al cerrar WP-005.** `ACTIVE` cambia **exactamente una vez** en todo el cierre, y lo hace en el mismo diff que marca el WP `done`. **Ningún acto que no sea una transición mueve `ACTIVE`.**

**Por qué los pasos 8 y 9 están separados.** El 8 deja el job **existiendo y reportando**; el 9 lo hace **bloqueante para la fusión**, y eso es una **mutación humana de GitHub**, no código de ningún WP. Cerrar WP-005 en el 8 daría por cumplida esa parte del criterio de salida con un check que aún no bloquea, y obligaría a **escribir evidencia sobre un WP ya cerrado**. Por eso `ACTIVE` sigue en `WP-005` hasta que el registro esté completo. La PR del paso 9 es una **PR de operador** (`ops/*`), no una segunda PR de implementación: «un WP = una rama = una PR» **queda intacto**.

**Por qué WP-005 no es hoy ejecutable, y qué debe corregir su PR de operador.** Cuatro cosas, exigidas nominalmente por `DEC-003` §2.d y `DEC-007`:

1. **Ruta protegida.** El contrato declara `agente_responsable: implementer` y permite `.github/workflows/ci.yml`, pero `Edit(./.github/workflows/**)` está en `permissions.deny` y el capítulo [07 — Troubleshooting](07-troubleshooting.md) establece que esos archivos **los modifica una persona**. Debe redactarse como **parche verificable preparado por el agente y aplicado por una persona**, sin relajar el deny.
2. **Evidencia permitida.** Exige archivos en `evidence/WP-005/` pero esa ruta **no está en su `## Archivos permitidos`**. Debe añadir **`evidence/WP-005/**`**.
3. **Ramas de operador.** El job hace fallar toda rama que no encaje en `wp/(WP-[0-9]{3})-.*`, de modo que **rompería cada PR de operador** en ramas `ops/*` —deuda ya declarada en `WP-002` y en [02 — Ciclo de un WP](02-ciclo-de-un-wp.md)—. Debe **elegir expresamente** una política, y cualquiera que elija tiene que cumplir el **contrato medible** de `DEC-007`, que es su fuente normativa: **toda PR `ops/*` ejecuta siempre** el job que emite el check requerido, y **ningún filtro de workflow, condición de job ni mecanismo equivalente** puede impedir su creación o su ejecución —un filtro dejaría además la PR **pendiente para siempre**, sin actores de excepción que la desbloqueen—. **Cuidado con `needs:`**: un job **se salta** si su dependencia falla o se salta, y **un job saltado se presenta como satisfactorio**; por eso el job **no depende de otro** o usa **`if: ${{ always() }}`** y **evalúa por sí mismo** los resultados, la **ausencia, fallo o salto de una dependencia produce `failure`**, el verificador corre con **`continue-on-error: false`**, **ningún step posterior convierte su fallo en `success`** y hay **un único gate terminal** que agrega y **falla cerrado**. Las conclusiones se clasifican **de forma cerrada**: **única conforme** `success` **tras verificación completa**; **negativa esperada** `failure`; y **cualquier otro estado o conclusión** —`queued`, `requested`, `in_progress`, `waiting`, `action_required`, `cancelled`, `neutral`, `skipped`, `stale`, `timed_out`, `startup_failure`, ausente o pendiente— **impide cerrar WP-005**, aunque GitHub acepte alguno para fusionar; una **condición de step** solo vale si **no evita ejecutar el verificador** ni impide emitir la conclusión terminal; **el nombre de rama no basta** para reconocer una PR de operador; las ramas `wp/*` **conservan el fail-closed**; un fallo de verificación **cierra, no abre**; y hay **prueba roja y prueba verde falsables** —**caso rojo**: PR `ops/*` con autorización inexistente, inválida, caducada o de otro `HEAD`, con el job **ejecutado** y conclusión **`failure`**; **caso verde**: autorización **vigente para su `HEAD` actual**, job **ejecutado**, fuente de confianza verificada y conclusión **`success`**—, cada una con PR, `HEAD SHA`, par, identificador de ejecución, conclusión final, instante UTC y prueba de vigencia, **sin publicar secretos ni datos personales innecesarios**. **La fuente concreta de autorización humana no se elige todavía.** Además: **el check se identifica por el par `{context, integration_id}`** —nombre **y productor**—, de modo que un **contexto homónimo publicado por otro productor no lo satisface**; y **la autorización debe estar vigente**, vinculada al **`HEAD SHA` exacto y vigente** de la PR, **inválida** al cambiar el diff, el SHA o la fuente de confianza, **reevaluada** ante los eventos que el contrato enumere y **fail-closed** si su vigencia no puede demostrarse. Sin esa elección probada, ni se activa WP-005 ni puede incorporarse el check al ruleset: la propia PR de cierre **no sería fusionable**.
4. **Ruleset fuera del WP.** Marcar el check como requerido **no es alcance del código de WP-005**: es una **mutación humana** de GitHub.
5. **Evidencia reproducible de esa mutación.** El registro del paso 9 cumple **íntegramente** el esquema de [`DEC-007`](../../specs/decisions/DEC-007-punto-de-control-y-rumbo.md) § «Evidencia de la mutación del ruleset», **fuente normativa detallada que este capítulo no reproduce**. En resumen: **identidad de la captura** —repositorio y rama, `ruleset_id`, endpoint autoritativo y versión de API, instantes UTC—; **versiones y direccionamiento** —`version_id` anterior y posterior, `updated_at` y la **respuesta de historia capturada después de mutar**, con **tres endpoints distinguidos**: estado actual, **listado** —`version_id`, actor y `updated_at`, **sin** `state` completo— y **versión concreta**, que sí lo devuelve. **`version_id` es direccionamiento, no custodia**; **no se afirma inmutabilidad ni retención futura garantizada**, y la **ventana de 180 días** documentada por GitHub es **visibilidad de la interfaz**, no garantía del endpoint REST—; **estado semántico completo** de preimagen y postimagen —incluidos `enforcement`, condiciones, destino, *bypass actors*, **todas** las reglas con **todos** sus parámetros y los checks como pares **`{context, integration_id}`**—; **proyecciones** que **no sustituyen** al estado completo; un **delta** que debe reducirse **exactamente** al par añadido; **normalización declarada** de las colecciones sin orden significativo más **canonicalización RFC 8785 (JCS)** y **SHA-256 de esos bytes exactos**, con **canonicalizador identificado**; **actor verificable** por **referencia opaca al historial protegido** —se publica el rol «operador humano», **nunca** correo, usuario ni identificador de cuenta—; **comprobación de deriva** antes y después de mutar; **rollback mínimo** con **condición verificable**; un **orden vinculante** que separa lo que debe existir **antes de mutar** de lo que solo puede capturarse **después**; un **procedimiento fail-closed de indisponibilidad histórica** —la mutación **se conserva**, **WP-005 permanece abierto**, **no se presenta la PR de cierre**, se registran los intentos y **se escala**, **sin rollback automático**—; **credencial y permiso mínimo documentado** —hoy `Administration: write` para el endpoint de versión—, **nunca entregada al agente ni versionada**; y **custodia externa persistente y protegida** de las representaciones completas —**propietario**, **política de acceso**, **soporte y ubicación lógica** (**nunca `/private/tmp`**), **retención explícita**, **procedimiento de recuperación**, **auditabilidad futura** y **huella**—, con **parada** si la captura o la custodia no pueden acreditarse antes de continuar.

**Distribución temporal vinculante.** Antes de activar WP-005 solo se exige que la política esté definida en un contrato aprobado y verificable. La implementación y las pruebas roja/verde ocurren durante WP-005; hasta que pasen, no se toca el ruleset ni se cierra el WP. En el punto 3, «elección probada» se interpreta conforme a esta secuencia.

**Los tres estados de `check_scope`, que no deben fundirse.** *(1)* **ejecutable local** creado por WP-002, que invocan a mano el operador y los revisores y **no bloquea ninguna fusión**; *(2)* **job ejecutándose en CI** por WP-005, **todavía no requerido**, que puede ponerse rojo pero **no impide fusionar**; *(3)* **check incorporado a `required_status_checks`** por una persona, único estado que **bloquea la fusión**. «Bloqueante para la fusión» se reserva **en exclusiva** al estado 3. **Hoy no existe ninguno de los tres.**

**Fuera de la columna `ACTIVE`, porque no son WPs.** El humo seguro **no** es un estado de `ACTIVE`: es **alcance de WP-008**. El parche del guard delgado es un **acto de operador** sobre ruta vedada. El **cierre de la pausa** es una **PR de operador con `ACTIVE` en reposo**. Y el experimento **E2** del sandbox y su eventual **WP T3** de adopción **no tienen identificador reservado**: mientras se resuelven, `ACTIVE` sigue en reposo, y **no pueden ejecutarse** hasta que una decisión o enmienda posterior fije su `WP-NNN`, apruebe el contrato y lo admita en la lista cerrada de DEC-003 §4.


**Los cierres bloqueados de WP-009 y WP-013 y, después, WP-014 precedieron a
WP-008**, al revés que en la secuencia anterior. WP-008 terminó también
`blocked` por DEC-009. La secuencia posterior queda detenida: los antiguos pasos
de WP-002, WP-005, guard delgado, WP-007 y E2 se conservan como plan histórico y
análisis, no como autorización ejecutable. **Un WP activo cada vez.** Mientras
`ACTIVE` esté vacío no hay ninguna ruta autorizada.

## Recuperación vigente tras DEC-011

DEC-011 supera la parada de **deliberación**: el rumbo ya está elegido. No
supera la parada **técnica** ni cierra la pausa. El contrato replanteado de
`WP-015` ya existe, está `ready` y queda admitido en la lista cerrada de
DEC-003. `ACTIVE` permanece en reposo: todavía no hay activación ni
implementación autorizada.

El orden futuro vinculante de dependencias es:

1. `WP-015`, sucesor limpio de WP-002, ya tiene contrato `ready` y está
   admitido para ejecución posterior; falta un acto humano separado que lo
   active antes de producir `check_scope` local y la biblioteca;
2. sucesor limpio de WP-005, autorizado por separado, para integrar el mismo
   verificador en CI; después, mutación humana del ruleset que lo haga requerido;
3. convergencia humana del guard sobre la misma biblioteca y cierre de WP-007
   por superación mediante PR de operador, con `ACTIVE` siempre en reposo y
   previa recomprobación y custodia de su candidata;
4. sucesor limpio de WP-008 para instalar el runtime fail-closed y realizar un
   humo seguro cuyo oráculo haya superado su Definition of Ready;
5. E2, con identificador y contrato aprobados por otra autorización; adopción
   T3 separada solo si el resultado es positivo;
6. PR humana de cierre de la pausa cuando se cumpla el criterio adaptado.

La lista fija dependencias. Esta composición autoriza únicamente la admisión de
`WP-015`; **no autoriza ejecutar ningún paso**. Cada WP exige contrato,
presupuesto, autorización, rama, PR y ciclos propios. La excepción temporal a
la igualdad de DEC-002 §8 comienza solo cuando una autorización posterior
active WP-015; cubre su implementación, verificación y fusión, y termina con la
convergencia del guard. Aprobación y admisión, sin activación, no inician esa
ventana.

### Gramática resuelta; WP-015 aprobado y admitido, activación pendiente

La primera candidata externa de WP-015 agotó dos correcciones con una
contradicción normativa abierta: la plantilla decía a la vez que eliminaba
anotaciones entre paréntesis y que los paréntesis eran literales. DEC-012
resuelve la contradicción fuera del WP:

- todo el contenido posterior a `- ` es el patrón;
- no existen comentarios ni anotaciones inline;
- `#`, paréntesis y backticks son literales;
- `docs/(draft).md` autoriza únicamente esa ruta;
- hasta converger el guard, los contratos vivos usan el subconjunto temporal
  compatible fijado por DEC-012.

La decisión no corrigió ni aprobó la candidata agotada, que se preserva con su
`NO APTO`. La PR #48 materializó el contrato replanteado y la PR #49 lo aprobó
como `ready`. Esta composición lo admite en DEC-003 sin modificar el contrato.
`ACTIVE` permanece en reposo: admisión no es activación y el WP no puede
implementarse hasta un acto humano posterior y separado.

El humo no se retira, pero su oráculo anterior queda retirado. Antes de aprobar
el sucesor de WP-008 debe existir una señal positiva y atribuible basada en
interfaces oficiales o un A/B que distinga denegación, fallo de herramienta,
interrupción, timeout y pérdida de registro. Ausencia de `PostToolUse` no basta;
una ambigüedad produce fallo o resultado inconcluso, nunca verde.

El cierre exige: runtime fail-closed, preflight bloqueante y humo seguro
concluyente; los diez pins ya cumplidos; `check_scope` local, en CI y requerido,
guard convergente y WP-007 resuelto; y E2 registrado, con adopción efectiva si
es positivo. La instalación posterior en `AI-Comercial-System` es una prueba
sobre producto distinta y no es condición de cierre.

**Detalle histórico del criterio bajo D1, DEC-008 y DEC-009, sustituido por la
adaptación de DEC-011 anterior.** El **criterio de salida sigue teniendo
tres condiciones**: WP-008 fusionado —protección instalada, con la demostración
de bloqueo que exija la rama de D6 resuelta—; **WP-014 fusionado, con exactamente
los diez pins autorizados y el criterio de verificación n.º 2 de REQ-FDA-002
vacío —condición cumplida por la PR #40—**; y, como tercera **sustituida por D1**, la que ahora se titula **«Control
de alcance concluyente y resolución del gate del sandbox»**: **humo seguro
dentro del alcance de WP-008** y registrado en `evidence/WP-008/`, ejecutado
**antes de cerrarlo** (incluido el caso `Read(/**/.env*)` frente a `.env` en la
raíz) **+** `check_scope` **ejecutándose en CI** sobre una librería única de
matching, que construyen WP-002 y WP-005, **e incorporado a
`required_status_checks`** —único momento desde el que **bloquea la fusión**—
**+** el experimento **E2 ejecutado y su resultado registrado**, con adopción
por un WP T3 **cuyo identificador todavía no existe** solo si supera el gate.
Los cierres bloqueados de WP-009 y WP-013 no satisfacen la segunda condición.
El cierre bloqueado de WP-008 no satisface la primera ni el humo de la tercera.
WP-012 queda **liberado como condición de salida**: conserva identificador e
historia y no se ejecuta su runner por analogía.


**Qué es un «humo seguro».** El ensayo se monta sobre un **proyecto desechable y aislado, físicamente fuera de la raíz de FDA**, con un **`.env` sintético de contenido marcador y cero secretos reales**. Está **prohibido crear, leer o modificar cualquier `.env`, secreto o archivo real de FDA**; la evidencia se registra **saneada**; y la limpieza se limita a los **recursos propios del ensayo**. Un humo que incumpla esto **no vale como evidencia**.

**Un E2 negativo no es una garantía.** Si E2 no supera su gate, la condición se cumple con sus dos primeras partes, pero **no se materializa ninguna garantía del sistema operativo**: la arquitectura objetivo sigue **incompleta**, la garantía del kernel **solo existe tras la adopción efectiva** del sandbox, y **cerrar la pausa tras un E2 negativo no autoriza a describir la capa 2 como conseguida**.


**Ninguna de las tres partes demuestra la semántica general del runtime, y el criterio no lo afirma.** El humo seguro acredita un caso concreto; `check_scope` acreditará que ninguna escritura fuera de alcance sobrevive al diff cuando exista; y la tercera parte acredita que el gate del sandbox se resolvió. La garantía de kernel solo aparecería tras instalar, superar el gate y adoptar efectivamente el sandbox.

El **WP de mantenimiento de alcance mínimo** descrito más arriba sigue siendo el protocolo general y legítimo para reparar el gobierno cuando el fail-closed lo bloquea. **Para esta pausa concreta, el operador ha decidido no emplear esa vía** y ha elegido **preparación en solo lectura más materialización humana**: los contratos de los WPs admitidos se redactan sin escribir en el repositorio, y los materializa y activa el operador.

## Qué hacer con un WP bloqueado

```bash
sed -i '' 's/^estado: .*/estado: blocked/' work-packages/WP-014-*.md
```

Documenta el bloqueo en el propio WP —qué lo bloquea y qué se necesita— y deja constancia en `evidence/WP-014/`. El estado vive en archivos: si solo está en el chat, se pierde.
