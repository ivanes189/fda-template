# Coste — WP-000 (Bootstrap de la FDA, Fase 0)

| Concepto | Valor |
|---|---|
| Coste total | ⚠️ **PENDIENTE** — ejecuta `/cost` en esta sesión y anótalo aquí |
| Presupuesto del WP | 75,00 € |
| Consumo sobre presupuesto | pendiente |
| Sesiones | 1 (esta) |
| Ciclos de corrección | 0 / 2 |
| Modelo principal | opus (`claude-opus-4-8`) |
| Aceptado a la primera | pendiente de tu revisión |

## ⚠️ Por qué el coste está pendiente

`/cost` es un comando de la sesión interactiva de Claude Code. **Un agente no puede ejecutarlo ni leer su salida desde dentro de la propia sesión.** Registrar aquí una cifra inventada sería peor que dejarlo en blanco: contaminaría la primera medición de la métrica principal de la FDA.

**Cómo completarlo** (30 segundos, en esta misma sesión):

```
/cost
```

Y sustituye la fila «Coste total» por la cifra real.

> Esta limitación es estructural, no un descuido de este WP: afecta a **todos** los WPs ejecutados en modo interactivo. En modo CI, el coste sí sale del resumen de ejecución de `claude-code-action`. Está documentado en `docs/manual/06-costes-y-metricas.md`.

## Desglose por fases del trabajo

| Fase | Qué se hizo | Peso relativo |
|---|---|---|
| Lectura y análisis | Guía completa (199 líneas) + comprobación de entorno | bajo |
| Gobierno | `CLAUDE.md`, `CODEOWNERS`, `settings.json`, 5 agentes | medio |
| Hook `guard.sh` | Implementación + **2 bugs detectados y corregidos** + suite de 26 casos | **alto** |
| Contratos | `_TEMPLATE.md`, `WP-000`, `ACTIVE`, `ADR-001` | medio |
| Manual | 8 archivos, ~1.900 líneas | **alto** |
| Verificación | 3 scripts de comprobación + 6 archivos de evidencia | medio |

El coste está concentrado en `guard.sh` y el manual. El primero por los dos ciclos de depuración (divergencia BSD/GNU en `sed`, y *pathname expansion* en el bucle de patrones); el segundo por volumen.

## Notas para la calibración

Este WP **no es representativo** y no debe entrar en la media de la métrica «coste por WP aceptado»:

1. Es el WP que construye el sistema, no uno que lo usa. No hay otro igual.
2. Incluye trabajo de depuración real sobre un control de seguridad, con dos bugs encontrados por pruebas propias.
3. Su volumen de documentación (el manual entero) no se repetirá.

**La línea base empieza en la Fase 1.** Los 5 primeros WPs de calibración son los que dan la primera cifra con sentido — y aun así, con n=5, se lee la tendencia, no el valor.

## Criterios de aceptación de WP-000: estado

| Criterio | Estado |
|---|---|
| Estructura del §2 completa, sin elementos no pactados | ⚠️ 2 workflows ausentes · 0 no pactados |
| 5 agentes y 3 skills con frontmatter válido | ✅ |
| `guard.sh` deniega fuera de alcance y permite dentro | ✅ 26/26 |
| `guard.sh` falla cerrado | ✅ 4 casos |
| Los 3 workflows parsean y declaran `name`/`on`/`jobs` | ⚠️ solo `ci.yml` |
| Enlaces del manual sin roturas | ✅ 30/30 |
| Los 3 placeholders presentes | ✅ |
| `cost.md` existe y registra el coste | ⚠️ falta la cifra |

**Veredicto: NO APTO todavía.** Tres criterios abiertos, todos con causa identificada y hand-off documentado. Ninguno requiere rehacer trabajo.
