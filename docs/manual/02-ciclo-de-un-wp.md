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
| `Gobierno FDA` | Estructura intacta, hook ejecutable, WP activo existe, guard bloquea, workflows válidos, manual sin enlaces rotos, manual actualizado si cambia el proceso |
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
| Implementar dentro del alcance de un WP `ready` | Sí |
| Pasar un WP de `draft` a `ready` | **No** — es tu firma del contrato |
| Escribir en `ACTIVE` (activar o poner en reposo) | **No** — acto del operador |
| Ampliar los archivos permitidos de un WP | **No** — cambio de contrato |
| Fusionar una PR | **No** — durante la calibración, siempre humana |
| Modificar `.claude/**`, `.github/**`, `CODEOWNERS` | **No** — denegado por `settings.json` |

## Los dos modos de ejecución

| | Interactivo | CI |
|---|---|---|
| Cómo | Tú en Claude Code lanzando agentes | `@claude implementa WP-014` en un issue |
| Cuándo | **Calibración** (recomendado al empezar) | Cuando los contratos estén rodados |
| Contratos | Los mismos | Los mismos |
| Control de coste | `/cost` por sesión | `--max-turns` en `claude_args` |

Mismos contratos porque el gobierno vive en archivos del repositorio, y el agente los carga igual en tu máquina que en un runner.
