mst.pl

PROGETTO DI:
- Colombo Gaia
- Erba Sandro


DESCRIZIONE:
Questo progetto implementa l'algoritmo di Prim e la creazione del
relativo MST (Minimum Spanning Tree) per un grafo non diretto
Per raggiungere questo obiettivo sono state implementate le librerie per la
creazione e la manipolazione di Grafi e MinHeap


PREREQUISITI:
SWI-Prolog versione 8.2.1


UTILIZZO: 
- Creare un file "FileName.csv" (nella stessa cartella dove è salvato il file
  mst.pl) contenente il grafo su cui lavorare (ogni riga deve contenere un
  arco, nella forma "vertice vertice peso": i 3 elementi sono separati
  da un carattere di tabulazione)
- Caricare il programma su SWI-Prolog
- Scrivere nel prompt "read_graph(g, "FileName.csv")." dove g è il nome che
  assumerà il grafo
- Scrivere nel prompt "mst_prim(g, v)." dove v è il vertice dal quale far
  partire l'MST
- Scrivere nel prompt "mst_get(g, v, PreorderTree)." dove a PreorderTree
  corrisponderà la lista degli archi del MST


IMPLEMENTAZIONE:
Di seguito sono descritti i predicati da implementare indicati nella
descrizione del progetto
Di alcuni sono specificate alcune scelte implementative che non erano
presenti nel progetto (come il caso in cui se si chiama un predicato su un
grafo che non esiste, il predicato torna falso)
Sono ovviamente stati implementati altri predicati, di supporto a quelli
richiesti, che però non sono stati descritti in questo file, in quanto non
dovrebbero essere mai chiamati dall'utente, ma usati solo da altri metodi
(sono comunque spiegati nel file mst.pl con dei commenti)


***GRAFI***

- graph(G)
	- G è il nome del grafo

- vertex(G, V)
	- G è il nome del grafo a cui appartiene il vertice
	- V è il nome del vertice

- arc(G, V, U, W)
	- G è il nome del grafo a cui appartiene il vertice
	- V e U sono i nomi dei vertici che collega l'arco
	- W è il peso dell'arco

- new_graph(G)
	Il predicato inserisce un nuovo grafo G nella base-dati Prolog,
	ritorna sempre vero

- delete_graph(G)
	Il predicato rimuove tutto il grafo G (vertici e archi inclusi)
	dalla base-dati Prolog, ritorna sempre vero

- new_vertex(G, V)
	Il predicato aggiunge il vertice V nella base-dati Prolog,
	ritorna falso quando il grafo G non esiste

- graph_vertices(G, Vs)
	Il predicato è vero quando Vs è una lista contenente
	tutti i vertici di G

- list_vertices(G)
	Il predicato stampa su console una lista dei vertici del grafo G,
	è falso se G non esiste

- new_arc(G, U, V, Weight)
	Il predicato aggiunge un arco del grafo G alla base dati Prolog,
	è falso se il grafo G non esiste o se uno dei due vertici (U o
	V) non esistono

- graph_arcs(G, Es)
	Il predicato è vero quando Es è una lista di tutti gli archi
	presenti in G

- vertex_neighbors(G, V, Ns)
	Il predicato è vero quando V è un vertice di G e Ns è una lista
	contenente gli archi che portano ai vertici N immediatamente
	raggiungibili da V, è falso se G o V non esistono

- adjs(G, V, Vs)
	Il predicato è vero quando V è un vertice di G e Vs è una lista
	contenente tutti i vertici vertex(G, V), ad esso adiacenti, è
	falso se G o V non esistono

- list_arcs(G)
	Il predicato stampa su console una lista degli archi del grafo G,
	stampa falso se G non esiste

- list_graph(G)
	Il predicato stampa su console una lista dei vertici e degli archi
	del grafo G, stampa falso se G non esiste

- read_graph(G, FileName)
	Il predicato legge un grafo G, da un FileName.csv e lo inserisce
	nella base-dati di Prolog (crea il grafo, i vertici e gli archi)
	In FileName.csv ogni riga contiene 3 elementi separati da un
	carattere di tabulazione

- write_graph(G, FileName, Type)
	Il predicato è vero quando G viene scritto sul file FileName secondo
	il valore dell'argomento Type, che può essere graph o edges
	- Se Type è graph, allora G identifica un grafo nella base-dati
	  Prolog, in FileName saranno scritti gli archi del grafo secondo il
	  formato di read_graph/2
	- Se Type è edges, allora G è una lista di archi, ognuno dei quali
	  viene stampato su FileName secondo il formato di read_graph/2


***MINHEAP***

- heap(H, S)
	- H è il nome dell'heap
	- S è la dimensione dell'heap

- heap_entry(H, P, K, V)
	- H è il nome dell'heap
	- P è la posizione nell'heap H
	- K è la chiave (numerica)
	- V è il valore

- new_heap(H)
	Il predicato inserisce un nuovo heap H nella base-dati Prolog,
	ritorna sempre vero

- delete_heap(H)
	Il predicato rimuove tutto lo heap H (incluse tutte le "entries")
	dalla base-dati Prolog, ritorna sempre vero

- heap_has_size(H, S)
	Il predicato è vero quando S è la dimensione corrente dello heap H

- heap_empty(H)
	Il predicato è vero quando lo heap H non contiene elementi

- heap_not_empty(H)
	Il predicato è vero quando lo heap H contiene almeno un elemento

- heap_head(H, K, V)
	Il predicato è vero quando l'elemento dello heap H con chiave minima
	K è V

- heap_insert(H, K, V)
	Il predicato è vero quando l'elemento V è inserito nello heap H con
	chiave K, è falso quando H non esiste

- heap_extract(H, K, V)
	Il predicato è vero quando la coppia K V (con K minimo) è rimossa
	dallo heap H

- modify_key(H, NewKey, OldKey, V)
	Il predicato è vero quando la chiave OldKey (associata al valore V)
	è sostituita da NewKey (NewKey deve essere minore o uguale a OldKey)


***PRIM***

- vertex_key(G, V, K)
	- G è il nome del grafo
	- V è un vertice di G
	- K è il peso minimo di un arco che connette V nell'albero minimo
	  (se non è connesso all'albero, quindi l'arco non esiste, K è inf)

- vertex_previous(G, V, U)
	- G è il nome del grafo
	- V è il vertice "figlio" nel MST
	- U è il vertice "genitore" nel MST

- mst_prim(G, Source)
	Il predicato ha successo con un effetto collaterale: la base-dati
	Prolog viene aggiornata e conterrà i predicati vertex_key(G, V, K)
	per ogni V appartenente a G e conterrà anche i predicati
	vertex_previous(G, V, U) per ogni V, ottenuti durante le iterazioni
	dell'algoritmo di Prim

- mst_get(G, Source, PreorderTree)
	Il predicato è vero quando PreorderTree è una lista degli archi
	del MST ordinata secondo un attraversamento preorder dello stesso,
	fatta rispetto al peso dell'arco