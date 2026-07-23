---
name: new-work-package
description: Genera un work package nuevo desde la plantilla y valida su contrato contra la Definition of Ready. Acepta el WP-ID como argumento. Usar al empezar cualquier encargo, antes de tocar código.
---

# Crear un work package

Convierte un encargo en una hoja de encargo que cumple la Definition of Ready, o lo rechaza diciendo qué falta. No implementa nada.

**Uso:** `new-work-package [WP-ID]` — por ejemplo `new-work-package WP-014`. Sin argumento, se asigna el siguiente número libre.

## Procedimiento

### 1. Asignar identificador

Si se pasa un WP-ID explícito, se usa ese (ADR-001, invariante I4). Si no, el siguiente libre:

```bash
WP="${1:-}"
if [ -z "$WP" ]; then
  ULTIMO=$(ls work-packages/ 2>/dev/null | grep -oE 'WP-[0-9]{3}' | sort -u | tail -1)
  N=$(( ${ULTIMO#WP-} + 1 ))
  WP=$(printf 'WP-%03d' "$N")
fi
echo "WP-ID: $WP"
ls work-packages/"$WP"*.md >/dev/null 2>&1 && { echo "ERROR: $WP ya existe." >&2; exit 1; }
```

Archivo: `work-packages/$WP-descripcion-corta.md` (kebab-case, sin acentos).

### 2. Copiar la plantilla

```bash
cp work-packages/_TEMPLATE.md work-packages/WP-XXX-descripcion.md
```

Rellena **todas** las secciones. Una sección vacía es un WP que no está listo.

### 3. Redactar el contrato

Reglas que determinan si el WP sirve o no:

- **Objetivo**: el estado final, no la actividad. «El endpoint rechaza importes negativos con HTTP 400», no «mejorar validación».
- **Archivos permitidos**: rutas o globs concretos. Los aplica `guard.sh`: lo que no esté listado no se podrá escribir. Ser generoso aquí anula el control; ser tacaño provoca paradas legítimas a mitad de trabajo. Lista lo que el cambio necesita y nada más.
- **Verificación**: comandos ejecutables en headless, con código de salida significativo. Sin comandos no hay WP.
- **Criterios de aceptación**: verificables por un tercero sin interpretar. Nada de «que quede limpio».

Detalle con ejemplos anotados: `docs/manual/03-redactar-un-wp.md`.

### 4. Validar la Definition of Ready

Comprueba y responde una por una. Si alguna falla, el WP se queda en `draft`:

- [ ] Objetivo inequívoco, en términos de estado final
- [ ] Alcance con incluido y fuera de alcance explícitos
- [ ] Archivos permitidos: lista concreta, no «todo el repo»
- [ ] Comandos de validación headless
- [ ] Criterios de aceptación medibles
- [ ] Presupuesto y `max_ciclos_correccion` declarados
- [ ] Requisitos y ADR vinculados, si aplican

### 5. Comprobar coherencia del alcance

Verifica que las rutas de «Archivos permitidos» bastan para el objetivo. Un WP que obligará a parar en el primer minuto por una ruta ausente está mal redactado.

```bash
# Prueba en seco: ¿el guard permitiría escribir estas rutas?
echo '{"tool_name":"Write","tool_input":{"file_path":"RUTA/A/PROBAR"}}' | .claude/hooks/guard.sh; echo "exit=$?"
```

### 6. Activar el WP

Solo cuando esté en `ready` y con aprobación humana:

```bash
echo "WP-XXX" > work-packages/ACTIVE
git add work-packages/ && git commit -m "WP-XXX: activar work package"
```

`ACTIVE` es el único estado operativo mutable de la FDA y vive en el repo, no en la sesión.

## Condiciones de parada

- El encargo es ambiguo o contradice un requisito o ADR existente → para y solicita decisión.
- El encargo no cabe en un WP (toca varios componentes, mezcla refactor con funcionalidad, excede presupuesto) → propón el troceado al `planner`, no lo fuerces en un solo paquete.
- No sabes qué comandos validarían el resultado → el WP no está listo. Eso es un hallazgo, no un detalle a rellenar después.
