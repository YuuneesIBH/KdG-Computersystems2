# Geheugenbeheer - Computersystems 2

## Inleiding
Het geheugenbeheer is een cruciaal onderdeel van een besturingssysteem dat bepaalt hoe programma's in het RAM-geheugen worden geladen, georganiseerd en beheerd. Dit document behandelt alle aspecten van geheugenbeheer, van het laden van het OS tot geavanceerde technieken zoals virtueel geheugen.

## 1. Laden van het Operating System (OS)

### Von Neumann Architectuur
Het laden van het OS is mogelijk dankzij de **Von Neumann architectuur**, waarbij instructies en data in hetzelfde geheugen worden opgeslagen. Dit betekent dat programma's (inclusief het OS) als data kunnen worden behandeld en in het geheugen geladen.

### Kernel Types

#### 1. Monolitische Kernel
- **Definitie**: Alle OS-functionaliteiten zitten in één groot codeblok (één proces)
- **Voordelen**: Snelle communicatie tussen OS-componenten
- **Nadelen**: 
  - Bij wijzigingen (bijv. nieuwe device driver) moet de hele kernel opnieuw gelinkt worden
  - Systeem moet rebooten
  - Minder modulair en flexibel

#### 2. Modulaire Kernel
- **Definitie**: Kernel bestaat uit een kernproces dat dynamisch gelinkt is
- **Werking**: Kernel modules (zoals device drivers) kunnen tijdens runtime geladen of weggehaald worden
- **Voordelen**: 
  - Flexibiliteit zonder reboot
  - Kleinere kernel size
  - Modules kunnen on-demand geladen worden

#### 3. Micro-kernel
- **Definitie**: Micro-kernel bevat alleen basis OS-functionaliteit
- **Werking**: Alle andere functionaliteiten (HDD-drivers, scherm-drivers, netwerk, file management) zijn aparte processen
- **Communicatie**: Processen communiceren via **IPC (Inter-Process Communication)**
- **Voordelen**: 
  - Zeer modulair
  - Betere stabiliteit (crash van één driver crasht niet hele systeem)
  - Betere beveiliging
- **Nadelen**: Overhead door IPC-communicatie

### Ubuntu Kernel Modules
- **Extensie**: `.ko` (Kernel Object)
- **Locatie**: `/lib/modules/$(uname -r)/kernel/`
- **Commando om geladen modules te zien**: `lsmod`

## 2. Laden van Processen

### Het Probleem
Wanneer een programma opstart, moet het in het RAM-geheugen geladen worden. Het probleem is dat een programma op verschillende locaties in het geheugen terecht kan komen, wat problemen veroorzaakt met:
- Jump-instructies (JMP)
- Gegevenslocaties
- Absolute adressen

### Relocatie
**Relocatie** is het proces waarbij geheugenreferenties aangepast worden zodat een programma op verschillende locaties kan draaien.

#### Logische vs. Fysieke Adressen
- **Logische adressen**: Relatief ten opzichte van het begin van het proces
- **Fysieke adressen**: Absoluut ten opzichte van het begin van het geheugen
- **Vertaling**: Software gebruikt logische adressen, hardware vertaalt naar fysieke adressen

#### Voorbeeld: 8086 Processor
De 8086 processor gebruikt **Segment Registers** voor relocatie:
- **Segment Registers**: 16-bit registers die met 16 vermenigvuldigd worden (omdat adresbus 20-bit is)
- **Segmenten**: 
  - **Code Segment**: Bevat programma-instructies
  - **Data Segment**: Bevat globale variabelen en heap
  - **Stack Segment**: Bevat lokale variabelen en parameters

**Formule**: Fysiek adres = (Segment Register × 16) + Logisch adres

## 3. Linken

### Definitie
**Linken** is het proces waarbij verschillende programmamodules samengevoegd worden tot een uitvoerbaar bestand.

### Proces
1. **Compilatie**: Elke module wordt gecompileerd naar een object-file (.o)
2. **Object-file**: Bevat machine code en labels
3. **Linker**: Voegt object-files samen en vervangt labels door adressen

### Statisch vs. Dynamisch Linken

#### Statisch Linken
- **Definitie**: Alle benodigde code wordt in het uitvoerbare bestand opgenomen
- **Voordelen**: 
  - Geen dependencies tijdens runtime
  - Sneller opstarten
- **Nadelen**: 
  - Grote executable files
  - Geen code sharing tussen processen
  - Bij updates moet hele programma opnieuw gecompileerd worden

#### Dynamisch Linken
- **Definitie**: Externe libraries worden pas tijdens runtime geladen
- **Bestandstypen**: 
  - Linux: `.so` (Shared Object)
  - Windows: `.dll` (Dynamic Link Library)
- **Voordelen**: 
  - Kleinere executable files
  - Code sharing tussen processen (één library in geheugen)
  - Updates mogelijk zonder recompilatie
  - Functionaliteit uitbreidbaar tijdens runtime
- **Nadelen**: 
  - Dependencies tijdens runtime
  - Iets langzamer opstarten

### Compile Lab Commando's
```bash
# Compileren naar object files
gcc -c myApp.c fib.c

# Bekijk object file inhoud
objdump -d fib.o

# Statisch linken
gcc -o myApp_stat myApp.o fib.o

# Dynamisch linken - shared object maken
gcc -c -fPIC fib.c
gcc -shared -Wl,-soname,libfib.so.1 -o libfib.so.1.0 fib.o
ln -s libfib.so.1.0 libfib.so.1
ln -s libfib.so.1.0 libfib.so

# Dynamisch linken - executable maken
gcc -L. myApp.c -lfib -o myApp_dyn
export LD_LIBRARY_PATH=.

# Dependencies bekijken
ldd myApp_dyn
```

## 4. Call Stack

### Geheugenstructuur van een Proces
Een programma bestaat uit drie hoofdcomponenten:
1. **Code**: Machine-instructies
2. **Data**: Globale variabelen, statische data, dynamische variabelen (heap)
3. **Stack**: Lokale variabelen, parameters, return values, return addresses

### Werking van de Call Stack
De stack groeit naar beneden en bevat per functie-aanroep:
- **Parameters**: Argumenten van de functie
- **Return Address**: Waar de uitvoering moet verdergaan na return
- **Lokale Variabelen**: Variabelen binnen de functie
- **Return Value**: Resultaat van de functie

### Voorbeeld: Recursieve Functie
```c
int fac(int i) {
    int result = 0;
    if (i < 2) result = 1;
    else result = fac(i-1) * i;
    return result;
}
```

Bij `fac(2)` ontstaat volgende stack:
```
fac(2): param=2, result=0, return_address
fac(1): param=1, result=0, return_address
fac(1): result=1, return_value=1
fac(2): result=2, return_value=2
```

## 5. Geheugenbeheer Strategieën

### Overzicht
Geheugenbeheer houdt bij welke delen van het geheugen in gebruik zijn en welke niet. Er zijn drie hoofdstrategieën:

| Strategie | Aaneengesloten | Blokgrootte | Flexibiliteit |
|-----------|----------------|-------------|---------------|
| Partitionering | Ja | Vast/Dynamisch | Beperkt |
| Segmentatie | Nee | Dynamisch | Gemiddeld |
| Paging | Nee | Vast | Hoog |

## 6. Partitionering

### Vaste Partities

#### Gelijke Grootte
- **Werking**: RAM wordt opgedeeld in partities van gelijke grootte
- **Voordelen**: 
  - Eenvoudig te implementeren
  - Processen kunnen gemakkelijk naar schijf geschreven worden (swapping)
- **Nadelen**: 
  - **Interne fragmentatie**: Ongebruikte ruimte binnen partities
  - Proces mag niet groter zijn dan partitie
  - Vast aantal partities

#### Verschillende Groottes
- **Werking**: Partities hebben verschillende groottes
- **Toewijzing**: Proces krijgt kleinste partitie die groot genoeg is
- **Voordelen**: Meer mogelijkheden voor grotere processen
- **Nadelen**: Nog steeds interne fragmentatie en vast aantal partities

### Dynamische Partitionering

#### Werking
- OS houdt gelinkte lijst bij van vrije partities
- Partities worden dynamisch gecreëerd bij laden van proces
- Partitie is exact zo groot als het proces
- **Geen interne fragmentatie**

#### Placement Algorithms
1. **First-fit**: Eerste partitie die groot genoeg is
2. **Best-fit**: Kleinste partitie die groot genoeg is
3. **Next-fit**: Vanaf vorige partitie zoeken

#### Externe Fragmentatie
- **Probleem**: Kleine, onbruikbare stukken geheugen blijven over
- **Oplossing**: **Compactation** - alle processen bij elkaar schuiven

### Relocatie bij Partitionering
- **Beginadres B**: Start van de partitie
- **Logisch adres O**: Offset binnen partitie
- **Fysiek adres**: B + O

## 7. Segmentatie

### Concept
**Segmentatie** is een uitbreiding van dynamische partitionering waarbij een proces verspreid kan zijn over verschillende segmenten die niet aaneengesloten hoeven te zijn.

### Werking
- Elk segment heeft een **segment nummer**
- **Segment Table** bevat voor elk segment:
  - **Beginadres (B)**: Waar het segment in het geheugen begint
  - **Lengte (L)**: Grootte van het segment
- **Logisch adres** bestaat uit:
  - **Segment nummer**
  - **Offset** binnen dat segment

### Adresvertaling
1. Hardware splitst logisch adres in segment nummer en offset
2. Segment nummer wordt gebruikt om beginadres op te zoeken in segment table
3. Controle: offset < lengte van segment
4. Fysiek adres = beginadres + offset
5. Bij overschrijding: **Segmentation Fault** (interrupt)

### Voorbeeld Berekening
Gegeven segment table:
- Segment 00: Start 0x00010000, Lengte 0x00000100
- Segment 01: Start 0x0011F000, Lengte 0x00100000

Logisch adres 0x400FAE23:
- Segment: 01 (eerste 2 bits)
- Offset: 0x00FAE23
- Fysiek adres: 0x0011F000 + 0x00FAE23 = 0x0021DE23

## 8. Paging

### Concept
**Paging** combineert voordelen van vaste partitionering met flexibiliteit van segmentatie.

### Terminologie
- **Frame**: Vast blok in RAM-geheugen (typisch 1KiB, 4KiB)
- **Page**: Blok van proces, zelfde grootte als frame
- **Page Table**: Houdt bij welke page in welke frame zit

### Werking
1. Proces wordt opgedeeld in pages
2. Pages worden toegewezen aan vrije frames
3. Frames hoeven niet aaneengesloten te zijn
4. Page table houdt mapping bij

### Adresvertaling
- **Logisch adres** = Page nummer + Offset
- **Hardware lookup**: Page nummer → Frame nummer (via page table)
- **Fysiek adres** = Frame startadres + Offset

### Voordelen van Paging
- **Geen externe fragmentatie**
- **Flexibele geheugenindeling**
- **Eenvoudige adresvertaling** (frame grootte is macht van 2)

### Nadelen
- **Dubbele geheugentoegangen** (page table + data)
- **Oplossing**: Caching of page table in processor

### Voorbeeld Berekening
8-bit pages, logisch adres 1101 1100 1101 1000:
- Page nummer: 1101 1100 (220)
- Offset: 1101 1000 (216)
- Page table lookup: Page 220 → Frame X
- Fysiek adres: Frame X startadres + 216

## 9. Virtueel Geheugen

### Concept
**Virtueel geheugen** breidt het beschikbare geheugen uit door niet-gebruikte pages naar **swap space** op de harddisk te schrijven.

### Werking
1. **Uitswappen**: Niet-gebruikte pages naar disk schrijven
2. **Inswappen**: Pages van disk naar RAM laden wanneer nodig
3. **Swap space**: File of aparte partitie op HDD/SSD

### Page Fault
Wanneer CPU een page nodig heeft die niet in RAM staat:
1. **Page fault interrupt** wordt gegenereerd
2. OS zoekt vrije frame (mogelijk andere page uitswappen)
3. Gewenste page wordt ingeladen
4. Page table wordt bijgewerkt
5. Proces wordt hervat

### Voordelen
- **Meer programma's** kunnen geladen worden dan RAM groot is
- **Efficiënt geheugengebruik**
- **Multitasking** wordt mogelijk

### Design Issues

#### Performance
- **Swapping kost veel tijd** → moet geminimaliseerd worden
- **Thrashing**: OS besteedt meer tijd aan swappen dan aan proces uitvoering

#### Page Replacement Algorithms
- **LRU (Least Recently Used)**: Langst niet gebruikte page
- **LFU (Least Frequently Used)**: Minst gebruikte page
- **FIFO (First In, First Out)**: Oudste page

#### Page Loading Strategies
- **Demand paging**: Only load pages when needed
- **Prefetching**: Ook naburige pages laden

#### Other Considerations
- **Page size**: Bepaalt performantie en geheugengebruik
- **Locked frames**: Frames die niet uitgewisseld mogen worden (OS kernel)

### Ubuntu Page Size
Commando om page size te controleren:
```bash
getconf PAGE_SIZE
```
Typisch: 4096 bytes (4KiB)

## 10. Samenhang en Evolutie

### Historische Ontwikkeling
1. **Vaste partities** → Eenvoudig maar inflexibel
2. **Dynamische partities** → Flexibeler maar externe fragmentatie
3. **Segmentatie** → Oplossing voor fragmentatie maar complex
4. **Paging** → Beste van beide werelden
5. **Virtueel geheugen** → Uitbreiding van beschikbaar geheugen

### Moderne Systemen
Moderne besturingssystemen gebruiken vaak een **combinatie**:
- **Segmentatie + Paging**: Logische indeling (segmenten) + fysieke indeling (pages)
- **Virtueel geheugen**: Standaard in alle moderne OS
- **Memory Management Unit (MMU)**: Hardware ondersteuning voor adresvertaling

### Performance Optimalisaties
- **Translation Lookaside Buffer (TLB)**: Cache voor page table entries
- **Multi-level page tables**: Hiërarchische page tables voor grote adresruimtes
- **Demand paging**: Pages alleen laden wanneer nodig
- **Copy-on-write**: Efficiënte geheugenindeling bij process forking

## 11. Herhalingsvragen

### Conceptuele Vragen
1. **Kernel Types**: Wat zijn de verschillen tussen monolitische, modulaire en micro-kernels?
2. **Linking**: Wat is het verschil tussen statisch en dynamisch linken?
3. **Fragmentatie**: Wat is interne vs. externe fragmentatie?
4. **Virtueel geheugen**: Hoe werkt virtueel geheugen en wat is thrashing?

### Praktische Berekeningen
1. **Segmentatie**: Gegeven segment table, bereken fysieke adressen
2. **Paging**: Gegeven page table, bereken fysieke adressen
3. **Partitionering**: Welk algoritme (first-fit, best-fit, next-fit) is beste?

### Belangrijke Termen
- **Segmentation Fault**: Interrupt bij overschrijding segmentgrens
- **Page Fault**: Interrupt bij toegang tot niet-geladen page
- **Thrashing**: Systeem besteedt meer tijd aan swappen dan aan nuttige werk
- **Compactation**: Proces om externe fragmentatie op te lossen

## Conclusie

Geheugenbeheer is een complex maar essentieel onderdeel van moderne besturingssystemen. De evolutie van eenvoudige partitionering naar geavanceerde virtuele geheugen systemen toont de voortdurende zoektocht naar efficiënte en flexibele geheugenindeling. Moderne systemen combineren verschillende technieken om optimale performance en flexibiliteit te bieden.