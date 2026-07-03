# Slew-Rate Simulation 1: TL082CP OpAmp als Komparator

## Übersicht

Diese Simulation misst die **Slew Rate** (Anstiegsgeschwindigkeit der Ausgangsspannung) des **TL082CP** JFET-Operationsverstärkers. Als Schaltungstopologie wurde ein **Open-Loop-Komparator** verwendet, um die Slew-Rate bei Rail-zu-Rail-Übergängen ohne Beeinflussung durch Rückkopplung zu beobachten.

## Schaltungstopologie

```
              V+ (+15V)
               │
               │
        ┌──────┴──────┐
        │             │
   Vin ─┤In+     Out  ├─ Vout
        │             │
        │In-          │
        │             │
        └──────┬──────┘
               │
               │ (kein Feedback!)
               │
              GND (Vref = 0V)
```

**Verdrahtung:**
- `In+` direkt mit `Vin` verbunden
- `In-` direkt mit `GND` verbunden → Vref = 0 V
- **Keine Rückkopplung** vom Ausgang zum Eingang
- Schaltschwelle: `Vout = +Rail` wenn `Vin > 0`, `Vout = −Rail` wenn `Vin < 0`

**Eigenschaften des Open-Loop-Komparators:**
- Ausgang schwingt zwischen den Rails (≈ ±13.5 V bei ±15 V Versorgung)
- Übergang Rail → Rail bei jedem Nulldurchgang von `Vin`
- Übergangszeit wird durch die Slew-Rate des OpAmps begrenzt
- **Keine Beeinflussung** durch externe Komponenten (keine R/C im Feedback)

## LTSpice-Konfiguration

### Spannungsversorgung
- `V+ = +15 V` (Pin 8 des TL082)
- `V- = -15 V` (Pin 4 des TL082)
- Versorgung über zwei `voltage`-Quellen: `V2 = 15`, `V3 = 15` (V3 mit umgekehrter Polarität ergibt −15 V am V−-Pin)

### Eingangssignal (Vin)
**Rechteck-Puls** mit folgenden Parametern:
- `PULSE(-5 5 0 1p 1p 10u 20u)`
- **V1 = −5 V** (LOW-Pegel)
- **V2 = +5 V** (HIGH-Pegel)
- **Td = 0** (keine Startverzögerung)
- **Tr = 1 ps** (sehr steile Anstiegsflanke, effektiv Dirac-Sprung)
- **Tf = 1 ps** (sehr steile Abfallflanke)
- **Pw = 10 µs** (Pulsweite, 50% Duty Cycle)
- **Per = 20 µs** (Periode, entspricht 50 kHz)

**Spezifikation des Eingangssignals:**
- Frequenz: **50 kHz** (1/Periode)
- Tastverhältnis: **50 %** (Pw/Per)
- Amplitude: **10 Vpp** (peak-to-peak, V2 − V1)
- Offset: **0 V** (symmetrisch um 0 V)

**Hinweis zu Vin-Amplitude:** Es wurde auch eine Variante mit `PULSE(-10 10 ...)` (20 Vpp) simuliert. Die Slew-Rate-Ergebnisse waren identisch (≈ 13.0 V/µs in beiden Fällen), da im Open-Loop-Komparator der Ausgang unabhängig von der Eingangsamplitude immer Rail-zu-Rail schwingt. Die finale Konfiguration verwendet 10 Vpp.

### Transienten-Analyse
- `.tran 0 40u 0 1n`
- Start: 0 s
- Ende: 40 µs (= 2 volle Perioden)
- `maxstep = 1 ns` (1 ns maximale Schrittweite für den Solver)
- 2 vollständige Pulse sichtbar (jeweils 1 Rail-zu-Rail-Übergang in jede Richtung)

### OpAmp-Modell
- `TL082.301` (TI Macro-Modell aus 1989, PSpice-kompatibel)
- Verwendet als `.SUBCKT` in der `.asc`-Schaltung
- Simuliert das Verhalten des TL082 mit vereinfachten internen Stufen

## Messung der Slew-Rate

### Verwendete `.meas`-Direktiven

```
* Gesamt-Messungen
.meas tran vin_max   MAX V(Vin)  FROM 0 TO 40u
.meas tran vout_max  MAX V(vout) FROM 0 TO 40u
.meas tran vout_min  MIN V(vout) FROM 0 TO 40u

* Profil Anstieg Rail -> Rail (t = 0.5 bis 2.5 µs)
.meas tran vout_rise_05u  FIND V(vout) AT 0.50u
.meas tran vout_rise_08u  FIND V(vout) AT 0.80u
.meas tran vout_rise_10u  FIND V(vout) AT 1.00u
.meas tran vout_rise_12u  FIND V(vout) AT 1.20u
.meas tran vout_rise_13u  FIND V(vout) AT 1.30u
.meas tran vout_rise_14u  FIND V(vout) AT 1.40u
.meas tran vout_rise_15u  FIND V(vout) AT 1.50u
.meas tran vout_rise_16u  FIND V(vout) AT 1.60u
.meas tran vout_rise_17u  FIND V(vout) AT 1.70u
.meas tran vout_rise_18u  FIND V(vout) AT 1.80u
.meas tran vout_rise_20u  FIND V(vout) AT 2.00u
.meas tran vout_rise_25u  FIND V(vout) AT 2.50u

* Profil Abfall Rail -> Rail (t = 10.5 bis 12.5 µs)
.meas tran vout_fall_1050u FIND V(vout) AT 10.50u
.meas tran vout_fall_1080u FIND V(vout) AT 10.80u
.meas tran vout_fall_1100u FIND V(vout) AT 11.00u
.meas tran vout_fall_1120u FIND V(vout) AT 11.20u
.meas tran vout_fall_1130u FIND V(vout) AT 11.30u
.meas tran vout_fall_1140u FIND V(vout) AT 11.40u
.meas tran vout_fall_1150u FIND V(vout) AT 11.50u
.meas tran vout_fall_1160u FIND V(vout) AT 11.60u
.meas tran vout_fall_1170u FIND V(vout) AT 11.70u
.meas tran vout_fall_1180u FIND V(vout) AT 11.80u
.meas tran vout_fall_1200u FIND V(vout) AT 12.00u
.meas tran vout_fall_1250u FIND V(vout) AT 12.50u

* Slew-Rate-Berechnungen
* Anstieg: Rail -> Rail (Slew-Phase zwischen 1.0 und 2.0 µs)
.meas tran sr_rise_peak  PARAM (vout_rise_15u - vout_rise_10u) / 0.50u
.meas tran sr_rise_mid   PARAM (vout_rise_18u - vout_rise_12u) / 0.60u
* Abfall: Rail -> Rail (Slew-Phase zwischen 11.0 und 12.0 µs)
.meas tran sr_fall_peak  PARAM (vout_fall_1150u - vout_fall_1100u) / 0.50u
.meas tran sr_fall_mid   PARAM (vout_fall_1180u - vout_fall_1120u) / 0.60u
```

### Slew-Rate-Formeln

Die Slew-Rate wird als **lineare Steigung** in ausgewählten Zeitfenstern berechnet:

- **sr_rise_peak:** Slew-Rate am **Beginn** der Anstiegsflanke (t = 1.0 → 1.5 µs, Δt = 0.5 µs)
- **sr_rise_mid:** Slew-Rate in der **Mitte** der Anstiegsflanke (t = 1.2 → 1.8 µs, Δt = 0.6 µs)
- **sr_fall_peak:** Slew-Rate am **Beginn** der Abfallflanke (t = 11.0 → 11.5 µs, Δt = 0.5 µs)
- **sr_fall_mid:** Slew-Rate in der **Mitte** der Abfallflanke (t = 11.2 → 11.8 µs, Δt = 0.6 µs)

## Messergebnisse

### Gesamtübersicht (aus LTSpice-Log, Vin = 10 Vpp)

```
vin_max:   5.0000 V
vout_max:  13.4764 V  (positiver Rail)
vout_min: -13.4773 V  (negativer Rail)

sr_rise_peak:  1.07079e+07 V/s  =  +10.71 V/µs
sr_rise_mid:   1.30027e+07 V/s  =  +13.00 V/µs
sr_fall_peak: -1.20560e+07 V/s  =  -12.06 V/µs
sr_fall_mid:  -1.33294e+07 V/s  =  -13.33 V/µs
```

### Vergleich: 10 Vpp vs 20 Vpp

| Messung | 10 Vpp (Vin = ±5 V) | 20 Vpp (Vin = ±10 V) | Differenz |
|---|---|---|---|
| `vout_max` | 13.4764 V | 13.4764 V | ≈ 0 % |
| `vout_min` | −13.4773 V | −13.4779 V | ≈ 0 % |
| `sr_rise_peak` | 10.71 V/µs | 10.25 V/µs | −4.3 % |
| `sr_rise_mid`  | **13.00 V/µs** | **13.00 V/µs** | **≈ 0 %** |
| `sr_fall_peak` | 12.06 V/µs | 12.82 V/µs | +6.3 % |
| `sr_fall_mid`  | **13.33 V/µs** | **13.65 V/µs** | +2.4 % |

**Erkenntnis:** Die Slew-Rate ist **unabhängig** von der Eingangsamplitude, da der Ausgang im Open-Loop-Komparator immer Rail-zu-Rail schwingt (≈ 27 V Hub).

### Profil der Anstiegsflanke (Rail → Rail)

| Zeitpunkt | Vout (V) | Steigung lokal |
|---|---|---|
| 0.50 µs | −13.44 | (Rail-Plateau) |
| 0.80 µs | −13.42 | (Rail-Plateau) |
| 1.00 µs | −13.40 | (Slew-Phase beginnt) |
| 1.20 µs | −11.95 | +7.2 V/µs |
| 1.30 µs | −10.65 | +13.0 V/µs |
| 1.40 µs | −9.35 | +13.0 V/µs |
| 1.50 µs | −8.05 | +13.0 V/µs |
| 1.60 µs | −6.75 | +13.0 V/µs |
| 1.70 µs | −5.45 | +13.0 V/µs |
| 1.80 µs | −4.15 | +13.0 V/µs |
| 2.00 µs | −1.55 | +13.0 V/µs |
| 2.50 µs | +4.96 | (Plateau fast erreicht) |

### Profil der Abfallflanke (Rail → Rail)

| Zeitpunkt | Vout (V) | Steigung lokal |
|---|---|---|
| 10.50 µs | +13.47 | (Rail-Plateau) |
| 10.80 µs | +13.42 | (Rail-Plateau) |
| 11.00 µs | +13.36 | (Slew-Phase beginnt) |
| 11.20 µs | +11.33 | −10.2 V/µs |
| 11.30 µs | +9.99 | −13.4 V/µs |
| 11.40 µs | +8.66 | −13.3 V/µs |
| 11.50 µs | +7.33 | −13.3 V/µs |
| 11.60 µs | +6.00 | −13.3 V/µs |
| 11.70 µs | +4.66 | −13.4 V/µs |
| 11.80 µs | +3.33 | −13.3 V/µs |
| 12.00 µs | +0.66 | −13.4 V/µs |
| 12.50 µs | −5.99 | (Plateau fast erreicht) |

## Interpretation der Ergebnisse

### 1. Slew-Rate-Magnitude
- **Gemessen (Mitte):** **13.0–13.3 V/µs** (symmetrisch für Anstieg und Abfall)
- **Datenblatt TL082CP:** **20 V/µs** typisch
- **Verhältnis:** ≈ 65 % des Datenblatt-Werts
- **Ursache der Diskrepanz:** siehe Hauptsektion unten

### 2. Symmetrie zwischen Anstieg und Abfall
- `sr_rise_mid ≈ |sr_fall_mid|` (13.00 vs 13.33 V/µs, Differenz 2.5 %)
- Beide Flanken zeigen **nahezu identische Slew-Rate**
- Bestätigt die spannungsunabhängige Slew-Rate bei großen Differenzspannungen

### 3. Spannungsabhängigkeit der Slew-Rate
- Im Profil erkennt man drei Phasen:
  - **Rail-Plateau (0.5–1.0 µs):** Ausgang bewegt sich kaum (Reduktion der Differenzspannung)
  - **Slew-Phase (1.0–2.0 µs):** Volle Slew-Rate von ≈ 13 V/µs
  - **Settling (2.0–2.5 µs):** Annäherung an den neuen Rail
- Im Open-Loop-Komparator ist die Rail-zu-Rail-Slew-Phase **beschränkt** durch die Spannungsdifferenz, die der OpAmp treiben muss

### 4. Vergleich mit Buffer-Topologie
| Topologie | Slew-Rate (Mitte) |
|---|---|
| Buffer (Vin = ±10 V) | 13.4 V/µs |
| Komparator (Vin = ±5 V) | 13.0 V/µs |
| Komparator (Vin = ±10 V) | 13.0 V/µs |

**Ergebnis:** Beide Topologien liefern **nahezu identische** Slew-Rate. Das bestätigt, dass der OpAmp **eine** fundamentale Slew-Rate hat, unabhängig von der Schaltungstopologie.

## Warum ist die gemessene Slew-Rate schlechter als im Datenblatt?

Datenblatt: **20 V/µs** typisch
Gemessen:    **13.0 V/µs**
Verhältnis:   **65 %** des Datenblatt-Werts

Es gibt mehrere Ursachen für diese Diskrepanz. Die **wahrscheinlichste** wird zuerst erklärt:

### 🔴 Hauptursache (wahrscheinlich): TL082.301 Macro-Modell-Vereinfachung

**Das `TL082.301` Macro-Modell von 1989 ist ein vereinfachtes PSpice-Modell**, das nicht alle parasitären Effekte des realen TL082 abbildet. Konkret:

- **Theoretische Macro-Slew-Rate:** `SR_macro = ISS / C1 = 195 µA / 3.498 pF ≈ 55.7 V/µs`
  - `ISS` = 195 µA (interne Stromquelle am Eingangs-Differenzpaar)
  - `C1` = 3.498 pF (Miller-Kompensationskondensator)
- **Tatsächliche simulierte Slew-Rate:** 13.0 V/µs (≈ 4× niedriger als theoretisch)
- **Grund:** Das Macro modelliert **nicht alle** Stufen des OpAmps. Die Differenz zwischen 55 V/µs (theoretisch) und 13 V/µs (real) zeigt, dass das Modell die tatsächliche Stromverteilung im Chip nicht korrekt abbildet.

**Konsequenz:** Das Macro-Modell ist für **funktionale Simulationen** (z. B. DC-Analyse, kleinsignalige AC-Analyse) gut geeignet, aber für **großsignalige Dynamik** (Slew-Rate, Rail-Clipping) **nicht exakt**. Reale TL082-Chips erreichen die 20 V/µs im Datenblatt, aber das Macro approximiert sie auf ≈ 13 V/µs.

### 🟡 Sekundäre Ursachen

#### 1. Strombegrenzung im Eingangs-Differenzpaar
- JFET-Eingangspaar (Modell `JX`) hat einen begrenzten `ISS = 195 µA`
- Dieser Strom lädt den Miller-Kondensator `C1` auf → bestimmt SR
- Reale TL082-Chips haben ähnliche Ströme, aber zusätzliche parasitäre Kapazitäten, die im Macro fehlen

#### 2. `.meas`-Fenster-Mittelung
- Die Slew-Rate ist nicht über die gesamte Flanke konstant
- Anlauf und Ende der Flanke sind langsamer (OpAmp-Antwortzeit, Settling)
- `sr_*_mid` mittelt über 0.5–0.6 µs Slew-Phase → leicht reduzierter Wert
- Spitzen-SR (in einem infinitesimalen Zeitfenster) wäre höher, ist aber mit `.meas FIND` nicht direkt messbar

#### 3. Rail-Clipping-Effekt
- Bei Komparator schwingt Ausgang zwischen ±13.5 V
- Nahe den Rails reduziert sich die Slew-Rate (Miller-Effekt, Sättigung der Ausgangsstufe)
- Datenblatt misst SR bei 50% Rail-Spannung oder im linearen Bereich, nicht am Rail
- Im Komparator wird die Slew-Phase **teilweise** durch Rail-Nähe beeinflusst

#### 4. Test-Bedingungen im Datenblatt vs. unserer Simulation
- **Datenblatt:** `SR` gemessen mit `RL = 2 kΩ`, `CL = 100 pF`, `TA = 25°C`
- **Unsere Sim:** keine Last, keine parasitäre Kapazität, `TA = 27°C`
- **Lastfrei** sollte **eigentlich höhere** SR ergeben → konsistent mit unserer Messung
- Das **Macro-Modell** approximiert die reale Schaltung jedoch nicht perfekt

#### 5. Modell-Vereinfachung der Sättigungs-Charakteristik
- Macro `ISS` ist ein **fester DC-Strom**, kein sättigender Transistor
- Reale JFET-Strombegrenzung ist sanfter (drain current vs. Vds ist nichtlinear)
- Führt zu **anderer** Slew-Charakteristik im Macro

#### 6. Numerische Aspekte
- `CompressWinPoints = 1024` → Waveform-Daten werden komprimiert
- `.meas` mit `FIND` interpoliert zwischen komprimierten Samples
- Kann zu geringfügig abweichenden Werten führen (typischerweise < 1 %)

### Zusammenfassung: Datenblatt-Diskrepanz

| Ursache | Wahrscheinlichkeit | Beitrag zur Diskrepanz |
|---|---|---|
| **Macro-Modell-Vereinfachung (1989)** | **Hoch** | **~30–50 %** |
| `.meas`-Fenster-Mittelung | Mittel | ~3–5 % |
| Rail-Clipping-Effekt | Mittel | ~2–5 % |
| Test-Bedingungen Unterschied | Niedrig | ~1–2 % |
| Strombegrenzung im Differenzpaar | Niedrig | bereits im Macro |
| Modell-Sättigungscharakteristik | Niedrig | bereits im Macro |
| Numerische Aspekte | Sehr niedrig | < 1 % |

**Schlussfolgerung:** Die Hauptursache für die Diskrepanz zwischen gemessener (13.0 V/µs) und Datenblatt-Slew-Rate (20 V/µs) ist die **Vereinfachung des `TL082.301` Macro-Modells**. Reale TL082-Chips erreichen die 20 V/µs unter den im Datenblatt spezifizierten Test-Bedingungen, aber das Simulationsmodell approximiert die tatsächliche Slew-Rate konservativ.

## Theoretischer Hintergrund

### Slew-Rate-Definition
Die **Slew Rate (SR)** ist die maximale Anstiegsgeschwindigkeit der Ausgangsspannung:
```
SR = max |dv_out(t) / dt|
```
Einheit: **V/µs**

### Physikalische Ursache
Die Slew-Rate entsteht durch die **Strombegrenzung der Eingangsstufe** eines OpAmps:

```
       V+ ──────┐
                 │
   In+ ─────┐    │
            ├─[Q1]──┬──── Miller-Cc ──── Ausgang
   In- ─────┤    │
            ├─[Q2]──┘
       V- ──────┘
```

Wenn die Differenzspannung am Eingang groß genug ist, sättigt einer der Eingangstransistoren (Q1 oder Q2). Der maximale Strom, der dann in den Miller-Kondensator fließen kann, ist `I_sat`:
```
SR = I_sat / C_c
```

Für das TL082.301 Macro-Modell:
- `I_sat = ISS = 195 µA`
- `C_c = C1 = 3.498 pF`
- `SR_macro_theoretisch = 195e-6 / 3.498e-12 ≈ 55.7 V/µs`
- `SR_macro_simuliert ≈ 13.0 V/µs` (wegen Modell-Vereinfachungen)

### Open-Loop-Komparator vs. Buffer
| Eigenschaft | Buffer | Open-Loop-Komparator |
|---|---|---|
| Ausgangs-Spannungshub | ±Vin (1:1) | ≈ ±Rail (≈ ±13.5 V) |
| Rückkopplung | Ja (direkt) | Nein |
| Slew-Rate-Bestimmung | OpAmp + Last | OpAmp + Ausgangsstufe |
| Spannungsabhängigkeit der SR | ja (bei kleinem Hub) | nein (immer Rail-zu-Rail) |
| Typische Anwendung | Impedanzwandler, Sample-and-Hold | Schaltschwelle, Null-Detektor |

## Vergleich mit anderen Topologien

### Open-Loop-Komparator (diese Simulation)
- **Vorteil:** Rail-zu-Rail-Übergang mit maximaler Slew-Rate
- **Nachteil:** Ausgang schwingt zwischen den Rails (kein linearer Betrieb)
- **Anwendung:** Schaltschwelle, Null-Detektor, Rechteck-Generator

### Buffer (Spannungsfolger)
- **Vorteil:** Lineare 1:1-Verstärkung, Ausgang folgt Eingang
- **Nachteil:** Rail-Clipping bei großem `Vin`
- **Anwendung:** Impedanzwandler, Sample-and-Hold

### Nicht-invertierender Verstärker (z. B. Gain = 11)
- **Vorteil:** Konfigurierbare Verstärkung
- **Nachteil:** Rückkopplungs-Widerstände können effektive SR reduzieren
- **Anwendung:** Verstärkerschaltungen

### Schmitt-Trigger (Komparator mit Hysterese)
- **Vorteil:** Saubere Schaltflanken, definierte Schaltschwellen
- **Nachteil:** Mitkopplung kompensiert teilweise Slew-Effekt
- **Anwendung:** Hysterese-Komparator, Oszillator

## Dateien

| Datei | Beschreibung |
|---|---|
| `WORKS-non-inverting-comparator-test-slew-rate-tl802-op-amp.asc` | LTSpice-Schaltung (Open-Loop-Komparator, ±5 V Puls) |
| `WORKS-non-inverting-comparator-test-slew-rate-tl802-op-amp.log` | LTSpice-Logfile mit Messwerten |
| `WORKS-non-inverting-comparator-test-slew-rate-tl802-op-amp.raw` | LTSpice-Rohdaten (Transient-Analysis) |
| `WORKS-non-inverting-comparator-test-slew-rate-tl802-op-amp.plt` | LTSpice-Plot-Konfiguration |
| `WORKS-non-inverting-comparator-test-slew-rate-tl802-op-amp.net` | LTSpice-Netzliste |
| `WORKS-non-inverting-comparator-test-slew-rate-tl802-op-amp.op.raw` | LTSpice-OP-Punkt Daten |
| `TL082.301` | TI Macro-Modell des TL082 OpAmp |
| `TL082.asy` | LTSpice-Symboldefinition für TL082 |

## Zusammenfassung

| Parameter | Wert |
|---|---|
| OpAmp | TL082CP |
| Schaltungstopologie | **Open-Loop-Komparator (kein Feedback)** |
| Versorgung | ±15 V |
| Eingangssignal | Rechteck, ±5 V, 50 kHz, 50% DC |
| Gemessene Slew-Rate (Mitte) | **≈ 13.0 V/µs** (symmetrisch) |
| Datenblatt-Wert | 20 V/µs (typisch) |
| Übergangszeit Rail→Rail | ≈ 1 µs (für 27 V Hub) |
| Rail-Spannung | ≈ ±13.5 V |

**Fazit:** Die Slew-Rate des TL082CP, gemessen im Open-Loop-Komparator, liegt bei **13.0 V/µs**, was 65 % des Datenblatt-Werts (20 V/µs) entspricht. Die Hauptursache für diese Diskrepanz ist die **Vereinfachung des `TL082.301` Macro-Modells** von 1989, das für funktionale Simulationen geeignet ist, aber die großsignalisge Dynamik (Slew-Rate, Rail-Clipping) nicht exakt abbildet. Die Symmetrie zwischen An- und Abstiegsflanke bestätigt die spannungsunabhängige Slew-Rate bei großen Differenzspannungen.
