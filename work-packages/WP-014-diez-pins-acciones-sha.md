# WP-014 — Diez acciones de workflows fijadas por SHA

estado: done
prioridad: P0
riesgo: T3
agente_responsable: Claude Code (implementer)
agente_revisor: GPT-6 Astra (Alto, contexto nuevo, externo, solo lectura)
requisitos: [REQ-FDA-002, SEC-001]  adr: [ADR-001]
decision: [DEC-008]
presupuesto_max_eur: 12             max_ciclos_correccion: 2

<!-- CIERRE — 2026-09-13, por decisión humana. La PR #40, revisada sobre el
     HEAD d1ae1b86fbe3114cf583ddc9ff73c90d758ad526, fue fusionada mediante
     ea004919b661baf206257952f2fd5ca7bfad2c05 con los tres checks en SUCCESS.
     Resultado: diez pins exactos (5/2/1/2), aplicación humana, revisión Astra
     completa y revalidación enfocada APTO tras C1; coste medido 2,73 EUR de
     12 EUR y contador final 1/2. Evidencia: evidence/WP-014/CIERRE.md. -->

## Objetivo y contexto

Los tres workflows versionados conservan su comportamiento y contienen
exactamente diez referencias `uses:` a acciones de terceros fijadas a los SHA
completos aprobados, cada una con su versión legible en comentario adyacente.
El criterio 2 de REQ-FDA-002 devuelve vacío y la procedencia de los cuatro SHA,
el parche exacto aplicado humanamente y la verificación del candidato quedan
reconstruibles desde `evidence/WP-014/`.

WP-013 quedó `blocked` y DEC-008 retiró la dependencia de un materializador
general. Este WP usa únicamente Git nativo sobre un worktree limpio y dedicado.

## Alcance (incluido / fuera de alcance)

**Incluido:**
- sustituir las diez etiquetas móviles ya existentes, sin añadir ni retirar
  pasos, por los cuatro SHA y comentarios de versión cerrados en este contrato;
- preparar un único parche de workflows, versionarlo como blob Git y detenerse
  antes de su comprobación y aplicación protegidas por Iván;
- actualizar mínimamente REQ-FDA-002 y el manual para reflejar el estado real y
  satisfacer la regla documental existente;
- verificar sintaxis, cardinalidad, postimágenes, diff exacto, permisos,
  ausencia de construcciones prohibidas, evidencia y coste.

**Fuera de alcance:**
- crear materializadores, scripts, dependencias, acciones, jobs o tests nuevos;
- cambiar lógica, eventos, permisos, secretos, argumentos, modelos o versiones
  distintas de las cuatro fijadas aquí;
- modificar el ruleset, `CODEOWNERS`, hooks, agentes, `ACTIVE`, contratos,
  decisiones, ADR, otros requisitos o cualquier otro workflow;
- incorporar código o evidencias de las candidatas WP-009/WP-013, reabrirlas,
  limpiar sus ramas/worktrees o ejecutar sus artefactos;
- crear o ejecutar WP-008, comprar créditos, desplegar o fusionar la PR.

## Archivos permitidos

- .github/workflows/ci.yml
- .github/workflows/claude.yml
- .github/workflows/code-review.yml
- specs/requirements/REQ-FDA-002-workflows-endurecidos.md
- docs/manual/01-instalacion.md
- evidence/WP-014/**

## Archivos prohibidos

- work-packages/**
- specs/decisions/**
- specs/adr/**
- .claude/**
- .codex/**
- CODEOWNERS
- tests/**
- scripts/**
- evidence/WP-009/**
- evidence/WP-013/**

## Contratos técnicos (interfaces, schemas, eventos, invariantes)

### Matriz cerrada de pins

Los valores se resolvieron el 2026-09-13 mediante `git ls-remote` sobre cada
repositorio oficial. En tags anotados se usa el commit pelado `^{}`, no el
objeto tag. La etiqueta semántica y el SHA constituyen la pareja aprobada:

| Acción oficial | Apariciones | Versión legible | SHA de commit completo |
|---|---:|---|---|
| `actions/checkout` | 5 | `v4.4.0` | `11d5960a326750d5838078e36cf38b85af677262` |
| `actions/setup-python` | 2 | `v5.6.0` | `a26af69be951a213d495a4c3e4e4022e16d87065` |
| `gitleaks/gitleaks-action` | 1 | `v2.3.9` | `ff98106e4c7b2bc287b24eaf42907196329070c7` |
| `anthropics/claude-code-action` | 2 | `v1.0.223` | `9cdae7f0d995e3ba7c33f226087fdf82a59cd520` |

Cada postimagen tiene la forma exacta `owner/repo@SHA # versión`. No se conserva
la etiqueta móvil en posición ejecutable. Las cinco, dos, una y dos apariciones
permanecen en los mismos archivos y posiciones lógicas que sus preimágenes.

No cambian nombres, modos (`100644`) ni tipos de los tres workflows. Tampoco
cambia ninguna línea de workflow que no sea una de las diez líneas `uses:`.
El comentario legible se incorpora en esa misma línea; no añade otra línea.

### Parche protegido

Claude Code puede escribir el parche
`evidence/WP-014/parche/workflows-actions-sha.patch`, las demás evidencias y las
dos rutas documentales permitidas. No edita directamente
`.github/workflows/**`, cuya edición está denegada por
`.claude/settings.json`.

El parche unificado contiene exactamente las diez sustituciones cerradas y
ninguna otra ruta. Se crea en el worktree dedicado y se commitea primero; ese
commit es `PATCH_COMMIT`. Después se escribe y commitea
`evidence/WP-014/manifest.md`, que registra `BASE_SHA`, `PATCH_COMMIT`, la ruta
y `PATCH_BLOB`. `PATCH_BLOB` es exactamente un OID Git hexadecimal de 40
caracteres y de tipo `blob`, no un nombre simbólico ni un revspec. Así el
manifiesto no intenta contener el SHA de su propio commit.

`BASE_SHA` es el `main` remoto consultado inmediatamente antes de crear la rama
y el worktree, y coincide con el commit inicialmente extraído. La consulta, el
SHA y el instante UTC quedan en `manifest.md`. Antes del acto humano, el HEAD
limpio se captura como `PRE_APPLY_HEAD`: puede ser posterior a `PATCH_COMMIT`,
pero este es su ancestro y el blob de la ruta del parche es idéntico en ambos.
`PRE_APPLY_HEAD` se registra después en la evidencia de aplicación, evitando
otra autorreferencia.

Iván ejecuta personalmente, desde la raíz de ese worktree limpio, la
comprobación y aplicación protegidas. Primero fija y comprueba las tres
identidades ya registradas. Después obtiene ambas entradas del mismo objeto Git
inmutable identificado por `PATCH_BLOB`:

```bash
set -euo pipefail
PATCH_COMMIT="$(sed -n 's/^PATCH_COMMIT: `\([0-9a-f]\{40\}\)`.*/\1/p' evidence/WP-014/manifest.md)"
PATCH_BLOB="$(sed -n 's/^PATCH_BLOB: `\([0-9a-f]\{40\}\)`.*/\1/p' evidence/WP-014/manifest.md)"
PRE_APPLY_HEAD="$(git rev-parse --verify HEAD^{commit})"
test -z "$(git status --porcelain=v1 -uall)"
git merge-base --is-ancestor "$PATCH_COMMIT" "$PRE_APPLY_HEAD"
test "$(git cat-file -t "$PATCH_BLOB")" = blob
test "$(git rev-parse "${PATCH_COMMIT}:evidence/WP-014/parche/workflows-actions-sha.patch")" = "$PATCH_BLOB"
test "$(git rev-parse "${PRE_APPLY_HEAD}:evidence/WP-014/parche/workflows-actions-sha.patch")" = "$PATCH_BLOB"
git cat-file blob "$PATCH_BLOB" | git apply --check --index -
test -z "$(git status --porcelain=v1 -uall)"
git cat-file blob "$PATCH_BLOB" | git apply --index -
```

Codex y Claude Code se detienen antes de esas dos órdenes. Preparar el parche,
mostrar los comandos o disponer de autorización para ejecutar WP-014 no
autoriza a ejecutarlas por interfaz, API o CLI. La aplicación humana requiere
su autorización separada y confirmación posterior.

Precondiciones del acto: worktree dedicado; `HEAD` igual a `PRE_APPLY_HEAD`,
con `PATCH_COMMIT` ancestro y el blob idéntico;
índice y árbol limpios; raíz, `.git` y tres destinos esperados; destinos
regulares modo `100644`; ningún trabajo ajeno; `PATCH_BLOB` resuelve exactamente
a la ruta registrada. Tras la primera orden el árbol permanece limpio. Tras la
segunda, índice y árbol contienen las mismas tres modificaciones protegidas.

Si cualquier precondición u orden falla, no se repite a ciegas, no se usa
`--reject`, `--3way`, `--unsafe-paths` ni `--force`: se preservan diagnóstico y
estado, se para y se escala. Git no se describe como sandbox ni transacción
general. La recuperación ordinaria solo descarta y recrea el worktree dedicado
después de comprobar que no contiene trabajo ajeno y con autorización humana;
un fallo del repositorio compartido o almacenamiento se escala.

REQ-FDA-002 cambia solo lo necesario para registrar que su criterio 2 queda
cumplido por WP-014. El manual cambia solo lo necesario para explicar que la
plantilla distribuye acciones fijadas a SHA y que sus actualizaciones conservan
versión legible y revisión explícita. No se modifica el significado de ningún
control.

## Entorno autorizado (herramientas, comandos, red, secretos)

- Claude Code: Read, Grep, Glob, Write/Edit solo fuera de workflows y dentro de
  las rutas permitidas; Bash local para preparar, commitear y verificar.
- Iván: las dos órdenes Git protegidas anteriores, únicamente tras el punto de
  parada y dentro del worktree identificado.
- Comandos: `git` local, `python3`, `bash`, `actionlint`, `shasum`, `diff`,
  `grep`, `sed`.
- Red: solo el coordinador consulta `refs/heads/main` antes de crear el
  worktree. NINGUNA para Claude durante preparación, aplicación y verificación.
  La procedencia queda cerrada aquí; cambiar la matriz exige decisión.
- Secretos: NINGUNO; no leer, imprimir ni versionar valores de secretos.

## Verificación (comandos de validación + criterios de aceptación medibles)

**Comandos headless sobre candidato limpio y commiteado:**

```bash
set -euo pipefail
WP014_HEAD="$(git rev-parse --verify HEAD^{commit})"
WP014_BASE="$(sed -n 's/^BASE_SHA: `\([0-9a-f]\{40\}\)`.*/\1/p' evidence/WP-014/manifest.md)"
test -n "$WP014_BASE"
test -z "$(git status --porcelain=v1 -uall)"
git merge-base --is-ancestor "$WP014_BASE" "$WP014_HEAD"
git diff --check "$WP014_BASE" "$WP014_HEAD"

actionlint -color .github/workflows/*.yml
python3 .claude/skills/run-verification/validate-workflows.py .github/workflows
ACTIVE_RESULT="$(bash tests/governance/check-active.sh)"
test "$(printf '%s\n' "$ACTIVE_RESULT" | sed -n '1p')" = 'ACTIVO: WP-014'
ACTIVE_ID="$(sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' work-packages/ACTIVE)"
test "$ACTIVE_ID" = 'WP-014'
python3 evidence/WP-000/checks/check-manual.py

test -z "$(grep -rn 'uses:' .github/workflows/ | grep -v '@[0-9a-f]\{40\}' | grep -v 'uses: \./')"
python3 - "$WP014_BASE" "$WP014_HEAD" <<'PY'
import subprocess, sys
base, head = sys.argv[1:]
paths = (".github/workflows/ci.yml", ".github/workflows/claude.yml",
         ".github/workflows/code-review.yml")
replacements = {
    b"actions/checkout@v4": b"actions/checkout@11d5960a326750d5838078e36cf38b85af677262 # v4.4.0",
    b"actions/setup-python@v5": b"actions/setup-python@a26af69be951a213d495a4c3e4e4022e16d87065 # v5.6.0",
    b"gitleaks/gitleaks-action@v2": b"gitleaks/gitleaks-action@ff98106e4c7b2bc287b24eaf42907196329070c7 # v2.3.9",
    b"anthropics/claude-code-action@v1": b"anthropics/claude-code-action@9cdae7f0d995e3ba7c33f226087fdf82a59cd520 # v1.0.223",
}
expected_counts = [5, 2, 1, 2]
observed = [0, 0, 0, 0]
for path in paths:
    before = subprocess.check_output(["git", "show", f"{base}:{path}"])
    after = subprocess.check_output(["git", "show", f"{head}:{path}"])
    expected = before
    for index, (old, new) in enumerate(replacements.items()):
        observed[index] += expected.count(old)
        expected = expected.replace(old, new)
    assert after == expected, f"postimagen inesperada: {path}"
    for rev in (base, head):
        meta = subprocess.check_output(["git", "ls-tree", rev, "--", path]).split()
        assert meta[:2] == [b"100644", b"blob"], f"tipo/modo inesperado: {rev}:{path}"
assert observed == expected_counts, (observed, expected_counts)
PY

test -z "$(git diff --name-only "$WP014_BASE" "$WP014_HEAD" | grep -E '(^|/)\.env($|\.)|\.pem$|(^|/)secrets/')"
set +e
git grep -q -E 'sk-[A-Za-z0-9]|gh[op]_[A-Za-z0-9]|AKIA[0-9A-Z]{16}|BEGIN [A-Z ]*PRIVATE KEY' "$WP014_HEAD" -- evidence/WP-014
SECRET_RC=$?
set -e
case "$SECRET_RC" in 1) : ;; 0) echo 'ERROR: posible secreto en evidence/WP-014' >&2; exit 1 ;; *) echo 'ERROR: falló el escaneo local' >&2; exit "$SECRET_RC" ;; esac
git diff --exit-code --no-renames "$WP014_BASE" "$WP014_HEAD" -- . \
  ':(top,exclude,literal).github/workflows/ci.yml' \
  ':(top,exclude,literal).github/workflows/claude.yml' \
  ':(top,exclude,literal).github/workflows/code-review.yml' \
  ':(top,exclude,literal)specs/requirements/REQ-FDA-002-workflows-endurecidos.md' \
  ':(top,exclude,literal)docs/manual/01-instalacion.md' \
  ':(top,exclude,glob)evidence/WP-014/**'
```

El bloque Python compara cada postimagen byte a byte con su preimagen después de
aplicar solo las cuatro sustituciones y comprueba tipos y modos; no introduce un
script. Después de que Iván cree la PR de implementación, el job existente
`secretos / Escaneo de secretos` debe terminar `success` sobre su HEAD vigente
antes de fusionar. Esa comprobación remota posterior no se presenta como prueba
local ni autoriza a ningún agente a crear o fusionar la PR.

**Criterios de aceptación:**
- [x] Los comandos terminan en 0; `actionlint` y el validador aceptan los tres
      workflows; `ACTIVE` sigue indicando `WP-014` durante la ejecución.
- [x] Hay exactamente diez pins: 5 checkout, 2 setup-python, 1 gitleaks y 2
      claude-code-action, con SHA completo y comentario de versión exactos.
- [x] En los workflows solo cambian esas diez líneas; lógica, permisos, eventos,
      argumentos, secretos, nombres, tipos y modos quedan idénticos.
- [x] El criterio 2 de REQ-FDA-002 devuelve vacío y no se introduce
      `pull_request_target` ni interpolación nueva en bloques `run:`.
- [x] El parche aplicado es el blob registrado y contiene solo los tres
      workflows; las dos órdenes reciben bytes del mismo `PATCH_BLOB`.
- [x] La aplicación fue realizada y confirmada por Iván; ningún agente ejecutó
      las órdenes protegidas ni modificó workflows por otro mecanismo.
- [x] Diff final limitado a seis patrones permitidos; candidatas WP-009/WP-013,
      reglas, workflows ajenos y demás repositorio permanecen intactos.
- [x] Revisión Astra completa de contrato, código y seguridad sin hallazgos
      ALTOS o CRÍTICOS abiertos; correcciones, si existen, las hace Claude y se
      someten a revisión enfocada independiente, máximo dos ciclos.
- [x] `cost.md` es conforme a DEC-004 y el coste es `<= 12 EUR`.
- [x] El job remoto `secretos / Escaneo de secretos` está verde para el HEAD
      vigente de la PR; la URL del check y el SHA se registran sin secretos.

## Evidencias exigidas (qué debe aparecer en evidence/WP-014/)

- [x] `manifest.md`: base, commits/HEAD, `PATCH_BLOB`, rutas, tipos y modos.
- [x] `procedencia.md`: matriz, repositorios oficiales, tags consultados,
      commits pelados cuando aplica y fecha; sin incorporar herramientas WP-009.
- [x] Parche exacto bajo `parche/` y prueba de que su blob coincide con el
      aplicado humanamente.
- [x] `verification.md`: comandos, salidas completas, códigos, comprobación del
      diff de diez líneas y ausencia de rutas no permitidas.
- [x] Confirmación del acto humano sin datos personales ni secretos.
- [x] Resultado local saneado de higiene y, tras crear la PR, referencia al job
      de secretos verde para el HEAD exacto.
- [x] `cost.md` conforme a DEC-004.
- [x] Revisión Astra completa y revisiones enfocadas que correspondan.

## Condiciones de parada específicas

- La base remota cambió de forma incompatible, alguna preimagen no coincide o
  aparece una undécima referencia `uses:` de terceros.
- Se propone otro SHA/versión, una actualización funcional o cualquier ruta no
  permitida; se necesita modificar una decisión, ADR, permiso o ruleset.
- El parche no puede reducirse a diez sustituciones o no es el mismo blob para
  comprobación y aplicación.
- Falta una precondición del worktree, falla Git/actionlint/una comprobación, se
  detecta deriva, trabajo ajeno, un secreto o una vulnerabilidad.
- No puede delegarse la revisión final exactamente en GPT-6 Astra, Alto,
  contexto nuevo y solo lectura: se prepara un mensaje para ejecución manual.
- Se superan 12 EUR o dos ciclos; no se crea C3 cambiando de agente o nombre.

## Migración / rollback

No hay datos ni migración. Antes de fusionar, un fallo de aplicación se trata
con la recuperación acotada de DEC-008. Tras fusionar, rollback = una PR humana
que revierte conjuntamente las diez líneas de workflows y actualiza el estado
documental; nunca se mueve una etiqueta ni se modifica el historial.
