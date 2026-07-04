#!/bin/bash
# Export TL082CP PDIP-8 Footprint in 1:1 und 2:1 Maßstab

# Verzeichnis erstellen
mkdir -p mechanisch

echo "=== TL082CP Footprint Export ==="
echo ""

# Methode 1: Mit Inkscape (falls SVG vorhanden)
if command -v inkscape &> /dev/null; then
    echo "Inkscape gefunden - verwende Inkscape für Export"
    
    # 1:1 Export
    if [ -f "kicad/TL082CP/P8_TEX.kicad_mod" ]; then
        echo "Exportiere 1:1..."
        # Hier würde der SVG-Export aus KiCad kommen
    fi
fi

# Methode 2: Mit ImageMagick (für PNG-Dateien)
if command -v convert &> /dev/null; then
    echo "ImageMagick gefunden - konvertiere PNG-Dateien"
    
    # 1:1 Kopie
    if [ -f "docs/footprint.png" ]; then
        cp docs/footprint.png mechanisch/TL082CP_1to1.png
        echo "✓ mechanisch/TL082CP_1to1.png erstellt"
    fi
    
    # 2:1 (200% skaliert)
    if [ -f "docs/footprint.png" ]; then
        convert docs/footprint.png -resize 200% mechanisch/TL082CP_2to1.png
        echo "✓ mechanisch/TL082CP_2to1.png erstellt (2:1)"
    fi
fi

# Methode 3: Mit PDF-Export
if command -v convert &> /dev/null; then
    echo ""
    echo "Erstelle PDF-Versionen..."
    
    # 1:1 PDF
    if [ -f "docs/footprint.png" ]; then
        convert docs/footprint.png mechanisch/TL082CP_1to1.pdf
        echo "✓ mechanisch/TL082CP_1to1.pdf erstellt"
    fi
    
    # 2:1 PDF
    if [ -f "docs/footprint.png" ]; then
        convert docs/footprint.png -resize 200% mechanisch/TL082CP_2to1.pdf
        echo "✓ mechanisch/TL082CP_2to1.pdf erstellt (2:1)"
    fi
fi

echo ""
echo "=== Export abgeschlossen ==="
echo "Dateien im Ordner: mechanisch/"
ls -la mechanisch/
