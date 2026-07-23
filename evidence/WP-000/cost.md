# Coste — WP-000 (Bootstrap de la FDA, Fase 0)

```
coste_usd: 15.14          # crudo, inmutable
tipo_eurusd: 1.1383       # specs/finops/fx-rates.md → 2026-07
fuente: BCE ref. 2026-07-01
coste_eur: 13.30
presupuesto_eur: 75
consumo: 18 %
```

> **Conversión reconstruida.** El coste se midió antes de aprobarse DEC-001. La conversión se aplicó a posteriori con el tipo del mes en curso (2026-07), conforme a la cláusula de aplicación retroactiva de la decisión. El valor en USD es el original y no se ha alterado.

| Concepto | Valor |
|---|---|
| Coste total (registro) | **$15,14 USD** |
| Coste total (gobierno) | **13,30 €** |
| Presupuesto del WP | 75,00 € |
| Consumo sobre presupuesto | 18 % |
| Sesiones | 1 |
| Ciclos de corrección | 0 / 2 |
| Modelo principal | Opus 4.8 (`claude-opus-4-8`) |
| Tiempo de API | 44 min |
| Tiempo total (reloj) | 49 min |
| Aceptado a la primera | pendiente de tu revisión |

Medición: `/cost` el 2026-07-23T13:02:58Z.

## Nota de divisa — RESUELTA

La convención está fijada en [`specs/decisions/DEC-001-divisa-costes.md`](../../specs/decisions/DEC-001-divisa-costes.md): **USD es el registro, EUR es el gobierno, el tipo se congela por mes natural**.

El tipo aplicado (1,1383) es la referencia del BCE del 2026-07-01, registrada en [`specs/finops/fx-rates.md`](../../specs/finops/fx-rates.md). No se recalculará: aunque el euro se mueva, este coste seguirá siendo 13,30 €.

Para métricas de eficiencia entre WPs, la vista correcta es la **técnica** (USD crudo): elimina el ruido cambiario.

## Desglose por consumo de tokens

| Concepto | Cantidad |
|---|---|
| Entrada (sin caché) | 490 |
| Salida | 2.200 |
| Lectura de caché | 36.600.000 |
| Escritura de caché | 1.100.000 |

**El dato importante de esta tabla:** 36,6 M de tokens leídos de caché frente a 490 de entrada real. La sesión se sostuvo casi por completo sobre contexto cacheado, que es la razón de que 49 minutos de trabajo agéntico continuado cuesten $15 y no varios cientos.

Consecuencia para el modelo de costes de la FDA: **una sesión larga sobre un mismo WP es mucho más barata que varias sesiones cortas** que reconstruyen el contexto desde cero. Refuerza el diseño de «un WP = una rama = una sesión» y desaconseja trocear un WP en tantos pedazos que cada uno pague su propio arranque de contexto.

## Consumo de plan

| Límite | Consumido |
|---|---|
| Sesión | 55 % |
| Semanal (todos los modelos) | 6 % |

El WP de bootstrap consumió algo más de la mitad de una ventana de sesión. Los WPs de calibración, mucho más pequeños, deberían quedar muy por debajo.

## Desglose por fases del trabajo

| Fase | Qué se hizo | Peso relativo |
|---|---|---|
| Lectura y análisis | Guía completa (199 líneas) + comprobación de entorno | bajo |
| Gobierno | `CLAUDE.md`, `CODEOWNERS`, `settings.json`, 5 agentes | medio |
| Hook `guard.sh` | Implementación + **3 defectos detectados y corregidos** + suite de 42 casos | **alto** |
| Contratos | `_TEMPLATE.md`, `WP-000`, `ACTIVE`, `ADR-001` | medio |
| Manual | 8 archivos, ~2.000 líneas | **alto** |
| Verificación | 4 scripts + 6 archivos de evidencia + script de aplicación | medio |

Los tres defectos del hook: divergencia BSD/GNU en `sed` dentro de clases de caracteres; *pathname expansion* en el bucle de patrones (el guard comparaba contra archivos existentes en vez de contra el contrato); y el bypass de `Bash`, que dejaba el control central sin efecto para cualquier agente con shell.

## Notas para la calibración

Este WP **no es representativo** y no debe entrar en la media de «coste por WP aceptado»:

1. Es el WP que construye el sistema, no uno que lo usa. No hay otro igual.
2. Incluye depuración real de un control de seguridad, con tres defectos encontrados por pruebas propias.
3. Su volumen de documentación (el manual entero) no se repetirá.
4. Incluyó tres bloqueos de permisos y un hand-off manual, que consumieron contexto sin producir código.

**La línea base empieza en la Fase 1.** Los 5 primeros WPs de calibración dan la primera cifra con sentido — y aun con n=5 se lee la tendencia, no el valor.

## Criterios de aceptación de WP-000: estado

| Criterio | Estado |
|---|---|
| Estructura del §2 completa, sin elementos no pactados | ✅ 22/22, 0 no pactados |
| 5 agentes y 3 skills con frontmatter válido | ✅ 0 fallos |
| `guard.sh` deniega fuera de alcance y permite dentro | ✅ 42/42 |
| `guard.sh` falla cerrado | ✅ 4 casos |
| `guard.sh` cubre escrituras vía Bash | ✅ 9 vectores bloqueados, 7 falsos positivos evitados |
| Los 3 workflows parsean y declaran `name`/`on`/`jobs` | ✅ 0 errores |
| Enlaces del manual sin roturas | ✅ 30/30 |
| Los 3 placeholders presentes | ✅ 5 marcadores en 5 archivos |
| `cost.md` existe y registra el coste | ✅ $15,14 |

Pendiente únicamente: confirmación humana de la carga de agentes y skills en sesión interactiva.
