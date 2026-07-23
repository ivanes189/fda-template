#!/usr/bin/env python3
"""
check-manual.py — Verificación 5 de la Fase 0.

1. Todos los enlaces internos del manual (y de CLAUDE.md) resuelven a archivos
   que existen.
2. Los 3 placeholders de instalación están presentes donde deben estar.

Uso:   python3 evidence/WP-000/checks/check-manual.py
Salida: exit 0 = OK · exit 1 = enlaces rotos o placeholders ausentes
"""

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[3]
MANUAL = ROOT / "docs" / "manual"

PLACEHOLDERS = [
    "{{COMANDOS_VALIDACION}}",
    "{{PROPIEDAD_COMPONENTES}}",
    "{{PRESUPUESTOS_Y_MODELOS}}",
]

# [texto](destino) — ignora imágenes y anclas puras
ENLACE = re.compile(r"(?<!\!)\[([^\]]+)\]\(([^)]+)\)")

fallos: list[str] = []

print("=" * 62)
print(" Manual — enlaces internos y placeholders de instalación")
print("=" * 62)

# --- 1. Enlaces -------------------------------------------------------------
archivos = sorted(MANUAL.glob("*.md")) + [ROOT / "CLAUDE.md"]
archivos = [f for f in archivos if f.is_file()]

total_enlaces = 0
print(f"\n--- Enlaces internos ({len(archivos)} archivos) ---")

for f in archivos:
    texto = f.read_text(encoding="utf-8")
    rotos_aqui = []
    for etiqueta, destino in ENLACE.findall(texto):
        if destino.startswith(("http://", "https://", "mailto:", "#")):
            continue
        total_enlaces += 1
        objetivo = (f.parent / destino.split("#")[0]).resolve()
        if not objetivo.exists():
            rotos_aqui.append(f"[{etiqueta}]({destino})")
            fallos.append(f"{f.relative_to(ROOT)}: enlace roto -> {destino}")
    estado = "OK   " if not rotos_aqui else "ROTO "
    print(f"  {estado} {str(f.relative_to(ROOT)):<44} "
          f"{'' if not rotos_aqui else ' | '.join(rotos_aqui)}")

print(f"\n  Enlaces internos comprobados: {total_enlaces}")

# --- 2. Placeholders --------------------------------------------------------
print("\n--- Placeholders en docs/manual/01-instalacion.md ---")
instalacion = MANUAL / "01-instalacion.md"
if not instalacion.is_file():
    fallos.append("falta docs/manual/01-instalacion.md")
    print("  FALTA el archivo")
else:
    texto = instalacion.read_text(encoding="utf-8")
    for p in PLACEHOLDERS:
        if p in texto:
            print(f"  OK    {p}")
        else:
            fallos.append(f"01-instalacion.md: falta el placeholder {p}")
            print(f"  FALTA {p}")

# --- 3. Los placeholders también viven en los archivos que se parametrizan ---
print("\n--- Placeholders en los archivos parametrizados ---")
esperado = {
    "CODEOWNERS": ["{{PROPIEDAD_COMPONENTES}}"],
    ".github/workflows/ci.yml": ["{{COMANDOS_VALIDACION}}"],
}
for rel, ps in esperado.items():
    ruta = ROOT / rel
    if not ruta.is_file():
        print(f"  AVISO {rel} no existe todavía")
        continue
    texto = ruta.read_text(encoding="utf-8")
    for p in ps:
        if p in texto:
            print(f"  OK    {rel:<34} {p}")
        else:
            fallos.append(f"{rel}: falta el marcador {p}")
            print(f"  FALTA {rel:<34} {p}")

print("\n" + "=" * 62)
for f in fallos:
    print(f"FALLO  {f}")
print(f" RESULTADO: {len(fallos)} fallos")
print("=" * 62)
sys.exit(1 if fallos else 0)
