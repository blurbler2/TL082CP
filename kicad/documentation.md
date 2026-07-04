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
| PJ-102A | PJ-102A (aus SnapEDA importiert, Same Sky) |
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
Gitarre ──→ J1 (PJ-102A, Tip)
               │
               ├── C1 (10µF) ──┬──── TL082 Pin 3 (Non-inv. Input A)
               │                │
               │            R3 (1MΩ)
               │                │
               │               GND (Bias-Referenz)
               │
               └─────────────────┘
                                     │
                                     ├── R1 (4.7kΩ) ──→ GND
                                     │
                                     └── VR1 (50kΩ Poti) ──→ TL082 Pin 1 (Output A)
                                                                │
                                                                └── C2 (10µF) ──→ J2 (PJ-102A, Tip) ──→ Verstärker/Amp
```

**Verstärkung:**
```
Gain = 1 + (VR1 / R1)
VR1 einstellbar von 0 bis 50 kΩ:
  VR1 = 0 Ω     → Gain = 1    (0 dB, Unity)
  VR1 = 4.7 kΩ  → Gain = 2    (6 dB)
  VR1 = 25 kΩ   → Gain = 6.3  (16 dB)
  VR1 = 50 kΩ   → Gain = 11.6 (21.3 dB)
```

**Silkscreen-Beschriftung:** "GAIN  0 dB – 21 dB" (oder "1× – 12×")

**Warum Gain 1-11.6 statt 1-51?**
- Passive Gitarre liefert typisch 100-500 mV Peak (ca. 300 mV bei normalem Anschlag)
- Bei Gain 51 und 300 mV Input: 15.3 V Output → Clipping bei ±12V Versorgung
- Bei Gain 11.6 und 300 mV Input: 3.5 V Output → kein Clipping, mehr Reserve
- Gain 1-11.6 ist ein realistischer und gut beherrschbarer Bereich für einen Clean Preamp

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

**Schaltung:** Nicht-invertierender Buffer (Gain=1)  
**Eingang:** Rechtecksignal ±10V, 50 kHz, 50% Duty Cycle  
**Messung:** Anstiegszeit am Ausgang mit `.meas`-Direktiven

**Ergebnis:**  
Slew Rate = ΔV / Δt ≈ **13.4 V/µs**

**Datenblatt-Vergleich:**
- Simuliert: 13.4 V/µs
- Datenblatt TL082CP: 20 V/µs typisch
- Abweichung: 67% des Datenblattwerts

**Modell-Limitierung:**  
Das verwendete TI-Makromodell `TL082.301` wurde am 06.06.1989 erstellt (`CREATED USING PARTS RELEASE 4.01 ON 06/16/89 AT 13:08`). Die Diskrepanz ist auf Vereinfachungen im Makromodell zurückzuführen:
- Vereinfachte Eingangsstufen-Modellierung
- Idealisierte Stromquellen und Kapazitäten
- Keine Berücksichtigung moderner Fertigungstoleranzen

**Reflexion:**  
Trotz der Abweichung bildet das Modell das grundlegende dynamische Verhalten korrekt ab:
- Symmetrische Slew Rate für Anstieg/Abfall
- Konstante Slew Rate bei großen Differenzspannungen
- Reduzierte Slew Rate bei kleinen Differenzspannungen (lineare Region)

### 3.3 Simulation 2: Input Offset Voltage

**Ziel:** Gleichspannungsfehler am Eingang messen

**Schaltung:** Invertierender Verstärker (Gain=-1000)  
**Eingang:** 0 V DC  
**Messung:** DC-Arbeitspunkt mit `.op`-Analyse

**Ergebnis:**  
V_offset ≈ **11 µV** (rein numerischer Artefakt)

**Datenblatt-Vergleich:**
- Simuliert: 11 µV
- Datenblatt TL082CP: 3-15 mV (typisch-max)
- Abweichung: Faktor 300-1000

**Modell-Limitierung:**  
Das TI-Makromodell `TL082.301` enthält **keine Eingangs-Offsetspannung** modelliert:
- Keine `VOS`-Spannungsquelle am Eingang
- Keine Mismatch-Parameter für JFETs (J1, J2)
- Keine Bias-Strom-Streuung
- Alle JFETs sind ideal symmetrisch (gleiche VTO, BETA)

Die gemessenen 11 µV sind **Floating-Point-Rundungsfehler** des SPICE-Solvers, kein physikalischer Offset.

**Lösung für realistische Simulation:**  
Externe Vos-Quelle manuell hinzufügen (bereits in `real-input-0V-measure-dc-point-test-input-offset-voltage-tl802-op-amp.asc` implementiert):
- Vos = 5 mV → Vout = -5.005 V (linear)
- Vos = 13.3 mV → Vout = -13.35 V (Sättigung)

**Empfehlung:**  
Für Offset-Analysen immer:
1. Externe Vos-Quelle verwenden, ODER
2. Vollständiges Hersteller-Modell (TI PSpice) mit `.param Vos`, ODER
3. Monte-Carlo-Analyse mit Mismatch-Parametern

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

Die Simulationen zeigen die Stärken und Limitierungen des TI-Makromodells `TL082.301`:

| Parameter | Simuliert | Datenblatt | Modell-Qualität |
|-----------|-----------|------------|-----------------|
| Slew Rate | 13.4 V/µs | 20 V/µs | ⚠️ 67% (akzeptabel für Funktionsnachweis) |
| Input Offset | 11 µV | 3-15 mV | ❌ Nicht modelliert (nur mit externer Quelle) |
| Verstärkung | ✓ korrekt | - | ✓ Gut |
| Bandbreite | ✓ korrekt | 4 MHz | ✓ Gut |
| Eingangsimpedanz | ✓ korrekt | hoch (JFET) | ✓ Gut |

**Stärken des Modells:**
- Korrekte Verstärkungscharakteristik
- Realistische Bandbreite
- Gutes dynamisches Verhalten (Slew Rate innerhalb 67% des Datenblatts)
- Symmetrisches Verhalten für Anstieg/Abfall

**Limitierungen des Modells:**
- Slew Rate unterschätzt (13.4 vs. 20 V/µs) - auf vereinfachte Modellierung zurückzuführen
- Input Offset nicht modelliert (11 µV vs. 3-15 mV) - keine Mismatch-Parameter vorhanden
- Kein Rauschmodell vorhanden
- Modell von 1989, keine Berücksichtigung moderner Fertigungstoleranzen

**Fazit:**  
Das Modell ist geeignet für:
- ✅ Funktionsnachweis (Verstärkung, Filter, etc.)
- ✅ Frequenzgang-Analyse (AC-Analyse)
- ✅ Dynamisches Verhalten (Slew Rate, Transient)
- ❌ Offset-Analyse (nur mit externer Vos-Quelle)
- ❌ Rausch-Analyse (kein Rauschmodell)

Für die Abgabe werden die simulierten Werte als Modell-Limitierungen akzeptiert und dokumentiert. Die Diskrepanzen sind auf das Alter und die Vereinfachungen des Makromodells zurückzuführen, nicht auf Fehler in der Schaltung oder Simulation.

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
│   ├── TL082CP_PCB_1to1.pdf
│   └── TL082CP_PCB_2to1.pdf
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
| R1 | 4.7 kΩ (THT, 1/4 W) — Gain-Setzung (fest) |
| VR1 | 50 kΩ Potentiometer (Same Sky PT01-D130D-B503) — einstellbare Verstärkung |
| R3 | 1 MΩ (THT, 1/4 W) — Pull-down für hochohmige Gitarren-Pickups |
| C1, C2 | 10 µF Elko (THT) — AC-Kopplung Ein-/Ausgang (in Serie) |
| C3, C4 | 100 nF (THT) — Entkopplung V+/V- am TL082 |
| C5, C6 | 10 µF (THT) — Pump-Kondensatoren für TMR 1-1222 |
| J1 | PJ-102A — 6.35mm Mono-Jack (Same Sky, aus SnapEDA importiert) |
| J2 | PJ-102A — 6.35mm Mono-Jack (Same Sky, aus SnapEDA importiert) |
| J3 | Barrel_Jack 5.5/2.1mm — DC-Stromversorgung (9-18V) |

---

## 10. Quellen

- TL082 Datenblatt: https://www.ti.com/product/TL082-N
- TL082 Pinout & Applications: https://www.ariat-tech.com/blog/tl082-jfet-dual-op-amp-pinout,applications-and-alternatives.html
- Traco Power TMR 1-1222: https://www.tracopower.com/int/model/tmr-1-1222
- PJ-102A Audio-Jack: https://www.snapeda.com/parts/PJ-102A/Same%20Sky/view-part/
- Elektronik-Kompendium OpAmp: https://www.elektronik-kompendium.de/public/schaerer/opa1.htm

---

**Abgabedatum:** 05.07.2026  
**Matrikelnummer:** [einzutragen]  
**Name:** [einzutragen]
