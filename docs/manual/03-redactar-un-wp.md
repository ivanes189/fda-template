[← Manual](MANUAL.md)

# 03 — Cómo redactar un work package

Un WP es un **contrato**, no una descripción. Si un tercero no puede verificar el resultado sin preguntarte nada, el contrato está mal escrito.

Las cinco reglas que deciden si un WP sirve:

1. **Objetivo = estado final**, no actividad. «El endpoint rechaza importes negativos con HTTP 400», no «mejorar la validación».
2. **Archivos permitidos = lista concreta.** Los aplica `guard.sh`. «Todo el repo» no es una lista.
3. **Comandos de validación ejecutables**, headless, con código de salida.
4. **Criterios de aceptación medibles**, verificables sin interpretar.
5. **Fuera de alcance explícito.** Lo que no se excluye acaba implementándose «de propina».

---

## Ejemplo BUENO (comentado)

```markdown
# WP-014 — Rechazar importes negativos en el endpoint de pagos

estado: ready
prioridad: P1
agente_responsable: implementer     agente_revisor: code-reviewer
requisitos: [REQ-FR-023]            adr: [ADR-004]
presupuesto_max_eur: 75             max_ciclos_correccion: 2

## Objetivo y contexto

POST /api/pagos rechaza con HTTP 400 y código de error PAGO_IMPORTE_INVALIDO
cualquier petición con importe <= 0, sin crear registro en la base de datos.

Contexto: incidencia INC-231, tres pagos de importe -50 € crearon asientos
contables que hubo que revertir a mano.
```
*Estado final observable y el porqué. Un tercero entiende el problema sin preguntar.*

```markdown
## Alcance (incluido / fuera de alcance)

**Incluido:**
- Validación de importe en el esquema de entrada del endpoint
- Prueba unitaria de la validación y prueba de integración del endpoint

**Fuera de alcance:**
- Validación de moneda o de límites superiores (irá en WP-015)
- Refactor del servicio de pagos
- Migración de los asientos ya creados (WP-016)
```
*Los «fuera de alcance» son los que evitan que el WP crezca en silencio.*

```markdown
## Archivos permitidos

- src/pagos/schemas.py
- src/pagos/endpoints.py
- tests/pagos/test_validacion_importes.py

## Archivos prohibidos

- src/pagos/servicio.py
```
*Tres archivos concretos. `servicio.py` se prohíbe explícitamente porque es donde
más tentaría «aprovechar y refactorizar».*

```markdown
## Contratos técnicos

- La respuesta de error mantiene el formato existente:
  {"error": {"codigo": str, "mensaje": str}}
- Invariante: ninguna petición rechazada crea filas en la tabla `pagos`.
- No cambia la firma pública de PagoService.crear().

## Entorno autorizado

- Herramientas: Read, Grep, Glob, Edit, Write, Bash
- Comandos: pytest, ruff, mypy, git (local)
- Red: NINGUNA
- Secretos: NINGUNO

## Verificación

```bash
ruff check src/pagos tests/pagos
mypy src/pagos
pytest tests/pagos/test_validacion_importes.py -v
pytest tests/pagos --cov=src/pagos --cov-fail-under=90
```

**Criterios de aceptación:**

- [ ] POST /api/pagos con importe = -1 devuelve 400 y codigo PAGO_IMPORTE_INVALIDO
- [ ] POST /api/pagos con importe = 0 devuelve 400 y el mismo código
- [ ] POST /api/pagos con importe = 0.01 devuelve 201 (no hay regresión)
- [ ] Tras una petición rechazada, SELECT COUNT(*) FROM pagos no varía
- [ ] Cobertura de src/pagos >= 90 %
```
*Cada criterio se comprueba ejecutando algo. Incluye el caso que NO debe romperse.*

```markdown
## Evidencias exigidas

- [ ] Salida de los 4 comandos con su código de salida
- [ ] Informe de cobertura mostrando src/pagos >= 90 %
- [ ] cost.md

## Condiciones de parada específicas

- Si la validación exige tocar PagoService: parar (está prohibido por contrato).
- Si aparecen pagos negativos legítimos (devoluciones): parar, es un cambio de requisito.

## Migración / rollback

No aplica: no hay cambio de esquema. Rollback = revertir el commit.
```

---

## Ejemplo MALO (anotado)

```markdown
# WP-014 — Mejorar la validación de pagos          ← ① 

estado: ready
agente_responsable: implementer
presupuesto_max_eur:                                ← ②

## Objetivo y contexto

Hay que mejorar cómo se validan los pagos porque están entrando datos
incorrectos y da problemas. Que quede robusto.                ← ③

## Alcance

Todo lo relacionado con la validación de pagos.               ← ④

## Archivos permitidos

- src/**                                                       ← ⑤

## Archivos prohibidos

(vacío)

## Verificación

Que funcione bien y no rompa nada. Ejecutar las pruebas.       ← ⑥

**Criterios de aceptación:**
- [ ] El código queda limpio y mantenible                      ← ⑦
- [ ] Mejora el rendimiento                                    ← ⑧
```

### Por qué fallaría

| | Problema | Qué provoca |
|---|---|---|
| ① | Título de actividad, no de estado final | Nadie puede decir cuándo está terminado |
| ② | Presupuesto vacío | No hay condición de parada por coste: el WP puede consumir sin límite |
| ③ | «Datos incorrectos», «robusto» | **Ambigüedad**: el agente debe parar y preguntar. Si no para, elige él qué significa |
| ④ | Sin «fuera de alcance» | El WP crece: refactor, logs, caché… todo cabe en «lo relacionado» |
| ⑤ | `src/**` | Anula el hook. El control existe pero no controla nada |
| ⑥ | «Que funcione bien» | No es un comando. Nada verificable, nada reproducible en CI |
| ⑦ | «Limpio y mantenible» | Criterio subjetivo: dos revisores dan veredictos opuestos |
| ⑧ | «Mejora el rendimiento» | Sin línea base ni umbral. ¿Mejora respecto a qué? ¿Cuánto basta? |

**Consecuencia real:** el `planner` lo rechaza en la DoR. Si se colara, el `implementer` pararía en el primer minuto por ambigüedad (③) — y eso sería el **mejor** desenlace. El peor es que no pare: entonces implementa su interpretación, toca medio `src/`, y la revisión no puede rechazarlo por contrato porque el contrato no dice nada.

---

## Lista de comprobación antes de poner un WP en `ready`

- [ ] ¿El objetivo describe un estado final observable?
- [ ] ¿Un tercero podría verificarlo sin preguntarme nada?
- [ ] ¿«Fuera de alcance» impide las tres expansiones más probables?
- [ ] ¿Los archivos permitidos son los mínimos suficientes? (¿Hay algún `**` que sobre?)
- [ ] ¿Cada comando de validación se ejecuta sin humano delante?
- [ ] ¿Cada criterio se comprueba ejecutando algo concreto?
- [ ] ¿Hay al menos un criterio de **no regresión**?
- [ ] ¿Presupuesto y ciclos declarados?
- [ ] ¿Sé qué haría el agente si se topa con X? (si no, falta una condición de parada)

## Anti-patrones que la FDA rechaza

Encargos ambiguos («mejora el backend»); WPs sin comandos de validación; agentes con acceso total «para ir más rápido»; fusionar con CI rojo «por esta vez»; conclusiones de coste con n=1; construir orquestación propia antes de agotar lo que GitHub + Claude Code ya dan hecho.
