# Evidencia — Verificaciones locales y árbol limpio

**Fecha:** 2026-07-23T14:57:04Z · **Commit:** 2fa0f3b · **Rama:** wp/WP-000-fase1-prep

## Las cinco verificaciones

```
bash evidence/WP-000/checks/check-structure.sh                           exit=0  OK
python3 evidence/WP-000/checks/check-agents-skills.py                    exit=0  OK
bash tests/guard/run-suite.sh                                            exit=0  OK
python3 .claude/skills/run-verification/validate-workflows.py .github/workflows exit=0  OK
python3 evidence/WP-000/checks/check-manual.py                           exit=0  OK
```

## Linters del sandbox (comandos de validación instanciados)

```
actionlint                               exit=0  OK
shellcheck --severity=warning            exit=2  FALLO

Archivos analizados por shellcheck:
  .claude/hooks/guard.sh
  evidence/WP-000/checks/check-guard.sh
  evidence/WP-000/checks/check-structure.sh
  tests/guard/run-suite.sh
```

## Árbol de trabajo

```
$ git status --short
?? evidence/WP-000/fase1-prep/
(sin salida = árbol limpio)

$ git log --oneline -5
2fa0f3b WP-000: entrecomillar expresiones de git en el script de anonimización
52db2bd WP-000: añadir script de anonimización de autoría previo a publicar
e9408ed WP-000: corregir SC1087 en guard.sh
6d1c748 WP-000: corregir comentarios que shellcheck interpretaba como directivas
7208101 WP-000: limpiar SC2045, retirar candidato del guard y preparar arreglo SC1087

commits totales: 35
archivos versionados: 73
```
