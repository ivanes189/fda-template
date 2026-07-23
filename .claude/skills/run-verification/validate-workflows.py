#!/usr/bin/env python3
"""
validate-workflows.py — Validación estructural de workflows de GitHub Actions.

Sustituto offline de actionlint para la verificación de la FDA: no requiere red,
ni instalar binarios, ni descargar nada. Comprueba lo que puede romper un
workflow en silencio: YAML inválido, claves obligatorias ausentes, jobs mal
formados y acciones de terceros sin anclar a una versión.

No sustituye a actionlint en profundidad (no valida expresiones ${{ }} ni el
catálogo de acciones). Si actionlint está instalado, úsalo también:
    actionlint .github/workflows/*.yml

Uso:   python3 validate-workflows.py [directorio_o_archivo ...]
Salida: exit 0 = todo válido · exit 1 = algún error
"""

import sys
import pathlib

try:
    import yaml
except ImportError:
    print("ERROR: falta PyYAML.  pip install pyyaml", file=sys.stderr)
    sys.exit(2)

errors: list[str] = []
warnings: list[str] = []


def check_step(wf: str, job: str, idx: int, step) -> None:
    where = f"{wf} :: job '{job}' :: paso {idx}"
    if not isinstance(step, dict):
        errors.append(f"{where}: el paso no es un mapa")
        return
    if "uses" not in step and "run" not in step:
        errors.append(f"{where}: el paso no tiene ni 'uses' ni 'run'")
    uses = step.get("uses")
    if isinstance(uses, str) and not uses.startswith("./"):
        if "@" not in uses:
            errors.append(f"{where}: acción sin versión anclada -> '{uses}'")
        elif uses.split("@")[-1] in ("main", "master"):
            warnings.append(
                f"{where}: acción anclada a rama móvil -> '{uses}' "
                "(usa una etiqueta o un SHA)"
            )


def check_workflow(path: pathlib.Path) -> None:
    wf = path.name
    try:
        data = yaml.safe_load(path.read_text(encoding="utf-8"))
    except yaml.YAMLError as e:
        errors.append(f"{wf}: YAML inválido -> {e}")
        return

    if not isinstance(data, dict):
        errors.append(f"{wf}: el workflow no es un mapa YAML")
        return

    # Cuidado: en YAML 1.1 la clave 'on' se interpreta como booleano True.
    # PyYAML devuelve la clave True, no la cadena 'on'. Aceptamos ambas.
    has_on = "on" in data or True in data
    if not has_on:
        errors.append(f"{wf}: falta la clave obligatoria 'on'")
    if "jobs" not in data:
        errors.append(f"{wf}: falta la clave obligatoria 'jobs'")
    if "name" not in data:
        warnings.append(f"{wf}: sin 'name' (se mostrará el nombre del archivo)")

    jobs = data.get("jobs")
    if not isinstance(jobs, dict) or not jobs:
        if "jobs" in data:
            errors.append(f"{wf}: 'jobs' vacío o mal formado")
        return

    for job_name, job in jobs.items():
        if not isinstance(job, dict):
            errors.append(f"{wf} :: job '{job_name}': no es un mapa")
            continue
        if "uses" in job:  # workflow reutilizable: no lleva runs-on ni steps
            continue
        if "runs-on" not in job:
            errors.append(f"{wf} :: job '{job_name}': falta 'runs-on'")
        steps = job.get("steps")
        if not isinstance(steps, list) or not steps:
            errors.append(f"{wf} :: job '{job_name}': 'steps' ausente o vacío")
            continue
        for i, step in enumerate(steps, 1):
            check_step(wf, job_name, i, step)


def collect(args: list[str]) -> list[pathlib.Path]:
    targets = [pathlib.Path(a) for a in (args or [".github/workflows"])]
    files: list[pathlib.Path] = []
    for t in targets:
        if t.is_dir():
            files.extend(sorted(t.glob("*.yml")) + sorted(t.glob("*.yaml")))
        elif t.is_file():
            files.append(t)
        else:
            errors.append(f"{t}: no existe")
    return files


def main() -> int:
    files = collect(sys.argv[1:])

    if not files and not errors:
        print("ERROR: no se encontró ningún workflow que validar", file=sys.stderr)
        return 1

    for f in files:
        check_workflow(f)

    print(f"Workflows analizados: {len(files)}")
    for f in files:
        print(f"  - {f}")
    print()

    for w in warnings:
        print(f"AVISO  {w}")
    for e in errors:
        print(f"ERROR  {e}")

    print()
    print(f"RESULTADO: {len(errors)} errores, {len(warnings)} avisos")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
