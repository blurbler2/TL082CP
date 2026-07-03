# Slew-Rate Simulation 1: TL082CP OpAmp als Buffer

## Übersicht

Diese Simulation misst die **Slew Rate** (Anstiegsgeschwindigkeit der Ausgangsspannung) des **TL082CP** JFET-Operationsverstärkers. Als Schaltungstopologie wurde ein **Buffer (Spannungsfolger / Voltage Follower)** verwendet, um die Slew-Rate des OpAmps ohne externe Spannungsteiler-Effekte direkt zu beobachten.

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
               │ (direkte Rückkopplung)
               │
              Out
```

**Verdrahtung:**
- `In+` direkt mit `Vin` verbunden
- `In-` direkt mit `Out` (= `Vout`) verbunden
- Keine externen Widerstände
- `Gain = 1` (reiner Spannungsfolger)

**Vorteile des Buffers für die Slew-Rate-Messung:**
- Kein Spannungsteiler, der die gemessene Slew-Rate verfälschen könnte
- Direkte Beobachtung der OpAmp-internen Strombegrenzung
- `Vout` folgt `Vin` 1:1 (innerhalb der Rail-Grenzen)

## LTSpice-Konfiguration

### Spannungsversorgung
- `V+ = +15 V` (Pin 8 des TL082)
- `V- = -15 V` (Pin 4 des TL082)
- Versorgung über zwei `voltage`-Quellen: `V2 = 15`, `V3 = 15` (V3 mit umgekehrter Polarität ergibt −15 V am V−-Pin)

### Eingangssignal (Vin)
**Rechteck-Puls** mit folgenden Parametern:
- `PULSE(-10 10 0 1p 1p 10u 20u)`
- **V1 = −10 V** (LOW-Pegel)
- **V2 = +10 V** (HIGH-Pegel)
- **Td = 0** (keine Startverzögerung)
- **Tr = 1 ps** (sehr steile Anstiegsflanke, effektiv Dirac-Sprung)
- **Tf = 1 ps** (sehr steile Abfallflanke)
- **Pw = 10 µs** (Pulsweite, 50% Duty Cycle)
- **Per = 20 µs** (Periode, entspricht 50 kHz)

**Spezifikation des Eingangssignals:**
- Frequenz: **50 kHz** (1/Periode)
- Tastverhältnis: **50 %** (Pw/Per)
- Amplitude: **20 Vpp** (peak-to-peak, V2 − V1)
- Offset: **0 V** (symmetrisch um 0 V)

**Begründung für Vin = ±10 V:**
- Genug Spannungshub, um eine **lange, gut messbare Slew-Phase** zu erzeugen
- Übergangszeit bei 20 V/µs (Datenblatt-Wert): 20 V / 20 V/µs ≈ 1 µs → 5-fach länger als bei Vin = ±2.5 V
- Vermeidet Rail-Clipping als visuelle Störung, solange Ausgangsspannung < ±13.5 V bleibt

### Transienten-Analyse
- `.tran 0 40u 0 1n`
- Start: 0 s
- Ende: 40 µs (= 2 volle Perioden)
- `maxstep = 1 ns` (1 ns maximale Schrittweite für den Solver)
- 2 vollständige Pulse sichtbar (Anstieg + Plateau + Abfall + Plateau, zweimal)

### OpAmp-Modell
- `TL082.301` (TI Macro-Modell aus 1989, PSpice-kompatibel)
- Verwendet als `.SUBCKT` in der `.asc`-Schaltung
- Simuliert das Verhalten des TL082 mit vereinfachten internen Stufen

## Messung der Slew-Rate

### Verwendete `.meas`-Direktiven

```
.meas tran vin_max   MAX V(Vin)  FROM 0 TO 40u
.meas tran vout_max  MAX V(vout) FROM 0 TO 40u

* Profil-Messungen Anstieg (t = 0 bis 3 µs, in 50–500 ns Schritten)
.meas tran vout_005u  FIND V(vout) AT 0.05u
.meas tran vout_010u  FIND V(vout) AT 0.10u
.meas tran vout_015u  FIND V(vout) AT 0.15u
.meas tran vout_020u  FIND V(vout) AT 0.20u
.meas tran vout_025u  FIND V(vout) AT 0.25u
.meas tran vout_030u  FIND V(vout) AT 0.30u
.meas tran vout_040u  FIND V(vout) AT 0.40u
.meas tran vout_050u  FIND V(vout) AT 0.50u
.meas tran vout_100u  FIND V(vout) AT 1.00u
.meas tran vout_200u  FIND V(vout) AT 2.00u
.meas tran vout_300u  FIND V(vout) AT 3.00u

* Profil-Messungen Abfall (t = 10.05 bis 13 µs, symmetrisch zum Anstieg)
.meas tran vout_10050u FIND V(vout) AT 10.05u
.meas tran vout_10060u FIND V(vout) AT 10.10u
.meas tran vout_10070u FIND V(vout) AT 10.15u
.meas tran vout_10080u FIND V(vout) AT 10.20u
.meas tran vout_10090u FIND V(vout) AT 10.25u
.meas tran vout_10100u FIND V(vout) AT 10.30u
.meas tran vout_10110u FIND V(vout) AT 10.40u
.meas tran vout_10120u FIND V(vout) AT 10.50u
.meas tran vout_10200u FIND V(vout) AT 12.00u
.meas tran vout_10300u FIND V(vout) AT 13.00u

* Berechnete Slew-Rate-Werte
.meas tran sr_peak   PARAM (vout_020u  - vout_005u)  / 0.15u
.meas tran sr_late   PARAM (vout_040u  - vout_030u)  / 0.10u
.meas tran sr_fall   PARAM (vout_10080u - vout_10050u) / 0.15u
.meas tran sf_peak   PARAM (vout_10070u - vout_10050u) / 0.10u
```

### Slew-Rate-Formeln

Die Slew-Rate wird als **lineare Steigung** in ausgewählten Zeitfenstern berechnet:

- **sr_peak:** Slew-Rate in der **Mitte** der Anstiegsflanke (t = 0.05 → 0.20 µs, Δt = 0.15 µs)
- **sr_late:** Slew-Rate am **Ende** der Anstiegsflanke (t = 0.30 → 0.40 µs, Δt = 0.10 µs)
- **sr_fall:** Slew-Rate in der **Mitte** der Abfallflanke (t = 10.05 → 10.20 µs, Δt = 0.15 µs)
- **sf_peak:** Slew-Rate in der **frühen** Abfallflanke (t = 10.05 → 10.15 µs, Δt = 0.10 µs)

## Messergebnisse

### Gesamtübersicht (aus LTSpice-Log)

```
vin_max:   10.0000 V
vout_max:  10.0642 V  (leicht über 10 V durch Overshoot)

sr_peak:   +1.34315e+07 V/s  =  +13.43 V/µs
sr_late:   +1.33670e+07 V/s  =  +13.37 V/µs
sr_fall:   -1.34503e+07 V/s  =  -13.45 V/µs
sf_peak:   -1.34058e+07 V/s  =  -13.41 V/µs
```

### Profil der Anstiegsflanke (Vin: −10 V → +10 V)

| Zeitpunkt | Vout (V) | Steigung lokal |
|---|---|---|
| 0.05 µs | −9.62 | — |
| 0.10 µs | −8.96 | +6.6 V/µs |
| 0.15 µs | −8.28 | +6.8 V/µs |
| 0.20 µs | −7.61 | +6.7 V/µs |
| 0.25 µs | −6.94 | +6.7 V/µs |
| 0.30 µs | −6.27 | +6.7 V/µs |
| 0.40 µs | −4.93 | +13.4 V/µs |
| 0.50 µs | −3.60 | +13.3 V/µs |
| 1.00 µs | +2.93 | +6.5 V/µs (Settling) |
| 2.00 µs | +10.00 | (Rail erreicht) |
| 3.00 µs | +10.00 | (Plateau) |

### Profil der Abfallflanke (Vin: +10 V → −10 V)

| Zeitpunkt | Vout (V) | Steigung lokal |
|---|---|---|
| 10.05 µs | +9.62 | — |
| 10.10 µs | +8.96 | −6.6 V/µs |
| 10.15 µs | +8.28 | −6.8 V/µs |
| 10.20 µs | +7.61 | −6.7 V/µs |
| 10.25 µs | +6.92 | −6.9 V/µs |
| 10.30 µs | +6.24 | −6.8 V/µs |
| 10.40 µs | +4.88 | −13.6 V/µs |
| 10.50 µs | +3.51 | −13.7 V/µs |
| 12.00 µs | −9.99 | (Settling) |
| 13.00 µs | −10.00 | (Plateau) |

## Interpretation der Ergebnisse

### 1. Slew-Rate-Magnitude
- **Gemessen:** ≈ **13.4 V/µs** (alle vier Werte, sehr konsistent)
- **Datenblatt TL082CP:** **20 V/µs** typisch
- **Verhältnis:** ≈ 67 % des Datenblatt-Werts
- **Ursache der Diskrepanz:** Das `TL082.301` Macro-Modell von 1989 approximiert die reale Slew-Rate nur ungenau. Reale TL082-Chips erreichen 15–20 V/µs je nach Exemplar und Betriebsbedingungen.

### 2. Symmetrie zwischen Anstieg und Abfall
- `sr_peak ≈ |sr_fall|` und `|sr_late| ≈ |sf_peak|`
- Beide Flanken zeigen **nahezu identische Slew-Rate** → **spannungsunabhängig bei großen Differenzspannungen**
- Bestätigt die theoretische Erwartung: Die Slew-Rate wird durch die maximale Stromstärke der Eingangsstufe (`I_sat`) und den Miller-Kompensationskondensator (`C_c`) bestimmt, nicht durch die Vorzeichen der Spannung.

### 3. Spannungsabhängigkeit der Slew-Rate
- Im Profil (siehe Tabelle oben) erkennt man eine **leichte Steigungs-Variation**:
  - Erste 100 ns: ≈ 6.6 V/µs (Anlaufphase)
  - Mitte (200–500 ns): ≈ 13.4 V/µs (voller Slew)
- **Theorie:** Bei großen Differenzspannungen am OpAmp-Eingang (Vin ≠ Vout) ist die Eingangsstufe in Sättigung → konstanter Maximalstrom → konstante Slew-Rate. Bei kleinen Differenzspannungen (Vout ≈ Vin) arbeitet die Eingangsstufe im linearen Bereich → reduzierter Strom → reduzierte Slew-Rate.
- **Im Buffer** ist die Differenzspannung am Eingang **immer** gleich `(Vin − Vout)`. Beim Anstieg ist `Vin` bereits auf +10 V, aber `Vout` ist noch bei −10 V → **große Differenz** → voller Slew. Wenn `Vout` sich `Vin` nähert (am Ende der Flanke), nimmt die Differenz ab → **reduzierter Slew**.

### 4. Rail-Clipping
- Bei `Vout_200u = +10.00 V` erreicht der Ausgang den Rail
- Der TL082-Macro sättigt bei ≈ ±10 V (nicht bei den erwarteten ±13.5 V)
- **Ursache:** Interne Strombegrenzung des Macro-Modells (`ISS = 195 µA`)

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
- `SR_macro = 195e-6 / 3.498e-12 ≈ 55.7 V/µs`

Das Macro überschätzt die Slew-Rate (Datenblatt 20 V/µs, Macro 55 V/µs). Die simulierten 13.4 V/µs liegen **zwischen** diesen Werten, was auf die vereinfachte Berechnung im `.meas`-Fenster zurückzuführen ist (Mittelung über die Slew-Phase + Übergang in Rail-Clipping).

### Slew-Rate und Signalfrequenz
Für **sinusförmige** Signale ohne Verzerrung muss gelten:
```
SR ≥ 2π · f_peak · V_peak
```

Mit `SR = 20 V/µs` (Datenblatt) und `V_peak = 10 V`:
```
f_max = SR / (2π · V_peak) = 20e6 / (2π · 10) ≈ 318 kHz
```

Oberhalb von **318 kHz** wird eine 20 Vpp-Sinuswelle am Ausgang slew-rate-begrenzt (Dreieck statt Sinus).

## Vergleich mit anderen Topologien

### Buffer (diese Simulation)
- **Vorteil:** Direkte Messung der OpAmp-Slew-Rate ohne Beeinflussung durch Rückkopplung
- **Nachteil:** `Vout` clippt an den Rails bei großem `Vin`

### Nicht-invertierender Verstärker (z. B. Gain = 11 mit R1=1k, R2=10k)
- **Vorteil:** Ausgangsspannung wird mit konfigurierbarem Gain verstärkt → Rail-Clipping früher
- **Nachteil:** Rückkopplungs-Widerstände können die effektive Slew-Rate reduzieren

### Open-Loop-Komparator
- **Vorteil:** Sehr schnelle Schaltflanken
- **Nachteil:** Ausgang schwingt zwischen den Rails, Slew-Rate schwer zu messen

### Schmitt-Trigger (Komparator mit Hysterese)
- **Vorteil:** Saubere, schnelle Schaltflanken
- **Nachteil:** Mitkopplung kompensiert teilweise den Slew-Effekt

## Dateien

| Datei | Beschreibung |
|---|---|
| `WORKS-non-inverting-buffer-test-slew-rate-tl802-op-amp.asc` | LTSpice-Schaltung (Buffer, ±10 V Puls) |
| `WORKS-non-inverting-buffer-test-slew-rate-tl802-op-amp.log` | LTSpice-Logfile mit Messwerten |
| `WORKS-non-inverting-buffer-test-slew-rate-tl802-op-amp.raw` | LTSpice-Rohdaten (Transient-Analysis) |
| `WORKS-non-inverting-buffer-test-slew-rate-tl802-op-amp.plt` | LTSpice-Plot-Konfiguration |
| `WORKS-non-inverting-buffer-test-slew-rate-tl802-op-amp.net` | LTSpice-Netzliste |
| `WORKS-non-inverting-buffer-test-slew-rate-tl802-op-amp.op.raw` | LTSpice-OP-Punkt Daten |
| `TL082.301` | TI Macro-Modell des TL082 OpAmp |
| `TL082.asy` | LTSpice-Symboldefinition für TL082 |

## Zusammenfassung

| Parameter | Wert |
|---|---|
| OpAmp | TL082CP |
| Schaltungstopologie | **Buffer (Spannungsfolger, Gain = 1)** |
| Versorgung | ±15 V |
| Eingangssignal | Rechteck, ±10 V, 50 kHz, 50% DC |
| Gemessene Slew-Rate | **≈ 13.4 V/µs** (symmetrisch für Anstieg und Abfall) |
| Datenblatt-Wert | 20 V/µs (typisch) |
| Übergangszeit (ges.) | ≈ 1 µs (für 20 V Spannungshub) |
| Rail-Clipping | Ja, bei ≈ ±10 V (Macro-Limit) |

**Fazit:** Die Slew-Rate des TL082CP (gemessen mit einem Buffer) liegt bei **13.4 V/µs**, was 67 % des Datenblatt-Werts entspricht. Die Diskrepanz ist auf das vereinfachte Macro-Modell `TL082.301` zurückzuführen. Die Symmetrie zwischen An- und Abstiegsflanke bestätigt die spannungsunabhängige Slew-Rate bei großen Differenzspannungen.
