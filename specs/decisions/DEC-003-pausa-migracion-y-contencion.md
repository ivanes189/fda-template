# DEC-003 — Pausa de la migración de DEC-002 y contención del carril automático

**Estado:** aceptada · **Fecha:** 2026-08-03 · **Ámbito:** la migración de [`DEC-002`](DEC-002-semantica-de-traversal.md), el estado de `work-packages/ACTIVE`, los workflows de agente y las adaptaciones de otros runtimes presentes en el árbol de trabajo
**Origen:** contraste de dos auditorías independientes sobre `36cb46c`, verificado sobre el repositorio y sobre GitHub el 2026-08-03.
**Enmendada el 2026-09-09 por [`DEC-007`](DEC-007-punto-de-control-y-rumbo.md):** §§1, 2, 4, 5, 6 y 7. D1, D2, D3, D4 y D6 quedan ratificadas; D5 queda resuelta por su default, sin acuerdo formal. La enmienda entra en vigor en el mismo diff atómico que crea DEC-007.

## Problema

La migración de DEC-002 va por PR-2 de cuatro. La secuencia es correcta y no se discute. Lo que ha cambiado es lo que se sabe del suelo sobre el que se apoya.

### 1. El guard falla abierto: mecanismo demostrado, materialización no demostrada

`.claude/settings.json` invoca el hook por ruta relativa. `PreToolUse` solo bloquea con exit `2`; cualquier otro código deja pasar la herramienta.

| Invocación | Código | Efecto |
|---|---|---|
| Raíz, ruta absoluta, escritura a ruta prohibida | `2` | Bloquea |
| Desde un subdirectorio, invocación relativa tal como está en `settings.json` | `127` | No bloquea |

**Demostrado:** el mecanismo. La invocación relativa produce 127 y 127 no bloquea. **No demostrado:** que Claude Code cambie de directorio de trabajo durante una sesión, es decir, que el fallo se haya materializado alguna vez. La distinción se mantiene y no se resuelve por conveniencia.

No cambia la decisión, porque otros dos modos del mismo fallo **no dependen del `cwd`**: hook ausente (`127`) y hook sin permiso de ejecución (`126`).

### 2. REQ-FDA-002 incumplido

Diez apariciones `uses:`, cuatro acciones únicas, ninguna fijada por SHA. El propio requisito lo registra en su tabla «Verificación actual» desde 2026-07-23.

### 3. El revisor automático nunca ha revisado

Once ejecuciones de `code-review.yml`: 6 fallos (2026-07-23) y 5 éxitos (2026-07-28 → 2026-08-01). Las cinco PRs correspondientes —#2, #4, #5, #6, #7— tienen **0 reviews y 0 comentarios del bot**; el único comentario, en la #6, es humano. Cinco de cinco falsos verdes, consumiendo Opus por PR.

### 4. Permisos amplios sobre una referencia mutable

Dos afirmaciones distintas, que no deben mezclarse:

- **Control actual.** `anthropics/claude-code-action` exige por defecto que el actor que dispara la ejecución tenga **permiso de escritura** en el repositorio. Un comentarista sin ese permiso no obtiene ejecución.
- **Riesgo.** Ese control no está versionado aquí, no figura en la tabla de controles del manual, y la acción se referencia por **etiqueta mutable** (`@v1`) mientras el job concede `contents: write`, `pull-requests: write`, `issues: write` y acceso a `ANTHROPIC_API_KEY`. El repositorio es público.

### Por qué obliga a pausar

WP-007 y WP-002 existen para que el alcance se enforce de verdad. Apoyar más trabajo sobre un guard que falla abierto y una cadena de suministro mutable produce **la apariencia** de enforcement. Son riesgos de integridad del sistema de control, no del contenido de DEC-002.

## Decisión

### 1. La migración queda pausada tras PR-2; WP-007 queda congelado

**Estado oficial:** `main` sigue en `36cb46c` y **WP-007 sigue `ready`**. Esta decisión no cambia su estado contractual. WP-002 permanece `blocked`.

**Foto histórica de la secuencia de `DEC-002`.** El contrato original de `WP-007` previó **PR-3** —su implementación— y **PR-4** —PR de operador que marcaba `WP-007` `done`, devolvía `WP-002` a `ready` y escribía **`ACTIVE` ← `WP-002`**—. **Así estaba previsto, y así se conserva: como historia.** No se borra.

**Estado posterior al punto de control [enmienda de `DEC-007`].** Esas dos PR **ya no son la secuencia ejecutable**. La enmienda de §2 sitúa la resolución de `WP-007` **después** de `WP-002` y `WP-005`, de modo que **la PR-4 original queda obsoleta**: intenta **devolver el control a `WP-002`**, que para entonces estará **`done`** desde la fila 6, y reescribiría hacia atrás su estado contractual. En consecuencia, **bajo la rama de ejecución (21-B) la PR-4 debe retirarse o sustituirse durante la corrección previa del contrato**, y **bajo la rama de superación (21-A) no se ejecuta**, porque `WP-007` se cierra por superación con `ACTIVE` en reposo. La **historia queda etiquetada como historia** y **separada de la secuencia vigente propuesta**.

**Inventario del trabajo preexistente, no versionado.** Existe en un worktree separado una **implementación candidata de WP-007, aplicada localmente y sin versionar**:

| Elemento | Estado |
|---|---|
| Rama `wp/WP-007-semantica-de-traversal` | Existe. **0 commits** por delante de `main`. Sin PR abierta |
| Worktree | Árbol de trabajo sucio: `.claude/hooks/guard.sh`, `tests/guard/run-suite.sh` y `docs/manual/05-bloqueos-y-parada.md` modificados; `evidence/WP-007/` sin versionar |
| Naturaleza | Candidata local. **No es un WP terminado, ni revisado, ni APTO** |
| Registro interno | `evidence/WP-007/14-desviacion-de-control.md` es un registro **sin versionar** y no constituye norma. La norma aplicable es `CLAUDE.md`, el manual versionado y el propio contrato de WP-007 |

**Qué le falta para poder ser APTO** —los cuatro, sin excepción:

- [ ] `evidence/WP-007/cost.md`, conforme al contrato de WP-007 y a las decisiones de coste vigentes cuando se reanude. Actualmente el contrato remite a `DEC-001`; antes del APTO deberá comprobarse además su conformidad con `DEC-004`, que según la secuencia se aprobará durante la pausa. Hoy el archivo está ausente.
- [ ] La **evidencia postcommit** (`git diff --name-status -M main...HEAD`), que solo dice algo una vez que la rama tenga commit propio. Hoy ausente.
- [ ] La **revisión exigida** por el contrato del WP.
- [ ] **Reconciliar `evidence/WP-007/PENDIENTE-HUMANO.md` con los logs 15–22.** Su checklist los marca como pendientes, pero los ocho existen y terminan en `0`. Un registro que contradice sus propias evidencias no puede sostener un veredicto APTO.

**Huella de congelación — siete magnitudes.** Medidas el 2026-08-03 sobre el worktree, **recalculables en cualquier momento sin escribir nada**:

| # | Magnitud | Valor |
|---|---|---|
| 1 | `HEAD` completo | `36cb46c0e854cca66063a5b59cefcd2665c373f1` |
| 2 | Cambios en el índice (staged) | **ninguno** |
| 3 | Archivos rastreados modificados | **exactamente 3** |
| 4 | Archivos bajo `evidence/WP-007/` | **exactamente 32** |
| 5 | SHA-256 del diff binario de los 3 rastreados | `156f69e72061ae7b7203fea469986237d970da956db063b3758d3e30ad9580d9` |
| 6 | SHA-256 agregado del árbol `evidence/WP-007/` | `28db13fa58ffa69714bfca972db9228d366e0d2e30cba207023902039b7e3490` |
| 7 | Entradas Git visibles / SHA-256 del estado Git | **exactamente 35** / `41475f734ebf0fd420dd928c076cbcaeaec8eae8bac10f23c9c6af0b0a54236a` |

Comandos de recálculo, todos de solo lectura, desde la raíz del worktree:

```bash
git rev-parse HEAD
git diff --cached --name-only | wc -l
git diff --name-only | wc -l
find evidence/WP-007 -type f | wc -l
git diff --binary | shasum -a 256
find evidence/WP-007 -type f -print0 | LC_ALL=C sort -z | xargs -0 shasum -a 256 | shasum -a 256
git status --porcelain=v1 -z -uall | tr '\0' '\n' | wc -l
git status --porcelain=v1 -z -uall | shasum -a 256
```

La magnitud 6 usa `-print0`, `LC_ALL=C sort -z` y `xargs -0` para ser estable ante espacios, saltos de línea en nombres y diferencias de locale, e incluye las rutas en el digest; hashear solo las sumas sin las rutas produce otro valor y no es esta huella.

**Qué aporta cada grupo, y por qué hacen falta los dos.**

- **La magnitud 7 vigila el conjunto de rutas.** `git status --porcelain=v1 -z -uall` enumera toda ruta Git visible, incluidas las no rastreadas una a una. Detecta la **aparición** de un archivo nuevo en cualquier punto del worktree —también fuera de `evidence/WP-007/`—, su **desaparición**, su paso a **staged**, y cualquier **cambio de clasificación** (`??` → ` M`, ` M` → `M `, etc.). Es la magnitud que cierra el hueco que las otras seis dejaban abierto.
- **Las magnitudes 5 y 6 vigilan el contenido.** `git status` informa de *qué* rutas están en qué estado, no de *qué hay dentro*. Una edición que deje un archivo igual de modificado no altera la magnitud 7 en absoluto. Por eso las huellas de contenido se conservan: sin ellas, una reescritura del parche o de una evidencia pasaría inadvertida.

Ninguno de los dos grupos sustituye al otro. Las siete magnitudes se comprueban juntas.

**Qué NO cubre la huella.** Las siete magnitudes verifican `HEAD` e índice; la clasificación y el conjunto de rutas Git visibles; los bytes de los cambios rastreados; y las rutas y los bytes de los 32 archivos de `evidence/WP-007/`. **No verifican los metadatos del sistema de archivos de los archivos sin versionar** —modo, permisos, propiedad, marcas temporales—: un cambio de modo sobre un archivo de evidencia dejaría las siete magnitudes intactas. A fecha de hoy los 32 archivos son regulares y tienen modo `0644`.

De ahí tres consecuencias, que no se sustituyen entre sí:

1. **Cualquier cambio de metadatos sigue prohibido por la congelación**, exactamente igual que un cambio de contenido. Que la huella no lo detecte no lo autoriza.
2. **Las huellas no deben presentarse como prueba de esos metadatos.** Acreditan contenido y clasificación Git, nada más.
3. **Antes de cualquier staging, al reanudarse WP-007, se comprobará en solo lectura** que los 32 archivos siguen siendo regulares y con modo `0644`:

   ```bash
   find evidence/WP-007 -type f ! -perm 0644 -print
   find evidence/WP-007 -type f | wc -l
   ```

   El primero debe devolver **vacío**; el segundo, **32**.

**Por qué una huella y no solo el estado de la rama.** «0 commits por delante» y «sin PR abierta» son necesarios pero **no suficientes**: ninguno observa el árbol de trabajo, que es donde vive todo el trabajo candidato. Una edición, un `restore` o un `stash` dejarían intactos ambos indicadores y romperían la congelación sin dejar señal.

**Congelación.** Mientras la pausa esté vigente, sobre WP-007 **no** se realiza: ninguna edición nueva, `git add`, `commit`, `stash`, `checkout`, `restore`, cambio de rama, `push`, apertura de PR ni fusión. El worktree queda exactamente como está. **Levantar la congelación exige una decisión humana posterior y separada**, que esta decisión no concede. Si alguna de las siete magnitudes difiere, la congelación se ha roto: **parada y análisis**, no actualización de la huella.

**Resolución prevista de WP-007 [enmienda de `DEC-007`].** La nueva secuencia de §2 resuelve WP-007 **por ejecución o por superación**, en un **acto separado y expresamente registrado**, después de que `WP-002` y `WP-005` hayan construido la librería única de matching y `check_scope`, y después del parche humano del guard delgado. Si se resuelve por ejecución, es una transición propia de `ACTIVE` a `WP-007`; si se resuelve por superación, es un acto de operador con `ACTIVE` en reposo. Hasta ese momento la congelación y sus siete magnitudes siguen intactas y **el estado contractual `ready` no cambia**: esta enmienda declara cuándo y cómo se resolverá, no lo resuelve ni levanta la congelación, que sigue exigiendo una decisión humana posterior y separada. Su candidata local se preserva como evidencia histórica.

### 2. Secuencia de `work-packages/ACTIVE` durante la pausa

`ACTIVE` queda **inicialmente** en reposo, y **no permanece vacío durante toda la pausa**. La secuencia completa, en este orden estricto, y cada transición un acto del operador humano:

**Invariante de `ACTIVE`, que ninguna secuencia puede romper.** El archivo `work-packages/ACTIVE` solo admite dos clases de contenido: **reposo** —vacío o solo comentarios— o **un único identificador existente con forma `WP-NNN`**. Cualquier otro contenido es un **estado incoherente**: `tests/governance/check-active.sh` lo rechaza con exit `1`, el job `Gobierno FDA` se pone en rojo y, por ser check obligatorio, **queda bloqueada toda fusión, incluida la que lo arreglaría**. Por eso esta sección **nunca** presenta como valor de `ACTIVE` una actividad, una descripción, un identificador provisional ni una combinación de dos WPs.

**Tres cosas distintas que no se mezclan en la misma tabla:**

- **Transición de `ACTIVE`** — el operador escribe reposo o un `WP-NNN` en el archivo. Es lo único que cambia `ACTIVE`.
- **Acto de operador** — PR de operador, parche humano sobre ruta vedada, custodia externa. **No** cambia `ACTIVE`.
- **Hito futuro no autorizado** — actividad prevista por la hoja de ruta que todavía **no tiene identificador ni contrato aprobado**. No cambia `ACTIVE`, que permanece en reposo, y su ejecución no está autorizada.

### 2.a Secuencia vigente bajo D1 y D6 ratificadas — transiciones de `ACTIVE`

| # | `ACTIVE` | Qué ocurre mientras | Condición para la transición siguiente |
|---|---|---|---|
| 1 | **Reposo** | Suspensión de WP-008-r2. Custodia externa de la candidata local; contrato breve de `WP-009` redactado, validado y aprobado por acto de operador | Contrato de `WP-009` aprobado |
| 2 | `WP-009` | Cadena de suministro: acciones fijadas por SHA | Cierre y fusión de WP-009 |
| 3 | **Reposo** | PR de operador de **un solo archivo** con el contrato de `WP-008` según la rama de D6 resuelta, que incorpora en su alcance el humo seguro de D1 y retira la equivalencia no medida de `WP008-F6` | Contrato de `WP-008` materializado, validado y aprobado |
| 4 | `WP-008` | Implementación del núcleo **y ejecución del humo seguro antes del cierre**, con evidencia en `evidence/WP-008/`. **Si el humo falla, WP-008 no se cierra**: se aplica el presupuesto de ciclos vigente de su contrato | Cierre y fusión de WP-008, **con el humo en verde** |
| 5 | **Reposo** | PR de operador que **corrige el contrato de `WP-002`** para sacarlo de `blocked`, lo valida y lo aprueba | Contrato de `WP-002` aprobado y en estado activable |
| 6 | `WP-002` | Librería única de matching y `check_scope` | Cierre y fusión de WP-002 |
| 7 | **Reposo** | PR de operador que **corrige integralmente** el contrato de `WP-005` y lo deja `ready`. No basta con cambiar el estado: debe resolver las **cuatro exigencias** de §2.d antes de que el WP pueda activarse | Contrato de `WP-005` **ejecutable**, validado y aprobado |
| 8 | `WP-005` | El agente prepara un **parche verificable** de `.github/workflows/ci.yml` y **una persona lo aplica** dentro de la rama y la PR de WP-005, **manteniendo `ACTIVE` en `WP-005`** y **sin relajar `permissions.deny`**. El job de `check_scope` queda **ejecutándose en CI como check todavía NO requerido**; se capturan el caso rojo, el verde, las validaciones y las revisiones. **Se fusiona la PR de implementación**, pero `WP-005` **no se marca `done`** y `ACTIVE` **no vuelve a reposo** | PR de implementación fusionada y el job **reportando desde `main`** |
| 9 | `WP-005` (**sigue activo** hasta el final del paso) | **Mutación humana del ruleset**: una persona añade `check_scope` como **cuarta comprobación requerida dentro de la regla `required_status_checks` ya existente**. Ese acto **no cambia ningún estado versionado**. Después, una **PR de operador de cierre** que, en un **único diff atómico**, registra la evidencia del ruleset conforme al contrato de `DEC-007` § «Evidencia de la mutación del ruleset», **acredita que la política elegida para las ramas `ops/*` permite fusionar esa propia PR**, **marca `WP-005` `done`** y **escribe reposo en `ACTIVE`**. **Los dos últimos no pueden ir en diffs distintos**: uno intermedio dejaría versionado un `ACTIVE` apuntando a un WP ya cerrado, y `check-active.sh` no lo detectaría. **Es la única transición `WP-005` → reposo de la secuencia** | Check **requerido** y verificado, registro versionado completo, y `WP-005` `done` **y** `ACTIVE` en reposo **en el mismo diff** |
| 10 | **Reposo** | **Parche humano del guard delgado** sobre la librería única (carril T3, ruta vedada a agentes). Después, **precondición común**: recálculo en solo lectura de las **siete magnitudes** de §1, **parada si alguna difiere**, comprobación de cardinalidad, tipos y modos, y **custodia externa persistente de la candidata completa antes de tocarla**. Solo entonces, **decisión humana registrada sobre `WP-007`** que elige entre **superación** y **ejecución**, levanta la congelación y, en la rama de ejecución, **corrige íntegramente su contrato en una PR de operador previa** —incluida la **retirada o sustitución de la PR-4 histórica**— | **Si se elige superación:** `WP-007` queda **resuelto** por acto de operador con `ACTIVE` en reposo, con **`estado: done`** y bloque **«Cerrado por superación»**; **no hay transición** y se pasa al paso 12. **Si se elige ejecución:** el contrato corregido está **aprobado y fusionado** y `WP-007` queda en **`estado: ready`**; se pasa al paso 11 |
| 11 | `WP-007` **solo en la rama de ejecución** | Ejecución, verificación, revisión y **fusión de la PR de implementación** gobernada por el contrato ya corregido —**no** una segunda fusión del contrato— | **PR final de operador** que, en un **único diff atómico**, marca `WP-007` `done`, **escribe reposo en `ACTIVE`** y registra el resultado |
| 12 | **Reposo** | Estado en el que se resuelve E2 y su gate —ver §2.c— y desde el que se cierra la pausa | Criterio de salida de §6 efectivamente cumplido |

**Las dos ramas son excluyentes y la condición del paso 10 nunca exige `WP-007` resuelto antes de poder ejecutarlo.** El paso 11 **no existe** en la rama de superación: la secuencia va del paso 10 al 12 **sin transición intermedia**, porque superar el WP es un **acto de operador** que **no mueve `ACTIVE`**. En la rama de ejecución, el paso 10 exige que la congelación esté **levantada** y que el **contrato corregido esté aprobado**; la resolución llega **al final** del paso 11, no antes. `DEC-007` § «Secuencia de ejecución posterior al punto de control», paso 21, escribe las dos ramas con su tipificación exacta: **21-A superación (`O`)** y **21-B ejecución (`O` + `T` + `W` + `T`)**, **nunca un `O/T` único**.

**Precondición común de las dos ramas: custodia antes de descongelar.** Antes de levantar la congelación, y sea cual sea la rama, se **recalculan en solo lectura las siete magnitudes** de §1 y se **comparan exactamente** con la huella; **si cualquiera difiere, parada y análisis, sin actualizar la huella**. Se comprueban además **cardinalidad, tipos y modos** de los archivos sin versionar, que la huella **expresamente no cubre**. Y se crea una **custodia externa persistente de la candidata completa** —rama y `HEAD`, estado Git `NUL`, diff binario, rutas rastreadas y no rastreadas, tipos, modos, tamaños, `SHA-256` por archivo y digest agregado— con **propietario, política de acceso, soporte y durabilidad, ubicación lógica —nunca `/private/tmp`—, retención, recuperación y auditabilidad**, marcada **`CANDIDATA HISTÓRICA NO CONFORME — NO EJECUTAR`**. **El descarte no puede destruir la única fuente**: solo cabe sobre el **worktree original** y **solo después** de acreditar la custodia. En la rama de ejecución se distinguen cuatro cosas: la **preimagen original custodiada**, que no se modifica; la **candidata usada como punto de partida**; la **reconciliación** de §7; y el **resultado finalmente versionado**.

**El contrato vigente de `WP-007` no es activable tal como está.** Su **PR-4 histórica** ordena `WP-002` → `ready` y **`ACTIVE` ← `WP-002`**, transición **obsoleta** tras la fila 6, y su premisa de que el hook precede al reinicio de `WP-002` queda **invertida** por el orden nuevo. Por eso la rama de ejecución exige, **antes** de activarlo, una **PR de operador que corrija íntegramente** `work-packages/WP-007-semantica-de-traversal.md`: retirar o sustituir la PR-4, adaptar el orden de trabajo —**primero** librería y `check_scope`, **después** guard delgado—, preservar la revisión humana, la **reconciliación de corpus de §7** y el tratamiento de la candidata local, actualizar condiciones de parada y criterios de aceptación, y **no reactivar `WP-002` ni `WP-005`**. **Sin ese contrato corregido y aprobado, la fila 11 no puede iniciarse.** Esta PR del punto de control **no modifica ese archivo**: no está en la lista cerrada de §4 como ruta editable de este diff, igual que `WP-002` y `WP-005`.

**Por qué los pasos 8 y 9 no se funden, y por qué el 9 no rompe «un WP = una rama = una PR».** El paso 8 termina con el job **existiendo y reportando**; el 9 lo convierte en **bloqueante para la fusión**, y eso es una **mutación humana de la configuración de GitHub**, fuera del alcance del código de cualquier WP. Cerrar `WP-005` antes del paso 9 dejaría el criterio de salida cumplido sobre un check que todavía no bloquea; y ordenar el registro después del cierre obligaría a **escribir evidencia sobre un WP ya cerrado**. Por eso `ACTIVE` **permanece en `WP-005`** hasta que el registro esté completo. La PR del paso 9 es una **PR de operador** (`ops/*`), no una segunda PR de implementación del WP, de modo que la convención «un WP = una rama = una PR» **queda intacta**.

**El cierre de la pausa es un acto de operador con `ACTIVE` en reposo**, nunca un estado de `ACTIVE`. La PR que lo ejecuta marca esta decisión `superada`, dice por qué acto y arrastra el registro de §3.

### 2.b Rama histórica no aplicable

D1 quedó ratificada. La alternativa que mantenía WP-012 se conserva en el
historial anterior, pero no forma parte de la secuencia ejecutable.

### 2.c E2 del sandbox y su eventual WP de adopción: hito futuro, no autorizado

El experimento **E2** y el **WP de nivel T3** que adoptaría el sandbox si E2 supera su gate **no tienen identificador reservado**, y ni esta decisión ni `DEC-007` se lo asignan. En consecuencia:

- **no aparecen como valor de `ACTIVE`** en ninguna de las dos secuencias;
- mientras se resuelven, `ACTIVE` permanece en **reposo**;
- antes de ejecutarlos hace falta **una decisión o enmienda posterior** que asigne el identificador exacto con forma `WP-NNN`, apruebe su contrato y **lo admita en la lista cerrada de §4**;
- hasta ese acto, su ejecución **no está autorizada**.

Si E2 no supera su gate, la tercera condición de salida se cumple con sus dos primeras partes y el resultado negativo se registra por escrito (§6).

### 2.d Precondiciones de activación de `WP-005`: el contrato debe hacerse ejecutable

La PR de operador del paso 7 **no puede limitarse a cambiar `draft` por `ready`**.
El contrato vigente de `WP-005` **no es ejecutable tal como está redactado**, y esta
decisión exige **nominalmente** que esa PR resuelva las cuatro cosas siguientes
**antes** de que el WP pueda activarse:

1. **Ruta protegida.** El contrato declara `agente_responsable: implementer` y
   permite `.github/workflows/ci.yml`, pero `Edit(./.github/workflows/**)` está en
   `permissions.deny` de `.claude/settings.json`, y `docs/manual/07-troubleshooting.md`
   establece que esos archivos **los crea o modifica una persona**. El contrato debe
   decir expresamente que **el agente prepara un parche verificable** —con respaldo
   previo, validaciones posteriores y comprobación por huella de que no toca nada
   más— y que **una persona lo aplica dentro de la propia PR de `WP-005`**,
   **manteniendo `ACTIVE` en `WP-005`** y **sin relajar `permissions.deny`**.
2. **Evidencia permitida.** El contrato exige archivos en `evidence/WP-005/` pero
   **esa ruta no figura hoy en su `## Archivos permitidos`**, que solo lista
   `.github/workflows/ci.yml` y `scripts/**`. Debe **añadir explícitamente**
   `evidence/WP-005/**`; de lo contrario el WP exige una evidencia que su propio
   alcance prohíbe escribir.
3. **Ramas de operador.** El job hace **fallar** toda rama que no encaje en
   `wp/(WP-[0-9]{3})-.*`, de modo que **rompería cada PR de operador** en ramas
   `ops/*`. `WP-002` y `docs/manual/02-ciclo-de-un-wp.md` lo registran como **deuda
   declarada**. El contrato debe **elegir expresamente** la política. Esta decisión
   **no elige por él**, pero fija el **contrato medible** que cualquier política
   admisible debe cumplir, escrito íntegramente en `DEC-007` § «Política de
   `ops/*`: contrato medible, sin elegir todavía»:

   - **ejecución incondicional**: **toda PR `ops/*` ejecuta siempre** el job que
     emite el check requerido; **ningún filtro de workflow, condición de job ni
     mecanismo equivalente** puede impedir su creación o su ejecución. En
     particular, un job con **`needs:`** **puede saltarse** si su dependencia
     falla o se salta, y un job saltado **se presenta como satisfactorio**: por
     eso el job **no depende de otro** o usa **`if: ${{ always() }}`** y **evalúa
     por sí mismo** todos los resultados requeridos, la **ausencia, fallo o salto
     de una dependencia produce `failure`**, el verificador usa
     **`continue-on-error: false`**, **ningún step posterior convierte su fallo
     en `success`**, y existe **un único gate terminal** que agrega y **falla
     cerrado**;
   - **conclusiones, clasificadas de forma cerrada**: **única conforme**,
     `success` **tras verificación completa**; **negativa esperada**, `failure`;
     y **cualquier otro estado o conclusión** —`queued`, `requested`,
     `in_progress`, `waiting`, `action_required`, `cancelled`, `neutral`,
     `skipped`, `stale`, `timed_out`, `startup_failure`, ausente o pendiente—
     **impide cerrar `WP-005`**, aunque GitHub acepte alguno para fusionar. **No
     se exige transformar artificialmente en `failure` los fallos de
     infraestructura incontrolables**: basta con que sean no conformes y
     bloqueen el cierre;
   - **condiciones de step acotadas**: solo admisibles si **no evitan ejecutar el
     verificador** ni impiden emitir la **conclusión terminal** del check
     requerido;
   - **el prefijo `ops/*` no basta**: la política acredita por un **mecanismo
     verificable** que la PR es realmente de operador;
   - las ramas `wp/*` **conservan el fail-closed**;
   - existen **prueba roja y prueba verde falsables**: el **caso rojo** es una PR
     `ops/*` con autorización **inexistente, inválida, caducada o de otro
     `HEAD`**, y el job **se crea, se ejecuta y termina en `failure`**; el **caso
     verde** es una PR `ops/*` con autorización **vigente para su `HEAD`
     actual**, y el job **se crea, se ejecuta, verifica la fuente de confianza y
     termina en `success`**. **En ninguno de los dos** el check queda `skipped`,
     `neutral`, ausente ni pendiente. Cada prueba registra PR, **`HEAD SHA`
     exacto**, par **`{context, integration_id}`**, **identificador real de la
     ejecución**, **conclusión final**, **instante UTC** y **fuente de confianza
     con prueba de vigencia**, **sin publicar secretos ni datos personales
     innecesarios**;
   - un error, un dato ausente o la imposibilidad de verificar producen **fallo
     cerrado**;
   - **prohibidos los filtros de workflow** que eviten por completo la emisión del
     check requerido —dejarían la PR **pendiente para siempre**, y el ruleset
     **no registra actores de excepción** que pudieran desbloquearla—;
   - **no se elige aquí la fuente concreta de autorización humana**: se fija qué
     debe cumplir cualquiera que se elija;
   - **el check se identifica por el par `{context, integration_id}`**, no por su
     nombre a secas: un **contexto homónimo publicado por otro productor no
     satisface el requisito**. `integration_id` es el campo de la **API de
     rulesets** y **no se confunde con el `app_id`** de los endpoints clásicos de
     protección de rama; **«cualquier productor» no es el valor por defecto
     admisible** y solo cabe por decisión humana explícita con controles
     compensatorios;
   - **la autorización debe estar vigente**: vinculada al **`HEAD SHA` exacto y
     vigente** de la PR, **inválida** al cambiar el diff, el SHA o la fuente de
     confianza, **reevaluada** ante todos los eventos relevantes para el
     mecanismo elegido y **fail-closed** si su vigencia no puede demostrarse.

   Si se elige la **aprobación humana verificable**, el contrato fija además su
   **fuente de confianza**, la **consulta exacta**, los **permisos mínimos**
   —incluido `pull-requests: read` si procede—, la **identidad estable** de la
   aprobación **y su vinculación al `HEAD SHA` vigente**, el **tratamiento
   fail-closed** de errores, indisponibilidad y respuestas ambiguas, y la
   **ausencia de secretos**. Sea cual sea la política, el contrato **enumera
   nominalmente los eventos** necesarios para su fuente de confianza concreta,
   fija **activadores y permisos exactos** y **prueba que ningún cambio relevante
   conserva indebidamente un verde anterior**. `DEC-007` no congela esa lista de
   eventos porque la política todavía no está elegida.

   Antes de activar `WP-005`, la política debe quedar **definida** en un contrato
   aprobado y verificable. La implementación y las pruebas roja y verde se
   producen **durante `WP-005`**. Hasta que estén en verde, no se incorpora el
   check al ruleset ni se cierra el WP; la PR de operador del paso 9 no sería
   fusionable.
4. **Ruleset fuera del WP.** Marcar el check como requerido **queda fuera del
   alcance del código de `WP-005`**: es una **mutación humana** de la configuración
   de GitHub, y se ejecuta y se registra en el paso 9 de §2.a.
5. **Evidencia reproducible de esa mutación.** El registro del paso 9 cumple
   **íntegramente** el esquema de `DEC-007` § «Evidencia de la mutación del
   ruleset», que es su **fuente normativa detallada** y **no se reproduce aquí**.
   En resumen, ese esquema exige: **identidad de la captura** —repositorio y
   rama, `ruleset_id`, endpoint autoritativo y versión de API, instantes UTC—;
   **versiones y direccionamiento** —`version_id` anterior y posterior,
   `updated_at` y la **respuesta de historia capturada después de mutar**, no
   solo apuntada, con **tres endpoints distinguidos**: el de **estado actual**,
   el de **listado** —que devuelve `version_id`, actor y `updated_at`, **no**
   `state` completo— y el de **versión concreta**, que sí lo devuelve.
   **`version_id` es direccionamiento, no custodia**; **no se afirma que la
   entrada sea inmutable ni que su retención futura esté garantizada**, y la
   **ventana de 180 días** que GitHub documenta es **visibilidad de la interfaz
   de gestión**, **no** garantía de retención del endpoint REST—; **estado semántico completo** de preimagen y postimagen —nombre e
   identificador, origen y tipo de origen, destino, `enforcement`, condiciones,
   *bypass actors*, lista completa de reglas con **todos** sus parámetros y
   checks requeridos como pares **`{context, integration_id}`**—; **proyecciones
   declaradas** que **no sustituyen** al estado completo; un **delta semántico**
   que debe reducirse **exactamente** a la incorporación del par esperado;
   **normalización declarada de las colecciones sin orden significativo** más
   **canonicalización RFC 8785 (JCS)** y **SHA-256 de esos bytes exactos**, con
   **implementación y versión** del canonicalizador; **actor verificable** por
   **referencia opaca al historial protegido**, publicando solo el rol «operador
   humano» y **nunca** identidad personal; **comprobación de deriva** antes y
   después de mutar; **rollback mínimo** con **condición verificable**; un
   **orden vinculante escrito una sola vez** que separa **lo que debe existir
   antes de mutar** de **lo que solo puede capturarse después**, y **lo que
   impide mutar** de **lo que impide cerrar `WP-005`**; un **procedimiento
   fail-closed de indisponibilidad histórica** —intentos, plazo y backoff fijados
   de antemano; la mutación **se conserva**, **`WP-005` permanece abierto**,
   **no se presenta la PR de cierre**, se registran los intentos y **se
   escala**, **sin rollback automático**—; **credencial y permiso mínimo
   documentado** de la consulta —hoy `Administration: write` para el endpoint de
   versión—, **nunca entregada al agente ni versionada**, con **parada previa**
   si no está disponible; y **custodia externa persistente y protegida** de las
   representaciones completas —con **propietario**, **política de acceso**,
   **soporte y ubicación lógica** —nunca `/private/tmp`—, **retención
   explícita**, **procedimiento de recuperación**, **auditabilidad futura** y
   **huella**—, con **parada previa a mutar** si esa custodia no puede
   acreditarse. La
   postimagen debe demostrar que **solo se añadió el par previsto** y que **no
   cambiaron** otras reglas, parámetros, `enforcement`, condiciones, destino ni
   *bypass actors*.

`work-packages/WP-005-check-scope-en-ci.md` **no se modifica en la PR del punto de
control**: no está en la lista cerrada de §4 como ruta editable de este diff. La
corrección queda **exigida a su PR de operador posterior**, y sin ella el paso 8
**no puede iniciarse**.

**La suspensión de WP-008-r2 no es cierre ni abandono.** El paso 1 devuelve `ACTIVE` a reposo por un cambio de rumbo autorizado por `DEC-007`, no por incumplimiento: WP-008 no se declara cerrado, no se retira su identificador, no se borra su worktree y no se autoriza tocar su candidata local. Se reactiva en el paso 4.

**Un WP activo cada vez.** Nunca hay dos. Entre WPs, reposo. **Cada cambio de `ACTIVE` es una transición humana separada**, documentada y no combinable con implementación. `WP-002` y `WP-005` son **secuenciales**: nunca comparten `ACTIVE`, y cada uno conserva su propio WP, su propia rama y su propia PR, conforme a «un WP = una rama = una PR» de `CLAUDE.md`.

Al pasar a reposo, el archivo resultante es byte a byte idéntico al que ya tuvo en `8190976`.

**Secuencia anterior, conservada como historia.** Hasta el punto de control del 2026-09-07 la tabla vigente era: reposo → `WP-008` (núcleo) → reposo → `WP-009` → reposo → `WP-012` → reposo → `WP-007`. La enmienda la sustituye por completo; no se aplica en paralelo ni se reanuda por analogía.

**El contrato actual de WP-008 queda congelado.** `DEC-005` trocea WP-008 en un **núcleo de protección**, que conserva el identificador, y un **instrumento empírico**, que pasa a `WP-012`. Mientras `ACTIVE` esté en reposo no hay ninguna ruta autorizada y ningún agente escribe sobre WP-008. **Solo podrá reactivarse cuando su versión reducida esté materializada, validada y aprobada**, en el paso 4. Hasta entonces el contrato vigente permanece como estado histórico y **no gobierna ningún trabajo**.

**Interrupción excepcional del paso de WP-008** —el paso 2 de la secuencia anterior, el paso 4 de la nueva §2.a. [`DEC-006`](DEC-006-abandono-y-reinicio-controlado-de-wp-008.md)
registra que la primera cadena del núcleo se detuvo en S1, con una barrera roja no
conforme, y autoriza devolver `ACTIVE` a reposo **sin presentar WP-008 como
cerrado**. Tras cerrar la PR abandonada sin fusionar y corregir el contrato en una
PR de operador de un solo archivo, el mismo paso se reanuda una sola vez sobre
`wp/WP-008-runtime-fail-closed-r2`. La reactivación vuelve a ser un acto de
operador posterior y separado. Esta excepción no adelanta ningún WP posterior.

**Desviación explícita y firmada.** El plan externo de continuación pedía para este paso una PR de operador con «solo la decisión». Esta composición —decisión, manual y `ACTIVE` en un mismo diff— es una **desviación aprobada por el operador el 2026-08-03**, amparada en [`docs/manual/02-ciclo-de-un-wp.md`](../../docs/manual/02-ciclo-de-un-wp.md), que permite a una PR de operador combinar varios actos, con precedente en la PR #7. Se registra porque una desviación no escrita es lo que esta decisión existe para impedir.

### 3. Registro del estado creado fuera del repositorio

El 2026-08-03, por decisión humana en la interfaz de GitHub:

| Workflow | Estado | Condición de término |
|---|---|---|
| `Claude` (`claude.yml`) | `disabled_manually` | **Toda la calibración** |
| `Revisión de código` (`code-review.yml`) | `disabled_manually` | **Hasta WP-011** |
| `CI` (`ci.yml`) | `active` | No se toca |

**Este estado externo NO caduca con la pausa.** Sus condiciones de término son WP-011 y el fin de la calibración, no el 2026-08-10. La PR de operador que cierre la pausa debe **arrastrar este registro**, no darlo por extinguido.

**Reactivar** cualquiera de los dos exige **dos cosas**: (a) que se haya cumplido el WP o la decisión que lo gobierna, y (b) una **transición explícita del operador**, registrada. **No exige necesariamente una DEC nueva.**

Los tres checks obligatorios son jobs de `ci.yml` y siguen operando. La contención no retira ninguna garantía real: de los dos controles suspendidos, uno nunca revisó y el otro no tenía barrera propia versionada.

### 4. Lista cerrada de lo admitido durante la pausa

| Admitido | Qué es |
|---|---|
| `DEC-003` | Registro de la pausa |
| `DEC-004` | Estados del coste. Decisión sola, sin implementación |
| `DEC-005` | Revisión de la pausa y troceado de WP-008 |
| `WP-008` | Runtime realmente fail-closed. Tras `DEC-005`, **solo el núcleo de protección** |
| `WP-009` | Cadena de suministro |
| `WP-012` | Instrumento empírico, troceado desde WP-008 por `DEC-005` |
| `DEC-006` | Abandono y reinicio controlado de la primera cadena del núcleo WP-008 |
| `DEC-007` | Punto de control del 2026-09-07 y rumbo: resoluciones D1–D6 |
| `docs/03-hoja-de-ruta.md` | Hoja de ruta v2, con la foto local de WP-008-r2 corregida y la arquitectura objetivo separada del estado materializado |
| `docs/04-analisis-conversaciones-ia.md` | Análisis de las cinco conversaciones; procedencia del rumbo |
| `docs/05-analisis-investigacion-leandro-y-revalidacion.md` | Segunda revisión y revalidación, con su corrección factual |
| `CLAUDE.md` | Constitución. Solo las frases del modelo de control afectadas por D3 y el enlace que hace descubrible el rumbo |
| `docs/02-guia-fabrica-desarrollo-agentica.md` | Especificación vinculante. Solo las frases sobre el hook afectadas por D3 y el enlace a la hoja de ruta |
| `docs/manual/MANUAL.md` | Índice del manual. Modelo de controles y navegación hacia `docs/03–05` |
| `WP-002` | `check_scope` y librería única de matching. **Solo** puede activarse tras la PR de operador que corrija su contrato y lo saque de `blocked` |
| `WP-005` | Integración del job de `check_scope` **ejecutándose en CI** sobre esa misma librería. **Solo** puede activarse tras la PR de operador que **corrija integralmente su contrato** conforme a §2.d y lo lleve de `draft` a `ready`. **Marcar el check como requerido no es alcance de este WP**: es mutación humana del ruleset (§2.a paso 9) |
| `WP-007` | Resolución por ejecución o superación, en acto separado y registrado (§1 y §2.a pasos 10–11) |
| Prueba de humo de D1 | **No es una entrada propia**: es alcance del contrato de `WP-008`, con evidencia en `evidence/WP-008/` |
| Parche humano del guard delgado | Acto de operador sobre `.claude/hooks/**`, carril T3, posterior a `WP-002` y `WP-005` |
| Transiciones de operador | Estrictamente las de §2 |

Cualquier otra cosa exige enmendar esta DEC. La lista es cerrada, no ilustrativa.

**Lo que esta lista NO admite, y por qué se dice expresamente.** El experimento **E2** del sandbox y el **WP de nivel T3** que lo adoptaría **no figuran** y **no pueden ejecutarse**: no tienen identificador con forma `WP-NNN`, ni contrato aprobado, y esta decisión **no se los inventa**. Admitir una actividad sin identificador sería autorizar trabajo que ningún `ACTIVE` puede expresar. Antes de ejecutarlos hará falta **una enmienda posterior de esta sección** que fije el identificador exacto, apruebe el contrato y lo incorpore aquí por el mismo mecanismo atómico. Hasta entonces `ACTIVE` permanece en reposo (§2.c).

**Cómo se ha enmendado esta lista, y por qué importa la forma.** [`DEC-004`](DEC-004-estados-del-coste.md) §2 enmendó **por declaración** la entrada `DEC-004`, que **ya figuraba** en esta lista, para ampliar la composición de su PR. Ese mecanismo no sirve para admitir lo que no está: una decisión ausente no puede admitirse a sí misma sin circularidad. Por eso las entradas `DEC-005` y `WP-012` se han incorporado **modificando directamente esta sección**, en el mismo diff atómico que introdujo `DEC-005`.
La entrada `DEC-006` se incorpora por el mismo mecanismo atómico en la PR que la
materializa; no se autoautoriza.

**Admisión atómica de `DEC-007`, de `docs/03–05` y de las tres rutas de gobierno.** Las entradas nuevas se incorporan por ese mismo mecanismo: **modificando directamente esta sección dentro del único diff que crea `DEC-007` y que trae los demás documentos**. `DEC-007` no puede admitirse a sí misma —sería la circularidad que esta subsección prohíbe—, y ninguno de los documentos era norma antes de entrar en `main`; por eso todas las rutas y esta enmienda viajan juntas o no viajan.

`CLAUDE.md`, `docs/02` y `docs/manual/MANUAL.md` se admiten por una razón distinta de las anteriores: no aportan trabajo nuevo, sino que **retiran una contradicción que la propia PR crearía** al hacer vinculante `docs/03`. Sin ellas quedarían dos normas vinculantes afirmando lo contrario sobre el mismo control, que es una condición de parada de `CLAUDE.md`.

`WP-002`, `WP-005` y `WP-007` se admiten porque §2 los programa; admitirlos aquí es la condición para que esa programación sea legítima. Admitirlos **no** los activa ni cambia su estado contractual: `WP-002` sigue `blocked` y `WP-005` `draft` hasta sus respectivas PRs de operador, y `WP-007` sigue `ready` y congelado.

La composición exacta de esa PR es de **nueve archivos** bajo D3 ratificada, y está fijada en `DEC-007`. Si D3 quedara resuelta por su default, esta admisión se limita a `DEC-007` y no alcanza a `docs/03–05` ni a las tres rutas de gobierno, y la PR es la variante separada de tres archivos.

### 5. Punto de control de la pausa: 2026-09-07

Sustituye a la fecha original del 2026-08-10, cuya revisión se practicó y quedó registrada en [`DEC-005`](DEC-005-troceado-de-wp-008-y-revision-de-la-pausa.md) §1: el criterio de §6 no estaba cumplido y no podía estarlo, porque `WP-009` no tenía siquiera contrato redactado.

Es un **punto de control, no una promesa de finalización**. En esa fecha: o el criterio de §6 está cumplido y la pausa termina, o **parada y análisis de causa registrado por escrito**. Llegar sin haberlo cumplido **no es un incumplimiento**: es el disparador de ese análisis, exactamente como ocurrió el 2026-08-10. Esta caducidad rige **la pausa**, no el estado externo de §3.

**Resultado efectivo del punto de control, registrado el 2026-09-09.** El criterio de §6 **no está cumplido**. El análisis de causa es la hoja de ruta v2, la revisión `docs/05` y `DEC-007`: el enforcement se estaba endureciendo en la capa débil mientras la concluyente seguía sin construirse. La pausa **no termina**; se reordena conforme a D1, D2, D3, D4 y D6 ratificadas, D5 resuelta por su default, la secuencia de §2 y el criterio de salida de §6.

**No se fija otra fecha de revisión.** El tercer punto de control por calendario queda sustituido por **gates de evidencia**: la pausa avanza cuando cada paso de §2 cumple su condición verificable y se cierra cuando el criterio de §6 está efectivamente cumplido, no en una fecha. Las fechas de la hoja de ruta son orientativas; los criterios de salida son los que vinculan (principio P4 de `docs/03`). Si un paso se atasca, el disparador sigue siendo el mismo: **parada y análisis de causa por escrito**, no una prórroga automática.

### 6. Criterio de salida

Tres condiciones. **Ninguna sustituye a otra**: la primera instala, la segunda cierra la cadena de suministro y la tercera demuestra que los controles disparan.

- [ ] **Runtime fail-closed instalado.** `WP-008` fusionado: comando canónico anclado con `CLAUDE_PROJECT_DIR` y normalizado a `exit 2`; ocho reglas reancladas a la raíz del proyecto; preflight estructural bloqueante en el job `Gobierno FDA`, con la demostración del bloqueo que exija la rama de D6 resuelta.
- [ ] **Acciones fijadas por SHA.** `WP-009` fusionado: el criterio de verificación n.º 2 de `REQ-FDA-002` devuelve vacío.
- [ ] **Control de alcance concluyente y resolución del gate del sandbox** *(tercera condición fijada por `DEC-007`, D1 ratificada)*. Las tres partes son acumulativas:
  1. **Humo seguro documentado, dentro del alcance de `WP-008`**, registrado en `evidence/WP-008/` y **ejecutado antes de cerrar WP-008**. Verifica que el runtime carga la configuración y resuelve, como mínimo, el caso de cero segmentos `Read(/**/.env*)` frente a `.env` en la raíz del proyecto. **Si falla, WP-008 no se cierra** y se aplica el presupuesto de ciclos vigente de su contrato; no se abre presupuesto nuevo ni se reabre un WP cerrado.

     **Condiciones de seguridad, vinculantes.** El ensayo se monta sobre un **proyecto desechable y aislado**, **físicamente fuera de la raíz de FDA**; usa un **`.env` sintético con contenido marcador y cero secretos reales**; **prohíbe crear, leer o modificar cualquier `.env`, secreto o archivo real de FDA**; registra **evidencia saneada**, sin contenido sensible; y **limita la limpieza a los recursos propios del ensayo**. Un humo que incumpla estas condiciones **no es admisible como evidencia** de esta condición;
  2. **`check_scope` sobre el diff de la PR contra el contrato del WP**, implementado sobre una **única librería de matching** compartida con el guard. Lo construyen `WP-002` y `WP-005` **secuencialmente**, cada uno con su contrato, rama y PR. **Tres estados distintos, que esta decisión no funde:** *(a)* **ejecutable local** creado por `WP-002`, que invocan a mano el operador y los revisores y que **no bloquea ninguna fusión**; *(b)* **job integrado y ejecutándose en CI** por `WP-005`, **todavía no requerido**, que puede ponerse rojo pero **no impide fusionar**; y *(c)* **check incorporado por una persona a `required_status_checks`**, momento desde el cual **bloquea la fusión**. Esta condición exige **las dos últimas**: job ejecutándose **y** check incorporado. **Hoy no existe ninguno de los tres**;
  3. **Experimento E2 del sandbox ejecutado y su resultado registrado por escrito.** Lo que acredita esta parte es **la resolución del gate**, no una garantía. **Si E2 supera el gate**, se exige su **adopción efectiva mediante el futuro WP de nivel T3**; **si no lo supera**, el gate queda **resuelto negativamente** y esta condición se cumple con sus dos primeras partes. **Ni E2 ni ese WP T3 tienen identificador reservado**: requieren la enmienda posterior de §4 descrita en §2.c antes de poder ejecutarse.

**Qué acredita y qué no un E2 negativo.** Resolver negativamente E2 **no materializa ninguna garantía del sistema operativo**: la **arquitectura objetivo de tres capas sigue incompleta**, la **garantía del kernel solo existe tras la adopción efectiva** del sandbox, y **cerrar la pausa tras un E2 negativo no autoriza a describir la capa 2 como conseguida** en ningún texto de gobierno. El sandbox no ofrece hoy ninguna garantía efectiva porque **no está instalado**.

Criterio literal de `REQ-FDA-002`:

```bash
grep -rn 'uses:' .github/workflows/ \
  | grep -v '@[0-9a-f]\{40\}' \
  | grep -v 'uses: \./'
```

**Qué demuestra y qué no demuestra la tercera condición.** El humo acredita que la configuración se carga y que un caso concreto se resuelve como se contrató; `check_scope` **acreditará, cuando exista** —hoy no está implementado—, que **ninguna escritura fuera de alcance sobrevive al diff de la PR**, venga de donde venga; el sandbox, **si se instala, supera su gate y se adopta, trasladaría** la garantía al kernel. **Ninguna de las tres demuestra la semántica general del runtime**, y esta decisión no la promete: lo que se exigía a `WP-012` era esa demostración empírica, y se sustituye deliberadamente por un control del resultado, no por una afirmación equivalente. Cualquier texto que presente el humo como prueba de que Claude Code aplica su configuración en general contradice esta sección.

**`WP-012` queda liberado como condición de salida.** Conserva su identificador y su historia; no se ejecuta su runner por analogía ni se reactiva sin decisión nueva. Si D1 hubiera quedado en su default, esta sustitución no estaría en vigor y regiría la tercera condición anterior —`WP-012` fusionado, exit `0`, composición **14 sondas lógicas · 13 CONFORME · 1 REGISTRADA_FUERA_DE_CONTRATO · 0 NO_CONFORME**—, que se conserva aquí para que la comparación sea auditable. Detalle del reparto original en `DEC-005` §§4, 5 y 7.

Cumplidas las tres, una **PR de operador cierra esta decisión con `ACTIVE` en reposo** —paso 12 de §2.a, o su equivalente en §2.b—, marca esta decisión `superada`, dice por qué acto y arrastra el registro de §3. **El cierre de la pausa no es un estado de `ACTIVE`.**

### 7. `tests/guard/run-suite.sh`: dos líneas base, y una prohibición hacia adelante

Dos cosas que no deben confundirse:

| Línea base | Dónde | Contadores |
|---|---|---|
| **Versionada** | `main` @ `36cb46c` | **68 · 0 · 10 · 0** |
| **Candidata local** | worktree congelado de WP-007, sin versionar | **75 · 0 · 10 · 0** |

La modificación de `run-suite.sh` en ese worktree es **anterior a esta decisión** y es trabajo legítimo del contrato de WP-007. **No es incumplimiento de una pausa que aún no existía**: queda congelada por §1, no sancionada.

**Prohibición vigente hacia adelante:** **ninguna acción de ninguna clase** —admitida por §4, omitida de §4 por error, WP presente o futuro, acto de operador o trabajo de agente— modifica `tests/guard/run-suite.sh` mientras dure la pausa. Se nombran expresamente `WP-008`, `WP-009`, `WP-002`, `WP-005`, `WP-007` y `WP-012`, pero la prohibición **no depende de que un WP figure en la lista cerrada**: alcanza también a cualquiera que se admita más adelante. Todo contrato que se redacte o corrija durante la pausa **debe incluir esa ruta entre sus archivos prohibidos**, y su ausencia en el contrato no la autoriza.

**La única excepción posible es la rama en la que `WP-007` se resuelve por ejecución**, una vez **levantada expresamente la congelación** de §1 y **durante el trabajo autorizado de su contrato**. **La superación de `WP-007` no autoriza modificar `run-suite.sh`**: es un acto de operador con `ACTIVE` en reposo y sin ejecución del WP. La excepción se define así **por su contenido, no por un número de paso**, para que renumerar la secuencia no la desplace. Cualquier otra modificación es una desviación que obliga a **parada y análisis**.

Razón: WP-007 fija 75 = 68 previas + 7 nuevas, y su `aplicar.sh` aborta si el candidato no devuelve `75 · 0 · 10 · 0`. Alterar la baseline versionada durante la pausa rompería esa aritmética al reanudar. El preflight de WP-008 vive por tanto en script propio con contadores propios.

**Reconciliación del manual.** [`docs/manual/05-bloqueos-y-parada.md`](../../docs/manual/05-bloqueos-y-parada.md) cambia en esta PR y **también** tiene cambios pendientes en el worktree congelado. Cuando WP-007 se reanude, su versión **no sobrescribe** a la de esta decisión: deberá **reconciliarse con el manual procedente de DEC-003 y preservar ambos contenidos**. Es un acto explícito del ciclo de reanudación, no una resolución automática de conflicto.

### 8. Adaptaciones de otros runtimes: inventario y carácter local no gobernado

Sin versionar en el árbol de trabajo a fecha de hoy:

| Ruta | Contenido |
|---|---|
| `.agents/` | `skills/` — copias de `new-work-package`, `run-verification`, `prepare-pr` |
| `.codex/` | `hooks.json`, `hooks/guard.sh`, `agents/*.toml` (5 agentes) |
| `AGENTS.md` | Constitución adaptada a otro runtime |

1. **No se versionan, no se ignoran y no se modifican.**
2. Son estado operativo local, fuera de gobierno.
3. **Codex queda autorizado únicamente para lectura y auditoría.** No escribe en este repositorio por ninguna vía.
4. La restricción se levanta solo con una DEC propia y un WP específico. **Debe resolverse antes de cualquier uso de Codex como implementador.**

**Estado técnico verificado.** `.codex/hooks/guard.sh` es **hoy** una copia byte a byte de `.claude/hooks/guard.sh` de `main` (`sha256 d435597a…`). **No está integrado como consumidor verificado**: cero referencias en `.github/workflows/`, `tests/` y `evidence/WP-000/checks/`. Nada garantiza que siga siendo idéntico: **puede divergir en el futuro** sin que ningún control lo detecte. Toda la capa preventiva es específica del runtime, porque `guard.sh` se invoca desde `.claude/settings.json` vía `PreToolUse`.

**Observación registrada, no corregida aquí.** Con estas tres rutas presentes, `evidence/WP-000/checks/check-structure.sh` termina en exit `1` («3 no pactados»). Ese script no forma parte de `ci.yml`, de modo que el rojo es local y no alcanza a ninguna barrera.

## Consecuencias

**A favor.** El enforcement se arregla antes de apoyar más trabajo en él. Se detiene un gasto de Opus que no compraba nada. La pausa tiene lista cerrada, fecha y criterio de salida verificable. La secuencia de `ACTIVE` mantiene un solo WP activo cada vez. La congelación de WP-007 es comprobable con siete magnitudes, no solo declarada.

**En contra.** DEC-002 se retrasa y su migración queda a medias más tiempo del previsto. Aceptado: el coste de retrasar es acotado; el de construir sobre un guard que falla abierto no lo es.

**Coste de la congelación.** El trabajo candidato de WP-007 queda sin commitear durante la pausa, expuesto a pérdida por una operación de Git descuidada sobre ese worktree. Se asume conscientemente: commitearlo sería avanzar la migración que esta decisión pausa. Cualquier cambio de criterio exige la decisión separada de §1.

**Fricción asumida por decisión del operador.** Con `ACTIVE` en reposo no hay ninguna ruta autorizada y ningún agente escribe. El **WP de mantenimiento de alcance mínimo** de [`docs/manual/05-bloqueos-y-parada.md`](../../docs/manual/05-bloqueos-y-parada.md) sigue siendo el protocolo general y legítimo para reparar el gobierno cuando el fail-closed lo bloquea; **para esta pausa concreta, el operador ha decidido no emplear esa vía** y ha elegido **preparación en solo lectura más materialización humana**: los contratos de WP-008 y WP-009 se redactan sin escribir en el repositorio y los materializa y activa el operador cuando estén completos, validados y aprobados. Que redactar un WP en `draft` sea trabajo de agente y el reposo lo impida sigue siendo una **tensión real del manual**; queda registrada y no se resuelve ampliando el alcance de la pausa.

**Riesgo identificado y NO aprobado.** El ruleset **sí** exige pull request y **sí** impone los tres checks bloqueantes, además de `non_fast_forward` y `deletion`. Lo que falta es **revisión humana obligatoria**: `required_approving_review_count: 0` y `require_code_owner_review: false`, mientras `CODEOWNERS` y el manual afirman revisión obligatoria por propietario. Esta decisión **no lo aprueba ni lo acepta**: lo registra como abierto. Corresponde a WP-011 y requiere aprobación explícita del operador.

**Mantenimiento.** El punto de control del 2026-08-10 se practicó y quedó registrado en `DEC-005` §1; el del 2026-09-07, en §5 de esta decisión. **No queda pendiente ninguna revisión por calendario**: el seguimiento son los gates de evidencia de §§2 y 6. La PR que cierre la pausa debe marcar esta decisión `superada`, decir por qué acto, y arrastrar el registro de §3.

## Referencias

- [`DEC-002`](DEC-002-semantica-de-traversal.md) — su § Migración es lo que aquí se pausa
- [`DEC-001`](DEC-001-divisa-costes.md) — intacta
- [`DEC-006`](DEC-006-abandono-y-reinicio-controlado-de-wp-008.md) — recuperación excepcional de WP-008
- [`DEC-007`](DEC-007-punto-de-control-y-rumbo.md) — decisión aceptada el 2026-09-09; enmienda §§1, 2, 4, 5, 6 y 7 de esta decisión
- [`CLAUDE.md`](../../CLAUDE.md) — constitución; ruta de la composición de esa PR
- [`docs/02-guia-fabrica-desarrollo-agentica.md`](../../docs/02-guia-fabrica-desarrollo-agentica.md) — especificación vinculante; ruta de la composición
- [`docs/manual/MANUAL.md`](../../docs/manual/MANUAL.md) — índice y modelo de controles; ruta de la composición
- [`docs/03-hoja-de-ruta.md`](../../docs/03-hoja-de-ruta.md) — rumbo propuesto como vinculante y secuencia posterior a la pausa
- [`docs/04-analisis-conversaciones-ia.md`](../../docs/04-analisis-conversaciones-ia.md) — procedencia del rumbo
- [`docs/05-analisis-investigacion-leandro-y-revalidacion.md`](../../docs/05-analisis-investigacion-leandro-y-revalidacion.md) — revalidación y foto local corregida
- [`REQ-FDA-002`](../requirements/REQ-FDA-002-workflows-endurecidos.md) — incumplido, punto 2
- [`ADR-001`](../adr/ADR-001-runtime.md) — ejecución headless
- [`work-packages/WP-007-semantica-de-traversal.md`](../../work-packages/WP-007-semantica-de-traversal.md) — `ready`, congelado
- [`work-packages/WP-002-check-scope.md`](../../work-packages/WP-002-check-scope.md) — `blocked`; su contrato debe corregirse y aprobarse antes de poder activarse
- [`work-packages/WP-005-check-scope-en-ci.md`](../../work-packages/WP-005-check-scope-en-ci.md) — `draft`; debe pasar a contrato validado y aprobado antes de poder activarse
- [`tests/governance/check-active.sh`](../../tests/governance/check-active.sh) — valida `ACTIVE`: reposo o `WP-NNN`; cualquier otro contenido es exit `1`
- [`docs/manual/02-ciclo-de-un-wp.md`](../../docs/manual/02-ciclo-de-un-wp.md) — PR de operador
- [`docs/manual/05-bloqueos-y-parada.md`](../../docs/manual/05-bloqueos-y-parada.md) — condiciones de parada
