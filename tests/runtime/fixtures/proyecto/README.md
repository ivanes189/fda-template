# Fixture de proyecto — plantillas versionadas e inmutables

Estos archivos son **plantillas versionadas e inmutables**. **Ninguna prueba las
modifica jamás**, ni siquiera de forma temporal o reversible.
`tests/runtime/test-protocolo.sh` **copia** lo que necesita a una **raíz de
trabajo externa** a la raíz física del repositorio, y toda la máquina de estados
del parche se ejercita **sobre esa copia**, nunca aquí.

## Mapa de materialización

La copia externa se construye a partir de esta plantilla con esta
correspondencia exacta y determinista:

| Plantilla versionada | Destino en la copia externa | Modo en la copia |
|---|---|---|
| `settings-antes.json` | `.claude/settings.json` | `644` |
| `ci-antes.yml` | `.github/workflows/ci.yml` | `644` |
| `workflow-claude.yml` | `.github/workflows/claude.yml` | `644` |
| `workflow-code-review.yml` | `.github/workflows/code-review.yml` | `644` |
| `guard-trivial.sh` | `.claude/hooks/guard.sh` | **`755`** |

Además, y **solo en la copia**, se crea el marcador `.fda-fixture` como archivo
regular. **La plantilla no lo lleva y no puede llevarlo:** es lo que impide que
`aplicar.sh --root` apunte nunca a este directorio.

**Por qué la plantilla no reproduce la jerarquía real.** Guardar aquí rutas como
`.claude/hooks/**` o `.github/workflows/**` metería el árbol de plantillas en las
mismas rutas que `.claude/settings.json` veda a toda máquina. El mapa anterior
mantiene la fidelidad **donde importa** —la copia externa sí tiene la jerarquía
real, con los mismos bytes y el bit de ejecución correcto— sin crear rutas
ambiguas dentro del repositorio.

**Por qué el bit de ejecución se pone en la copia.** `WP-008` autoriza `chmod`
**solo sobre copias externas de fixture**. La plantilla se versiona con modo
`644` y la copia recibe `755` donde el contrato lo exige.

## Invariante de las dos líneas base

`settings-antes.json` y `ci-antes.yml` son **copias byte a byte** de
`.claude/settings.json` y `.github/workflows/ci.yml` en su estado **ANTES**, y
sus SHA-256 son exactamente `SETTINGS_ANTES` y `CI_ANTES` de
`evidence/WP-008/parche/huellas.sha256`. Es lo que permite que la copia externa
arranque en **S0**.

Si alguna vez cambiara el estado **ANTES** de cualquiera de los dos archivos
reales, habría que actualizar **a la vez** estas dos plantillas y las cuatro
huellas del parche. No es deuda: es el acoplamiento propio de un protocolo que
se verifica por huella.
