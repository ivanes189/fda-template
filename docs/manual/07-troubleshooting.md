[← Manual](MANUAL.md)

# 07 — Troubleshooting

Diagnóstico de los fallos habituales. El patrón: **reproduce el fallo con un comando antes de cambiar nada.**

---

## El hook bloquea de más

### Síntoma: bloquea una ruta que debería estar permitida

```bash
# 1. Reproduce con traza
echo '{"tool_name":"Write","tool_input":{"file_path":"src/pagos/schemas.py"}}' \
  | FDA_GUARD_DEBUG=1 .claude/hooks/guard.sh; echo "exit=$?"

# 2. Mira qué patrones lee realmente del WP
grep -A 20 '^## Archivos permitidos' work-packages/WP-014-*.md
```

| Causa | Cómo se reconoce | Arreglo |
|---|---|---|
| El patrón no cubre la ruta | `docs/*` no cubre `docs/a/b.md` | Usa `**`: `*` no cruza `/`, `**` sí |
| El WP activo no es el que crees | `guard: wp_id=` muestra otro | `cat work-packages/ACTIVE` |
| El item no se parsea | No aparece en la lista del mensaje | Debe ser `- ruta` (guion + espacio) bajo `## Archivos permitidos` |
| Prohibido gana a permitido | El mensaje dice «explícitamente PROHIBIDA» | Revisa `## Archivos prohibidos`: tiene precedencia |

### Síntoma: bloquea absolutamente todo

Es **fail-closed** haciendo su trabajo. Causas, en orden de frecuencia:

```bash
cat work-packages/ACTIVE                      # ¿vacío o ausente?
ls work-packages/WP-*.md                      # ¿existe el archivo del WP?
grep -c '^-' work-packages/WP-014-*.md        # ¿tiene rutas permitidas?
```

Sin WP activo no hay cambios. Es intencionado: un guard que ante la duda deja pasar no es un guard.

### Síntoma: no bloquea nada

```bash
test -x .claude/hooks/guard.sh && echo "ejecutable" || echo "FALTA chmod +x"
python3 -c "import json;print(json.load(open('.claude/settings.json'))['hooks'])"
```

Causas: falta `chmod +x`; `settings.json` con JSON inválido (se ignora entero, en silencio); o la sesión se abrió antes de crear el hook — **reinicia `claude`**, los hooks se cargan al arrancar.

### Escrituras vía `Bash`: cubiertas, pero no herméticas

El matcher de `.claude/settings.json` **incluye `Bash`**, y `guard.sh` analiza el comando en busca de vectores de escritura:

```bash
echo "codigo" > src/fuera_de_alcance.py     # BLOQUEADO
```

**Qué detecta:** redirecciones `>` y `>>` (también con la ruta entrecomillada), `tee`, `sed -i`, `perl -i`, `dd of=`, `cp`, `mv`, `rm`, `rmdir`, `truncate`, `touch`, `install`, `shred`, `ln`.

**Qué NO detecta** — el shell es demasiado expresivo para garantizarlo:

```bash
python3 -c "open('src/x.py','w').write('...')"   # pasa
eval "$(printf 'echo x > src/y.py')"              # pasa
base64 -d fichero.b64 > src/z.py                  # se detecta la redirección, no el contenido
```

**Falsos positivos evitados:** el contenido entrecomillado se neutraliza antes de buscar, así que `git commit -m "arreglar a > b"` no dispara. Y `/dev/null`, `/dev/std*`, `/tmp` y `$TMPDIR` están exentos.

Si un comando legítimo te bloquea, comprueba qué rutas está extrayendo:

```bash
echo '{"tool_name":"Bash","tool_input":{"command":"TU COMANDO AQUI"}}' \
  | FDA_GUARD_DEBUG=1 .claude/hooks/guard.sh; echo "exit=$?"
```

⚠️ **La línea más sensible de la configuración** es el matcher. Si alguien lo deja en `Edit|Write|MultiEdit|NotebookEdit`, el hueco se reabre entero y en silencio. La suite `check-guard.sh` lo detecta: 9 de sus 42 casos fallan si falta `Bash`.

**Red de seguridad de todo lo anterior:** el job `Gobierno FDA` de CI, la revisión del diff completo y branch protection. Nada llega a `main` sin pasar por ahí.

---

## CI en rojo

### `Gobierno FDA` falla

| Paso que falla | Causa | Arreglo |
|---|---|---|
| Archivos de gobierno presentes | Instalación incompleta | Copia el archivo que falta de la plantilla |
| El hook es ejecutable | Permiso perdido al copiar | `chmod +x .claude/hooks/guard.sh && git update-index --chmod=+x .claude/hooks/guard.sh` |
| El WP activo existe | `ACTIVE` apunta a un WP borrado | Corrige `ACTIVE` |
| El guard bloquea | Regresión en `guard.sh` | `bash evidence/WP-000/checks/check-guard.sh` en local |
| El manual acompaña | Cambiaste proceso sin tocar `docs/manual/` | Actualiza el manual **en esta PR** |

### `Lint · Tipos · Pruebas` pasa sin ejecutar nada

Los condicionales `if: hashFiles(...)` del bloque `{{COMANDOS_VALIDACION}}` no encuentran tu configuración. **Un job que se salta en silencio es peor que uno que falla.** Fija los comandos de tu stack y quita los condicionales ([01 — Instalación](01-instalacion.md)).

### `Escaneo de secretos` falla

```bash
git ls-files | grep -E '(^|/)\.env($|\.)|\.pem$|(^|/)secrets/'
```

Si hay un secreto **ya commiteado**, no basta con borrarlo: está en el historial. Rótalo primero, purga después.

En repos de organización, `gitleaks-action` requiere licencia. Sin ella, elimina ese paso y apóyate en el secret scanning nativo de GitHub.

### Nunca hagas esto para poner el CI en verde

Modificar `.github/workflows/` para que un check no se ejecute; añadir `continue-on-error: true`; bajar `--cov-fail-under`; marcar pruebas como `skip`. **CI rojo = no se fusiona.** Si el CI está mal, se arregla el CI en su propio WP.

---

## Un agente no carga

```bash
ls .claude/agents/                    # deben estar los 5 .md
head -12 .claude/agents/implementer.md
python3 -c "
import sys,yaml,pathlib
for f in sorted(pathlib.Path('.claude/agents').glob('*.md')):
    t=f.read_text()
    if not t.startswith('---'): print('SIN FRONTMATTER:',f); continue
    try: yaml.safe_load(t.split('---')[1])
    except Exception as e: print('YAML INVÁLIDO:',f,e)
"
```

| Causa | Señal |
|---|---|
| Frontmatter no empieza en la línea 1 | Una línea en blanco o un BOM antes de `---` |
| YAML inválido | Dos puntos sin comillas en `description` |
| Falta `name` o `description` | El agente no aparece en `/agents` |
| Sesión abierta antes de crear el archivo | Reinicia `claude` |

Lo mismo para skills: deben estar en `.claude/skills/<nombre>/SKILL.md` con frontmatter `name` y `description`. Un `SKILL.md` suelto fuera de su carpeta no se carga.

---

## El agente se sale del alcance

Si un agente **intentó** salirse y el hook lo paró: el sistema funcionó. Revisa si el WP estaba mal definido ([05 — Bloqueos](05-bloqueos-y-parada.md)).

Si un agente **consiguió** salirse, es un incidente de gobierno. Diagnóstico:

```bash
git diff --name-only main...HEAD    # contrasta con ## Archivos permitidos
```

Causas posibles: escritura vía `Bash` (ver límite conocido arriba); `ACTIVE` apuntando a otro WP; o alcance demasiado amplio (`src/**`) que hizo pasar el control sin controlar nada.

---

## El bootstrap no puede escribir su propia configuración

**Síntoma:** al instalar la plantilla, un agente no puede crear `.github/workflows/*` ni modificar `.claude/settings.json` o `.claude/hooks/*`.

**No es un fallo: es el control funcionando.** Esas rutas están en `permissions.deny` precisamente para que ningún agente pueda crear un workflow (ejecución de código arbitrario con acceso a tus secretos) ni desactivar sus propias guardas.

**Arreglo:** esos archivos los crea o modifica **una persona**. Es la excepción de bootstrap, y es deliberada. Si te resulta incómodo, mide el riesgo antes de relajar el deny: un agente que puede escribir en `.github/workflows/` puede exfiltrar `ANTHROPIC_API_KEY` y el `GITHUB_TOKEN` en el siguiente push.

---

## Comprobación completa del sistema

```bash
bash evidence/WP-000/checks/check-structure.sh
python3 evidence/WP-000/checks/check-agents-skills.py
bash evidence/WP-000/checks/check-guard.sh
python3 .claude/skills/run-verification/validate-workflows.py .github/workflows
python3 evidence/WP-000/checks/check-manual.py
```

Los cinco en verde = la FDA está operativa. Si alguno falla, arréglalo antes de lanzar ningún WP: un sistema de gobierno a medias da falsa confianza, que es peor que no tener ninguno.
