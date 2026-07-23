---
name: run-verification
description: Ejecuta la batería de validación del WP activo y compila las evidencias en evidence/WP-XXX/. Usar antes de abrir la PR y tras cada ciclo de corrección.
---

# Ejecutar la verificación de un WP

Ejecuta los comandos declarados en el WP, captura la evidencia y emite un veredicto. No arregla código: si algo falla, reporta.

## Procedimiento

### 1. Identificar el WP activo

```bash
WP=$(grep -v '^[[:space:]]*#' work-packages/ACTIVE | grep -v '^[[:space:]]*$' | head -1 | tr -d '[:space:]')
echo "WP activo: $WP"
mkdir -p "evidence/$WP"
```

### 2. Extraer los comandos de validación

Están en la sección `## Verificación` del WP. Ejecútalos **tal cual están escritos**, en orden. No los sustituyas por equivalentes, no les añadas flags, no los reordenes. Si un comando parece incorrecto, eso es un hallazgo que se reporta, no algo que se arregla sobre la marcha.

### 3. Ejecutar capturando salida y código de salida

Patrón para cada comando (headless, sin interacción):

```bash
{
  echo "=== COMANDO: <comando> ==="
  echo "=== FECHA:   $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="
  echo "=== COMMIT:  $(git rev-parse --short HEAD) ==="
  echo
  <comando> 2>&1
  echo
  echo "=== EXIT: $? ==="
} | tee -a "evidence/$WP/verificacion.log"
```

El código de salida es parte de la evidencia. Una salida sin código de salida no demuestra nada.

### 4. Evaluar los criterios de aceptación

Uno a uno, contra la evidencia obtenida. Para cada criterio: **cumple** / **no cumple** / **no evaluable**, con el fragmento de evidencia que lo respalda.

Un criterio «no evaluable» cuenta como **no cumplido**. No lo des por bueno porque parezca razonable.

### 5. Registrar el coste

```bash
# En sesión interactiva: /cost   →   vuelca el resultado aquí
$EDITOR "evidence/$WP/cost.md"
```

Formato en `docs/manual/06-costes-y-metricas.md`.

### 6. Veredicto

```
VEREDICTO: APTO | NO APTO
Comandos ejecutados: N · Fallidos: M
Criterios: N cumplidos / M no cumplidos / K no evaluables
Evidencias: evidence/WP-XXX/
```

**APTO** exige: todos los comandos en verde y todos los criterios cumplidos. No hay aprobado por mayoría.

## Prohibiciones

No relajes una verificación para que pase: nada de `--no-verify`, `continue-on-error`, `skip`, `xfail`, bajar umbrales de cobertura ni comentar aserciones. Si la verificación estorba, el problema es el código o el criterio.

No inventes evidencia. Si un comando no se pudo ejecutar, la evidencia es el error, no una descripción de lo que habría pasado.

## Herramienta incluida

`validate-workflows.py` valida los workflows de GitHub Actions sin necesidad de red ni de `actionlint`:

```bash
python3 .claude/skills/run-verification/validate-workflows.py .github/workflows
```

Comprueba YAML válido, claves obligatorias (`name`, `on`, `jobs`), estructura de cada job (`runs-on`, `steps`) y que las acciones de terceros estén ancladas a una versión.
