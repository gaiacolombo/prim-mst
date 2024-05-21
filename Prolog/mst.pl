%%%% -*- Mode: Prolog -*-


%%%% mst.pl

%%%% PROGETTO DI:
%%%% Colombo Gaia (matricola 856483)
%%%% Erba Sandro (matricola 856327)


:- dynamic(graph/1).
:- dynamic(vertex/2).
:- dynamic(arc/4).

:- dynamic(heap/2).
:- dynamic(heap_entry/4).

:- dynamic(vertex_key/3).
:- dynamic(vertex_previous/3).


:- retractall(graph(_)).
:- retractall(vertex(_, _)).
:- retractall(arc(_, _, _, _)).
:- retractall(heap(_, _)).
:- retractall(heap_entry(_, _, _, _)).
:- retractall(vertex_key(_, _, _)).
:- retractall(vertex_previous(_, _, _)).


%   Libreria manipolazione grafi
%
%   Predicates:
%   new_graph(G)
%   delete_graph(G)
%
%   new_vertex(G, V)
%   graph_vertices(G, Vs)
%   list_vertices(G)
%
%   new_arc(G, U, V, Weight)
%   graph_arcs(G, Es)
%   vertex_neighbors(G, V, Ns)
%   adjs(G, V, Vs)
%   list_arcs(G)
%
%   list_graph(G)
%
%   read_graph(G, FileName)
%   add_all_arcs(G, Ls)
%
%   write_graph(G, FileName)
%   write_graph(G, FileName, Type)
%   control_arcs(Es)
%   convert_arcs(Es, Ls)


%!  new_graph(G)
%
%   Il predicato inserisce un nuovo grafo G nella base-dati Prolog

new_graph(G) :-
    graph(G),
    !.
new_graph(G) :-
    assert(graph(G)),
    !.


%!  delete_graph(G)
%
%   Il predicato rimuove tutto il grafo G (vertici e archi inclusi)
%   dalla base-dati Prolog, ritorna sempre vero

delete_graph(G) :-
    retract(graph(G)),
    retractall(vertex(G, _)),
    retractall(arc(G, _, _, _)),
    retractall(vertex_key(G, _, _)),
    retractall(vertex_previous(G, _, _)).


%!  new_vertex(G, V)
%
%   Il predicato aggiunge il vertice V nella base-dati Prolog, ritorna
%   falso quando il grafo G non esiste

new_vertex(G, V) :-
    vertex(G, V),
    !.
new_vertex(G, V) :-
    graph(G),
    assert(vertex(G, V)),
    !.


%!  graph_vertices(G, Vs)
%
%   Il predicato è vero quando Vs è una lista contenente tutti i vertici
%   di G

graph_vertices(G, Vs) :-
    graph(G),
    findall(vertex(G, V), vertex(G, V), Vs).


%!  list_vertices(G)
%
%   Il predicato stampa su console una lista dei vertici del grafo G,
%   è falso se G non esiste

list_vertices(G) :-
    graph(G),
    listing(vertex(G, _)).


%!  new_arc(G, U, V, Weight)
%
%   Il predicato aggiunge un arco del grafo G alla base dati Prolog,
%   è falso se il grafo G non esiste o se uno dei due vertici (U o
%   V) non esistono

new_arc(G, U, V) :-
    new_arc(G, U, V, 1).
new_arc(G, U, U, _) :-
    vertex(G, U),
    !.
new_arc(G, U, V, Weight) :-
    vertex(G, U),
    vertex(G, V),
    Weight < 0,
    !.
new_arc(G, U, V, Weight) :-
    arc(G, U, V, _),
    retract(arc(G, U, V, _)),
    new_arc(G, U, V, Weight),
    !.
new_arc(G, U, V, Weight) :-
    arc(G, V, U, _),
    retract(arc(G, V, U, _)),
    new_arc(G, U, V, Weight),
    !.
new_arc(G, U, V, Weight) :-
    vertex(G, U),
    vertex(G, V),
    assert(arc(G, U, V, Weight)),
    !.


%!  graph_arcs(G, Es)
%
%   Il predicato è vero quando Es è una lista di tutti gli archi
%   presenti in G

graph_arcs(G, Es) :-
    graph(G),
    findall(arc(G, U, V, W), arc(G, U, V, W), Es).


%!  vertex_neighbors(G, V, Ns)
%
%   Il predicato è vero quando V è un vertice di G e Ns è una lista
%   contenente gli archi che portano ai vertici N immediatamente
%   raggiungibili da V, è falso se G o V non esistono

vertex_neighbors(G, V, Ns) :-
    vertex(G, V),
    findall(arc(G, V, X, Y), arc(G, V, X, Y), N1s),
    findall(arc(G, Z, V, K), arc(G, Z, V, K), N2s),
    append(N1s, N2s, Ns).


%!  adjs(G, V, Vs)
%
%   Il predicato è vero quando V è un vertice di G e Vs è una lista
%   contenente tutti i vertici vertex(G, V), ad esso adiacenti, è
%   falso se G o V non esistono

adjs(G, V, Vs) :-
    vertex(G, V),
    findall(vertex(G, X), arc(G, V, X, _), V1s),
    findall(vertex(G, Z), arc(G, Z, V, _), V2s),
    append(V1s, V2s, Vs).


%!  list_arcs(G)
%
%   Il predicato stampa su console una lista degli archi del grafo G,
%   stampa falso se G non esiste

list_arcs(G) :-
    graph(G),
    listing(arc(G, _, _, _)).


%!  list_graph(G)
%
%   Il predicato stampa su console una lista dei vertici e degli archi
%   del grafo G, stampa falso se G non esiste

list_graph(G) :-
    list_vertices(G),
    list_arcs(G).


%!  read_graph(G, FileName)
%
%   Il predicato legge un grafo G, da un FileName.csv e lo inserisce
%   nella base-dati di Prolog
%   In FileName.csv ogni riga contiene 3 elementi separati da un
%   carattere di tabulazione

read_graph(G, FileName) :-
    graph(G),
    delete_graph(G),
    new_graph(G),
    csv_read_file(FileName, L, [separator(0'\t)]),
    add_all_arcs(G, L),
    !.
read_graph(G, FileName) :-
    new_graph(G),
    csv_read_file(FileName, L, [separator(0'\t)]),
    add_all_arcs(G, L),
    !.


%!  add_all_arcs(G, Es)
%
%   Il predicato, di supporto a read_graph/2, aggiunge alla base-dati di
%   Prolog tutti vertici della lista Vs

add_all_arcs(_, []).
add_all_arcs(G, [row(U, V, W) | Es]) :-
    new_vertex(G, U),
    new_vertex(G, V),
    new_arc(G, U, V, W),
    add_all_arcs(G, Es).


%!  write_graph(G, FileName, Type)
%
%   Il predicato è vero quando G viene scritto sul file FileName secondo
%   il valore dell'argomento Type, che può essere graph o edges
%   Se Type è graph, allora G identifica un grafo nella base-dati
%   Prolog, in FileName saranno scritti gli archi del grafo secondo il
%   formato di read_graph/2
%   Se Type è edges, allora G è una lista di archi, ognuno dei quali
%   viene stampato su FileName secondo il formato di read_graph/2

write_graph(G, FileName) :-
    write_graph(G, FileName, graph).
write_graph(G, FileName, graph) :-
    graph_arcs(G, Es),
    write_graph(Es, FileName, edges).
write_graph(Es, FileName, edges) :-
    is_list(Es),
    control_arcs(Es),
    convert_arcs(Es, Ls),
    csv_write_file(FileName, Ls, [separator(0'\t)]).


%!  control_arcs(Es)
%
%   Il predicato, di supporto a write_graph/2, è vero quando tutti gli
%   elementi della lista Es sono predicati di arità 4 con funtore arc

control_arcs([]).
control_arcs([E | Es]) :-
    functor(E, arc, 4),
    control_arcs(Es).


%!  convert_arcs(Es, Ls)
%
%   Il predicato, di supporto a write_graph/2, è vero quando Es è una
%   lista del tipo arc(G, U, V, W) e la lista Ls è una lista del tipo
%   row(U, V, W), con lo stesso numero di elementi

convert_arcs([], []).
convert_arcs([arc(_, U, V, W) | Es], [row(U, V, W) | Ls]) :-
    convert_arcs(Es, Ls).


%%%%%%%%%%%%%%%

%   Libreria MinHeap
%
%   Predicates:
%   new_heap(H)
%   delete_heap(H)
%   heap_has_size(H, S)
%   heap_empty(H)
%   heap_not_empty(H)
%
%   heap_head(H, K, V)
%   heap_insert(H, K, V)
%   insert(H, P)
%   heap_extract(H, K, V)
%   heapify(H, P)
%
%   modify_key(H, NewKey, OldKey, V)
%   list_heap(H)


%!  new_heap(H)
%
%   Il predicato inserisce un nuovo heap H nella base-dati Prolog

new_heap(H) :-
    heap(H, _),
    !.
new_heap(H) :-
    assert(heap(H, 0)),
    !.


%!  delete_heap(H)
%
%   Il predicato rimuove tutto lo heap H (incluse tutte le "entries")
%   dalla base-dati Prolog, ritorna sempre vero

delete_heap(H) :-
    retractall(heap_entry(H, _, _, _)),
    retractall(heap(H, _)).


%!  heap_has_size(H, S)
%
%   Il predicato è vero quando S è la dimensione corrente dello heap H

heap_has_size(H, S) :-
    heap(H, S).


%!  heap_empty(H)
%
%   Il predicato è vero quando lo heap H non contiene elementi

heap_empty(H) :-
    heap_has_size(H, 0).


%!  heap_not_empty(H)
%
%   Il predicato è vero quando lo heap H contiene almeno un elemento

heap_not_empty(H) :-
    not(heap_empty(H)).


%!  heap_head(H, K, V)
%
%   Il predicato è vero quando l'elemento dello heap H con chiave minima
%   K è V

heap_head(H, K, V) :-
    heap_entry(H, 1, K, V).


%!  heap_insert(H, K, V)
%
%   Il predicato è vero quando l'elemento V è inserito nello heap H con
%   chiave K, è falso quando H non esiste

heap_insert(H, K, V) :-
    heap_has_size(H, S),
    NewS is S + 1,
    assert(heap_entry(H, NewS, K, V)),
    retract(heap(H, _)),
    assert(heap(H, NewS)),
    insert(H, NewS).


%!  insert(H, P)
%
%   Il predicato, di supporto a heap_insert/3, viene richiamato
%   sull'ultimo nodo, appena inserito, e lo fa risalire scambiandolo
%   eventualmente con il padre, in modo da mantenere le proprietà
%   dell'heap H

insert(_, 1) :-
    !.
insert(H, P) :-
    heap_entry(H, P, Kson, _),
    NewP is floor(P / 2),
    heap_entry(H, NewP, Kfather, _),
    Kson > Kfather,
    !.
insert(H, P) :-
    heap_entry(H, P, Kson, Vson),
    NewP is floor(P / 2),
    heap_entry(H, NewP, Kfather, Vfather),
    Kson = Kfather,
    Vson @>= Vfather,
    !.
insert(H, P) :-
    heap_entry(H, P, Kson, Vson),
    NewP is floor(P / 2),
    heap_entry(H, NewP, Kfather, Vfather),
    Kson = Kfather,
    Vson @< Vfather,
    retract(heap_entry(H, P, Kson, Vson)),
    retract(heap_entry(H, NewP, Kfather, Vfather)),
    assert(heap_entry(H, NewP, Kson, Vson)),
    assert(heap_entry(H, P, Kfather, Vfather)),
    insert(H, NewP),
    !.
insert(H, P) :-
    heap_entry(H, P, Kson, Vson),
    NewP is floor(P / 2),
    heap_entry(H, NewP, Kfather, Vfather),
    Kfather > Kson,
    retract(heap_entry(H, P, Kson, Vson)),
    retract(heap_entry(H, NewP, Kfather, Vfather)),
    assert(heap_entry(H, NewP, Kson, Vson)),
    assert(heap_entry(H, P, Kfather, Vfather)),
    insert(H, NewP),
    !.


%!  heap_extract(H, K, V)
%
%   Il predicato è vero quando la coppia K, V (con K minimo) è rimossa
%   dallo heap H

heap_extract(H, K, V) :-
    heap_has_size(H, 1),
    retract(heap_entry(H, 1, K, V)),
    retract(heap(H, 1)),
    assert(heap(H, 0)),
    !.
heap_extract(H, Khead, Vhead) :-
    retract(heap_entry(H, 1, Khead, Vhead)),
    heap_has_size(H, S),
    retract(heap_entry(H, S, K, V)),
    assert(heap_entry(H, 1, K, V)),
    retract(heap(H, S)),
    NewS is S - 1,
    assert(heap(H, NewS)),
    heapify(H, 1),
    !.

%!  heapify(H, P)
%
%   Il predicato, di supporto a heap_extract/2, viene richiamato sapendo
%   che i suoi "sottoalberi" sinistro e destro sono degli heap, e fa
%   "scendere" il nodo P fino alla posizione corretta per mantenere le
%   proprietà dell'heap H

%%  non ha figli
heapify(H, P) :-
    NewP is P * 2,
    heap_has_size(H, S),
    NewP > S,
    !.
%%  ha un figlio
%   è minore -> scambio
heapify(H, P) :-
    Pson is P * 2,
    heap_has_size(H, Pson),
    heap_entry(H, P, K, V),
    heap_entry(H, Pson, Kson, Vson),
    Kson < K,
    retract(heap_entry(H, P, K, V)),
    retract(heap_entry(H, Pson, Kson, Vson)),
    assert(heap_entry(H, Pson, K, V)),
    assert(heap_entry(H, P, Kson, Vson)),
    !.
%   è uguale, con lettere minori -> scambio
heapify(H, P) :-
    Pson is P * 2,
    heap_has_size(H, Pson),
    heap_entry(H, P, K, V),
    heap_entry(H, Pson, K, Vson),
    Vson @< V,
    retract(heap_entry(H, P, K, V)),
    retract(heap_entry(H, Pson, Kson, Vson)),
    assert(heap_entry(H, Pson, K, V)),
    assert(heap_entry(H, P, Kson, Vson)),
    !.
%   è uguale (con lettere maggiori) o maggiore -> NO
%   scambio
heapify(H, P) :-
    Pson is P * 2,
    heap_has_size(H, Pson),
    heap_entry(H, P, K, _V),
    heap_entry(H, Pson, Kson, _Vson),
    Kson >= K,
    !.
%%  ha due figli
%   entrambi maggiori -> NO scambio
heapify(H, Pfather) :-
    heap_entry(H, Pfather, Kfather, _Vfather),
    Pleft is Pfather * 2,
    heap_entry(H, Pleft, Kleft, _Vleft),
    Pright is Pleft + 1,
    heap_entry(H, Pright, Kright, _Vright),
    Kfather < Kleft,
    Kfather < Kright,
    !.
%   il figlio sinistro ha K minore al figlio dx e diverso dal padre ->
%   scambio
heapify(H, Pfather) :-
    heap_entry(H, Pfather, Kfather, Vfather),
    Pleft is Pfather * 2,
    heap_entry(H, Pleft, Kleft, Vleft),
    Pright is Pleft + 1,
    heap_entry(H, Pright, Kright, _Vright),
    Kleft < Kright,
    Kleft \= Kfather,
    retract(heap_entry(H, Pfather, Kfather, Vfather)),
    retract(heap_entry(H, Pleft, Kleft, Vleft)),
    assert(heap_entry(H, Pleft, Kfather, Vfather)),
    assert(heap_entry(H, Pfather, Kleft, Vleft)),
    heapify(H, Pleft),
    !.
%   il figlio destro ha K minore al figlio sx e diverso dal padre ->
%   scambio
heapify(H, Pfather) :-
    heap_entry(H, Pfather, Kfather, Vfather),
    Pleft is Pfather * 2,
    heap_entry(H, Pleft, Kleft, _Vleft),
    Pright is Pleft + 1,
    heap_entry(H, Pright, Kright, Vright),
    Kright < Kleft,
    Kright \= Kfather,
    retract(heap_entry(H, Pfather, Kfather, Vfather)),
    retract(heap_entry(H, Pright, Kright, Vright)),
    assert(heap_entry(H, Pright, Kfather, Vfather)),
    assert(heap_entry(H, Pfather, Kright, Vright)),
    heapify(H, Pright),
    !.
%   il figlio sinistro ha K minore al figlio dx (e uguale al padre),
%   lettera minore del padre -> scambio
heapify(H, Pfather) :-
    heap_entry(H, Pfather, Kfather, Vfather),
    Pleft is Pfather * 2,
    heap_entry(H, Pleft, Kleft, Vleft),
    Pright is Pleft + 1,
    heap_entry(H, Pright, Kright, _Vright),
    Kleft < Kright,
    Vleft @< Vfather,
    retract(heap_entry(H, Pfather, Kfather, Vfather)),
    retract(heap_entry(H, Pleft, Kleft, Vleft)),
    assert(heap_entry(H, Pleft, Kfather, Vfather)),
    assert(heap_entry(H, Pfather, Kleft, Vleft)),
    heapify(H, Pleft),
    !.
%   il figlio sinistro ha K minore al figlio dx (e uguale al padre),
%   (lettera maggiore/uguale del padre) -> NO scambio
heapify(H, Pfather) :-
    heap_entry(H, Pfather, _Kfather, _Vfather),
    Pleft is Pfather * 2,
    heap_entry(H, Pleft, Kleft, _Vleft),
    Pright is Pleft + 1,
    heap_entry(H, Pright, Kright, _Vright),
    Kleft < Kright,
    !.
%   il figlio destro ha K minore al figlio sx (e uguale al padre),
%   lettera minore del padre -> scambio
heapify(H, Pfather) :-
    heap_entry(H, Pfather, Kfather, Vfather),
    Pleft is Pfather * 2,
    heap_entry(H, Pleft, Kleft, _Vleft),
    Pright is Pleft + 1,
    heap_entry(H, Pright, Kright, Vright),
    Kright < Kleft,
    Vright @< Vfather,
    retract(heap_entry(H, Pfather, Kfather, Vfather)),
    retract(heap_entry(H, Pright, Kright, Vright)),
    assert(heap_entry(H, Pright, Kfather, Vfather)),
    assert(heap_entry(H, Pfather, Kright, Vright)),
    heapify(H, Pright),
    !.
%   il figlio destro ha K minore al figlio sx (e uguale al padre),
%   (lettera maggiore/uguale del padre) -> NO scambio
heapify(H, Pfather) :-
    heap_entry(H, Pfather, _Kfather, _Vfather),
    Pleft is Pfather * 2,
    heap_entry(H, Pleft, Kleft, _Vleft),
    Pright is Pleft + 1,
    heap_entry(H, Pright, Kright, _Vright),
    Kright < Kleft,
    !.
%   il figlio destro e sinistro sono uguali, la lettera sinistra è
%   minore/uguale alla lettera del destro -> scambio sx con padre
heapify(H, Pfather) :-
    heap_entry(H, Pfather, Kfather, Vfather),
    Pleft is Pfather * 2,
    heap_entry(H, Pleft, K, Vleft),
    Pright is Pleft + 1,
    heap_entry(H, Pright, K, Vright),
    Vleft @=< Vright,
    retract(heap_entry(H, Pfather, Kfather, Vfather)),
    retract(heap_entry(H, Pleft, K, Vleft)),
    assert(heap_entry(H, Pleft, Kfather, Vfather)),
    assert(heap_entry(H, Pfather, K, Vleft)),
    heapify(H, Pleft),
    !.
%   il figlio destro e sinistro sono uguali, la lettera sinistra è
%   maggiore della lettera del destro -> scambio dx con padre
heapify(H, Pfather) :-
    heap_entry(H, Pfather, Kfather, Vfather),
    Pleft is Pfather * 2,
    heap_entry(H, Pleft, K, Vleft),
    Pright is Pleft + 1,
    heap_entry(H, Pright, K, Vright),
    Vright @< Vleft,
    retract(heap_entry(H, Pfather, Kfather, Vfather)),
    retract(heap_entry(H, Pright, K, Vright)),
    assert(heap_entry(H, Pright, Kfather, Vfather)),
    assert(heap_entry(H, Pfather, K, Vright)),
    heapify(H, Pright),
    !.


%!  modify_key(H, NewKey, OldKey, V)
%
%   Il predicato è vero quando la chiave OldKey (associata al valore V)
%   è sostituita da NewKey (NewKey deve essere minore o uguale a OldKey)

modify_key(H, NewKey, OldKey, V) :-
    NewKey =< OldKey,
    retract(heap_entry(H, P, OldKey, V)),
    assert(heap_entry(H, P, NewKey, V)),
    insert(H, P).


%!  list_heap(H)
%
%   Il predicato stampa su console una lista degli heap_entry
%   dell'heap H, stampa falso se H non esiste

list_heap(H) :-
    heap(H, _),
    listing(heap_entry(H, _, _, _)).


%%%%%%%%%%%%%%%

%   Libreria MST
%
%   Predicates:
%
%   mst_prim(G, Source)
%   create_heap(G, Source, Ns)
%   create_vertex_key(Vs)
%
%   create_mst(G)
%   find_father(G, U, Father, K)
%   aggiorna_heap(Vs, U)
%
%   mst_get(G, Suorce, PreorderTree)
%   make_heap(G, Vs)
%   fill_heap(G, Source, PTs)
%   recursive_mst_get(G, Source, PreorderTree)


%!  mst_prim(G, Source)
%
%   Il predicato ha successo con un effetto collaterale: la base-dati
%   Prolog viene aggiornata e conterrà i predicati vertex_key(G, V, K)
%   per ogni V appartenente a G e conterrà anche i predicati
%   vertex_previous(G, V, U) per ogni V, ottenuti durante le iterazioni
%   dell'algoritmo di Prim

mst_prim(G, Source) :-
    vertex_neighbors(G, Source, Ns),
    new_heap(G),
    create_heap(G, Source, Ns),
    graph_vertices(G, Vs),
    create_vertex_key(Vs),
    retract(vertex_key(G, Source, inf)),
    assert(vertex_key(G, Source, 0)),
    assert(vertex_previous(G, Source, void)),
    create_mst(G),
    delete_heap(G).


%!  create_heap(G, Source, Ns)
%
%   Il predicato, di supporto a mst_prim/2, inserisce nell'heap G gli
%   heap_entry(G, K, V), corrispondenti agli archi arc(G, Source, V, K)
%   o arc(G, Source, V, K) della lista Ns

create_heap(_, _, []) :-
    !.
create_heap(G, Source, [arc(G, Source, V, K) | Ns]) :-
    heap_insert(G, K, V),
    create_heap(G, Source, Ns).
create_heap(G, Source, [arc(G, V, Source, K) | Ns]) :-
    heap_insert(G, K, V),
    create_heap(G, Source, Ns).


%!  create_vertex_key(Vs)
%
%   Il predicato, di supporto a mst_prim/2, inserisce nella base-dati
%   Prolog i vertex_key(G, V, inf), corrispondenti ai vertex(G, V) della
%   lista Vs

create_vertex_key([]).
create_vertex_key([vertex(G, V) | Vs]) :-
    assert(vertex_key(G, V, inf)),
    create_vertex_key(Vs).


%!  create_mst(G)
%
%   Il metodo, di supporto a mst_prim/2, esegue le iterazioni
%   dell'algoritmo di Prim, creando l'MST

create_mst(G) :-
    heap_empty(G),
    !.
create_mst(G) :-
    heap_not_empty(G),
    heap_extract(G, K, U),
    retract(vertex_key(G, U, inf)),
    assert(vertex_key(G, U, K)),
    find_father(G, U, Father, K),
    assert(vertex_previous(G, U, Father)),
    vertex_neighbors(G, U, Vs),
    aggiorna_heap(Vs, U),
    create_mst(G),
    !.


%!  find_father(G, U, Father, K)
%
%   Il predicato, di supporto a create_mst/2, trova il vertice dal quale
%   è partito l'arco con costo minore

find_father(G, U, Father, K) :-
    arc(G, U, Father, K),
    vertex_previous(G, Father, _).
find_father(G, U, Father, K) :-
    arc(G, Father, U, K),
    vertex_previous(G, Father, _).


%!  aggiorna_heap(Vs, U)
%
%   Il predicato, di suppporto a create_mst/2, aggiorna l'heap G,
%   inserendo gli arc(G, V, U, K) nel caso in cui V non faccia parte
%   dell'MST e sia già presente nell'heap G, se invece è già presente
%   aggiorna il costo con quello migliore

aggiorna_heap([], _) :-
    !.
aggiorna_heap([arc(G, V, U, K) | Vs], U) :-
    heap_entry(G, _, K1, V),
    Kmin is min(K, K1),
    modify_key(G, Kmin, K1, V),
    aggiorna_heap(Vs, U),
    !.
aggiorna_heap([arc(G, U, V, K) | Vs], U) :-
    heap_entry(G, _, K1, V),
    Kmin is min(K, K1),
    modify_key(G, Kmin, K1, V),
    aggiorna_heap(Vs, U),
    !.
aggiorna_heap([arc(G, V, U, _) | Vs], U) :-
    vertex_previous(G, V, _),
    aggiorna_heap(Vs, U),
    !.
aggiorna_heap([arc(G, U, V, _) | Vs], U) :-
    vertex_previous(G, V, _),
    aggiorna_heap(Vs, U),
    !.
aggiorna_heap([arc(G, V, U, K) | Vs], U) :-
    heap_insert(G, K, V),
    aggiorna_heap(Vs, U),
    !.
aggiorna_heap([arc(G, U, V, K) | Vs], U) :-
    heap_insert(G, K, V),
    aggiorna_heap(Vs, U),
    !.


%!  mst_get(G, Suorce, PreorderTree)
%
%   Il predicato è vero quando PreorderTree è una lista degli archi
%   del MST ordinata secondo un attraversamento preorder dello stesso,
%   fatta rispetto al peso dell'arco

mst_get(G, Source, PreorderTree) :-
    graph_vertices(G, Vs),
    make_heap(G, Vs),
    recursive_mst_get(G, Source, PreorderTree),
    retractall(vertex_key(G, _, _)),
    retractall(vertex_previous(G, _, _)).


%!  make_heap(G, Vs)
%
%   Il predicato, di supporto a mst_get/3, crea un heap per ogni vertice
%   V di G (contenuti in Vs) e riempie ogni heap V con tutti i suoi
%   figli

make_heap(_, []) :-
    !.
make_heap(G, [vertex(G, Source) | Vs]) :-
    findall(V, vertex_previous(G, V, Source), Ls),
    new_heap(Source),
    fill_heap(G, Source, Ls),
    make_heap(G, Vs),
    !.


%!  fill_heap(G, Source, Ls)
%
%   Il predicato, di supporto a make_heap/2, riempie l'heap Source con
%   tutti i "vertici" contenuti in Ls

fill_heap(_, _, []) :-
    !.
fill_heap(G, Source, [L | Ls]) :-
    vertex_key(G, L, K),
    heap_insert(Source, K, L),
    fill_heap(G, Source, Ls),
    !.


%!  recursive_mst_get(G, Source, PreorderTree)
%
%   Il predicato, di supporto a mst_get/3, è vero quando PreorderTree è
%   una lista degli archi dell'MST ordinata secondo un attraversamento
%   preorder dello stesso, fatta rispetto al peso dell'arco

recursive_mst_get(_, Source, []) :-
    heap_empty(Source),
    delete_heap(Source),
    !.
recursive_mst_get(G, Source, [arc(G, Source, V, K) | PTs]) :-
    heap_extract(Source, K, V),
    recursive_mst_get(G, V, PT1s),
    recursive_mst_get(G, Source, PT2s),
    append(PT1s, PT2s, PTs),
    !.



%%%% end of file -- mst.pl



















