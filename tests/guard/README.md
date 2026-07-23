# Suite adversarial de `guard.sh`

Pruebas de regresión del hook `.claude/hooks/guard.sh`, el control determinista que impide escribir fuera del alcance del WP activo.

```bash
bash tests/guard/run-suite.sh
```

Exit `0` = todo conforme · exit `1` = algún fallo inesperado. Headless, sin red, sin dependencias más allá de bash, `python3` o `jq`.

Para validar un parche del guard **antes** de instalarlo:

```bash
FDA_GUARD=/ruta/al/candidato.sh bash tests/guard/run-suite.sh
```

## Convención

| Convención | Significado |
|---|---|
| exit `0` del guard | Permite la escritura |
| exit `2` del guard | La bloquea |

## Tipos de caso

- **`run`** — comportamiento exigido. Si no se cumple, la suite falla y el CI se pone rojo.
- **`xfail`** — hueco **conocido** del guard, documentado con el WP que lo cerrará. Hoy no se comporta como se desea; la suite lo tolera y lo reporta. Si algún día pasa, se marca **XPASS** y hay que promoverlo a `run` para que quede como regresión.

Un `xfail` no es una prueba que «no importa»: es un límite del control, medido y con dueño.

## Grupos

| Grupo | Qué cubre |
|---|---|
| A | Rutas dentro del alcance de WP-000 |
| B | **Regresión**: rutas permitidas que aún no existen en disco |
| C | Fuera de alcance por omisión |
| D | Prohibidos explícitos (prohibido gana a permitido) |
| E | Evasión por forma de la ruta (traversal, absolutas) |
| F | Fail-closed (sin `ACTIVE`, vacío, WP inexistente, sin rutas) |
| G | Escrituras vía Bash |
| H | Falsos positivos que **no** deben bloquearse |
| I | **Autoprotección** frente a un WP de alcance realista |
| J | Huecos conocidos (`xfail`) |

### Por qué el grupo B existe

Detectó un defecto real: `matches_any()` iteraba con `for _g in $_globs`, y una variable sin comillas en un `for` sufre *pathname expansion*. Bash expandía `docs/**` contra el disco antes de compararlo, así que el guard validaba contra **los archivos que ya existían**, no contra el contrato del WP. Rutas nuevas dentro de alcance se bloqueaban.

### Por qué el grupo I usa un fixture y no el repositorio real

El alcance de bootstrap de WP-000 incluye `.claude/**`, `work-packages/**` y `CODEOWNERS`, así que frente a WP-000 esas escrituras están **legítimamente permitidas**. La pregunta que importa —«¿puede un implementer reescribir su propio contrato?»— solo tiene sentido frente a un WP de trabajo normal, y por eso el grupo monta un fixture cuyo alcance es únicamente `docs/manual/**`.

Si estos casos dejaran de bloquear, el enforcement entero colapsaría: un agente que puede editar `work-packages/ACTIVE` o su propio WP puede ampliarse el alcance a voluntad.

## Huecos conocidos y su cierre

El guard es **preventivo y best-effort**. El shell admite vías de escritura no enumerables, así que ningún analizador de comandos puede ser exhaustivo:

| Hueco | Cierra en |
|---|---|
| Symlink dentro de alcance apuntando fuera | WP-002 |
| `python -c "open(...,'w')"` | WP-002 |
| Redirección dentro de comillas simples (`bash -c '… > ruta'`) | WP-002 |
| `git apply` de un parche fuera de alcance | WP-002 |
| `tar -C` extrayendo fuera de alcance | WP-002 |
| APFS: variante en minúsculas que elude un prohibido | WP-002 |
| `git push -f` / `--force` | No aplica: el control está en `permissions.deny` de `settings.json`, no en el hook |

**La defensa concluyente no es ampliar esta lista**, que es infinita, sino la verificación post-hoc del diff (`scripts/check_scope.py`, WP-002, impuesta en CI por WP-005). Sobre el diff de una PR no hay bypass posible, use el agente la herramienta que use: el hook evita el error, el check del diff lo hace imposible de fusionar.

Ver [`REQ-FDA-001`](../../specs/requirements/REQ-FDA-001-alcance-verificado.md).
