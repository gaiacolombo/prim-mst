mst.lisp

PROGETTO DI:
- Colombo Gaia
- Erba Sandro


DESCRIZIONE:
Questo progetto implementa l'algoritmo di Prim e la creazione del
relativo MST (Minimum Spanning Tree) per un grafo non diretto
Per raggiungere questo obiettivo sono state implementate le librerie per la
creazione e la manipolazione di Grafi e MinHeap, con l'utilizzo delle
hash-tables


PREREQUISITI:
LispWorks Personal Edition 7.1.2


UTILIZZO: 
- Caricare il programma su LispWorks
- Creare il grafo con la funzione (new-heap heap-id)
- Inserire nel grafo tutti i vertici del grafo con la funzione
  (new-vertex heap-id vertex-id)
- Inserire nel grafo tutti gli archi del grafo con la funzione
  (new-vertex heap-id vertex-id vertex-id &optional weight)
- Scrivere nel prompt "(mst-prim graph-id source)" dove source è il
  vertice dal quale far partire l'MST
- Scrivere nel prompt "(mst-get graph-id source)", il valore ritornato sarà
  la lista preorder-mst


IMPLEMENTAZIONE:
Di seguito sono descritti i predicati da implementare indicati nella
descrizione del progetto
Di alcuni sono specificate alcune scelte implementative che non erano
presenti nel progetto (come il caso in cui se si chiama un predicato su un
grafo che non esiste, il predicato torna NIL)
Sono ovviamente stati implementati altri predicati, di supporto a quelli
richiesti, che però non sono stati descritti in questo file, in quanto non
dovrebbero essere mai chiamati dall'utente, ma usati solo da altri metodi


***GRAFI***

- is-graph: graph-id -> graph-id or NIL
  Ritorna il graph-id stesso se questo grafo è già stato creato,
  altrimenti NIL

- new-graph: graph-id -> graph-id
  Genera un nuovo grafo e lo inserisce nel data-base (ovvero nella
  hash-table) dei grafi

- delete-graph: graph-id -> NIL
  Rimuove l'intero grafo dalla base di dati

- new-vertex: graph-id vertex-id -> vertex-rep
  Aggiunge un nuovo vertice vertex-id al grafo graph-id,
  ritorna NIL se il grafo graph-id non esiste

- graph-vertices: graph-id -> vertex-rep-list
  Torna una lista di vertici del grafo,
  ritorna NIL se il grafo graph-id non esiste

- new-arc: graph-id vertex-id vertex-id &optional (weight 1) -> arc-rep
  Aggiunge un arco del grafo graph-id nella hash-table *arcs*,
  ritorna NIL se il grafo graph-id non esiste, se uno dei due
  vertex-id non esiste, se l'arco è un cappio, o se il peso è minore
  di 0 Se l'arco esiste già, il suo peso viene sostituito con
  quello nuovo

- graph-arcs: graph-id -> arc-rep-list
  Ritorna una lista una lista di tutti gli archi presenti in graph-id

- graph-vertex-neighbors: graph-id vertex-id -> arc-rep-list
  Ritorna una lista arc-rep-list contenente gli archi (arc graph-id
  vertex-id N W) che portano ai vertici immediatamente raggiungibili
  da vertex-id
  Ritorna NIL se il vertice vertex-id non esiste in graph-id

- graph-vertex-adjacent: graph-id vertex-id -> vertex-rep-list
  Ritorna una lista vertex-rep-list contenente
  i vertici (arc graph-id vertex-id V) adiacenti a vertex-id
  Ritorna NIL se il vertice vertex-id non esiste in graph-id

- graph-print: graph-id -> boolean
  Stampa alla console una lista dei vertici e degli archi del grafo
  graph-id


***MINHEAP***

- new-heap: heap-id &optional (capacity 42) -> heap-rep
  Inserisce un nuovo heap nella hash-table *heaps*
  Ritorna la rappresentazione dell'heap

- heap-delete: heap-id -> T
  Rimuove tutto l'heap indicizzato da heap-id
  Ritorna sempre T

- heap-empty: heap-id -> boolean
  È vero quando l'heap heap-id non contiene elementi,
  NIL altrimenti, o se l'heap heap-id non esiste

- heap-not-empty: heap-id -> boolean
  È vero quando l'heap heap-id contiene almeno un elemento,
  NIL altrimenti, o se l'heap heap-id non esiste

- heap-head: heap-id -> (K V)
  Ritorna una lista di due elementi dove K è la chiave minima
  e V il valore associato
  Ritorna NIL se l'heap heap-id non esiste

- heap-insert: heap-id K V -> boolean
  Inserisce l'elemento V nello heap heap-id con chiave K
  Ritorna NIL se l'heap-id non esiste, se l'heap è pieno raddoppia
  la sua capacità

- heap-extract: heap-id -> (K V)
  Ritorna la lista con K, V e con K minima, la coppia è rimossa
  dall'heap heap-id
  Ritorna NIL se l'heap heap-id non esiste o se è vuoto

- heap-modify-key: heap-id new-key old-key V -> boolean
  Sostituisce la chiave OldKey (associata al valore V) con NewKey,
  se NewKey è minore di OldKey
  Ritorna NIL altrimenti
  Per rendere la funzione efficiente, è stata aggiunta una hash table
  come ultimo elemento della "heap-rep" (definita "position"), che associa
  a ogni valore dell'heap la sua posizione nell'heap stesso

- heap-print: heap-id -> boolean
  Stampa sulla console lo stato interno dello heap heap-id


***PRIM***

- mst-prim: graph-id source -> NIL
  Dopo la sua esecuzione, la hash-table *vertex-key* contiene al suo
  interno le associazioni (graph-id V) -> d per ogni V appartenente a
  graph-id
  La hash-table *previous* contiene le associazioni (graph-id V) -> U
  calcolate durante l'esecuzione dell'algoritmo di Prim

- mst-get: graph-id source -> preorder-mst
  Questa funzione ritorna preorder-mst che è una lista degli archi
  del MST ordinata secondo un attraversamento preorder dello stesso,
  fatta rispetto al peso dell'arco