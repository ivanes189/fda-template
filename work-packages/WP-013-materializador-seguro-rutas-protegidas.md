# WP-013 — Materializador seguro de rutas protegidas

estado: ready
prioridad: P0
riesgo: T3
agente_responsable: implementer     agente_revisor: code-reviewer
requisitos: [SEC-001]               adr: [ADR-001]
decision: [DEC-008]
presupuesto_max_eur: 20             max_ciclos_correccion: 2

## Objetivo y contexto

Existe una herramienta de operador pequena y reutilizable que, sin red, valida
y aplica un parche exacto sobre una lista cerrada de archivos protegidos
regulares ya existentes. Una ejecucion correcta verifica la postimagen y deja
un recibo apto para rollback. Ante un fallo, la herramienta restaura y verifica
la preimagen o declara de forma inequivoca el estado incompleto que requiere
recuperacion humana; nunca informa exito sin comprobacion final.

DEC-008 separa esta herramienta de los diez pins de acciones. WP-013 no contiene
SHA de acciones ni modifica workflows. WP-014 no puede aplicar sus cambios hasta
que WP-013 este fusionado y sin hallazgos ALTOS o CRITICOS abiertos.

## Alcance (incluido / fuera de alcance)

**Incluido:**
- CLI en Python con biblioteca estandar y uso local aislado de `git apply`;
- parche unificado y manifiesto JSON v1 con destinos, modos y huellas exactos;
- preflight completo, scratch, staging, backups, sustitucion, recibo y rollback;
- pruebas unitarias y adversariales deterministas, sin red y sobre arboles
  sinteticos desechables;
- documentacion de uso, frontera de seguridad, recuperacion y evidencias.

**Fuera de alcance:**
- modificar workflows o fijar acciones por SHA;
- leer, copiar, ejecutar o incorporar la candidata historica WP-009;
- crear, borrar o renombrar destinos, cambiar sus modos o admitir binarios;
- hooks, CI, `ACTIVE`, contratos, decisiones, requisitos, WP-008/R2 o WP-014;
- red, remotos Git, secretos, dependencias nuevas o sandbox del sistema operativo.

## Archivos permitidos

- scripts/materialize-protected.py
- tests/materializer/**
- docs/manual/02-ciclo-de-un-wp.md
- evidence/WP-013/**

## Archivos prohibidos

- .github/workflows/**
- work-packages/**
- specs/**
- .claude/**
- CODEOWNERS
- tests/guard/run-suite.sh

## Contratos tecnicos (interfaces, schemas, eventos, invariantes)

La interfaz publica es:

```text
python3 scripts/materialize-protected.py apply --wp-id WP-NNN --repo ROOT \
  --patch PATCH --manifest MANIFEST --state-parent DIR
python3 scripts/materialize-protected.py rollback --wp-id WP-NNN --repo ROOT \
  --receipt RECEIPT
```

El WP-ID es obligatorio, se registra en el recibo y debe coincidir al hacer
rollback. No se deduce de `ACTIVE`; la herramienta nunca modifica `ACTIVE`.

El manifiesto JSON v1 contiene una lista no vacia y sin destinos duplicados de
objetos `{path, pre_sha256, post_sha256, mode}`. `mode` es una cadena de cuatro
digitos octales que representa solo bits de permiso; se rechazan bits
especiales. Las huellas son cadenas minusculas de 64 caracteres `[0-9a-f]`.
Se rechazan versiones desconocidas, claves JSON duplicadas, claves o campos
desconocidos, campos ausentes y tipos incorrectos.

Cada `path` es una ruta POSIX relativa canonica y literal. Se rechazan rutas
absolutas o vacias, NUL, barra inversa, globs, componentes vacios, `.` o `..`,
destinos repetidos y toda discrepancia entre manifiesto y parche. La raiz, los
componentes, los inputs, el estado y los destinos deben ser directorios o
archivos regulares segun corresponda. Se rechazan symlinks, hardlinks y
cualquier tipo inesperado.

La raiz y cada directorio se abren una vez; las lecturas, temporales, backups y
renames se hacen relativos a descriptores mediante `dir_fd` y `O_NOFOLLOW`.
Scratch, estado y temporales se crean de forma impredecible, exclusiva y
privada, nunca a partir del PID. Los archivos se sincronizan antes del rename y
los directorios se sincronizan despues cuando la plataforma lo permita; una
imposibilidad relevante termina de forma cerrada.

Antes de la primera sustitucion de un destino se validan completamente
manifiesto, parche, preimagenes, postimagenes y backups. `git apply` solo actua
en un scratch exclusivo, con configuracion aislada, sin hooks, atributos
externos, credenciales ni red. Se rechazan rutas extra, binarios, altas, bajas,
renames, cambios de modo y cambios de tipo.

Las escrituras auxiliares se limitan al estado privado creado exclusivamente
bajo `--state-parent` y a temporales exclusivos en los directorios de destino.
Ninguna entrada preexistente ajena al manifiesto puede modificarse o eliminarse.
Tras cada sustitucion se verifica la postimagen. Cualquier fallo tras iniciar el
commit intenta restaurar todo lo tocado desde backups ya validados y comprueba
la preimagen.

El recibo v1 identifica transaccion, WP, resultado y, por destino, ruta
relativa, modo, huellas esperadas, estado observado (`preimagen`, `postimagen` o
`desconocido`) y referencia relativa a su backup dentro del estado privado.
Antes de restaurar se validan recibo, backups y destinos con las mismas reglas
de rutas, tipos, enlaces, modos y huellas. Nunca se usa un dato del recibo sin
validarlo para escribir.

El rollback explicito ordinario exige que una aplicacion terminada conserve
intactas sus postimagenes. Si un rollback queda incompleto, se preserva el
estado, se identifican las rutas no restauradas, se termina distinto de cero y
se emite `ESCALAR DE INMEDIATO`; no se promete que repetir el rollback ordinario
lo recupere. Si no puede crearse el estado privado, se termina distinto de cero
sin tocar destinos y se emite diagnostico estructurado por `stderr`; no se exige
un recibo persistido imposible.

**Modelo de concurrencia:** el operador mantiene control exclusivo sobre la
raiz, los ancestros de los destinos y el estado durante toda la ejecucion. No se
cubren procesos privilegiados ni procesos capaces de mover esos directorios o
cambiar sus permisos mientras opera. Las pruebas adversariales afectan a
entradas y destinos dentro de esa envolvente estable. Ni `dir_fd` ni WP-013 se
presentan como el sandbox futuro del sistema operativo.

## Entorno autorizado (herramientas, comandos, red, secretos)

- Herramientas: Read, Grep, Glob, Write/Edit solo en archivos permitidos; Bash.
- Comandos: `python3`, `git` local, `bash`, `shasum`, `diff`, `grep`, `sed`.
- Red: NINGUNA; tampoco resolucion de remotos Git.
- Secretos: NINGUNO; no leer credenciales, configuraciones personales ni
  valores de secretos.
- Plataformas de prueba: macOS local y Linux de CI, sin interaccion ni TTY.

## Verificacion (comandos de validacion + criterios de aceptacion medibles)

**Comandos headless:**

```bash
set -eu
WP013_HEAD="$(git rev-parse --verify HEAD^{commit})"
WP013_BASE="$(git merge-base origin/main "$WP013_HEAD")"

git diff --check "$WP013_BASE" "$WP013_HEAD"
bash tests/materializer/run-suite.sh
python3 scripts/materialize-protected.py --help
bash tests/governance/check-active.sh

git diff --exit-code --no-renames "$WP013_BASE" "$WP013_HEAD" -- . \
  ':(top,exclude,literal)scripts/materialize-protected.py' \
  ':(top,exclude,glob)tests/materializer/**' \
  ':(top,exclude,literal)docs/manual/02-ciclo-de-un-wp.md' \
  ':(top,exclude,glob)evidence/WP-013/**'

git diff --exit-code "$WP013_BASE" "$WP013_HEAD" -- .github/workflows
```

`tests/materializer/run-suite.sh` preserva el codigo de salida de `unittest` y
falla si descubre cero pruebas. `check-active.sh` debe devolver codigo 0 y
primera linea `ACTIVO: WP-013`. La evidencia identifica `WP013_BASE` y
`WP013_HEAD` completos y corresponde al candidato revisado.

**Criterios de aceptacion:**
- [ ] Todos los comandos terminan en 0 y la suite ejecuta al menos una prueba.
- [ ] Las pruebas deterministas no usan red ni destinos del repositorio real.
- [ ] Exito con uno y varios destinos verifica postimagenes, modos y recibo.
- [ ] Se rechazan rutas mal formadas o extra, symlinks, hardlinks, tipos
      inesperados, temporales precreados, parches binarios, altas, bajas,
      renames, cambios de modo y huellas o modos incorrectos.
- [ ] Se prueban sustituciones adversariales de entradas dentro del modelo de
      concurrencia, fallo antes de escribir y fallo tras cada reemplazo.
- [ ] Rollback automatico y explicito restauran y verifican; drift y fallo de
      rollback terminan no-cero, conservan estado y no afirman exito.
- [ ] Cada fallo comprueba codigo, diagnostico o recibo cuando puede existir,
      huellas y fronteras de escrituras auxiliares y de destinos.
- [ ] El diff se limita a los cuatro patrones permitidos; workflows y candidata
      WP-009 permanecen sin intervencion. La preservacion fisica de la candidata
      se acredita separadamente contra su manifiesto, no mediante este diff.
- [ ] El manual declara precondiciones, uso exclusivamente humano en WPs
      posteriores, recuperacion y limites sin presentar la herramienta como
      sandbox ni autorizacion suficiente.
- [ ] Revision completa de codigo sin bloqueantes y revision de seguridad sin
      hallazgos ALTOS o CRITICOS abiertos.
- [ ] Coste conforme a DEC-004 y menor o igual que 20 EUR.

## Evidencias exigidas (que debe aparecer en evidence/WP-013/)

- [ ] Salida integra y codigo de cada comando, con base y HEAD completos.
- [ ] Matriz caso -> resultado -> huellas -> escrituras observadas.
- [ ] Recibos saneados de exito, rollback y fallo recuperable/no recuperable.
- [ ] Diff completo y comprobacion de alcance contra la base de la PR.
- [ ] `cost.md` conforme a DEC-004.
- [ ] Revision completa de codigo y revision de seguridad independientes.

## Condiciones de parada especificas

- Se necesita tocar una ruta no permitida o ampliar formatos o alcance.
- La implementacion requiere un sandbox, una decision o un cambio de ADR.
- Una prueba no puede ejecutarse de forma headless en macOS o Linux.
- Aparece una vulnerabilidad o un hallazgo ALTO o CRITICO.
- El coste supera 20 EUR o se alcanzaria un tercer ciclo de correccion.
- El modelo de concurrencia aprobado resulta insuficiente para el uso real.

## Migracion / rollback

No hay datos ni migracion. WP-013 solo crea la herramienta, pruebas, manual y
evidencias; no se aplica sobre rutas protegidas reales durante este WP. Su uso
en WP-014 sera una aplicacion humana autorizada por separado. Ante fallo de uso,
se restaura y verifica mediante el recibo; un estado incompleto se escala de
inmediato con backups y diagnostico preservados. Tras fusion, rollback de
WP-013 = revertir su PR completa.
