# WP-014 — Registro de coste

Conforme a `DEC-004` (estados del coste y adquisición verificable).

```
wp_id: WP-014
estado_coste: no_disponible
causa: >
  Esta sesión se ejecuta dentro del harness interactivo/gestionado de Claude
  Code (no como invocación `claude -p`/`query()` aislada), por lo que no hay
  un JSON estructurado con `total_cost_usd` que capturar (F1, DEC-004 §5).
  Tampoco hay agregación OpenTelemetry configurada para este WP con
  `fda.wp.id=WP-014` (F2, DEC-004 §6): no se fijó `OTEL_RESOURCE_ATTRIBUTES`
  ni `OTEL_METRICS_INCLUDE_RESOURCE_ATTRIBUTES=true` al lanzar esta sesión, y
  este agente no tiene acceso al backend de métricas para exportarlas
  retroactivamente. F3 (DEC-004 §7) exige una lectura humana de `/usage` o
  `/cost`, fechada y con el valor mostrado: es un acto exclusivo del operador,
  que este agente no puede ni debe suplantar. El indicador acumulado de
  presupuesto que el propio entorno muestra en cada turno («USD budget: X/8»)
  no es un artefacto exportable, no lleva SHA-256 verificable y no está
  documentado como fuente F1/F2/F3 de DEC-004; usarlo como si lo fuera
  inventaría una procedencia que no tiene.
presupuesto_eur: 12
operador: Claude Code (implementer)
```

## Nota de aptitud (DEC-004 §11)

`no_disponible` **sin** `excepcion` es un registro **válido**, pero deja el
criterio de aceptación «`cost.md` conforme a DEC-004 y coste `<= 12 EUR`» **sin
poder verificarse con una cifra**, y por tanto el WP queda, en este punto,
**NO APTO** por gobernanza de coste — no por un defecto del trabajo técnico
entregado. `DEC-004 §11` es explícito: mientras `DEC-003` esté vigente y
`specs/finops/excepciones-coste.md` no exista (lo crea WP-010, no esta PR),
**no hay excepción disponible** y esta es la única situación posible cuando no
existe cifra defendible.

Esto se declara aquí como **deuda/limitación conocida**, no se oculta ni se
rellena con una cifra inventada (prohibido por `DEC-004 §10.3`), y se traslada
a Iván como parte del cierre de esta preparación: la vía disponible para
obtener una cifra `medido`/`estimado` conforme es que el operador lea
`/usage` o `/cost` al final de la sesión real (F3, DEC-004 §7) y añada esa
lectura a este archivo con fecha, hora y valor mostrado, o que se lance una
sesión de captura F1 dedicada.
