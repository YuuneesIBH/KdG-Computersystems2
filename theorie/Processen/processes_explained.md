# Procesbeheer - Computersystems 2
## Theorie Hoofdstuk 6
*Datum: 25/11/2024*

---

## Inhoudsopgave

1. [Dispatcher/Scheduler](#dispatcherscheduler)
2. [Toestanden van een proces](#toestanden-van-een-proces)
3. [Opstarten van processen in Linux](#opstarten-van-processen-in-linux)
4. [Context Switch (Pre-emptive vs Non-pre-emptive)](#context-switch)
5. [Scheduling Strategieën](#scheduling-strategieën)
6. [Linux Scheduling](#linux-scheduling)
7. [Herhalingsvragen](#herhalingsvragen)

---

## Inleiding: Procesbeheer

### Basisconcepten

**Procesbeheer** is het systeem waarbij het besturingssysteem (OS) bepaalt welke processen processortijd krijgen. Dit is essentieel voor:

- **Multiprocessing**: Computer runt verschillende processen "tegelijkertijd"
- **Multi-user**: Verschillende gebruikers werken "tegelijkertijd" op de computer

### Belangrijke Hardware Componenten
- **Toetsenbord**: Invoerapparaat
- **Beeldscherm**: Uitvoerapparaat  
- **HDD (Hard Disk Drive)**: Traditionele opslag met draaiende schijven
- **SSD (Solid State Drive)**: Moderne opslag zonder bewegende delen

**Kernvraag**: Welk proces krijgt processortijd?

---

## Dispatcher/Scheduler

### Definities

**Dispatcher** (ook wel **Scheduler** genoemd):
- Onderdeel van het besturingssysteem (OS)
- Beslist welk proces processortijd krijgt
- Voert context switches uit tussen processen

### Traces (Sporen)

**Traces** zijn de uitvoeringspatronen van processen:
- Tonen hoe verschillende processen elkaar afwisselen
- 3 processen kunnen tegelijkertijd in het geheugen aanwezig zijn
- Dispatcher wisselt tussen processen

#### Traces vanuit verschillende perspectieven:

1. **Vanuit processen**: Elk proces ziet zijn eigen uitvoering
2. **Vanuit processor**: Processor ziet alle processen afwisselen

### Praktische Tools

**Linux/Mac OS-X**:
- `xload`: Toont systeembelasting grafisch
- `top`: Dynamische lijst van actieve processen
- `ps`: Momentopname van actieve processen
- `pstree`: Toont procesboom/hiërarchie

**Windows**:
- **Taakbeheer**: Grafische interface voor procesbeheer
- **PowerShell**: `Get-Process` commando

---

## Toestanden van een Proces

### Proces Samenstelling

Een **proces** bestaat uit:
- **Code**: De programma-instructies
- **Data**: Variabelen en gegevens
- **Stack**: Lokale variabelen en functieaanroepen
- **Toestand (Context)**: Huidige status van het proces

### Minimale Toestanden

Een proces moet **minstens 2 toestanden** hebben:
- **Running**: Proces wordt uitgevoerd
- **Not-running**: Proces wordt niet uitgevoerd

### Vijf-Toestand Model

**Probleem**: 2 toestanden zijn onvoldoende (geen verschil tussen wachten op I/O of gepauzeerd)

**Oplossing**: 3 basis + 2 extra toestanden:

#### Basis Toestanden:
1. **Ready**: Klaar om uitgevoerd te worden, wacht op processortijd
2. **Running**: Wordt momenteel uitgevoerd door processor
3. **Blocked**: Wacht op I/O of andere resource

#### Extra Toestanden:
4. **New**: Proces wordt aangemaakt
5. **Exit**: Proces is beëindigd

### Process Control Block (PCB)

**PCB** is een datastructuur die de **context** van een proces opslaat:

#### Inhoud van PCB:
- **Program Counter**: Laatst uitgevoerde instructie
- **Register waarden**: Toestand van alle CPU registers
- **Geheugenconfiguratie**: Paging, segmenting, virtual memory
- **Proces ID (PID)**: Unieke identificatie
- **Resources**: Open bestanden, netwerkverbindingen
- **Proces hiërarchie**: Kind-processen
- **Timing informatie**: Starttijd, processortijd
- **Prioriteit**: Scheduling prioriteit

### Context Switch

**Context Switch**: Het proces waarbij het OS:
1. Huidige proces context opslaat in PCB
2. Nieuw proces selecteert
3. Context van nieuw proces laadt
4. Uitvoering voortzet

### Queues in het OS

Het OS beheert **queues van PCB's**:
- **Ready Queue**: Processen klaar voor uitvoering
- **Blocked Queue**: Processen wachtend op I/O
- **Device Queues**: Processen wachtend op specifieke apparaten

---

## Opstarten van Processen in Linux

### Twee System Calls

Linux gebruikt **2 system calls** voor het starten van nieuwe processen:

#### 1. `fork()` System Call

```c
int fork()
```

**Functionaliteit**:
- Huidige proces wordt **gekopieerd**
- Kopieert: code segment, data segment, stack segment, PCB
- Beide processen (ouder en kind) kunnen verder lopen
- **Return values**:
  - **Kind proces**: krijgt `0`
  - **Ouder proces**: krijgt process-ID van kind

#### 2. `exec("executable")` System Call

```c
exec("executable")
```

**Functionaliteit**:
- **Vervangt** code segment met nieuwe programmacode
- **Reset** stack en data segment
- Gebruikt door kind proces om nieuw programma te laden

### Praktisch Voorbeeld: Bash

```bash
bash$ xload
```

**Proces**:
1. Bash doet `fork()` om child proces aan te maken
2. Child proces doet `exec()` om xload code te laden
3. Ouder proces (bash) blijft actief

### Code Voorbeeld

```c
#include <stdio.h>
#include <unistd.h>

void doe_child(int i) {
    printf("start van proces %d\n", i);
    int t;
    for(t=0; t<5; t++) {
        sleep(1);
        printf("proces %d: tel=%d\n", i, t);
    }
}

int main() {
    int i;
    for(i=0; i<10; i++) {
        int f = fork();
        if (f==0) {  // Kind proces
            doe_child(i);
            return 0;
        }
    }
    sleep(3);
    execl("/bin/ps", "ps", "-f", NULL);
    printf("Niet uitgeprint!");  // Wordt nooit uitgevoerd
}
```

**Uitleg**: 
- Maakt 10 kind-processen
- Elk kind proces telt tot 5
- Ouder proces vervangt zichzelf met `ps` commando

---

## Context Switch

### Non-Pre-emptive Scheduling

**Kenmerken**:
- OS onderbreekt applicatie **niet**
- Applicatie runt tot:
  - Return (proces eindigt)
  - I/O wachttijd
- **Voordeel**: Heel eenvoudig te implementeren
- **Nadeel**: Langlopende processen kunnen systeem blokkeren

**Voorbeelden**: Windows 3.11, Mac OS9, Oberon

### Pre-emptive Scheduling

**Kenmerken**:
- OS **onderbreekt** proces om ander proces te starten
- Gebeurt na **time slice** (tijdslot)
- **Voordeel**: Eerlijkere verdeling van processortijd
- **Nadeel**: Meer complex, overhead van context switches

**Voorbeelden**: Moderne Windows en Linux

### Pre-emptive Context Switch Proces

**Stappen**:
1. **Interrupt** veroorzaakt context switch
2. **Kernel mode**: Schakel naar kernel modus
3. **Save**: Bewaar registers en configuratie in PCB
4. **Queue**: Zet huidige PCB in juiste queue
5. **Select**: Zoek nieuw proces om te starten
6. **Update**: Bijwerken PCB nieuw proces (Running staat)
7. **Load**: Laad registers uit nieuwe PCB
8. **Timer**: Zet timer voor volgende context switch
9. **User mode**: Schakel terug naar user modus
10. **Jump**: Spring naar juiste adres in nieuw proces

---

## Scheduling Strategieën

### Doelstellingen

**Scheduling** heeft als doel:
- **Eerlijk verdelen** van processortijd over processen
- **Uithongering (starvation)** voorkomen
- **Weinig overhead** veroorzaken
- **Prioriteiten** van processen respecteren

### Proces Waarden (in PCB)

Elk proces heeft volgende waarden:
- **w**: Wachttijd in systeem (tot nu toe)
- **e**: Uitvoeringstijd besteed (tot nu toe)  
- **s**: Totale geschatte uitvoeringstijd (inclusief e)

### Online vs Batch Scheduling

#### Online Scheduling
- Jobs runnen in **foreground**
- **Interactie** met gebruiker
- Directe response verwacht

#### Batch Scheduling
- Jobs runnen in **background**
- **Geen interactie** met gebruiker
- Voor lange uitvoeringstijden
- Voorbeelden: MRP systemen, Deep Learning training

---

## Scheduling Algoritmen

### 1. First Come First Served (FCFS)

**Algoritme**: Kies proces met **maximale w** (oudste proces)

**Eigenschappen**:
- **Non-pre-emptive**: Wacht tot I/O of einde
- **Voordeel**: Lange processen worden sneller doorlopen
- **Nadeel**: Korte processen moeten soms lang wachten
- **Gebruik**: Niet geschikt voor online scheduling

### 2. Shortest Process Next (SPN)

**Algoritme**: Kies proces met **kleinste s**

**Eigenschappen**:
- **Non-pre-emptive**
- **Voordeel**: Snellere response-tijd
- **Nadelen**: 
  - Moet uitvoeringstijd kennen
  - Mogelijkheid tot **starvation**
- **Gebruik**: Niet geschikt voor online scheduling

### 3. Shortest Remaining Time (SRT)

**Algoritme**: Kies proces met kleinste **(s-e)**

**Eigenschappen**:
- **Pre-emptive**: Onderbreekt als nieuw proces kortere resterende tijd heeft
- **Nadeel**: Zoals SPN, plus complexiteit
- **Gebruik**: Niet geschikt voor online scheduling

### 4. Highest Response Ratio Next (HRRN)

**Algoritme**: Kies proces met hoogste **(w+s)/s**

**Response Ratio**: 
- Formule: (w+s)/s
- Initieel gelijk aan 1
- Stijgt naarmate proces langer wacht

**Eigenschappen**:
- **Non-pre-emptive**
- **Voordeel**: Balans tussen korte processen en lange wachtende processen
- **Nadeel**: Schatting van s nog steeds nodig
- **Gebruik**: Niet geschikt voor online scheduling

### 5. Round-Robin (RR)

**Algoritme**: Queue van processen, neem steeds de volgende

**Eigenschappen**:
- **Pre-emptive**: Elk proces krijgt gelijke **time-slice**
- Proces wordt onderbroken door **timer interrupt**
- **Voordelen**: 
  - Goede response-tijd
  - Rechtvaardige behandeling
- **Nadeel**: I/O gebonden processen krijgen relatief minder tijd
- **Gebruik**: Meest voorkomend in moderne OS'en

---

## Linux Scheduling

### Eigenschappen

**Linux Scheduling** is:
- **Pre-emptive**
- **Round-robin** gebaseerd
- Ondersteunt **verschillende prioriteiten**

### Prioriteiten

#### Nice Value (NI)
- Bereik: **-20 tot +19**
- Default voor nieuw proces: **0**
- Lager getal = **hogere prioriteit**

#### Priority (PR)
- Formule: **PR = NI + 20**
- Bereik: **0 (hoog) tot 39 (laag)**
- Default voor nieuw proces: **20**

#### Commando's
- `nice`: Start proces met aangepaste prioriteit
- `renice`: Wijzig prioriteit van lopend proces

**Regel**: Hoe lager PR of NI, hoe hoger de prioriteit

### Timeslice in Linux

**Vraag**: Wat is de grootteorde van de timeslice bij Linux?
**Antwoord**: Typisch enkele milliseconden tot tientallen milliseconden

---

## Slurm (Optioneel)

### Simple Linux Utility for Resource Management

**Slurm** is een:
- **Open source** batch job scheduler
- Gebruikt door veel **supercomputers**
- Beheert **exclusieve/niet-exclusieve** toegang tot compute nodes

### Voorbeeld Script

```bash
#!/bin/bash
#SBATCH --job-name=test
#SBATCH --output=test.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=10:00
#SBATCH --mem-per-cpu=100
srun testprogram
```

### Commando's
- `sbatch submit.sh`: Submit job
- `squeue`: Bekijk queue status

---

## Herhalingsvragen

### Belangrijke Examenvragen

1. **Processtructuur**: Bespreek delen van proces (stack, data, code, PCB)
2. **Procestoestanden**: Leg 5 toestanden uit + overgangen
3. **PCB**: Wat is een Process Control Block?
4. **Idle Time**: Wat is idle time? Welk commando toont dit?
5. **Context Switch**: Wat gebeurt tijdens pre-emptive context switch?
6. **Scheduling Types**: Verschil tussen pre-emptive en non-pre-emptive
7. **Linux Processen**: Hoe start proces in Linux? (fork/exec)
8. **Code Analyse**: Verklaar gegeven C code
9. **Scheduling Strategieën**: Bespreek strategie X (wat/hoe, voor/nadeel)
10. **Starvation**: Wat is uithongering?

---

## Belangrijke Afkortingen

| Afkorting | Volledige Naam | Betekenis |
|-----------|----------------|-----------|
| **OS** | Operating System | Besturingssysteem |
| **PCB** | Process Control Block | Datastructuur met procescontext |
| **PID** | Process ID | Unieke proces identificatie |
| **CPU** | Central Processing Unit | Centrale verwerkingseenheid |
| **I/O** | Input/Output | Invoer/Uitvoer |
| **HDD** | Hard Disk Drive | Traditionele harde schijf |
| **SSD** | Solid State Drive | Moderne opslag zonder bewegende delen |
| **FCFS** | First Come First Served | Eerst gekomen, eerst gediend |
| **SPN** | Shortest Process Next | Kortste proces eerst |
| **SRT** | Shortest Remaining Time | Kortste resterende tijd |
| **HRRN** | Highest Response Ratio Next | Hoogste response ratio eerst |
| **RR** | Round-Robin | Ronde verdeling |
| **NI** | Nice Value | Prioriteitswaarde (-20 tot +19) |
| **PR** | Priority | Prioriteit (0 tot 39) |

---

## Samenhang en Concepten

### Proceslevenscyclus
1. **New** → **Ready** (proces geladen in geheugen)
2. **Ready** → **Running** (scheduler selecteert proces)
3. **Running** → **Blocked** (wacht op I/O)
4. **Blocked** → **Ready** (I/O voltooid)
5. **Running** → **Ready** (time slice verlopen - pre-emptive)
6. **Running** → **Exit** (proces voltooid)

### Scheduling Hiërarchie
1. **Long-term scheduler**: Bepaalt welke processen in geheugen
2. **Short-term scheduler**: Bepaalt welk proces CPU krijgt
3. **Medium-term scheduler**: Swapping tussen geheugen en opslag

### Performance Metriek
- **Throughput**: Aantal processen per tijdseenheid
- **Turnaround time**: Totale tijd van submit tot completion
- **Response time**: Tijd tot eerste response
- **Waiting time**: Tijd gespendeerd in ready queue
- **CPU utilization**: Percentage CPU gebruik

---

*Deze samenvatting bevat alle belangrijke concepten uit het hoofdstuk Procesbeheer voor Computersystems 2.*