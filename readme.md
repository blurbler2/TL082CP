# TL082CP — Bauteil-Datenbank (CUE SS2026, AE27)

Abschlussaufgabe der Lehrveranstaltung "Computerunterstützter Schaltungs- und Systementwurf" (CAE).

**Bauteil:** TL082CP — Dual JFET-Input Operational Amplifier (Texas Instruments BI-FET II™)

## Aufgabenstellung

**Bauteil:** TL082CP — Dual JFET-Input Operational Amplifier  
**Bauform:** Frei wählbar (gewählt: PDIP-8)  
**Anwendung:** Audio-Vorverstärker (Gitarren-Pedal)

### Geforderte Deliverables:
- ✅ KiCad-Schaltung zum Nachweis der Hauptfunktionen
- ✅ LTSpice-Simulationen (Transient, DC, AC)
- ✅ Mechanische Bauteilfigur (1:1 und 2:1)
- ✅ Begründung der Simulationsverfahren (2-3 Seiten)
- ✅ KiCad-Layout mit Ein-/Ausgangssignalen
- ✅ Gerber-Files für PCB-Fertigung
- ✅ OpenSCAD Halterung (angepasst für das PCB)
- ✅ ZIP-File mit allen Unterlagen

**Abgabe:** Moodle-Kurs bis spätestens **05.07.2026, 23:55 Uhr**

## Projektstruktur

```
TL082CP/
├── kicad/                          # KiCad Projekte
│   ├── TL082CP/                    # Hauptprojekt (Gitarren-Pedal)
│   │   ├── TL082CP.kicad_pro
│   │   ├── TL082CP.kicad_sch      # Top-Level Schematic
│   │   ├── audio-vorverstaerker-TL082CP.kicad_sch  # Audio Amp Schaltung
│   │   ├── audio_signal.kicad_sch  # Signalweg
│   │   ├── power.kicad_sch         # Stromversorgung
│   │   └── TL082CP.kicad_pcb       # PCB Layout
│   │
│   ├── TL082-smd/                  # SMD Version (SOIC-8)
│   │   ├── TL082.kicad_sym
│   │   └── SOIC127P600X175-8N.kicad_mod
│   │
│   ├── ul_TL082CP-NOPB/            # Ultra Librarian Import
│   │   └── KiCADv6/
│   │       ├── 2026-07-03_18-03-43.kicad_sym
│   │       └── footprints.pretty/P8_TEX.kicad_mod
│   │
│   ├── 1_own_TL082CP.pretty/       # Eigene Footprints
│   │   ├── P8_TEX.kicad_mod
│   │   └── SOIC127P600X175-8N.kicad_mod
│   │
│   ├── NEUTRIKJKS/                 # Neutrik Audio-Jack Projekte
│   │   ├── NEUTRIKJKS_V6/
│   │   └── NEUTRIKJKS_V7/
│   │
│   ├── PT01-D130D-B503/            # Potentiometer (SnapEDA)
│   │   ├── PT01-D130D-B503.kicad_sym
│   │   └── TRIM_PT01-D130D-B503.kicad_mod
│   │
│   ├── idee.md                     # Schaltungsidee & ASCII-Schema
│   └── documentation.md            # Vollständige Dokumentation
│
├── ltspice/                        # LTSpice Simulationen
│   ├── ltspice-simulation-1-buffer-slew-rate/
│   │   ├── WORKS-non-inverting-buffer-test-slew-rate-tl802-op-amp.asc
│   │   └── simulation-1-buffer-slew-rate.md
│   │
│   ├── ltspice-simulation-1-comparator-slew-rate/
│   │   ├── WORKS-non-inverting-comparator-test-slew-rate-tl802-op-amp.asc
│   │   └── simulation-1-comparator-slew-rate.md
│   │
│   └── ltspice-simulation-2-input-offset-voltage/
│       ├── non-inverting-test-input-offset-voltage-tl802-op-amp.asc
│       ├── inverting-amplifier-test-input-offset-voltage-tl802-op-amp.asc
│       └── simulation-2-input-offset-voltage.md
│
├── docs/                           # Dokumentation & Datenblätter
│   ├── tl082.pdf                   # TL082 Datenblatt (TI)
│   ├── tl082-n.pdf                 # TL082-N Datenblatt
│   ├── mpdi001b.pdf                # Package Information
│   └── application-note.pdf        # Application Note
│
├── .gitignore                      # Git Ignore
└── readme.md                       # Diese Datei
```

## Preview

### PCB Layout
<img src="docs/pcb.png" alt="PCB Layout" width="50%">

### Footprint
<img src="docs/footprint.png" alt="Footprint" width="50%">

## Inhalt

| Datei | Beschreibung |
|---|---|
| `kicad/documentation.md` | Vollständige Dokumentation des Gitarren-Pedals |
| `kicad/idee.md` | Schaltungsidee mit ASCII-Schema und BOM |
| `docs/tl082.pdf` | Datenblatt (Texas Instruments) |
| `docs/application-note.pdf` | Application Note |
| `ltspice/` | LTSpice Simulationen (Slew Rate, Offset Voltage) |

## MD → PDF konvertieren

Die Dokumentation (`abgabe.md`) lässt sich mit **Pandoc + XeLaTeX** in ein druckbares PDF umwandeln.

### Voraussetzungen

- **Pandoc** installieren: `brew install pandoc` (macOS) bzw. `apt install pandoc` (Linux) bzw. https://pandoc.org
- **XeLaTeX** (TeX Live oder MiKTeX) installieren

### Beispiel: `abgabe.md` → PDF

```bash
pandoc abgabe.md \
  --pdf-engine=xelatex \
  -V lang=de \
  -V geometry:margin=2.5cm \
  -V fontsize=11pt \
  -V colorlinks=true \
  -o abgabe.pdf
```

### Hinweise

- Für **deutsche Sonderzeichen / Umlaute** ist XeLaTeX in Kombination mit `-V lang=de` empfohlen.

## KiCad — Ground Plane (Massefläche) erstellen

Eine Massefläche muss auf einem **Kupfer-Layer** erstellt werden, nicht auf `User.1`.

### Schritte

1. **Zone löschen** — Falls eine Zone auf `User.1` existiert: Zone auswählen → `Delete`

2. **Neue Zone auf B.Cu erstellen**
   - `Place → Zone` (Shortcut `P Z`)
   - **WICHTIG:** In der Layer-Auswahl unten links → **`B.Cu`** wählen
   - Im Dialog:
     - `Net:` → **`GND`** auswählen
     - `Zone connection:` → `Thermal Relief` (empfohlen)

3. **Zone zeichnen**
   - Umrandung um die gesamte PCB ziehen (entlang des Board-Randes)
   - Rechtsklick → `Fill Zone` oder `B` drücken

4. **Alle Netze neu zeichnen**
   - `Tools → Rebuild All Zones` oder `Shift+B`

5. **DRC prüfen**
   - `Tools → Design Rule Check` → `Start` — keine GND-Fehler sollte angezeigt werden

6. ** Gerber neu exportieren**
   - `File → Fabrication Outputs → Gerber` — Layer `B.Cu` muss enthalten sein
   - `File → Fabrication Outputs → Drill Files` — Bohr-Dateien aktualisieren

### Warum nicht `User.1`?

`User.1` ist eine Dokumentationsebene — Flächen darauf sind **nur optisch sichtbar**, elektrisch haben sie keine Funktion. Die Ground Plane muss auf `B.Cu` (oder `F.Cu`) liegen, damit sie tatsächlich mit dem GND-Netz verbunden ist.

---

## Abgabe

ZIP-File mit allen geforderten Unterlagen, Moodle-Kurs "CUE SS2026 – AE27", bis spätestens **05.07.2026, 23:55 Uhr**.

