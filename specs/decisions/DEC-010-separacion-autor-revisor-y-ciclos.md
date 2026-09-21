# DEC-010 — Separación de autor y revisor y bucle ordinario de dos ciclos

**Estado:** aceptada · **Fecha:** 2026-09-21 · **Ámbito:** revisiones
independientes, correcciones ordinarias, contabilidad de ciclos y aplicación del
nivel T3

**Origen:** investigación externa aceptada por el operador tras el cierre
bloqueado de WP-008 y revisión independiente de esta candidata normativa. Se
materializa desde reposo como acto de operador, sin reanudar la secuencia
técnica detenida por [`DEC-009`](DEC-009-cierre-bloqueado-wp-008.md).

## Problema

La FDA ya separaba implementador y revisor, limitaba las correcciones ordinarias
a dos ciclos y obligaba a parar ante el tercero. El flujo, sin embargo, estaba
repartido entre varios documentos y dejaba cuatro ambigüedades operativas:

1. no declaraba en un solo lugar que los hallazgos vuelven inmediatamente al
   autor y que la misma revisora hace después una revalidación enfocada;
2. no decía que la autorización inicial puede cubrir C1 y C2 sin nuevas
   confirmaciones cuando alcance, presupuesto y autoridad no cambian;
3. no exigía un registro durable del ciclo si una invocación falla o no produce
   cambios;
4. la tabla T3 podía leerse como dos revisores y aplicación humana universal,
   aunque la independencia exige una sola revisión completa y la aplicación
   humana corresponde a las rutas o actos protegidos.

WP-008 mostró el coste de estas ambigüedades: cinco ciclos —C1 y C2 ordinarios
y C3–C5 excepcionales— y varias revalidaciones sin convergencia. La respuesta
no es permitir que Astra corrija lo que revisa, porque perdería independencia,
sino cerrar y acelerar el bucle autor → revisión → corrección → revalidación.

## Decisión

### 1. Separación de funciones

- Claude Code es autor: implementa y corrige los WPs expresamente autorizados.
- GPT-6 Astra, razonamiento Alto y contexto nuevo, es revisor independiente y
  estrictamente de solo lectura. Nunca modifica el candidato que revisa.
- Astra recibe normas, contrato, candidato y pruebas; no recibe el `APTO` ni la
  conclusión del autor como premisa.

### 2. Una revisión completa y revalidaciones enfocadas

- Hay una sola revisión completa por candidato o transición.
- Si hay incumplimientos concretos, Claude corrige únicamente esos hallazgos y
  sus efectos directos. Las mejoras laterales se registran y no se incorporan.
- La misma Astra revalida de forma enfocada las correcciones y sus efectos
  directos. No se abre otra revisión general, no se añade otro revisor y no se
  revisa la revisión.
- El dictamen final puede ser `APTO` en la revisión completa inicial o en una
  revalidación enfocada posterior dentro de los ciclos autorizados.

### 3. Autorización cerrada para C1 y C2

Una autorización de ejecución que identifique el WP, el alcance aprobado, el
presupuesto máximo y `max_ciclos_correccion: 2` cubre la implementación inicial
y, si resultan necesarias, C1 y C2. No se pide una confirmación entre esas
pasadas cuando permanecen invariables el alcance, el presupuesto, los archivos
permitidos y la autoridad.

Esta cobertura nunca autoriza por implicación:

- ampliar el contrato o sus archivos permitidos;
- superar el presupuesto;
- aplicar rutas protegidas;
- cambiar `ACTIVE`, crear o fusionar PRs, o ejecutar otros actos reservados;
- resolver una ambigüedad, contradicción, vulnerabilidad o decisión humana;
- iniciar C3.

### 4. Contabilidad durable de ciclos

- La implementación inicial no consume ciclo.
- Cada pasada de corrección del autor posterior a un veredicto consume un ciclo
  desde que comienza, aunque la herramienta falle, se interrumpa, termine sin
  cambios o no cierre el hallazgo.
- Antes de comenzar la corrección, una fila debe quedar efectivamente
  **versionada en la rama candidata** en `evidence/WP-XXX/ciclos.md`, con:
  número, HEAD/candidato y revisión de origen, IDs de hallazgos autorizados,
  fecha y estado `abierto`. Si no existe autoridad para versionarla, la pasada
  no comienza.
- Al terminar se actualiza esa misma fila con resultado, HEAD final o
  `sin cambios`, verificaciones, coste/invocaciones y dictamen enfocado cuando
  exista.
- Al reanudar una sesión, ese registro —no la conversación— determina el
  siguiente número. Los expedientes históricos no se reescriben.
- Una revalidación sin nueva pasada de autor no consume ciclo.

### 5. Parada tras C2; C3 no es la continuación normal

Si el dictamen posterior a C2 no es `APTO`, se preserva el candidato y se para.
La siguiente decisión debe elegir cierre `blocked`, división del problema o
replanteamiento del contrato.

Un C3 solo puede existir mediante una decisión humana nueva, previa, fechada y
versionada que identifique WP, hallazgos cerrados, alcance exacto, presupuesto
adicional y techo final. No reinicia ni renombra el contador y no crea
precedente ni autorización implícita para C4. La opción predeterminada después
de C2 es dividir o replanificar, no conceder excepciones sucesivas.

### 6. Interpretación del nivel T3

- T3 exige una revisión independiente completa con lente conjunta de contrato,
  corrección y seguridad. En el modelo operativo vigente la realiza una sola
  Astra; no se duplica con un segundo revisor general.
- Si hay correcciones, la misma Astra hace las revalidaciones enfocadas.
- T3 no convierte por sí solo todos los archivos en protegidos. La aplicación
  personal por Iván se exige cuando la ruta o el acto está protegido por la
  constitución, permisos, decisiones o contrato. Los archivos no protegidos
  pueden ser escritos por Claude dentro de un WP activo y autorizado.
- La revisión nunca concede autoridad para aplicar protegidos.

### 7. Relación con DEC-009

Esta decisión no elige recuperación, sustitución ni cambio de la secuencia
técnica detenida por DEC-009. Autoriza exclusivamente esta composición normativa
de operador, desde reposo, para hacer coherente el método antes de preparar esa
decisión. `ACTIVE` permanece en reposo; no se crea ni activa WP; las candidatas
históricas permanecen intactas.

DEC-003 admite expresamente esta composición única en su lista cerrada. DEC-010
no se autoautoriza: su materialización y fusión requieren actos humanos
separados. Tras fusionarla, la parada técnica de DEC-009 continúa sin cambios.

## Composición atómica de operador

Los siguientes siete archivos viajan juntos o ninguno:

1. `specs/decisions/DEC-010-separacion-autor-revisor-y-ciclos.md`
2. `specs/decisions/DEC-003-pausa-migracion-y-contencion.md`
3. `CLAUDE.md`
4. `docs/03-hoja-de-ruta.md`
5. `docs/manual/02-ciclo-de-un-wp.md`
6. `docs/manual/04-agentes.md`
7. `docs/manual/05-bloqueos-y-parada.md`

No forman parte de la composición `work-packages/**`, `ACTIVE`, `.claude/**`,
`.github/**`, `CODEOWNERS`, `scripts/**`, `tests/**`, rulesets, candidatas ni
evidencias históricas.

## Revisión independiente de la candidata normativa

La revisión completa de Astra concluyó `NO APTO` por cuatro incumplimientos:
falta de admisión en DEC-003 y conflicto con la parada de DEC-009, tratamiento
T3 no reconciliado, ausencia de un registro durable de ciclos interrumpidos y
un criterio que atribuía indebidamente el `APTO` a la revisión inicial.

La primera corrección eligió esta composición de operador, precisó T3, añadió el
registro de ciclos y permitió que el dictamen final llegase en revalidación. La
primera revalidación enfocada cerró tres hallazgos y mantuvo abierto que
«preparar para versionado» no garantizaba el registro. La segunda corrección
exigió versionar la apertura antes de iniciar la pasada y corrigió la descripción
histórica de C1–C5. La segunda revalidación enfocada emitió `APTO`. No hubo otro
revisor, otra revisión general ni modificación de la candidata por Astra.

## Verificación

```bash
git diff --check
python3 evidence/WP-000/checks/check-manual.py
bash tests/governance/check-active.sh
```

Además:

- el diff contiene exactamente los siete archivos de la composición;
- `ACTIVE` sigue en reposo;
- no cambian workflows, ruleset, agentes, permisos, candidatas ni contratos;
- DEC-009 sigue deteniendo la recuperación técnica.

## Consecuencias

**A favor:** mantiene independencia, reduce esperas humanas dentro de límites
ya autorizados, hace reconstruibles los intentos fallidos y evita repetir la
espiral C3–C5 como flujo normal.

**Coste:** registrar la apertura de cada ciclo añade un commit antes de corregir.
Se acepta porque impide perder contabilidad al interrumpirse una herramienta o
una sesión.

**No autorizado:** fusionar sin acto humano posterior; cambiar `ACTIVE`; crear
o ejecutar un WP; tocar protegidos; decidir o reanudar la recuperación de
WP-008; limpiar ramas, worktrees o candidatas.
