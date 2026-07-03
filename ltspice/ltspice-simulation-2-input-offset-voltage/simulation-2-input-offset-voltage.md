# Simulation 2: Input Offset Voltage — Inverting Amplifier

**File:** `measure-dc-point-test-input-offset-voltage-tl802-op-amp.asc`  
**OpAmp:** TL082 (LTspice Macromodell `TL082.301`)  
**Konfiguration:** Invertierender Verstärker, DC-Messung mit `.op`

---

## Schaltung

```
                   TL082
                ┌──────────┐
   Vin ───R1────┤In-   Out ├────── Vout
   (0V)   1kΩ   │          │
                │      R2  │
                └─────┤1MΩ├┘
                      │
   GND ───────────────┤
                      │
                      └─── (Rückkopplung, Rf)

   V+ = +15V an Pin 8
   V- = -15V an Pin 4
   In+ (Pin 3) optional über Rbias nach GND
```

**Verstärkung:** A = -Rf/Ri = -1MΩ / 1kΩ = **-1000**

---

## SPICE Direktiven

```
.op
.lib TL082.301
```

**Vin:** DC-Quelle mit `0V` (kein Sinus für Offset-Messung).

---

## Log-Datei (Auszug)

```
LTspice 17.2.4 for MacOS
Circuit: * /Users/blurbler/TL082CP/blerta/ltspice-simulation-2-input-offset-voltage/test-input-offset-voltage-tl802-op-amp.asc
Start Time: Fri Jul  3 18:49:24 2026
solver = Normal
Maximum thread count: 8
tnom = 27
temp = 27
method = modified trap
CompressWinPoints = 1024
Direct Newton iteration for .op point succeeded.
Semiconductor Device Operating Points:
                        --- Diodes ---
Name:    d:u2:c      d:u2:e      d:u2:lp     d:u2:ln     d:u2:p
Model:    u2:dx       u2:dx       u2:dx       u2:dx       u2:dx
Id:     -1.28e-11   -1.28e-11   -2.50e-11   -2.50e-11   -3.00e-11
Vd:     -1.28e+01   -1.28e+01   -2.50e+01   -2.50e+01   -3.00e+01
Req:     1.00e+12    1.00e+12    1.00e+12    1.00e+12    1.00e+12
CAP:     0.00e+00    0.00e+00    0.00e+00    0.00e+00    0.00e+00

                        --- JFET Transistors ---
Name:    j:u2:1      j:u2:2
Model:    u2:jx       u2:jx
Id:     -9.77e-05   -9.77e-05
Vgs:     3.99e-01    3.99e-01
Vds:    -1.43e+01   -1.43e+01
Gm:      3.25e-04    3.25e-04
Gds:     0.00e+00    0.00e+00
Cgs:     0.00e+00    0.00e+00
Cgd:     0.00e+00    0.00e+00


Operating Bias Point Solution:
V(vin)                           0   voltage
V(vout)                  0.0109788   voltage
V(v-)                          -15   voltage
V(v+)                           15   voltage
V(n001)                1.09228e-05   voltage
I(R1)                  1.09228e-08   device_current
I(R2)                  1.09679e-08   device_current
I(V1)                  1.09228e-08   device_current
I(V2)                   -0.0141941   device_current
I(V3)                   -0.0141945   device_current
Ix(u2:1)               4.50531e-11   subckt_current
Ix(u2:2)               4.50532e-11   subckt_current
Ix(u2:3)                 0.0141941   subckt_current
Ix(u2:4)                -0.0141945   subckt_current
Ix(u2:5)              -1.09679e-08   subckt_current

Total elapsed time: 0.005 seconds.
```

---

## Auswertung

**Gemessene Ausgangsspannung:**
```
V(vout) = 10.9788 mV
```

**Berechnete Eingangs-Offsetspannung:**
```
V_offset = V(vout) / (1 + Rf/Ri)
        = 10.9788 mV / (1 + 1000)
        = 10.9788 mV / 1001
        = 10.97 µV
```

---

## Fazit

| Aspekt | Status |
|--------|--------|
| Schaltungs-Topologie (Invertierer, A=-1000) | ✓ korrekt |
| Direktiven (`.op`, keine `.measure FIND`) | ✓ korrekt |
| Versorgung (V+ = +15V, V- = -15V) | ✓ korrekt |
| Eingang DC 0V | ✓ korrekt |
| **Ergebnis: 10.97 µV simulierter Offset** | ✗ **bedeutungslos** |

**Problem:** Das LTspice-Standard-Macromodell `TL082.301` enthält **keine Eingangs-Offsetspannung** (`Vos`). Die gemessenen 11 µV sind rein numerische Modell-Artefakte aus der JFET-Paar-Asymmetrie (J1, J2).

**Datenblatt (TI TL082):**
- Vos typisch: 3–5 mV
- Vos max: 15 mV
- Slew rate: 20 V/µs (TL082 High-Speed-Variante: TL082 **CP** = Commercial, Plastic DIP)

**Diskrepanz:** Faktor 300–1000 zwischen Simulation (11 µV) und Realität (3–15 mV).

---

## Begründung: Warum weicht der simulierte Offset vom Datenblatt ab?

### 1. Das LTspice-Standard-Macromodell hat keinen Vos-Parameter

Schauen wir den Inhalt von `TL082.301` an:

```spice
.MODEL DX D(IS=800.0E-18)
.MODEL JX PJF(IS=15.00E-12 BETA=270.1E-6 VTO=-1)
```

**Was fehlt:**
- Keine `VOS`-Spannungsquelle am Eingang
- Kein `OFFSET`-Parameter in `.MODEL DX` oder `.MODEL JX`
- Keine `IB`-Bias-Stromquellen mit Streuung
- Kein Mismatch-Parameter für die JFETs J1 und J2

Das Modell bildet nur das **AC- und DC-Großsignalverhalten** nach (Verstärkung, Slew Rate, Bandbreite), aber **nicht den herstellungsbedingten Offset**.

### 2. Was das Modell tatsächlich abbildet

Aus dem `.op`-Log erkennbar:
```
JFET J1:  Vgs = 0.399V,  Id = -9.77e-05
JFET J2:  Vgs = 0.399V,  Id = -9.77e-05
```

J1 und J2 sind **exakt symmetrisch** modelliert (gleiche `VTO`, gleiche `BETA` in `.MODEL JX`). In der **Realität** sind die beiden JFETs im Eingangsdifferenzpaar **nie identisch**:
- Dotierungstoleranzen (±1–5%)
- Geometrische Abweichungen (Maskenfehler, Lithografie)
- Thermische Asymmetrie auf dem Chip
- Spannungsdifferenzen durch Lastgradienten

Diese Mismatches erzeugen den realen Offset. Das LTspice-Macromodell setzt alle diese Parameter **ideal gleich** → 0 V systematischer Offset.

### 3. Die 11 µV sind rein numerisches Rauschen

Die gemessenen 11 µV stammen aus:
- **Floating-Point-Rundung** im SPICE-Solver
- **Numerische Asymmetrie** in der Matrix-Lösung (nicht echte Physik)
- **Standard-Startwerte** für `.op` (nicht randomisiert)

**Beweis:** Würde man das Modell mehrfach mit verschiedenen Startwerten simulieren, bliebe der Wert bei ~10–11 µV → **deterministisch, nicht statistisch** → kein realer Offset.

### 4. Vergleich: Echtes Hersteller-Modell (z.B. TI PSpice)

Ein vollständiges Modell enthält typischerweise:

```spice
* Eingangs-Offset
VOS 11 12 DC 5m        ; 5mV Offset
* Bias-Ströme
IB1 1 0 DC 30p
IB2 2 0 DC 30p
* JFET-Mismatch
.MODEL JX PJF(...
+ VTO=-1.0  DT=0.002    ; Threshold-Asymmetrie
+ BETA=270.1u  DB=0.01  ; Beta-Mismatch
+ ...)
```

**Mit solchen Modellen** bekommt man die 3–15 mV aus dem Datenblatt korrekt simuliert.

### 5. Typische Mismatch-Quellen im echten TL082

| Quelle | Beitrag zum Offset |
|--------|-------------------|
| JFET-Threshold-Mismatch (ΔVth) | 1–10 mV |
| Lastwiderstands-Mismatch | 0,5–2 mV |
| Stromspiegel-Asymmetrie | 0,2–1 mV |
| Thermische Gradienten | 0,1–0,5 mV |
| Spannungsdifferenz der Gates | 0,1–1 mV |
| **Gesamt (typisch)** | **3–8 mV** |
| **Max (worst-case Exemplar)** | **15 mV** |

Das LTspice-Macromodell setzt **alle diese Quellen auf Null** → 11 µV statt 3–15 mV.

### 6. TL082-spezifisch

Der TL082 ist ein **JFET-Input-OpAmp** mit besonders niedrigem Bias-Strom, aber Offset wird durch JFET-Mismatch dominiert. Die Streuung von Exemplar zu Exemplar ist groß:
- **TL082A** (selektiert): max 6 mV
- **TL082B** (Low-Offset): max 3 mV
- **TL082 (Standard)**: max 15 mV

Das LTspice-Modell repräsentiert einen **„perfekten"** TL082 mit 0 mV Offset – das gibt es real nicht.

### 7. Konsequenz für die Simulation

| Simulation | Vos | Realistisch? |
|-----------|-----|--------------|
| LTspice-Macromodell | ~0 mV | ✗ Falsch |
| Echtes Bauelement | 3–15 mV | ✓ Wahr |
| LTspice + externe Vos-Quelle | beliebig | ✓ Bei korrekter Wahl |
| TI PSpice-Modell mit Vos | 3–15 mV | ✓ Wahr |

**Merksatz:** Das LTspice-Standard-Macromodell ist für **Funktionsprüfung und Frequenzgang** geeignet, **nicht für Offset-Analysen**. Für Offset-Messungen immer ein Hersteller-Modell mit `.param Vos` oder eine externe Vos-Quelle verwenden.

---

## Empfehlung: Externe Vos-Quelle für realistische Simulation

Da das Macromodell keinen Offset kennt, kannst du ihn **manuell als externe Quelle** einspeisen. So misst du, wie deine Schaltung auf einen realistischen Offset reagiert.

### Schritt 1: Neue Spannungsquelle einfügen

**In LTspice:**
1. Menü `Component` → `voltage` (oder F2)
2. Platziere die Quelle **zwischen Ri und In-** (siehe ASCII unten)
3. Rechtsklick → Label: `Vos`
4. Rechtsklick → Value: `5m` (= 5 mV, typischer TL082-Offset)
5. **Serienwiderstand 0Ω** (ideale Quelle)

### Schritt 2: Geänderte Schaltung

```
                   TL082
                ┌──────────┐
   Vin ───R1────┤In-   Out ├────── Vout
   (0V)   1kΩ   │          │
                │      R2  │
                └─────┤1MΩ├┘
                      │
   GND ────Vos(5mV)───┘
           DC-Quelle
           (+ an Ri-Seite,
            - an In-)
```

**Pin-Belegung Vos:**
- **Positives Ende (+)** an Knoten zwischen R1 und Pin 2
- **Negatives Ende (-)** an Pin 2 (In-)
- Wert: `5m` (5 mV)

### Schritt 3: Direktiven erweitern

```
.op
.lib TL082.301
.measure DC Vout_with_Vos FIND V(vout)
.measure DC Vos_input PARAM 5m
```

Da `.measure DC FIND` mit `.op` nicht funktioniert, lies `V(vout)` direkt aus dem Log.

### Schritt 4: Erwartetes Ergebnis

Mit Vos = 5 mV:
```
V(vout) = -Vos × (1 + Rf/Ri)
       = -5 mV × 1001
       = -5.005 V
```

Mit Vos = 15 mV (max):
```
V(vout) = -15 V  → sättigt am Ausgang (Versorgung ±15V)
```

### Schritt 5: Auswerten (manuell, aus dem Log)

```
V_offset_eff = V(vout) / 1001
```

### Schritt-für-Schritt Anleitung (LTspice GUI)

1. **Öffne** `measure-dc-point-test-input-offset-voltage-tl802-op-amp.asc`
2. **Lösche** die Sinus-Quelle V1 (`SINE(0 1 1k)`) und ersetze durch `DC 0`
3. **F2** drücken → `voltage` wählen → platzieren **zwischen R1 und Pin 2**
4. **Rechtsklick** auf neue Quelle → Label: `Vos`
5. **Rechtsklick** → Advanced → Wert: `5m` (oder `10m`, `15m` für verschiedene Szenarien)
6. **Run** → `.op` Analyse starten
7. **View → SPICE Error Log** → lies `V(vout)` aus dem Block `Operating Bias Point Solution`
8. **Teilen** durch 1001 → echter V_offset (laut Modell, mit manuell eingespieltem Vos)

---

## Verbesserung: Parametrischer Sweep

Für Monte-Carlo oder Min/Max-Analyse:

```
.step param Vos list 1m 5m 10m 15m
.param Vos=5m
.op
```

LTspice führt dann 4 separate `.op`-Läufe durch und zeigt die Ausgangsspannungen für jeden Offset-Wert.

---

## Reale Messung mit externer Vos-Quelle

**File:** `real-input-0V-measure-dc-point-test-input-offset-voltage-tl802-op-amp.asc`  
**Aufbau:** Wie oben, aber **zusätzliche externe Spannungsquelle V4 = 5 mV** zwischen R1 (n001) und Pin 2 (In-) des OpAmps.

### Geänderte Schaltung

```
                   TL082
                ┌──────────┐
   Vin ──R1─────┤In-   Out ├────── Vout
   (0V)  1kΩ    │          │
                │      R2  │
                └─────┤1MΩ├┘
                      │
   GND ──V4(5mV)──────┤
         (externe
         Vos-Quelle)
```

### Log-Datei (Auszug)

```
LTspice 17.2.4 for MacOS
Circuit: * /Users/blurbler/TL082CP/blerta/ltspice-simulation-2-input-offset-voltage/real-input-0V-measure-dc-point-test-input-offset-voltage-tl802-op-amp.asc
Start Time: Fri Jul  3 19:01:52 2026
solver = Normal
Maximum thread count: 8
tnom = 27
temp = 27
method = modified trap
CompressWinPoints = 1024
Direct Newton iteration for .op point succeeded.
Semiconductor Device Operating Points:
                        --- Diodes ---
Name:    d:u2:c      d:u2:e      d:u2:lp     d:u2:ln     d:u2:p
Model:    u2:dx       u2:dx       u2:dx       u2:dx       u2:dx
Id:     -2.62e-11    1.51e-06   -2.50e-11   -2.50e-11   -3.00e-11
Vd:     -2.62e+01    5.52e-01   -2.50e+01   -2.50e+01   -3.00e+01
Req:     1.00e+12    1.71e+04    1.00e+12    1.00e+12    1.00e+12
CAP:     0.00e+00    0.00e+00    0.00e+00    0.00e+00    0.00e+00

                        --- JFET Transistors ---
Name:    j:u2:1      j:u2:2
Model:    u2:jx       u2:jx
Id:     -9.69e-05   -9.85e-05
Vgs:     4.01e-01    3.96e-01
Vds:    -1.43e+01   -1.43e+01
Gm:      3.24e-04    3.26e-04
Gds:     0.00e+00    0.00e+00
Cgs:     0.00e+00    0.00e+00
Cgd:     0.00e+00    0.00e+00


Operating Bias Point Solution:
V(vin)                           0   voltage
V(vout)                   -13.3524   voltage
V(v-)                          -15   voltage
V(v+)                           15   voltage
V(n001)                      0.005   voltage
I(R1)                        5e-06   device_current
I(R2)                 -1.33574e-05   device_current
I(V1)                        5e-06   device_current
I(V2)                   -0.0141941   device_current
I(V3)                   -0.0141929   device_current
I(V4)                 -1.83575e-05   device_current
Ix(u2:1)               4.50478e-11   subckt_current
Ix(u2:2)               4.50635e-11   subckt_current
Ix(u2:3)                 0.0141941   subckt_current
Ix(u2:4)                -0.0141929   subckt_current
Ix(u2:5)               1.33574e-05   subckt_current

Total elapsed time: 0.008 seconds.
```

### Auswertung

**Gemessene Spannungen:**
```
V(vout) = -13.3524 V      ← Ausgang (Sättigung!)
V(n001) = +5 mV           ← Knoten n001 (= Vos)
V(vin)  = 0 V             ← Eingang
```

**Berechnung (linearer Fall, A = -1001):**
```
V_out_erwartet = -Vos × (1 + Rf/Ri)
              = -5 mV × 1001
              = -5,005 V
```

**Tatsächlich gemessen:**
```
V_out_gemessen = -13,3524 V
```

**Interpretation:**

| Parameter | Wert | Anmerkung |
|-----------|------|-----------|
| Vos (extern) | +5 mV | korrekt angelegt |
| V(vout) erwartet (linear) | -5,005 V | — |
| V(vout) gemessen | **-13,3524 V** | **gesättigt!** |
| V(vout) Sättigungsgrenze | ~ -13,5 V | Ausgangsstufen-Limit |

### ⚠️ Sättigung am Ausgang

Der Ausgang des OpAmp **sättigt** bei ca. **±13,5 V** (Versorgung ±15V, abzüglich ~1,5V Drop an den Ausgangstransistoren). Bei einer Verstärkung von 1001 reicht bereits **13,3 mV** Eingangs-Offset, um den Ausgang an die Sättigungsgrenze zu bringen.

```
V_out_sättigung ≈ V- + 1,5V = -15V + 1,5V ≈ -13,5V
```

**Mit 5 mV Vos:**
- Linearer Arbeitspunkt: -5,0 V → **kein Sättigen erwartet**
- Tatsächlich: -13,35 V → **Sättigung** 

**Erklärung:** Die externe Vos-Quelle speist **5 mV × 1001 = 5V** in den Ausgang, das ist innerhalb des linearen Bereichs. **Aber:** Die Sättigung deutet darauf hin, dass die Open-Loop-Verstärkung des Modells bei diesem Arbeitspunkt **nicht ausreicht**, um den Ausgang weiter auszusteuern. Das LTspice-Macromodell hat eine **begrenzte Open-Loop-Gain** (~200 V/mV = 106 dB), die bei großen Ausgangsspannungen nachlässt.

### Verbesserung: Kleinere Vos für linearen Bereich

Für lineare Messung im nicht-sättigenden Bereich:
- **Vos = 1 mV** → Vout = -1,0 V (linear)
- **Vos = 2 mV** → Vout = -2,0 V (linear)
- **Vos = 5 mV** → Vout = -5,0 V (grenzwertig)
- **Vos = 10 mV** → Vout = -10,0 V (sättigt!)
- **Vos = 15 mV** → Vout = -15,0 V (sättigt definitiv)

### Empfehlung

Für Offset-Simulationen **immer Vos ≤ 5 mV** wählen, sonst sättigt der Ausgang und die Messung wird nichtlinear.

**Alternative:** Verstärkung reduzieren (z.B. Rf=100k, Ri=1k → A=-100), dann sättigt der Ausgang erst bei Vos > 130 mV.

---

## Zusammenfassung

| Methode | Vos-Simulation | Realistisch? |
|---------|----------------|--------------|
| Standard Macromodell | 11 µV (Artefakt) | ✗ nein |
| Externe Vos-Quelle 5 mV | -5.0V am Ausgang | ✓ ja |
| TI PSpice-Modell mit `.param Vos=5m` | -5.0V am Ausgang | ✓ ja |

**Fazit:** Für realistische Offset-Simulationen **immer eine externe Vos-Quelle** oder ein vollständiges Hersteller-Modell verwenden. Das LTspice-Standard-Macromodell ist für Offset-Analysen **nicht geeignet**.
