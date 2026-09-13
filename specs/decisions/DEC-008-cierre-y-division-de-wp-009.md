# DEC-008 — Cierre bloqueado y división de WP-009

**Estado:** aceptada · **Fecha:** 2026-09-13 · **Ámbito:** cierres bloqueados de WP-009 y WP-013, transiciones de `ACTIVE` a reposo y ruta limitada hacia los diez pins de WP-014
**Origen:** parada obligatoria tras C2 (`2 / 2`), revisión de código NO APTA, revisión de seguridad con un hallazgo ALTO y decisiones humanas D13 y D14 ratificadas el 2026-09-13.

**Enmienda de recuperación — 2026-09-13.** WP-013 agotó C1, C2 y el C3
excepcional con veredicto final **NO APTO** y un hallazgo ALTO abierto. Se cierra
`blocked`, su candidata queda fuera del cierre como material histórico no
conforme y `ACTIVE` vuelve a reposo. Esta enmienda preserva como historia la
división original, pero sustituye su dependencia de un materializador general,
la secuencia vigente, el criterio de salida y la composición atómica.

## Problema

WP-009 debía fijar diez referencias `uses:` por SHA. Su contrato reunió además el diseño de un materializador de rutas protegidas, la acreditación remota de procedencia, herramientas provisionales de coste/BCE, documentación y un expediente amplio. Tras los dos ciclos permitidos, el candidato seguía sin cumplir:

1. **ALTO:** el materializador usa un temporal predecible que puede seguir un enlace y escribir fuera de las tres rutas protegidas;
2. clasificación completa de capturas F1;
3. comparación de tasas antes del redondeo;
4. separación entre pruebas unitarias y red real;
5. expediente final íntegro contra un HEAD identificado.

El coste quedó dentro de presupuesto (`45.6189187 USD = 39.3606 EUR`, frente a 43 EUR), pero eso no subsana el hallazgo ALTO ni habilita un tercer ciclo.

## Decisión

### 1. WP-009 se cierra bloqueado, no entregado

- `estado: blocked`, nunca `done`.
- Contador histórico final: `2 / 2`; no existe C3 ni un R2 de WP-009.
- `ACTIVE` pasa de `WP-009` a reposo en este mismo diff.
- Los workflows conservan sus referencias móviles actuales.
- El aplicador `evidence/WP-009/parche/APLICAR-ACCIONES-SHA.sh` no se ejecuta ni se versiona.
- La rama y el worktree candidatos quedan preservados fuera de esta PR como **CANDIDATA HISTÓRICA NO CONFORME — NO EJECUTAR**.

El cierre registra coste, manifiesto y dictámenes suficientes para que el estado no dependa de la conversación. No presenta la implementación fallida como guía operativa.

### 2. División inicial del trabajo — historia enmendada

**WP-013 — materializador seguro de rutas protegidas.** Resultado: una herramienta de operador pequeña y reutilizable, sin red, con creación exclusiva de temporales, operaciones ancladas al directorio, rechazo de enlaces/tipos inesperados y recuperación verificable. No contiene SHA de acciones ni modifica workflows. Riesgo T3; presupuesto candidato 20 EUR; máximo dos ciclos; revisión completa de código y seguridad.

**WP-014 — diez referencias fijadas por SHA.** Resultado: exactamente las diez sustituciones de REQ-FDA-002, aplicadas por una persona, más trazabilidad y evidencia propias. No diseña materializadores ni herramientas FinOps. Riesgo T3; presupuesto candidato 12 EUR; máximo dos ciclos; revisión completa de código y seguridad.

WP-010, WP-011 y WP-012 conservan los significados e historia que ya les asigna la hoja de ruta. Esta decisión admite los identificadores WP-013 y WP-014, pero no crea sus contratos, no los activa y no autoriza ejecutarlos.

La división no renombra una corrección. Cada sucesor tendrá contrato, rama, coste, evidencia y resultado propios, partirá del `main` remoto del momento y no incorporará en bloque la candidata WP-009.

**Resultado de recuperación vigente.** WP-013 no produjo una herramienta
admisible y queda cerrado `blocked`. WP-014 conserva únicamente su identificador
reservado: no se crea ni activa con esta enmienda. Su eventual contrato debe
limitarse a los diez pins exactos y a preparar los mismos bytes de parche para
`git apply --check --index -` y `git apply --index -`, suministrados por `stdin`.
Una persona aplicará esos bytes en un worktree limpio y dedicado y verificará el
diff exacto antes de continuar. Git y el worktree no se describen como sandbox
ni como transacción general. La recuperación ordinaria se limita a descartar y
recrear ese worktree dedicado; fallos del repositorio compartido o del
almacenamiento exigen parada y escalado.

### 3. Secuencia que sustituye a DEC-007

Esta decisión enmienda por declaración únicamente los pasos 5 y 6 de `DEC-007` § «Secuencia de ejecución posterior al punto de control». El archivo histórico de DEC-007 permanece intacto.

Los pasos antiguos:

> 5. implementar, verificar, revisar y fusionar WP-009;
> 6. WP-009 → reposo.

se sustituyen por:

1. **O/T** — esta PR de operador registra el bloqueo de WP-009 y escribe reposo en `ACTIVE` en el mismo diff;
2. **O/T** — contrato y activación de WP-013, ya ejecutados históricamente como
   actos separados; tras C3 y la revisión enfocada, esta composición registra
   su bloqueo y escribe reposo en `ACTIVE` en el mismo diff;
3. **O** — futuro contrato breve de WP-014, limitado a los diez pins y al
   procedimiento Git exacto, preparado, revisado y materializado por el
   operador;
4. **T** — reposo → WP-014;
5. **W/O** — el agente prepara el parche exacto; una persona comprueba y aplica
   mediante Git nativo los mismos bytes recibidos por `stdin` en un worktree
   limpio y dedicado; se verifica el diff exacto, se revisa y se fusiona WP-014;
6. **T** — WP-014 → reposo;
7. se continúa en el antiguo paso 7 de DEC-007, contrato breve de WP-008.

DEC-007 decía que `O/T` se usaba exactamente una vez, en su paso 19. Las dos
enmiendas de esta decisión sustituyen esa cardinalidad: `O/T` se usa tres veces,
en los cierres bloqueados de WP-009 y WP-013 y en el cierre de WP-005. Su
definición y sus invariantes no cambian.

Un WP activo cada vez. Contrato, activación, aplicación protegida, fusión y vuelta a reposo conservan sus autorizaciones humanas separadas.

### 4. Criterio de salida corregido

La segunda condición de `DEC-003` §6 y sus reproducciones en la hoja de ruta y el manual ya no puede exigir «WP-009 fusionado», porque WP-009 queda bloqueado de forma permanente. Se sustituye por:

> **Acciones fijadas por SHA.** WP-014 fusionado; el criterio de verificación
> n.º 2 de REQ-FDA-002 devuelve vacío; el diff contiene exactamente los diez
> pins autorizados y el procedimiento Git exacto aplicado humanamente no tiene
> hallazgos ALTOS o CRÍTICOS abiertos.

Las condiciones de WP-008 y del control de alcance/sandbox permanecen intactas.

## Composición atómica de esta PR

Para el cierre de recuperación de WP-013, `DEC-003` admite directamente esta
decisión y el conjunto cerrado de **doce archivos**:

1. `specs/decisions/DEC-008-cierre-y-division-de-wp-009.md`
2. `specs/decisions/DEC-003-pausa-migracion-y-contencion.md`
3. `docs/03-hoja-de-ruta.md`
4. `docs/manual/05-bloqueos-y-parada.md`
5. `work-packages/WP-013-materializador-seguro-rutas-protegidas.md`
6. `work-packages/ACTIVE`
7. `evidence/WP-013/CIERRE-BLOQUEADO.md`
8. `evidence/WP-013/MANIFIESTO-CANDIDATA-C3.md`
9. `evidence/WP-013/cost.md`
10. `evidence/WP-013/coste-f1.md`
11. `evidence/WP-013/revision-astra.md`
12. `evidence/WP-013/revision-astra-enfocada-c3.md`

Todos viajan juntos o ninguno. La candidata de implementación no forma parte de
ellos. DEC-008 no se autoautoriza: la modificación directa de `DEC-003` §4
viaja en el mismo diff.

## Coste del intento cerrado

La suma de los siete `total_cost_usd` es defendible, pero la primera captura no aporta modelos ni tokens. Conforme a DEC-004 §§3, 8 y 12, el registro se clasifica `estimado`, conserva la cifra y declara causa y base reconstruible. El tipo mensual 2026-09 se añade append-only a `specs/finops/fx-rates.md` en esta PR.

## Consecuencias y límites

**A favor:** la fuente de verdad refleja ambos bloqueos; se elimina una
dependencia imposible y el cambio futuro queda reducido a diez sustituciones
exactas aplicadas por una persona.

**Coste aceptado:** WP-013 no se entrega y su coste hundido queda registrado; el
procedimiento futuro renuncia a una herramienta general reutilizable.

**No autorizado por esta decisión:** fusionar esta PR sin acto posterior; crear
o activar WP-014; ejecutar WPs; aplicar pins; importar, modificar o eliminar las
candidatas WP-009 o WP-013; cambiar WP-008/R2; eliminar ramas o worktrees.

## Verificación

- `git diff --check`
- `bash tests/governance/check-active.sh` → `REPOSO: no hay WP activo.` y salida 0
- diff limitado a los doce archivos de la composición
- `WP-013` declara `blocked`, no `done`
- ningún archivo de implementación candidato ni workflow forma parte del diff
- el coste contiene `estado_coste: estimado`, tipo `1.1590`, presupuesto `20` y
  coste final `16.6085 EUR`
