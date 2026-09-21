# DEC-011 — Recuperación posterior a DEC-009

**Estado:** aceptada · **Fecha:** 2026-09-21 · **Ámbito:** elección de rumbo
posterior a DEC-009, reserva del primer sucesor y composición normativa de
operador; no crea ni activa ningún WP

**Base de decisión:** `f85163f93fe193ce177466dadfea63821f39e68f`.

## Problema

DEC-009 cerró WP-008 como `blocked` después de cinco ciclos y detuvo toda la
secuencia. El núcleo estructural no llegó a `main`; el humo A/B no fue
concluyente porque su oráculo dependía de representaciones internas y ambiguas
de la salida de Claude Code. Al mismo tiempo, el control concluyente previsto
desde el diagnóstico inicial —`check_scope` sobre el diff— no existe en local,
en CI ni como check requerido.

La recuperación debe evitar dos falsos atajos:

1. declarar seguro el runtime porque una prueba frágil produce verde; y
2. declarar controlado el alcance porque existe un script o job que todavía no
   bloquea la fusión.

## Estado verificado

1. `ACTIVE` está en reposo.
2. WP-014 está `done`; exactamente diez referencias de acciones están fijadas
   por SHA en `main`.
3. WP-008, WP-009 y WP-013 están `blocked`; sus candidatas permanecen históricas,
   no conformes y no ejecutables.
4. La candidata de WP-008 no está en `main`.
5. No existen `scripts/check_scope.py`, `tests/scope/**`, el job de alcance ni
   el check requerido.
6. El ruleset activo exige solo los tres checks ya registrados; no exige
   `check_scope`, aprobación humana ni CODEOWNERS.
7. El runtime fail-closed, su humo seguro y E2 siguen pendientes.
8. Las adaptaciones locales no rastreadas y las candidatas y worktrees
   históricos quedan en solo lectura y fuera de toda composición.

## Decisión

### 1. Control determinista del resultado primero

Se elige una recuperación híbrida. El primer WP técnico futuro será un
**sucesor mínimo y limpio de WP-002**, con identificador reservado `WP-015`,
dedicado exclusivamente a crear el ejecutable local determinista de alcance y
su biblioteca única de matching.

Esta decisión solo reserva el identificador y el primer paso. **No crea, aprueba,
admite para ejecución ni activa su contrato.** WP-002 permanece `blocked` como
historia y no se reabre. Ninguna candidata local se usa como base: el sucesor se
implementará desde el `main` que exista cuando sea autorizado.

WP-015 será T3 porque implementa un control, aunque no toque una ruta protegida.
Su contrato posterior deberá ser breve, fijar presupuesto y dos ciclos y exigir:

- fuente de confianza en el `merge-base`, nunca en el working tree ni en el
  contrato modificado por el candidato;
- semántica DEC-002 por componente, precedencia de prohibidos, symlinks por
  objetos Git y fallo cerrado ante entrada ausente, ambigua o inválida;
- corpus adversarial headless y reproducible;
- salida distinta de cero con inventario completo de violaciones;
- cero workflow, ruleset, `ACTIVE`, hook, configuración Claude o candidata
  histórica en su alcance;
- una revisión completa Astra y, si hay correcciones, revalidaciones enfocadas
  de la misma Astra conforme a DEC-010.

El cierre de WP-015 solo acreditará **ejecutable local**. No permitirá decir
«CI», «requerido» ni «bloqueante para la fusión».

### 2. Excepción temporal y acotada a DEC-002

Esta decisión enmienda, solo para esta recuperación, la obligación temporal «en
todo momento» de DEC-002 §8. La excepción solo comenzará si otra autorización
aprueba el contrato y activa WP-015; cubrirá su implementación, verificación y
fusión y terminará en la convergencia posterior del guard. DEC-011 no inicia el
intervalo ni autoriza trabajo.

Durante ese intervalo, la biblioteca aplicará la semántica por componente y el
guard histórico podrá seguir rechazando `foo../bar`. Es una posible falsa
denegación preventiva, no autoridad para relajar el juez del diff. La
divergencia no puede sobrevivir al hito de convergencia ni utilizarse para
declarar cerrada la pausa.

### 3. Orden posterior condicionado y no autorizado aquí

Solo si WP-015 queda `done`, el operador podrá autorizar por separado, uno cada
vez, los siguientes hitos:

1. **Integración en CI y ruleset.** Un sucesor limpio de WP-005 integrará el
   mismo verificador en CI. El job deberá ejecutarse en toda PR relevante, no
   quedar ausente ni saltado, fallar cerrado y distinguir ramas de operador
   mediante una autorización verificable ligada al `HEAD SHA`. Una persona
   aplicará el parche de workflow y, después de pruebas roja y verde, añadirá
   el par `{context, integration_id}` al ruleset. Solo desde esa mutación se
   podrá afirmar que el alcance bloquea la fusión. La preimagen, postimagen,
   historia, delta y rollback del ruleset deberán quedar acreditados.
2. **Convergencia del guard y resolución de WP-007.** En un acto posterior
   separado, una persona aplicará el guard delgado que consuma la misma
   biblioteca ya fusionada; el corpus común demostrará igualdad de veredictos.
   Hasta entonces WP-007 y su candidata siguen congelados. Después, otra PR de
   operador, sin transición de `ACTIVE` y manteniéndolo en reposo, cerrará
   WP-007 por superación conforme a DEC-003 §1 y DEC-007 paso 21-A. No ejecutará
   ni importará su candidata. Verificación y custodia conservan autorización
   separada; `tests/guard/run-suite.sh`, el hook y la custodia no cambian antes
   de sus decisiones y contratos específicos.
3. **Runtime técnico.** Un sucesor limpio de WP-008 instalará el núcleo
   fail-closed y un humo A/B seguro. No reutilizará código D6-A ni R2. El
   preflight comprobará el comando anclado a `${CLAUDE_PROJECT_DIR}`, existencia,
   ejecutabilidad y la forma documentada que convierte el fallo propio del
   guard en `exit 2`; no prometerá que un hook que no arranca o agota tiempo se
   deniega si el proveedor no lo garantiza. El humo solo se ejecutará en un
   proyecto desechable externo, con `.env` sintético y cero secretos reales.
4. **E2.** Desde reposo, otra autorización asignará identificador y contrato al
   experimento. Si supera el gate, otro acto separado aprobará su adopción T3
   con `sandbox.failIfUnavailable: true`; si no lo supera, se registrará el
   resultado negativo sin atribuir garantía de kernel.
5. **Cierre de la pausa.** Solo podrá proponerse cuando estén acreditados:
   *(a)* núcleo runtime fail-closed fusionado, preflight bloqueante dentro de
   `Gobierno FDA` y humo seguro concluyente; *(b)* los diez pins de WP-014, ya
   cumplidos; *(c)* `check_scope` local y en CI, incorporado al ruleset como
   check requerido, convergencia de la biblioteca con el guard y resolución de
   WP-007; y *(d)* E2 ejecutado y registrado, con adopción efectiva si es
   positivo. La prueba sobre producto no es condición de cierre.

Esta enumeración fija dependencias; no autoriza ni activa ningún paso.

### 4. El humo se conserva, pero su nuevo oráculo no está resuelto

Se retira expresamente el oráculo que normaliza o deduplica `tool_use_result`,
`content`, texto libre u otras formas internas no contratadas.

`PreToolUse` seguido de ausencia de `PostToolUse` tampoco basta: puede significar
fallo, interrupción o pérdida del registro, y `PermissionDenied` no se emite
cuando coincide una regla `deny` ordinaria.

Antes de aprobar el contrato del sucesor de WP-008, su Definition of Ready debe
identificar en documentación oficial vigente una señal positiva y explícita de
denegación, o un experimento A/B cuyo protocolo demuestre conjuntamente:

- intento `Read` exacto y ruta absoluta en `PreToolUse`;
- distinción de `PostToolUse`, `PostToolUseFailure`, denegación, interrupción y
  timeout;
- integridad y finalización del registro, de modo que «no apareció» no pueda
  equivaler a «no se registró»;
- control permitido que lee el marcador sintético y caso protegido idéntico
  salvo por la regla bajo prueba;
- negativas que reproduzcan fallo de lectura, fallo del registrador, evento
  perdido o duplicado, ejecución incompleta y versión no admitida;
- fallo o inconcluso ante cualquier ambigüedad, nunca verde por mera ausencia;
  y saneado sin transcriptos completos ni datos reales.

Si no existe un oráculo atribuible con interfaces documentadas, el contrato no
se aprueba y se vuelve a decisión humana para sustituir el criterio. No se
rescata el parser de `tool_use_result` ni se usa `PermissionDenied` por analogía.
El humo, si llega a ser admisible, probará un caso concreto, no la semántica
general de Claude Code.

### 5. Tres hitos distintos

1. **Prueba técnica del runtime:** núcleo fail-closed fusionado y humo A/B seguro
   concluyente. Demuestra instalación y un caso concreto; no el alcance de la
   fábrica.
2. **Prueba real de la fábrica:** `check_scope` local, el mismo verificador en
   CI, check requerido como `{context, integration_id}`, pruebas roja y verde y
   E2 resuelto. Un E2 negativo resuelve el gate, pero no aporta sandbox.
3. **Prueba real sobre producto:** instalación posterior en
   `AI-Comercial-System`, únicamente tras cerrar la pausa y acumular la
   calibración exigida. No forma parte de esta decisión.

### 6. Preservación y lectura histórica

Las candidatas de WP-008, WP-009, WP-013, WP-002 y WP-007 y todos sus worktrees,
ramas, commits y evidencias permanecen preservados. No se ejecutan, copian,
importan, corrigen ni limpian. Para redactar contratos solo pueden consultarse
las decisiones, cierres, manifiestos y evidencias textuales ya versionadas en
`main`; no se abre ni se lee el contenido de ramas, worktrees o artefactos de
las candidatas. Nada histórico se usa como base ni como evidencia de éxito.

## Compatibilidad normativa

- **DEC-003:** mantiene pausa, reposo, aplicación humana de protegidos y los tres
  estados de `check_scope`. DEC-011 enmienda su lista cerrada, secuencia y
  criterio de salida para admitir esta composición y sucesores limpios.
- **DEC-009:** satisface su exigencia de decisión humana nueva. No rehabilita
  WP-008 ni concede C6.
- **DEC-010:** Claude sigue como autor y corrector; una sola Astra revisa cada
  candidato o transición y la misma Astra revalida correcciones; C3 sigue
  exigiendo decisión nueva.
- **DEC-002/DEC-007:** conserva la semántica por componente y la dirección de
  poner el juez del diff antes del parser del guard; enmienda temporalmente la
  igualdad «en todo momento» hasta la convergencia y resolución de WP-007.

## Alternativas rechazadas

- **WP-008 primero:** llega antes a una prueba del runtime, pero vuelve a la
  capa preventiva antes de construir el juez del resultado y repite el riesgo
  que ya consumió cinco ciclos.
- **WP-002/WP-005 sin rediseñar el humo:** prioridad correcta, pero deja intacta
  la causa que bloqueó WP-008.
- **Retirar el humo:** elimina coste a cambio de no probar que el runtime cargó
  la configuración y negó el caso concreto.
- **Elegida — híbrida:** `check_scope` primero; después CI requerido,
  convergencia/WP-007, runtime con oráculo atribuible y E2.

## Condiciones de parada específicas

- necesidad de leer o ejecutar ramas, worktrees o artefactos de una candidata
  histórica; la evidencia textual versionada en `main` sí puede consultarse;
- divergencia no acotada entre DEC-002, biblioteca y guard;
- check ausente, saltado, homónimo sin productor o con falso verde;
- humo basado en campos no documentados, texto libre o decisión del modelo;
- intento de declarar E2 positivo sin adopción efectiva;
- tercer ciclo, escritura protegida no humana, ampliación de alcance o exceso de
  presupuesto.

## Composición atómica de operador

Esta decisión se admite modificando directamente DEC-003 en el mismo diff; no
se autoautoriza. La composición consta exactamente de cinco archivos:

1. `specs/decisions/DEC-011-recuperacion-post-dec009.md`;
2. `specs/decisions/DEC-003-pausa-migracion-y-contencion.md`;
3. `specs/decisions/DEC-002-semantica-de-traversal.md`;
4. `docs/03-hoja-de-ruta.md`;
5. `docs/manual/05-bloqueos-y-parada.md`.

No incluye `ACTIVE`, contratos, evidencias históricas, workflows, hooks,
scripts, tests, ruleset, candidatas ni adaptaciones locales. Reserva WP-015,
pero no lo admite para ejecución: esa admisión requiere contrato aprobado y
otra autorización. Crear y fusionar la PR siguen siendo actos humanos separados.

## Revisión independiente

La revisión completa de GPT-6 Astra, razonamiento Alto, contexto nuevo y solo
lectura, emitió `NO APTO` por cinco hallazgos: oráculo no atribuible, ciclo entre
cierre y producto, convergencia/WP-007 omitidos, composición no cerrada y una
política contradictoria de lectura histórica.

La primera corrección cerró cuatro y dejó dos precisiones de F3. La misma Astra
revalidó de forma enfocada y exigió que la excepción temporal comenzara con la
autorización y activación de WP-015 y que WP-007 se cerrara mediante PR de
operador sin transición de `ACTIVE`. La segunda corrección incorporó ambas. La
segunda revalidación enfocada emitió `APTO`. Astra no modificó la candidata ni
ejecutó Claude Code, humos o candidatas.

## Verificación

- diff limitado a los cinco archivos de la composición;
- `git diff --check`;
- `python3 evidence/WP-000/checks/check-manual.py`;
- `bash tests/governance/check-active.sh` → reposo y exit `0`;
- WP-015 no existe, no está activo ni está admitido para ejecución;
- ningún workflow, hook, ruleset, contrato, evidencia histórica o candidata
  cambia.

## Qué no autoriza

No crea, aprueba o activa WP-015; no ejecuta los hitos posteriores; no asigna
presupuesto; no modifica `ACTIVE`, contratos, código, tests, workflows, ruleset,
ramas, worktrees ni candidatas; no crea ni fusiona PRs; no instala nada en
producto.

## Referencias

- [DEC-002](DEC-002-semantica-de-traversal.md)
- [DEC-003](DEC-003-pausa-migracion-y-contencion.md)
- [DEC-007](DEC-007-punto-de-control-y-rumbo.md)
- [DEC-009](DEC-009-cierre-bloqueado-wp-008.md)
- [DEC-010](DEC-010-separacion-autor-revisor-y-ciclos.md)
- [Hoja de ruta](../../docs/03-hoja-de-ruta.md)
