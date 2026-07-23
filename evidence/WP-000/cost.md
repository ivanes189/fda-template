# Coste — WP-000 (Bootstrap de la FDA, Fase 0)

| Concepto | Valor |
|---|---|
| Coste total | **$15,14 USD** |
| Presupuesto del WP | 75,00 € |
| Consumo sobre presupuesto | ~18 % (ver nota de divisa) |
| Sesiones | 1 |
| Ciclos de corrección | 0 / 2 |
| Modelo principal | Opus 4.8 (`claude-opus-4-8`) |
| Tiempo de API | 44 min |
| Tiempo total (reloj) | 49 min |
| Aceptado a la primera | pendiente de tu revisión |

Medición: `/cost` el 2026-07-23T13:02:58Z.

## ⚠️ Nota de divisa — decisión pendiente

El presupuesto de la FDA está en **euros** (75 / 100 / 150 €) y la telemetría de Claude Code reporta en **dólares**. Mezclar divisas en la métrica principal es una fuente segura de confusión a los seis meses.

Hay que elegir una convención y aplicarla en `_TEMPLATE.md` y en `docs/manual/06-costes-y-metricas.md`:

- **Opción A** — mantener los umbrales en € y convertir cada medición al tipo del día del cierre del WP. Más fiel contablemente, exige registrar el tipo aplicado en cada `cost.md`.
- **Opción B** — reexpresar los umbrales en $ (p. ej. 85 / 115 / 170 $). Elimina la conversión de la operativa diaria; los umbrales dejan de coincidir con los del contrato original.

El ~18 % de la tabla asume una paridad aproximada y **no es una cifra contable**. Hasta que decidas, el dato bueno es `$15,14`.

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
