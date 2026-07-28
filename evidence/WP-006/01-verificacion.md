# Evidencia WP-006 — Verificación completa

**Fecha:** 2026-07-23T16:48:44Z · **Commit:** b3c501c · **Rama:** wp/WP-006-reposo-y-validacion-gobierno

## Los 8 comandos de validación del WP

```
bash tests/governance/test-check-active.sh                             exit=0  OK
bash tests/guard/run-suite.sh                                          exit=0  OK
bash evidence/WP-000/checks/check-structure.sh                         exit=0  OK
python3 evidence/WP-000/checks/check-agents-skills.py                  exit=0  OK
python3 .claude/skills/run-verification/validate-workflows.py .github/workflows exit=0  OK
python3 evidence/WP-000/checks/check-manual.py                         exit=0  OK
actionlint                                                             exit=0  OK
shellcheck --severity=warning (todos los .sh)                          exit=0  OK
```

## Los cuatro estados de ACTIVE (salida de las pruebas)

`bash tests/governance/test-check-active.sh`

```
==============================================================
 Validación del estado operativo — check-active.sh
 0=REPOSO o ACTIVO · 1=ERROR de coherencia · 2=ERROR sin archivo
==============================================================

--- Los cuatro estados ---
  OK    exit=0  marca=REPOSO   ACTIVE vacío (solo comentarios) → reposo
  OK    exit=0  marca=REPOSO   ACTIVE con archivo totalmente vacío → reposo
  OK    exit=0  marca=ACTIVO   ACTIVE con WP existente y con alcance → activo
  OK    exit=1  marca=ERROR    ACTIVE apunta a WP inexistente → error
  OK    exit=2  marca=ERROR    no existe el archivo ACTIVE → error

--- Coherencia adicional ---
  OK    exit=1  marca=ERROR    identificador mal formado (WP-7) → error
  OK    exit=1  marca=ERROR    identificador mal formado (basura) → error
  OK    exit=1  marca=ERROR    WP existente pero SIN rutas permitidas → error

--- Los mensajes son distinguibles entre sí ---
  OK    los 4 mensajes de primera línea son distintos
        reposo     : REPOSO: no hay WP activo.
        activo     : ACTIVO: WP-042
        inexistente: ERROR: ACTIVE apunta a 'WP-999' pero no existe work-packages/WP-999*.md
        sin archivo: ERROR: no existe work-packages/ACTIVE

--- INVARIANTE: el reposo sigue siendo fail-closed para escrituras ---
    (que el CI acepte ACTIVE vacío no relaja el guard)
  OK    exit=2  el guard DENIEGA una escritura con ACTIVE vacío

==============================================================
 RESULTADO: 10 correctas, 0 fallidas
==============================================================
=== EXIT: 0 ===
```

## El reposo sigue siendo fail-closed (grupo K de la suite del guard)

```
--- K. REPOSO: ACTIVE vacío (estado normal entre dos WPs) ---
    Debe seguir siendo fail-closed para escrituras REALES, sin bloquear
    comandos de diagnóstico cuyos únicos destinos son exentos.
  OK    exit=2  Write a docs/ (fail-closed intacto)
  OK    exit=2  Write a cualquier ruta
  OK    exit=2  Bash: echo > src/y.py
  OK    exit=2  Bash: cp hacia el repo
  OK    exit=0  Bash: 2>/dev/null (solo diagnóstico)
  OK    exit=0  Bash: >/dev/null y stderr
  OK    exit=0  Bash: escritura en /tmp
  OK    exit=0  Bash: sin destinos (pytest)
  OK    exit=0  Bash: mezcla exento + sin destino
  OK    exit=2  Bash: mezcla exento + destino real

```

## Suite del guard completa

```
  OK    exit=2  Bash: mezcla exento + destino real

==============================================================
 RESULTADO: 68 correctas · 0 fallidas · 9 huecos conocidos · 0 huecos cerrados
==============================================================
```
