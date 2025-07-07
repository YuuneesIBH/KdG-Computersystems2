# IPC & Threads - Computersystems 2

## Inleiding
Dit document behandelt twee cruciale aspecten van moderne besturingssystemen: **Inter-Process Communication (IPC)** en **Threads**. Deze concepten zijn essentieel voor het begrip van hoe processen samenwerken en hoe parallelle verwerking wordt gerealiseerd.

## 1. Interprocess Communication (IPC)

### Waarom IPC?
Processen hebben normaal gesproken hun **eigen afgeschermde geheugenruimte**. Dit is goed voor beveiliging en stabiliteit, maar soms moeten processen communiceren voor:
- **Copy/paste functionaliteit**
- **Parallel processing** (taken verdelen over meerdere processen)
- **Micro-kernel architectuur** (waar OS-componenten aparte processen zijn)

### IPC Mechanismen

#### Unix IPC
1. **Pipes**
2. **Message Queues**
3. **Shared Memory**

#### Windows IPC
1. **Pipes**
2. **Clipboard**
3. **Files**

## 2. Unix Pipes

### Concept
- Elk proces heeft **stdin** (standard input), **stdout** (standard output) en **stderr** (standard error)
- **Pipe** koppelt stdout van één proces aan stdin van ander proces
- **FIFO** (First In, First Out) principe

### Voorbeeld
```bash
cat filename | grep 'class' | sort
```
- `cat` output wordt input voor `grep`
- `grep` output wordt input voor `sort`

### Implementatie
- OS heeft per pipe een **circulaire buffer**
- Processen kunnen schrijven en lezen uit deze buffer
- C-implementatie via `pipe()` system call

```c
int pipe_fd[2];
pipe(pipe_fd);  // Creëert read/write file descriptors
```

## 3. Unix Message Queues

### Concept
Message queues zijn **geïdentificeerde wachtrijen** waar processen berichten naar kunnen sturen en van kunnen ontvangen.

### System Calls

#### `msgget(key, flags)`
- **Functie**: Creëert een message queue
- **Return**: Queue ID
- **Parameters**:
  - `key`: Unieke identifier voor de queue
  - `flags`: Permissies en opties (bijv. `IPC_CREAT`)

#### `msgsnd(qid, message, size, flags)`
- **Functie**: Zendt een bericht naar een queue
- **Parameters**:
  - `qid`: Queue ID
  - `message`: Pointer naar bericht structuur
  - `size`: Grootte van het bericht
  - `flags`: Opties (bijv. `IPC_NOWAIT`)

#### `msgrcv(qid, message, maxSize, type, flags)`
- **Functie**: Haalt een bericht van een queue
- **Parameters**:
  - `qid`: Queue ID
  - `message`: Buffer voor ontvangen bericht
  - `maxSize`: Maximum grootte van bericht
  - `type`: Bericht type filter
    - `type = 0`: **FIFO** (eerste bericht)
    - `type > 0`: Leest bericht van specifiek type
    - `type < 0`: Leest bericht met **laagste type** (prioriteit)
  - `flags`: Opties

#### `msgctl(qid, cmd, data)`
- **Functie**: Controle operaties op queue
- **Gebruik**: O.a. om queue te verwijderen (`IPC_RMID`)

### Praktisch Voorbeeld

#### Server Code
```c
#define MSGKEY 0x7B
struct msgform {
    long type;
    char message[255];
};

int main() {
    int msgid = msgget(MSGKEY, 0777|IPC_CREAT);
    printf("message queue %d created.\n", msgid);
    printf("Nu wachten...\n");
    
    struct msgform message;
    msgrcv(msgid, &message, 255, 1, 0);
    printf("bericht ontvangen: %s\n", message.message);
    
    msgctl(msgid, IPC_RMID, 0);  // Queue verwijderen
}
```

#### Client Code
```c
int main() {
    int msgid = msgget(MSGKEY, 0777);
    printf("Ga bericht sturen op de queue\n");
    
    struct msgform message;
    message.type = 1;
    strcpy(message.message, "Hello, world!");
    msgsnd(msgid, &message, 255, 0);
}
```

### Linux Commando's
- **Message queues bekijken**: `ipcs -q`
- **Message queues verwijderen**: `ipcrm -q <qid>`

## 4. Unix Shared Memory

### Concept
**Shared memory** is een geheugengebied dat door **meerdere processen** kan worden gebruikt. Dit is de snelste vorm van IPC omdat er geen data gekopieerd hoeft te worden.

### Karakteristieken
- **Persistent**: Shared memory wordt **niet automatisch vrijgegeven** als een proces stopt
- **Snelheid**: Directe geheugentoegangen, geen syscalls nodig voor data-uitwisseling
- **Synchronisatie**: Processen moeten zelf synchronisatie regelen

### System Calls

#### `shmget(key, size, flags)`
- **Functie**: Creëert of opent shared memory segment
- **Return**: Shared memory ID
- **Parameters**:
  - `key`: Unieke identifier
  - `size`: Grootte van geheugenblok
  - `flags`: Permissies en opties

#### `shmat(shmid, address, flags)`
- **Functie**: Mapt shared memory op een adres in proces
- **Return**: Pointer naar shared memory
- **Parameters**:
  - `shmid`: Shared memory ID
  - `address`: Gewenst adres (meestal NULL voor automatisch)
  - `flags`: Opties (bijv. `SHM_RDONLY`)

#### `shmdt(address)`
- **Functie**: Unmapt shared memory van proces
- **Parameter**: Adres van shared memory

#### `shmctl(shmid, cmd, data)`
- **Functie**: Controle operaties
- **Gebruik**: O.a. om shared memory te verwijderen

### Implementatie via Paging
Shared memory wordt **geïmplementeerd via paging**:
- Meerdere processen hebben **page table entries** die naar **dezelfde fysieke frames** verwijzen
- OS zorgt ervoor dat dezelfde fysieke geheugenblokken in meerdere virtuele adresruimtes verschijnen

```
Proces A Page Table    Fysiek Geheugen    Proces B Page Table
Page 2 → Frame 8  ←─────────────────────→  Page 5 → Frame 8
Page 3 → Frame 10 ←─────────────────────→  Page 3 → Frame 10
```

### Linux Commando's
- **Shared memory bekijken**: `ipcs -m`
- **Shared memory verwijderen**: `ipcrm -m <shmid>`

## 5. Threads

### Motivatie voor Threads
**Problemen met processen**:
- **Proces opstarten duurt lang** (fork() is duur)
- **Context-switch duurt lang** (volledige process state moet bewaard worden)
- **Complexe IPC** wanneer processen dezelfde data moeten delen
- **Inefficiënt** voor applicaties die meerdere parallelle taken hebben

### Definitie
**Thread** = **Light-weight process**
- Één proces kan **meerdere threads** hebben
- Threads zijn **uitvoerbare eenheden** binnen een proces

### Geheugenmodel

#### Gedeelde Componenten
Threads binnen hetzelfde proces delen:
- **Code segment**: Alle threads voeren dezelfde programma-code uit
- **Data segment**: Globale variabelen, statische variabelen, heap

#### Privé Componenten
Elke thread heeft eigen:
- **Stack**: Lokale variabelen, functie parameters, return addresses
- **Registers**: Processor registers (PC, SP, etc.)
- **Program Counter**: Huidige instructie-adres

### Geheugenindeling
```
┌─────────────────┐
│   Code Segment  │  ← Gedeeld door alle threads
├─────────────────┤
│   Data Segment  │  ← Gedeeld door alle threads
│   (Heap)        │
├─────────────────┤
│   Stack 1       │  ← Thread 1 privé
├─────────────────┤
│   Stack 2       │  ← Thread 2 privé
├─────────────────┤
│   Stack 3       │  ← Thread 3 privé
└─────────────────┘
```

### Voordelen van Threads
1. **Snellere creatie** dan processen
2. **Snellere context-switch** (minder state om te bewaren)
3. **Eenvoudige communicatie** (gedeeld geheugen)
4. **Betere resource-utilisatie** (CPU en geheugen)
5. **Parallellisme** op multi-core systemen

### Nadelen van Threads
1. **Complexere programmering** (synchronisatie problemen)
2. **Geen isolatie** (fout in één thread kan hele proces crashen)
3. **Debugging moeilijker** (race conditions, deadlocks)

## 6. Thread Implementatie Strategieën

### User-Level Threading (N:1)
**Concept**: N threads worden gemanaged door 1 OS scheduling entiteit

#### Werking
- **Proces zelf** heeft een scheduler voor threads
- **Kernel weet niet** dat er threads zijn
- **Alle threads** worden door OS gezien als één proces

#### Voordelen
- **Geen switch naar kernel-mode** nodig → zeer snel
- **Volledige controle** over thread scheduling
- **Portable** (werkt op elk OS)

#### Nadelen
- **Meer logica** in het proces (eigen scheduler)
- **Blocking system calls** blokkeren alle threads
- **Threads van 1 proces** draaien op **1 processor/core**
- **Geen echte parallelisme** op multi-core systemen

### Kernel-Level Threading (1:1)
**Concept**: 1 thread = 1 OS scheduling entiteit

#### Werking
- **OS regelt** scheduling van threads
- **Kernel is bewust** van alle threads
- **Elke thread** is een aparte scheduling entiteit

#### Voordelen
- **Transparant** voor processen
- **OS kan threads onafhankelijk** schedulen
- **Threads van 1 proces** kunnen op **verschillende processoren/cores** draaien
- **Blocking system calls** blokkeren alleen de betreffende thread

#### Nadelen
- **Switch naar kernel-mode** nodig → langzamer
- **Meer overhead** (kernel moet meer threads tracken)
- **Beperkt aantal threads** (kernel resources)

### Hybrid Threading (M:N)
**Concept**: M threads worden gemanaged door N OS scheduling entiteiten

#### Werking
- **Combinatie** van user-level en kernel-level threading
- **Meerdere user threads** worden gemanaged door **minder kernel threads**
- **Complexe mapping** tussen user en kernel threads

#### Voordelen
- **Combineert voordelen** van beide benaderingen
- **Flexibiliteit** in thread management
- **Betere scalabiliteit**

#### Nadelen
- **Zeer complexe implementatie**
- **Moeilijk te debuggen**
- **Weinig gebruikt** in praktijk

## 7. Threads in Linux

### POSIX Threads (pthreads)
Linux gebruikt **POSIX threads** (pthreads) voor thread management.

### Belangrijke Functies

#### `pthread_create()`
```c
int pthread_create(pthread_t *thread, const pthread_attr_t *attr,
                   void *(*start_routine)(void *), void *arg);
```
- **Functie**: Creëert een nieuwe thread
- **Parameters**:
  - `thread`: Pointer naar thread identifier
  - `attr`: Thread attributen (meestal NULL)
  - `start_routine`: Functie die thread moet uitvoeren
  - `arg`: Argument voor de functie

#### `pthread_join()`
```c
int pthread_join(pthread_t thread, void **retval);
```
- **Functie**: Wacht tot thread eindigt
- **Parameters**:
  - `thread`: Thread identifier
  - `retval`: Return value van thread

### Praktisch Voorbeeld
```c
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

pthread_t tid1, tid2;
char bericht[30];

void* doThread1(void *arg) {
    printf("1 stuurt naar 2\n");
    strcpy(bericht, "Bericht van 1");
    sleep(10);
    return NULL;
}

void* doThread2(void *arg) {
    sleep(10);
    printf("2 ontvangt: %s\n", bericht);
    return NULL;
}

int main(void) {
    pthread_create(&tid1, NULL, &doThread1, NULL);
    printf("Thread 1 created\n");
    
    pthread_create(&tid2, NULL, &doThread2, NULL);
    printf("Thread 2 created\n");
    
    pthread_join(tid1, NULL);
    pthread_join(tid2, NULL);
    
    printf("Threads done!\n");
    return 0;
}
```

### Compilatie en Debugging
```bash
# Compileren
gcc threadvb.c -o threadvb -pthread

# Threads bekijken
ps -eLf | grep threadvb
# of
top -H -p <pid>
```

### Belangrijke Opmerkingen
- **Globale variabelen** zijn gedeeld tussen threads
- **Lokale variabelen** staan op de stack en zijn **niet gedeeld**
- **Thread-safe** programmering is essentieel

## 8. Multi-Processor Systemen

### Architectuur
Moderne systemen hebben:
- **Multi-core processors**: Meerdere cores op 1 chip
- **Multi-processor**: Meerdere aparte processors
- **Meestal shared memory** architectuur

### Gevolgen voor OS
1. **Scheduling**: 1 ready queue, meerdere processors
2. **Load balancing**: Werk evenredig verdelen over processors
3. **Resource conflicts**: Meerdere processors willen dezelfde resource
4. **Synchronisatie**: Coördinatie tussen processors

### Architectuur Voorbeeld
```
┌─────────────────────────────────────────────────────────────┐
│                        System Bus                           │
├─────────┬─────────┬─────────┬─────────┬─────────┬─────────┤
│  Core 1 │  Core 2 │  Core 3 │  Core 4 │   RAM   │   ROM   │
└─────────┴─────────┴─────────┴─────────┴─────────┴─────────┘
         │                                           │
         └─────────────── I/O Bus ───────────────────┘
                    │         │         │
                ┌───────┐ ┌───────┐ ┌───────┐
                │ VRAM  │ │Keyboard│ │ HDD   │
                └───────┘ └───────┘ └───────┘
```

## 9. Multi-Processor OS Strategieën

### Master-Slave Architectuur
#### Werking
- **1 processor = master**, anderen zijn **slaves**
- **Master draait kernel** en doet scheduling
- **Slaves** voeren alleen user code uit

#### Voordelen
- **Eenvoudig te implementeren**
- **Geen synchronisatie problemen** in kernel
- **1 processor controleert** geheugen en I/O

#### Nadelen
- **Master kan bottleneck worden**
- **Niet optimaal gebruik** van alle processors
- **Single point of failure**

### Symmetric Multi-Processing (SMP)
#### Werking
- **Kernel kan draaien** op elke processor
- **Elke processor** doet eigen scheduling
- **Gelijke processors** zonder hiërarchie

#### Voordelen
- **Betere load balancing**
- **Hogere performance**
- **Redundantie** (geen single point of failure)

#### Nadelen
- **Complexe synchronisatie** in kernel
- **Race conditions** mogelijk
- **Ingrijpende wijzigingen** in kernel code nodig

#### Synchronisatie Problemen
- **Meerdere processors** kunnen dezelfde code willen uitvoeren
- **Gelijktijdige toegang** tot hetzelfde geheugen
- **Kernel moet thread-safe** zijn

### Distributed vs. Shared Memory
#### Shared Memory
- **Alle processors** hebben toegang tot hetzelfde geheugen
- **Goedkoper** voor kleinere systemen
- **Geheugen bus** wordt bottleneck bij veel processors

#### Distributed Memory
- **Elke processor** heeft eigen geheugen
- **Communicatie via netwerk** tussen processors
- **Gebruikt in supercomputers** (bijv. Cray ECMWF met 260.000 cores)
- **Schaalt beter** naar grote aantallen processors

## 10. Gelijktijdigheid (Concurrency)

### Het Probleem
Wanneer **meerdere threads/processen** gelijktijdig dezelfde resource gebruiken, kunnen er **race conditions** optreden.

### Voorbeeld van Race Condition
```c
#include <pthread.h>
pthread_t tid1, tid2;
char naam[10];  // Gedeelde variabele

void* doThread1(void *arg) {
    scanf("%s", naam);  // Thread 1 leest input
    sleep(3);
    printf("%s\n", naam);  // Thread 1 print naam
}

void* doThread2(void *arg) {
    sleep(2);
    scanf("%s", naam);  // Thread 2 overschrijft naam!
    printf("%s\n", naam);  // Thread 2 print naam
}
```

**Probleem**: Thread 2 kan de variabele `naam` overschrijven voordat Thread 1 deze heeft geprint.

### Critical Section
**Critical Section** = Een stuk code dat maar door **één thread tegelijkertijd** mag worden uitgevoerd.

#### Vereisten
- **Mutual Exclusion**: Hoogstens 1 thread in critical section
- **Progress**: Als niemand in critical section is, mag een wachtende thread binnen
- **Bounded Waiting**: Threads wachten niet oneindig lang

### Oplossing: Synchronisatie
Er moet een **locking mechanisme** zijn dat:
- **Light-weight** is (weinig overhead)
- **Atomic operations** gebruikt
- **Deadlock-free** is

## 11. Semaforen

### Concept
**Semafoor** = Synchronisatie primitief gebaseerd op verkeerslichten
- **0**: Rood licht (stop)
- **≥1**: Groen licht (mag doorrijden)

### Theoretische Operaties

#### `wait()` (ook wel `P()` genoemd)
```
wait(S):
    while (S <= 0) {
        // busy waiting
    }
    S = S - 1;
```

#### `signal()` (ook wel `V()` genoemd)
```
signal(S):
    S = S + 1;
```

### Linux Implementatie

#### Functies
```c
#include <semaphore.h>

sem_t semaphore;

// Initialisatie
int sem_init(sem_t *sem, int pshared, unsigned int value);

// Wait operatie (semafoor NEER)
int sem_wait(sem_t *sem);

// Signal operatie (semafoor OP)
int sem_post(sem_t *sem);

// Cleanup
int sem_destroy(sem_t *sem);
```

#### Parameters
- `sem`: Pointer naar semafoor
- `pshared`: 
  - `0`: Semafoor tussen threads van zelfde proces
  - `!0`: Semafoor tussen verschillende processen
- `value`: Initiële waarde van semafoor

### Praktisch Voorbeeld
```c
#include <pthread.h>
#include <semaphore.h>

pthread_t tid1, tid2;
char naam[10];
sem_t sema;

void* doThread1(void *arg) {
    sem_wait(&sema);    // Semafoor NEER
    scanf("%s", naam);  // Critical section
    printf("%s\n", naam);
    sem_post(&sema);    // Semafoor OP
}

void* doThread2(void *arg) {
    sem_wait(&sema);    // Semafoor NEER
    scanf("%s", naam);  // Critical section
    printf("%s\n", naam);
    sem_post(&sema);    // Semafoor OP
}

int main(void) {
    sem_init(&sema, 0, 1);  // Semafoor OP (1 = groen)
    
    pthread_create(&tid1, NULL, &doThread1, NULL);
    pthread_create(&tid2, NULL, &doThread2, NULL);
    
    pthread_join(tid1, NULL);
    pthread_join(tid2, NULL);
    
    sem_destroy(&sema);
    return 0;
}
```

### Atomic Operations
**Belangrijk**: `sem_wait()` en `sem_post()` zijn **atomic operations**
- **Gegarandeerd** door OS/hardware
- **Onafgebroken** uitvoering
- **Geen race conditions** in semafoor zelf

## 12. Deadlocks

### Definitie
**Deadlock** = Situatie waarbij twee of meer processen/threads **permanent geblokkeerd** zijn omdat ze op elkaar wachten.

### Klassiek Voorbeeld: Dining Philosophers
```
┌─────────────────┐
│   Philosopher   │ → Needs Fork A and B
│        A        │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│   Philosopher   │ → Needs Fork B and C
│        B        │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│   Philosopher   │ → Needs Fork C and D
│        C        │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│   Philosopher   │ → Needs Fork D and A
│        D        │
└─────────────────┘
```

**Deadlock**: Elke filosoof heeft één vork en wacht op de andere.

### Deadlock Voorwaarden (Coffman Conditions)
1. **Mutual Exclusion**: Resource kan maar door 1 proces gebruikt worden
2. **Hold and Wait**: Proces houdt resource vast en wacht op andere
3. **No Preemption**: Resource kan niet geforceerd weggenomen worden
4. **Circular Wait**: Cyclische keten van wachtende processen

### Code Voorbeeld van Deadlock
```c
sem_t sema1, sema2;

void* doThread1(void *arg) {
    sem_wait(&sema1);               // Lock sema1
    printf("1 gelocked, nu nog 2...\n");
    sleep(1);                       // Geef andere thread kans
    sem_wait(&sema2);               // Wacht op sema2 (DEADLOCK!)
    printf("1 en 2 gelocked!\n");
    sem_post(&sema2);
    sem_post(&sema1);
}

void* doThread2(void *arg) {
    sem_wait(&sema2);               // Lock sema2
    printf("2 gelocked, nu nog 1...\n");
    sleep(1);                       // Geef andere thread kans
    sem_wait(&sema1);               // Wacht op sema1 (DEADLOCK!)
    printf("2 en 1 gelocked!\n");
    sem_post(&sema1);
    sem_post(&sema2);
}
```

**Resultaat**: Thread 1 wacht op sema2, Thread 2 wacht op sema1 → **Deadlock**

### Deadlock Preventie
1. **Volgorde van locking**: Altijd dezelfde volgorde gebruiken
2. **Timeout**: Maximale wachttijd instellen
3. **Deadlock detection**: Cyclische dependencies detecteren
4. **Resource ordering**: Genummerde resources in volgorde aanvragen

### Oplossing voor Bovenstaand Voorbeeld
```c
void* doThread1(void *arg) {
    sem_wait(&sema1);    // Eerst altijd sema1
    sem_wait(&sema2);    // Daarna sema2
    printf("1 en 2 gelocked!\n");
    sem_post(&sema2);
    sem_post(&sema1);
}

void* doThread2(void *arg) {
    sem_wait(&sema1);    // Eerst altijd sema1
    sem_wait(&sema2);    // Daarna sema2
    printf("2 en 1 gelocked!\n");
    sem_post(&sema2);
    sem_post(&sema1);
}
```

## 13. Samenhang en Praktische Toepassingen

### Evolutie van Parallelisme
1. **Processen**: Isolatie en veiligheid
2. **IPC**: Communicatie tussen processen
3. **Threads**: Lightweight parallelisme
4. **Synchronisatie**: Veilige samenwerking

### Moderne Toepassingen
- **Web servers**: Threads voor elke client
- **Database systemen**: Parallelle query processing
- **Grafische applicaties**: Rendering threads
- **Embedded systemen**: Real-time tasks

### Performance Overwegingen
- **Context switch overhead**: Threads < Processen
- **Memory overhead**: Shared memory < Message passing
- **Synchronization overhead**: Atomic operations vs. system calls
- **Scalability**: User-level vs. kernel-level threading

## 14. Herhalingsvragen

### IPC Vragen
1. **Wat zijn pipes?** 
   - Communicatiemechanisme dat stdout van proces koppelt aan stdin van ander proces
   - FIFO principe, circulaire buffer in OS

2. **Stappen voor Unix berichten?**
   - `msgget()`: Queue maken/openen
   - `msgsnd()`: Bericht versturen
   - `msgrcv()`: Bericht ontvangen
   - `msgctl()`: Queue beheren/verwijderen

3. **Stappen voor shared memory?**
   - `shmget()`: Shared memory segment maken
   - `shmat()`: Segment mappen in proces
   - Gebruik shared memory
   - `shmdt()`: Segment unmappen
   - `shmctl()`: Segment verwijderen

4. **Hoe deelt OS geheugen?**
   - Via **paging**: Meerdere page tables verwijzen naar dezelfde fysieke frames

### Thread Vragen
5. **Gedeelde geheugensegmenten?**
   - **Gedeeld**: Code segment, data segment (heap)
   - **Privé**: Stack, registers

6. **Verschil proces vs. thread?**
   - **Proces**: Eigen geheugenruimte, dure context switch
   - **Thread**: Gedeelde geheugenruimte, goedkope context switch

7. **Voor- en nadelen threads?**
   - **Voordelen**: Sneller, eenvoudige communicatie, parallellisme
   - **Nadelen**: Complexer, geen isolatie, synchronisatie problemen

8. **User-level vs. kernel-level?**
   - **User-level**: Sneller, geen echte parallellisme
   - **Kernel-level**: Trager, echte parallellisme mogelijk

9. **Lokale vs. globale variabelen?**
   - **Lokale**: Op stack (privé per thread)
   - **Globale**: In data segment (gedeeld tussen threads)

### Multi-processor Vragen
10. **Load balancing?**
    - Werk evenredig verdelen over beschikbare processors/cores

11. **Multiprocessor architectuur?**
    - Meerdere cores/processors verbonden via system bus
    - Shared memory en I/O resources

12. **Master-slave vs. SMP?**
    - **Master-slave**: 1 processor doet scheduling, eenvoudig maar bottleneck
    - **SMP**: Elke processor kan scheduling doen, complex maar efficiënt

### Synchronisatie Vragen
13. **Critical section?**
    - Code die maar door 1 thread tegelijkertijd mag worden uitgevoerd

14. **Semafoor?**
    - Synchronisatie primitief met `wait()` (P) en `signal()` (V) operaties
    - Atomic operations gegarandeerd door OS

15. **Deadlocks?**
    - Situatie waarbij processen/threads permanent op elkaar wachten
    - Optreden bij: mutual exclusion, hold-and-wait, no preemption, circular wait

## Conclusie

IPC en threads vormen de basis van moderne multi-tasking en parallelle systemen. Het begrip van deze concepten is essentieel voor:
- **Systeem programmering**
- **Performance optimalisatie**
- **Betrouwbare software ontwikkeling**
- **Moderne applicatie architecturen**

De evolutie van enkelvoudige processen naar complexe multi-threaded applicaties met geavanceerde synchronisatie toont de voortdurende ontwikkeling in computersystemen.