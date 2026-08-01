# DEC-002 — Semántica de traversal en las rutas de alcance

**Estado:** aceptada · **Fecha:** 2026-07-29 · **Ámbito:** toda implementación de la semántica de `## Archivos permitidos` — `.claude/hooks/guard.sh`, `scripts/check_scope.py` y `work-packages/_TEMPLATE.md`
**Origen:** contradicción detectada al preparar la implementación de WP-002 entre la prosa de `work-packages/_TEMPLATE.md` (línea 73) y el comportamiento real de `.claude/hooks/guard.sh` (§8). Condición de parada n.º 2 —contradicción entre requisitos—, resuelta por el responsable.

## Problema

Hay **tres** normas vigentes a la vez sobre qué significa que una ruta «tenga traversal», y las tres dicen cosas distintas.

1. **`work-packages/_TEMPLATE.md`, sección «TRAVERSAL Y ENLACES» (línea 73):**

   > Cualquier ruta que contenga `..` se deniega, coincida o no con un patrón.

   Lectura literal: **subcadena**. `evidence/WP-002/notas..md` quedaría denegado.

2. **`work-packages/WP-002-check-scope.md`, sección «Semántica de patrones»:** repite esa prosa —«toda ruta que contenga `..` se deniega»— y añade el **invariante crítico** de que `check_scope.py` y `guard.sh` deben coincidir en su interpretación de los patrones, porque una divergencia produciría «un cambio que el hook permite y el CI rechaza, o al revés».

3. **`.claude/hooks/guard.sh`, §8 (`check_target`):** implementa una tercera cosa.

   ```bash
   case "$_rel" in
     *../*|*/..|..) deny "Ruta con traversal (..): $_raw" ;;
   esac
   ```

   Deniega la subcadena `../` en cualquier posición, el sufijo `/..` y la ruta `..` exacta. **No** es la semántica de subcadena de la prosa, y **tampoco** es la de componente.

Medido sobre `guard.sh` en el commit `305ed00`, con WP-002 activo y rutas de su propia allowlist —de modo que la única causa posible de denegación sea el traversal—: `evidence/WP-002/notas..md`, `evidence/WP-002/..hidden.md` y `evidence/WP-002/bar..` salen con exit `0` pese a contener `..`, lo que **contradice la prosa**; y `evidence/WP-002/foo../bar` sale con exit `2` y mensaje de traversal, lo que contradice cualquier lectura razonable del término: `foo..` es un nombre de directorio legítimo.

**Por qué esto bloquea y no es un matiz.** WP-002 exige simultáneamente dos cosas incompatibles: implementar «la semántica documentada en `_TEMPLATE.md`» y coincidir con `guard.sh`. Quien siga la prosa diverge del hook; quien copie el hook contradice el contrato escrito, que es lo que el `code-reviewer` comprobará. El propio WP-002 anticipa el caso en dos de sus condiciones de parada específicas: «ambigüedad en la semántica de los globs → parar» y «si al implementar se descubre que `guard.sh` interpreta algún patrón de forma distinta a lo documentado: parar y reportar».

[`docs/manual/05-bloqueos-y-parada.md`](../../docs/manual/05-bloqueos-y-parada.md) §2 fija el procedimiento, y es el que se sigue aquí: **no se resuelve dentro del WP.** Se resuelve en `specs/`, se registra como `DEC-xxx`, y **después** se actualiza el WP. Un WP no puede sobrescribir un requisito en silencio.

**Coste de cada lectura errónea.** La de subcadena produce falsos positivos sobre nombres legítimos —`notas..md`, `..hidden.md`, `bar..`, `config..bak`— que no son hipotéticos. La de `guard.sh` produce una clase de falso positivo más estrecha pero igual de real (`foo../bar`). Ninguna de las dos aporta seguridad frente a la de componente: **no existe ningún escape de directorio que no requiera un componente `..`**.

## Decisión

**«Traversal es un componente, no una subcadena.»**

### 1. Definición

Una ruta tiene **traversal** si y solo si **alguno de sus componentes es exactamente `..`** —dos puntos y nada más—. Una subcadena `..` dentro de un nombre legítimo **no** es traversal.

### 2. Comprobación textual, sin consultar el sistema de archivos

La ruta se separa por `/` y se examina cada componente resultante. **No se consulta el sistema de archivos:** nada de `realpath()`, `os.path.abspath()`, `stat()`, `readlink()` ni comprobación de existencia. Es una operación de cadena, determinista, que da el mismo resultado exista o no la ruta —condición sin la cual el control no sería reproducible en headless ni sobre un diff.

La separación por `/` es la **única** operación que esta decisión introduce sobre la ruta. No autoriza ninguna otra transformación.

### 3. Un componente `..` nunca se resuelve

Un `..` no se pliega contra el componente que lo precede. `evidence/WP-002/../WP-002/log.txt` **no** se convierte en `evidence/WP-002/log.txt`: conserva su componente `..` y se deniega, aunque el resultado del plegado hubiera caído dentro del alcance.

Dos motivos independientes, cualquiera de ellos suficiente:

- **Anularía el control.** Plegar permite construir rutas que contienen `..` y aun así se evalúan como si no lo tuvieran: la del ejemplo pasaría de denegada a permitida sin que cambie nada del contrato.
- **Es incorrecto incluso textualmente.** Si `evidence/WP-002` fuera un symlink, `evidence/WP-002/..` **no** es `evidence/`. El plegado asume una equivalencia que el sistema de archivos no garantiza, que es justamente la premisa que la sección «Symlinks» de WP-002 prohíbe asumir.

Consecuencia operativa: si hay un componente `..`, se deniega **sin llegar a evaluar los patrones**.

### 4. Alcance estricto de esta decisión

DEC-002 decide **únicamente** si existe un componente exactamente igual a `..`. **No define, no cambia y no introduce** tratamiento alguno para:

- componentes `.`;
- separadores duplicados;
- separadores iniciales o finales;
- mayúsculas y minúsculas;
- ningún otro aspecto de la forma de la ruta.

Cada implementación conserva en esos puntos **exactamente el comportamiento que tiene hoy**. Modificar cualquiera de ellos exige su propia decisión versionada, y queda fuera de este documento.

Tampoco se amplía aquí la interfaz de `check_scope.py`. Git no puede versionar una ruta con un componente `..` —no pueden existir en un árbol—, de modo que el caso no se presenta sobre un diff; las entradas imposibles o corruptas siguen sujetas al **fail-closed ya definido por WP-002**, sin códigos de salida nuevos ni semántica nueva.

### 5. Precedencia: el traversal se juzga antes que el alcance

El traversal se comprueba **antes** de `## Archivos permitidos` y de `## Archivos prohibidos`, y deniega **coincida o no con un patrón**. Esta parte de la prosa de `_TEMPLATE.md` se mantiene íntegra: no es una decisión de allowlist, es una decisión de **buena formación de la ruta**. En `guard.sh` el veredicto sigue siendo exit `2` con el mensaje `Ruta con traversal (..)`, como hoy.

### 6. Los destinos de symlink se rigen por otra regla, que no cambia

Es la distinción que más fácilmente se implementa mal, así que se escribe explícita:

| Qué se está juzgando | Tratamiento de `..` | Criterio de denegación |
|---|---|---|
| **Ruta versionada / ruta de escritura** | **Nunca** se resuelve | Cualquier componente `..` → traversal |
| **Destino de un symlink** (contenido del blob) | **Sí** se resuelve, textualmente y contra el directorio del enlace, sin tocar disco | Destino absoluto; o destino que tras resolverlo sale de la raíz del repositorio; o destino fuera de permitidos o dentro de prohibidos |

La sección «Symlinks» de WP-002 **queda intacta**. Allí `..` es información legítima —es cómo un enlace relativo expresa a dónde apunta— y hay que resolverlo para poder juzgarlo. Confundir ambas reglas produce uno de dos defectos, los dos graves: un verificador de enlaces incapaz de seguir ningún destino relativo, o un verificador de rutas que se traga el traversal.

### 7. Casos discriminantes (vinculantes)

Casos **mínimos**, medidos sobre `guard.sh` en `305ed00`. Las rutas se instancian dentro de la allowlist de WP-002 —`evidence/WP-002/**`— para aislar el traversal como única causa posible de denegación.

| Ruta | ¿Traversal? | Motivo | `guard.sh` hoy | Tras WP-007 |
|---|---|---|---|---|
| `evidence/WP-002/notas..md` | **no** | `notas..md` es un nombre legítimo | permite | permite |
| `evidence/WP-002/..hidden.md` | **no** | empieza por `..` pero no **es** `..` | permite | permite |
| `evidence/WP-002/bar..` | **no** | termina en `..` pero no **es** `..` | permite | permite |
| `evidence/WP-002/foo../bar` | **no** | `foo..` no es `..` | **deniega — falso positivo** | **permite** |
| `..` | **sí** | el único componente es `..` | deniega | deniega |
| `../x` | **sí** | primer componente `..` | deniega | deniega |
| `evidence/WP-002/../x` | **sí** | componente intermedio `..` | deniega | deniega |
| `evidence/WP-002/..` | **sí** | último componente `..` | deniega | deniega |

**Una sola fila cambia de veredicto:** `foo../bar`. Las otras siete ya coinciden con esta decisión; lo que hacen es fijarlas por escrito y protegerlas con pruebas, para que ninguna implementación futura las reinterprete.

Esta tabla es el **criterio de conformidad**. Toda implementación de la semántica debe reproducirla, y los casos deben existir como pruebas ejecutables en `tests/guard/run-suite.sh` y en `tests/scope/`.

### 8. El invariante crítico se reafirma, y no se abre ninguna ventana

`guard.sh` y `check_scope.py` deben emitir el **mismo veredicto en las ocho filas**, en todo momento. La secuencia de la sección «Migración» está ordenada precisamente para eso: **`guard.sh` se corrige y se fusiona antes de que WP-002 se reinicie**. No se implementa ni se fusiona ninguna versión de `check_scope.py` con una semántica distinta de la del hook vigente, ni siquiera transitoriamente. No hay ventana de divergencia y, por tanto, no hay deuda que declarar por este concepto.

## La lectura del contrato desde el `merge-base` queda intacta

DEC-002 cambia **el contenido de la semántica**, no **la fuente de verdad del contrato**. Son dos cosas distintas y no deben mezclarse.

Sigue vigente palabra por palabra la sección «Fuente de confianza del contrato» de WP-002:

1. El rango se acepta **exclusivamente** en la forma canónica `<base>...<head>`. Cualquier otra forma —`<base>..<head>`, una sola revisión, cadena vacía— es error fail-closed → exit `2`.
2. La revisión base es `git merge-base <base> <head>`, y es la **única** revisión confiable, por ser anterior a todo commit de la rama que se juzga.
3. El contrato se localiza y se lee **de esa revisión mediante objetos Git** —`git ls-tree -r --name-only <merge-base> -- work-packages/` y `git cat-file blob <merge-base>:<ruta>`—. Queda prohibido `open()` sobre el working tree y queda prohibido resolver contra `HEAD`.
4. Unicidad: exactamente un contrato para el WP-ID en la revisión base. Cero → exit `2`. Dos o más → exit `2`.
5. Buena formación: sin `## Archivos permitidos`, o vacía tras el parseo → exit `2`. Una allowlist vacía **nunca** significa «todo permitido».

**Advertencia explícita, porque esta decisión crea la tentación.** La existencia de DEC-002 **no** es motivo para leer «el contrato actualizado» desde `HEAD` ni desde el working tree. Lo que DEC-002 gobierna es **cómo se interpretan los patrones**, y eso vive en el código del verificador, no en el dato que se lee en cada ejecución:

- **La semántica vive en el programa** —compilada en `check_scope.py`, cubierta por `tests/scope/`—.
- **El contrato vive en el `merge-base`** —leído por objetos Git, en cada ejecución—.

Corolario: **`check_scope.py` no lee `specs/decisions/` en tiempo de ejecución.** No abre este archivo, no lo parsea y no depende de que exista en la revisión que juzga. Si lo hiciera, habría convertido una norma en un dato manipulable desde la propia rama juzgada, que es exactamente el fallo que la fuente de confianza existe para evitar.

El **caso 8** de WP-002 —contrato propio manipulado que añade rutas permitidas y aun así sigue siendo violación— queda **intacto** y sigue siendo la prueba de que la fuente de confianza es el `merge-base`.

## Estado de WP-002

WP-002 está **materialmente detenido desde el hallazgo**: no se implementa, no avanza ninguna rama y no se produce código contra un contrato que no es implementable tal como está escrito. Su sección «Semántica de patrones» exige a la vez la lectura de subcadena y la coincidencia con `guard.sh`, y ambas no pueden cumplirse simultáneamente. No es un problema de implementación que se resuelva con más esfuerzo: es un **defecto del contrato**, y por tanto una Definition of Ready rota.

Su cambio versionado a `estado: blocked` ocurre en **PR-2**, no en esta PR. **Esta PR registra únicamente DEC-002:** no modifica `work-packages/**`, no toca `work-packages/ACTIVE`, no toca `guard.sh` y no cambia ningún comportamiento.

## Migración

Cuatro PRs, en este orden estricto.

**PR-1 — únicamente DEC-002 (esta PR, operador).** Registra `specs/decisions/DEC-002-semantica-de-traversal.md` y nada más. `guard.sh` sigue operando exactamente como hoy, `_TEMPLATE.md` conserva su redacción y todavía no existe código que lea esta norma. Que la decisión se fije antes de que nadie implemente contra ella es el objetivo, no un efecto secundario.

**PR-2 — PR de operador.**

- `work-packages/_TEMPLATE.md`: alinear la línea 73 con DEC-002.
- `work-packages/WP-002-check-scope.md`: alinear la sección «Semántica de patrones» con DEC-002 y marcar el WP `blocked`.
- Crear **WP-007** —alineación de `guard.sh` con DEC-002— en estado `ready`.
- `work-packages/ACTIVE`: activar WP-007.
- Actualizar `docs/manual/` en lo que exija el CI.

Es un acto de operador y no puede ser otra cosa: son exactamente las rutas que WP-002 tiene prohibidas, y `ACTIVE` no figura en el alcance de ningún WP por diseño.

**PR-3 — WP-007.** Corrige `guard.sh` sustituyendo `*../*|*/..|..` por la comprobación por componente; añade a `tests/guard/run-suite.sh` las **siete** pruebas discriminantes —las ocho filas de la tabla menos `../x`, ya cubierta por el caso existente `traversal ../fuera.txt`—; aporta las evidencias; actualiza el manual en lo que exija el CI. Los diez `xfail` siguen siendo diez: este cambio no altera ninguno, añade casos que pasan.

`Edit(./.claude/hooks/**)` figura en el `deny` de `.claude/settings.json`, de modo que **ningún agente puede aplicar el cambio, tenga WP-007 el alcance que tenga**. Son dos capas distintas: el WP dice qué es del encargo, `settings.json` dice qué no toca ninguna máquina. La vía es la del manual —el agente prepara un **parche protegido y verificado**, con copia de seguridad previa, validaciones posteriores y comprobación por huella de que no toca nada más, y **una persona lo ejecuta**—. La **fusión también es humana**.

**PR-4 — PR de operador.** Marcar WP-007 `done`, devolver WP-002 a `ready` y activarlo en `work-packages/ACTIVE`.

**Solo después** se reinicia WP-002 y se implementa `check_scope.py` **desde el nuevo `main`**, con un `guard.sh` ya alineado. Es lo que garantiza que las dos capas nunca lleguen a discrepar.

## Consecuencias

**A favor:** una sola norma escrita en lugar de tres lecturas incompatibles; desaparecen los falsos positivos sobre nombres de archivo legítimos; la definición es comprobable con una tabla cerrada e independiente del lenguaje de implementación; la comprobación es puramente textual, de modo que el control es determinista, headless y reproducible sobre un diff sin working tree; y **no se pierde seguridad**, porque ningún escape de directorio es expresable sin un componente `..`.

**En contra:** exige tocar `guard.sh`, que es el archivo más protegido del repositorio, y eso obliga a un WP propio, un parche aplicado a mano y dos PRs de operador alrededor. Es lento. Aceptado: la alternativa —dejar el hook con la comparación por subcadena `../`— perpetúa una divergencia entre las dos capas, que el propio WP-002 califica como «el fallo más grave que puede introducir este WP». Segundo punto en contra: WP-002 queda parado durante cuatro PRs. También aceptado, y por el mismo motivo: implementarlo antes significaría elegir una de las tres lecturas por cuenta propia.

**Mantenimiento:** cualquier tercera implementación de esta semántica —un linter, un job de CI, un port a otro lenguaje— debe citar DEC-002 y reproducir la tabla del punto 7. Si algún día aparece un caso que la tabla no cubre, **es una parada** y una ampliación de este documento, no una interpretación local.

## Referencias

- [`work-packages/_TEMPLATE.md`](../../work-packages/_TEMPLATE.md) — sección «Archivos permitidos» → TRAVERSAL Y ENLACES (línea 73 en `305ed00`)
- [`.claude/hooks/guard.sh`](../../.claude/hooks/guard.sh) — §8, `check_target()`
- [`work-packages/WP-002-check-scope.md`](../../work-packages/WP-002-check-scope.md) — «Semántica de patrones», «Fuente de confianza del contrato», «Symlinks»
- [`docs/manual/05-bloqueos-y-parada.md`](../../docs/manual/05-bloqueos-y-parada.md) — condición de parada n.º 2 y protocolo para rutas vedadas por `settings.json`
- [`specs/requirements/REQ-FDA-001-alcance-verificado.md`](../requirements/REQ-FDA-001-alcance-verificado.md) — requisito que WP-002 implementa
- [`specs/adr/ADR-001-runtime.md`](../adr/ADR-001-runtime.md) — ejecución headless
- [`specs/decisions/DEC-001-divisa-costes.md`](DEC-001-divisa-costes.md) — formato de referencia
- [`CLAUDE.md`](../../CLAUDE.md) — alcance del trabajo y condiciones de parada
