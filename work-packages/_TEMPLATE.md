# WP-XXX — <título>

estado: draft | ready | in_progress | in_review | done | blocked
prioridad: P0 | P1 | P2
agente_responsable: implementer     agente_revisor: code-reviewer
requisitos: [REQ-...]               adr: [ADR-...]
presupuesto_max_eur: 75             max_ciclos_correccion: 2

<!--
CÓMO USAR ESTA PLANTILLA
- Copia a work-packages/WP-XXX-descripcion.md y rellena TODAS las secciones.
- Definition of Ready: sin objetivo, alcance, archivos permitidos, comandos de
  validación y criterios de aceptación, el WP NO pasa a 'ready'.
- La sección "Archivos permitidos" la aplica .claude/hooks/guard.sh de forma
  determinista: lo que no esté listado, no se puede escribir. No es una
  recomendación.
- Guía para redactar un buen WP: docs/manual/03-redactar-un-wp.md
-->

## Objetivo y contexto

<!-- Una frase con el ESTADO FINAL, no la actividad.
     Bien: "El endpoint /pagos rechaza importes negativos con HTTP 400."
     Mal:  "Mejorar la validación de pagos."
     Debajo, el contexto mínimo para entenderlo sin preguntar. -->

## Alcance (incluido / fuera de alcance)

**Incluido:**
-

**Fuera de alcance:**
<!-- Explícito. Lo que no se escribe aquí acaba implementándose "de propina". -->
-

## Archivos permitidos

<!--
SEMÁNTICA DE ESTA SECCIÓN — es un contrato ejecutable, no una descripción.
La aplica .claude/hooks/guard.sh (preventivo) y la aplicará scripts/check_scope.py
(post-hoc sobre el diff, WP-002). Ambos deben interpretarla igual.

FORMATO
  · Un patrón por línea, empezando por "- " (guion + espacio).
  · Se ignoran backticks, comentarios inline tras "#" y anotaciones entre paréntesis.
  · "ninguno", "none", "n/a" se interpretan como lista vacía.

RUTAS
  · Siempre RELATIVAS A LA RAÍZ del repositorio, sin "./" inicial.
      Bien: docs/manual/**        Mal: ./docs/manual/**   Mal: /docs/manual/**
  · Rutas absolutas dentro del repo se normalizan a relativas antes de comparar.
  · Rutas absolutas FUERA del repo se deniegan siempre, estén o no listadas.

COMODINES
  · *   coincide con cualquier cosa EXCEPTO el separador "/"
        src/*.py        →  sí: src/a.py          no: src/sub/a.py
  · **  coincide con cualquier cosa, INCLUIDO "/"
        docs/**         →  sí: docs/a.md, docs/x/y/z.md
  · ?   coincide con exactamente un carácter que no sea "/"
  · Un patrón terminado en "/" cubre todo su contenido:  build/  ≡  build/**
  · El resto de caracteres son literales: los metacaracteres de regex (. + ( ) [ ] etc.)
    NO tienen significado especial.  CLAUDE.md coincide solo con CLAUDE.md.

  ⚠️ Esto NO es fnmatch de Python: en fnmatch "*" también cruza "/", lo que haría
     que "src/*" cubriera "src/a/b/c.py". Aquí no. La semántica es la de los globs
     de shell con globstar, que es más restrictiva y por tanto más segura.

PRECEDENCIA
  · "Archivos prohibidos" GANA siempre sobre "Archivos permitidos".
  · Lo que no coincide con ningún patrón permitido, se deniega (lista blanca).

TRAVERSAL Y ENLACES
  · Una ruta tiene TRAVERSAL si y solo si, al separarla por "/", ALGUNO de sus
    componentes es exactamente ".." — dos puntos y nada más.
        Traversal:     ..    ../x    docs/../x    docs/..
        NO traversal:  notas..md   ..oculto.md   bar..   foo../bar
    Una subcadena ".." dentro de un nombre legítimo NO es traversal.
  · Se deniega coincida o no con un patrón, y se comprueba ANTES que
    "Archivos prohibidos" y "Archivos permitidos": es una decisión de buena
    formación de la ruta, no de allowlist.
  · Un componente ".." NUNCA se resuelve contra el que le precede.
    docs/../docs/x.md conserva su ".." y se deniega, aunque el plegado hubiera
    caído dentro del alcance.
  · La comprobación es puramente TEXTUAL: no se consulta el sistema de archivos
    (nada de realpath, abspath, stat, readlink ni comprobación de existencia).
  · Separar por "/" es la ÚNICA operación que esto introduce sobre la ruta. El
    tratamiento de ".", de los separadores duplicados, de los iniciales y
    finales y de las mayúsculas NO cambia.
  · Norma vinculante y tabla de conformidad de 8 casos:
      specs/decisions/DEC-002-semantica-de-traversal.md
  · Los symlinks NO amplían el alcance: un enlace situado dentro de una ruta
    permitida que apunte fuera de ella NO autoriza a escribir en el destino.
    Escribir a través de un symlink cuyo destino real cae fuera del alcance es
    una violación del contrato aunque la ruta del enlace esté permitida.
  · No crees symlinks que salgan del alcance del WP. Si necesitas uno, es señal
    de que el alcance está mal definido: detente y solicita decisión.

MAYÚSCULAS
  · La comparación distingue mayúsculas. Ojo en macOS: APFS suele ser
    case-insensitive, así que "claude.md" y "CLAUDE.md" son el MISMO archivo en
    disco pero patrones DISTINTOS para el matcher. Escribe las rutas con la
    capitalización exacta del repositorio.

BUENAS PRÁCTICAS
  · Lista lo mínimo que el cambio necesita. Ser generoso aquí anula el control:
    "src/**" en un WP que toca un archivo convierte el guard en decoración.
  · "Todo el repo" NO es una lista válida y no pasa la Definition of Ready.
  · Antes de aprobar el WP, prueba en seco cada ruta que preveas tocar:
      echo '{"tool_name":"Write","tool_input":{"file_path":"RUTA"}}' \
        | .claude/hooks/guard.sh; echo "exit=$?"     # 0 = permitido, 2 = bloqueado
-->
-

## Archivos prohibidos

<!-- Prohibición explícita: gana sobre "permitidos". Útil cuando un glob amplio
     debe tener excepciones. Escribe "ninguno" si no aplica. -->
- ninguno

## Contratos técnicos (interfaces, schemas, eventos, invariantes)

<!-- Firmas, tipos, formatos de evento, invariantes que deben seguir siendo
     ciertos después del cambio. Si el WP no cambia contratos, dilo. -->

## Entorno autorizado (herramientas, comandos, red, secretos)

- Herramientas:
- Comandos:
- Red: NINGUNA salvo lista explícita
- Secretos: NINGUNO salvo lista explícita

## Verificación (comandos de validación + criterios de aceptación medibles)

**Comandos** (ejecutables en headless, sin interacción, código de salida significativo):

```bash
```

**Criterios de aceptación** (verificables por un tercero, sin interpretar):

- [ ]

## Evidencias exigidas (qué debe aparecer en evidence/WP-XXX/)

- [ ] Salida íntegra de cada comando de validación, con su código de salida
- [ ] `cost.md` con el coste de la sesión
- [ ]

## Condiciones de parada específicas

<!-- Además de las generales de CLAUDE.md, las propias de este WP. -->
-

## Migración / rollback

<!-- Cómo se revierte si sale mal. Si no hay migración, escribe "no aplica". -->
