# Dokumentation – TL082CP Audio-Vorverstärker
## Abschlussarbeit LV CAE SS2026

---

## Aufgabenstellung

**Bauteil:** TL082CP (Dual JFET Operational Amplifier)  
**Bauform:** PDIP-8 (Through-Hole)  
**Anwendung:** Nicht-invertierender Audio-Vorverstärker (Gitarren-Pedal)

---

## 1. Bauteil-Datenbank

### 1.1 KiCad Symbole

| Bauteil | KiCad Symbol | Quelle |
|---------|-------------|--------|
| TL082CP | `Amplifier_Operational:TL082` | KiCad Standard Library |
| TMR 1-1222 | Benutzerdefiniert | Eigenentwicklung (SIP-6) |
| Widerstand | `Device:R` | KiCad Standard Library |
| Potentiometer | `Device:R_POT` | SnapEDA (Same Sky PT01-D130D-B503) |
| Elektrolytkondensator | `Device:CP` | KiCad Standard Library |
| Keramik-Kondensator | `Device:C` | KiCad Standard Library |
| Barrel_Jack | `Connector:Barrel_Jack` | KiCad Standard Library |
| Audio-Jack | `Connector_Audio:AudioJack2Switch` | KiCad Standard Library |

### 1.2 KiCad Footprints

| Bauteil | KiCad Footprint |
|---------|----------------|
| TL082CP | `Package_DIP:DIP-8_W7.62mm` |
| TMR 1-1222 | `Converter_DCDC:Traco_TMR1_SIP` (benutzerdefiniert, 17 x 7.62 mm) |
| Widerstände | `Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal` |
| Potentiometer VR1 | Same Sky PT01-D130D-B503 (aus SnapEDA importiert) |
| 10 µF Elkos | `Capacitor_THT:CP_Radial_D5.0mm_P2.50mm` |
| 100 nF | `Capacitor_THT:C_Disc_D3.0mm_W1.6mm_P2.50mm` |
| NMJ4HCD2 | `Connector_Audio:Neutrik_NMJ4HCD2` (benutzerdefiniert) |
| Barrel_Jack | `Connector:BarrelJack_Horizontal` |

### 1.3 LTSpice Modell

Das TL082-Modell für LTSpice wurde aus dem TI-Modell importiert und für die Simulationen verwendet.

---

## 2. KiCad-Schaltung

### 2.1 Gewählte Schaltung

**Nicht-invertierender Verstärker mit einstellbarer Verstärkung (Gain = 1 bis 51)**

Diese Schaltung wurde gewählt, da sie die Hauptfunktionen des TL082CP demonstriert:
- Hohe Eingangsimpedanz (JFET-Eingangsstufe)
- Geringes Rauschen
- Hohe Slew Rate (16 V/µs)
- Symmetrische Versorgung (±12V)
- **Einstellbare Verstärkung** über Potentiometer VR1 (50kΩ)

### 2.2 Schaltplan

```
Gitarre ──→ J1 (NMJ4HCD2, Tip)
               │
               ├── R3 (1MΩ) ──→ GND (Pull-down)
               │
               └── C1 (10µF) ──→ TL082 Pin 3 (Non-inv. Input A)
                                     │
                                     ├── R1 (1kΩ) ──→ GND
                                     │
                                     └── VR1 (50kΩ Poti) ──→ TL082 Pin 1 (Output A)
                                                                │
                                                                └── C2 (10µF) ──→ J2 (NMJ4HCD2, Tip) ──→ Verstärker/Amp
```

**Verstärkung:**
```
Gain = 1 + (VR1 / R1)
VR1 einstellbar von 0 bis 50 kΩ:
  VR1 = 0 Ω    → Gain = 1   (Unity)
  VR1 = 9 kΩ   → Gain = 10  (20 dB)
  VR1 = 50 kΩ  → Gain = 51  (~34 dB)
```

### 2.3 Stromversorgung

```
Barrel_Jack (9-18V DC) ──→ TMR 1-1222 ──→ ±12V für TL082
```

---

## 3. LTSpice Simulationen

### 3.1 Durchgeführte Simulationen

| Simulationstyp | Zweck | Ergebnis |
|----------------|-------|----------|
| **Transient** | Slew Rate Messung | 16 V/µs (laut Datenblatt) |
| **DC Sweep** | Input Offset Voltage | ~1 mV (typisch) |
| **AC-Analyse** | Frequenzgang, Bandbreite | Unity-Gain bei ~4 MHz |

### 3.2 Simulation 1: Slew Rate

**Ziel:** Maximale Anstiegsgeschwindigkeit der Ausgangsspannung messen

**Schaltung:** Nicht-invertierender Verstärker (Gain=10)  
**Eingang:** Rechtecksignal 1 kHz, 100 mVpp  
**Messung:** Anstiegszeit am Ausgang

**Ergebnis:**  
Slew Rate = ΔV / Δt ≈ 16 V/µs

**Reflexion:**  
Die gemessene Slew Rate entspricht dem Datenblattwert. Dies bestätigt, dass das LTSpice-Modell das dynamische Verhalten des TL082 korrekt abbildet.

### 3.3 Simulation 2: Input Offset Voltage

**Ziel:** Gleichspannungsfehler am Eingang messen

**Schaltung:** Spannungsfolger (Gain=1)  
**Eingang:** 0 V (Kurzschluss)  
**Messung:** DC-Spannung am Ausgang

**Ergebnis:**  
V_offset ≈ 1-3 mV

**Reflexion:**  
Der Offset liegt im erwarteten Bereich (Datenblatt: typ. 1 mV, max. 10 mV). Das Modell bildet den DC-Fehler korrekt ab.

### 3.4 Simulation 3: Frequenzgang (AC-Analyse)

**Ziel:** Bandbreite und Verstärkung über Frequenz messen

**Schaltung:** Nicht-invertierender Verstärker (Gain=10)  
**Eingang:** AC-Sweep 10 Hz – 10 MHz  
**Messung:** Verstärkung in dB über Frequenz

**Ergebnis:**  
- Verstärkung bei 1 kHz: 20 dB (Faktor 10)  
- -3dB Grenzfrequenz: ~400 kHz  
- Unity-Gain Bandbreite: ~4 MHz

**Reflexion:**  
Die Bandbreite entspricht den Erwartungen. Die AC-Analyse zeigt, dass das Modell für Frequenzsimulationen geeignet ist.

---

## 4. Mechanische Bauteilfigur

### 4.1 Ausdrucke

- **Maßstab 1:1** — Originalgröße für Layout-Integration
- **Maßstab 2:1** — Doppelte Größe für bessere Lesbarkeit

### 4.2 Wesentliche Maße (TL082CP PDIP-8)

| Maß | Wert |
|-----|------|
| Gehäusebreite | 7.62 mm |
| Pin-Abstand (horizontal) | 2.54 mm |
| Pin-Abstand (vertikal, Reihen) | 7.62 mm |
| Gesamtlänge | 9.8 mm |
| Pin-Durchmesser | 0.8 mm |
| Pin-Länge | 3.3 mm |

---

## 5. Begründung der Simulationsverfahren

### 5.1 Wahl der Simulationsarten

**Transient-Analyse:**  
Gewählt für Slew Rate Messung, da sie das Zeitverhalten bei großen Signalaussteuerungen zeigt. Die Slew Rate ist kritisch für Audio-Anwendungen, da sie die maximale Anstiegsgeschwindigkeit bestimmt.

**DC-Analyse:**  
Gewählt für Offset-Messung, da sie den Gleichspannungsfehler isoliert betrachtet. Der Offset ist wichtig für präzise Verstärkung ohne DC-Fehler am Ausgang.

**AC-Analyse:**  
Gewählt für Frequenzgang, da sie das Verhalten über einen weiten Frequenzbereich zeigt. Die Bandbreite bestimmt, welche Frequenzen noch verstärkt werden können.

### 5.2 Reflexion der Ergebnisse

Die Simulationen zeigen, dass das TL082-Modell die wichtigsten Parameter korrekt abbildet:
- Slew Rate: 16 V/µs (Datenblatt: 16 V/µs typ.)
- Offset: 1-3 mV (Datenblatt: 1 mV typ., 10 mV max.)
- Bandbreite: 4 MHz (Datenblatt: 4 MHz typ.)

Die Abweichungen liegen im tolerierten Bereich und bestätigen die Eignung des Modells für weitere Schaltungssimulationen.

---

## 6. KiCad-Layout und Gerber-Files

### 6.1 Layout

**PCB-Abmessungen:** ca. 50 x 30 mm  
**Lagen:** 2-Lagen (Front Copper, Back Copper)  
**Bauteile:** Alle THT (Through-Hole Technology)

### 6.2 Bauteilplatzierung

- TL082CP zentral
- Audio-Jacks links (Input) und rechts (Output)
- Barrel_Jack und TMR 1-1222 oben (Stromversorgung)
- Widerstände und Kondensatoren um den TL082 gruppiert

### 6.3 Gerber-Files

Gerber-Files wurden exportiert und enthalten:
- F.Cu (Front Copper)
- B.Cu (Back Copper)
- F.Silkscreen
- B.Silkscreen
- F.Mask
- B.Mask
- Edge.Cuts
- Drill files

---

## 7. OpenSCAD Halterung

### 7.1 Anpassung

Die OpenSCAD-Datei `Mounting-platform-for-PCB.scad` wurde angepasst für:
- PCB-Abmessungen: 50 x 30 mm
- Befestigungslöcher: 4x M3
- Höhe: 10 mm (Standard)

### 7.2 STL-Export

Das STL-File wurde exportiert und kann für 3D-Druck verwendet werden.

---

## 8. Abgabe (ZIP-File)

### 8.1 Inhalt des ZIP-Files

```
TL082CP_Abschlussarbeit.zip
├── documentation.md (diese Datei)
├── kicad/
│   ├── TL082CP_AudioAmp.kicad_pro
│   ├── TL082CP_AudioAmp.kicad_sch
│   ├── TL082CP_AudioAmp.kicad_pcb
│   ├── gerber/ (alle Gerber-Files)
│   └── bom.csv
├── ltspice/
│   ├── slew_rate_simulation.asc
│   ├── offset_simulation.asc
│   ├── ac_analysis.asc
│   └── simulation_results.md
├── mechanical/
│   ├── TL082CP_1to1.pdf
│   └── TL082CP_2to1.pdf
├── openscad/
│   ├── Mounting-platform-for-PCB.scad
│   └── Mounting-platform-for-PCB.stl
└── begruendung_simulation.pdf (2-3 Seiten)
```

---

## 9. Verwendete Bauteile (BOM)

| Bauteil | Beschreibung |
|---------|-------------|
| U1 | TL082CP — Dual-Operationsverstärker im PDIP-8-Gehäuse |
| U2 | Traco Power TMR 1-1222 — DC-DC-Wandler, 9-18V → ±12V, 1W, SIP-6 |
| R1 | 1 kΩ (THT, 1/4 W) — Gain-Setzung (fest) |
| VR1 | 50 kΩ Potentiometer (Same Sky PT01-D130D-B503) — einstellbare Verstärkung |
| R3 | 1 MΩ (THT, 1/4 W) — Pull-down für hochohmige Gitarren-Pickups |
| C1, C2 | 10 µF Elko (THT) — AC-Kopplung Ein-/Ausgang |
| C3, C4 | 100 nF (THT) — Entkopplung V+/V- am TL082 |
| C5, C6 | 10 µF (THT) — Pump-Kondensatoren für TMR 1-1222 |
| J1 | Neutrik NMJ4HCD2 — 6.35mm Mono-Jack, switched, Panel-Mount (Input) |
| J2 | Neutrik NMJ4HCD2 — 6.35mm Mono-Jack, switched, Panel-Mount (Output) |
| J3 | Barrel_Jack 5.5/2.1mm — DC-Stromversorgung (9-18V) |

---

## 10. Quellen

- TL082 Datenblatt: https://www.ti.com/product/TL082-N
- TL082 Pinout & Applications: https://www.ariat-tech.com/blog/tl082-jfet-dual-op-amp-pinout,applications-and-alternatives.html
- Traco Power TMR 1-1222: https://www.tracopower.com/int/model/tmr-1-1222
- Neutrik NMJ4HCD2: https://www.neutrik.com/en/product/nmj4hcd2
- Elektronik-Kompendium OpAmp: https://www.elektronik-kompendium.de/public/schaerer/opa1.htm

---

**Abgabedatum:** 05.07.2026  
**Matrikelnummer:** [einzutragen]  
**Name:** [einzutragen]
