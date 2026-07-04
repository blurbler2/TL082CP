#!/usr/bin/env python3
"""
TL082CP PDIP-8 Footprint Export
Erstellt 1:1 und 2:1 (vergrößerte) Versionen des Footprints
"""

from PIL import Image
import os

# Verzeichnisse
BASE_DIR = "/Users/blurbler/TL082CP"
SOURCE_IMG = os.path.join(BASE_DIR, "docs/footprint.png")
OUTPUT_DIR = os.path.join(BASE_DIR, "mechanisch")

# Ausgabe-Verzeichnis erstellen
os.makedirs(OUTPUT_DIR, exist_ok=True)

print("=" * 50)
print("TL082CP Footprint Export (1:1 und 2:1)")
print("=" * 50)
print()

# Prüfe ob Quellbild existiert
if not os.path.exists(SOURCE_IMG):
    print(f"FEHLER: Quellbild nicht gefunden: {SOURCE_IMG}")
    exit(1)

# Bild laden
img = Image.open(SOURCE_IMG)
print(f"Quellbild: {SOURCE_IMG}")
print(f"  Größe: {img.size[0]} x {img.size[1]} Pixel")
print(f"  Modus: {img.mode}")
print()

# 1:1 Export (Originalgröße)
output_1to1 = os.path.join(OUTPUT_DIR, "TL082CP_1to1.png")
img.save(output_1to1, "PNG", dpi=(300, 300))
print(f"✓ 1:1 erstellt: {output_1to1}")
print(f"  Größe: {os.path.getsize(output_1to1) / 1024:.1f} KB")
print()

# 2:1 Export (200% skaliert)
# Für 2:1 Maßstab: Bild muss 2x größer sein
width, height = img.size
new_size = (width * 2, height * 2)
img_2to1 = img.resize(new_size, Image.LANCZOS)

output_2to1 = os.path.join(OUTPUT_DIR, "TL082CP_2to1.png")
img_2to1.save(output_2to1, "PNG", dpi=(300, 300))
print(f"✓ 2:1 erstellt: {output_2to1}")
print(f"  Größe: {os.path.getsize(output_2to1) / 1024:.1f} KB")
print(f"  Dimensionen: {new_size[0]} x {new_size[1]} Pixel")
print()

# Auch als PDF exportieren
output_pdf_1to1 = os.path.join(OUTPUT_DIR, "TL082CP_1to1.pdf")
img.save(output_pdf_1to1, "PDF", resolution=300.0)
print(f"✓ 1:1 PDF erstellt: {output_pdf_1to1}")

output_pdf_2to1 = os.path.join(OUTPUT_DIR, "TL082CP_2to1.pdf")
img_2to1.save(output_pdf_2to1, "PDF", resolution=300.0)
print(f"✓ 2:1 PDF erstellt: {output_pdf_2to1}")
print()

print("=" * 50)
print("Export abgeschlossen!")
print("=" * 50)
print()
print("Dateien:")
for f in sorted(os.listdir(OUTPUT_DIR)):
    filepath = os.path.join(OUTPUT_DIR, f)
    size = os.path.getsize(filepath) / 1024
    print(f"  {f:30s} {size:>8.1f} KB")
