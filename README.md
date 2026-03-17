# Microcomputer System Project 2 – 8051 Melody Player (The Swan)

## 📌 Overview
This project implements a melody player on the 8051 microcontroller using an onboard passive buzzer. The system generates musical notes by controlling hardware timers to produce square waves with accurate frequencies and durations. The target melody is *“The Swan”* from *Le Carnaval des Animaux*.


##  🎥Demo
* **Project Demo Video:** [Play melody with buzzer - YouTube](https://www.youtube.com/watch?v=4lBPS6rVXbs)



## 🧠System Architecture

### 🔹Design Concept
The core functionality is decoupled into two independent hardware timers:
| Module | Responsibility | Function |
| :--- | :--- | :--- |
| **Timer 0** | Frequency (Pitch) | Generates the square wave for specific notes |
| **Timer 1** | Duration (Tempo) | Controls how long each note is played |

1. **Separation of Concerns:** Timer 0 handles waveform generation, while Timer 1 manages the overarching timing control.
2. **Lookup-Table Approach:** Precomputed `TH0`/`TL0` values for each musical note are stored in memory. This eliminates runtime calculation overhead for the 8051 chip.
3. **Loop-Based Delay Extension:** Since the maximum delay of a 16-bit timer is insufficient for a full beat, the `DJNZ` instruction is utilized to accumulate longer durations.

### 🔄Program Flow
1. Initialize registers and configure both timers to **Mode 1 (16-bit timer)**.
2. Fetch the next note's frequency and duration from the lookup tables.
3. **Start Timer 0** to begin waveform generation.
4. **Start Timer 1** to begin timing the note's duration.
5. Wait until the duration expires.
6. **Stop Timer 0** (or set `TH0=TL0=0` if it is a rest note).
7. Move the index to the next note and repeat until the melody concludes.

### ⏱️Timing & Tempo Control

#### System Timing Parameters
* **System Clock:** `11.0592 MHz`
* **Timer Frequency:** `11.0592 MHz / 12 = 921.6 kHz`
* **Time per Count:** `1 / 921.6 kHz ≈ 1.085 μs`
* **Maximum Timer Delay:** `65536 × 1.085 μs ≈ 0.0711 sec`

#### Tempo Implementation (♩ = 70)
* **1 Beat Duration:** `60 / 70 ≈ 0.857 sec`
* **Loop-Based Extension:** To achieve an `0.857s` delay using a timer that maxes out at `0.0711s`, a loop multiplier is required:
  * `M ≈ 0.857 / 0.0711 ≈ 12`
  * Register `R2` is set to `12` and controlled via the `DJNZ R2, LOOP` instruction.

## 🔊Hardware Considerations & Limitations

###  Passive Buzzer 
* **Working Principle:** Requires an external square wave (PWM) to determine the pitch. The volume is determined by the amplitude (current).
* **Single-Tone Output:** The hardware can only produce one frequency at a time, making chords impossible.
* **Frequency Range Constraint:** The effective audio range is roughly **100 Hz to 4000 Hz**. Frequencies outside this boundary result in severe distortion or weak output.
* **No Software Volume Control:** Since the timers only manipulate frequency, volume adjustment requires hardware modifications (e.g., altering the input current).

## 💡Challenges & Solutions

* **Challenge 1: Frequency Calculation Complexity**
  * *Issue:* Manually calculating the timer counts for each note is highly error-prone.
  * *Solution:* Developed an Excel-based automated lookup table ([`8051_Project_design.xlsx`](https://github.com/rayyichen310/Microcomputer-System-Project-2/blob/main/Project_2_Submission/8051_Project_design.xlsx) to generate precise `TH0`/`TL0` hex values instantly.
* **Challenge 2: Hardware Timer Limitation**
  * *Issue:* A single 16-bit timer overflow is too short to represent a musical beat.
  * *Solution:* Implemented multi-loop timing accumulation using registers to extend the delay accurately without drifting.


