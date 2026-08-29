# DEC-003 — Pausa de la migración de DEC-002 y contención del carril automático

**Estado:** aceptada · **Fecha:** 2026-08-03 · **Ámbito:** la migración de [`DEC-002`](DEC-002-semantica-de-traversal.md), el estado de `work-packages/ACTIVE`, los workflows de agente y las adaptaciones de otros runtimes presentes en el árbol de trabajo
**Origen:** contraste de dos auditorías independientes sobre `36cb46c`, verificado sobre el repositorio y sobre GitHub el 2026-08-03.

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

**Estado oficial:** `main` sigue en `36cb46c` y **WP-007 sigue `ready`**. Esta decisión no cambia su estado contractual. WP-002 permanece `blocked`. PR-3 y PR-4 siguen siendo las siguientes de la secuencia.

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

### 2. Secuencia de `work-packages/ACTIVE` durante la pausa

`ACTIVE` queda **inicialmente** en reposo, y **no permanece vacío durante toda la pausa**. La secuencia completa, en este orden estricto, y cada transición un acto del operador humano:

| Paso | `ACTIVE` | Condición para pasar al siguiente |
|---|---|---|
| 1 | **Reposo** | Materialización de [`DEC-005`](DEC-005-troceado-de-wp-008-y-revision-de-la-pausa.md) |
| 2 | `WP-008` (núcleo) | Su contrato **reducido**, validado y aprobado, y el aislamiento de `DEC-005` §9 completado |
| 3 | **Reposo** | Cierre de WP-008 |
| 4 | `WP-009` | Su contrato **completo, validado y aprobado** |
| 5 | **Reposo** | Cierre de WP-009 |
| 6 | `WP-012` | Su contrato **completo, validado y aprobado**, y las precondiciones de `DEC-005` §9 verificadas |
| 7 | **Reposo** | Cierre de WP-012 |
| 8 | `WP-007` | **Solo** al cumplirse las **tres** condiciones del criterio de salida de §6; cierra la pausa |

**Un WP activo cada vez.** Nunca hay dos. Entre WPs, reposo.

Al pasar a reposo, el archivo resultante es byte a byte idéntico al que ya tuvo en `8190976`.

**El contrato actual de WP-008 queda congelado.** `DEC-005` trocea WP-008 en un **núcleo de protección**, que conserva el identificador, y un **instrumento empírico**, que pasa a `WP-012`. Mientras `ACTIVE` esté en reposo no hay ninguna ruta autorizada y ningún agente escribe sobre WP-008. **Solo podrá reactivarse cuando su versión reducida esté materializada, validada y aprobada**, en el paso 2. Hasta entonces el contrato vigente permanece como estado histórico y **no gobierna ningún trabajo**.

**Interrupción excepcional del paso 2.** [`DEC-006`](DEC-006-abandono-y-reinicio-controlado-de-wp-008.md)
registra que la primera cadena del núcleo se detuvo en S1, con una barrera roja no
conforme, y autoriza devolver `ACTIVE` a reposo **sin presentar WP-008 como
cerrado**. Tras cerrar la PR abandonada sin fusionar y corregir el contrato en una
PR de operador de un solo archivo, el mismo paso 2 se reanuda una sola vez sobre
`wp/WP-008-runtime-fail-closed-r2`. La reactivación vuelve a ser un acto de
operador posterior y separado. Esta excepción no adelanta el paso 3 ni ningún WP
posterior.

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
| Transiciones de operador | Estrictamente las de §2 |

Cualquier otra cosa exige enmendar esta DEC. La lista es cerrada, no ilustrativa.

**Cómo se ha enmendado esta lista, y por qué importa la forma.** [`DEC-004`](DEC-004-estados-del-coste.md) §2 enmendó **por declaración** la entrada `DEC-004`, que **ya figuraba** en esta lista, para ampliar la composición de su PR. Ese mecanismo no sirve para admitir lo que no está: una decisión ausente no puede admitirse a sí misma sin circularidad. Por eso las entradas `DEC-005` y `WP-012` se han incorporado **modificando directamente esta sección**, en el mismo diff atómico que introdujo `DEC-005`.
La entrada `DEC-006` se incorpora por el mismo mecanismo atómico en la PR que la
materializa; no se autoautoriza.

### 5. Punto de control de la pausa: 2026-09-07

Sustituye a la fecha original del 2026-08-10, cuya revisión se practicó y quedó registrada en [`DEC-005`](DEC-005-troceado-de-wp-008-y-revision-de-la-pausa.md) §1: el criterio de §6 no estaba cumplido y no podía estarlo, porque `WP-009` no tenía siquiera contrato redactado.

Es un **punto de control, no una promesa de finalización**. En esa fecha: o el criterio de §6 está cumplido y la pausa termina, o **parada y análisis de causa registrado por escrito**. Llegar sin haberlo cumplido **no es un incumplimiento**: es el disparador de ese análisis, exactamente como ocurrió el 2026-08-10. Esta caducidad rige **la pausa**, no el estado externo de §3.

### 6. Criterio de salida

Tres condiciones. **Ninguna sustituye a otra**: la primera instala, la segunda cierra la cadena de suministro y la tercera demuestra.

- [ ] **Runtime fail-closed instalado.** `WP-008` fusionado: comando canónico anclado con `CLAUDE_PROJECT_DIR` y normalizado a `exit 2`; ocho reglas reancladas a la raíz del proyecto; preflight estructural bloqueante en el job `Gobierno FDA`, con una **ejecución roja real de CI** que demuestre el bloqueo, capturada como evidencia.
- [ ] **Acciones fijadas por SHA.** `WP-009` fusionado: el criterio de verificación n.º 2 de `REQ-FDA-002` devuelve vacío.
- [ ] **Runtime fail-closed demostrado empíricamente.** `WP-012` fusionado: el runner empírico termina en **exit `0`** con la composición exacta **14 sondas lógicas · 13 CONFORME · 1 REGISTRADA_FUERA_DE_CONTRATO · 0 NO_CONFORME**, sin errores de entorno, con sus resultados saneados incorporados como evidencia bajo `evidence/WP-012/**`.

Criterio literal de `REQ-FDA-002`:

```bash
grep -rn 'uses:' .github/workflows/ \
  | grep -v '@[0-9a-f]\{40\}' \
  | grep -v 'uses: \./'
```

**La tercera condición no es una recomendación ni un requisito informal previo a WP-007.** La evidencia determinista del núcleo demuestra el comportamiento del comando canónico, la conformidad de la configuración y el bloqueo del preflight; **no demuestra que Claude Code aplique realmente esa configuración**. Esa demostración es exclusivamente de `WP-012`, y por eso figura aquí en pie de igualdad. Detalle del reparto en `DEC-005` §§4, 5 y 7.

Cumplidas las tres, una PR de operador cierra esta decisión y ejecuta el **paso 8** de §2.

### 7. `tests/guard/run-suite.sh`: dos líneas base, y una prohibición hacia adelante

Dos cosas que no deben confundirse:

| Línea base | Dónde | Contadores |
|---|---|---|
| **Versionada** | `main` @ `36cb46c` | **68 · 0 · 10 · 0** |
| **Candidata local** | worktree congelado de WP-007, sin versionar | **75 · 0 · 10 · 0** |

La modificación de `run-suite.sh` en ese worktree es **anterior a esta decisión** y es trabajo legítimo del contrato de WP-007. **No es incumplimiento de una pausa que aún no existía**: queda congelada por §1, no sancionada.

**Prohibición vigente hacia adelante:** ni WP-008, ni WP-009, ni ninguna otra acción admitida por §4 modifica `tests/guard/run-suite.sh`. Sus futuros contratos **deben incluirlo entre sus archivos prohibidos**.

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

**Mantenimiento.** El 2026-08-10 hay que revisar esta decisión. Si la pausa termina, la PR que la cierre debe marcarla `superada`, decir por qué acto, y arrastrar el registro de §3.

## Referencias

- [`DEC-002`](DEC-002-semantica-de-traversal.md) — su § Migración es lo que aquí se pausa
- [`DEC-001`](DEC-001-divisa-costes.md) — intacta
- [`DEC-006`](DEC-006-abandono-y-reinicio-controlado-de-wp-008.md) — recuperación excepcional de WP-008
- [`REQ-FDA-002`](../requirements/REQ-FDA-002-workflows-endurecidos.md) — incumplido, punto 2
- [`ADR-001`](../adr/ADR-001-runtime.md) — ejecución headless
- [`work-packages/WP-007-semantica-de-traversal.md`](../../work-packages/WP-007-semantica-de-traversal.md) — `ready`, congelado
- [`work-packages/WP-002-check-scope.md`](../../work-packages/WP-002-check-scope.md) — `blocked`, sin cambios
- [`docs/manual/02-ciclo-de-un-wp.md`](../../docs/manual/02-ciclo-de-un-wp.md) — PR de operador
- [`docs/manual/05-bloqueos-y-parada.md`](../../docs/manual/05-bloqueos-y-parada.md) — condiciones de parada
