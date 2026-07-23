## Problema encontrado

Vaciar `work-packages/ACTIVE` —el estado seguro entre dos WPs— **rompía el CI**. El paso `El WP activo existe` del job `Gobierno FDA` devolvía exit 1, y ese job es check obligatorio del ruleset: ninguna PR podría fusionarse, **incluida la que arreglase el problema**.

Añadido: con la fábrica en reposo, el guard bloqueaba comandos de solo diagnóstico cuyo único destino era `/dev/null`.

## Causa raíz

Dos, independientes:

1. **La comprobación se escribió asumiendo que siempre hay un WP en curso.** Entre dos WPs no lo hay, y ese es precisamente el estado deseable. El defecto no era vaciar `ACTIVE`: era la comprobación.
2. **En `guard.sh`, los destinos exentos se filtraban DESPUÉS del chequeo fail-closed.** Con `ACTIVE` vacío se denegaba antes de llegar a comprobar que el destino era `/dev/null`.

## Solución aplicada

**La lógica de gobierno sale del YAML y pasa a un script versionado con pruebas.** `ci.yml` queda como una línea que invoca `tests/governance/check-active.sh`.

Los workflows están vedados a los agentes —y deben seguir estándolo, porque ejecutan código con los secretos del repositorio—. Mientras la lógica viviera incrustada en el YAML, **cada ajuste futuro exigiría intervención humana**. Ahora no.

Semántica implementada:

| `ACTIVE` | Resultado | Salida |
|---|---|---|
| Vacío | exit 0 | `REPOSO` |
| WP existente con alcance | exit 0 | `ACTIVO: WP-XXX` |
| WP inexistente / mal formado / sin alcance | exit 1 | `ERROR` |
| Archivo ausente | exit 2 | `ERROR` |

En `guard.sh`, el filtro de exentos se mueve antes de resolver el WP activo. **El fail-closed no cambia**: con `ACTIVE` vacío se sigue denegando toda escritura real.

## Alternativas descartadas

| Alternativa | Por qué no |
|---|---|
| Parchear el bloque inline de `ci.yml` | Deja la lógica en un archivo vedado a los agentes: cada cambio futuro necesitaría intervención humana |
| Mantener `WP-000` activo de forma permanente | Deja abierto el alcance de bootstrap (`.claude/**`, `.github/**`, `work-packages/**`) sin nadie trabajando |
| Relajar el fail-closed del guard | Cambia un control de seguridad para arreglar un problema de CI. Son capas distintas con propósitos distintos |
| Reabrir WP-000 | Está cerrado, y su alcance es enorme para una reparación que necesita 5 rutas |

## Pruebas ejecutadas

```
bash tests/governance/test-check-active.sh                      exit=0   10/10
bash tests/guard/run-suite.sh                                   exit=0   68 OK · 0 fallidas · 10 xfail
bash evidence/WP-000/checks/check-structure.sh                  exit=0
python3 evidence/WP-000/checks/check-agents-skills.py           exit=0
python3 .claude/skills/run-verification/validate-workflows.py   exit=0
python3 evidence/WP-000/checks/check-manual.py                  exit=0   31 enlaces, 0 rotos
actionlint                                                      exit=0
shellcheck --severity=warning (todos los .sh)                   exit=0
```

**Prueba clave del grupo K:** un comando con destino exento **y** destino real sigue bloqueado. El filtro no abre ninguna puerta trasera.

## Hallazgo colateral: la suite del guard dependía del estado ambiental

Al cambiar `ACTIVE` de WP-000 a WP-006, **8 casos se pusieron rojos sin que el guard hubiera cambiado nada**: los grupos A–H se ejecutaban contra el repositorio real y, por tanto, contra el WP activo del momento.

Una batería de pruebas que se rompe según qué encargo esté en curso enseña a la gente a ignorarla, que es la peor avería posible en un control. Corregido con un fixture de bootstrap: los casos ya son deterministas.

## Evidencias

- `evidence/WP-006/01-verificacion.md` — los 8 comandos, los 4 estados de ACTIVE, el grupo K completo
- `evidence/WP-006/02-alcance-del-diff.md` — análisis del diff y **convención que debe implementar `check_scope` (WP-002)**
- `evidence/WP-006/aplicar-reparacion.sh` + su log — el parche humano, con huellas SHA-256 de integridad
- `evidence/WP-006/cost.md` — pendiente de `/cost`

## Riesgos

**Bajo.** No se relaja ningún control: `settings.json` intacto, denies intactos, fail-closed intacto y probado explícitamente. El cambio de `ci.yml` sustituye lógica por una llamada equivalente y **más estricta**: detecta además identificadores mal formados y WPs sin alcance declarado, que antes pasaban desapercibidos.

**Deuda declarada:**

- 10 huecos conocidos del guard registrados como `xfail`, con dueño (WP-002). Dos son nuevos, descubiertos en este WP: el `>` entrecomillado seguido de cadena, y las rutas exentas escritas tras una variable sin expandir.
- La exención nominal de `ACTIVE` y del contrato propio en `check_scope` queda **especificada pero no implementada** (WP-002).
- `V0` de `/cost` no se registró: WP-006 nació como reparación urgente, sin medición previa. Es en sí mismo un dato de calibración.

## Rollback

Cerrar la PR sin fusionar. O restaurar los dos archivos parcheados desde `evidence/WP-006/backups/<fecha>/`.

---

⚠️ **La fusión es humana.** Fase 1 no iniciada: WP-001 a WP-005 siguen en `draft`.

---

## Hallazgo colateral (no corregido aquí): falta la GitHub App de Claude

El check `code-reviewer` falla en esta PR y en la #2, con la API key ya configurada:

```
401 Unauthorized - Claude Code is not installed on this repository.
```

`claude-code-action@v1` necesita **dos** requisitos: el secreto `ANTHROPIC_API_KEY` (presente) y la **GitHub App instalada** (ausente). El manual documenta el primero y no el segundo.

No se corrige en este WP: instalar la App es una acción humana, y actualizar el manual quedaría fuera del objetivo de WP-006. Análisis y opciones en `evidence/WP-006/03-hallazgo-github-app.md`.

**No bloquea:** `code-reviewer` no es check obligatorio. Los tres que sí lo son están en verde.
