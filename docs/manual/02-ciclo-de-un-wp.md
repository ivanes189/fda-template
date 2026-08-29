[← Manual](MANUAL.md)

# 02 — El ciclo de un work package

Un WP = una rama = una PR. Ocho pasos, con los comandos exactos de cada uno.

```
1 Crear WP  →  2 Validar DoR  →  3 Implementar  →  4 Verificar
                     ↓ falla                            ↓ falla
                  vuelve a 1                       vuelve a 3 (máx. 2 ciclos)
                                                        ↓
5 Abrir PR  →  6 CI bloqueante  →  7 Revisión  →  8 Fusión (humana)
```

---

## Paso 1 — Crear el WP

```bash
ls work-packages/ | grep -oE 'WP-[0-9]{3}' | sort -u | tail -1    # último ID usado
cp work-packages/_TEMPLATE.md work-packages/WP-014-validar-importes.md
```

En Claude Code, la skill hace el trabajo y valida el contrato:

```
/new-work-package
```

Rellena **todas** las secciones. Cómo escribir un buen contrato: [03 — Redactar un WP](03-redactar-un-wp.md).

## Paso 2 — Validar la Definition of Ready

```
> Usa el agente planner para validar la DoR de WP-014 y trocearlo si es grande.
```

El `planner` responde con qué falta o con la propuesta de troceado. No pasa a `ready` sin: objetivo, alcance, archivos permitidos, comandos de validación y criterios de aceptación.

Cuando esté listo, actívalo. **Este es el paso que hace que el hook empiece a proteger el alcance:**

```bash
sed -i '' 's/^estado: .*/estado: ready/' work-packages/WP-014-validar-importes.md
echo "WP-014" > work-packages/ACTIVE
git add work-packages/ && git commit -m "WP-014: activar work package"
```

Comprueba que el alcance declarado sirve, antes de gastar un solo token:

```bash
echo '{"tool_name":"Write","tool_input":{"file_path":"src/pagos/validacion.py"}}' \
  | .claude/hooks/guard.sh; echo "exit=$?"     # 0 = dentro de alcance
```

## Paso 3 — Implementar

```bash
git checkout -b wp/WP-014-validar-importes
```

```
> Usa el agente implementer para implementar WP-014.
```

El `implementer` trabaja en un worktree aislado (`isolation: worktree`), modifica solo los archivos permitidos y para si necesita salirse. Si se detiene: [05 — Bloqueos y parada](05-bloqueos-y-parada.md).

## Paso 4 — Verificar en local

```
/run-verification
```

O a mano, capturando la evidencia con su código de salida:

```bash
WP=$(grep -v '^[[:space:]]*#' work-packages/ACTIVE | grep -v '^[[:space:]]*$' | head -1 | tr -d '[:space:]')
mkdir -p "evidence/$WP"
{
  echo "=== COMANDO: pytest --cov ==="
  echo "=== COMMIT:  $(git rev-parse --short HEAD) ==="
  pytest --cov 2>&1
  echo "=== EXIT: $? ==="
} | tee -a "evidence/$WP/verificacion.log"
```

**APTO** exige todos los comandos en verde y todos los criterios cumplidos. No hay aprobado por mayoría.

Si falla, vuelve al paso 3. Máximo **2 ciclos**; al tercero, parada y replanificación.

## Paso 5 — Abrir la PR

```
/prepare-pr
```

O a mano:

```bash
git push -u origin wp/WP-014-validar-importes
gh pr create --title "WP-014: validar importes negativos" \
             --body-file .github/pull_request_template.md --base main
```

Rellena la plantilla con contenido real: qué y por qué, evidencias con rutas concretas, riesgos, deuda declarada, rollback y coste. Una plantilla con las casillas sin marcar no es una PR.

> `git push` está en la lista `ask` de `settings.json`: pedirá confirmación. Es intencionado.

## Paso 6 — CI bloqueante

Tres jobs, todos obligatorios:

| Job | Qué comprueba |
|---|---|
| `Gobierno FDA` | Estructura intacta, hook ejecutable, **configuración del runtime fail-closed** (preflight `tests/runtime/check-config.sh`), WP activo existe, guard bloquea, workflows válidos, manual sin enlaces rotos, manual actualizado si cambia el proceso |
| `Lint · Tipos · Pruebas` | Los comandos de tu stack |
| `Escaneo de secretos` | gitleaks + ningún archivo de secretos versionado |

**Rojo = no se fusiona.** No hay excepciones conversacionales. Si el CI está mal, se arregla el CI en su propio WP; no se fusiona «por esta vez».

```bash
gh pr checks --watch
```

## Paso 7 — Revisión

`code-review.yml` lanza al `code-reviewer` automáticamente en cada PR. Para revisión de seguridad —**obligatoria** si el WP toca auth, secretos, red, entrada de usuario, migraciones o dependencias nuevas:

```
> Usa el agente security-reviewer para revisar el diff de esta PR.
```

El revisor verifica **primero el cumplimiento del contrato** (que el diff no toque archivos fuera del WP) y solo después la calidad del código. Un archivo fuera de la lista es rechazo inmediato.

## Paso 8 — Fusión

**Humana, siempre, durante la calibración.**

```bash
gh pr merge --squash --delete-branch     # lo ejecuta una persona, no un agente
```

Ningún agente fusiona. No es una norma de prompt: `settings.json` pone `gh pr merge` en `ask`, y branch protection lo impide a nivel de GitHub.

Cierra el WP:

```bash
sed -i '' 's/^estado: .*/estado: done/' work-packages/WP-014-validar-importes.md
git checkout main && git pull
```

Y **devuelve la fábrica al reposo**:

```bash
printf '# fabrica en reposo: sin WP activo\n' > work-packages/ACTIVE
git add work-packages/ACTIVE && git commit -m "WP-014: devolver la fábrica al reposo"
```

---

## El estado de reposo

Entre dos work packages **no hay ninguno activo**, y eso es correcto. `ACTIVE` vacío no es un error ni un estado a medias: es el estado seguro por defecto.

| Estado de `ACTIVE` | Qué significa | Escrituras | CI |
|---|---|---|---|
| **Vacío** (o solo comentarios) | Reposo: no hay trabajo en curso | **Ninguna** — el guard deniega todo | 🟢 verde |
| **WP existente con alcance** | Trabajo en curso | Solo las rutas de ese WP | 🟢 verde |
| **WP inexistente o mal formado** | Estado incoherente | Ninguna | 🔴 **rojo** |

Compruébalo en cualquier momento:

```bash
bash tests/governance/check-active.sh
```

Responde `REPOSO`, `ACTIVO: WP-XXX` o `ERROR`, con código de salida 0, 0 y ≠0 respectivamente. Es el mismo comando que ejecuta el CI, así que lo que veas en tu terminal es lo que verá GitHub.

**Por qué el reposo importa.** Mientras hay un WP activo, su alcance está abierto. Dejar activo un WP ya terminado —sobre todo uno de alcance amplio como el de bootstrap— significa dejar esa puerta abierta sin que nadie esté trabajando. El reposo la cierra.

**Qué NO significa.** El reposo no relaja ningún control: el guard sigue denegando escrituras, y de hecho las deniega *todas*. Lo único que cambia respecto a un WP activo es que no hay ninguna ruta autorizada.

### Iniciar un WP (salir del reposo)

Escribir en `ACTIVE` es un **acto del operador humano**, no del agente. Ningún WP debe listar `work-packages/ACTIVE` entre sus archivos permitidos: un encargo que puede reescribir el archivo que define su propio alcance puede ampliárselo a voluntad, y todo el control se desmorona.

```bash
echo "WP-015" > work-packages/ACTIVE
bash tests/governance/check-active.sh          # debe decir ACTIVO: WP-015
git add work-packages/ACTIVE && git commit -m "WP-015: activar work package"
```

### Volver al reposo

```bash
printf '# fabrica en reposo: sin WP activo\n' > work-packages/ACTIVE
bash tests/governance/check-active.sh          # debe decir REPOSO
```

### Qué exige aprobación humana

| Acción | ¿Puede hacerla un agente? |
|---|---|
| **Redactar** un WP nuevo en `draft` (skill `/new-work-package`) | **Sí** — es una propuesta, no un contrato firmado |
| Implementar dentro del alcance de un WP `ready` | Sí |
| Pasar un WP de `draft` a `ready` | **No** — es tu firma del contrato |
| Escribir en `ACTIVE` (activar o poner en reposo) | **No** — acto del operador |
| Marcar un WP `blocked` o `done` | **No** — acto del operador: cambia el estado contractual |
| Ampliar los archivos permitidos de un WP | **No** — cambio de contrato |
| Modificar `work-packages/_TEMPLATE.md` | **No** — es el contrato de los contratos |
| Fusionar una PR | **No** — durante la calibración, siempre humana |
| Modificar `.github/workflows/**`, `CODEOWNERS`, `.claude/hooks/**` o `.claude/settings.json` | **No** — denegado por `settings.json` |
| Modificar el resto de `.claude/**` (agentes, skills) | **Depende del WP** — no lo cubre ese deny: lo gobiernan el alcance del WP activo y el guard |

## Las PR de operador (`ops/*`)

Algunos cambios no pertenecen al encargo de ningún WP, sino al **andamiaje que define los encargos**: aprobar un WP, cambiar su estado contractual, mover `ACTIVE`, corregir `_TEMPLATE.md`. Viajan en una **PR de operador**: rama `ops/<descripcion>`, sin WP asociado, y **no implementan nada**.

La norma que las justifica es una sola: **un WP no puede reescribir su propio contrato ni `ACTIVE` para ampliarse el alcance.** Un encargo capaz de editar el archivo que define su alcance puede ampliárselo a voluntad, y el enforcement se desmorona. De ahí que los WPs de trabajo declaren `work-packages/**` entre sus **archivos prohibidos** —WP-002 y WP-006 lo hacen explícitamente— y que ningún WP liste `ACTIVE` entre sus permitidos.

No es que `work-packages/` sea intocable en abstracto: es que **no lo toca el WP que se está ejecutando**. Quién puede hacer qué está en la tabla «Qué exige aprobación humana», más arriba. En particular, **redactar** un WP nuevo en `draft` sí es trabajo de agente —para eso está `/new-work-package`—; lo que es firma humana es **aprobarlo** pasándolo a `ready`.

### PR de WP y PR de operador

| | PR de WP (`wp/WP-XXX-*`) | PR de operador (`ops/*`) |
|---|---|---|
| Qué contiene | La implementación del WP | Cambios de contrato y de estado |
| Quién la aplica | **El agente**, dentro del alcance del WP (ver excepción abajo) | **Una persona** |
| Qué toca | Solo `## Archivos permitidos` del WP | `work-packages/**`, `ACTIVE`, `_TEMPLATE.md` |
| Qué NO toca | El contrato que la gobierna | La implementación de ningún WP |
| Fusión | Humana | Humana |

**Excepción en la PR de WP.** Las rutas vedadas por `settings.json` —`.claude/hooks/**`, `.github/workflows/**`, `.claude/settings.json`, `CODEOWNERS`— **no las escribe ningún agente, tenga el WP el alcance que tenga**. Ahí el agente prepara un **parche verificado** —copia de seguridad, huella `sha256`, validaciones posteriores y prueba de que no toca nada más— y **lo ejecuta una persona**. Protocolo completo en [05 — Bloqueos y parada](05-bloqueos-y-parada.md).

**Cuándo bloquea el guard.** Depende del **WP activo**, no del nombre de la rama: `guard.sh` no sabe en qué rama estás. Si el WP en curso declara `work-packages/**` entre sus prohibidos —lo habitual—, denegará al agente cualquier escritura ahí y el cambio tendrá que aplicarlo el operador. Con la fábrica en reposo deniega todo. No lo supongas: mídelo con la prueba en seco del Paso 2.

### Actos habituales en una PR de operador

| Acto | Qué hace |
|---|---|
| Preparar | Aprueba un WP `draft` → `ready` y lo activa en `ACTIVE` |
| Bloquear | Marca un WP `blocked`, con la causa exacta y el criterio de desbloqueo |
| Cerrar | Marca el WP `done` y devuelve la fábrica al reposo |
| Corregir contrato | Alinea `_TEMPLATE.md` o un WP con una decisión de `specs/decisions/` |

Una misma PR de operador puede **combinar varios**: la que bloqueó WP-002 preparó además WP-007, alineó `_TEMPLATE.md` con DEC-002 y movió `ACTIVE`, todo en un mismo diff.

**Lo que nunca combina es implementación.** Si el cambio necesita tocar `work-packages/` y además escribir código, son **dos PRs**: la de operador primero, la del WP después. Mezclarlas devuelve el sistema al estado en que era imposible verificar el alcance — y es el motivo por el que `check_scope` (WP-002) **no** lleva exenciones nominales para `work-packages/`.

> **Deuda declarada.** El contrato de WP-005 hará **fallar** el job de alcance cuando la rama no encaje en `wp/(WP-[0-9]{3})-.*`, lo que rompería toda PR de operador. Antes de marcar ese check como obligatorio, WP-005 debe decidir qué hace con las ramas `ops/*`. Registrado en `work-packages/WP-002-check-scope.md`, sección «Deuda declarada: WP-005 y las ramas `ops/*`».

## Los dos modos de ejecución

| | Interactivo | CI |
|---|---|---|
| Cómo | Tú en Claude Code lanzando agentes | `@claude implementa WP-014` en un issue |
| Cuándo | **Calibración** (recomendado al empezar) | Cuando los contratos estén rodados |
| Contratos | Los mismos | Los mismos |
| Control de coste | F1/F2/F3 según [DEC-004](../../specs/decisions/DEC-004-estados-del-coste.md) | F1/F2 según DEC-004 · `--max-turns` en `claude_args` |

Mismos contratos porque el gobierno vive en archivos del repositorio, y el agente los carga igual en tu máquina que en un runner.

**El contrato objetivo no depende de pantallas; durante el periodo provisional F3 todavía requiere una lectura humana de `/usage`.** La cifra se adquiere por **F1** (JSON estructurado), **F2** (OpenTelemetry) o **F3** (estimación humana con base concreta), y solo por esas tres. `/cost` existe como alias de `/usage`, pero muestra un panel de sesión: sirve como base F3 y **nunca** como adquisición automática.

**Provisional y objetivo, que no son lo mismo.** Hasta que se fusione **WP-010**, la adquisición por F3 sigue siendo un acto humano previo al cierre del WP, y ningún `cost.md` está validado automáticamente. El objetivo —captura y validación headless, con código de salida significativo, conforme a [ADR-001](../../specs/adr/ADR-001-runtime.md) I2 e I3— lo entrega WP-010. Formato, campos y estados: [06 — Costes y métricas](06-costes-y-metricas.md).
