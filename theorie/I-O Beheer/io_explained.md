# Computersystemen 2 - I/O Beheer - Uitgebreide Samenvatting

## Inleiding: Het I/O Probleem

Wanneer een computer opstart, heeft deze toegang tot de processor en het geheugen, maar hoe kan deze communiceren met externe apparaten? De fundamentele vragen zijn:

- **Hoe kan je iets op een scherm zetten?**
- **Hoe weet je welke toets een gebruiker heeft aangeslagen?**
- **Hoe lees je iets van de harddisk drive (HDD) of solid state drive (SSD)?**

De BIOS (Basic Input/Output System) biedt wel enige ondersteuning, maar deze is veel te beperkt voor moderne toepassingen. Daarom hebben we geavanceerde I/O-beheersystemen nodig.

---

## 1. Beeldscherm (Display) I/O

### Grafische Kaart Architectuur

Een **grafische kaart** is verantwoordelijk voor het besturen van het beeldscherm en bestaat uit verschillende componenten:

#### Componenten van een Grafische Kaart:
- **GPU (Graphics Processing Unit)**: De processor die grafische berekeningen uitvoert
- **VRAM (Video RAM)**: Speciaal geheugen voor het opslaan van beelddata
- **RAMDAC (Random Access Memory Digital-to-Analog Converter)**: Converteert digitale signalen naar analoge signalen voor de monitor
- **Control Unit**: Beheert de communicatie en coördinatie tussen componenten

### Video Modes

Een grafische kaart kan in verschillende modi werken:

#### 1. Text-Mode
- **Resolutie**: 80 kolommen × 25 rijen karakters
- **Geheugengebruik**: 1 byte per karakter op het scherm
- **Totaal geheugen**: 80 × 25 = 2000 bytes
- **Gebruik**: Eenvoudige tekstweergave, command-line interfaces

#### 2. Grafische Mode - Indexed
- **Principe**: Elk pixel wordt weergegeven door 1 byte
- **Kleurrepresentatie**: De byte bevat een kleurnummer (index) dat verwijst naar een kleurentabel
- **Kleurentabel**: Bevat de werkelijke RGB-waarden voor elke kleurindex
- **Voordeel**: Geheugenefficiënt, beperkte maar voldoende kleuren

#### 3. Grafische Mode - True-Color
- **Principe**: Elk pixel wordt weergegeven door 3 bytes (RGB)
- **Kleurrepresentatie**: 
  - 1 byte voor rood (0-255)
  - 1 byte voor groen (0-255)
  - 1 byte voor blauw (0-255)
- **Totaal**: 16.777.216 verschillende kleuren mogelijk
- **Nadeel**: Veel geheugengebruik

### Video RAM (VRAM) Adressering

#### Text-Mode Voorbeeld:
Om karakter 'A' (ASCII 65) op kolom 5 van regel 10 te plaatsen:
```
VRAM[10 × 80 + 5] = 65
```

**Uitleg van de berekening:**
- Regel 10 betekent dat we 10 complete rijen van 80 karakters moeten overslaan
- 10 × 80 = 800 karakters
- Plus kolom 5 = 800 + 5 = 805
- VRAM[805] = 65 (ASCII-waarde voor 'A')

#### Grafische Mode Voorbeeld:
Voor een 800×600 indexed mode, om pixel (300, 200) kleur 5 te geven:
```
VRAM[200 × 800 + 300] = 5
```

**Berekening:**
- Regel 200 × 800 pixels per regel = 160.000 pixels
- Plus kolom 300 = 160.000 + 300 = 160.300
- In hexadecimaal: 160.300 = 0x2722C
- VRAM[0x2722C] = 5

### Memory-Mapped I/O voor Beeldscherm

**Memory-Mapped I/O** is een techniek waarbij I/O-apparaten worden toegewezen aan specifieke geheugenlocaties in de adresruimte van de processor.

#### Voordelen van Memory-Mapped I/O:
1. **Eenvoud**: Gewone geheugeninstructies (load/store) kunnen worden gebruikt
2. **Uniformiteit**: Geen speciale I/O-instructies nodig
3. **Flexibiliteit**: Alle geheugenoperaties zijn beschikbaar voor I/O

#### Praktisch Voorbeeld:
Als VRAM gemapt is op adres 0xA0000:
```
VRAM[805] = 65  →  RAM[0xA0000 + 805] = RAM[0xA0325] = 65
```

### GPU-versnelling

Complexe grafische operaties zoals `drawCircle()` vereisen veel berekeningen. De **GPU** lost dit op door:

1. **CPU** plaatst opdrachten in VRAM
2. **GPU** voert deze opdrachten parallel uit
3. **GPU** kan efficiënt tekenen: lijnen, cirkels, polygonen, 3D-objecten

---

## 2. Toetsenbord (Keyboard) I/O

### Keyboard Controller

De **keyboard controller** is een speciale chip die toetsaanslagen verwerkt en communiceert met de processor via drie belangrijke registers:

#### Keyboard Controller Registers:
1. **Data Register**: Bevat de laatst aangeslagen toets
2. **Status Register**: Geeft aan of er nieuwe data klaar staat
3. **Control Register**: Bevat instellingen en configuratie

### Memory-Mapped Keyboard I/O

De keyboard registers worden ook via memory-mapped I/O benaderd, wat betekent dat ze specifieke geheugenlocaties krijgen toegewezen.

**Belangrijk**: Keyboard registers zijn geen CPU-registers, maar geheugenlocaties die de keyboard controller representeren.

### Programmed I/O vs Interrupt-Driven I/O

#### Programmed I/O (Polling)
```c
int status;
do {
    status = memory[KEYB_STATUS];
} while (status != GEREED)
char c = memory[KEYB_DATA];
```

**Nadelen van Programmed I/O:**
- **CPU-verspilling**: Processor is constant bezig met controleren
- **Inefficiëntie**: Geen andere taken kunnen worden uitgevoerd
- **Energieverspilling**: Constant actieve controle

#### Interrupt-Driven I/O
**Principe**: Hardware stuurt een signaal (interrupt) naar de CPU wanneer data klaar staat.

**Werking:**
1. **Interrupt Pin**: Speciale pin op de CPU voor interrupts
2. **Interrupt Signal**: Keyboard controller stuurt interrupt wanneer toets wordt ingedrukt
3. **Interrupt Tabel**: Bevat koppeling tussen interrupt-nummer en ISR-adres
4. **ISR Uitvoering**: Interrupt Service Routine wordt uitgevoerd
5. **Terugkeer**: Na ISR wordt teruggesprongen naar oorspronkelijke taak

**Voordelen van Interrupt-Driven I/O:**
- **Efficiëntie**: CPU kan andere taken uitvoeren
- **Responsiviteit**: Onmiddellijke reactie op input
- **Energiebesparing**: Geen constante polling nodig

### Interrupt Service Routine (ISR)

Een **ISR** is een speciale functie die wordt uitgevoerd wanneer een interrupt optreedt.

**Taken van een Keyboard ISR:**
1. **Data lezen**: Toetsaanslag uit keyboard controller halen
2. **Buffer plaatsing**: Data in circulaire buffer plaatsen
3. **Status resetten**: Interrupt-vlag wissen
4. **Terugkeer**: Normale programma-uitvoering hervatten

### Circulaire Buffer

Een **circulaire buffer** is een datastructuur voor tijdelijke opslag van toetsaanslagen.

#### Eigenschappen:
- **Vaste grootte**: Bijvoorbeeld 256 bytes
- **Twee pointers**: 
  - **Lees-pointer**: Waar volgende karakter gelezen wordt
  - **Schrijf-pointer**: Waar volgende karakter geschreven wordt

#### Buffer Status:
- **Leeg**: `lees == schrijf`
- **Vol**: `schrijf == (lees - 1) % buffergrootte`
- **Overflow risico**: Wanneer buffer vol is en nieuwe data arriveert

#### Voordelen Circulaire Buffer:
1. **Tijdelijke opslag**: Toetsaanslagen gaan niet verloren
2. **Asynchrone verwerking**: ISR en hoofdprogramma werken onafhankelijk
3. **Efficiëntie**: Geen geheugen-allocatie tijdens runtime

---

## 3. Disk Drive I/O

### Het DMA-probleem

Bij **disk drives** (HDD/SSD) worden grote hoeveelheden data verplaatst. Als de CPU elke byte individueel zou moeten kopiëren via interrupt-driven I/O, zou dit leiden tot:

- **CPU-overbelasting**: Constant bezig met data-transfer
- **Inefficiëntie**: Geen tijd voor andere taken
- **Prestatie-verlies**: Langzame data-overdracht

### Direct Memory Access (DMA)

**DMA** is een technologie die hardware toestaat om direct data te kopiëren tussen geheugen en I/O-apparaten zonder CPU-interventie.

#### DMA-werkingsprincipe:
1. **Opdracht**: CPU geeft opdracht aan DMA-controller
2. **Parameters**: Bronadres, bestemmingsadres, aantal bytes
3. **Bus-overname**: DMA krijgt controle over de systeembus
4. **Data-transfer**: DMA voert de kopie-operatie uit
5. **Interrupt**: DMA stuurt interrupt naar CPU wanneer klaar
6. **Bus-teruggave**: CPU krijgt bus-controle terug

#### DMA-controller Componenten:
- **Adres-registers**: Voor bron- en bestemmingsadressen
- **Teller**: Aantal over te dragen bytes
- **Control-registers**: Instellingen en status
- **Bus-arbitratie**: Logica voor bus-toegang

### Voordelen van DMA:
1. **CPU-vrijheid**: Processor kan andere taken uitvoeren
2. **Snelheid**: Directe geheugen-naar-geheugen transfer
3. **Efficiëntie**: Geen overhead van interrupt per byte
4. **Parallellisme**: Meerdere operaties tegelijkertijd

---

## Systeem Architectuur

### Bus-structuur

Moderne computers gebruiken een **hiërarchische bus-structuur**:

#### Componenten:
- **Systeembus**: Verbindt CPU, RAM, ROM
- **I/O-bus**: Verbindt I/O-apparaten
- **Bridge**: Verbindt systeembus met I/O-bus

#### Voordelen Hiërarchische Structuur:
1. **Prestatie**: Snelle systeembus voor kritieke componenten
2. **Kostenbesparing**: Langzamere I/O-bus voor perifere apparaten
3. **Flexibiliteit**: Verschillende bus-standaarden mogelijk
4. **Schaalbaarheid**: Eenvoudig uitbreiden met nieuwe apparaten

### Adresruimte Organisatie

De processor ziet een **uniforme adresruimte** waarin verschillende componenten zijn gemapt:

```
0x00000000 - 0x7FFFFFFF: RAM
0x80000000 - 0x9FFFFFFF: ROM/BIOS
0xA0000000 - 0xA00FFFFF: VRAM
0xA0100000 - 0xA0100FFF: Keyboard Controller
0xA0200000 - 0xA0200FFF: DMA Controller
...
```

---

## Belangrijke Concepten Samengevat

### Memory-Mapped I/O
- **Definitie**: I/O-apparaten krijgen geheugenlocaties toegewezen
- **Voordeel**: Standaard geheugeninstructies bruikbaar
- **Universaliteit**: Niet alle computers gebruiken dit (sommige hebben aparte I/O-adresruimte)

### I/O-technieken Vergelijking

| Techniek | CPU-belasting | Efficiëntie | Complexiteit | Gebruik |
|----------|---------------|-------------|--------------|---------|
| Programmed I/O | Hoog | Laag | Laag | Eenvoudige apparaten |
| Interrupt-driven I/O | Gemiddeld | Hoog | Gemiddeld | Toetsenbord, muis |
| DMA | Laag | Zeer hoog | Hoog | Disk drives, netwerk |

### Prestatie-optimalisatie

1. **Buffering**: Circulaire buffers voor tijdelijke opslag
2. **Interrupts**: Vermijd polling waar mogelijk
3. **DMA**: Voor grote data-transfers
4. **GPU**: Voor grafische bewerkingen
5. **Caching**: Veelgebruikte data in snelle toegang

---

## Examen Herhalingsvragen - Gedetailleerde Antwoorden

### 1. Welke componenten zitten er op een video-kaart?
- **GPU**: Graphics Processing Unit voor grafische berekeningen
- **VRAM**: Video RAM voor opslag van beelddata
- **RAMDAC**: Digital-to-Analog converter voor monitor-aansturing
- **Control Unit**: Coördinatie en communicatie-beheer

### 2. Wat is de rol van de GPU?
- **Parallelle verwerking**: Duizenden eenvoudige cores voor grafische berekeningen
- **Opdracht-uitvoering**: Complexe grafische operaties zoals lijnen, cirkels, polygonen
- **3D-rendering**: Transformaties, lighting, texturing
- **CPU-ontlasting**: Neemt grafische taken over van hoofdprocessor

### 3. In welke modes kan een video kaart werken?
- **Text-mode**: 80×25 karakters, 1 byte per karakter
- **Indexed grafische mode**: 1 byte per pixel, kleurnummer verwijst naar tabel
- **True-color mode**: 3 bytes per pixel (RGB), directe kleurweergave

### 4. VRAM geheugen-mapping berekening
Voor grafische kaart in indexed mode 800×600, VRAM gemapt op 0x1E2345, pixel (300,200) kleur 5:
```
Berekening: 200 × 800 + 300 = 160.300 = 0x2722C
Adres: 0x1E2345 + 0x2722C = 0x209571
Operatie: RAM[0x209571] = 5
```

### 5. Memory-mapped I/O voordelen
- **Uniformiteit**: Standaard geheugeninstructies (load/store) bruikbaar
- **Eenvoud**: Geen speciale I/O-instructies nodig
- **Flexibiliteit**: Alle geheugenoperaties beschikbaar
- **Niet universeel**: Sommige computers hebben aparte I/O-adresruimte

### 6. Programmed I/O vs Interrupt-driven I/O
**Programmed I/O (Polling):**
- CPU controleert constant status
- Hoge CPU-belasting
- Inefficiënt voor sporadische events

**Interrupt-driven I/O:**
- Hardware stuurt signaal bij data
- Lage CPU-belasting
- Efficiënt, CPU kan andere taken doen

### 7. Circulaire buffer werking
- **Structuur**: Vaste grootte met lees- en schrijf-pointers
- **Leeg**: lees == schrijf
- **Vol**: schrijf == (lees - 1) % buffergrootte
- **Overflow**: Nieuwe data overschrijft oude data

### 8. ISR (Interrupt Service Routine)
- **Functie**: Speciale routine voor interrupt-afhandeling
- **Taken**: Data lezen, buffer plaatsen, status resetten
- **Eigenschappen**: Kort, efficiënt, geen blocking operations

### 9. DMA Controller
- **Functie**: Direct Memory Access zonder CPU-interventie
- **Noodzaak**: Grote data-transfers (disk I/O) efficiënt afhandelen
- **Werking**: Krijgt bus-controle, voert transfer uit, stuurt interrupt
- **Voordeel**: CPU vrijgemaakt voor andere taken

---

## Conclusie

I/O-beheer is een complex systeem dat verschillende technieken combineert voor optimale prestatie:

1. **Memory-mapped I/O** voor uniforme toegang
2. **Interrupt-driven I/O** voor efficiënte event-handling
3. **DMA** voor grootschalige data-transfers
4. **Buffering** voor tijdelijke opslag en synchronisatie
5. **Specialized hardware** (GPU, controllers) voor specifieke taken

Deze technieken werken samen om een responsive en efficiënt computersysteem te creëren dat kan omgaan met diverse I/O-vereisten van moderne toepassingen.