# WP-014 — Cierre `done`

## Identidad del resultado

```text
wp_id: WP-014
estado_final: done
fecha_cierre: 2026-09-13
base_pr: 1feb66554c8754e586a1089822e1ab5a6edae900
head_pr_revisado: d1ae1b86fbe3114cf583ddc9ff73c90d758ad526
pr: https://github.com/ivanes189/fda-template/pull/40
merged_at_utc: 2026-09-13T21:00:03Z
merge_commit: ea004919b661baf206257952f2fd5ca7bfad2c05
base_candidato_cierre: ea004919b661baf206257952f2fd5ca7bfad2c05
ciclos_correccion: 1 / 2
coste_usd: 3.1601409
tipo_eurusd: 1.1590
coste_eur: 2.73
presupuesto_eur: 12
```

El cierre se materializa como diff de operador sobre `base_candidato_cierre`.
No se crea un commit por anticipado para resolver una identidad
autorreferencial: el `HEAD` exacto del cierre lo fijará la PR humana posterior.
Hasta entonces, su identidad comprobable es esa base más la composición cerrada
de siete rutas enumerada en DEC-003 §4.

## Resultado entregado

- Los tres workflows contienen exactamente diez referencias de terceros fijadas
  por SHA completo, con distribución `5 checkout / 2 setup-python / 1 gitleaks /
  2 claude-code-action` y comentario de versión legible.
- El criterio n.º 2 de REQ-FDA-002 devuelve vacío.
- El diff de implementación cambió únicamente esas diez líneas `uses:` en los
  workflows; tipos `blob`, modos `100644`, lógica, permisos, eventos, argumentos
  y secretos permanecieron invariantes.
- Iván comprobó y aplicó personalmente mediante `stdin` los mismos bytes del
  `PATCH_BLOB` registrado. Ningún agente ejecutó las órdenes protegidas.
- WP-014 termina `done`; el cambio contractual y la vuelta de `ACTIVE` a reposo
  forman parte del mismo diff de operador.

Los diez criterios de aceptación y los ocho grupos de evidencia marcados en el
contrato describen la implementación identificada por `base_pr` y
`head_pr_revisado`. No presentan el diff posterior de cierre como si fuera la
implementación del WP ni exigen que `ACTIVE` siga activo después de cerrarlo.

## Comprobaciones remotas posteriores a la PR

Consulta de solo lectura practicada el `2026-09-13T21:12:56Z` mediante:

```text
gh pr view 40 --repo ivanes189/fda-template --json number,state,mergedAt,mergeCommit,headRefOid,baseRefOid,url,title,reviewDecision,statusCheckRollup
```

Resultado relevante:

| Check | Estado / conclusión | Ejecución |
|---|---|---|
| Gobierno FDA | `COMPLETED / SUCCESS` | https://github.com/ivanes189/fda-template/actions/runs/34782297269/job/103791389968 |
| Lint · Shell · Tests · Manual | `COMPLETED / SUCCESS` | https://github.com/ivanes189/fda-template/actions/runs/34782297269/job/103791389816 |
| Escaneo de secretos | `COMPLETED / SUCCESS` | https://github.com/ivanes189/fda-template/actions/runs/34782297269/job/103791389931 |

La misma consulta devolvió `state: MERGED`, los identificadores de base, HEAD y
merge de la cabecera y el instante de fusión indicado. El cuerpo de la PR
registra el HEAD vigente, el check remoto de secretos y la confirmación de
revisión humana. La PR fue creada y fusionada por una cuenta no bot.

Iván autorizó expresamente la fusión, confirmó su revisión y ejecutó la fusión
humanamente. La API devuelve `reviews: []`: por tanto este expediente **no**
afirma que exista una aprobación formal registrada como GitHub Review. Registra
la revisión humana confirmada por el operador, que es una práctica vigente y no
un control impuesto por el ruleset actual.

## Aplicación protegida y corrección de portabilidad

El primer intento humano se detuvo antes de cualquier variante de `git apply`:
`zsh` interpretó `$PATCH_COMMIT:evidence/...` mediante el modificador `:e` y
produjo una ruta inválida. Todas las órdenes anteriores eran de lectura; no hubo
estado que revertir.

La ejecución posterior delimitó las variables como
`${PATCH_COMMIT}:evidence/...` y `${PRE_APPLY_HEAD}:evidence/...`, conservó las
tres identidades registradas y terminó correctamente. Este cierre corrige esas
dos líneas del contrato para que el procedimiento documentado coincida con la
forma segura ya ejecutada. La preimagen histórica permanece identificada por el
merge commit de implementación y el diagnóstico completo sigue en
`aplicacion-humana.md`.

No fue necesario descartar ni recrear el worktree. Esa recuperación permanece
como regla contingente; no se presenta como operación ejecutada.

## Revisión independiente y corrección

La revisión completa de implementación se realizó con GPT-6 Astra, razonamiento
Alto, contexto nuevo y solo lectura. Encontró F1–F3 en la evidencia, sin cambios
funcionales requeridos ni hallazgos ALTOS o CRÍTICOS. Claude Code corrigió F2 y
F3 en C1; el operador atestó F1 y Codex agregó el coste. La revalidación Astra
enfocada declaró C1 `APTO`; no se abrió C2.

Antes de materializar este cierre, una segunda revisión completa de la
transición —GPT-6 Astra, Alto, contexto nuevo y solo lectura— comprobó la
fusión, las diez postimágenes, el parche, costes, checks y composición. Emitió
`APTO` sin bloqueantes ni hallazgos ALTOS o CRÍTICOS abiertos en el entregable y
procedimiento aplicado de WP-014. Solicitó dos precisiones MENORES:

1. no presentar la recuperación contingente del worktree como ejecutada;
2. acotar la ausencia de hallazgos a WP-014.

Ambas se incorporaron al candidato externo. La revalidación enfocada posterior
las declaró `CORREGIDAS`, sin efectos adversos bloqueantes y sin repetir la
auditoría general.

## Coste y ciclos

El registro humano agregado acredita dos invocaciones F1:

```text
2.5364507 USD + 0.6236902 USD = 3.1601409 USD
3.1601409 / 1.1590 = 2.726609922... EUR -> 2.73 EUR
```

El consumo es el 23 % del presupuesto máximo de 12 EUR. El contador final es
`1 / 2`; no existe C2.

## Verificación del candidato de cierre

La validación se ejecuta sobre el diff de operador basado en
`ea004919b661baf206257952f2fd5ca7bfad2c05`, sin ejecutar ninguna variante de
`git apply`. Debe registrar:

- composición exacta de siete rutas;
- `git diff --check` en cero;
- `check-active.sh` en reposo y código cero;
- validadores de workflows y manual en cero;
- cero diff de workflows respecto de la base del cierre;
- exactamente dieciocho casillas `[x]` en el contrato;
- condición segunda de DEC-003 marcada y primera/tercera pendientes;
- criterio literal de REQ-FDA-002 vacío y recuentos `5/2/1/2`.

Resultado materializado y revalidado el `2026-09-13T21:18:33Z`:

```text
COMPOSICION=7 rutas exactas
DIFF_CHECK=0
ACTIVE=REPOSO
ACTIVE_EXIT=0
WORKFLOWS=3 analizados; 0 errores; 0 avisos
ACTIONLINT=0
MANUAL=60 enlaces; 0 fallos
GUARD=68 correctas; 0 fallidas; 10 huecos conocidos
GOBIERNO_ACTIVE=10 correctas; 0 fallidas
WORKFLOW_DIFF=0 rutas
WP_ESTADO=done
CASILLAS_WP014=18
DEC003_CONDICIONES=pendiente/cumplida/pendiente
REQ_FDA_002=vacío
PINS=5/2/1/2
CIERRE_VALIDACION_EXIT=0
```

Las siete rutas comprobadas fueron exactamente:

```text
docs/03-hoja-de-ruta.md
docs/manual/05-bloqueos-y-parada.md
evidence/WP-014/CIERRE.md
specs/decisions/DEC-003-pausa-migracion-y-contencion.md
specs/requirements/REQ-FDA-002-workflows-endurecidos.md
work-packages/ACTIVE
work-packages/WP-014-diez-pins-acciones-sha.md
```

La comprobación no ejecutó ninguna variante de `git apply`. El candidato sigue
sin commit ni PR: esas materializaciones requieren sus actos humanos separados.

## Límites

Este cierre no modifica workflows, DEC-008, ruleset, permisos, `CODEOWNERS`,
ramas, worktrees ni candidatas WP-009/WP-013. No crea, corrige, activa ni ejecuta
WP-008 u otro WP. La segunda condición de salida de DEC-003 queda satisfecha;
la pausa sigue vigente porque las condiciones primera y tercera permanecen
pendientes.
