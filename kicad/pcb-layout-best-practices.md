# PCB Layout Best Practices - TL082 Audio Preamp

## 1. Bauteilplatzierung

### Prinzip
- **TL082 zentral** platzieren für kurze Signalwege
- **Audio-Jacks** an den Rändern für einfache Gehäusmontage
- **DC-Jack** und **TMR 1-1222** zusammen auf einer Seite (Stromversorgung)
- **Widerstände und Kondensatoren** nah am TL082 (<10mm)

### Platzierungsreihenfolge
1. Audio-Jacks (J1, J2) - links und rechts
2. TL082 (U1) - zentral
3. DC-Jack (J3) - oben oder unten
4. TMR 1-1222 (U2) - nahe DC-Jack
5. Entkopplungskondensatoren (C3, C4) - direkt an TL082
6. Gain-Widerstände (R1, VR1) - nah an TL082 Pin 1-2
7. Koppelkondensatoren (C1, C2) - nahe Audio-Jacks

## 2. Routing Prioritäten

### Prioritätsreihenfolge
1. **Audio-Signalwege** - kürzeste Wege, keine Kreuzungen mit Stromleitungen
2. **Stromversorgung** - breite Leiterbahnen für ±12V
3. **GND** - Ground Plane oder breite Ground-Traces
4. **Entkopplung** - C3, C4 (100nF) direkt an TL082 V+/V- Pins

### Audio-Signalweg
```
J1 (Input) → C1 (10µF) → TL082 Pin 3 → TL082 Pin 1 → C2 (10µF) → J2 (Output)
```
- **Kurz halten** (<50mm ideal)
- **Nicht parallel** zu Stromleitungen führen
- **Keine Vias** im Audio-Signalweg wenn möglich

## 3. Ground Design

### Ground Topologie
- **Sternpunkt-Masse** oder **Ground Plane** verwenden
- **Analog Ground** und **Power Ground** trennen (falls nötig)
- **Ground Loops vermeiden** - alle GND-Verbindungen zu einem Punkt

### Ground-Verbindungen
- TL082 Pin 4 (V-) → GND
- R1 (1kΩ) → GND
- C1, C2 (negative Seite) → GND
- C3, C4 → GND (nah an TL082)
- Audio-Jacks (Sleeve) → GND
- DC-Jack (Sleeve) → GND

## 4. Stromversorgung Routing

### Leiterbahn-Breiten
- **Signalwege**: 0.2-0.3mm (8-12mil)
- **Stromversorgung (±12V)**: 0.5-1.0mm (20-40mil)
- **GND**: 0.5mm oder Ground Plane

### Entkopplung
- **C3 (100nF)**: Zwischen V+ (Pin 8) und GND, <5mm Abstand
- **C4 (100nF)**: Zwischen V- (Pin 4) und GND, <5mm Abstand
- **C5, C6 (10µF)**: Nahe TMR 1-1222 Ausgang

### TMR 1-1222
- **Input**: 9-18V vom DC-Jack
- **Output**: ±12V zum TL082
- **GND**: Gemeinsame Masse

## 5. Thermische considerations

### TMR 1-1222
- Erzeugt etwas Wärme (1W Leistung)
- **Abstand** zu empfindlichen Bauteilen (>5mm)
- **Keine** heißen Bauteile nahe TL082

### Allgemeine thermische Regeln
- **Keine** Bauteile direkt übereinander (wenn möglich)
- **Luftzirkulation** ermöglichen
- **Kupferflächen** zur Wärmeableitung nutzen

## 6. KiCad Layout Schritte

### Schritt 1: Footprints platzieren
1. Alle Footprints auf PCB importieren
2. Gemäß Platzierungsplan anordnen
3. **Ratsnest** zeigt noch unverbindliche Luftdrähte

### Schritt 2: Board Outline definieren
1. Layer: **Edge.Cuts**
2. Geschlossenen Umriss zeichnen
3. **DRC prüfen** - keine offenen Ecken

### Schritt 3: Routing
1. **Route Tracks** (X-Taste)
2. Erst Audio-Signalwege
3. Dann Stromversorgung
4. Zuletzt GND
5. **Vias** nur wenn nötig (Layer-Wechsel)

### Schritt 4: DRC prüfen
1. **Inspect → DRC**
2. Alle Fehler beheben
3. **0 violations** erreichen

### Schritt 5: Gerber exportieren
1. **File → Fabrication Outputs → Gerbers**
2. Alle Layer auswählen
3. **Drill Files** exportieren
4. In `gerber/` Ordner speichern

## 7. Design Rules (KiCad)

### Empfohlene Einstellungen
- **Minimum Trace Width**: 0.2mm (8mil)
- **Minimum Clearance**: 0.2mm (8mil)
- **Minimum Via Diameter**: 0.6mm (24mil)
- **Minimum Drill Size**: 0.3mm (12mil)

### Audio-spezifisch
- **Differential Pairs**: Nicht nötig (single-ended Audio)
- **Impedance Control**: Nicht kritisch bei Audio-Frequenzen
- **Length Matching**: Nicht nötig

## 8. Häufige Fehler vermeiden

### ❌ Vermeiden
- Lange parallele Leiterbahnen (Crosstalk)
- 90° Winkel in Leiterbahnen (Reflexionen)
- Ground Loops
- Unentkoppelte ICs
- Zu dünne Stromversorgungs-Leiterbahnen

### ✅ Machen
- Kurze, direkte Signalwege
- 45° oder runde Winkel
- Sternpunkt-Masse
- Entkopplungskondensatoren nah an ICs
- Breite Stromversorgungs-Leiterbahnen

## 9. 3D View und mechanische Checks

### Vor Gerber-Export prüfen
1. **3D View** (Alt+3)
2. Alle Bauteile sichtbar?
3. Keine Kollisionen?
4. Audio-Jacks zugänglich?
5. DC-Jack erreichbar?

### Maße prüfen
- **PCB-Größe**: ca. 50x30mm (kompakt)
- **Bohrungen**: 3.2mm für M3 Schrauben (falls Halterung)
- **Randabstand**: min. 2mm zu Bauteilen

## 10. Zusammenfassung

### Kritische Punkte für Audio Preamp
1. **Kurze Audio-Signalwege**
2. **Gute Entkopplung** (C3, C4 nah an TL082)
3. **Sauberer Ground** (keine Loops)
4. **Breite Stromversorgungs-Leiterbahnen**
5. **Keine Crosstalk** (Audio nicht parallel zu Power)

### Nach dem Layout
- ✅ DRC: 0 violations
- ✅ 3D View: alle Bauteile sichtbar
- ✅ Gerber exportiert
- ✅ Drill Files exportiert
- ✅ In ZIP-File gepackt

---

**Quellen:**
- TL082 Datenblatt (Layout Guidelines)
- TMR 1-1222 Datasheet
- KiCad Dokumentation
- Allgemeine PCB Design Best Practices
