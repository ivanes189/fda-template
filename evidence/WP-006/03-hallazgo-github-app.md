# Hallazgo colateral — falta la GitHub App de Claude

**Detectado en:** WP-006, al revisar por qué el check `code-reviewer` falla en las PRs #2 y #3.
**Estado:** no corregido en este WP. **Fuera de su objetivo y de su alcance.**

## Síntoma

El workflow `code-review.yml` falla en toda PR, incluso con el secreto `ANTHROPIC_API_KEY` correctamente configurado:

```
App token exchange failed: 401 Unauthorized - Claude Code is not installed on this
repository. Please install the Claude Code GitHub App at https://github.com/apps/claude
Attempt 1 failed: ...
Attempt 2 failed: ...
Attempt 3 failed: ...
Operation failed after 3 attempts
##[error]Action failed with error: Claude Code is not installed on this repository.
```

## Causa raíz

`anthropics/claude-code-action@v1` necesita **dos** requisitos independientes:

| Requisito | Para qué | Estado |
|---|---|---|
| Secreto `ANTHROPIC_API_KEY` | Autenticar contra la API de Claude | ✅ configurado 2026-07-23 15:31Z |
| **GitHub App de Claude instalada en el repositorio** | Obtener un token de instalación para comentar en la PR | ❌ **ausente** |

El manual de instalación (`docs/manual/01-instalacion.md`) documenta el primero pero **no el segundo**. Es un vacío del checklist, no un defecto del código: los workflows están bien escritos.

## Impacto

**Ninguno sobre la Fase 1**, que es interactiva: los agentes se invocan desde Claude Code, no desde GitHub Actions.

`code-reviewer` **no es check obligatorio** del ruleset, así que su fallo no bloquea ninguna fusión. Los tres que sí lo son —`Gobierno FDA`, `Lint · Shell · Tests · Manual` y `Escaneo de secretos`— están en verde.

El impacto real es de higiene: un check permanentemente rojo en todas las PRs **normaliza el rojo**, que es la primera etapa de dejar de mirar el CI.

## Por qué no se corrige aquí

Instalar la App exige una autorización OAuth en `github.com/apps/claude`: es una acción humana, no automatizable. Y actualizar el manual, aunque `docs/manual/**` está dentro del alcance de WP-006, quedaría **fuera de su objetivo** — que es la semántica del estado de reposo. Mezclar cambios no relacionados en un WP es exactamente lo que el contrato prohíbe.

## Acción propuesta

**Decisión para el operador**, dos opciones:

| Opción | Efecto |
|---|---|
| **A — Instalar la App** en https://github.com/apps/claude, concediendo acceso a `ivanes189/fda-template` | `code-reviewer` empieza a funcionar y aporta revisión automática desde la próxima PR |
| **B — Desactivar `code-review.yml`** hasta la Fase 3 | Elimina el rojo permanente. Coherente con el veto del §1.3-B6 del plan, que ya prohíbe activar `claude.yml` hasta entonces |

En ambos casos, el manual necesita una entrada nueva en el checklist de instalación de GitHub. Dueño natural: el WP que redacte los capítulos pendientes del manual, o un WP de documentación específico.

**Recomendación:** opción A si quieres empezar a calibrar la revisión automática ya; opción B si prefieres que la Fase 1 sea íntegramente interactiva, como dice el plan. La segunda es más coherente con lo aprobado.
