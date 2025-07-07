# Computersystemen 2 - Bestandsbeheer
## Uitgebreide Handleiding

*Datum: 15-10-2024*

---

## Inhoudsopgave

1. [HDD en SSD](#hdd-en-ssd)
2. [RAID](#raid)
3. [Bestandsystemen](#bestandsystemen)
4. [FAT Tabel](#fat-tabel)
5. [Linux Inodes](#linux-inodes)
6. [Next Gen File Systems](#next-gen-file-systems)
7. [NAS en SAN](#nas-en-san)
8. [Herhalingsvragen](#herhalingsvragen)

---

## HDD en SSD

### HDD - Hard Disk Drive

**HDD** staat voor **Hard Disk Drive** en is een traditionele vorm van gegevensopslag.

#### Componenten van een HDD:
- **Disks (Schijven)**: Ronde magnetische schijven waarop data wordt opgeslagen
- **Heads (Koppen)**: Lees/schrijfkoppen die data van en naar de schijven lezen/schrijven
- **Cylinders (Cilinders)**: Virtuele cilinders gevormd door alle tracks op dezelfde positie van verschillende schijven
- **Tracks (Sporen)**: Concentrische cirkels op elke schijf waarop data wordt opgeslagen
- **Sectors**: Kleinste adresseerbare eenheden op een track

#### Kenmerken van HDD:
- **Magnetische opslag**: Data wordt opgeslagen door magnetische velden
- **Weinig schokbestendig**: Mechanische onderdelen zijn gevoelig voor trillingen
- **Latency**: Vertraging doordat de kop fysiek moet bewegen naar de juiste positie
- **Delete-gedrag**: Wanneer een bestand wordt verwijderd, wordt alleen de verwijzing uit de directory-tabel verwijderd. De sectoren met data blijven fysiek bestaan totdat ze worden overschreven

### SSD - Solid-State Drive

**SSD** staat voor **Solid-State Drive** en is een moderne vorm van gegevensopslag zonder bewegende delen.

#### Componenten van een SSD:
- **Interface**: Verbinding met het systeem (bijvoorbeeld SATA, NVMe)
- **Controller**: Firmware die de werking van de SSD regelt
- **NAND Flash Memory**: Geheugentype dat data opslaat in floating gate transistors

#### NAND Flash Memory Types:
**NAND Flash** gebruikt floating gate transistors die hun toestand behouden zonder stroom (non-volatile memory).

1. **SLC (Single Level Cell)**:
   - Opslag: 1 bit per cel
   - Waarden: 0 of 1
   - Voltage levels: Bijvoorbeeld 0V en 3V
   - Eigenschappen: Snelst, meest betrouwbaar, duurste

2. **MLC (Multi Level Cell)**:
   - Opslag: 2 bits per cel
   - Waarden: 00, 01, 10, 11
   - Voltage levels: Bijvoorbeeld 0V, 1V, 2V, 3V
   - Eigenschappen: Hogere capaciteit, trager, minder betrouwbaar dan SLC

3. **TLC (Triple Level Cell)**:
   - Opslag: 3 bits per cel
   - Eigenschappen: Nog hogere capaciteit, nog trager, nog minder betrouwbaar

#### Unieke eigenschappen van SSD:
- **Write-once pages**: Een geschreven page kan niet direct worden overschreven, maar moet eerst worden gewist
- **TRIM-instructie**: Speciale OS-instructie die aan de SSD doorgeeft welke pages kunnen worden gewist
- **Celdegradatie**: Geheugencellen degraderen bij elke write-cyclus
- **Beperkte write-cycles**: Elk blok heeft een beperkt aantal keren dat het kan worden geschreven
- **Geen defragmentatie**: Defragmentatie is niet nodig en zelfs schadelijk voor SSD's
- **Wear-leveling**: Techniek om writes gelijkmatig over de SSD te verdelen om degradatie te minimaliseren

### Vergelijking SSD vs HDD

| Aspect | SSD | HDD |
|--------|-----|-----|
| **Access Time** | 35-100 μsec | 5-10 ms |
| **Prijs/Capaciteit** | Duurste | Goedkoper (vooral >1TB) |
| **Betrouwbaarheid** | Geen bewegende delen | Mechanische onderdelen |
| **Stroomverbruik** | Minder | Meer |
| **Geluid** | Geen geluid | Draaiende schijven en bewegende koppen |
| **Grootte** | Veel formaten, compact | Meestal 3.5" en 2.5" |
| **Warmte** | Bijna geen warmte | Bewegende delen veroorzaken warmte |
| **Magnetisme** | Geen effect | Kan data wissen |
| **Bestandssysteem** | Geen defragmentatie | Defragmentatie nodig |

---

## RAID

### RAID - Redundant Array of Independent Disks

**RAID** staat voor **Redundant Array of Independent Disks** en is een technologie die meerdere fysieke schijven combineert tot één virtuele schijf.

#### Voordelen van RAID:
- **Grotere bestandssystemen**: Capaciteit van meerdere schijven combineren
- **Parallelle operaties**: Meerdere schijfoperaties tegelijkertijd uitvoeren
- **Redundantie**: Bescherming tegen schijfuitval mogelijk
- **Verbeterde prestaties**: Snellere lees- en/of schrijfoperaties

#### Implementatie van RAID:
1. **Software RAID**: Geïmplementeerd in het besturingssysteem
2. **Hardware RAID**: Geïmplementeerd in hardware, OS weet van niets

### RAID Levels

#### RAID 0 (Striping)
**Striping** betekent dat data wordt verdeeld over meerdere schijven.

**Werkingswijze**:
- Schijven worden verdeeld in kleine delen (strips)
- Data wordt verspreid over alle schijven
- Elke schijf bevat een deel van elk bestand

**Voordelen**:
- Snellere toegang door parallelle lees/schrijfoperaties
- Volledige capaciteit van alle schijven wordt gebruikt

**Nadelen**:
- Geen redundantie: fout in 1 schijf = alle data verloren
- Verhoogde kans op dataverlies (meer schijven = meer failure points)

#### RAID 1 (Mirroring)
**Mirroring** betekent dat alle data op meerdere schijven wordt gedupliceerd.

**Werkingswijze**:
- Verdubbel het aantal schijven
- Alle data wordt identiek opgeslagen op 2 schijven
- Bij uitval van 1 schijf blijft data beschikbaar

**Voordelen**:
- Foutcorrectie mogelijk
- Snelle leestoegang (kan van beide schijven lezen)
- Eenvoudig te implementeren

**Nadelen**:
- Duur (2x aantal schijven nodig)
- Geen capaciteitsvoordeel
- Langzamer schrijven (moet naar beide schijven)

#### RAID 3 (Dedicated Parity)
**Dedicated Parity** gebruikt één schijf specifiek voor redundantie-informatie.

**Werkingswijze**:
- Gebruik 1 schijf voor pariteitsbits
- Pariteit berekend met XOR-operatie: P(b) = b₀ ⊕ b₁ ⊕ b₂ ⊕ b₃
- Bij uitval kan data worden gereconstrueerd

**Voorbeeld reconstructie**:
Als schijf 2 uitvalt en we lezen:
- Schijf 0: 1010 1101
- Schijf 1: 1010 1100  
- Schijf 2: xxxx xxxx (defect)
- Schijf 3: 0010 0000
- Pariteit: 1001 0101

Dan: b₂ = b₀ ⊕ b₁ ⊕ b₃ ⊕ P = 1010 1101 ⊕ 1010 1100 ⊕ 0010 0000 ⊕ 1001 0101

**Voordelen**:
- Goedkoper dan RAID 1
- Mogelijkheid tot foutcorrectie
- Snel lezen

**Nadelen**:
- Traag bij schrijven (pariteit moet steeds worden herberekend)
- Pariteitsschijf wordt bottleneck

#### RAID 5 (Distributed Parity)
**Distributed Parity** spreidt pariteitsinformatie over alle schijven.

**Werkingswijze**:
- Pariteitsbits worden gespreid over alle schijven
- Geen enkele schijf wordt bottleneck
- Elke schijf bevat zowel data als pariteit

**Voordelen**:
- Sneller schrijven dan RAID 3
- Goede balans tussen prestatie, capaciteit en redundantie
- Kan uitval van 1 schijf aan

**Nadelen**:
- Complexere implementatie
- Prestatie-impact bij reconstructie

#### RAID 6 (Double Parity)
**Double Parity** gebruikt meerdere schijven voor redundantie.

**Werkingswijze**:
- Gebruik meerdere schijven voor redundantie
- Complexere berekeningen (Reed-Solomon codes)
- Kan uitval van 2 schijven tegelijkertijd aan

**Voordelen**:
- Meerdere schijven mogen tegelijk uitvallen
- Hogere betrouwbaarheid

**Nadelen**:
- Meer schijven nodig voor redundantie
- Complexere berekeningen
- Lagere schrijfprestaties

### Nested/Hybrid RAID

**Nested RAID** combineert verschillende RAID-levels:
- **RAID 01**: Eerst striping, dan mirroring
- **RAID 10**: Eerst mirroring, dan striping
- **RAID 50**: RAID 5 arrays in RAID 0 configuratie

### Belangrijke RAID-regel

**RAID is geen vervanging voor back-up!**

Redenen waarom back-up nog steeds nodig is:
- Alle schijven kunnen tegelijk uitvallen (power spike)
- Bescherming tegen diefstal
- Off-site opslag bij natuurrampen
- Gebruikersfouten (belangrijkste reden)
- Historische versies van data

---

## Bestandsystemen

### File Management

**File Management** is het deel van het besturingssysteem dat boven disk I/O draait en definieert:

- **Bestanden**: Containers voor data
- **Directories**: Mappen die bestanden organiseren
- **Links**: Verwijzingen naar andere bestanden (shortcuts)
- **Vuilbak**: Tijdelijke opslag voor verwijderde bestanden
- **Meta-informatie**: Bestandsattributen

### Bestandsattributen

Bestandsattributen bevatten metadata over bestanden:

- **Eigenaar**: Wie bezit het bestand
- **Rechten**: Lees/schrijf/uitvoer-rechten (bijvoorbeeld Unix: rwx rwx rwx)
- **Compressie**: Is het bestand gecomprimeerd?
- **Back-up**: Moet het bestand worden gebackupt?
- **Tijdstempels**: Creatie, laatste wijziging, laatste toegang
- **Applicatie-associatie**: Welke applicatie opent dit bestand?
- **Versies**: Zijn er verschillende versies van dit bestand?

### Fragmentatie

#### Interne Fragmentatie

**Interne fragmentatie** ontstaat doordat bestanden worden opgeslagen in blokken van vaste grootte.

**Voorbeeld**:
- Blokgrootte: 4096 bytes
- Bestandsgrootte: 10.000 bytes
- Benodigde blokken: 3 (eerste 2 vol, laatste gedeeltelijk gevuld)
- Verloren ruimte: 4096 - (10.000 - 2×4096) = 2192 bytes

**Berekening gemiddeld verlies**:
- Gemiddeld verlies per bestand: blokgrootte ÷ 2
- Voor 1.000.000 bestanden met 4096-byte blokken: 1.000.000 × 2048 bytes = ~2 GB

**Conclusie**: Kleinere blokken = minder interne fragmentatie

#### Externe Fragmentatie

**Externe fragmentatie** ontstaat wanneer bestanden verspreid staan over niet-aangrenzende blokken.

**Oorzaken**:
- Bestanden worden geschreven en verwijderd
- Er ontstaan "gaten" in het bestandssysteem
- Nieuwe bestanden worden in beschikbare gaten geplaatst

**Gevolgen**:
- Sequentieel lezen wordt trager (HDD kop moet heen en weer)
- Prestatie-impact vooral bij HDD's

**Oplossing**: Defragmentatie (niet bij SSD's!)

**Trade-off**: Grotere blokken = minder externe fragmentatie maar meer interne fragmentatie

### Blokgrootte Bepaling

De blokgrootte van een bestandssysteem bepaalt:
- Hoeveelheid interne fragmentatie
- Impact van externe fragmentatie  
- Maximale grootte van het bestandssysteem
- Maximale grootte van een bestand
- Prestaties van het bestandssysteem

**Overwegingen bij keuze**:
- Soort bestanden op het systeem
- Afweging snelheid vs. ruimteverlies
- Maximale benodigde grootte van bestanden/systeem

**Configuratie commando's**:
```bash
mkfs.ext4 -b block_size
mkfs.vfat -s sectors_per_block
```

---

## FAT Tabel

### File Allocation Table (FAT)

**FAT** staat voor **File Allocation Table** en is een bestandssysteem dat een inhoudstafel bijhoudt voor alle bestanden.

#### FAT Varianten:
- **FAT12**: 12-bit entries, kleine schijven
- **FAT16**: 16-bit entries, tot 4 GB
- **FAT32**: 32-bit entries, veel grotere schijven

### FAT16 Beperkingen

**FAT16** heeft specifieke beperkingen:
- Maximum 65.536 blokken (2¹⁶)
- Maximum blokgrootte: 65.536 bytes
- **Maximale schijfcapaciteit**: 65.536 × 65.536 = 4 GiB

**Interne fragmentatie voorbeeld**:
- 10.000 bestanden op FAT16 systeem
- Gemiddeld verlies: 32.768 bytes per bestand
- Totaal verlies: 327,68 MB

### FAT32 Verbeteringen

**FAT32** lost groottebeperkingen op:
- Zelfde maximum blokgrootte
- 4 miljard blokken mogelijk (2³²)
- Veel grotere schijven ondersteund

### FAT Structuur

Een FAT-partitie bevat:

1. **Boot Sector (Blok 0)**:
   - Bootcode voor opstarten
   - Informatie over de schijfindeling

2. **FAT1 en FAT2 (Blokken 1-2)**:
   - Twee identieke kopieën voor foutcorrectie
   - Array van integers (12/16/32-bit)
   - Evenveel elementen als blokken

3. **Root Directory (Blok 3)**:
   - Informatie over bestanden in root folder
   - Bestandsnaam, startblok, grootte, attributen

4. **Data Area (Resterende blokken)**:
   - Werkelijke bestandsdata

### FAT Werking

#### Directory Tabel Voorbeeld:
```
filename      start  length  attributes
readme.txt    4      15      867
myApp.exe     6      27      814
verslag.doc   16     22      010
```

#### FAT Array Voorbeeld:
```
Blok:  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22...31
FAT:   0  0  0  0  5  8  7 10  9 FF 13  0  0 14 15 31 17 18 19 20 21 FF  0...FF
```

**Interpretatie**:
- Blok 0-3: Systeemblokken (boot, FAT, root)
- Blok 4: Verwijst naar blok 5 (onderdeel van gelinkte lijst)
- FFFF: Einde van bestand
- 0: Vrije blokken (beschikbaar voor nieuwe bestanden)

### FAT Voor- en Nadelen

**Voordelen**:
- Zeer eenvoudig te implementeren
- Breed ondersteund
- Goed compatibel tussen systemen

**Nadelen**:
- Zeer traag bij schrijven
- FAT moet voor elke blok worden aangepast
- FAT wordt dubbel geschreven (mirroring)
- Veel head-beweging bij HDD's

**Oplossing**: Caching
- FAT in geheugen houden
- Periodiek wegschrijven naar schijf
- Risico bij plotselinge uitval

---

## Linux Inodes

### Inode Concept

**Inode** (Index Node) is een datastructuur in Unix/Linux systemen die metadata van een bestand bevat.

#### Inode vs FAT:
- **FAT**: Eén tabel voor alle bestanden
- **Inode**: Eén inode per bestand

### Inode Structuur

#### Directory Structuur:
- Directory is een blok gevuld met pointers naar inodes
- Elke inode bevat bestandsinformatie

#### Inode Inhoud:
- **Filename**: Naam van het bestand
- **Length**: Grootte van het bestand
- **Permissions**: Lees/schrijf/uitvoer rechten
- **Timestamps**: Verschillende tijdstempels
- **16 Pointers**: Verwijzingen naar datablokken

### Inode Pointer Systeem

Een inode bevat 16 pointers met verschillende functies:

#### Direct Pointers (1-13):
- Verwijzen direct naar de eerste 13 datablokken
- Voor kleine bestanden volstaat dit

#### Indirect Pointers:

1. **Single Indirect (Pointer 14)**:
   - Verwijst naar een blok met pointers
   - Dat blok bevat pointers naar datablokken

2. **Double Indirect (Pointer 15)**:
   - Verwijst naar een blok met pointers naar single indirect blokken
   - Twee niveaus van indirectie

3. **Triple Indirect (Pointer 16)**:
   - Verwijst naar een blok met pointers naar double indirect blokken
   - Drie niveaus van indirectie

### Bestandsgrootte Berekeningen

#### Gegeven:
- Blokgrootte: 512 bytes
- Pointers: 32-bit unsigned integers (4 bytes)
- Pointers per blok: 512 ÷ 4 = 128

#### Berekeningen:

**Zonder indirects**:
- Grootte: 13 × 512 = 6.656 bytes

**Zonder double indirects**:
- Grootte: 13 × 512 + 128 × 512 = 6.656 + 65.536 = 72.192 bytes

**Maximum bestandsgrootte**:
- Direct: 13 × 512
- Single indirect: 128 × 512
- Double indirect: 128² × 512  
- Triple indirect: 128³ × 512
- **Totaal**: ≈ 1 GiB

#### Oefening (4096 bytes blokken):
- Pointers per blok: 4096 ÷ 4 = 1024
- Zonder indirects: 13 × 4096 = 53.248 bytes
- Zonder double indirects: 13 × 4096 + 1024 × 4096 ≈ 4,2 MB
- Maximum: 13 × 4096 + 1024 × 4096 + 1024² × 4096 + 1024³ × 4096 ≈ 4 TiB

---

## Next Gen File Systems

### Moderne Bestandssystemen

**Next Generation File Systems** combineren traditionele bestandssystemen met volume management.

#### Voorbeelden:
- **ZFS**: Zettabyte File System
- **Btrfs**: B-tree FS / Better FS

### Belangrijke Eigenschappen

#### Gecombineerde Functionaliteit:
- **File System**: Traditionele bestandsorganisatie
- **Volume Manager**: Schijfbeheer en pooling

#### Geavanceerde Features:

1. **Data Corruption Protection**:
   - Checksums voor data-integriteit
   - Automatische detectie van corrupte data
   - Zelfherstellende mechanismen

2. **High Storage Capacity**:
   - Ondersteuning voor extreem grote volumes
   - Zettabyte-schaal capaciteiten

3. **Copy-on-Write (COW)**:
   - Data wordt eerst gekopieerd voordat het wordt overschreven
   - Verbeterde data-integriteit
   - Efficiënte snapshot-functionaliteit

4. **Snapshots en Cloning**:
   - Instant point-in-time kopieën
   - Ruimte-efficiënte opslag
   - Snelle backup en recovery

5. **Ingebouwde RAID**:
   - RAID-functionaliteit ingebouwd in het bestandssysteem
   - Geen aparte RAID-controller nodig
   - Betere integratie en beheer

### ZFS Voorbeeld Commando's

```bash
# Striping (RAID 0)
zpool create new-pool /dev/sdb1 /dev/sdc1

# Mirroring (RAID 1)  
zpool create new-pool mirror /dev/sdb1 /dev/sdc1

# Met mountpoint
zpool create -m /usr/share/pool new-pool mirror /dev/sdb1 /dev/sdc1

# Status controleren
zpool status

# Pool verwijderen
zpool destroy new-pool
```

---

## NAS en SAN

### Storage over Netwerk

Er zijn verschillende manieren om opslag over het netwerk te delen:

#### DAS - Direct Attached Storage:
- **DAS**: Direct Attached Storage
- HDD/SSD zit direct in de computer
- Geen netwerkdeling

### NAS - Network Attached Storage

**NAS** staat voor **Network Attached Storage** en deelt bestandssystemen over het netwerk.

#### Kenmerken:
- **Niveau**: File-level sharing
- **Bestandssysteem**: Staat op de NAS-box/file server
- **Netwerk**: Gewoon TCP/IP netwerk
- **Protocollen**:
  - **SMB/CIFS**: Server Message Block / Common Internet File System
  - **NFS**: Network File System

#### Gebruik:
- Client ziet "network drives" of "shares"
- Bestanden worden over het netwerk gedeeld
- NAS beheert het onderliggende bestandssysteem

### SAN - Storage Area Network

**SAN** staat voor **Storage Area Network** en deelt blokken over het netwerk.

#### Kenmerken:
- **Niveau**: Block-level sharing
- **Bestandssysteem**: Staat op de client-computer
- **Netwerk**: Gespecialiseerd storage netwerk
- **Protocollen**:
  - **Fibre Channel**: Met SAN switches
  - **iSCSI**: SCSI-commando's in TCP/IP-pakketten

#### Gebruik:
- Client ziet rauwe blokken (alsof het lokale schijf is)
- Client beheert het bestandssysteem
- SAN beheert alleen de fysieke opslag

### Vergelijking NAS vs SAN

| Aspect | NAS | SAN |
|--------|-----|-----|
| **Afkorting** | Network Attached Storage | Storage Area Network |
| **Niveau** | File-level | Block-level |
| **Bestandssysteem** | Op NAS-box | Op client-computer |
| **Netwerk** | TCP/IP | Fibre Channel/iSCSI |
| **Protocollen** | SMB/CIFS, NFS | Fibre Channel, iSCSI |
| **Complexiteit** | Eenvoudiger | Complexer |
| **Prestaties** | Goed voor file sharing | Beter voor databases |
| **Kosten** | Lager | Hoger |

---

## Herhalingsvragen

### HDD en SSD Vragen

1. **Hoe werkt een HDD?**
   - Magnetische schijven draaien rond
   - Lees/schrijfkoppen bewegen over tracks
   - Data wordt magnetisch opgeslagen in sectoren

2. **Hoe werkt een SSD?**
   - NAND Flash geheugen met floating gate transistors
   - Geen bewegende delen
   - Controller beheert wear-leveling en garbage collection

### RAID Vragen

1. **Wat doet RAID-X?**
   - Beschrijf functionaliteit van elk RAID-level
   - Vergelijk voor- en nadelen

2. **RAID-5 Reconstructie Voorbeeld**:
   - Gegeven: RAID-5 met 4 schijven (3 data + 1 pariteit)
   - Schijf 2 valt uit
   - Reconstrueer data met XOR-operatie

### Caching Vragen

1. **Wat is caching bij harde schijven?**
   - **Voordeel**: Snellere toegang tot vaak gebruikte data
   - **Nadeel**: Dataverlies bij plotseling uitvallen

### Fragmentatie Vragen

1. **Interne fragmentatie**:
   - Voorbeeld: 1000 bestanden, 4096-byte blokken
   - Gemiddeld verlies: 2048 bytes per bestand
   - Totaal verlies: 1000 × 2048 = ~2 MB

2. **Externe fragmentatie**:
   - Ontstaat door schrijven en verwijderen van bestanden
   - Bestanden worden verspreid over niet-aangrenzende blokken
   - Oplossing: defragmentatie (niet bij SSD!)

### FAT Vragen

1. **Wat is een File Allocation Table?**
   - Inhoudstafel die bijhoudt welke blokken bij welk bestand horen
   - Array van integers met verwijzingen naar volgende blokken

2. **FAT Analyse Voorbeelden**:
   - Volg gelinkte lijsten door FAT
   - Tel aantal bestanden
   - Bereken vrije ruimte
   - Teken nieuwe FAT na toevoegen bestand

### Linux Inode Vragen

1. **Maximale bestandsgrootte berekenen**:
   - Met/zonder indirects
   - Voor verschillende blokgroottematen
   - Direct + single + double + triple indirect

### Overige Vragen

1. **Hoe bepaal je blokgrootte?**
   - Afweging tussen interne en externe fragmentatie
   - Soort bestanden op het systeem
   - Maximale benodigde grootte

2. **Wat is LVM?**
   - Logical Volume Management
   - Dynamisch resizen van volumes
   - Snapshots en encryptie

3. **Commando's**:
   - **fdisk**: Partitioneren van schijven
   - **mdadm**: RAID-beheer
   - **mkfs**: Bestandssysteem aanmaken  
   - **mount**: Bestandssysteem koppelen

4. **Next-gen eigenschappen**:
   - Copy-on-write
   - Snapshots
   - Data corruption protection
   - Ingebouwde RAID

5. **zpool commando**:
   - Beheert ZFS storage pools
   - Maakt, verwijdert en configureert pools

6. **Verschil SAN vs NAS**:
   - SAN: Block-level, client beheert bestandssysteem
   - NAS: File-level, server beheert bestandssysteem

---

## Praktische Labs

### RAID Lab Stappen:

1. **Voorbereiding**:
   ```bash
   # Voeg 2 virtuele schijven toe aan Linux VM
   ```

2. **Partitioneren**:
   ```bash
   fdisk /dev/sdb
   fdisk /dev/sdc
   ```

3. **RAID Configuratie**:
   ```bash
   mdadm --create /dev/md0 --level=mirror --raid-devices=2 /dev/sdb1 /dev/sdc1
   mdadm --detail /dev/md0
   mdadm --examine /dev/sdb1 /dev/sdc1
   ```

4. **Formatteren**:
   ```bash
   mkfs.ext4 /dev/md0
   ```

5. **Mounten**:
   ```bash
   mount /dev/md0 /mnt/raid1
   ```

### ZFS Lab Stappen:

1. **Voorbereiding**:
   ```bash
   # Hergebruik schijven, verwijder md raid
   mdadm --stop /dev/md0
   ```

2. **ZFS Configuratie**:
   ```bash
   # Installeer ZFS
   apt install zfsutils-linux
   
   # Maak pool
   zpool create new-pool mirror /dev/sdb1 /dev/sdc1
   
   # Controleer status
   zpool status
   ```

---

*Deze handleiding vormt een complete reference voor het vak Computersystemen 2 - Bestandsbeheer. Alle concepten, voorbeelden en praktische oefeningen zijn uitgebreid behandeld met focus op begrip en toepassing.*