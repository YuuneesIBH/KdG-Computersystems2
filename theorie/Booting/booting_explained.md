# Computersystemen 2 - Volledige Samenvatting

## Inhoudsopgave
1. [Inleiding en Taken van een Besturingssysteem](#inleiding)
2. [Grootheden en Conversies](#grootheden)
3. [Computer Architecturen](#architecturen)
4. [Registers en RAM Geheugen](#registers-ram)
5. [Booting Process](#booting)
6. [ROM Firmware](#rom-firmware)
7. [MBR en Boot-loader](#mbr-bootloader)
8. [UEFI vs BIOS](#uefi-bios)
9. [Examenvragen](#examenvragen)

---

## 1. Inleiding en Taken van een Besturingssysteem {#inleiding}

### Wat is een Besturingssysteem?
Een **besturingssysteem (OS - Operating System)** is software die fungeert als intermediair tussen:
- **Hardware** (processor, geheugen, I/O devices)
- **Applicaties** (programma's die gebruikers uitvoeren)
- **Gebruikers**

### Hoofdtaken van een Besturingssysteem
1. **Boot-process**: Het opstarten van het systeem
2. **Hardware Abstraction**: Abstractie van hardware voor applicaties
3. **I/O Management**: Beheer van input/output devices
4. **File Management**: Beheer van bestanden en directories
5. **Process Management**: Beheer van processen en threads
6. **Memory Management**: Beheer van RAM en virtueel geheugen
7. **Window Management**: Beheer van grafische interface

### Hiërarchie van Computersystemen
```
┌─────────────────────┐
│    Eindgebruiker    │
├─────────────────────┤
│ Toepassingsprogr.   │
├─────────────────────┤
│  Hulpprogramma's    │
├─────────────────────┤
│ Besturingssysteem   │
├─────────────────────┤
│     Hardware        │
└─────────────────────┘
```

---

## 2. Grootheden en Conversies {#grootheden}

### Decimale vs Binaire Prefixen

#### Decimaal (Macht van 10)
- **K** (kilo) = 10³ = 1.000
- **M** (mega) = 10⁶ = 1.000.000
- **G** (giga) = 10⁹ = 1.000.000.000
- **T** (tera) = 10¹² = 1.000.000.000.000
- **P** (peta) = 10¹⁵

#### Binair (Macht van 2)
- **Ki** (kibi) = 2¹⁰ = 1.024
- **Mi** (mebi) = 2²⁰ = 1.024² = 1.048.576
- **Gi** (gibi) = 2³⁰ = 1.024³ = 1.073.741.824
- **Ti** (tebi) = 2⁴⁰ = 1.024⁴
- **Pi** (pebi) = 2⁵⁰ = 1.024⁵

### Conversie Formules
- **Decimaal naar Binair**: Deel door 1.024
- **Binair naar Decimaal**: Vermenigvuldig met 1.024

### Voorbeelden
- 68.608 bytes = 68.608 ÷ 1.024 = 67 KiB
- 150 KiB = 150 × 1.024 = 153.600 bytes = 153,6 KB
- 300 MiB = 300 × 1.024² = 314.572.800 bytes = 314,6 MB

### Hexadecimale Conversies
- **0x100000** = 1×16⁵ = (2⁴)⁵ = 2²⁰ = 1 MiB
- **0x40000000** = 4×16⁷ = 4×2²⁸ = 2³⁰ = 1 GiB

---

## 3. Computer Architecturen {#architecturen}

### Harvard Architectuur
```
┌─────────────┐    ┌─────────────┐
│ Program RAM │    │  Data RAM   │
│   (ROM)     │    │             │
└─────────────┘    └─────────────┘
       │                  │
       └─────────┬────────┘
                 │
        ┌─────────────┐
        │  Processor  │
        │ • Registers │
        │ • ALU       │
        │ • Control   │
        └─────────────┘
```

**Kenmerken:**
- **Gescheiden geheugen** voor programma's en data
- **Twee aparte bussen** voor instructies en data
- **Sneller** omdat instructies en data parallel kunnen worden benaderd
- **Voorbeeld**: Arduino microcontrollers

### Von Neumann Architectuur
```
┌─────────────────────┐
│   Program & Data    │
│        RAM          │
└─────────────────────┘
           │
    ┌─────────────┐
    │  Processor  │
    │ • Registers │
    │ • ALU       │
    │ • Control   │
    └─────────────┘
```

**Kenmerken:**
- **Gedeeld geheugen** voor programma's en data
- **Één bus** voor zowel instructies als data
- **Instructiecyclus**: Fetch → Decode → Execute
- **Voorbeeld**: Raspberry Pi, moderne PC's

### Von Neumann met I/O Devices
```
┌─────────────────────┐
│   Program & Data    │
│        RAM          │
└─────────────────────┘
           │
    ┌─────────────┐    ┌─────────────┐
    │  Processor  │────│ I/O Devices │
    │             │    │ • Keyboard  │
    │             │    │ • Display   │
    │             │    │ • Storage   │
    └─────────────┘    └─────────────┘
```

---

## 4. Registers en RAM Geheugen {#registers-ram}

### Soorten Registers

#### Gegevensregisters
- **Tijdelijke opslagplaatsen** voor data tijdens berekeningen
- **Snelste geheugen** in de processor

#### Adresregisters
- **Indexregisters**: Voor array-indexering
- **Segmentregisters**: Voor geheugen-segmentatie
- **Stackpointer**: Wijst naar top van de stack

#### Stuur- en Statusregisters
- **Program Counter (PC)**: Bevat adres van volgende instructie
- **Flags**: Status bits (carry, zero, overflow, etc.)

### RAM Geheugen Organisatie

#### Code in RAM
- **Machine-code**: Bytes die instructies representeren
- **Instructies** bestaan uit:
  - Instructie code (opcode)
  - Argumenten (operanden)

#### Voorbeelden van Instructies
- Laad waarde uit geheugen naar register
- Sla waarde van register op in geheugen
- Laad register met directe waarde
- Tel twee registers op
- Spring naar ander adres (conditionally)

#### Data in RAM
- **Getallen**: bytes, words, floating point
- **Tekst**: ASCII, Unicode, EBCDIC
- **Belangrijk**: Data kan als code worden uitgevoerd!

### Intel 8086 Voorbeeld
- **16-bit processor** met 16-bit registers
- **Grootste getal in register**: 2¹⁶ = 64 KiB
- **20-bit adresbus** → maximaal 2²⁰ = 1 MiB RAM
- **Segmented addressing**: adres = CS × 16 + IP
  - CS = Code Segment register
  - IP = Instruction Pointer

### Moderne Processors
- **Intel Pentium**: 32-bit registers, 32-bit adresbus
- **Intel i7**: 64-bit registers, 40-52 bit adresbus

---

## 5. Booting Process {#booting}

### Het Probleem
**Vraag**: Wat gebeurt er als je een computer aanzet?
**Probleem**: De processor heeft instructies nodig, maar die staan in RAM, en RAM is leeg bij het opstarten.

### De Oplossing: ROM Firmware
- **ROM (Read-Only Memory)** bevat permanente software
- **Firmware** is de software in ROM die het systeem opstart

### Booting Stappen (Algemeen)
1. **ROM Firmware** wordt uitgevoerd
2. **Boot Loader** wordt geladen en uitgevoerd
3. **Kernel** wordt geladen door boot loader
4. **Volledig OS** wordt geïnitialiseerd

### Geheugen Layout tijdens Boot
```
┌─────────────────────┐ 0x7FFFFFFF
│                     │
│        RAM          │
│                     │
├─────────────────────┤ 0x000FFFFF
│    BIOS/ROM         │
├─────────────────────┤ 0x000A0000
│                     │
│        RAM          │
│                     │
└─────────────────────┘ 0x00000000
```

---

## 6. ROM Firmware {#rom-firmware}

### Inhoud van ROM
1. **POST (Power-On Self Test)**
   - Test of hardware correct werkt
   - Controleert RAM, processor, I/O devices

2. **HAL (Hardware Abstraction Layer)**
   - Biedt interface tussen software en hardware
   - Gestandaardiseerde functies voor hardware-toegang

3. **Shell/Interface**
   - Basis gebruikersinterface
   - Meestal command-line interface

4. **Boot Code**
   - Code om boot loader te laden van externe media
   - Meestal van harde schijf of USB

### BIOS (Basic Input/Output System)
- **Locatie**: Gemapped tussen 0xA0000 en 0xFFFFF
- **Functies**: Drivers voor keyboard, display, HDD
- **Software Interrupts**: API via INT instructies

### BIOS Interrupt Voorbeelden
- **INT 0x10**: Video services (karakter op scherm)
- **INT 0x16**: Keyboard services (lees toetsenbord)
- **INT 0x13**: Disk services (lees sector van HDD)

**Belangrijk**: BIOS kan alleen **sectoren** lezen, geen bestanden!

### BIOS Boot Process
1. **POST** uitvoeren
2. **HAL** initialiseren
3. **Eerste sector** van HDD laden naar RAM adres 0x7C00
4. **Sprong** naar 0x7C00 om boot loader uit te voeren

---

## 7. MBR en Boot-loader {#mbr-bootloader}

### MBR (Master Boot Record)
- **Eerste sector** van de harde schijf
- **Grootte**: 512 bytes
- **Locatie**: Sector 0 van HDD

### MBR Structuur
```
┌─────────────────────┐ Byte 0
│   Boot Loader Code  │ 446 bytes
├─────────────────────┤ Byte 446
│   Partition Table   │ 64 bytes (4×16)
├─────────────────────┤ Byte 510
│  Boot Signature     │ 2 bytes (0x55AA)
└─────────────────────┘ Byte 512
```

### Boot Loader Functionaliteit
- **Kleine programma** (max 446 bytes in MBR)
- **Laadt rest** van boot loader uit volgende sectoren
- **Kan filesystemen** lezen
- **Laadt kernel** van het besturingssysteem
- **Voorbeelden**: GRUB, LILO

### Boot Process met MBR
1. **BIOS** laadt MBR (512 bytes) naar 0x7C00
2. **MBR boot code** wordt uitgevoerd
3. **Boot loader** laadt eigen vervolg-code
4. **Boot loader** leest filesysteem
5. **Kernel** wordt geladen en gestart

### Partition Table
- **4 primaire partities** mogelijk
- **16 bytes per partitie**:
  - Boot flag (1 byte)
  - Start CHS (3 bytes)
  - Partition type (1 byte)
  - End CHS (3 bytes)
  - Start LBA (4 bytes)
  - Size in sectors (4 bytes)

---

## 8. UEFI vs BIOS {#uefi-bios}

### UEFI (Unified Extensible Firmware Interface)
- **Opvolger** van BIOS
- **Moderne standaard** voor firmware
- **Backward compatible** met BIOS

### Vergelijkingstabel

| Aspect | BIOS | UEFI |
|--------|------|------|
| **Boot Code** | MBR (1ste sector HDD) | EFI-bestand op EFI System Partition |
| **Partitie Tabel** | MBR | GPT (GUID Partition Table) |
| **Max Partities** | 4 primair (14 met extended) | 128 partities |
| **Partitie Grootte** | 16 bytes in MBR | 128 bytes in GPT |
| **Max Filesystem** | 2 TiB | 8 ZiB |
| **Secure Boot** | Nee | Ja |
| **Boot Loader** | Altijd nodig | Kan direct kernel opstarten |

### UEFI Voordelen
1. **Grotere schijven** (tot 8 ZiB vs 2 TiB)
2. **Meer partities** (128 vs 4)
3. **Sneller opstarten**
4. **Secure Boot** functionaliteit
5. **Grafische interface**
6. **Netwerkondersteuning**

### GPT (GUID Partition Table)
- **GUID**: Globally Unique Identifier
- **128 partities** mogelijk
- **Elk 128 bytes** per partitie-entry
- **Backup GPT** aan einde van schijf
- **Beschermd tegen corruptie**

### EFI System Partition
- **FAT32 filesystem**
- **Bevat EFI boot bestanden**
- **Voorbeeld pad**: `\EFI\BOOT\BOOTx64.EFI`
- **Per OS eigen directory**: `\EFI\Microsoft\`, `\EFI\Ubuntu\`

---

## 9. Belangrijke Concepten en Definities

### Acroniemen en Afkortingen
- **BIOS**: Basic Input/Output System
- **UEFI**: Unified Extensible Firmware Interface
- **EFI**: Extensible Firmware Interface
- **MBR**: Master Boot Record
- **GPT**: GUID Partition Table
- **GUID**: Globally Unique Identifier
- **POST**: Power-On Self Test
- **HAL**: Hardware Abstraction Layer
- **ROM**: Read-Only Memory
- **RAM**: Random Access Memory
- **HDD**: Hard Disk Drive
- **CHS**: Cylinder-Head-Sector
- **LBA**: Logical Block Addressing

### Belangrijke Adressen
- **0x7C00**: Waar BIOS de MBR laadt
- **0xA0000-0xFFFFF**: BIOS geheugen mapping
- **0x55AA**: Boot signature (magic number)

### Sector en Grootte Concepten
- **Sector**: 512 bytes (traditioneel)
- **MBR**: 512 bytes (1 sector)
- **Boot signature**: Laatste 2 bytes van MBR
- **Partition table**: 64 bytes (4×16) in MBR

---

## 10. Examenvragen {#examenvragen}

### Theoretische Vragen
1. **Wat zijn de taken van een besturingssysteem?**
   - Boot-process, hardware abstraction, I/O management, file management, process management, memory management, window management

2. **Wat is een Von Neumann architectuur?**
   - Architectuur met gedeeld geheugen voor programma's en data, instructiecyclus: fetch-decode-execute

3. **Verschil met Harvard architectuur?**
   - Harvard: gescheiden geheugen voor programma's en data; Von Neumann: gedeeld geheugen

4. **Wat is een bus?**
   - Communicatiekanaal tussen processor, geheugen en I/O devices

5. **Wat zijn I/O devices?**
   - Input/Output apparaten zoals keyboard, display, storage devices

6. **Wat is POST?**
   - Power-On Self Test: hardware controle tijdens opstarten

7. **Wat is een HAL?**
   - Hardware Abstraction Layer: interface tussen software en hardware

8. **Welke stappen bij opstarten?**
   - ROM firmware → Boot loader → Kernel → Volledig OS

9. **Hoe ziet MBR eruit?**
   - 446 bytes boot code + 64 bytes partition table + 2 bytes boot signature

10. **Verschillen BIOS en UEFI?**
    - Zie vergelijkingstabel hierboven

11. **Is boot-loader nodig?**
    - BIOS: altijd; UEFI: kan direct kernel opstarten

12. **Nut van boot signature?**
    - Verificatie dat sector een geldige boot sector is (magic number 0x55AA)

13. **Hoe ziet partitietabel eruit?**
    - MBR: 4×16 bytes; GPT: 128×128 bytes

14. **Hoe zien of BIOS of UEFI?**
    - Windows: msinfo32, disk management; Linux: ls /sys/firmware/efi

### Praktische Oefeningen
- **Conversies** tussen decimaal en binair
- **Geheugen berekeningen**
- **MBR analyse** met hexdump
- **UEFI configuratie** in VirtualBox

---

## Tips voor het Examen

1. **Oefen conversies** tussen Ki/Mi/Gi en K/M/G
2. **Onthoud belangrijke adressen**: 0x7C00, 0x55AA
3. **Begrijp het verschil** tussen BIOS en UEFI
4. **Ken de MBR structuur** uit je hoofd
5. **Weet wat elke afkorting betekent**
6. **Begrijp de boot sequence** stap voor stap
7. **Oefen met hexadecimale berekeningen**

Deze samenvatting bevat alle essentiële informatie uit de slides en is gestructureerd voor optimale voorbereiding op het examen.