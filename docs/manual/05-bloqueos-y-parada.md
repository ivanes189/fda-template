[← Manual](MANUAL.md)

# 05 — Bloqueos y condiciones de parada

**Que un agente se detenga es el sistema funcionando, no fallando.** El fallo sería que continuara inventando una interpretación.

Cuando un agente para, produce tres cosas: qué le bloquea, qué necesita para seguir, y qué ha hecho hasta ese punto. Tu trabajo es decidir, no reiniciarlo esperando otro resultado.

## Las ocho condiciones de parada

| # | Condición | Quién decide |
|---|---|---|
| 1 | Requisito ambiguo | Tú |
| 2 | Contradicción entre requisitos | Tú |
| 3 | Cambio de ADR necesario | Tú |
| 4 | Migración con riesgo de pérdida de datos | Tú |
| 5 | Vulnerabilidad detectada | Tú, con el `security-reviewer` |
| 6 | Pruebas inejecutables | Tú |
| 7 | Coste fuera de presupuesto | Tú |
| 8 | Tercer ciclo de corrección | Tú |

---

### 1. Requisito ambiguo

**Síntoma:** «el WP dice *validar el importe* pero no especifica si 0 es válido».

**Qué NO hacer:** responder «tú decide, usa el sentido común». Eso traslada una decisión de producto a un modelo y la entierra en el código.

**Qué hacer:** decidir tú, y **escribirlo en el WP**, no en el chat. Luego reanudar.

```bash
# Añade el criterio al WP y confírmalo
sed -n '/## Verificación/,/^## /p' work-packages/WP-014-*.md
git add work-packages/ && git commit -m "WP-014: precisar criterio de importe cero"
```

Si la ambigüedad se repite en varios WPs, el problema está en `specs/requirements/`: arréglalo ahí, no WP a WP.

### 2. Contradicción entre requisitos

**Síntoma:** REQ-FR-023 exige rechazar importes ≤ 0; REQ-FR-031 exige aceptar devoluciones con importe negativo.

**Qué hacer:** no la resuelvas en el WP. Resuélvela en `specs/requirements/`, registra la decisión en `specs/decisions/DEC-xxx.md`, y **después** actualiza el WP. Un WP no puede sobrescribir un requisito en silencio.

### 3. Cambio de ADR necesario

**Síntoma:** el WP no se puede implementar sin contradecir una decisión de arquitectura.

**Qué hacer:** para el WP. Escribe un ADR nuevo que supersede al anterior (contexto, decisión, consecuencias) o rechaza el cambio. **Nunca** dejes que un WP erosione un ADR sin registro: en seis meses nadie sabrá por qué el código contradice la arquitectura documentada.

```bash
cp specs/adr/ADR-001-runtime.md specs/adr/ADR-00X-titulo.md   # como referencia de formato
```

### 4. Migración con riesgo de pérdida de datos

**Síntoma:** el cambio implica `DROP COLUMN`, `ALTER` destructivo, reescritura de datos o borrado.

**Qué hacer:** el WP se divide en tres, siempre en este orden:

1. Migración **aditiva** (añadir sin quitar) + doble escritura
2. Backfill verificable, con conteos antes/después como evidencia
3. Retirada de lo viejo, en un WP posterior y con rollback probado

Ningún agente ejecuta una migración destructiva. Ni con aprobación conversacional.

### 5. Vulnerabilidad detectada

**Síntoma:** el `security-reviewer` reporta un hallazgo **CRÍTICO** o **ALTO**.

**Qué hacer:** el WP se bloquea. No se fusiona. El arreglo va en su propio WP con alcance propio y su propia revisión. No hay «se arregla en el siguiente» salvo decisión humana explícita **registrada en la PR**.

Si el hallazgo es MEDIO o BAJO: puede fusionarse declarándolo como deuda en la PR y abriendo el WP de arreglo. Deuda declarada, no deuda escondida.

### 6. Pruebas inejecutables

**Síntoma:** el entorno está roto, faltan dependencias, o los resultados varían entre ejecuciones.

**Qué NO hacer:** marcar la prueba como `skip` para avanzar. Eso convierte un problema visible en uno invisible.

**Qué hacer:** arreglar el entorno en un WP propio. Si las pruebas son no deterministas, eso **es** el hallazgo: una prueba que a veces pasa no verifica nada.

### 7. Coste fuera de presupuesto

**Síntoma:** el WP supera su `presupuesto_max_eur`.

| Umbral | Acción |
|---|---|
| > 100 € | Aviso: registra y revisa el troceado |
| > 150 € | **Parada**: el agente pide autorización |
| > 750 €/mes | Revisión de la política de modelos |

**Qué hacer:** casi siempre el WP estaba mal troceado, no mal presupuestado. Antes de subir el presupuesto, pregúntate si se puede partir en dos. Ver [06 — Costes y métricas](06-costes-y-metricas.md).

### 8. Tercer ciclo de corrección

**Síntoma:** el `code-reviewer` pide cambios por tercera vez.

**Qué hacer:** **no abras el tercer ciclo.** Para, y busca la causa raíz, que casi nunca es el código:

- ¿El contrato estaba mal definido? → reescribe el WP
- ¿El alcance estaba mal troceado? → pártelo
- ¿El requisito era ambiguo? → arréglalo en `specs/`
- ¿Faltaban criterios de aceptación? → añádelos y reinicia

Registra la causa en `evidence/WP-XXX/`. Los terceros ciclos son la señal más valiosa que da el sistema sobre cómo estás escribiendo los contratos.

---

## Cuando el bloqueo es del hook

Si `guard.sh` bloquea una escritura, el mensaje dice qué ruta y qué permite el WP:

```
BLOQUEADO por la FDA (.claude/hooks/guard.sh)
Ruta fuera del alcance de WP-014: src/pagos/servicio.py
Rutas permitidas por el WP activo:
  - src/pagos/schemas.py
  - src/pagos/endpoints.py
```

Tres respuestas posibles, en orden de preferencia:

1. **El agente se estaba saliendo del alcance** → correcto, que siga sin tocar ese archivo.
2. **El WP estaba mal definido** → amplía `## Archivos permitidos` **conscientemente**, con commit propio que deja rastro de por qué.
3. **Nunca:** vaciar `ACTIVE`, ampliar a `**` o desactivar el hook para «desatascar». Eso no desatasca: apaga el control.

## Qué hacer con un WP bloqueado

```bash
sed -i '' 's/^estado: .*/estado: blocked/' work-packages/WP-014-*.md
```

Documenta el bloqueo en el propio WP —qué lo bloquea y qué se necesita— y deja constancia en `evidence/WP-014/`. El estado vive en archivos: si solo está en el chat, se pierde.
