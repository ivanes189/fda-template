#!/usr/bin/env python3
"""
check-agents-skills.py — Verificación 2 de la Fase 0.

Comprueba que los 5 agentes y las 3 skills están en las rutas que lee Claude
Code y que su frontmatter es válido y cargable.

LÍMITE DE ESTA COMPROBACIÓN: valida los archivos, no arranca el CLI. La carga
real en una sesión interactiva se confirma con /agents y /skills — ese paso lo
ejecuta una persona (ver evidence/WP-000/02-agentes-skills.md).

Uso:   python3 evidence/WP-000/checks/check-agents-skills.py
Salida: exit 0 = todo válido · exit 1 = algún fallo
"""

import pathlib
import sys

try:
    import yaml
except ImportError:
    print("ERROR: falta PyYAML.  pip install pyyaml", file=sys.stderr)
    sys.exit(2)

ROOT = pathlib.Path(__file__).resolve().parents[3]

AGENTES = {
    "planner": {"edita": False},
    "implementer": {"edita": True},
    "qa": {"edita": True},
    "security-reviewer": {"edita": False},
    "code-reviewer": {"edita": False},
}
SKILLS = ["new-work-package", "run-verification", "prepare-pr"]

fallos: list[str] = []
avisos: list[str] = []


def frontmatter(path: pathlib.Path):
    """Devuelve (dict, error). El frontmatter debe empezar en la línea 1."""
    texto = path.read_text(encoding="utf-8")
    if not texto.startswith("---"):
        return None, "el frontmatter no empieza en la primera línea"
    partes = texto.split("---", 2)
    if len(partes) < 3:
        return None, "frontmatter sin cierre '---'"
    try:
        datos = yaml.safe_load(partes[1])
    except yaml.YAMLError as e:
        return None, f"YAML inválido: {e}"
    if not isinstance(datos, dict):
        return None, "el frontmatter no es un mapa"
    return datos, None


print("=" * 62)
print(" Agentes y skills — frontmatter y rutas")
print("=" * 62)

print("\n--- Agentes (.claude/agents/) ---")
for nombre, cfg in AGENTES.items():
    ruta = ROOT / ".claude" / "agents" / f"{nombre}.md"
    if not ruta.is_file():
        fallos.append(f"agente ausente: {ruta.relative_to(ROOT)}")
        print(f"  FALTA  {nombre}")
        continue

    datos, err = frontmatter(ruta)
    if err:
        fallos.append(f"{nombre}: {err}")
        print(f"  ERROR  {nombre}: {err}")
        continue

    for campo in ("name", "description"):
        if not datos.get(campo):
            fallos.append(f"{nombre}: falta '{campo}'")
    if datos.get("name") != nombre:
        fallos.append(f"{nombre}: 'name' es '{datos.get('name')}', debe coincidir con el archivo")

    tools = str(datos.get("tools", ""))
    disallowed = str(datos.get("disallowedTools", ""))
    escribe = "Edit" in tools or "Write" in tools

    # Los agentes de solo lectura no pueden tener herramientas de escritura.
    if not cfg["edita"]:
        if escribe:
            fallos.append(f"{nombre}: es de solo lectura pero tiene Edit/Write en 'tools'")
        if "Edit" not in disallowed:
            avisos.append(f"{nombre}: convendría 'disallowedTools' explícito")

    modelo = datos.get("model", "(heredado)")
    turns = datos.get("maxTurns", "(sin límite)")
    if turns == "(sin límite)":
        avisos.append(f"{nombre}: sin 'maxTurns' — no hay criterio de parada por coste")

    print(f"  OK     {nombre:<18} model={modelo:<8} maxTurns={turns:<5} "
          f"{'escribe' if escribe else 'solo lectura'}")

print("\n--- Skills (.claude/skills/<nombre>/SKILL.md) ---")
for nombre in SKILLS:
    ruta = ROOT / ".claude" / "skills" / nombre / "SKILL.md"
    if not ruta.is_file():
        fallos.append(f"skill ausente: {ruta.relative_to(ROOT)}")
        print(f"  FALTA  {nombre}")
        continue

    datos, err = frontmatter(ruta)
    if err:
        fallos.append(f"{nombre}: {err}")
        print(f"  ERROR  {nombre}: {err}")
        continue

    for campo in ("name", "description"):
        if not datos.get(campo):
            fallos.append(f"skill {nombre}: falta '{campo}'")
    if datos.get("name") != nombre:
        fallos.append(f"skill {nombre}: 'name' no coincide con el directorio")

    print(f"  OK     {nombre:<18} {str(datos.get('description', ''))[:44]}...")

# El hook debe ser ejecutable o no bloquea nada.
guard = ROOT / ".claude" / "hooks" / "guard.sh"
print("\n--- Hook ---")
import os
if not guard.is_file():
    fallos.append("falta .claude/hooks/guard.sh")
    print("  FALTA  guard.sh")
elif not os.access(guard, os.X_OK):
    fallos.append("guard.sh no es ejecutable (chmod +x): el hook no bloquearía")
    print("  ERROR  guard.sh no es ejecutable")
else:
    print("  OK     guard.sh ejecutable")

print("\n" + "=" * 62)
for a in avisos:
    print(f"AVISO  {a}")
for f in fallos:
    print(f"FALLO  {f}")
print(f" RESULTADO: {len(fallos)} fallos, {len(avisos)} avisos")
print("=" * 62)
sys.exit(1 if fallos else 0)
