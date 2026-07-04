# Idee: TL082CP Gitarren-Pedal (Audio-Vorverstärker)

## Konzept

Nicht-invertierender Audio-Vorverstärker für E-Gitarre mit **einstellbarer Verstärkung**.  
Versorgung über 9-18V DC Steckernetzteil → TMR 1-1222 → ±12V für TL082.  
**Gain einstellbar** über Potentiometer VR1 (50kΩ) als Feedback-Widerstand R2.

---

## ASCII-Schaltplan

```
┌─────────────────────────────────────────────────────────────────────┐
│                        TL082CP GUITAR PEDAL                         │
└─────────────────────────────────────────────────────────────────────┘

STROMVERSORGUNG:
════════════════

    DC-Jack (9-18V)
         │
         ├──── Tip (+9-18V) ────┐
         │                      │
         └──── Sleeve (GND) ────┤
                                │
                          ┌─────┴─────┐
                          │ TMR 1-1222│
                          │  (SIP-6)  │
                          └─────┬─────┘
                                │
              ┌─────────────────┼─────────────────┐
              │                 │                 │
           +12V               GND              -12V
              │                 │                 │
              │                 │                 │
         ┌────┴────┐       ┌────┴────┐       ┌────┴────┐
         │  C5     │       │         │       │  C6     │
         │  10µF   │       │         │       │  10µF   │
         └────┬────┘       └────┬────┘       └────┬────┘
              │                 │                 │
              └─────────────────┼─────────────────┘
                                │
                               GND


AUDIO-SIGNALWEG:
════════════════

    Gitarre
       │
       │
    ┌──┴──┐
    │ J1  │  PJ-102A (6.35mm Mono-Jack)
    │ IN  │
    └──┬──┘
       │
       ├── C1 (10µF) ────┬──── TL082 Pin 3 (Non-inv. Input A)
       │                  │
       │              R3 (1MΩ)
       │                  │
       │                 GND (Bias-Referenz)
       │
                        ┌────┴────┐
                        │  TL082  │
                        │  (U1)   │
                        │ PDIP-8  │
                        └────┬────┘
                             │
       ┌─────────────────────┼─────────────────────┐
       │                     │                     │
  Pin 1 (Output A)      Pin 8 (V+)            Pin 4 (V-)
       │                     │                     │
       │                  +12V                  -12V
       │
       └──── VR1 (50kΩ) ────┬──── Pin 2 (Inv. Input A)
        (Gain Poti)          │
                        R1 (4.7kΩ)
                             │
                            GND
       
       │
       └──── C2 (10µF) ────┬──── J2 (PJ-102A)
                              │
                           Verstärker/Amp


ENTKOPPLUNG:
════════════

    +12V ────┬──── C3 (100nF) ──── GND
             │
             └──── TL082 Pin 8
    
    -12V ────┬──── C4 (100nF) ──── GND
             │
             └──── TL082 Pin 4
```

---

## Bauteilliste (BOM)

| Ref | Bauteil | Wert | Footprint | KiCad Symbol | Menge |
|-----|---------|------|-----------|--------------|-------|
| U1 | TL082CP | Dual Op-Amp | `Package_DIP:DIP-8_W7.62mm` | `Amplifier_Operational:TL082` | 1 |
| U2 | TMR 1-1222 | DC-DC 9-18V → ±12V | `Converter_DCDC:Traco_TMR1_SIP` | Benutzerdefiniert | 1 |
| R1 | Widerstand | 4.7 kΩ | `Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal` | `Device:R` | 1 |
| VR1 | Potentiometer | 50 kΩ | Benutzerdefiniert (Same Sky PT01-D130D-B503) | `Device:R_POT` | 1 |
| R3 | Widerstand | 1 MΩ | `Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal` | `Device:R` | 1 |
| C1 | Elko | 10 µF | `Capacitor_THT:CP_Radial_D5.0mm_P2.50mm` | `Device:CP` | 1 | AC-Kopplung Eingang (in Serie) |
| C2 | Elko | 10 µF | `Capacitor_THT:CP_Radial_D5.0mm_P2.50mm` | `Device:CP` | 1 | AC-Kopplung Ausgang (in Serie) |
| C3 | Keramik | 100 nF | `Capacitor_THT:C_Disc_D3.0mm_W1.6mm_P2.50mm` | `Device:C` | 1 |
| C4 | Keramik | 100 nF | `Capacitor_THT:C_Disc_D3.0mm_W1.6mm_P2.50mm` | `Device:C` | 1 |
| C5 | Elko | 10 µF | `Capacitor_THT:CP_Radial_D5.0mm_P2.50mm` | `Device:CP` | 1 |
| C6 | Elko | 10 µF | `Capacitor_THT:CP_Radial_D5.0mm_P2.50mm` | `Device:CP` | 1 |
| J1 | Audio-Jack | 6.35mm Mono | PJ-102A (aus SnapEDA importiert, Same Sky) | `Connector_Audio:AudioJack2Switch` | 1 |
| J2 | Audio-Jack | 6.35mm Mono | PJ-102A (aus SnapEDA importiert, Same Sky) | `Connector_Audio:AudioJack2Switch` | 1 |
| J3 | DC-Jack | 5.5/2.1mm | `Connector:BarrelJack_Horizontal` | `Connector:Barrel_Jack` | 1 |

---

## Verstärkung

```
Gain = 1 + (VR1 / R1)

VR1 einstellbar von 0 bis 50 kΩ:
  VR1 = 0 Ω     → Gain = 1    (0 dB, Unity)
  VR1 = 4.7 kΩ  → Gain = 2    (6 dB)
  VR1 = 25 kΩ   → Gain = 6.3  (16 dB)
  VR1 = 50 kΩ   → Gain = 11.6 (21.3 dB)

Silkscreen-Beschriftung: "GAIN  0 dB - 21 dB"  (oder "1× - 12×")

Warum nicht Gain 1-51?
  Passive Gitarre: 100-500 mV Peak (typisch 300 mV)
  Bei Gain 51 und 300 mV Input: 15.3 V Output → Clipping bei ±12V Versorgung
  Bei Gain 11.6 und 300 mV Input: 3.5 V Output → kein Clipping, mehr Reserve
  
  Gain 1-11.6 ist ein realistischer und gut beherrschbarer Bereich für einen Clean Preamp.

Beispiel bei Gain = 10:
  Gitarre: 100 mVpp → Output: 1 Vpp
  Gitarre: 300 mVpp → Output: 3 Vpp
```

---

## KiCad-Implementierung

### Symbole aus Bibliotheken:
- TL082: `Amplifier_Operational:TL082`
- Widerstände: `Device:R`
- Potentiometer: `Device:R_POT` (aus SnapEDA importiert: Same Sky PT01-D130D-B503)
- Kondensatoren: `Device:CP` (Elko), `Device:C` (Keramik)
- Audio-Jack: `Connector_Audio:AudioJack2Switch`
- Barrel-Jack: `Connector:Barrel_Jack`
- TMR 1-1222: Benutzerdefiniertes Symbol erstellen

### Footprints:
- TL082CP: `Package_DIP:DIP-8_W7.62mm`
- TMR 1-1222: Benutzerdefinierter Footprint (SIP-6, 17 x 7.62 mm)
- Potentiometer VR1: Same Sky PT01-D130D-B503 (aus SnapEDA importiert)
- Audio-Jacks: PJ-102A (aus SnapEDA importiert, Same Sky)
- Barrel-Jack: `Connector:BarrelJack_Horizontal`

---

## Nächste Schritte

1. ✅ TMR 1-1222 Symbol und Footprint erstellen
2. ✅ PJ-102A Footprint erstellen
3. ✅ Schaltplan in KiCad zeichnen
4. ✅ PCB Layout erstellen
5. ✅ Gerber-Files exportieren
6. ✅ OpenSCAD Halterung anpassen
