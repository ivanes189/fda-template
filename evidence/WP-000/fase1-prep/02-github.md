# Evidencia — Configuración de GitHub y CI en verde

**Fecha:** 2026-07-23 · **Repositorio:** https://github.com/ivanes189/fda-template

## Estado de la configuración

| Elemento | Estado | Nota |
|---|---|---|
| Repositorio | ✅ `ivanes189/fda-template` | **Público** — ver justificación abajo |
| `main` empujada | ✅ 35 commits | Autoría anonimizada antes de publicar |
| CI sobre `main` | ✅ **success** | 3 jobs en verde |
| Ruleset `main-calibracion` | ✅ **activo** (id 19625506) | Verificado con un push rechazado |
| Secret scanning | ✅ enabled | |
| Push protection | ✅ enabled | |
| Dependabot (alertas + seguridad) | ✅ enabled | |
| Secreto `ANTHROPIC_API_KEY` | ⏸ **pendiente** | Lo configura una persona con `gh secret set` |

## CI en verde sobre main

```
completed  success  WP-000: entrecomillar expresiones de git en el script de anonimización
                    CI  main  push  run 30018031893

JOBS
✓ Gobierno FDA
✓ Lint · Shell · Tests · Manual
✓ Escaneo de secretos
```

Los tres jobs son **checks obligatorios** del ruleset.

## Ruleset: reglas activas sobre main

```
$ gh api repos/ivanes189/fda-template/rules/branches/main --jq '[.[] | .type] | unique'
["deletion","non_fast_forward","pull_request","required_status_checks"]
```

| Regla | Efecto |
|---|---|
| `pull_request` | PR obligatoria. **Aprobaciones requeridas: 0** (decisión D5: tu merge manual es la aprobación) |
| `required_status_checks` | Los 3 checks deben pasar. Política estricta: la rama debe estar al día |
| `non_fast_forward` | Force-push prohibido |
| `deletion` | Borrado de `main` prohibido |

Sin actores de excepción (*bypass actors*): las reglas aplican **también al propietario del repositorio**. Un control que el administrador puede saltarse a voluntad no es un control.

## Prueba de que el enforcement es real

El punto B1 del diagnóstico advertía: «sin remoto no hay branch protection: hoy *el implementer no puede fusionar* depende de disciplina, no de construcción». Prueba de que ya no:

```
$ git commit --allow-empty -m "PRUEBA: este commit no debe poder empujarse a main"
$ git push origin main

remote:
remote: - Changes must be made through a pull request.
remote:
remote: - 3 of 3 required status checks are expected.
remote:
To https://github.com/ivanes189/fda-template.git
 ! [remote rejected] main -> main (push declined due to repository rule violations)
error: falló el empuje de algunas referencias
```

El commit de prueba se revirtió en local. **B1 queda cerrado:** la fusión ya no depende de que nadie —persona o agente— se acuerde de no empujar a `main`.

## Por qué el repositorio es público

El plan pedía repositorio **privado**. No fue posible mantener ambas cosas:

```
$ gh api --method POST repos/ivanes189/fda-template/rulesets ...
403: Upgrade to GitHub Pro or make this repository public to enable this feature.
```

En una cuenta personal sin Pro, un repositorio privado **no admite rulesets ni branch protection**. Las opciones eran: pagar Pro, renunciar a la protección de rama, o publicar.

Se optó por publicar, por decisión humana explícita, porque el plan clasifica la protección de rama como **bloqueo real** para la Fase 1: sin ella se calibraría una fábrica cuya garantía central no está activa, y WP-005 no podría cumplir su criterio de aceptación.

Ventaja añadida: en repositorios públicos, el secret scanning y la push protection nativos son gratuitos, así que **SEC-001 pasa a estar cubierto de verdad** y no solo por el job de gitleaks.

### Revisión previa a publicar

Antes de la publicación —acción irreversible— se comprobó:

| Comprobación | Resultado |
|---|---|
| Archivos de secretos versionados (`.env`, `*.pem`, `secrets/`) | ninguno |
| Cadenas con forma de credencial en **todo el historial** | ninguna |
| `.claude/settings.local.json` versionado | no |
| Correo de autoría en los commits | **hallazgo** — corregido |

El correo personal aparecía en los 35 commits y habría quedado público y permanente. Se reescribió el historial a `74557686+ivanes189@users.noreply.github.com`, verificando que el árbol de archivos quedaba **idéntico**: solo cambió la metadata. Respaldo del historial original en `refs/original/refs/heads/main`.

Quedan visibles rutas locales (`/Users/ivan/...`) en tres archivos de log de evidencias. Revelan el nombre de usuario local; se consideró un dato menor y se dejó constancia.

## Lo que falta

**El secreto `ANTHROPIC_API_KEY`.** No lo configura ningún agente: `gh secret set` lo lee de forma interactiva y lo transmite cifrado, sin que el valor pase por la sesión ni por ningún archivo.

```bash
gh secret set ANTHROPIC_API_KEY --repo ivanes189/fda-template
```

Lo necesitan `claude.yml` y `code-review.yml`. Ninguno de los dos se activa durante la Fase 1 —que es interactiva—, así que no bloquea la calibración.
