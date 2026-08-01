# WP-007 — Alinear `guard.sh` con la semántica de traversal por componente

estado: ready
prioridad: P0
agente_responsable: implementer     agente_revisor: code-reviewer
requisitos: [REQ-FDA-001]           adr: [ADR-001]
presupuesto_max_eur: 20             max_ciclos_correccion: 2

<!-- Revisores: qa (pruebas) + code-reviewer (revisión de la PR).
     `Edit(./.claude/hooks/**)` está en el `deny` de `.claude/settings.json`:
     NINGÚN agente escribe guard.sh, tenga este WP el alcance que tenga.
     El agente prepara un parche verificado y lo ejecuta una persona. -->

## Objetivo y contexto

`.claude/hooks/guard.sh` juzga el traversal **por componente**: deniega una ruta si y solo si alguno de sus componentes separados por `/` es exactamente `..`, y reproduce las ocho filas de la tabla de conformidad de [`DEC-002`](../specs/decisions/DEC-002-semantica-de-traversal.md) §7. `tests/guard/run-suite.sh` fija esas ocho filas como pruebas ejecutables.

Contexto: hoy §8 (`check_target`) implementa `case "$_rel" in *../*|*/..|..)`, una comparación por **subcadena** sobre `../`. Medido sobre `8457f64` produce un **falso positivo**: `evidence/WP-002/foo../bar` sale con exit `2` y mensaje de traversal pese a que `foo..` es un nombre de directorio legítimo y ningún componente de la ruta es `..`.

De las ocho filas de DEC-002 §7, **una ya está protegida por una prueba existente**: `../x`, cubierta por el caso `traversal ../fuera.txt` del grupo E de la suite. Las **siete restantes** necesitan pruebas nuevas y exactas: seis que hoy ya emiten el veredicto correcto —y que sin prueba podría reinterpretar cualquier reescritura futura sin que nada lo detecte— más `foo../bar`, que es la **única fila cuyo veredicto cambia**.

Este WP es la **PR-3** de la migración de DEC-002. Existe porque el invariante crítico de WP-002 exige que `guard.sh` y `check_scope.py` emitan el mismo veredicto en las ocho filas **en todo momento**: por eso el hook se corrige y se fusiona **antes** de que WP-002 se reinicie, y no al revés.

**Este WP no se cierra a sí mismo.** Tras la fusión humana de esta PR, una **PR de operador** —PR-4 de DEC-002— realiza en un mismo diff y de forma atómica: este WP → `done`, WP-002 → `ready`, y `work-packages/ACTIVE` → `WP-002`.

**Una capa, no dos.** Este WP toca **solo** el hook preventivo. No crea, no diseña y no anticipa `scripts/check_scope.py`.

## Alcance (incluido / fuera de alcance)

**Incluido:**
- **Parche verificado** en `evidence/WP-007/parche/` que sustituye la comprobación de traversal de `guard.sh` §8 por la comprobación por componente de DEC-002 §1–§3, y que **ejecuta una persona**.
- Las **siete** pruebas discriminantes que faltan en `tests/guard/run-suite.sh` — las ocho filas de DEC-002 §7 menos `../x`, ya cubierta por el caso existente `traversal ../fuera.txt`.
- Evidencias en `evidence/WP-007/`: las ocho filas medidas antes y después, la suite completa antes y después, las huellas del hook y el log de aplicación del parche.
- `docs/manual/05-bloqueos-y-parada.md`: registrar el uso del protocolo de parche verificado y la semántica de traversal vigente.

**Fuera de alcance:**
- **WP-002 y `scripts/check_scope.py`:** no se implementan, no se diseñan, no se preparan. WP-002 sigue `blocked` y su desbloqueo es una PR de operador posterior.
- **`work-packages/**` y `work-packages/ACTIVE`:** son actos del operador. Este WP **no** se marca `done` a sí mismo ni reactiva WP-002: eso es la PR-4.
- **Los diez `xfail` del grupo J.** Siguen siendo diez: la señal de que este cambio se ha ceñido a su alcance es que **no promueve ninguno**. Los defectos del analizador Bash —`>` entrecomillado, variable sin expandir, subshell, `git apply`, `tar`, `python -c`, symlinks, APFS— quedan fuera.
- Cualquier otro aspecto de la forma de la ruta: componentes `.`, separadores duplicados, iniciales o finales, mayúsculas. DEC-002 §4 los deja **exactamente como están** y cambiarlos exige su propia decisión versionada.
- Refactorizar `guard.sh` más allá del bloque de traversal: ni la normalización previa, ni `is_exempt`, ni `matches_any`, ni `bash_targets`, ni `deny`.
- `.github/workflows/**`, `.claude/settings.json`, `.claude/agents/**`, `CODEOWNERS`, `CLAUDE.md`, `tests/governance/**`, `tests/scope/**`, `scripts/**`.
- Evidencias de otros WPs: `evidence/WP-000/**` y `evidence/WP-006/**` son registro histórico y no se reescriben.

## Archivos permitidos

- .claude/hooks/guard.sh
- tests/guard/run-suite.sh
- evidence/WP-007/**
- docs/manual/05-bloqueos-y-parada.md

<!-- guard.sh figura aquí porque el diff de la PR lo contiene y el contrato debe
     decir la verdad sobre lo que la PR toca (mismo criterio que WP-006). Pero
     listarlo NO autoriza a ningún agente a escribirlo: Edit(./.claude/hooks/**)
     está en el `deny` de .claude/settings.json y esa capa gana siempre. Son dos
     capas distintas: el WP dice qué es del encargo; settings.json dice qué no
     toca ninguna máquina. La vía es el parche verificado que ejecuta una persona
     (docs/manual/05-bloqueos-y-parada.md, punto 3). -->

## Archivos prohibidos

- .claude/settings.json
- .claude/agents/**
- .claude/skills/**
- .github/**
- work-packages/**
- scripts/**
- tests/scope/**
- tests/governance/**
- evidence/WP-000/**
- evidence/WP-006/**
- CLAUDE.md
- CODEOWNERS

<!-- Redundante con la lista blanca a propósito: hace explícito y auditable qué
     NO es de este encargo, sin obligar a leer la allowlist en negativo. -->

## Contratos técnicos (interfaces, schemas, eventos, invariantes)

### El cambio en `guard.sh`

Se sustituye **únicamente** el bloque de traversal de §8 (`check_target`), hoy:

```bash
  # Escapes de traversal: se bloquean siempre, sin excepción.
  case "$_rel" in
    *../*|*/..|..) deny "Ruta con traversal (..): $_raw" ;;
  esac
```

por una comprobación **por componente**, compatible con bash 3.2 (sin arrays asociativos, sin `mapfile`, sin `globstar`), puramente textual.

Invariantes del cambio:

- **Veredicto y mensaje.** El traversal sigue siendo exit `2` con el texto `Ruta con traversal (..)`. No se añaden códigos de salida ni semántica nueva.
- **Precedencia.** Se comprueba **antes** que `## Archivos prohibidos` y `## Archivos permitidos`, y deniega coincida o no con un patrón.
- **Sin resolución.** Un componente `..` nunca se pliega contra el anterior: `docs/../docs/x.md` conserva su `..` y se deniega.
- **Sin sistema de archivos.** Nada de `realpath`, `stat`, `readlink`, `cd` ni comprobación de existencia.
- **Nada más cambia.** Ni la normalización previa (`$REPO_ROOT/*`, `/*`, `./*`), ni `is_exempt`, ni el orden de las secciones, ni `matches_any`, ni el tratamiento de `.`, separadores duplicados o mayúsculas.

### Tabla de conformidad (DEC-002 §7)

| # | Ruta | ¿Traversal? | Hoy | Tras este WP | Prueba |
|---|---|---|---|---|---|
| 1 | `evidence/WP-002/notas..md` | no | `0` | `0` | nueva |
| 2 | `evidence/WP-002/..hidden.md` | no | `0` | `0` | nueva |
| 3 | `evidence/WP-002/bar..` | no | `0` | `0` | nueva |
| 4 | `evidence/WP-002/foo../bar` | no | `2` | `0` | nueva |
| 5 | `..` | sí | `2` | `2` | nueva |
| 6 | `../x` | sí | `2` | `2` | **ya existente**: `traversal ../fuera.txt` |
| 7 | `evidence/WP-002/../x` | sí | `2` | `2` | nueva |
| 8 | `evidence/WP-002/..` | sí | `2` | `2` | nueva |

Siete pruebas nuevas y una ya existente. Las rutas se instancian contra el fixture `BOOT` de la suite, cuyo alcance permite `evidence/**`, para que la **única** causa posible de denegación sea el traversal. **Una sola fila cambia de veredicto: la 4.**

### El parche y su aplicación

El agente entrega en `evidence/WP-007/parche/`:

1. `aplicar.sh` — headless, idempotente, sin red y sin prompts.
2. `huellas.sha256` — las **dos** huellas legítimas del hook: la de partida (`ANTES`) y la resultante (`DESPUES`).
3. `README.md` — el comando exacto que ejecuta la persona y qué debe ver.

**Dónde va la copia de seguridad.** **Fuera del repositorio, siempre.** `aplicar.sh` crea su directorio de trabajo con `mktemp -d` bajo `${TMPDIR:-/tmp}` y deja allí la copia del hook. **No se versiona ninguna copia del hook** dentro de `evidence/WP-007/` ni en ningún otro sitio del repositorio: una copia versionada aparecería como archivo nuevo en `git status` y rompería la comprobación de alcance, que exige **una sola** ruta cambiada. Y nunca, en ningún caso, junto a `.claude/hooks/guard.sh`.

**Idempotencia por huella.** `aplicar.sh` calcula el `sha256` del `guard.sh` actual y actúa según **exactamente tres** desenlaces:

| Huella actual | Acción | Salida |
|---|---|---|
| `= ANTES` | Aplica la secuencia completa de abajo | `APLICADO`, exit `0` |
| `= DESPUES` | **No toca nada.** El parche ya estaba aplicado | `YA APLICADO`, exit `0` |
| cualquier otra | **Aborta sin escribir nada**, sin copia y sin parche | `ABORTADO`, exit `2` |

Una tercera huella significa que el archivo cambió bajo los pies del parche: aplicarlo a ciegas produciría un `guard.sh` que nadie ha revisado. Fail-closed.

**Secuencia obligatoria cuando la huella es `ANTES`**, en este orden:

1. Crear el directorio temporal con `mktemp -d` y copiar allí el `guard.sh` original.
2. **Validar el candidato antes de sustituir nada**, con `FDA_GUARD=<candidato> bash tests/guard/run-suite.sh`. Si no da 75 · 0 · 10 · 0, **aborta sin haber tocado el hook**.
3. Sustituir `.claude/hooks/guard.sh` por el candidato.
4. Ejecutar las validaciones posteriores: verificación de la huella `DESPUES`, `bash -n`, `shellcheck --severity=warning`, `bash tests/guard/run-suite.sh` y la comprobación de alcance.
5. **Ante cualquier fallo posterior a la sustitución**, restaurar automáticamente el `guard.sh` del directorio temporal. El rollback no es opcional ni manual.
6. Tras restaurar, **verificar que la huella vuelve a ser `ANTES`**. Si no lo es, el rollback ha fallado: imprimir el fallo, la ruta del directorio temporal y la huella obtenida.
7. Salir con código **distinto de cero** e imprimir `ROLLBACK APLICADO`.
8. **Solo si todo pasa**, imprimir `APLICADO` y salir con `0`.

**Comprobación de alcance.** El parche introduce **un solo cambio**: `.claude/hooks/guard.sh`. Los cambios en `tests/guard/run-suite.sh`, `evidence/WP-007/**` y `docs/manual/05-bloqueos-y-parada.md` son trabajo legítimo del WP y **ya están presentes** cuando la persona ejecuta el parche; confundirlos con efectos del parche haría la comprobación inútil. Por eso se compara **contra una instantánea previa** de `git status --porcelain` tomada antes de tocar nada, y la diferencia entre la instantánea posterior y la previa debe ser **exactamente una entrada**, correspondiente a `.claude/hooks/guard.sh`. Cualquier otra ruta, o más de una, dispara el rollback.

**Validar antes de sustituir.** `run-suite.sh` acepta `FDA_GUARD=/ruta/candidato.sh`, de modo que el candidato parcheado se valida **antes** de tocar el archivo real. Es el paso 2 de la secuencia y no es opcional.

**La fusión también es humana.**

## Entorno autorizado (herramientas, comandos, red, secretos)

- Herramientas: Read, Grep, Glob, Edit, Write, Bash
- Comandos: `bash`, `git` (local, solo lectura), `shellcheck`, `shasum`/`sha256sum`, `diff`, `comm`, `sort`, `mktemp`
- Red: NINGUNA
- Secretos: NINGUNO

**Sin dependencias nuevas.** No se instala nada. El parche y la suite deben funcionar con el `bash` 3.2 de macOS y con el `bash` 5 de los runners de CI.

## Verificación (comandos de validación + criterios de aceptación medibles)

**Comandos** (headless, sin red, código de salida significativo):

```bash
bash -n .claude/hooks/guard.sh
shellcheck --severity=warning --shell=bash .claude/hooks/guard.sh tests/guard/run-suite.sh evidence/WP-007/parche/aplicar.sh
bash tests/guard/run-suite.sh
bash tests/governance/check-active.sh
bash tests/governance/test-check-active.sh
python3 evidence/WP-000/checks/check-manual.py
```

Los tres últimos son de **no regresión**: este WP no toca la validación de gobierno ni los enlaces del manual, y deben seguir en verde sin cambios.

**Criterios de aceptación:**

- [ ] `bash tests/guard/run-suite.sh` termina con exit `0` y **0 fallidas**
- [ ] La suite reporta **75 correctas** (68 previas + 7 nuevas), **0 fallidas**, **10 huecos conocidos** y **0 huecos cerrados**
- [ ] **Ningún XPASS:** los diez `xfail` siguen siendo diez y ninguno se ha promovido a `run`
- [ ] Las ocho filas de DEC-002 §7 se reproducen exactamente en la columna «Tras este WP», medidas y registradas en `evidence/WP-007/`
- [ ] `evidence/WP-002/foo../bar` pasa de exit `2` a exit `0`, y es el **único** veredicto de toda la suite que cambia respecto a la medición previa
- [ ] `guard.sh` sigue denegando el traversal con exit `2` y el texto `Ruta con traversal (..)`
- [ ] El bloque de traversal **no consulta el sistema de archivos**: `realpath`, `readlink`, `stat` y `cd` ausentes, verificable por inspección del diff
- [ ] `git diff -- .claude/hooks/guard.sh` afecta **solo** al bloque de traversal de §8
- [ ] `aplicar.sh` es **idempotente**: una segunda ejecución seguida imprime `YA APLICADO`, sale `0` y **no modifica ningún archivo**
- [ ] `aplicar.sh` **aborta con exit `2` y sin escribir nada** ante una huella distinta de `ANTES` y de `DESPUES`
- [ ] Ante un fallo provocado después de sustituir el hook, `aplicar.sh` **restaura solo**, deja la huella `ANTES`, imprime `ROLLBACK APLICADO` y sale distinto de cero
- [ ] La copia de seguridad vive **únicamente** en el directorio de `mktemp -d`; `git status --porcelain` no muestra ninguna copia del hook dentro del repositorio
- [ ] La comprobación de alcance devuelve **exactamente** `.claude/hooks/guard.sh`, sin confundirlo con los cambios legítimos ya presentes en `tests/`, `evidence/` y `docs/manual/`
- [ ] `shellcheck --severity=warning` sin avisos sobre `guard.sh`, la suite y `aplicar.sh`
- [ ] `bash -n .claude/hooks/guard.sh` en verde (compatibilidad bash 3.2)
- [ ] La huella `sha256` del `guard.sh` resultante coincide con `DESPUES` en `evidence/WP-007/parche/huellas.sha256`
- [ ] `git diff --name-only main...HEAD` ⊂ archivos permitidos

## Evidencias exigidas (qué debe aparecer en evidence/WP-007/)

- [ ] Las ocho filas de DEC-002 §7 medidas **antes** del parche, con su exit
- [ ] Salida íntegra de `bash tests/guard/run-suite.sh` **antes** (RESULTADO esperado: 68 · 0 · 10 · 0)
- [ ] Salida de la validación del candidato con `FDA_GUARD=`, previa a sustituir el archivo real, con 75 · 0 · 10 · 0
- [ ] Salida íntegra de la suite **después** de sustituir el hook (esperado: 75 · 0 · 10 · 0)
- [ ] Las ocho filas medidas **después**, reproduciendo la columna «Tras este WP»
- [ ] `huellas.sha256` y las huellas reales `ANTES` y `DESPUES` medidas en la ejecución
- [ ] Log de `aplicar.sh` tal como lo ejecutó la persona, con su código de salida y la ruta del directorio temporal empleado
- [ ] Log de una **segunda** ejecución mostrando `YA APLICADO` y exit `0` (idempotencia)
- [ ] Log de una ejecución contra una huella ajena mostrando `ABORTADO` y exit `2` (fail-closed)
- [ ] Log de un **rollback provocado**: fallo forzado tras la sustitución, `ROLLBACK APLICADO`, exit distinto de cero y huella restaurada igual a `ANTES`
- [ ] Salida de la comprobación de alcance, con su única entrada `.claude/hooks/guard.sh`
- [ ] `git status --porcelain` tras la aplicación, sin ninguna copia del hook versionada
- [ ] `git diff -- .claude/hooks/guard.sh` completo
- [ ] Salidas de `bash -n` y `shellcheck`
- [ ] Salidas de no regresión: `check-active.sh`, `test-check-active.sh`, `check-manual.py`
- [ ] `git diff --name-status -M main...HEAD`
- [ ] `cost.md` con el formato de DEC-001

## Condiciones de parada específicas

- Si corregir el traversal exigiera tocar **cualquier otra parte** de `guard.sh` —normalización, `is_exempt`, `matches_any`, `bash_targets`—: **parar**. Es una reparación acotada, no un refactor.
- Si apareciera un caso de ruta que la tabla de DEC-002 §7 **no cubre**: **parar** y ampliar DEC-002 en una decisión propia. DEC-002 lo exige en «Mantenimiento»: no se interpreta localmente.
- Si tras el parche algún `xfail` pasara a **XPASS**: **parar y reportar**. Significa que el cambio hizo más de lo que este WP autoriza. No se promueve el caso ni se ajusta la prueba para que pase.
- Si **cualquier** caso existente de la suite cambiara de veredicto además de la fila 4: **parar**.
- Si la huella del `guard.sh` de partida no fuera `ANTES` ni `DESPUES`: **parar**. El archivo ha cambiado bajo los pies del parche.
- Si el rollback automático no recuperase la huella `ANTES`: **parar y escalar de inmediato**. El hook ha quedado en un estado que nadie ha revisado; se restaura a mano desde el directorio temporal, cuya ruta imprime `aplicar.sh`.
- Si la comprobación de alcance devolviera algo distinto de `.claude/hooks/guard.sh`: **parar**. El parche toca más de lo que declara.
- Si cubrir un caso exigiera escribir en `work-packages/`, `scripts/`, `tests/scope/`, `tests/governance/` o `.github/`: **parar**.
- Si se planteara «aprovechar» para implementar, diseñar o preparar `check_scope.py`, o para marcar este WP `done` o reactivar WP-002: **parar**. Son actos de la PR-4 de operador, no de esta PR.
- Si algún agente intentara escribir `.claude/hooks/guard.sh` directamente: **parar**. Esa ruta la aplica una persona, siempre.

## Migración / rollback

**Orden de aplicación obligatorio**, y no es indiferente:

1. Escribir las **siete** pruebas en `tests/guard/run-suite.sh`.
2. Preparar el candidato y `evidence/WP-007/parche/`.
3. La persona ejecuta `aplicar.sh`, que valida el candidato con `FDA_GUARD` **antes** de sustituir nada.
4. Capturar las evidencias con la suite ya corriendo contra el hook real.

Las pruebas y el parche viajan en la **misma PR**: la cabeza de la rama nunca queda con la suite en rojo, y `main` nunca queda con un hook alineado sin pruebas ni con pruebas sin hook alineado.

**Rollback durante la aplicación: automático.** Lo hace `aplicar.sh` sin intervención, restaurando el `guard.sh` guardado en el directorio de `mktemp -d` y comprobando que la huella vuelve a ser `ANTES`. Ese directorio **no** se versiona y su ruta se imprime en el log para poder restaurar a mano si el propio rollback fallara.

**Rollback posterior, no destructivo.** Nunca `git reset --hard`, nunca `git branch -D`, nunca force-push, nunca reescritura de historial.

- **Antes del commit:** restaurar por rutas explícitas desde `HEAD` con `git restore --source=HEAD --staged --worktree --` seguido de las rutas afectadas. Nada de `git checkout .` ni de restauraciones masivas, y sin depender de ninguna copia versionada: no existe ninguna.
- **Tras un commit local no publicado:** `git switch main`, conservando la rama intacta. Para abandonarla se informa del **nombre de la rama** y del **hash** y se espera **autorización humana explícita**; solo `git branch -d` cuando Git confirme que está fusionada. `git branch -D` queda **prohibido**.
- **Tras el push:** cerrar la PR sin fusionar y borrar la rama remota. `main` no se modifica y no se hace force-push.
- **Tras una eventual fusión:** revertir mediante una **PR nueva** de revert. No se reescribe el historial de `main`.
