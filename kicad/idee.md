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
    │ J1  │  Neutrik NMJ4HCD2 (6.35mm Mono-Jack)
    │ IN  │
    └──┬──┘
       │
       ├──── R3 (1MΩ) ──── GND  (Pull-down für hochohmige Pickups)
       │
       └──── C1 (10µF) ────┬──── TL082 Pin 3 (Non-inv. Input A)
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
                        R1 (1kΩ)
                             │
                            GND
       
       │
       └──── C2 (10µF) ────┬──── J2 (Neutrik NMJ4HCD2)
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
| R1 | Widerstand | 1 kΩ | `Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal` | `Device:R` | 1 |
| VR1 | Potentiometer | 50 kΩ | Benutzerdefiniert (Same Sky PT01-D130D-B503) | `Device:R_POT` | 1 |
| R3 | Widerstand | 1 MΩ | `Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P7.62mm_Horizontal` | `Device:R` | 1 |
| C1 | Elko | 10 µF | `Capacitor_THT:CP_Radial_D5.0mm_P2.50mm` | `Device:CP` | 1 |
| C2 | Elko | 10 µF | `Capacitor_THT:CP_Radial_D5.0mm_P2.50mm` | `Device:CP` | 1 |
| C3 | Keramik | 100 nF | `Capacitor_THT:C_Disc_D3.0mm_W1.6mm_P2.50mm` | `Device:C` | 1 |
| C4 | Keramik | 100 nF | `Capacitor_THT:C_Disc_D3.0mm_W1.6mm_P2.50mm` | `Device:C` | 1 |
| C5 | Elko | 10 µF | `Capacitor_THT:CP_Radial_D5.0mm_P2.50mm` | `Device:CP` | 1 |
| C6 | Elko | 10 µF | `Capacitor_THT:CP_Radial_D5.0mm_P2.50mm` | `Device:CP` | 1 |
| J1 | Audio-Jack | 6.35mm Mono | `Connector_Audio:Neutrik_NMJ4HCD2` | `Connector_Audio:AudioJack2Switch` | 1 |
| J2 | Audio-Jack | 6.35mm Mono | `Connector_Audio:Neutrik_NMJ4HCD2` | `Connector_Audio:AudioJack2Switch` | 1 |
| J3 | DC-Jack | 5.5/2.1mm | `Connector:BarrelJack_Horizontal` | `Connector:Barrel_Jack` | 1 |

---

## Verstärkung

```
Gain = 1 + (VR1 / R1)

VR1 einstellbar von 0 bis 50 kΩ:
  VR1 = 0 Ω    → Gain = 1   (Unity)
  VR1 = 9 kΩ   → Gain = 10  (20 dB)
  VR1 = 50 kΩ  → Gain = 51  (~34 dB)

Beispiel bei Gain = 10:
  Gitarre: 100 mVpp → Output: 1 Vpp
  Gitarre: 200 mVpp → Output: 2 Vpp
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
- Audio-Jacks: `Connector_Audio:Neutrik_NMJ4HCD2` (benutzerdefiniert)
- Barrel-Jack: `Connector:BarrelJack_Horizontal`

---

## Nächste Schritte

1. ✅ TMR 1-1222 Symbol und Footprint erstellen
2. ✅ Neutrik NMJ4HCD2 Footprint erstellen
3. ✅ Schaltplan in KiCad zeichnen
4. ✅ PCB Layout erstellen
5. ✅ Gerber-Files exportieren
6. ✅ OpenSCAD Halterung anpassen
