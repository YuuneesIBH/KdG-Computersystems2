# Computersystems 2 - UI & Virtualisatie

## Inhoudsopgave
- [User Interfaces](#user-interfaces)
- [X Windows](#x-windows)
- [Virtualisatie](#virtualisatie)
- [Cloud Computing](#cloud-computing)
- [Blade Servers](#blade-servers)

---

## User Interfaces

### Text Terminals

**Definitie:** Een text terminal is een combinatie van een scherm en toetsenbord die uitsluitend karakter-output kan weergeven.

**Kenmerken:**
- **Resolutie:** Typisch 80 kolommen × 25 rijen karakters
- **Verbinding:** Via serial connection of modem (telnet protocol)
- **Gebruik:** Veel gebruikt voor communicatie met embedded systemen

**Toepassingen:**
- Router configuratie
- Auto-elektronica
- Industriële systemen

**Unix/Linux context:**
- **TTY (TeleTYpewriter):** Elke gebruiker heeft een eigen tty
- **Standaard streams:** Elk proces heeft drie standaard streams:
  - `stdin`: Input-stream vanuit terminal
  - `stdout`: Output-stream naar terminal
  - `stderr`: Error-stream (standaard naar terminal)

**Architectuur:**
```
Computer ←→ Terminal (serial connection)
Computer ←→ Terminal (serial connection)
```

### Windowing Systems

**Probleem:** Meerdere processen op één scherm vereist een windowing system.

**Definitie:** Een windowing system is een softwarelaag tussen applicatie en besturingssysteem die de hardware bestuurt.

**Concepten:**
- **Window:** Virtueel scherm voor een applicatie
- **Windowing system:** Beheert meerdere windows op één fysiek scherm

**Implementatie-opties:**
1. **Ingebouwd in OS:** Microsoft Windows
2. **Apart proces:** X-Windowing System (Unix/Linux)

---

## X Windows

### X Window System Overzicht

**Afkortingen:**
- **X11:** X Window System versie 11
- **MIT:** Massachusetts Institute of Technology (ontwikkelaar)

**Doelstellingen:**
- Ondersteuning voor meerdere gebruikers op één systeem
- Netwerk-transparantie: X-applicaties van verschillende computers op één X-server

**Architectuur:**
```
Computer 1 ←→ X-server (Scherm/Toetsenbord/Muis)
Computer 2 ←→ X-server (TCP/IP netwerk)
```

### X Window System Componenten

**X-server:**
- Aparte machine of proces
- Ontvangt berichten via TCP/IP connectie
- Beheert hiërarchie van windows (zonder randen)
- Tekent grafische elementen (punten, lijnen, bitmaps)
- Vangt events op en stuurt door naar applicaties

**Alternatieven:**
- **Windows:** MobaXterm voor X-server functionaliteit
- **Wayland:** Moderne vervanger van X

### X Window System Architectuur

**Hoofdcomponenten:**

1. **X Server:**
   - Basis grafische server

2. **Display Manager:**
   - **Greeter:** Inloginterface
   - **Startup scripts:** Uitvoeren bij opstarten
   - **XDM Protocol:** X Display Manager protocol

3. **Window Manager:**
   - Gewoon proces (niet ingebouwd)
   - Tekent randen van windows
   - Regelt window-operaties:
     - Minimaliseren/maximaliseren
     - Verplaatsen/vergroten/verkleinen

4. **Desktop Environment:**
   - Menu's en toolbars
   - Widgets
   - File browser
   - Geïntegreerde gebruikerservaring

### Desktop Environments

**Populaire Desktop Environments:**

| Desktop Environment | Window Manager | Display Manager | Programmeertaal | Distributies |
|-------------------|---------------|----------------|----------------|-------------|
| **GNOME** | Mutter | gdm | C | Ubuntu, Redhat, Debian, Fedora |
| **KDE Plasma** | kwin | kdm/sddm | C++ | Kubuntu |
| **Xfce** | Xfwm | xdm | C | Xubuntu |
| **Unity** | Compiz | lightdm | C++ | Ubuntu 16.04 (legacy) |

**Afkortingen:**
- **GNOME:** GNU Network Object Model Environment
- **KDE:** K Desktop Environment
- **Xfce:** XForms Common Environment
- **gdm:** GNOME Display Manager
- **kdm:** KDE Display Manager
- **sddm:** Simple Desktop Display Manager
- **xdm:** X Display Manager

### SSH X Forwarding

**Doel:** X-applicatie op Host B gebruiken vanaf Host A (weergave op X-server van Host A)

**Configuratie:**
```bash
# Host B (server):
sudo apt-get install openssh-server

# Host A (client):
ssh -X hostB
# Start X applicatie
```

**Hoe het werkt:**
- SSH tunnel voor X11 verkeer
- X-applicatie draait op Host B
- Weergave gebeurt op Host A
- Veilige verbinding via SSH

### Terminal Services (Microsoft)

**Definitie:** Microsoft's antwoord op X-Windowing System

**Kenmerken:**
- **Terminal:** Scherm/toetsenbord/muis = "thin client"
- **Verbinding:** Via netwerk naar computer
- **Protocol:** RDP (Remote Desktop Protocol)

**Oorspronkelijk doel:** Sessie overnemen (remote assistance)

**Werking:**
- Drivers voor scherm/toetsenbord/muis worden vervangen
- Nieuwe drivers communiceren met terminal
- Ondersteuning voor meerdere gelijktijdige sessies/gebruikers

---

## Virtualisatie

### Waarom Virtualisatie?

**Hoofdredenen:**

1. **Hardware Benutting:**
   - Gemiddeld slechts 5-15% belasting van servers
   - Significante kostenbesparing

2. **Deployment:**
   - Snellere installatie van nieuwe servers
   - Self-deployment mogelijkheden

3. **High-Availability en Load-Balancing:**
   - Pool van virtuele servers op verschillende fysieke servers
   - Betere fault tolerance

4. **Management:**
   - **Klonen:** Exact kopiëren van VM's
   - **Snapshots:** Moment-opnames voor backup/restore
   - **Anti-virus:** Op hypervisor niveau

5. **Storage:**
   - VM's op NAS (Network Attached Storage) of SAN (Storage Area Network)
   - **Deduplicatie:** Eliminatie van duplicate data

### Data Deduplicatie

**Definitie:** Techniek om duplicate data te elimineren en storage efficiëntie te verbeteren.

**Voordelen:**
- Verminderde storage kosten
- Snellere backup/restore
- Efficiënter netwerkgebruik

**Voorbeeld:** VMware VMotion gebruikt deduplicatie voor VM migratie

### Soorten Virtualisatie

#### 1. Full Virtualisation

**Kenmerken:**
- Hardware wordt volledig gevirtualiseerd
- Guest OS heeft geen aanpassingen nodig
- Guest OS weet niet dat het op VM draait

**Type 2 Hypervisor (Hosted):**
```
Hardware
├── Host OS
    └── Hypervisor
        ├── VM 1
        ├── VM 2
        └── VM ...
```

- Hypervisor draait op host OS
- **Voorbeeld:** VirtualBox, VMware Workstation

**Type 1 Hypervisor (Bare Metal):**
```
Hardware
├── Hypervisor
    ├── VM 1
    ├── VM 2
    └── VM ...
```

- Hypervisor draait rechtstreeks op hardware
- **Voorbeeld:** VMware ESX, Microsoft Hyper-V

#### 2. Paravirtualisation

**Kenmerken:**
- Guest OS kernel vereist aanpassingen
- User applicaties blijven ongewijzigd
- Hypervisor heeft minder overhead
- **Voorbeeld:** Xen

**Voordelen:**
- Betere prestaties dan full virtualisation
- Directere communicatie met hypervisor

#### 3. OS Virtualisation (Containers)

**Kenmerken:**
- Host kernel wordt gedeeld door alle guests
- Guest OS = Host OS
- Geen hardware abstractie
- Zeer snelle uitvoering

```
Hardware
├── Kernel
    ├── Container 1
    ├── Container 2
    └── Container ...
```

**Voorbeelden:**
- **Docker:** Populairste container platform
- **LXD:** Linux containers
- **Solaris Containers:** Oracle Solaris

---

## Cloud Computing

### Cloud Service Models

**Afkortingen:**
- **IaaS:** Infrastructure as a Service
- **PaaS:** Platform as a Service
- **SaaS:** Software as a Service

**Service Models:**

1. **IaaS (Infrastructure as a Service):**
   - **Voorbeeld:** Amazon EC2 (Elastic Compute Cloud)
   - Virtuele machines en infrastructuur
   - Gebruiker beheert OS en applicaties

2. **PaaS (Platform as a Service):**
   - **Voorbeelden:** AWS, Microsoft Azure Web Sites
   - Platform voor applicatie-ontwikkeling
   - Gebruiker beheert alleen applicaties

3. **SaaS (Software as a Service):**
   - **Voorbeeld:** Salesforce.com
   - Volledige applicatie als service
   - Gebruiker gebruikt alleen de applicatie

### Cloud Deployment Models

**Deployment Types:**

1. **Public Cloud:**
   - Services beschikbaar voor algemeen publiek
   - Gehost door cloud provider
   - Kostenefficïent, schaalbaar

2. **Private Cloud:**
   - Exclusief voor één organisatie
   - Meer controle en beveiliging
   - Hogere kosten

3. **Hybrid Cloud:**
   - Combinatie van public en private cloud
   - Flexibiliteit en optimalisatie

### Cloud Scaling

**Scaling Strategieën:**

1. **Vertical Scaling (Scale Up):**
   - Meer kracht toevoegen aan bestaande server
   - CPU, RAM uitbreiden
   - Beperkt door hardware limieten

2. **Horizontal Scaling (Scale Out):**
   - Meer servers toevoegen
   - Betere fault tolerance
   - Onbeperkte schaling mogelijk

**Overwegingen bij Horizontal Scaling:**
- **Sessie-informatie:** Opslaan in gemeenschappelijke database of in-memory datastore (Redis)
- **Session Affinity:** Requests van specifieke client naar dezelfde backend server sturen
- **Load Balancer:** Verdeling van verkeer over meerdere servers

---

## Blade Servers

### Definitie en Kenmerken

**Blade Server:** Gestroomlijnde server die ontworpen is om minimale ruimte te gebruiken en energie te verbruiken.

**Gedeelde Resources:**
- **Voeding:** Gemeenschappelijke power supply units
- **Koeling:** Gedeelde koelsystemen
- **Netwerk:** Gemeenschappelijke netwerkinfrastructuur
- **Management:** Centraal beheer van alle blades

**Voordelen:**
- Ruimtebesparing in datacenter
- Energie-efficiëntie
- Vereenvoudigd beheer
- Kostenreductie

**Architectuur:**
```
Blade Chassis
├── Blade Server 1
├── Blade Server 2
├── Blade Server ...
├── Shared Power Supply
├── Shared Cooling
└── Shared Network Infrastructure
```

---

## Samenvatting Examenvragen

### Kernconcepten en Afkortingen

**X-Windows:**
- **X11:** X Window System versie 11
- **MIT:** Massachusetts Institute of Technology
- **RDP:** Remote Desktop Protocol
- **SSH:** Secure Shell
- **TTY:** TeleTYpewriter

**Virtualisatie:**
- **VM:** Virtual Machine
- **NAS:** Network Attached Storage
- **SAN:** Storage Area Network
- **ESX:** VMware ESX Server

**Cloud Computing:**
- **IaaS:** Infrastructure as a Service
- **PaaS:** Platform as a Service
- **SaaS:** Software as a Service
- **EC2:** Elastic Compute Cloud

**Desktop Environments:**
- **GNOME:** GNU Network Object Model Environment
- **KDE:** K Desktop Environment
- **Xfce:** XForms Common Environment

### Samenhang tussen Concepten

1. **UI Evolution:**
   Text Terminals → Windowing Systems → X-Windows → Modern Desktop Environments

2. **Virtualisatie Spectrum:**
   Physical Hardware → Full Virtualisation → Paravirtualisation → Containers

3. **Cloud Computing Stack:**
   Infrastructure (IaaS) → Platform (PaaS) → Software (SaaS)

4. **Scaling Relationship:**
   Single Server → Vertical Scaling → Horizontal Scaling → Cloud Computing

Deze concepten vormen samen het fundament van moderne computersystemen, van gebruikersinterfaces tot cloud-gebaseerde infrastructuur.