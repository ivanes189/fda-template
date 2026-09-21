# WP-008 — Runtime fail-closed: núcleo mínimo

estado: blocked
prioridad: P0
riesgo: T3
agente_responsable: Claude Code (implementer)
agente_revisor: GPT-6 Astra (Alto, contexto nuevo, externo, solo lectura)
requisitos: [REQ-FDA-001, REQ-FDA-003, SEC-001]
adr: [ADR-001]
decision: [DEC-003, DEC-005, DEC-006, DEC-007, DEC-009]
presupuesto_max_eur: 40
max_ciclos_correccion: 2

<!-- Cierre bloqueado por DEC-009. D6-A consumió C1 y C2 ordinarios y C3–C5
excepcionales: 5/2. C6 no está autorizado. Se conservan sin renumerar los once
ciclos históricos y el 2/2 agotado de R2. La candidata D6-A queda preservada
fuera del cierre como histórica no conforme. -->

## Cierre bloqueado

WP-008 D6-A quedó `blocked`, nunca `done`, el 2026-09-21. El A/B final no se
ejecutó y el último dictamen Astra mantiene un hallazgo MEDIO del oráculo de
humo y dos regresiones ineficaces. El contador final es `5 / 2`: C1–C2
ordinarios y C3–C5 excepcionales; no existe C6 autorizado.

La decisión y el expediente mínimo están en
[`DEC-009`](../specs/decisions/DEC-009-cierre-bloqueado-wp-008.md) y
[`evidence/WP-008/CIERRE-BLOQUEADO.md`](../evidence/WP-008/CIERRE-BLOQUEADO.md).
La candidata local se preserva como **CANDIDATA HISTÓRICA NO CONFORME — NO
EJECUTAR** y no forma parte de la PR de cierre.

## Objetivo

Implementar el núcleo mínimo decidido en DEC-007 D6-A:

1. `.claude/settings.json` llama al guard desde la raíz y convierte ausencia, no
   ejecutabilidad o fallo en `exit 2`;
2. cuatro reglas `Read` y cuatro `Edit` quedan ancladas a la raíz;
3. un preflight estructural con suite determinista entra en `Gobierno FDA`; y
4. un humo acredita solo que `Read(/**/.env*)` impide leer el `.env` raíz de un
   proyecto desechable, mediante un control pareado atribuible a esa regla.

WP-012 queda fuera. La candidata R2 permanece histórica, no conforme e intacta; no se copia, reutiliza, modifica, ejecuta ni elimina.

La implementación inicial no consume ciclo. Se consume un ciclo cuando, después
de una pasada completa, una revisión independiente o una validación contractual
exige cambios y la persona abre una nueva pasada de edición. Corregir y revalidar
los mismos hallazgos dentro de esa pasada no abre otro ciclo. Una petición nueva
posterior al cierre de la pasada abre el siguiente. Una parada de operación humana
conserva su clasificación y exige decisión. Un tercer ciclo requiere una decisión
humana nueva, fechada y versionada.

## Alcance

Incluido:

- candidatos exactos para ambos protegidos y aplicador humano probado, anclado y
  fail-closed; aplicación humana separadamente autorizada de ambos;
- `check-config.sh`, oráculos, catorce fixtures y suite de veintidós casos;
- los seis casos de aplicador exigidos por D6-A;
- humo A/B seguro en proyectos desechables externos;
- documentación mínima, evidencias, coste y revisión T3.

Fuera:

- captura roja/verde, protocolo antiguo de doce escenarios, batería A,
  cuarentena, `capturar-ci-rojo.sh` y escáner local de alcance;
- runner empírico y cualquier ruta de WP-012;
- `check_scope`, sandbox, ruleset, permisos, `CODEOWNERS`, `guard.sh`, otros
  workflows, acciones o dependencias; importar/corregir R2 o sus F2/F4/F5;
- afirmar semántica general; mover `ACTIVE`; cambiar decisiones/ADR; publicar o fusionar.

## Archivos permitidos

- .claude/settings.json
- .github/workflows/ci.yml
- tests/runtime/check-config.sh
- tests/runtime/test-check-config.sh
- tests/runtime/test-aplicar-wp008.sh
- tests/runtime/smoke-env-raiz.sh
- tests/runtime/test-smoke-env-raiz.sh
- tests/runtime/command-canonico.txt
- tests/runtime/reglas-canonicas.txt
- tests/runtime/fixtures/config/**
- evidence/WP-008/**
- CLAUDE.md
- docs/02-guia-fabrica-desarrollo-agentica.md
- docs/03-hoja-de-ruta.md
- docs/manual/MANUAL.md
- docs/manual/01-instalacion.md
- docs/manual/04-agentes.md
- docs/manual/07-troubleshooting.md
- specs/requirements/SEC-001-sin-secretos.md

Las dos primeras rutas solo entran mediante el paquete protegido: ningún agente
las escribe; Iván las aplica tras parada y autorización separada.

## Archivos prohibidos

- work-packages/**
- specs/decisions/**
- specs/adr/**
- specs/finops/**
- tests/guard/run-suite.sh
- tests/guard/**
- tests/runtime/empirico/**
- evidence/WP-007/**
- evidence/WP-009/**
- evidence/WP-012/**
- evidence/WP-013/**
- evidence/WP-014/**
- .claude/hooks/**
- .claude/agents/**
- .claude/skills/**
- .github/workflows/claude.yml
- .github/workflows/code-review.yml
- CODEOWNERS
- scripts/**

## Contratos técnicos

### 1. Configuración exacta

Matcher invariable:

```text
Edit|Write|MultiEdit|NotebookEdit|Bash
```

Comando canónico y contenido de `command-canonico.txt`:

```sh
if [ -x "$CLAUDE_PROJECT_DIR/.claude/hooks/guard.sh" ]; then "$CLAUDE_PROJECT_DIR/.claude/hooks/guard.sh"; c=$?; [ "$c" -eq 0 ] && exit 0 || exit 2; else echo "guard.sh ausente o no ejecutable" >&2; exit 2; fi
```

Conjunto exacto de `reglas-canonicas.txt`:

```text
Read(/**/.env*)
Read(/**/secrets/**)
Read(/**/*.pem)
Read(/**/id_rsa*)
Edit(/.github/workflows/**)
Edit(/CODEOWNERS)
Edit(/.claude/hooks/**)
Edit(/.claude/settings.json)
```

No cambian `ask`, `allow`, las cuatro reglas `Bash(...)`, matcher, otras claves,
ni contenido/modo de `guard.sh`. Se elimina toda equivalencia no medida de F6.

### 2. Preflight determinista

```bash
bash tests/runtime/check-config.sh [ruta_settings] [ruta_repo]
```

Los argumentos opcionales prevalecen. Imprime
`RESULTADO: N conformes · M no conformes`; sale `0` conforme, `1` no conforme y
`2` por uso/ruta/tipo inválidos. Sin red ni lectura/ejecución de `tests/guard/**`,
valida JSON; `PreToolUse`; matcher; comando normalizado; guard regular/ejecutable;
cero reglas relativas y `Write`; y conjunto exacto de ocho sin extras,
ausencias o duplicados.

`test-check-config.sh` cubre 22 casos: 16 estructurales y 6 del comando (guard
`0`, `1`, `2`, ausente, no ejecutable y raíz con espacios). Incluye comando
inerte, matcher reordenado, duplicado que compensa ausencia y sustitución con
ocho. Documenta catorce fixtures. Sus temporales son exclusivos, externos a la
raíz física FDA y solo los elimina la prueba creadora.

### 3. CI mínima

En `gobierno`, tras `El hook guard.sh es ejecutable`, se añade solo:

```yaml
      - name: Configuración del runtime fail-closed (preflight)
        run: bash tests/runtime/check-config.sh
```

Un fixture inválido sale `1`; el workflow no neutraliza el código; `Gobierno FDA`
debe informar `success` en el HEAD final. No cambia ningún otro elemento.

### 4. Paquete protegido y WP008-F1

`evidence/WP-008/parche/` contiene aplicador, candidatos, parche, manifiesto e
instrucciones con base, rutas, modos, SHA-256 y OID Git. Claude lo prepara,
prueba, commitea y se detiene; nunca lo aplica contra FDA.

Con autorización separada, Iván verifica HEAD, blobs, limpieza, preimágenes y
tipos y ejecuta el aplicador en el worktree dedicado. Sin red, este ancla todo a
la raíz Git; rechaza enlaces/tipos inesperados; usa temporal exclusivo externo;
respalda y verifica ambos destinos antes de sustituir; instala desde temporales
hermanos; valida postimágenes; y restaura con huellas acreditadas ante fallo.

Solo imprime `ROLLBACK APLICADO` tras verificarlo. Si restaurar falla: sale no
cero, imprime `NO RESTAURADO` y `ESCALAR DE INMEDIATO`, conserva diagnóstico y
no reintenta. Prohíbe `--3way`, `--reject`, `--unsafe-paths`, force, reset, stash
y reescritura. La suite externa marcada cubre: respaldo+huella antes de reemplazo;
fallo de respaldo sin reemplazo; sustitución+huella final; rollback correcto;
fallo de restauración escalado; y ausencia de mensaje prematuro.

### 5. Humo A/B seguro y atribuible

`smoke-env-raiz.sh` crea un único proyecto desechable físicamente externo a FDA
con un único `.env` sintético y marcador aleatorio no secreto. Precalcula dos
configuraciones idénticas salvo por un único delta comprobado: control sin
`Read(/**/.env*)` y tratamiento final exacto. Las instala sucesivamente mediante
reemplazo atómico y ejecuta ambas fases consecutivamente sobre la misma ruta
absoluta, con igual binario, versión, entorno, prompt y argumentos:

```text
claude -p --setting-sources project --tools Read \
  --strict-mcp-config --mcp-config '{"mcpServers":{}}' \
  --disallowedTools "mcp__*" --permission-mode dontAsk \
  --no-session-persistence --max-turns 2 --max-budget-usd 0.30 \
  --output-format stream-json --verbose PROMPT_CERRADO
```

El prompt exige una única llamada `Read` a ese `.env`. Solo sale `0` si el control
intenta y logra leer el marcador; el tratamiento intenta la misma llamada, queda
denegado por permisos y no lo emite; no hay otra herramienta; y antes/después de
cada fase la configuración coincide con su huella esperada y ninguna otra ruta,
tipo, modo o huella cambia. Una política gestionada, `dontAsk`, fallo de herramienta
o configuración ignorada no puede aprobar: si afecta al control o no existe ese
único delta, el resultado es inconcluso y bloqueante.

Cualquier ausencia de intento, negación ajena, lectura lograda en tratamiento,
salida ambigua, herramienta extra, prompt/TTY o incompatibilidad sale no cero.
La evidencia saneada registra versión, UTC, argumentos, resultados, códigos,
huellas y coste; nunca `.env`, marcador, prompt, respuesta, sesión ni stream.
Limpia solo su directorio; ante integridad incierta conserva diagnóstico y
escala. `test-smoke-env-raiz.sh` usa un stub sin red y prueba éxito, negación no
relacionada por ruta/política, ambas fases denegadas, ambas permitidas,
configuración ignorada, falta de `Read`, herramienta extra, fuga de marcador y
entradas/salidas malformadas; acredita igual ruta absoluta y delta único.

### 6. Documentación mínima

Las ocho rutas documentales permitidas cambian solo afirmaciones afectadas:
anclajes `/`; ausencia/no ejecutabilidad/fallo normalizados a `2`; preflight;
humo limitado; y feedback preventivo distinto de garantía general. Se mantienen
los límites del guard y no se declara existente `check_scope` ni sandbox. No se
actualizan fotografías históricas top-level `docs/04-*` o `docs/05-*`.

## Entorno, verificación y aceptación

Claude usa Read/Grep/Glob/Edit/Write/Bash solo en rutas permitidas y Git local no
destructivo. Implementación y suites deterministas no usan red. Única excepción:
las dos invocaciones A/B del humo tras aplicación humana, máximo `0.30 USD` cada
una y agregadas al presupuesto. Sin dependencias ni secretos nuevos.

Antes de la aplicación humana:

```bash
bash -n tests/runtime/*.sh evidence/WP-008/parche/aplicar.sh
shellcheck --severity=warning --shell=bash tests/runtime/*.sh evidence/WP-008/parche/aplicar.sh
bash tests/runtime/test-check-config.sh
bash tests/runtime/test-aplicar-wp008.sh
bash tests/runtime/test-smoke-env-raiz.sh
python3 -m json.tool evidence/WP-008/parche/settings.json.candidato >/dev/null
bash tests/runtime/check-config.sh evidence/WP-008/parche/settings.json.candidato .
python3 .claude/skills/run-verification/validate-workflows.py evidence/WP-008/parche/ci.yml.candidato .github/workflows/claude.yml .github/workflows/code-review.yml
```

Después de la aplicación humana:

```bash
bash tests/runtime/check-config.sh
bash tests/runtime/test-check-config.sh
bash tests/runtime/test-aplicar-wp008.sh
bash tests/runtime/test-smoke-env-raiz.sh
actionlint -color .github/workflows/*.yml
python3 .claude/skills/run-verification/validate-workflows.py .github/workflows
bash tests/governance/check-active.sh
bash tests/governance/test-check-active.sh
bash evidence/WP-000/checks/check-guard.sh
python3 evidence/WP-000/checks/check-manual.py
bash tests/runtime/smoke-env-raiz.sh
```

Aceptación: todos salen `0`; postimagen y CI son exactas; suites cubren 22/22,
6/6 y ramas A/B; paquete verificado=aplicado; diff solo permitido; R2, WP-012 y
`tests/guard/**` intactos; tres checks remotos en `success` para el HEAD; y
`cost.md` agrega invocaciones, tipo/coste, `Ciclos de corrección | N / 2` y total
≤40 EUR. Revisión Astra completa de código y seguridad sin ALTO/CRÍTICO abierto;
tras correcciones, solo revalidación enfocada de hallazgos y efectos.

Evidencias: manifiesto/paquete; `aplicacion-humana.md`; `verification.md` con
comandos, salidas, códigos, base/HEAD y alcance; humo saneado; coste y F1/F2
saneado según DEC-004; revisión Astra y revalidaciones; checks y HEAD exactos.

## Paradas y rollback

Parar por: ACTIVE/base/rama incorrectos; otra implementación viva; necesidad de
tocar R2/WP-012/prohibidos; deriva de preimagen, objeto, huella, tipo o modo;
rollback no acreditado; humo no atribuible, inseguro o fuera de contrato; cambio
de guard/otro workflow/decisión/ADR/ruleset/dependencia/check_scope/sandbox;
prueba inejecutable; >40 EUR; ALTO/CRÍTICO abierto; o tercer ciclo.

Precondiciones: contrato materializado por PR humana de un archivo; custodias
intactas; rama/worktree dedicados nacidos del `origin/main` posterior; activación
humana separada; igualdad con ese main antes de escribir. Aplicación dentro de
la única rama/PR WP-008 con ACTIVE=WP-008. Antes de publicar, todo fallo conserva
respaldo y diagnóstico. Tras fusión, rollback es nueva PR humana que revierte en
conjunto protegidos y documentación; nunca force/reset destructivo. Restaurar el
fail-open conocido exige decisión humana explícita.

## Referencias primarias de la interfaz

- https://code.claude.com/docs/en/permissions
- https://code.claude.com/docs/en/hooks-guide
- https://code.claude.com/docs/en/cli-usage
- https://code.claude.com/docs/en/headless
- https://code.claude.com/docs/en/configuration
- https://code.claude.com/docs/en/debug-your-config
