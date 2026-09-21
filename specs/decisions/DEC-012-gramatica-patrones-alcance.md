# DEC-012 — Gramática inequívoca de los patrones de alcance

**Estado:** aceptada · **Fecha:** 2026-09-21
**Ámbito:** contenido ejecutable de `## Archivos permitidos` y
`## Archivos prohibidos`, transición segura del guard histórico y desbloqueo
normativo del replanteamiento de WP-015
**Base:** `origin/main`
`ab4eeb3c70715a5e32778e2b61868d0acc6b6a8a`, árbol Git
`52910d20b0548f622970c4b26ccd8c2062b71a4e`

## Problema

`work-packages/_TEMPLATE.md` ordenaba simultáneamente ignorar backticks,
comentarios inline tras `#` y anotaciones entre paréntesis, y tratar como
literales todos los caracteres distintos de `*`, `**` y `?`, incluidos
expresamente `(` y `)`. No existía un delimitador que permitiese decidir si
`(`, `)`, `#` o un backtick pertenecían a la ruta o a la presentación Markdown.

El guard vigente elimina todos los backticks y corta el patrón desde el primer
`#` o `(`, incluso sin espacio separador. Convierte `docs/(draft).md` en
`docs/`; como un patrón acabado en `/` cubre todo su contenido, esa
transformación autoriza más rutas que la escritura original.

La revisión independiente del borrador externo de WP-015 identificó esta
contradicción como `WP015-F1`, ALTO y bloqueante. Tras C2, Astra ordenó parar y
devolver el contrato a resolución normativa; no existe C3 ordinario.

## Evidencia verificada

- Las dos reglas contradictorias estaban en `_TEMPLATE.md`, líneas 45 y 61 del
  árbol base.
- `guard.sh` ejecuta `gsub(/`/, "")` y después corta por `#` y por `(` con cero
  espacios obligatorios.
- Los 143 elementos de contratos `WP-NNN` y el sentinela de `_TEMPLATE.md`
  usan la forma cruda y ninguno contiene `#`, `(`, `)` o backticks. Esta
  decisión preserva los contratos actuales sin reescribirlos.
- Git trata los nombres de ruta como secuencias de bytes no NUL y recomienda
  salidas NUL para no confundir nombres inusuales. La gramática del contrato no
  debe apropiarse silenciosamente de caracteres que Git admite en nombres.
- Los code spans de CommonMark normalizan ciertos espacios. No son una
  codificación de rutas adecuada ni se incorporan como parser implícito.

## Decisión

### 1. La línea ejecutable completa es el patrón

Bajo `## Archivos permitidos` y `## Archivos prohibidos`, una entrada
ejecutable tiene exactamente esta forma léxica:

```text
H* "-" H+ P H*
```

`H` es espacio ASCII o tabulador horizontal y `P` una secuencia no vacía
contenida en una sola línea. Se retira el marcador y se eliminan solo los
espacios o tabuladores exteriores. El contenido restante es el patrón completo.

No hay una segunda pasada para retirar presentación, comentarios o anotaciones.
No hay escapes, interpolación, expansión de shell, normalización Unicode ni
interpretación CommonMark. La semántica posterior de `*`, `**`, `?`, sufijo
`/`, traversal y precedencia sigue gobernada por `_TEMPLATE.md`, DEC-002 y esta
decisión.

El marcador normativo es guion seguido de espacio. Una línea de lista iniciada
con `*` o `+` no es alternativa válida: dentro de cualquiera de las dos
secciones hace que el contrato sea malformado y el verificador termine con
exit `2`.

### 2. Todos los demás caracteres se conservan

Después del recorte exterior:

- `#` es literal;
- `(` y `)` son literales;
- los backticks son literales;
- espacios interiores, corchetes, llaves, puntos y signos `+` son literales;
- solo `*`, `**` y `?` conservan la función de glob ya documentada.

Un patrón que necesite esos caracteres los escribe directamente. Los backticks
no decoran rutas y nunca se eliminan.

Los nombres con espacio o tabulador ASCII inicial o final no son representables
como patrones literales exactos, porque el recorte exterior es deliberado. Un
glob más amplio como `docs/**` sí puede cubrirlos; esta decisión no añade una
validación de rutas ni una denegación nueva. Una representación exacta exigiría
otra decisión versionada; no se inventa un escape local.

### 3. No existen comentarios ni anotaciones inline

Se retiran del lenguaje ejecutable los comentarios y anotaciones inline. Una
explicación va en una línea separada que no empiece con marcador de lista,
preferiblemente con el prefijo humano `Nota:`. Esa línea no produce patrón y el
extractor la ignora.

Si alguien escribe por error:

```text
- docs/** # documentación
```

el patrón es literalmente `docs/** # documentación`; usado en permitidos no
autoriza `docs/a.md` y produce una falsa denegación visible.

En prohibidos el efecto se invierte: si permitidos contiene `docs/**` y se
escribe `docs/** # documentación` como prohibido, `docs/a.md` queda autorizado.
La gramática distingue los bytes, no la intención humana. Por eso los metadatos
inline quedan prohibidos por contrato y la tabla conserva ambos casos; el
parser no puede adivinar cuál de dos textos literales era comentario.

### 4. Sentinelas de lista vacía

Tras el recorte exterior, solo los valores exactos en minúsculas `ninguno`,
`none`, `n/a` y `-` representan una lista vacía. Deben aparecer solos en la
sección; mezclar un sentinela con patrones es contrato malformado y exit `2`.

Una lista de prohibidos vacía es válida. Una lista de permitidos vacía conserva
el fail-closed de DEC-002: exit `2`, nunca «todo permitido». El nombre de ruta
literal `-` no es representable en esta versión.

### 5. Caso discriminante vinculante

La entrada:

```text
- docs/(draft).md
```

produce exactamente `docs/(draft).md`. Autoriza únicamente esa ruta
—respetando mayúsculas— y no autoriza `docs/otro.md`, `docs/draft.md`, el
directorio `docs/` ni su contenido general.

El guard histórico obtiene hoy `docs/` y da un falso permiso. Ese resultado es
no conforme; no es una interpretación alternativa.

### 6. Tabla cerrada de conformidad

| Entrada en la sección | Resultado ejecutable | Efecto sobre `docs/a.md` |
|---|---|---|
| `- docs/(draft).md` | `docs/(draft).md` | no autoriza |
| `- docs/file#v1` | `docs/file#v1` | no autoriza |
| ``- `docs/**` `` | `` `docs/**` `` | no autoriza |
| `- docs/** # nota` | `docs/** # nota` | no autoriza |
| `- docs/** (manual)` | `docs/** (manual)` | no autoriza |
| `Nota: solo manuales` | ninguna entrada | no autoriza |
| `- docs/**` | `docs/**` | autoriza |
| `- ninguno` en prohibidos | lista vacía | no prohíbe |
| `- -` en prohibidos | lista vacía | no prohíbe |

Caso de precedencia complementario: permitidos `docs/**` y prohibidos
`docs/** # nota` autorizan `docs/a.md`; la prohibición literal no coincide. Es
el riesgo humano descrito, no una ambigüedad del parser.

Toda implementación de extracción debe reproducir la tabla. Los casos con
caracteres especiales se prueban como texto UTF-8 y sin consultar el sistema de
archivos.

### 7. Fuente de confianza y fallos

DEC-012 no cambia la fuente de confianza: `check_scope` lee el contrato del
merge-base por objetos Git. Esta gramática se aplica al texto de ese blob.

Son exit `2`, entre otros:

- sección de permitidos ausente o vacía;
- entrada vacía tras el recorte;
- sentinela mezclado con patrones;
- marcador alternativo `*` o `+` dentro de las secciones;
- texto contractual que no pueda decodificarse estrictamente como UTF-8;
- cualquier estado que impida obtener todas las entradas con certeza.

Una línea no ejecutable separada se ignora. Que parezca una explicación no
permite recortar una entrada ejecutable.

## Transición sin falso verde

### 1. Subconjunto de compatibilidad temporal

Hasta que el guard consuma la biblioteca única fusionada, todo contrato que se
apruebe, admita o active debe limitar sus entradas ejecutables al subconjunto
sin `#`, `(`, `)` ni backticks y sin comentarios o anotaciones inline. `-`
conserva exclusivamente su papel de sentinela.

No se admite ningún carácter Unicode con propiedad `White_Space` salvo espacio
ASCII U+0020 o tabulador U+0009; estos dos se recortan en los extremos y se
conservan en el interior. Los 144 elementos versionados actuales cumplen el
subconjunto.

WP-015 y el futuro sucesor limpio de WP-005 deben usarlo íntegramente. Sus
pruebas sintéticas sí cubrirán la tabla completa para construir la semántica
final, pero ningún contrato vivo puede explotar la divergencia antes de la
convergencia del guard. Aprobar un contrato que incumpla el subconjunto es una
parada, no una excepción informal.

El corpus de transición incluye: permitidos `- *`, prohibidos `- -` y ruta `-`,
que queda permitida porque `-` es lista vacía y no una prohibición literal;
U+000C final tras `docs/`; y un whitespace Unicode distinto de U+0020 y U+0009.
Los dos casos de whitespace son contrato no admisible durante la transición.

### 2. Enmienda acotada de DEC-011

La excepción temporal de DEC-011 se amplía solo para reconocer esta segunda
divergencia conocida del parser histórico. Comienza y termina en los mismos
hitos que la excepción de traversal. No reduce la autoridad del juez del diff
ni convierte el guard en garantía hermética.

El subconjunto evita que la divergencia gramatical sea ejercitable por el
contrato activo. El cierre exige que guard y `check_scope` consuman la misma
biblioteca y pasen el corpus común, incluida la tabla de esta decisión. No basta
con dos parsers que coincidan casualmente en los contratos existentes.

### 3. WP-015 se replantea; no se abre C3

La candidata externa de WP-015 y sus revisiones se preservan. DEC-012 no la
modifica ni transforma su `NO APTO` en `APTO`.

Una autorización humana separada podrá pedir una candidata replanteada de
WP-015 que cite DEC-012, use el subconjunto temporal y contenga la tabla
vinculante. Será un candidato nuevo con revisión completa Astra, no una tercera
corrección ordinaria del candidato agotado. Aprobarlo, admitirlo y activarlo
seguirán siendo actos separados.

## Compatibilidad normativa

- **REQ-FDA-001:** conserva lista blanca, precedencia y juicio sobre el diff.
- **DEC-002:** no cambia traversal, globs, symlinks ni merge-base; añade la
  gramática léxica que DEC-002 no había decidido.
- **DEC-003:** mantiene pausa y reposo; admite solo esta composición normativa.
- **DEC-010:** respeta la parada tras C2 y elige replanteamiento, no C3.
- **DEC-011:** conserva WP-015 como primer paso y amplía de forma acotada la
  excepción temporal hasta la convergencia de biblioteca y guard.

## Alternativas rechazadas

- **Separador por espacio:** deja sin representación inequívoca rutas legítimas
  con esos sufijos y exige escapes nuevos.
- **Code spans de CommonMark:** normalizan espacios y exigen un parser Markdown
  o una imitación parcial.
- **Parser del guard:** transforma `docs/(draft).md` en `docs/` y amplía el
  alcance.
- **Elegida — patrones puros:** una frontera léxica, caracteres conservados y
  menos código. En permitidos un comentario inline erróneo deniega; en
  prohibidos conserva el riesgo inverso declarado en §3.

## Composición atómica de operador

Esta decisión se admite modificando directamente DEC-003 en el mismo diff; no
se autoautoriza. La composición consta exactamente de ocho archivos:

1. `specs/decisions/DEC-012-gramatica-patrones-alcance.md`;
2. `specs/decisions/DEC-002-semantica-de-traversal.md`;
3. `specs/decisions/DEC-003-pausa-migracion-y-contencion.md`;
4. `specs/decisions/DEC-011-recuperacion-post-dec009.md`;
5. `docs/03-hoja-de-ruta.md`;
6. `work-packages/_TEMPLATE.md`;
7. `docs/manual/03-redactar-un-wp.md`;
8. `docs/manual/05-bloqueos-y-parada.md`.

No incluye WP-015, `ACTIVE`, hooks, scripts, tests, workflows, ruleset,
contratos existentes, evidencias ni candidatas. `_TEMPLATE.md` y las normas
son rutas de operador; esta composición no autoriza trabajo técnico.

## Revisión independiente

La revisión completa de GPT-6 Astra, razonamiento Alto, contexto nuevo y solo
lectura, emitió `NO APTO` por `DEC012-F1` ALTO y bloqueante y por `F2` y `F3`
IMPORTANTES. C1 alineó el sentinela y el whitespace temporal, declaró el riesgo
simétrico en prohibidos y corrigió la afirmación sobre espacios extremos.

La misma Astra revalidó C1 de forma enfocada: cerró F3 y dejó dos
contradicciones residuales en F1 y F2. C2 separó los resultados del sentinela y
del whitespace y acotó la falsa denegación a permitidos. La segunda
revalidación enfocada cerró F1 y F2 y emitió `APTO`, sin hallazgos abiertos.
Astra no modificó la candidata.

## Verificación

- diff limitado exactamente a los ocho archivos;
- tabla coherente en decisión, plantilla y manual;
- inventario reproducible de los elementos existentes y pertenencia al
  subconjunto temporal;
- `git diff --check`;
- `PYTHONDONTWRITEBYTECODE=1 python3 evidence/WP-000/checks/check-manual.py`;
- `bash tests/governance/check-active.sh` → reposo y exit `0`;
- ausencia de `work-packages/WP-015*`;
- cero cambios en guard, scripts, tests, workflows, ruleset o evidencias.

## Condiciones de parada

- cualquier interpretación que vuelva a recortar una entrada por contenido;
- necesidad de representar rutas con espacio o tabulador inicial o final;
- contrato vivo fuera del subconjunto antes de converger el guard;
- intento de usar esta decisión para aprobar o activar WP-015;
- ampliación de la composición, escritura protegida automática o C3 encubierto;
- contradicción nueva con fuente de confianza, globs, traversal o symlinks.

## Qué no autoriza

No crea, modifica, aprueba, admite, activa ni implementa WP-015; no cambia
`ACTIVE`; no modifica el guard ni inicia la excepción temporal de DEC-011; no
autoriza commits, PRs ni los hitos técnicos posteriores.

## Referencias

- [`_TEMPLATE.md`](../../work-packages/_TEMPLATE.md)
- [`.claude/hooks/guard.sh`](../../.claude/hooks/guard.sh)
- [`REQ-FDA-001`](../requirements/REQ-FDA-001-alcance-verificado.md)
- [`DEC-002`](DEC-002-semantica-de-traversal.md)
- [`DEC-003`](DEC-003-pausa-migracion-y-contencion.md)
- [`DEC-010`](DEC-010-separacion-autor-revisor-y-ciclos.md)
- [`DEC-011`](DEC-011-recuperacion-post-dec009.md)
- [Git — `git-diff`](https://git-scm.com/docs/git-diff)
- [Git — codificación de rutas](https://git-scm.com/docs/git-commit)
- [CommonMark — code spans](https://spec.commonmark.org/spec#code-spans)
