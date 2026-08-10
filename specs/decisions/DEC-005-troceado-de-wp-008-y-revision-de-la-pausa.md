# DEC-005 — Revisión de la pausa, troceado de WP-008 y creación de WP-012

**Estado:** aceptada · **Fecha:** 2026-08-10 · **Ámbito:** el criterio de salida, la lista cerrada y
la secuencia de `ACTIVE` de [`DEC-003`](DEC-003-pausa-migracion-y-contencion.md), el alcance de
`WP-008` y la creación de `WP-012`
**Origen:** la revisión que `DEC-003` §5 fija para el 2026-08-10, y la auditoría independiente del
undécimo ciclo de WP-008.
**Preparación:** el borrador se redactó en solo lectura el **2026-08-09**. La **constatación de §1 y
la materialización de esta decisión corresponden únicamente al 2026-08-10**, su fecha de revisión.

## Problema

`DEC-003` §5 fija el **2026-08-10** como fecha de revisión de la pausa: «En esa fecha: o el criterio
de §6 está cumplido y la pausa termina, o **parada y análisis de causa registrado por escrito**».

El criterio **no está cumplido**, y no podía estarlo. Esta decisión es ese análisis por escrito.

## Admisión previa: esta decisión no se autoriza a sí misma

`DEC-003` §4 declara su lista «**cerrada, no ilustrativa**», y **`DEC-005` no figura en ella**. Una
decisión ausente de la lista **no puede admitirse por declaración propia**: sería circular.

El precedente de `DEC-004` §2 **no sirve como autoautorización**. `DEC-004` **ya estaba admitida** —la
lista la enumeraba como «Estados del coste. Decisión sola, sin implementación»—, y lo que enmendó por
declaración fue **su propia entrada preexistente**, ampliando la composición de su PR. Aquí no hay
entrada que enmendar. El precedente vale para la **forma** de una enmienda por declaración, no para
crear la admisión que falta.

**La admisión es un acto del operador sobre `DEC-003`, no una cláusula de este documento.** La PR que
materialice esta decisión debe **modificar `DEC-003` §4 de forma atómica**, en el mismo diff, para
incorporar a la lista cerrada:

| Admitido | Qué es |
|---|---|
| `DEC-005` | Revisión de la pausa y troceado de WP-008 |
| `WP-012` | Instrumento empírico, troceado desde WP-008 |

Si esa modificación de `DEC-003` no viaja en el mismo diff, **esta decisión no es admisible** y no
debe fusionarse.

## Decisión

### 1. Constatación de la revisión — 2026-08-10

| Condición de `DEC-003` §6 | Estado |
|---|---|
| **Runtime fail-closed probado.** WP-008 fusionado | **No cumplida.** WP-008 sigue `ready` y sin fusionar |
| **Acciones fijadas por SHA.** WP-009 fusionado | **No cumplida.** `work-packages/WP-009-*.md` **no existe**: su contrato no se ha redactado |

La segunda no podía cumplirse por construcción: `DEC-003` §2 sitúa WP-009 en el paso 4 de la
secuencia de `ACTIVE`, **después** del cierre de WP-008, y §2 impone «un WP activo cada vez, nunca
hay dos». Con WP-008 aún abierto, WP-009 no podía siquiera empezar.

**Estado de WP-008 a esta fecha.** Su rama prevista `wp/WP-008-runtime-fail-closed` existe **solo en
local**, con **cero commits por delante de `main`** y **sin publicar**. **No hay ninguna PR de
implementación abierta**, y por tanto no hay nada que cerrar, revertir ni reescribir en GitHub. Lo
único publicado de WP-008 son sus **PRs de operador**, ya fusionadas, que redactaron y replanificaron
su contrato.

**La pausa no termina hoy.** Se prorroga con el criterio de salida de §7 y el punto de control de §8.

### 2. Análisis de causa

| Magnitud | Valor |
|---|---|
| Ciclos de corrección consumidos sobre WP-008 | **11** |
| Replanificaciones humanas del contrato | **10**, entre 2026-08-08 y 2026-08-09 |
| Ejecuciones empíricas reales del runner | **3**, todas fallidas: exit 2, exit 1 y exit 2 |
| Ejecuciones empíricas conformes —14 · 13 · 1 · 0— | **0** |
| Pruebas deterministas del undécimo ciclo | **456 correctas · 0 fallidas** |
| Coste saneado acumulado de la tercera ejecución | 0,4096884 USD en siete invocaciones físicas |
| Auditoría independiente del undécimo ciclo | **NO APTO**, con dos hallazgos reproducibles |

**Los once ciclos corrigieron defectos reales.** No fueron ruido ni retrabajo evitable. Cada uno cerró
un defecto demostrado, unas veces del **contrato** —el esquema de los eventos de hook no estaba
definido; el orden causal no se exigía; la secuencia completa no se validaba; los recuentos de ciclo
de `M3.fuera` no estaban escritos— y otras de la **implementación** —asociación por subcadena,
resultados huérfanos, adquisiciones vacías, instantáneas no byte-safe, `delta_permitido` aprobando su
propio fallo—. La auditoría independiente los detectó todos **antes de cualquier fusión**. El control
de calidad no falló: funcionó once veces seguidas, y por eso no se ha fusionado nada defectuoso.

**Lo que falló fue sistémico y de otro orden.** Tras varios ciclos consecutivos sobre la misma capa,
el proceso **no reevaluó el troceado**. `docs/manual/05-bloqueos-y-parada.md` §8 enumera cuatro causas
raíz ante una parada, y **las diez replanificaciones eligieron siempre la primera** —«¿El contrato
estaba mal definido? → reescribe el WP»—, que era correcta caso a caso. **Ninguna evaluó la segunda**:
«¿El alcance estaba mal troceado? → **pártelo**». Corregir bien cada defecto sin preguntar por qué
seguían apareciendo en el mismo sitio es lo que impidió converger.

**Causa raíz declarada:** no haber reevaluado a tiempo el troceado de WP-008, pese a que once ciclos
consecutivos se concentraron en una sola de sus dos capas.

### 3. Las dos capas de WP-008

| Capa | Qué es | Estado |
|---|---|---|
| **Protección** | Reanclaje de `settings.json`, comando canónico fail-closed, preflight estructural, protocolo de parche, evidencia real de CI | Determinista, reproducible en CI, **especificada y estable desde el primer contrato, sin una sola corrección** |
| **Instrumento** | Runner empírico: catorce sondas, motor de adquisición, analizador de flujo, instantáneas, reintentos y diagnósticos | Empírico, no reproducible en CI, **once ciclos y ninguna medición conforme** |

**Por qué el corte va por capa y no por sondas.** Se descartó expresamente separar `M1–M7` de
`C1–C7`: ambos grupos comparten el **mismo motor** de adquisición, análisis, instantáneas, reintento y
diagnóstico, que es exactamente donde se produjeron los once ciclos. Ese corte dejaría el motor en el
camino crítico y no resolvería nada. Además `M6` y `M7` —hook ausente y hook sin permiso de
ejecución— **no son informativas**: tienen rama de rechazo `NO_CONFORME` propia. La única sonda sin
expectativa es `M2`.

### 4. Troceado aprobado: WP-008 núcleo y WP-012 instrumento

`WP-008` **conserva su identificador y su rama local prevista**, y **reduce su alcance** al núcleo de
protección. El instrumento empírico pasa íntegro a un contrato nuevo, **`WP-012`**, confirmado por el
operador.

El identificador se verificó contra el repositorio, no por analogía: `WP-009` está reservado a la
cadena de suministro por `DEC-003` §2, §4 y §6; `WP-010` a la adquisición de coste, al validador de
`cost.md` y al registro `specs/finops/excepciones-coste.md` por `DEC-004` §11 y §14; `WP-011` a la
frontera de revisión verificable y al hueco de revisión humana del ruleset por `DEC-003` §3 y su
sección «Riesgo identificado y NO aprobado». **`WP-012` no aparece en ninguna fuente versionada.**

| | **WP-008 — núcleo de protección** | **WP-012 — instrumento empírico** |
|---|---|---|
| Objetivo | Instalar el runtime fail-closed y su barrera en CI | Demostrar empíricamente que el runtime lo aplica |
| Cambios vedados | `.claude/settings.json`, `.github/workflows/ci.yml`, por parche humano | Ninguno |
| Scripts | `check-config.sh`, `test-check-config.sh`, `test-protocolo.sh`, `capturar-ci-rojo.sh`, `test-capturar-ci-rojo.sh`, `check-alcance-wp008.sh` | `runner-empirico.sh`, `test-runner-empirico.sh` |
| Especificación | Los dos oráculos versionados | `matriz-empirica.md`, `smoke-capacidades.md` |
| Fixtures | Configuración conforme y no conforme, proyecto para el protocolo, `ci/`, `cuarentena/` | Los **nueve** de runner |
| Sondas | Ninguna | **Catorce**: `M1–M7` y `C1–C7`, con su motor compartido íntegro |
| Composición exigida | — | **14 · 13 · 1 · 0**, sin cambios |
| Red | `gh` en solo lectura | Servicio de Claude, con sus topes |
| Reproducible en CI | **Sí** | **No** |
| `max_ciclos_correccion` | El de su contrato reducido | **2** |

**WP-012 conserva sin rebaja** las catorce sondas, la composición 14 · 13 · 1 · 0, los topes de
0,30 USD por invocación y 5,00 USD agregado, `--max-turns 4` solo en las tres subsondas tolerantes y
`--max-turns 3` en `M3.fuera` y el resto, el preámbulo cerrado exacto `ls -la`, el criterio de
abandono y la exigencia de autorización humana separada antes de cualquier ejecución real.

**`max_ciclos_correccion: 2` para WP-012.** El recuento arranca en cero porque el contrato es nuevo, y
cuenta **solo ciclos de corrección**: la implementación inicial no consume ninguno. Es deliberadamente
estrecho —frente a los once de WP-008— porque el contrato nuevo nace con todo lo aprendido escrito
desde su primera línea. Un tercer ciclo exigiría otra decisión humana, nueva y fechada.

### 5. Reparto de `tests/runtime/` y `evidence/` afectado por el troceado

**No hay ningún `tests/runtime/**` compartido.** Cada contrato declara una **lista cerrada de archivos
y prefijos físicamente disjuntos** de la del otro, de modo que ni el guard ni ningún escáner puedan
mezclarlos.

| WP | Archivos y prefijos |
|---|---|
| **WP-008** | `tests/runtime/check-config.sh` · `tests/runtime/test-check-config.sh` · `tests/runtime/test-protocolo.sh` · `tests/runtime/capturar-ci-rojo.sh` · `tests/runtime/test-capturar-ci-rojo.sh` · `tests/runtime/check-alcance-wp008.sh` · `tests/runtime/command-canonico.txt` · `tests/runtime/reglas-canonicas.txt` · `tests/runtime/fixtures/config/**` · `tests/runtime/fixtures/proyecto/**` · `tests/runtime/fixtures/ci/**` · `tests/runtime/fixtures/cuarentena/**` · **`evidence/WP-008/**`** |
| **WP-012** | **`tests/runtime/empirico/**`** · **`evidence/WP-012/**`** |

**Esta tabla NO es el alcance completo de ninguno de los dos WPs.** Reparte únicamente las rutas de
`tests/runtime/` y de `evidence/` que el troceado afecta. **El contrato reducido de WP-008 enumerará
además**, en su `## Archivos permitidos`, las rutas que el troceado no toca y que conserva íntegras:
`.claude/settings.json` y `.github/workflows/ci.yml` —ambas por parche humano—, los cinco archivos
nominales de `docs/manual/`, `docs/02-guia-fabrica-desarrollo-agentica.md` y
`specs/requirements/SEC-001-sin-secretos.md`; y en su `## Archivos prohibidos`, entre otras,
`tests/guard/run-suite.sh` y `work-packages/**`. El contrato de WP-012 hará lo propio con las suyas.

La lista de WP-008 es **exacta y cerrada** porque **ninguno de esos archivos existe todavía**. Lo que
`tests/runtime/` contiene hoy son los **trece candidatos de WP-012** —los **cuatro** principales y los
**nueve** fixtures bajo `fixtures/runner/`—, y nada más. No hay nada que mover en el núcleo, y el paso
de `ci.yml` sigue invocando `bash tests/runtime/check-config.sh` **sin cambio**.

**Evidencias, también disjuntas.** `evidence/WP-008/**` es del núcleo y **no contiene evidencia
empírica**: `evidence/WP-008/empirico/**` **queda eliminado del diseño futuro**. Todo lo que ese
directorio iba a contener —`runner.log`, `test-runner.log`, `matriz/`, `smoke/`, `recuentos.md`,
`coste.md`, `integridad.md`, `version.txt`— pasa a `evidence/WP-012/empirico/**`. Cada WP lleva además
su propio `no-regresion/`, `diff/` y `cost.md` bajo su prefijo.

**El escáner de cuarentena del núcleo deja de ser recursivo sobre `tests/runtime/`.** El §10b actual
construye su lista con «todos los archivos `*.sh` situados bajo `tests/runtime/`, recursivamente». El
contrato reducido debe **acotarlo a su propia lista cerrada más `evidence/WP-008/parche/aplicar.sh`**.
Así el invariante de cuarentena sigue cubriendo íntegramente los scripts de WP-008 —incluido el
escáner— y deja de alcanzar archivos de otro encargo. WP-012 declarará su propio control equivalente
sobre `tests/runtime/empirico/**`.

### 6. Reubicación: cero referencias obsoletas

La reubicación de los trece candidatos bajo `tests/runtime/empirico/` **no es un `mv`**. El contrato
de WP-012 debe exigir que se corrijan, **como mínimo**, todas estas clases de referencia:

| Clase | Ejemplos que se sabe que existen hoy |
|---|---|
| **Rutas de plantillas** | `PLANTILLAS="$REPO_ROOT/tests/runtime/fixtures/runner"` en `runner-empirico.sh` |
| **Comandos de uso** | Las líneas `Uso:` de las cabeceras de ambos scripts, y `bash tests/runtime/runner-empirico.sh` allí donde aparezca |
| **Comentarios** | Las referencias a `tests/runtime/matriz-empirica.md` y `tests/runtime/smoke-capacidades.md` en las cabeceras de precedencia de ambos scripts |
| **Documentos** | Los enlaces relativos de `matriz-empirica.md` y `smoke-capacidades.md`: al bajar un nivel, `../../work-packages/…` y `../../specs/…` pasan a `../../../…`, y el enlace mutuo entre ambos se mantiene |
| **Evidencias** | Toda ruta bajo `evidence/WP-008/empirico/**` pasa a `evidence/WP-012/empirico/**` |
| **Magnitudes de integridad** | La magnitud 4 enumera hoy `tests/runtime/**` y `evidence/WP-008/parche/aplicar.sh`: debe acotarse al prefijo de WP-012, o dejará de ser estable en cuanto el núcleo escriba sus archivos |
| **Referencias contractuales antiguas** | Toda mención a rutas de `WP-008` que ya pertenezcan a `WP-012` |

**Criterio de aceptación, determinista y verificable:** una búsqueda sobre el repositorio de los
patrones `tests/runtime/runner-empirico.sh`, `tests/runtime/test-runner-empirico.sh`,
`tests/runtime/matriz-empirica.md`, `tests/runtime/smoke-capacidades.md`,
`tests/runtime/fixtures/runner` y `evidence/WP-008/empirico` debe devolver **cero coincidencias**
fuera del propio registro histórico de esta decisión y de las replanificaciones ya fusionadas de
WP-008, que son inmutables. El contrato de WP-012 fijará el comando exacto y su código de salida.

`test-runner-empirico.sh` carga el runner por `dirname "$0"` y **no requiere cambio** por la
reubicación.

### 7. Enmienda de `DEC-003` §6 — tercera condición de salida

El criterio de salida pasa a tener **tres** condiciones. La tercera es **nueva y expresa**: WP-012 no
se describe como requisito informal previo a WP-007, sino como condición de salida en pie de igualdad.

- [ ] **Runtime fail-closed instalado.** `WP-008` fusionado: comando canónico anclado con
      `CLAUDE_PROJECT_DIR` y normalizado a `exit 2`; ocho reglas reancladas a la raíz del proyecto;
      preflight estructural bloqueante en el job `Gobierno FDA`, con una **ejecución roja real de CI**
      que demuestre el bloqueo, capturada como evidencia.
- [ ] **Acciones fijadas por SHA.** `WP-009` fusionado: el criterio de verificación n.º 2 de
      `REQ-FDA-002` devuelve vacío.
- [ ] **Runtime fail-closed demostrado empíricamente.** `WP-012` fusionado: el runner empírico termina
      en **exit `0`** con la composición exacta **14 sondas lógicas · 13 CONFORME ·
      1 REGISTRADA_FUERA_DE_CONTRATO · 0 NO_CONFORME**, sin errores de entorno, con sus resultados
      saneados incorporados como evidencia bajo `evidence/WP-012/**`.

**Ninguna sustituye a otra.** La primera instala, la segunda cierra la cadena de suministro y la
tercera demuestra. **No hay reducción de controles**: WP-012 no se retira del criterio de salida, se
reordena.

### 8. Enmienda de `DEC-003` §2 y §5 — `ACTIVE`, secuencia y punto de control

**Transición inmediata de `work-packages/ACTIVE`.** El archivo contiene hoy `WP-008`. La PR que
materialice esta decisión debe **devolverlo a reposo** en el mismo diff, como acto del operador. El
archivo resultante es byte a byte idéntico al que ya tuvo en `8190976`.

**El contrato actual de `WP-008` queda congelado.** Con `ACTIVE` en reposo no hay ninguna ruta
autorizada y ningún agente escribe sobre él. **Solo podrá reactivarse cuando su versión reducida esté
materializada, validada y aprobada**, en una PR de operador posterior. Hasta entonces, el contrato de
2152 líneas permanece en el repositorio como estado histórico y **no gobierna ningún trabajo**.

Secuencia confirmada de `ACTIVE`, en este orden estricto, cada transición un acto del operador:

| Paso | `ACTIVE` | Condición para pasar al siguiente |
|---|---|---|
| 1 | **Reposo** | Materialización de esta decisión |
| 2 | `WP-008` (núcleo) | Su contrato **reducido**, validado y aprobado, y el aislamiento de §9 completado |
| 3 | **Reposo** | Cierre de WP-008 |
| 4 | `WP-009` | Su contrato completo, validado y aprobado |
| 5 | **Reposo** | Cierre de WP-009 |
| 6 | `WP-012` | Su contrato completo, validado y aprobado, y las precondiciones de §9 verificadas |
| 7 | **Reposo** | Cierre de WP-012 |
| 8 | `WP-007` | **Solo** al cumplirse las **tres** condiciones de §7; cierra la pausa |

**Un WP activo cada vez. Nunca hay dos.** Entre WPs, reposo.

**Punto de control: 2026-09-07.** Sustituye a la fecha de `DEC-003` §5. Es un **punto de control, no
una promesa de finalización**: llegar a esa fecha sin haber cumplido el criterio de §7 **no es un
incumplimiento**, sino el disparador del mismo acto que hoy —revisión y **análisis de causa registrado
por escrito**—. Esta caducidad rige **la pausa**, no el estado externo de `DEC-003` §3, cuyas
condiciones de término siguen siendo WP-011 y el fin de la calibración.

### 9. Aislamiento del trabajo candidato de WP-012

Existen hoy en el árbol principal, **sin versionar**, **trece** archivos que son el trabajo candidato
del undécimo ciclo y pertenecen a WP-012. Se conservan íntegros y **no se revierten**.

| # | Ruta actual | Destino bajo `tests/runtime/empirico/` | Tipo | Modo | SHA-256 |
|---|---|---|---|---|---|
| 1 | `tests/runtime/runner-empirico.sh` | `runner-empirico.sh` | regular | **`755`** | `811890e96a45228469ddf4e51199be8d9bbbc995535004aef17f26e2b8855c43` |
| 2 | `tests/runtime/test-runner-empirico.sh` | `test-runner-empirico.sh` | regular | `644` | `0e54c26d243d484eb08ba92ac4f9a30ca77320b073c847acdbd0eb1dafd616fa` |
| 3 | `tests/runtime/smoke-capacidades.md` | `smoke-capacidades.md` | regular | `644` | `5294a87c4118860294288b27ae7784c0d2962e8e847317e9e3110c1f778f46fe` |
| 4 | `tests/runtime/matriz-empirica.md` | `matriz-empirica.md` | regular | `644` | `3873cda5df2214f936d9ae285a37b0dab431a0cee2e0dc84b31321d5390e59c0` |
| 5 | `tests/runtime/fixtures/runner/active` | `fixtures/runner/active` | regular | `644` | `df315fb7bd247205e47900da069ab1097a8c9d0b792e91dec1959ad3cd4b9758` |
| 6 | `tests/runtime/fixtures/runner/guard-exit0.sh` | `fixtures/runner/guard-exit0.sh` | regular | **`755`** | `22a501de9f5e1f7944fbdb750e49629f181724bcd6969c53a1916949ec95954f` |
| 7 | `tests/runtime/fixtures/runner/guard-exit1.sh` | `fixtures/runner/guard-exit1.sh` | regular | **`755`** | `b7c08551351f60e2c966e714340c5e309354be9de7c9c3f396a1e46ccb4f8a8c` |
| 8 | `tests/runtime/fixtures/runner/guard-exit2.sh` | `fixtures/runner/guard-exit2.sh` | regular | **`755`** | `2cbf53430d04f70bcf3f6e3415655454ab8379f638658c7a8a4747ace23c5d12` |
| 9 | `tests/runtime/fixtures/runner/settings-canonico-debug.json` | `fixtures/runner/settings-canonico-debug.json` | regular | `644` | `d544aed760b1dc6addb1f523ff2f4cae0e6d047b5f2ee5626fe79fb5582ca079` |
| 10 | `tests/runtime/fixtures/runner/settings-canonico.json` | `fixtures/runner/settings-canonico.json` | regular | `644` | `cf6594b626290d4d5624b13782e5243d95a51592aa275412bb550a5bea3b8b8e` |
| 11 | `tests/runtime/fixtures/runner/settings-directo.json` | `fixtures/runner/settings-directo.json` | regular | `644` | `2b6fa5ca3edfa7f496ddc2f55e0a5858bdc351d2a2359cc510e3f0dbde48da42` |
| 12 | `tests/runtime/fixtures/runner/settings-neutro.json` | `fixtures/runner/settings-neutro.json` | regular | `644` | `e0703cbe338aab8aa9dc10e14a156e943e051933c0f6bcbbc7c5bf499d47972b` |
| 13 | `tests/runtime/fixtures/runner/wp-fixture.md` | `fixtures/runner/wp-fixture.md` | regular | `644` | `0cd103c770e185b7a022e2a04eb209e204d1d117ebc323f9d97e3b245a125aeb` |

**El bit de ejecución es contractual, no cosmético.** Los tres `guard-exit*.sh` son guards triviales
que el runner **ejecuta**, y `M7` mide precisamente un hook **sin** bit de ejecución. Un respaldo que
pierda el modo `755` invalidaría `C4`, `C5` y la construcción de `M7`.

**Manifiesto de aislamiento.** Registra, por entrada: **ruta origen**, **ruta destino**, **tipo**,
**modo** y **SHA-256**, más el **recuento total: 13**. El conjunto de rutas forma parte del
manifiesto: no basta con que los hashes coincidan; **no puede sobrar ni faltar ninguna ruta**.

**Vía confirmada: respaldo externo recuperable y worktree independiente.** Tres fases, todas actos
humanos. **Ninguna se ejecuta con esta decisión.**

- **Fase A — respaldo recuperable, fuera del repositorio.** Copiar los trece **preservando modos** a un
  directorio externo a la raíz física del repositorio, junto con el manifiesto. Verificar las cuatro
  magnitudes —conjunto de rutas, tipo, modo y SHA-256— contra la tabla anterior. **Si alguna difiere:
  parada y análisis, nunca actualización de la tabla.** El respaldo debe ser **recuperable por sí
  solo**, sin depender del árbol de trabajo ni del worktree.
- **Fase B — worktree independiente de WP-012.** Crear un worktree propio desde `origin/main` en la
  rama `wp/WP-012-*`, **fuera** del árbol principal, y restituir allí los trece bajo
  `tests/runtime/empirico/`, preservando modos. Reverificar las cuatro magnitudes.
- **Fase C — retirada del árbol principal.** Solo con A y B verificadas, retirar los trece del árbol
  principal, de modo que `tests/runtime/` quede libre para el núcleo. Comprobar después que no queda
  ninguno, que el árbol sigue sin cambios rastreados ni preparados y que el respaldo externo sigue
  verificando.

**Precondición de activación de WP-012.** Antes del paso 6 de §8, y como requisito de activación:

1. El **`HEAD` de la rama `wp/WP-012-*` debe ser exactamente igual** al `origin/main` posterior a la
   fusión de WP-008 y de WP-009: `git rev-parse HEAD` y `git rev-parse origin/main` deben devolver el
   **mismo hash**. **No basta con una relación de ancestro ni con que el fast-forward sea posible: se
   exige igualdad.** Como el trabajo candidato está **sin versionar**, alcanzarla **no reescribe
   ningún historial**: la rama no tiene commits propios.
2. Tras esa igualdad, **se reverifican las trece rutas, tipos, modos y SHA-256** contra el manifiesto.
   Cualquier discrepancia: **parada y análisis**.

**Prohibido en todas las fases:** `git add`, `commit`, `stash`, cambio de rama del árbol principal, y
**cualquier retirada anterior a la verificación completa de A y B**. Si una fase falla a mitad, el
respaldo de la fase A es la vía de recuperación y su integridad se comprueba antes de nada.

**El worktree de WP-012 no autoriza trabajo.** Es custodia. El primer ciclo no empieza hasta que su
contrato esté materializado, validado, aprobado y activo en `ACTIVE`.

### 10. Historia heredada: los once ciclos no se borran

`WP-012` nace con contrato propio y con `max_ciclos_correccion: 2`. **Eso no reinicia ningún
marcador.**

1. Los **once ciclos consumidos** pertenecen al contrato de `WP-008` y quedan registrados aquí, con
   sus causas y sus tres ejecuciones empíricas fallidas.
2. El presupuesto nuevo se concede sobre un **contrato nuevo y mejor troceado**, que incorpora desde
   su primera línea todo lo aprendido: esquema contractual de los eventos de hook, orden causal,
   secuencia completa, preámbulo acotado, adquisición vacía y reintento único, resultados huérfanos,
   campos vinculantes, instantáneas byte-safe y fail-closed de tres estados. Es el mismo criterio con
   que la replanificación del 2026-08-08 concedió su tercer hueco.
3. **Dos ciclos, no once.** El presupuesto estrecho es deliberado: si un contrato que nace con todo lo
   aprendido necesitara más de dos correcciones, la causa raíz ya no sería el troceado, y esta
   decisión **no autoriza por anticipado ninguna respuesta a esa situación**.

### 11. Los dos hallazgos del undécimo ciclo pasan a WP-012

La auditoría independiente declaró **NO APTO** con dos hallazgos reproducibles. Ambos se trasladan al
**primer ciclo de `WP-012`**, y su contrato debe recogerlos **expresamente y como obligatorios**:

| # | Hallazgo | Clasificación y tratamiento |
|---|---|---|
| 1 | El diagnóstico saneado del intento abortado antes de la segunda invocación arrastra `precondicion=ok` e `instantanea=sin_delta` del primer intento y registra `motivo=sin_analisis`, cuando la causa real fue que el fixture cambió entre intentos | **Defecto contractual.** Incumple la exigencia de registrar «el diagnóstico saneado **correspondiente**». Su prueba solo contaba líneas, sin comprobar la causa, de modo que incumple además la regla de que todo campo vinculante tenga una prueba negativa que alcance el rechazo final. **Se corrige, con prueba de la causa registrada** |
| 2 | El parser de instantáneas valida cabecera, NUL final y aridad, pero no rutas relativas, únicas y ordenadas, ni tipos permitidos, ni formato de modo, ni forma del digest, ni coherencia entre tipo y carga | **Endurecimiento obligatorio.** No es incumplimiento —el contrato fija propiedades de la representación y la propagación de fallos de parseo, y el único generador es controlado—, pero **queda contratado en WP-012** como defensa en profundidad, con su razón escrita: **el parser no confía en su propio generador** |

**El undécimo ciclo queda consumido y su resultado es NO APTO.** El trabajo candidato se conserva
íntegro conforme a §9 y **no se revierte**: es materialmente superior al del décimo ciclo y es el
punto de partida de WP-012.

### 12. Qué NO autoriza esta decisión

1. **No autoriza el duodécimo ciclo de WP-008.** WP-008 pierde la capa de instrumento y no vuelve a
   tener ciclos sobre ella.
2. **No autoriza ninguna ejecución del runner real**, ni ahora ni al materializarse WP-012. Sigue
   exigiendo autorización humana separada y posterior.
3. **No materializa ningún WP.** Ni el contrato reducido de WP-008, ni el de WP-012. Ambos son actos
   del operador en PRs separadas.
4. **No ejecuta el aislamiento de §9.** Lo diseña; no lo realiza.
5. **No reactiva WP-008.** `ACTIVE` queda en reposo y su contrato actual, congelado.
6. **No levanta la congelación de WP-007**, no altera las siete magnitudes de `DEC-003` §1, no toca
   `tests/guard/run-suite.sh` —cuya prohibición de `DEC-003` §7 **deben recoger** los contratos de
   WP-008 reducido y de WP-012 entre sus archivos prohibidos—, no reactiva ningún workflow y no
   modifica el ruleset.
7. **No adelanta WP-009, WP-010 ni WP-011**, cuyas reservas se conservan intactas.

### 13. Secuencia operativa completa

Del estado de hoy al cierre de la pausa, en este orden estricto. Cada paso es un acto del operador o
un ciclo de WP con su propia PR.

| # | Paso | Qué ocurre |
|---|---|---|
| 1 | **DEC-005 y reposo** | PR de operador de cuatro archivos: `DEC-003` modificada, `DEC-005` creada, manual actualizado y `ACTIVE` a **reposo**. WP-008 queda congelado |
| 2 | **Contrato reducido de WP-008** | PR de operador que reescribe `WP-008` al núcleo de protección, con su lista cerrada, `evidence/WP-008/**` sin capa empírica y el §10b acotado |
| 3 | **Aislamiento, fases A–C** | Respaldo externo recuperable con manifiesto · worktree independiente de WP-012 con los trece restituidos bajo `tests/runtime/empirico/` · retirada del árbol principal. Verificación de las cuatro magnitudes en cada fase |
| 4 | **Activación y cierre de WP-008** | `ACTIVE` ← `WP-008` · implementación, parche rojo/verde, capturas reales de CI · fusión humana · `ACTIVE` ← **reposo** |
| 5 | **Materialización, activación y cierre de WP-009** | Contrato de la cadena de suministro · `ACTIVE` ← `WP-009` · implementación · fusión humana · `ACTIVE` ← **reposo** |
| 6 | **Contrato de WP-012** | PR de operador con el contrato del instrumento, `max_ciclos_correccion: 2`, los dos hallazgos y el criterio de cero referencias obsoletas |
| 7 | **Igualdad con `origin/main` y reverificación** | `HEAD` de `wp/WP-012-*` **exactamente igual** al `origin/main` posterior a WP-008 y WP-009 · reverificación de las trece rutas, tipos, modos y SHA-256 |
| 8 | **Activación y cierre de WP-012** | `ACTIVE` ← `WP-012` · implementación · **autorización humana separada** de la ejecución empírica · fusión humana · `ACTIVE` ← **reposo** |
| 9 | **Comprobación de las tres condiciones** | Verificación de las tres casillas de §7, cada una con su evidencia |
| 10 | **WP-007 y cierre de la pausa** | `ACTIVE` ← `WP-007` · PR de operador que cierra `DEC-003`, marca su estado y **arrastra el registro** de su §3 |

## Consecuencias

**A favor.** La protección deja de estar bloqueada por un instrumento que no converge y puede
instalarse y demostrarse en CI en plazo corto. El instrumento recibe contrato, presupuesto y ciclo de
revisión propios, con un enunciado que ya incorpora once ciclos de aprendizaje. El criterio de salida
**no pierde ninguna garantía**: gana una tercera condición explícita. Los alcances y las evidencias
disjuntos eliminan de raíz el acoplamiento entre dos encargos sobre el mismo árbol. Y la causa raíz
queda evaluada contra la segunda entrada del manual §8, no contra la primera por inercia.

**En contra.** La pausa se prolonga y `DEC-002` sigue a medias. Entre la fusión de WP-008 núcleo y la
de WP-012 existirá una ventana en la que la protección está instalada pero su aplicación por el
runtime **no** está demostrada empíricamente; la tabla de garantías la declara y §7 la cierra. La
secuencia estricta de un WP activo cada vez impide adelantar trabajo en paralelo, de modo que el orden
confirmado tiene coste de calendario real. Y la reubicación bajo `tests/runtime/empirico/` obliga a
WP-012 a absorber en su primer ciclo los ajustes de §6, con `max_ciclos_correccion: 2` como margen.

**Riesgo declarado y no resuelto aquí.** Si `WP-012` agotara sus dos ciclos sin converger, habrá que
decidir si el runner empírico es viable con las herramientas actuales o si la demostración de que el
runtime aplica la configuración debe buscarse por otra vía. Esta decisión **no** anticipa esa
respuesta.

**Mantenimiento.** El 2026-09-07 hay que revisar esta decisión y `DEC-003`. La PR de operador que
cierre la pausa debe **arrastrar el registro** del estado externo de `DEC-003` §3, que no caduca con
ella.

## Referencias

- [`DEC-003`](DEC-003-pausa-migracion-y-contencion.md) — §2, §4, §5 y §6, modificados atómicamente por la misma PR
- [`DEC-004`](DEC-004-estados-del-coste.md) — §2, precedente de forma; **no** de autoautorización
- [`ADR-001`](../adr/ADR-001-runtime.md) — I2 e I3, ejecución headless
- [`work-packages/WP-008-runtime-fail-closed.md`](../../work-packages/WP-008-runtime-fail-closed.md) — contrato congelado, a reducir
- [`docs/manual/05-bloqueos-y-parada.md`](../../docs/manual/05-bloqueos-y-parada.md) — §8, causas raíz
- `REQ-FDA-002` — criterio de verificación n.º 2, condición de WP-009
