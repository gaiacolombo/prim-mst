;;;; -*- Mode: Lisp -*-



;;;; mst.lisp

;;;; PROGETTO DI:
;;;; Colombo Gaia (matricola 856483)
;;;; Erba Sandro (matricola 856327)



(defparameter *graphs* (make-hash-table :test #'equal))
(defparameter *vertices* (make-hash-table :test #'equal))
(defparameter *arcs* (make-hash-table :test #'equal))
(defparameter *visited* (make-hash-table :test #'equal))
(defparameter *vertex-keys* (make-hash-table :test #'equal))
(defparameter *previous* (make-hash-table :test #'equal))
(defparameter *heaps* (make-hash-table :test #'equal))



;;;; Graph


;; is-graph: graph-id -> graph-id or NIL
;; Ritorna il graph-id stesso se questo grafo è già stato creato,
;; altrimenti NIL

(defun is-graph (graph-id)
  (gethash graph-id *graphs*))


;; new-graph: graph-id -> graph-id
;; Genera un nuovo grafo e lo inserisce nel data-base (ovvero nella
;; hash-table) dei grafi

(defun new-graph (graph-id)
  (or (is-graph graph-id)
      (setf (gethash graph-id *graphs*) graph-id)))


;; delete-graph: graph-id -> NIL
;; Rimuove l'intero grafo dal sistema

(defun delete-graph (graph-id)
  (delete-vertex-keys graph-id)
  (delete-previous graph-id)
  (delete-arcs (graph-arcs graph-id))
  (delete-vertices (graph-vertices graph-id))
  (remhash graph-id *graphs*)
  (is-graph graph-id))

(defun delete-vertices (l)
  (cond
   ((null l)
    NIL)
   (T
    (remhash (first l) *vertices*)
    (delete-vertices (rest l)))))

(defun delete-arcs (l)
  (cond
   ((null l)
    NIL)
   (T
    (remhash (without-last (first l)) *arcs*)
    (delete-arcs (rest l)))))

(defun without-last (l)
  (reverse (cdr (reverse l))))

(defun delete-vertex-keys (graph-id)
  (maphash (lambda (k v) (if (eq (second v)
                                 graph-id)
                             (remhash
                              (list 'vertex-key
                                    graph-id (third v))
                              *vertex-keys*))) *vertex-keys*))

(defun delete-previous (graph-id)
  (maphash (lambda (k v) (if (eq (second v)
                                 graph-id)
                             (remhash
                              (list 'previous
                                    graph-id (third v))
                              *previous*))) *previous*))


;; new-vertex: graph-id vertex-id -> vertex-rep
;; Aggiunge un nuovo vertice vertex-id al grafo graph-id,
;; ritorna NIL se il grafo graph-id non esiste

(defun new-vertex (graph-id vertex-id)
  (cond
   ((not (is-graph graph-id))
    NIL)
   (T
    (setf (gethash (list 'vertex graph-id vertex-id) *vertices*)
          (list 'vertex graph-id vertex-id)))))


;; graph-vertices: graph-id -> vertex-rep-list
;; Torna una lista di vertici del grafo,
;; ritorna NIL se il grafo graph-id non esiste

(defun graph-vertices (graph-id)
  (let ((values nil))
    (maphash (lambda (k v) (if (eq (second v) graph-id)
                               (push v values))) *vertices*)
    values))


;; new-arc: graph-id vertex-id vertex-id &optional (weight 1) ->
;; arc-rep
;; Aggiunge un arco del grafo graph-id nella hash-table *arcs*,
;; ritorna NIL se il grafo graph-id non esiste, se uno dei due
;; vertex-id non esiste, se l'arco è un cappio, o se il peso è minore
;; di 0 Se l'arco esiste già, il suo peso viene sostituito con
;; quello nuovo

(defun new-arc (graph-id vertex1-id vertex2-id &optional (weight 1))
  (cond
   ((eq vertex1-id vertex2-id) NIL)
   ((< weight 0) NIL)
   ((not (is-graph graph-id)) NIL)
   ((not (gethash (list 'vertex graph-id vertex1-id) *vertices*))
    NIL)
   ((not (gethash (list 'vertex graph-id vertex2-id) *vertices*))
    NIL)
   ((or (gethash (list 'arc graph-id vertex1-id vertex2-id) *arcs*)
	(gethash (list 'arc graph-id vertex2-id vertex1-id) *arcs*))
    (setf (gethash (list 'arc graph-id vertex1-id vertex2-id) *arcs*)
          (list 'arc graph-id vertex1-id vertex2-id weight)))
   (T (setf (gethash (list 'arc graph-id vertex1-id vertex2-id)
		     *arcs*)
	    (list 'arc graph-id vertex1-id vertex2-id weight)))))


;; graph-arcs: graph-id -> arc-rep-list
;; Ritorna una lista una lista di tutti gli archi presenti in graph-id

(defun graph-arcs (graph-id)
  (let ((values nil))
    (maphash (lambda (k v) (if (eq (second v) graph-id)
                               (push v values))) *arcs*)
    values))


;; graph-vertex-neighbors: graph-id vertex-id -> arc-rep-list
;; Ritorna una lista arc-rep-list contenente gli archi (arc graph-id
;; vertex-id N W) che portano ai vertici immediatamente raggiungibili
;; da vertex-id
;; Ritorna NIL se il vertice vertex-id non esiste in graph-id

(defun graph-vertex-neighbors (graph-id vertex-id)
  (recursive-neighbors (graph-arcs graph-id) vertex-id))

(defun recursive-neighbors (l vertex-id)
  (cond
   ((null l) NIL)
   ((or (eql (third (first l)) vertex-id)
        (eql (fourth (first l)) vertex-id))
    (cons (first l)
          (recursive-neighbors (rest l) vertex-id)))
   (T (recursive-neighbors (rest l) vertex-id))))


;; graph-vertex-adjacent: graph-id vertex-id -> vertex-rep-list
;; Ritorna una lista vertex-rep-list contenente
;; i vertici (arc graph-id vertex-id V) adiacenti a vertex-id
;; Ritorna NIL se il vertice vertex-id non esiste in graph-id

(defun graph-vertex-adjacent (graph-id vertex-id)
  (recursive-adjacent (graph-vertices graph-id) graph-id vertex-id))

(defun recursive-adjacent (list graph-id vertex-id)
  (cond
   ((null list)
    nil)
   ((vertex-near graph-id vertex-id (third (first list)))
    (cons (first list) (recursive-adjacent (rest list)
					   graph-id vertex-id)))
   (T
    (recursive-adjacent (rest list) graph-id vertex-id))))

(defun vertex-near (graph-id vertex1-id vertex2-id)
  (or (gethash (list 'arc graph-id vertex1-id vertex2-id) *arcs*)
      (gethash (list 'arc graph-id vertex2-id vertex1-id) *arcs*)))


;; graph-print: graph-id -> boolean
;; Stampa alla console una lista dei vertici e degli archi del grafo
;; graph-id

(defun graph-print (graph-id)
  (format t "~S~%~S~%" (graph-vertices graph-id)
	  (graph-arcs graph-id)))



;;;; MinHeap


;; new-heap: heap-id &optional (capacity 42) -> heap-rep
;; Inserisce un nuovo heap nella hash-table *heaps*

(defun new-heap (heap-id &optional (capacity 42))
  (or (gethash heap-id *heaps*)
      (setf (gethash heap-id *heaps*)
            (list 'heap heap-id 0 (make-array capacity :adjustable t)
                  (make-hash-table :test #'equal)))))

(defun heap-size (heap-id)
  (third (gethash heap-id *heaps*)))

(defun heap-actual-heap (heap-id)
  (fourth (gethash heap-id *heaps*)))

(defun is-heap (heap-id)
  (gethash heap-id *heaps*))


;; heap-delete: heap-id -> T
;; Rimuove tutto lo heap indicizzato da heap-id

(defun heap-delete (heap-id)
  (remhash heap-id *heaps*))


;; heap-empty: heap-id -> boolean
;; È vero quando lo heap heap-id non contiene elementi,
;; NIL altrimenti, o se l'heap heap-id non esiste

(defun heap-empty (heap-id)
  (if (is-heap heap-id)
      (zerop (heap-size heap-id))))


;; heap-not-empty: heap-id -> boolean
;; È vero quando lo heap heap-id contiene almeno un elemento

(defun heap-not-empty (heap-id)
  (if (is-heap heap-id)
      (> (heap-size heap-id) 0)))


;; heap-head: heap-id -> (K V)
;; Ritorna una lista di due elementi dove K è la chiave minima
;; e V il valore associato, ritorna NIL se l'heap heap-id non esiste

(defun heap-head (heap-id)
  (if (is-heap heap-id)
      (aref (heap-actual-heap heap-id) 0)))

(defun k-head (heap-id)
  (first (heap-head heap-id)))

(defun v-head (heap-id)
  (second (heap-head heap-id)))


;; heap-insert: heap-id K V -> boolean
;; Inserisce l'elemento V nello heap heap-id con chiave K,
;; ritorna NIL se l'heap-id non esiste, se l'heap è pieno raddoppia
;; la sua capacità

(defun heap-insert (heap-id k v)
  (cond ((is-heap heap-id)
         (if (= (length (heap-actual-heap heap-id))
		(heap-size heap-id))
             (setf (fourth (gethash heap-id *heaps*))
		   (adjust-array
		    (heap-actual-heap heap-id)
		    (list (+ (* (length (heap-actual-heap heap-id))
			     2) 1)))))
         (setf (aref (heap-actual-heap heap-id) (heap-size heap-id))
	       (list k v))
         (set-position heap-id k v (heap-size heap-id))
         (insert heap-id (heap-size heap-id) k v)
         (setf (third (gethash heap-id *heaps*))
	       (1+ (heap-size heap-id)))
         T)))

(defun p-father (p)
  (truncate (/ (1- p) 2)))

(defun k-father (heap-id p)
  (first (aref (heap-actual-heap heap-id) (p-father p))))

(defun v-father (heap-id p)
  (second (aref (heap-actual-heap heap-id) (p-father p))))

(defun insert (heap-id p k v)
  (cond
   ((zerop p)
    NIL)
   ((< (k-father heap-id p) k)
    NIL)
   ((and (numberp v)
         (numberp (v-father heap-id p))
         (= (k-father heap-id p) k)
         (>= v (v-father heap-id p)))
    NIL)
   ((and (or (not (numberp v))
             (not (numberp (v-father heap-id p))))
         (= (k-father heap-id p) k)
         (string>= (write-to-string v)
                   (write-to-string (v-father heap-id p))))
    NIL)
   (T
    (invert heap-id p k v (p-father p))
    (insert heap-id (p-father p) k v))))

(defun invert (heap-id p k v pinvert)
  (setf (aref (heap-actual-heap heap-id) p) 
        (aref (heap-actual-heap heap-id) pinvert))
  (setf (aref (heap-actual-heap heap-id) pinvert)
        (list k v))
  (set-position heap-id k v pinvert)
  (set-position heap-id (first (aref (heap-actual-heap heap-id) p))
                (second (aref (heap-actual-heap heap-id) p)) p))


;; heap-extract: heap-id -> (K V)
;; Ritorna la lista con K, V e con K minima, la coppia è rimossa
;; dall'heap heap-id, ritorna NIL se l'heap heap-id non esiste o
;; se è vuoto

(defun heap-extract (heap-id)
  (let ((values NIL))
    (cond
     ((and (is-heap heap-id)
           (heap-not-empty heap-id))
      (push (second (heap-head heap-id)) values)
      (push (first (heap-head heap-id)) values)
      (delete-position heap-id (second (heap-head heap-id)))
      (setf (aref (heap-actual-heap heap-id) 0)
            (aref (heap-actual-heap heap-id)
		  (1- (heap-size heap-id))))
      (setf (aref (heap-actual-heap heap-id)
		  (1- (heap-size heap-id)))
            NIL)
      (setf (third (gethash heap-id *heaps*))
            (1- (heap-size heap-id)))
      (heapify heap-id 0 (first (aref (heap-actual-heap heap-id) 0))
               (second (aref (heap-actual-heap heap-id) 0)))))
    values))

(defun heapify (heap-id p k v)
  (cond
   ((>= (p-left p) (heap-size heap-id))
    NIL)
   ((= (p-right p) (heap-size heap-id))
    (cond
     ((< (k-left heap-id p) k)
      (invert heap-id p k v (p-left p)))
     ((and (numberp (v-left heap-id p))
           (numberp v)
           (= (first (aref (heap-actual-heap heap-id) (p-left p))) k)
           (< (v-left heap-id p) v))
      (invert heap-id p k v (p-left p)))
     ((and (or (not (numberp (v-left heap-id p)))
               (not (numberp v)))
       (= (first (aref (heap-actual-heap heap-id) (p-left p))) k)
           (string< (write-to-string (v-left heap-id p))
                    (write-to-string v)))
      (invert heap-id p k v (p-left p)))
     (T nil)))
   (T
    (cond
     ((and (> (k-left heap-id p) k)
           (> (k-right heap-id p) k))
      NIL)
     ((and (< (k-left heap-id p) (k-right heap-id p))
           (/= (k-left heap-id p) k))
      (invert heap-id p k v (p-left p))
      (heapify heap-id (p-left p) k v))
     ((and (> (k-left heap-id p) (k-right heap-id p))
           (/= (k-right heap-id p) k))
      (invert heap-id p k v (p-right p))
      (heapify heap-id (p-right p) k v ))
     
     ((and (numberp (v-left heap-id p))
           (numberp v)
           (< (k-left heap-id p) (k-right heap-id p))
           (= (k-left heap-id p) k)
           (< (v-left heap-id p) v))
      (invert heap-id p k v (p-left p))
      (heapify heap-id (p-left p) k v))
     ((and (or (not (numberp (v-left heap-id p)))
               (not (numberp v)))
           (< (k-left heap-id p) (k-right heap-id p))
           (= (k-left heap-id p) k)
           (string< (write-to-string (v-left heap-id p))
                    (write-to-string v)))
      (invert heap-id p k v (p-left p))
      (heapify heap-id (p-left p) k v))

      ((and (numberp (v-left heap-id p))
            (numberp v)
            (< (k-left heap-id p) (k-right heap-id p))
            (= (k-left heap-id p) k)
            (>= (v-left heap-id p) v))
      NIL)
     ((and (or (not (numberp (v-left heap-id p)))
               (not (numberp v)))
           (< (k-left heap-id p) (k-right heap-id p))
           (= (k-left heap-id p) k)
           (string>= (write-to-string (v-left heap-id p))
                     (write-to-string v)))
      NIL)

     ((and (numberp (v-right heap-id p))
           (numberp v)
           (> (k-left heap-id p) (k-right heap-id p))
           (= (k-right heap-id p) k)
           (< (v-right heap-id p) v))
      (invert heap-id p k v (p-right p))
      (heapify heap-id (p-right p) k v ))
     ((and (or (not (numberp (v-right heap-id p)))
               (not (numberp v)))
           (> (k-left heap-id p) (k-right heap-id p))
           (= (k-right heap-id p) k)
           (string< (write-to-string (v-right heap-id p))
                    (write-to-string v)))
      (invert heap-id p k v (p-right p))
      (heapify heap-id (p-right p) k v ))

     ((and (numberp (v-right heap-id p))
           (numberp v)
           (> (k-left heap-id p) (k-right heap-id p))
           (= (k-right heap-id p) k)
           (>= (v-right heap-id p) v))
      NIL)
     ((and (or (not (numberp (v-right heap-id p)))
               (not (numberp v)))
           (> (k-left heap-id p) (k-right heap-id p))
           (= (k-right heap-id p) k)
           (string>= (write-to-string (v-right heap-id p))
                     (write-to-string v)))
      NIL)

     ((and (numberp (v-left heap-id p))
           (numberp (v-right heap-id p))
           (= (k-left heap-id p) (k-right heap-id p))
           (<= (v-left heap-id p) (v-right heap-id p)))
      (invert heap-id p k v (p-left p))
      (heapify heap-id (p-left p) k v ))
     ((and (or (not (numberp (v-left heap-id p)))
               (not (numberp (v-right heap-id p))))
           (= (k-left heap-id p) (k-right heap-id p))
           (string<= (write-to-string (v-left heap-id p))
                     (write-to-string (v-right heap-id p))))
      (invert heap-id p k v (p-left p))
      (heapify heap-id (p-left p) k v ))

     ((and (numberp (v-left heap-id p))
           (numberp (v-right heap-id p))
           (= (k-left heap-id p) (k-right heap-id p))
           (> (v-left heap-id p) (v-right heap-id p)))
      (invert heap-id p k v (p-right p))
      (heapify heap-id (p-right p) k v ))
     ((and (or (not (numberp (v-left heap-id p)))
               (not (numberp (v-right heap-id p))))
           (= (k-left heap-id p) (k-right heap-id p))
           (string> (write-to-string (v-left heap-id p))
                    (write-to-string (v-right heap-id p))))
      (invert heap-id p k v (p-right p))
      (heapify heap-id (p-right p) k v ))))))

(defun p-left (p)
  (+ 1 (* 2 p)))

(defun p-right (p)
  (+ 2 (* 2 p)))

(defun k-left (heap-id p)
  (first (aref (heap-actual-heap heap-id) (p-left p))))

(defun k-right (heap-id p)
  (first (aref (heap-actual-heap heap-id) (p-right p))))

(defun v-left (heap-id p)
  (second (aref (heap-actual-heap heap-id) (p-left p))))

(defun v-right (heap-id p)
  (second (aref (heap-actual-heap heap-id) (p-right p))))


;; heap-modify-key: heap-id new-key old-key V -> boolean
;; Sostituisce la chiave OldKey (associata al valore V) con NewKey,
;; se NewKey è minore di OldKey

(defun heap-modify-key (heap-id new-key old-key v)
  (cond
   ((< new-key old-key)
    (setf (aref (heap-actual-heap heap-id) (get-position heap-id v))
          (list new-key v))
    (set-position heap-id new-key v (get-position heap-id v))
    (insert heap-id (get-position heap-id v) new-key v)
    T)
   (T NIL)))


;; heap-print: heap-id -> boolean
;; Stampa sulla console lo stato interno dello heap heap-id

(defun heap-print (heap-id)
  (format t "~S~%" (heap-actual-heap heap-id)))


;; position

(defun set-position (heap-id k v p)
  (setf (gethash (list 'position heap-id v) (get-hash-table heap-id))
	(list 'position heap-id k v p)))

(defun get-hash-table (heap-id)
  (fifth (is-heap heap-id)))

(defun get-position (heap-id v)
  (fifth (gethash (list 'position heap-id v)
		  (get-hash-table heap-id))))

(defun get-k (heap-id v)
  (third (gethash (list 'position heap-id v)
		  (get-hash-table heap-id))))

(defun delete-position (heap-id v)
  (remhash (list 'position heap-id v) (get-hash-table heap-id)))



;;;; Prim


;; mst-vertex-key: graph-id vertex-id -> k
;; Dato un vertex-id di un grafo graph-id ritorna, durante e dopo
;; l'esecuzione dell'algoritmo di Prim, il peso minimo di un arco
;; che connette vertex-id nell'albero minimo, se questo arco non
;; esiste (ed all'inizio dell'esecuzione) allora k è
;; MOST-POSITIVE-DOUBLE-FLOAT

(defun mst-vertex-key (graph-id vertex-id)
  (fourth (gethash (list 'vertex-key graph-id vertex-id)
		   *vertex-keys*)))

(defun set-vertex-key (graph-id k vertex-id)
  (setf (gethash (list 'vertex-key graph-id vertex-id) *vertex-keys*)
        (list 'vertex-key graph-id vertex-id k)))


;; mst-previous: graph-id V -> U
;; Durante e dopo l'esecuzione dell'algoritmo di Prim, ritorna il
;; vertice U che è il vertice "genitore" di V nel MST V

(defun mst-previous (graph-id v)
  (fourth (gethash (list 'previous graph-id v) *previous*)))

(defun set-previous (graph-id v u)
  (setf (gethash (list 'previous graph-id v) *previous*)
        (list 'previous graph-id v u)))


;; visited

(defun visit (graph-id v)
  (setf (gethash (list 'visited graph-id v) *visited*)
        (list 'visited graph-id v)))

(defun check-visit (graph-id v)
  (gethash (list 'visited graph-id v) *visited*))


;; mst-prim: graph-id source -> NIL
;; Dopo la sua esecuzione, la hash-table *vertex-key* contiene al suo
;; interno le associazioni (graph-id V) -> d per ogni V appartenente a
;; graph-id La hash-table *previous* contiene le associazioni
;; (graph-id V) -> U calcolate durante l'esecuzione dell'algoritmo di

(defun mst-prim (graph-id source)
  (new-heap graph-id)
  (create-heap graph-id source
	       (graph-vertex-neighbors graph-id source))
  (create-vertex-key (graph-vertices graph-id))
  (set-vertex-key graph-id 0 source)
  (visit graph-id source)
  (set-previous graph-id source nil)
  (create-mst graph-id)
  (heap-delete graph-id))

(defun create-heap (graph-id source l)
  (cond
   ((null l)
    NIL)
   ((equal source (third (first l)))
    (heap-insert graph-id (fifth (first l)) (fourth (first l)))
    (create-heap graph-id source (rest l)))
   ((equal source (fourth (first l)))
    (heap-insert graph-id (fifth (first l)) (third (first l)))
    (create-heap graph-id source (rest l)))))

(defun create-vertex-key (l)
  (cond
   ((null l)
    NIL)
   (T
    (set-vertex-key (second (first l))
		    MOST-POSITIVE-DOUBLE-FLOAT (third (first l)))
    (create-vertex-key (rest l)))))

(defun create-mst (heap-id)
  (cond
   ((heap-empty heap-id)
    NIL)
   (T
    (set-vertex-key heap-id (k-head heap-id) (v-head heap-id))
    (set-previous heap-id (v-head heap-id)
                  (find-father heap-id
			       (graph-vertex-neighbors
				heap-id (v-head heap-id))
                               (k-head heap-id) (v-head heap-id)))
    (visit heap-id (v-head heap-id))
    (aggiorna-heap heap-id
                   (graph-vertex-neighbors heap-id (v-head heap-id))
                   (second (heap-extract heap-id)))
    (create-mst heap-id))))

(defun find-father (heap-id l k v)
  (cond
   ((null l)
    NIL)
   ((and (equal (third (first l)) v)
         (= (fifth (first l)) k)
         (check-visit heap-id (fourth (first l))))
    (fourth (first l)))
   ((and (equal (fourth (first l)) v)
         (= (fifth (first l)) k)
         (check-visit heap-id (third (first l))))
    (third (first l)))
   (T
    (find-father heap-id (rest l) k v))))

(defun aggiorna-heap (heap-id l u)
  (cond
   ((null l)
    NIL)
   ((and (not (equal (and (equal (fourth (first l)) u)
                          (get-k heap-id (third (first l))))
                     NIL))
         (< (fifth (first l)) (get-k heap-id (third (first l)))))
    (heap-modify-key heap-id (fifth (first l))
                     (get-k heap-id (third (first l)))
		     (third (first l)))
    (aggiorna-heap heap-id (rest l) u))
   ((and (not (equal (and (equal (third (first l)) u)
                          (get-k heap-id (fourth (first l))))
                     NIL))
         (< (fifth (first l)) (get-k heap-id (fourth (first l)))))
    (heap-modify-key heap-id (fifth (first l))
                     (get-k heap-id (fourth (first l)))
		     (fourth (first l)))
    (aggiorna-heap heap-id (rest l) u))
   ((and (equal (fourth (first l)) u)
         (check-visit heap-id (third (first l))))
    (aggiorna-heap heap-id (rest l) u))
   ((and (equal (third (first l)) u)
         (check-visit heap-id (fourth (first l))))
    (aggiorna-heap heap-id (rest l) u))
   ((and (not (equal (and (equal (fourth (first l)) u)
                          (get-k heap-id (third (first l)))) NIL))
         (>= (fifth (first l)) (get-k heap-id (third (first l)))))
    (aggiorna-heap heap-id (rest l) u))
   ((and (not (equal (and (equal (third (first l)) u)
                          (get-k heap-id (fourth (first l)))) NIL))
         (>= (fifth (first l)) (get-k heap-id (fourth (first l)))))
    (aggiorna-heap heap-id (rest l) u))
   ((equal (third (first l)) u)
    (heap-insert heap-id (fifth (first l)) (fourth (first l)))
    (aggiorna-heap heap-id (rest l) u))
   ((equal (fourth (first l)) u)
    (heap-insert heap-id (fifth (first l)) (third (first l)))
    (aggiorna-heap heap-id (rest l) u))
   (T
    (aggiorna-heap heap-id (rest l) u))))



;; mst-get: graph-id source -> preorder-mst
;; Questa funzione ritorna preorder-mst che è una lista degli archi
;; del MST ordinata secondo un attraversamento preorder dello stesso,
;; fatta rispetto al peso dell'arco

(defun mst-get (graph-id source)
  (make-heap graph-id (graph-vertices graph-id))
  (rest (recursive-mst-get graph-id source)))


(defun make-heap (heap-id l)
  (cond
   ((null l)
    NIL)
   (T
    (new-heap (third (first l)))
    (fill-heap heap-id (third (first l))
	       (let ((values NIL))
                 (maphash (lambda (k v)
                            (if (equal (third (first l))
                                       (mst-previous heap-id
						     (third v)))
                                (push (third v) values))) *previous*)
                 values))
    (make-heap heap-id (rest l)))))


(defun fill-heap (heap-id source l)
  (cond
   ((null l)
    NIL)
   (T
    (heap-insert source (mst-vertex-key heap-id (first l)) (first l))
    (fill-heap heap-id source (rest l)))))


(defun recursive-mst-get (heap-id source)
  (cond
   ((check-visit heap-id source) 
    (remhash (list 'visited heap-id source) *visited*) 
    (append (list (list 'arc heap-id (mst-previous heap-id source)
                        source (mst-vertex-key heap-id source)))
            (recursive-mst-get heap-id source)))
   ((heap-empty source)
    (heap-delete source)
    (remhash (list 'previous heap-id source) *previous*)
    (remhash (list 'vertex-key heap-id source) *vertex-keys*)
    NIL)
   (T
    (append 
     (recursive-mst-get heap-id (second (heap-extract source)))
     (recursive-mst-get heap-id source)))))



;;;; end of file - mst.lisp
