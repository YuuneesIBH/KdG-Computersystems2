# Computersystemen 2 - Theorie

## 0. Introductie

### Overzicht van het vak
- **Theorie (30%)**: Nadruk op kennis van interne werking van besturingssystemen
- **Praktijk (70%)**:
  - Scripting / Google Cloud (40%)
  - Docker (30%)
- **Examen**: Laptopexamen na periode 2, gesloten boek

### Taken van een besturingssysteem
- Boot-process
- Hardware abstraction
- I/O management
- File management
- Process management
- Memory management
- Window management

---

## 1. Herhaling

### Grootheden

#### Macht van 2 vs Macht van 10

| Binair | Waarde | Binaire naam | Decimaal | Waarde | Decimale naam |
|--------|--------|--------------|----------|--------|---------------|
| 1 Ki | 2^10 = 1024 | Kibi | 1 K | 10^3 = 1000 | Kilo |
| 1 Mi | 2^20 = 1024² | Mebi | 1 M | 10^6 = 1000² | Mega |
| 1 Gi | 2^30 = 1024³ | Gibi | 1 G | 10^9 = 1000³ | Giga |
| 1 Ti | 2^40 = 1024⁴ | Tebi | 1 T | 10^12 = 1000⁴ | Tera |

### Architecturen

#### Harvard Architectuur
- **Gescheiden geheugen**: Program RAM (ROM) en Data RAM
- **Twee bussen**: Een voor programma's, een voor data
- **Voorbeeld**: Arduino

#### Von Neumann Architectuur
- **Gedeeld geheugen**: Program en data in hetzelfde RAM
- **Eén bus**: Voor zowel instructies als data
- **Instructiecyclus**: fetch, decode, execute
- **Voorbeeld**: Raspberry Pi

### Registers
- **Gegevensregisters**: Tijdelijke opslagplaatsen
- **Adresregisters**: Stack pointer, index registers, segment registers
- **Stuur- en statusregisters**: Program counter, flags

### RAM Geheugen
- **Code**: Machine-code bytes, instructies
- **Data**: Getallen, tekst (ASCII, Unicode, EBCDIC)
- **Probleem**: Data kan als code uitgevoerd worden (beveiligingsrisico)

---

## 2. Booten

### Het bootproces
1. **ROM Firmware**: PowerOn Self Test (POST), Hardware Abstraction Layer (HAL)
2. **Boot loader**: Laden van startup disk naar RAM
3. **Kernel**: Start na laden van disk naar RAM
4. **Volledig OS**: Processen opstarten, filesystemen mounten, netwerk configureren

### BIOS vs UEFI

| Aspect | BIOS | UEFI |
|--------|------|------|
| Boot code | MBR (1ste sector HDD) | EFI-file op EFI systeem partitie |
| Partitietabel | MBR (4 partities × 16 bytes) | GPT (128 partities × 128 bytes) |
| Max filesysteem | 2 TiB | 8 ZiB |
| Secure boot | Nee | Ja |
| Boot-loader vereist | Ja altijd | Kan rechtstreeks kernel opstarten |

### Master Boot Record (MBR)
- **Grootte**: 512 bytes
- **Inhoud**:
  - Boot-loader code
  - Partitietabel
  - Boot signature (magic number)

---

## 3. I/O Beheer

### Beeldscherm

#### Video modes
- **Text-mode**: 80×25 karakters, 1 byte per karakter
- **Grafische mode**:
  - **Indexed**: 1 byte per pixel (kleurnummer uit tabel)
  - **True-color**: 3 bytes per pixel (RGB)

#### Memory-mapped I/O
- VRAM wordt in het geheugenadresruimte gemapt
- Processor kan direct naar VRAM schrijven via normale geheugeninstructies
- **Voorbeeld**: VRAM op 0xA0000, karakter 'A' op positie (5,10): `RAM[0xA0000 + 10*80 + 5] = 65`

### Toetsenbord

#### Keyboard controller registers
- **Data register**: Laatste toetsaanslag
- **Status register**: Is er data klaar?
- **Control register**: Instellingen

#### I/O methoden
1. **Programmed I/O (polling)**:
   ```c
   do {
       status = memory[KEYB_STATUS];
   } while (status != READY);
   char c = memory[KEYB_DATA];
   ```
   **Nadeel**: Verspilt processortijd

2. **Interrupt-driven I/O**:
   - CPU krijgt interrupt van keyboard controller
   - Interrupt Service Routine (ISR) behandelt toetsaanslag
   - Data wordt in circulaire buffer opgeslagen
   - **Voordeel**: Efficiënter gebruik van processortijd

#### Circulaire buffer
- **Leeg**: lees = schrijf
- **Vol**: schrijf = lees - 1
- **Risico**: Buffer overflow

### Disk drives

#### Direct Memory Access (DMA)
- **Probleem**: Grote hoeveelheden data verplaatsen kost veel processortijd
- **Oplossing**: DMA controller krijgt controle over de bus
- Processor kan ondertussen andere taken uitvoeren
- DMA stuurt interrupt wanneer transfer voltooid is

---

## 4. Bestandsbeheer

### HDD vs SSD

| Aspect | HDD | SSD |
|--------|-----|-----|
| Technologie | Magnetisch | NAND Flash Memory |
| Access Time | 5-10 ms | 35-100 μs |
| Bewegende delen | Ja (platters, heads) | Nee |
| Geluid | Ja | Nee |
| Defragmentatie | Nuttig | Schadelijk |
| Magnetisme | Gevoelig | Ongevoelig |

#### SSD specifics
- **SLC**: 1 bit/cel (sneller, betrouwbaarder)
- **MLC**: 2 bits/cel (hogere capaciteit, trager)
- **TLC**: 3 bits/cel (hoogste capaciteit, traagst)
- **Wear-leveling**: Gelijkmatige verdeling van schrijfoperaties
- **TRIM**: OS instrueert SSD welke pages te wissen

### RAID (Redundant Array of Independent Disks)

#### RAID Levels
- **RAID 0 (Striping)**:
  - **Voordeel**: Snellere toegang (parallel)
  - **Nadeel**: Fout in 1 schijf = alle data verloren

- **RAID 1 (Mirroring)**:
  - **Voordeel**: Foutcorrectie, snelle leestoegang
  - **Nadeel**: Duur (2× aantal schijven)

- **RAID 5**:
  - **Pariteitsblokken** verspreid over schijven
  - **Voordeel**: Goedkoper dan RAID-1, sneller schrijven dan RAID-3
  - **Nadeel**: Langzamer dan RAID-0

- **RAID 6**:
  - **Meerdere schijven** voor redundantie
  - **Voordeel**: Meerdere schijven mogen tegelijk falen
  - **Nadeel**: Complexere berekeningen (Reed-Solomon codes)

**Belangrijk**: RAID is geen vervanging voor backup!

### Fragmentatie

#### Interne fragmentatie
- **Oorzaak**: Bestanden nemen niet exact een veelvoud van blokgrootte in
- **Gemiddeld verlies**: Blokgrootte ÷ 2 per bestand
- **Voorbeeld**: 1.000.000 bestanden, blokgrootte 4096 bytes = ~2GB verloren

#### Externe fragmentatie
- **Oorzaak**: Bestanden verspreid over niet-aangrenzende blokken
- **Gevolg**: Langzamer sequentieel lezen (vooral bij HDD)
- **Oplossing**: Defragmentatie (NIET bij SSD!)

### File Allocation Table (FAT)

#### FAT structuur
1. **Boot sector**: Bootcode en schijfgegevens
2. **FAT1 en FAT2**: File allocation tables (voor foutcorrectie)
3. **Root folder**: Directory tabel
4. **Data area**: Eigenlijke bestandsdata

#### FAT werking
- Array met evenveel elementen als blokken
- Elke entry wijst naar volgende blok van bestand
- 0 = vrije blok
- FFFF = laatste blok van bestand

#### FAT voor- en nadelen
- **Voordeel**: Heel eenvoudig
- **Nadeel**: 
  - Traag (FAT moet vaak aangepast en 2× geschreven worden)
  - Veel disk seeks nodig

### Linux Inodes

#### Inode structuur
- **Directe pointers**: 13 pointers naar eerste 13 blokken
- **Single indirect**: Pointer naar blok met pointers
- **Double indirect**: Pointer naar blok met single indirect pointers
- **Triple indirect**: Pointer naar blok met double indirect pointers

#### Maximale bestandsgrootte
Voor blokgrootte 512 bytes, 32-bit pointers:
- **Direct**: 13 × 512 = 6.656 bytes
- **Single indirect**: 128 × 512 = 65.536 bytes
- **Double indirect**: 128² × 512 = 8.388.608 bytes
- **Triple indirect**: 128³ × 512 ≈ 1 GiB
- **Totaal**: ≈ 1 GiB

### Next Generation Filesystems

#### ZFS en Btrfs kenmerken
- **Copy-on-write**: Data wordt gekopieerd bij wijziging
- **Snapshots**: Momentopnames van filesysteem
- **Data integrity**: Bescherming tegen data corruptie
- **Built-in RAID**: Geen aparte RAID controller nodig
- **Compression**: Automatische data compressie

### NAS vs SAN

| Aspect | NAS | SAN |
|--------|-----|-----|
| Niveau | File-level | Block-level |
| Filesysteem | Op NAS box | Op computer |
| Protocol | SMB/CIFS, NFS | Fibre Channel, iSCSI |
| Netwerk | Gewone TCP/IP | Speciale SAN switches |

---

## 5. Geheugenbeheer

### OS Laden

#### Kernel types
- **Monolitische kernel**: Alle functionaliteit in 1 proces
- **Modulaire kernel**: Dynamisch linkbare modules
- **Micro-kernel**: Basis functionaliteit + drivers als aparte processen

### Relocatie en Linking

#### Logische vs Fysieke adressen
- **Logische adressen**: Relatief t.o.v. begin proces
- **Fysieke adressen**: Absoluut t.o.v. begin geheugen
- **Hardware** doet de vertaling

#### Linking
- **Statisch linking**: Object files samengevoegd tot executable
- **Dynamisch linking**:
  - **Voordelen**: Kleinere executables, gedeelde libraries, updates zonder hercompileren
  - **Nadelen**: Runtime dependencies, complexere deployment

### Call Stack werking
```
main() {
    int a = fac(2);
}
int fac(int i) {
    if (i < 2) return 1;
    else return fac(i-1) * i;
}
```

Stack groeit naar beneden:
```
[return-value]
[return address]
[param=2]
[result=0]       <- fac(2)
[return address]
[param=1]
[result=0]       <- fac(1)
```

### Partitionering

#### Vaste partities
- **Gelijke grootte**: 
  - **Voordeel**: Eenvoudig
  - **Nadeel**: Interne fragmentatie, beperkt aantal partities
- **Verschillende groottes**:
  - **Strategie**: Kleinste partitie die groot genoeg is
  - **Nadeel**: Nog steeds interne fragmentatie

#### Dynamische partities
- **Principe**: Partitie even groot als proces
- **Algoritmen**:
  - **First-fit**: Eerste partitie die groot genoeg is
  - **Best-fit**: Kleinste partitie die groot genoeg is
  - **Next-fit**: Vanaf vorige partitie zoeken
- **Probleem**: Externe fragmentatie
- **Oplossing**: Compaction (processen bij elkaar schuiven)

### Segmentation
- **Principe**: Proces verspreid over meerdere segmenten
- **Logisch adres**: Segmentnummer + offset
- **Hardware**: Controleert segmentgrenzen
- **Fout**: Segmentation fault bij overschrijding

#### Segmentation voorbeeld
2 bits voor segmenten:
- Segment 00: start=0x10000, lengte=0x100
- Segment 01: start=0x11F000, lengte=0x100000

### Paging
- **Frame**: Vast blok in RAM geheugen
- **Page**: Blok van proces (zelfde grootte als frame)
- **Page table**: Mapping van page naar frame
- **Voordeel**: Geen externe fragmentatie
- **Hardware**: Page nummer + offset → frame adres + offset

#### Paging berekening
Voor 8-bit pages (256 bytes per page):
- Logisch adres 0x1DC8 = page 0x1D (29), offset 0xC8 (200)
- Als page 29 in frame 5 staat: fysiek adres = 5 × 256 + 200 = 1480

### Virtueel geheugen
- **Principe**: Pages kunnen naar disk geswapped worden
- **Page fault**: Hardware interrupt wanneer page niet in RAM
- **Swapping proces**:
  1. OS zoekt vrij frame (eventueel page uitswappen)
  2. Laad benodigde page van disk
  3. Update page table
  4. Resume proces
- **Thrashing**: Meer tijd aan swapping dan aan nuttige arbeid

---

## 6. Procesbeheer

### Process states
1. **New**: Proces wordt aangemaakt
2. **Ready**: Klaar om uitgevoerd te worden
3. **Running**: Wordt momenteel uitgevoerd
4. **Blocked**: Wacht op I/O of event
5. **Exit**: Proces beëindigd

### Process Control Block (PCB)
- **Context**: Register waarden, program counter
- **Memory management**: Page tables, segment tables
- **I/O status**: Open files, network connections
- **Process info**: PID, parent PID, start time
- **Scheduling**: Priority, CPU time gebruikt

### Linux proces creatie
```c
int pid = fork();  // Kopieer huidige proces
if (pid == 0) {
    // Kind proces
    exec("nieuwe_applicatie");
} else {
    // Ouder proces
    // pid bevat kind proces ID
}
```

### Context Switch
#### Non-preemptive
- **Proces runt** tot return of I/O wait
- **Voordeel**: Eenvoudig
- **Nadeel**: Oneerlijke verdeling processortijd

#### Preemptive
- **OS onderbreekt** proces na time slice
- **Stappen**:
  1. Save registers in PCB
  2. PCB in juiste queue
  3. Kies nieuw proces
  4. Load registers uit nieuwe PCB
  5. Timer instellen
  6. Jump naar proces

### Scheduling algoritmen

#### Batch scheduling
- **FCFS (First Come First Served)**:
  - Kies proces met maximale waiting time
  - Non-preemptive
- **SPN (Shortest Process Next)**:
  - Kies proces met kleinste execution time
  - Risico op starvation
- **SRT (Shortest Remaining Time)**:
  - Preemptive versie van SPN
- **HRRN (Highest Response Ratio Next)**:
  - Response ratio = (w+s)/s
  - Voorkomt starvation

#### Interactive scheduling
- **Round-Robin**:
  - Elke proces krijgt time slice
  - Preemptive
  - **Voordeel**: Eerlijke verdeling
  - **Nadeel**: I/O gebonden processen benadeeld

### Linux scheduling
- **Preemptive round-robin** met prioriteiten
- **Priority/Nice values**:
  - NI: -20 (hoog) tot +19 (laag)
  - PR = NI + 20
- **Default**: PR=20, NI=0

---

## 7. IPC & Threads

### Interprocess Communication (IPC)

#### Unix Pipes
- **FIFO**: First In, First Out
- **Gebruik**: `cat file | grep pattern | sort`
- **Implementatie**: Circulaire buffer in kernel

#### Message Queues
```c
int msgget(key, flags);              // Maak queue
void msgsnd(qid, message, size, flags);  // Stuur bericht
void msgrcv(qid, message, size, type, flags);  // Ontvang bericht
void msgctl(qid, cmd, data);         // Beheer queue
```

#### Shared Memory
```c
int shmget(key, size, flags);        // Maak segment
void *shmat(mid, address, flags);    // Map naar adres
void shmdt(address);                 // Unmap
void shmctl(mid, cmd, data);         // Beheer segment
```

### Threads
- **Light-weight process**: Delen code en data segment
- **Eigen stack**: Lokale variabelen niet gedeeld
- **Voordelen**:
  - Snellere creatie dan processen
  - Snellere context switch
  - Eenvoudigere communicatie (shared memory)

#### Thread implementaties
1. **User-level (N:1)**:
   - **Voordeel**: Geen kernel calls (snel)
   - **Nadeel**: Blocking syscall blokkeert alle threads
2. **Kernel-level (1:1)**:
   - **Voordeel**: Onafhankelijke scheduling
   - **Nadeel**: Kernel overhead
3. **Hybrid (M:N)**:
   - Combineert voordelen van beide

### Gelijktijdigheid

#### Critical Sections
- **Probleem**: Meerdere threads/processen wijzigen dezelfde data
- **Oplossing**: Semaforen

#### Semaforen
```c
sem_init(&sema, 0, 1);    // Initialiseer op 1
sem_wait(&sema);          // P-operatie (probeer te verkrijgen)
// Critical section
sem_post(&sema);          // V-operatie (geef vrij)
sem_destroy(&sema);       // Opruimen
```

#### Deadlock
- **Definitie**: Twee of meer processen wachten op elkaar
- **Voorbeeld**:
  ```c
  Thread 1: lock(A); lock(B); unlock(B); unlock(A);
  Thread 2: lock(B); lock(A); unlock(A); unlock(B);
  ```
- **Voorkoming**: Consistente lock volgorde

### Multi-processor systemen

#### Strategieën
- **Master-Slave**: Eén processor doet scheduling
- **Symmetric (SMP)**: Kernel op elke processor
- **Load balancing**: Werk verdelen over processors

---

## 8. UI & Virtualisatie

### User Interfaces

#### Text terminals
- **Kenmerken**: 80×25 karakters, serial connection
- **Gebruik**: Embedded systemen, servers
- **Unix**: Elke gebruiker heeft een "tty"

#### X Window System
- **Netwerkprotocol**: X applicaties over TCP/IP
- **Componenten**:
  - **X Server**: Beheert scherm, toetsenbord, muis
  - **Window Manager**: Window decoratie en beheer
  - **Desktop Environment**: Menu's, toolbars, widgets

#### Desktop Environments
| Environment | Window Manager | Display Manager | Distributie |
|-------------|---------------|-----------------|-------------|
| GNOME | Mutter | gdm | Ubuntu, Fedora |
| KDE Plasma | kwin | kdm/sddm | Kubuntu |
| Xfce | Xfwm | xdm | Xubuntu |

### Virtualisatie

#### Waarom virtualisatie?
- **Benutting**: Hardware gemiddeld 5-15% belast
- **Deployment**: Snellere installatie nieuwe servers
- **High Availability**: VM's verplaatsen tussen hosts
- **Management**: Klonen, snapshots

#### Virtualisatie types

##### Full Virtualization
- **Type 1 (Bare Metal)**: Hypervisor rechtstreeks op hardware
  - **Voorbeeld**: VMware ESX
- **Type 2 (Hosted)**: Hypervisor op host OS
  - **Voorbeeld**: VirtualBox

##### Paravirtualization
- **Aanpassing**: Guest OS kernel moet aangepast worden
- **Voordeel**: Minder overhead
- **Voorbeeld**: Xen

##### OS Virtualization (Containers)
- **Principe**: Shared kernel tussen containers
- **Voordelen**: Zeer lichte overhead, snelle start
- **Voorbeelden**: Docker, LXD

### Cloud Computing

#### Service Models
- **IaaS**: Infrastructure as a Service (Amazon EC2)
- **PaaS**: Platform as a Service (AWS, Azure)
- **SaaS**: Software as a Service (Salesforce)

#### Deployment Models
- **Public Cloud**: Services voor algemeen publiek
- **Private Cloud**: Dedicated infrastructuur
- **Hybrid Cloud**: Combinatie van public en private

#### Scaling
- **Vertical (Scale Up)**: Meer kracht aan bestaande server
- **Horizontal (Scale Out)**: Meer servers toevoegen
  - **Session Affinity**: Client naar zelfde backend
  - **Stateless design**: Sessie-info in gedeelde database

### Blade Servers
- **Concept**: Meerdere servers in één chassis
- **Gedeeld**: Voeding, koeling, netwerk, management
- **Voordelen**: Ruimtebesparing, energie-efficiëntie, centraal beheer

---

## Examenvragen (Voorbeelden)

### Algemene concepten
- Wat zijn de taken van een besturingssysteem?
- Wat is het verschil tussen Von Neumann en Harvard architectuur?
- Wat is POST? Wat is een HAL?

### Booten
- Welke stappen worden uitgevoerd bij het opstarten?
- Wat zijn de verschillen tussen BIOS en UEFI?
- Hoe ziet de MBR eruit?

### I/O
- Wat is memory-mapped I/O? Wat zijn de voordelen?
- Wat is het verschil tussen programmed I/O en interrupt-driven I/O?
- Wat is een DMA controller? Waarom is die nodig?

### File systems
- Wat is interne/externe fragmentatie?
- Hoe werkt een FAT filesysteem?
- Wat is het verschil tussen SAN en NAS?

### Memory management
- Wat is het verschil tussen partitionering, segmentatie en paging?
- Wat is virtueel geheugen? Hoe werkt het?
- Wat is een page fault?

### Process management
- Wat is een PCB?
- Wat is het verschil tussen pre-emptive en non-preemptive scheduling?
- Hoe start een proces in Linux (fork/exec)?

### IPC & Threads
- Wat is het verschil tussen een proces en een thread?
- Wat zijn semaforen? Hoe werken ze?
- Wat zijn deadlocks? Wanneer treden ze op?

### Virtualisatie
- Wat is het verschil tussen full virtualisatie en paravirtualisatie?
- Wat is het verschil tussen IaaS, PaaS en SaaS?
- Wat zijn containers? Hoe verschillen ze van VM's?