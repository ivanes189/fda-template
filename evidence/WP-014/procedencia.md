# WP-014 — Procedencia de los cuatro SHA de la matriz cerrada

La matriz de pins es la cerrada en el contrato de WP-014 (idéntica a la
recibida del coordinador humano). Este documento reproduce, sin reabrir
WP-009/WP-013 ni sus herramientas, la trazabilidad exigida por el contrato:
repositorio oficial, apariciones en los tres workflows, versión legible y SHA
de commit completo (commit pelado `^{}` en el caso de las etiquetas anotadas).

| Acción oficial | Repositorio oficial | Apariciones | Versión legible | SHA de commit completo |
|---|---|---:|---|---|
| `actions/checkout` | `github.com/actions/checkout` | 5 | `v4.4.0` | `11d5960a326750d5838078e36cf38b85af677262` |
| `actions/setup-python` | `github.com/actions/setup-python` | 2 | `v5.6.0` | `a26af69be951a213d495a4c3e4e4022e16d87065` |
| `gitleaks/gitleaks-action` | `github.com/gitleaks/gitleaks-action` | 1 | `v2.3.9` | `ff98106e4c7b2bc287b24eaf42907196329070c7` |
| `anthropics/claude-code-action` | `github.com/anthropics/claude-code-action` | 2 | `v1.0.223` | `9cdae7f0d995e3ba7c33f226087fdf82a59cd520` |

Fecha de resolución de la matriz: **2026-09-13**, mediante `git ls-remote` sobre
cada repositorio oficial (acto del coordinador humano; Claude Code no tuvo ni
usó acceso de red durante la preparación de este WP, conforme a la sección
«Entorno autorizado» del contrato). En los cuatro casos la pareja
etiqueta/SHA es la ya cerrada en el contrato `work-packages/WP-014-diez-pins-acciones-sha.md`,
§«Matriz cerrada de pins»; este documento no introduce, sustituye ni reabre
ninguna candidata de procedencia distinta.

## Distribución de apariciones por archivo

Verificada por lectura directa de los tres workflows en este `HEAD` (ver
`evidence/WP-014/verification.md` para el conteo automatizado post-parche):

| Archivo | `actions/checkout` | `actions/setup-python` | `gitleaks/gitleaks-action` | `anthropics/claude-code-action` |
|---|---:|---:|---:|---:|
| `.github/workflows/ci.yml` | 3 (jobs `gobierno`, `calidad`, `secretos`) | 2 (jobs `gobierno`, `calidad`) | 1 (job `secretos`) | 0 |
| `.github/workflows/claude.yml` | 1 | 0 | 0 | 1 |
| `.github/workflows/code-review.yml` | 1 | 0 | 0 | 1 |
| **Total** | **5** | **2** | **1** | **2** |

Suma total: **10** referencias `uses:` de terceros, la cardinalidad exacta que
exige el contrato.

## Herramientas y fuentes no incorporadas

No se reutiliza ningún script, materializador ni herramienta de coste de las
candidatas históricas WP-009 o WP-013. No se consulta red durante esta
preparación: la única consulta remota de la matriz es la registrada arriba,
realizada por el coordinador humano antes de crear la rama y el worktree.
