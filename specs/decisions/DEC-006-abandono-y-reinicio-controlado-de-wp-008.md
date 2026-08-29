# DEC-006 — Abandono y reinicio controlado de la cadena de WP-008

**Estado:** aceptada · **Fecha:** 2026-08-29 · **Ámbito:** el intento interrumpido de
`WP-008`, su PR de implementación, la custodia de S1, la contabilidad de ciclos, la
secuencia excepcional de `ACTIVE` y las condiciones para un único reintento limpio
**Origen:** la barrera roja del run real `33246993973`, las dos auditorías técnicas
independientes posteriores y las autorizaciones expresas del operador del 2026-08-29.
**Preparación:** este borrador se redactó fuera del repositorio. No materializa por sí
mismo ninguna decisión, no modifica la PR #24 y no ejecuta la recuperación.

## Problema

El paso 4 de `DEC-005` §13 se interrumpió después de publicar `C_ROJO` y antes de
aplicar la fase verde. La barrera roja se detuvo correctamente con exit `1`: la
composición de la ejecución real no coincidía con la que el contrato describía.

Estado exacto del intento que se abandona:

| Magnitud | Valor |
|---|---|
| `main` y `origin/main` | `b485214574abcf3beb1bd023c9ad98b4bbc1c043` |
| Rama congelada | `wp/WP-008-runtime-fail-closed` |
| `HEAD`, rama remota y `C_ROJO` | `f745b5d15b269f2dbc34b9716a07eea9cf4a7dd0` |
| Distancia respecto de `main` | exactamente un commit por delante |
| PR | [#24](https://github.com/ivanes189/fda-template/pull/24), abierta como borrador, sin fusionar |
| Run rojo | [33246993973](https://github.com/ivanes189/fda-template/actions/runs/33246993973), `failure`, `headSha = C_ROJO` |
| Par real | S1: `settings.json` en ANTES y `ci.yml` en DESPUÉS rojo |
| Marcadores | `ACTO1_OK` presente; `BARRERA_ROJA_OK`, `ACTO3_OK` y `BARRERA_VERDE_OK` ausentes |
| Índice y cambios rastreados | vacíos |

La persona autorizó expresamente **abandonar esta cadena**, conservar PR, rama,
commit y custodia como evidencia, no ejecutar el acto 3 y preparar un plan de
recuperación sin reescritura de historial.

## Causa raíz

### 1. La barrera hizo su trabajo

La barrera no produjo un falso rojo ni debe eludirse. Detectó que la condición 6
del contrato —«los pasos posteriores del mismo job están en `skipped`»— incluía
también pasos internos añadidos por GitHub, que no son pasos declarados del
workflow y tienen otra semántica legítima.

La forma real observada fue:

| Posición relativa | Paso | Conclusión |
|---|---|---|
| housekeeping previo | `Set up job` | `success` |
| declarado | `Run actions/checkout@v4` | `success` |
| declarado | `Run actions/setup-python@v5` | `success` |
| declarado | `Instalar PyYAML` | `success` |
| declarado | `Archivos de gobierno presentes` | `success` |
| declarado | `El hook guard.sh es ejecutable` | `success` |
| declarado | `Configuración del runtime fail-closed (preflight)` | `failure` |
| declarado | `Estado operativo coherente (ACTIVE)` | `skipped` |
| declarado | `El guard bloquea fuera de alcance (suite completa)` | `skipped` |
| declarado | `Workflows válidos` | `skipped` |
| declarado | `Manual sin enlaces rotos` | `skipped` |
| declarado | `El manual acompaña a los cambios de proceso` | `skipped` |
| housekeeping posterior | `Post Run actions/setup-python@v5` | `skipped` |
| housekeeping posterior | `Post Run actions/checkout@v4` | `success` |
| housekeeping posterior | `Complete job` | `success` |

La numeración `23`, `24` y `25` de los tres últimos pasos es un detalle del runner
y no forma parte de la garantía. Sí forman parte de ella sus nombres exactos,
conclusiones exactas y orden relativo.

### 2. El contrato y los fixtures no modelaban la forma real

El defecto es contractual antes que de implementación:

1. La condición 6 trataba cualquier paso posterior como declarado y exigía
   `skipped`, en lugar de distinguir mediante oráculos cerrados los pasos del
   workflow y el housekeeping del runner.
2. La condición 4 tenía el defecto simétrico: comprobaba las conclusiones de los
   pasos presentes, pero no exigía positivamente que estuviera el conjunto
   declarado completo y en orden.
3. Los fixtures de CI representaban una forma idealizada: no incluían `Set up
   job`, `Post Run ...` ni `Complete job`.
4. La adquisición no capturaba ni validaba que el evento fuese `pull_request`,
   aunque la ejecución roja contractual solo nace al abrir la PR.
5. El conjunto de jobs tampoco se exigía positivamente, de modo que un job
   declarado ausente podía pasar sin ser observado.

Corregir el comprobador dentro de la rama publicada añadiría un commit intermedio
y convertiría la cadena final en cuatro commits, o rompería la ascendencia directa
`C_ROJO` → `C_VERDE`. Ambas vías contradicen el contrato. Fabricar
`BARRERA_ROJA_OK` sería eludir una prueba bloqueante. Por eso el intento no es
recuperable dentro de su cadena de tres commits.

## Custodia recuperable del intento abandonado

El paquete consumido y toda su custodia se copiaron, sin mover el original, desde:

`/private/tmp/wp008-operacion-humana-s1`

a la ubicación estable externa al repositorio:

`/Users/ivan/Desktop/fda-template-respaldo-WP-008-intento-abandonado-20260829`

Las dos raíces tienen modo `700`. Ambas contienen **30 archivos y 2
subdirectorios**, cero enlaces simbólicos y cero entradas especiales. Tipos,
modos, tamaños y bytes coinciden. Las nueve huellas de `SHA256SUMS` dan `OK` en
ambas. El digest independiente del manifiesto completo de los 30 archivos es:

`f8d67999c5f258aa468d6f9ad115b6ed6256b52914e36e58beb007f9124d22b9`

Finder conservó propietario, modos y bytes, y asignó a la copia el grupo ordinario
del Escritorio (`20`) en lugar del grupo del temporal (`0`). El grupo no forma
parte del manifiesto contractual y no altera accesibilidad ni integridad.

`verificar-paquete.sh` devuelve en las dos raíces el mismo único fallo esperado:
la custodia tiene 21 entradas y el paquete era de un solo uso. Ese resultado
acredita que fue consumido; **el paquete no se reutiliza**.

### Manifiesto cerrado

| Ruta relativa | Tipo | Modo | SHA-256 |
|---|---|---:|---|
| `00-LEEME-PRIMERO.md` | regular | `600` | `f56144a6ee63cd6eafa1c5ae9d7d20c76ff3391928ab3f7ee4a4227a60436210` |
| `01-ROJO-Y-CROJO.command` | regular | `700` | `6ae7178e4df7c9ea2ddc0511aa3ee682d955171afbcb546ec16205ea7dbe01dd` |
| `02-BARRERA-ROJA.command` | regular | `700` | `05201af7081c682c10f8199153d55414b18e18c53d0cbdc59c9323d7863c3df2` |
| `03-VERDE-Y-CVERDE.command` | regular | `700` | `e072732047de4c6745b41795150daebace32108a20327272e19c4c0b68fff5c7` |
| `04-BARRERA-VERDE.command` | regular | `700` | `a0099c16acaf7a151622ecf4559107e3e5ed279bb8c760110b1fa9ff0ad258c7` |
| `90-PARADAS-Y-RECUPERACION.md` | regular | `600` | `4de484c69daa0473e6b3dc0ab82f60145d921914b59291235f94723f752822c1` |
| `MANIFIESTO.md` | regular | `600` | `1460a0a4d07f246e3bd3028f88935865e689930260cd9de5e3f5593e0888cb33` |
| `RUTAS-CROJO.txt` | regular | `600` | `75ff5b73adf72c15305223f124b6b4f786a45675312aa4ab653e1d07fbcd3f7f` |
| `SHA256SUMS` | regular | `600` | `d553d728918bf8cf70935d82cec400b713d0f1c386063927ee4d0bc638bdeb08` |
| `custodia` | directorio | `700` | — |
| `custodia/01-fase-roja.log` | regular | `644` | `c6d72a67a7f86449ad1c1771a445a650eb1d81473fe5b1f0a0908080787d1395` |
| `custodia/01-fase-roja.salida.txt` | regular | `644` | `6fe884cefbd5748e9f78c868be1e52c7fa18700f34098fe234d2839912c671f0` |
| `custodia/02-rojo-idempotente.log` | regular | `644` | `6616386db9d7779fc4795f27add25a1564d548a6d84a1fcf241fd10a4db5bb84` |
| `custodia/ACTO1_OK` | regular | `644` | `bee830acf14d611558633d8a9e57f9cf153754a02f539878306569159bfa9f30` |
| `custodia/C_ROJO-rutas.nul` | regular | `644` | `74cc8ed3e8086bf1682d4d7c7ff707523acadc7ec9bce3586fda3dbe4d06a171` |
| `custodia/barrera-roja.salida.txt` | regular | `644` | `991abf4d53c5be05f0145defd5c467dc384faacdf5413d5b08bac688b61379ab` |
| `custodia/captura-roja` | directorio | `700` | — |
| `custodia/captura-roja/captura-rojo.log` | regular | `644` | `0fcd6f513c847ff54cf835a94657c020a770a3d131cbe8acdc5785ae3334ec6c` |
| `custodia/captura-roja/run-rojo.json` | regular | `644` | `199d458c01bd21e3f976d82fc3125088683819b7c97cff44df71b9630c45214b` |
| `custodia/commit-C_ROJO.log` | regular | `644` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `custodia/diff-post-commit-C_ROJO.log` | regular | `644` | `f3a57ce93269bf29b41d13d66009a5dc06ffb1ac6c51d6a832c6826df1d570b0` |
| `custodia/documentos-actuales.txt` | regular | `644` | `0539ab43635ad0968bed1bc4265b9c12867a47d289b77dc005c6c32ab0b66636` |
| `custodia/documentos-esperados.txt` | regular | `644` | `0539ab43635ad0968bed1bc4265b9c12867a47d289b77dc005c6c32ab0b66636` |
| `custodia/esperado-C_ROJO.nul` | regular | `644` | `74cc8ed3e8086bf1682d4d7c7ff707523acadc7ec9bce3586fda3dbe4d06a171` |
| `custodia/push-C_ROJO.log` | regular | `644` | `0289230e1cb8858b3ff3347f8df5fcc91cb10ccf3f7f58fa42e4c7cd3fa32151` |
| `custodia/registro.log` | regular | `644` | `6cb942acd77293454afb06626ec9cd6c9175420b326fde1809558c383df80f30` |
| `custodia/runtime-actual.txt` | regular | `644` | `a6617969836570c1ede50e10b3f390dff3c7267200c70b65bbe6812e8e33d4b1` |
| `custodia/runtime-esperado.txt` | regular | `644` | `a6617969836570c1ede50e10b3f390dff3c7267200c70b65bbe6812e8e33d4b1` |
| `custodia/staged-C_ROJO-revalidado.nul` | regular | `644` | `74cc8ed3e8086bf1682d4d7c7ff707523acadc7ec9bce3586fda3dbe4d06a171` |
| `custodia/staged-C_ROJO.log` | regular | `644` | `ebd074f801afb7f7f3649a5458764ec0d0c9e86be812c78f6ab7476b284cc1af` |
| `custodia/staged-C_ROJO.nul` | regular | `644` | `74cc8ed3e8086bf1682d4d7c7ff707523acadc7ec9bce3586fda3dbe4d06a171` |
| `verificar-paquete.sh` | regular | `700` | `74f31cc0bf6b2b54c93f0f19ed4dd80b856e67fa84e11f4b7293427afdb880c9` |

## Condición de admisibilidad

Esta decisión solo es admisible si su creación, la incorporación nominal de
`DEC-006` a la lista cerrada de `DEC-003` §4, el ajuste de `DEC-005`, la
actualización del manual y `ACTIVE` a reposo viajan **en el mismo diff atómico**.
Si la modificación de `DEC-003` no viaja en ese mismo diff, esta decisión no es
admisible y no debe fusionarse. El borrador externo de la PR no sustituye esta
condición versionada.

## Decisión

### 1. La cadena publicada queda abandonada y congelada

No se ejecuta el acto 3, no se fabrica ningún marcador, no se añade ningún commit,
no se hace `amend`, `rebase`, force-push ni reescritura. La PR #24 se cerrará **sin
fusionar** después de que esta decisión se materialice. La rama remota y
`f745b5d15b269f2dbc34b9716a07eea9cf4a7dd0` se conservan como referencia de la
evidencia real.

Conservar la rama remota es una **desviación expresa** respecto de la cláusula de
rollback vigente, que ordena borrarla tras cerrar la PR. Se aprueba porque borrarla
reduciría la trazabilidad del único run rojo real. La excepción solo cubre esta
rama abandonada; no autoriza trabajo ni nuevos commits sobre ella.

### 2. Las reaperturas durante S1 se registran como desviaciones

Después de la parada se reabrieron sesiones de agente para que la persona, que no
dispone de otro apoyo técnico, pudiera entender el bloqueo y preparar una decisión.
Las dos primeras fueron:

- `S1-001`: auditoría de Codex tras la parada de la barrera roja.
- `S1-002`: segunda opinión independiente de Claude Code.

Después de la autorización expresa de abandono hubo además sesiones de Codex y
Claude Code dedicadas exclusivamente a redactar, contrastar y corregir estos
borradores externos. Todas fueron de solo lectura respecto del repositorio: cero
Git mutable, cero avance de la cadena y cero ejecución de los lanzadores. Aun así,
el texto vigente reservaba S1 a operación humana y prohibía cualquier sesión, no
solo las escrituras. Por tanto **todas las sesiones de auditoría abiertas desde la
parada y hasta materializar la PR A** se registran como desviaciones
procedimentales, no como actuaciones plenamente conformes.

La relación cronológica se cierra al materializar A y se incorpora más adelante a
`evidence/WP-008/historico/intento-1-abandonado.md`, junto con las referencias a
los artefactos externos de revisión; no se copian prompts ni respuestas íntegras.
Este registro abierto evita que cada revisión del propio borrador obligue a fingir
que la lista ya era final. La autorización posterior de abandono permite auditar
y planificar la recuperación, pero no cambia retroactivamente el contrato vigente.

El contrato corregido distinguirá en adelante dos estados:

1. **S1 operativo:** ninguna sesión de agente.
2. **S1 detenido:** solo tras una salida de parada del paquete, se permiten
   auditorías de agente estrictamente de solo lectura para explicar y preparar una
   decisión humana. No permiten reanudar la cadena, ejecutar la fase verde ni
   realizar red o Git mutable.

### 3. Contabilidad conservadora y presupuesto nuevo

No existe un archivo versionado del que pueda derivarse cuántos de los dos ciclos
propios del contrato reducido se consumieron durante la preparación. No se fabrica
esa evidencia. El operador resuelve conservadoramente el vacío y declara el
intento abandonado **agotado: 2 / 2**.

Esta cifra es una **decisión de gobierno**, no un hallazgo auditado. No borra ni
renumera los once ciclos del contrato anterior que registra `DEC-005`, ni ninguna
pasada real de este intento.

La causa contractual y el abandono se clasifican como replanificación conforme a
la causa raíz n.º 1 de `docs/manual/05-bloqueos-y-parada.md` §8: contrato mal
definido, por tanto se reescribe antes de continuar.

Se concede al contrato corregido y a la rama
`wp/WP-008-runtime-fail-closed-r2` un presupuesto **nuevo, explícito y máximo de
dos ciclos de corrección**. El cómputo será:

- La implementación inicial no consume ciclo.
- Se consume un ciclo cuando, después de una pasada completa, una revisión
  independiente o una validación contractual exige cambios y la persona abre una
  nueva pasada de edición para resolverlos.
- Corregir y revalidar el mismo hallazgo dentro de esa pasada no abre otro ciclo.
- Una petición nueva, posterior al cierre de la pasada, abre el siguiente ciclo.
- Una parada de operación humana no se recategoriza por conveniencia: se aplica su
  contrato de parada y exige decisión.
- El tercer ciclo vuelve a requerir otra decisión humana, nueva, fechada y
  versionada.

La cifra final `N / 2` y la relación de ciclos se incorporarán en
`evidence/WP-008/cost.md`, dentro de `C_EVIDENCIA`. El contrato corregido hará esa
fila nominal y obligatoria.

### 4. Reposo y tres PRs de operador

La recuperación usa tres PRs de operador, cerradas y separadas:

| PR | Composición exacta |
|---|---|
| **A — decisión y reposo** | esta `DEC-006`; admisión atómica en `DEC-003` §4; ajuste de `DEC-005` §13; actualización de `docs/manual/05-bloqueos-y-parada.md`; `ACTIVE` a reposo |
| **B — contrato** | exactamente `work-packages/WP-008-runtime-fail-closed.md` |
| **C — activación** | exactamente `work-packages/ACTIVE`, escribiendo `WP-008` |

La PR A devuelve inmediatamente `ACTIVE` a reposo, byte a byte idéntico a
`8190976`, con SHA-256
`7daa77261f1dbda06f35b5681e7e1b54967a84de6e0b5a6b530d6a9faad878ff`.
Es una transición excepcional desde un WP interrumpido, no su cierre exitoso.

La PR B mantiene la precondición de cardinalidad: el contrato se materializa,
valida y aprueba en un diff de **un solo archivo**. Ninguna evidencia ni cambio de
implementación viaja con él.

La PR C se crea solo después de que la nueva rama exista desde el `origin/main`
posterior a B y se hayan verificado las precondiciones 1 y 2 y la precondición 3
en su estado inicial. La precondición 4 la satisface la propia PR C. Después de
fusionar C, la rama nueva avanza por fast-forward y se vuelven a demostrar las
precondiciones 3 y 4 sobre el estado final, con la rama **exactamente igual** al
`origin/main` posterior a la activación.

### 5. Una sola rama y una sola PR vivas

La excepción a «un WP = una rama = una PR» preserva su finalidad:

- Como máximo existe **una rama de WP-008 habilitada para trabajo** y **una PR de
  implementación abierta**.
- La rama original queda congelada y su PR se cierra antes de activar el reintento.
- La rama nueva se llama `wp/WP-008-runtime-fail-closed-r2`.
- Crear la rama nueva no abre la PR. La nueva PR en borrador se abre solo después
  de publicar el nuevo `C_ROJO`, porque el evento `pull_request` es lo que dispara
  el run contractual.
- Ningún commit se copia mediante cherry-pick: el contenido se reconstruye sobre
  el `origin/main` actualizado para producir una cadena nueva de tres commits.

### 6. Forma real cerrada y fail-closed

El contrato corregido debe exigir simultáneamente:

1. Adquisición del campo `event` y valor exacto `pull_request` para el run rojo.
2. Conjunto exacto de jobs: `Gobierno FDA`, `Lint · Shell · Tests · Manual` y
   `Escaneo de secretos`; falta o sobra uno, exit `2` por forma desconocida.
3. Oráculos positivos y ordenados de los pasos declarados anteriores y
   posteriores al preflight. Falta, sobra, duplicación o versión distinta, exit
   `2` por forma desconocida.
4. Housekeeping previo exacto: `Set up job` → `success`.
5. Housekeeping posterior exacto y en orden: `Post Run
   actions/setup-python@v5` → `skipped`; `Post Run actions/checkout@v4` →
   `success`; `Complete job` → `success`.
6. Los campos `number` no se usan como oráculo.
7. Forma desconocida, exit `2`; forma conocida con conclusión no conforme, exit
   `1`; composición exacta, exit `0`.
8. La comprobación de segunda causa sigue recorriendo todos los pasos de todos los
   jobs, incluido el housekeeping.
9. Un fixture sintético reproduce la forma real sin copiar como fixture la
   captura real. La captura real abandonada se conserva solo como evidencia
   histórica.

La fijación exacta de `@v4` y `@v5` crea un acoplamiento deliberado con WP-009: al
fijar esas acciones por SHA cambiarán los nombres de los pasos internos. Ese cambio
debe abortar cualquier reutilización del oráculo y quedar advertido en el futuro
contrato de WP-009; no se amplía automáticamente ningún patrón.

## Secuencia autorizada

| # | Actor | Acto |
|---|---|---|
| 1 | Humano | Materializar y fusionar la PR A. `ACTIVE` queda en reposo |
| 2 | Humano | Cerrar PR #24 sin fusionar, comentar el enlace a esta decisión y conservar la rama remota |
| 3 | Humano | Materializar, validar y fusionar la PR B de un solo archivo |
| 4 | Humano | Crear `wp/WP-008-runtime-fail-closed-r2` desde el `origin/main` posterior a B, sin abrir PR |
| 5 | Humano | Antes de C, verificar las precondiciones 1 y 2 y la precondición 3 en su estado inicial: `-r2` exactamente igual al `origin/main` posterior a B |
| 6 | Humano | Materializar y fusionar la PR C, solo `ACTIVE` ← `WP-008`; este acto satisface la precondición 4 |
| 7 | Humano | Avanzar `-r2` por fast-forward hasta el `origin/main` posterior a C y volver a demostrar conjuntamente las precondiciones 3 y 4 sobre el estado final activado |
| 8 | Agentes y humano | Implementar, revisar manualmente y ejecutar la batería A sobre el estado definitivo |
| 9 | Humano | Ejecutar la nueva fase roja, crear y publicar el nuevo `C_ROJO` |
| 10 | Humano | Abrir la nueva PR de implementación en borrador; comprobar `event=pull_request` |
| 11 | Humano | Ejecutar la barrera roja; continuar únicamente con exit `0` |
| 12 | Según contrato | Fase verde, barrera verde, `C_EVIDENCIA`, revisión y fusión humana |
| 13 | Humano | Devolver `ACTIVE` a reposo mediante su acto de operador de cierre |

Sobre la rama congelada no se hace checkout, commit, push ni modificación. Si
hace falta leer una ruta histórica, se usa `git show HASH:RUTA` sin desplegarla en
un worktree.

## Qué no autoriza esta decisión

1. No modifica por sí misma el repositorio ni la PR #24.
2. No permite ejecutar el acto 3 del paquete consumido ni reutilizar ese paquete.
3. No permite corregir, completar o fusionar `f745b5d`.
4. No permite cerrar PR #24 antes de fusionar la PR A.
5. No permite abrir la nueva PR antes del nuevo `C_ROJO`.
6. No activa WP-008: la activación es la PR C posterior y separada.
7. No permite un tercer ciclo del contrato corregido.
8. No altera WP-007, WP-009, WP-010, WP-011 ni WP-012; no reactiva workflows de
   agente, no modifica el ruleset y no levanta la pausa.
9. No convierte la captura abandonada en fixture ni presenta la resolución `2 / 2`
   como una medición que el repositorio no contiene.

## Consecuencias

**A favor.** Se conserva la única observación de forma real; la barrera sigue
siendo bloqueante; el reintento nace de `main` sin historia reescrita; y la forma
del runner pasa a tener oráculos positivos, cerrados y fail-closed.

**En contra.** La recuperación exige tres PRs de operador antes de volver a
implementar y una nueva cadena roja/verde/evidencia. Es coste real de calendario,
aceptado para no convertir una excepción conversacional en una garantía falsa.

**Riesgo residual.** GitHub puede cambiar en el futuro los nombres o la semántica
de sus pasos internos. La respuesta contratada es exit `2` y replanificación, no
aceptación automática.

**Punto de control.** El 2026-09-07 de `DEC-003` y `DEC-005` no cambia. Si llega sin
cumplirse el criterio de salida, se practica la revisión y el análisis por escrito
que esas decisiones exigen.

## Referencias

- [`DEC-003`](DEC-003-pausa-migracion-y-contencion.md) — pausa, lista cerrada y secuencia de `ACTIVE`
- [`DEC-005`](DEC-005-troceado-de-wp-008-y-revision-de-la-pausa.md) — troceado, aislamiento y paso 4 interrumpido
- [`work-packages/WP-008-runtime-fail-closed.md`](../../work-packages/WP-008-runtime-fail-closed.md) — contrato a corregir en la PR B
- [`docs/manual/05-bloqueos-y-parada.md`](../../docs/manual/05-bloqueos-y-parada.md) — causa raíz y protocolo de parada
- [PR #24](https://github.com/ivanes189/fda-template/pull/24) — intento abandonado, no fusionado
- [Run 33246993973](https://github.com/ivanes189/fda-template/actions/runs/33246993973) — observación roja real preservada
