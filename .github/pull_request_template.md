<!--
Plantilla de PR de la FDA. Una PR = un WP.
Rellena TODOS los apartados con contenido real. Casillas sin marcar y apartados
vacíos = PR incompleta: consume revisión humana para nada.
-->

**WP:** WP-XXX — <título>
**Rama:** `wp/WP-XXX-descripcion`
**Requisitos / ADR:** REQ-... / ADR-...

## Qué y por qué

<!-- El estado final alcanzado y el problema que resuelve. No la lista de commits. -->

## Alcance

<!-- Confirma que el diff toca SOLO los archivos permitidos por el WP.
     Si tocaste algo fuera, esta PR no debería existir: explica por qué. -->

- [ ] El diff toca solo archivos de `## Archivos permitidos` del WP
- [ ] No se han modificado `CLAUDE.md`, `.claude/**`, `.github/**` ni `CODEOWNERS` sin autorización explícita del WP

## Verificación

**Comandos ejecutados** (los del WP, tal cual):

```
```

- [ ] Todos los comandos de validación en verde
- [ ] Todos los criterios de aceptación cumplidos y evaluados uno a uno
- [ ] Cobertura de pruebas del código modificado sin regresión

## Evidencias

<!-- Rutas concretas en evidence/WP-XXX/ y qué demuestra cada una.
     "Ver evidencias" no es una entrada válida. -->

- `evidence/WP-XXX/` — 
- [ ] Salidas íntegras con código de salida
- [ ] `cost.md` relleno

## Riesgos

<!-- Qué puede romper esto en producción. "Ninguno" exige justificarlo. -->

## Deuda introducida

<!-- Explícita. Deuda no declarada es el hallazgo, no la deuda.
     Si no hay, escribe "ninguna" y responde por ello en revisión. -->

## Rollback

<!-- Cómo se revierte. Si hay migración de datos, el plan de vuelta atrás. -->

## Coste

| Concepto | Valor |
|---|---|
| Coste del WP | € |
| Presupuesto del WP | € |
| Ciclos de corrección consumidos | / 2 |

## Documentación

- [ ] Si esta PR cambia proceso, contrato o agentes, `docs/manual/` se actualiza **en esta misma PR** (CLAUDE.md: manual desactualizado = PR incompleta)

## Revisión

- [ ] `code-reviewer` ha revisado
- [ ] `security-reviewer` ha revisado — **obligatorio** si toca auth, secretos, red, entrada de usuario, migraciones o dependencias nuevas
- [ ] Revisión humana (durante la calibración, siempre)

---

⚠️ **La fusión es humana.** Ningún agente fusiona su propia PR. CI en rojo = no se fusiona, sin excepciones conversacionales.
