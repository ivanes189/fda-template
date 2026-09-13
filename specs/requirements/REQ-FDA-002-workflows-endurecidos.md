# REQ-FDA-002 — Los workflows usan permisos mínimos y acciones fijadas por SHA

**Id:** REQ-FDA-002 · **Categoría:** SEC (seguridad de la cadena de suministro) · **Estado:** activo · **Fecha:** 2026-07-23

## Texto

Todo workflow de GitHub Actions del repositorio debe:

1. Declarar `permissions:` de forma **explícita**, con el conjunto mínimo que necesita, a nivel de workflow o de job. Nunca depender del permiso por defecto del repositorio.
2. Fijar toda acción de terceros por **SHA de commit completo** (40 caracteres), no por etiqueta móvil (`@v1`, `@main`, `@master`), con la versión legible anotada en un comentario adyacente.
3. No usar `pull_request_target` con checkout de la referencia de la PR, ni ninguna construcción que ejecute código de un fork con permisos elevados.
4. No interpolar expresiones `${{ ... }}` con datos controlables por terceros dentro de un bloque `run:`; esos valores se pasan por `env:`.

## Justificación

Un workflow es **ejecución de código arbitrario con acceso a los secretos del repositorio**. Es la superficie más sensible de la FDA.

Una etiqueta como `@v1` es mutable: quien controle el repositorio de la acción puede reapuntarla a código distinto sin que aquí cambie una línea. Fijar por SHA convierte la dependencia en inmutable y hace que cualquier actualización sea un cambio visible en el diff, revisable como cualquier otro.

La interpolación directa de `${{ }}` en `run:` es el vector de inyección de comandos habitual en Actions: el contenido de un título de issue o de una rama entra sin escapar en el shell.

## Criterio de verificación

1. `actionlint` en verde sobre `.github/workflows/*.yml`, sin errores.
2. Comprobación automática: ninguna línea `uses:` que apunte a una acción de terceros carece de un SHA de 40 caracteres hexadecimales.

   ```bash
   grep -rn 'uses:' .github/workflows/ | grep -v '@[0-9a-f]\{40\}' | grep -v 'uses: \./'
   ```

   Debe devolver vacío.
3. Todo workflow declara `permissions:` explícitamente; ningún job recibe permisos por defecto.
4. Ningún workflow usa `pull_request_target`.
5. Revisión del `security-reviewer` sin hallazgos de severidad ALTA o CRÍTICA abiertos.

## Verificación actual

| Punto | Estado |
|---|---|
| `permissions:` explícitos | Cumplido en `claude.yml` y `code-review.yml`; `ci.yml` los declara a nivel de workflow |
| Acciones fijadas por SHA | Cumplido por WP-014 y la PR #40: las diez referencias `uses:` de terceros de los tres workflows están fijadas por SHA de commit completo (40 caracteres), con versión legible en comentario adyacente, mediante un parche preparado y versionado y aplicado humanamente. El criterio 2 de verificación devuelve vacío. Ver `evidence/WP-014/CIERRE.md`. |
| Sin `pull_request_target` | Cumplido |
| Sin interpolación en `run:` | Cumplido — `ci.yml` pasa `BASE_SHA` por `env:` |

Nota de procedencia: la aplicación de los diez pins la realiza una persona
(Iván) mediante `git apply` nativo sobre un blob preparado y versionado por el
implementador, en un worktree limpio y dedicado; ningún agente ejecuta las
órdenes de aplicación. Detalle completo, matriz de pins y trazabilidad en
`evidence/WP-014/` (`manifest.md`, `procedencia.md`, `verification.md`).

## Trazabilidad

- Implementa: WP-005 (endurecimiento de workflows); WP-014 (acciones fijadas por SHA)
- Origen: `FDA-diagnostico-y-plan-fase1.md` §3 (WP-005)
- Relacionado: [`SEC-001`](SEC-001-sin-secretos.md)
