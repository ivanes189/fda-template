---
name: prepare-pr
description: Abre la PR de un WP con la plantilla rellena y las evidencias adjuntas. Usar solo cuando run-verification haya dado APTO.
---

# Preparar la PR de un WP

Convierte un WP verificado en una PR revisable. **Nunca fusiona**: la fusión es humana durante la calibración.

## Precondiciones (comprobar antes de nada)

- [ ] `run-verification` ha dado **APTO**
- [ ] `evidence/WP-XXX/` contiene las evidencias exigidas por el WP
- [ ] `evidence/WP-XXX/cost.md` existe y está relleno
- [ ] El diff toca **solo** archivos permitidos por el WP
- [ ] La rama es `wp/WP-XXX-descripcion`

Si alguna falla, para. Una PR incompleta consume revisión humana para nada.

## Procedimiento

### 1. Comprobar que el diff respeta el alcance

```bash
WP=$(grep -v '^[[:space:]]*#' work-packages/ACTIVE | grep -v '^[[:space:]]*$' | head -1 | tr -d '[:space:]')
git diff --name-only main...HEAD
```

Contrasta cada archivo con `## Archivos permitidos` del WP. Un archivo fuera de la lista invalida la PR: para y reporta.

### 2. Comprobar que el manual está al día

Si el cambio toca proceso, contrato o agentes, `docs/manual/` debe cambiar en esta misma PR. Manual desactualizado = PR incompleta (CLAUDE.md).

```bash
git diff --name-only main...HEAD | grep -E '^(CLAUDE\.md|\.claude/|work-packages/_TEMPLATE\.md|\.github/)' && \
  echo "→ Cambio de proceso detectado: verifica que docs/manual/ se actualiza en esta PR"
```

### 3. Empujar la rama

```bash
git push -u origin "wp/$WP-descripcion"
```

`git push` está en la lista `ask` de `.claude/settings.json`: requiere confirmación humana. Es intencionado.

### 4. Abrir la PR

```bash
gh pr create \
  --title "$WP: <título del WP>" \
  --body-file .github/pull_request_template.md \
  --base main
```

Rellena la plantilla con contenido real antes de crear la PR. Una plantilla con las casillas sin marcar y los apartados vacíos no es una PR: es un borrador.

Secciones que hay que rellenar con sustancia:

- **Qué y por qué**: el objetivo del WP y el estado final alcanzado.
- **Evidencias**: rutas concretas dentro de `evidence/WP-XXX/` y qué demuestra cada una.
- **Riesgos**: qué puede romper esto en producción.
- **Deuda introducida**: explícita. Deuda no declarada es el hallazgo, no la deuda.
- **Rollback**: cómo se revierte.
- **Coste**: cifra de `cost.md` contra el presupuesto del WP.

### 5. Solicitar revisión

```bash
gh pr edit --add-reviewer <revisor-humano>
```

`code-review.yml` lanza automáticamente al `code-reviewer` en cada PR. Convoca además al `security-reviewer` si el WP toca auth, secretos, red, entrada de usuario, migraciones o dependencias nuevas.

## Prohibiciones absolutas

- **Nunca** `gh pr merge`. Ni con CI en verde, ni con revisión aprobada, ni «porque es trivial». La fusión es humana.
- Nunca `git push --force` sobre una rama con PR abierta.
- Nunca cierres o reabras PRs ajenas.
- Nunca modifiques `.github/workflows/` para que el CI pase. CI rojo = no se fusiona, sin excepciones conversacionales.

## Tras la revisión

Máximo **2 ciclos de corrección** ordinarios. Al tercero: para, analiza la causa raíz (contrato mal definido, alcance mal troceado, requisito ambiguo) y devuelve el WP a replanificación. Ver `docs/manual/05-bloqueos-y-parada.md`.
