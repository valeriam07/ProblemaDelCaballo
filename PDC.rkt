#lang racket

;                   ______________________________________________________________________________
;__________________/ PDC-sol

;size(int) = size x size, initial = (x, y)
(define (PDC-sol size initial)
  (sol_aux size (list initial) (possibleMoves initial size (list initial)))) ;lista de movimientos -> 1.posicion inicial (initial)

(define (sol_aux size mov pmoves)
  (cond((equal? (getsize mov) (* size size)) mov) ;Se recorrio todo el tablero 
       ((null? mov) "No hay solucion, fin del tour")
       ((null? pmoves)
        (display "vacio") 
        (sol_aux size mov (cdr pmoves)))
       (else
        (sol_aux size (append mov (list (car (quicksort pmoves size mov)))) (possibleMoves (car (quicksort pmoves size mov)) size (append mov (list (car (quicksort pmoves size mov))))))
       )))

;Quicksort -> organiza la matriz de posibles movimientos segun el numero de vecinos de cada uno 
(define (quicksort lista size mov) ;lista = pmoves
  (cond ((null? lista) '())
        (else (append (quick_menores lista (neighbour-count lista size mov) size mov)
                      (list(car lista))
                      (quick_mayores lista (neighbour-count lista size mov) size mov)))))

(define (quick_menores lista pivote size mov)
  (cond ((null? lista) '())
        ((< (neighbour-count lista size mov) pivote) (quicksort (cons (car lista) (quick_menores (cdr lista) pivote size mov)) size mov))
        (else (quick_menores (cdr lista) pivote size mov)) ))

(define (quick_mayores lista pivote size mov)
  (cond ((null? lista) '())
        ((> (neighbour-count lista size mov) pivote) (quicksort (cons (car lista) (quick_mayores (cdr lista) pivote size mov)) size mov))
        (else (quick_mayores (cdr lista) pivote size mov)) ))
  
;Asignar numero de vecinos de cada posible movimiento 
(define (neighbour-count pmoves size mov)
  (getsize (possibleMoves (car pmoves) size mov))) ;retorna numero de vecinos
  
;Ultimo elemento de la lista mov = posicion actual
(define (last-element lst)
  (cond ((null? (cdr lst)) (car lst))
        (else (last-element (cdr lst)))))

  
;Generar lista de posibles movimientos a partir de una posicion
(define (possibleMoves pos size mov)
  (visited (validate (list (cons (- (car pos) 2) (cons (+ (cadr pos) 1) '()))
                           (cons (- (car pos) 2) (cons (- (cadr pos) 1) '()))
                           (cons (- (car pos) 1) (cons (+ (cadr pos) 2) '()))
                           (cons (- (car pos) 1) (cons (- (cadr pos) 2) '()))
                           (cons (+ (car pos) 1) (cons (+ (cadr pos) 2) '()))
                           (cons (+ (car pos) 1) (cons (- (cadr pos) 2) '()))
                           (cons (+ (car pos) 2) (cons (+ (cadr pos) 1) '()))
                           (cons (+ (car pos) 2) (cons (- (cadr pos) 1) '()))) size) mov))
       
;Eliminar movimientos invalidos/fuera del tablero
(define (validate pmoves size)
  (cond ((null? pmoves) '())
        ((or(< (caar pmoves) 1) (> (caar pmoves) size) (< (cadar pmoves) 1) (> (cadar pmoves) size))(validate (cdr pmoves) size))
        (else (cons (car pmoves) (validate (cdr pmoves) size)))))

;Eliminar movimientos hacia casillas ya visitadas
(define (visited pmoves mov)
  (cond ((null? pmoves) '()) ;se recorrio todo pmoves -> fin, no se repite
        ((eq? (miembro (car pmoves) mov) #t) (visited (cdr pmoves) mov)) ;se encontro una coincidencia = eliminar y seguir
        (else (cons (car pmoves) (visited (cdr pmoves) mov)))))

(define (miembro pos mov) ;pos = elemento en pmoves, mov = matriz de movimientos
  (cond ((null? mov) #f)
        ((and (equal? (car pos) (caar mov)) (equal? (cadr pos) (cadar mov))) #t)
        (else (miembro pos (cdr mov)))))

;Obtener numero de filas de una matriz
(define (getsize matrix)
  (getsize_aux matrix 0))

(define (getsize_aux matrix i)
  (cond((null? matrix) i)
       (else (getsize_aux (cdr matrix) (add1 i)))))


;                   ______________________________________________________________________________
;__________________/ PDC-test

(define (PDC-test size sol)
  (cond((equal? (getsize sol) size) (test_aux size (getMov size sol) (list (car sol))))
       (else "No es solucion el tamaño no calza")
  ))

(define (test_aux size sol mov)
  (cond((or (null? mov) (null? sol)) "No es solucion")
       ((equal? (getsize sol) 1) "si es una posible solucion") ;llego al ultimo movimiento
       ((eq? (miembro (cadr sol) (possibleMoves (car sol) size mov)) #t) (test_aux size (cdr sol) (append mov (list(cadr sol)))))
       (else "No es solucion")))

(define (getMov size sol)
  (getMov_aux size sol '() 1)
  )

(define (getMov_aux size sol mov i)
  (cond((equal? (getsize mov) (* size size)) mov)
       ((null? (getPos i sol)) '()) ;no se encontro el siguiente elemento -> no es solucion 
       (else (getMov_aux size sol (append mov (list (getPos i sol))) (add1 i)))))

(define (getPos ele matrix)
  (getPos_aux ele matrix 1))

(define (getPos_aux ele matrix i)
  (cond((null? matrix) '()) ;no se encontro el elemento
       ((> (searchRow ele (car matrix) 1) 0) (append (list i) (list (searchRow ele (car matrix) 1))))
       (else (getPos_aux ele (cdr matrix) (add1 i)))))

(define (searchRow ele row j)
  (cond ((null? row) 0)
        ((equal? ele (car row)) j)
        (else (searchRow ele (cdr row) (add1 j)))))

        
  


;(PDC-sol 5 '(1 1))

#|(PDC-test 5 '((1 16 21 10 7)
              (22 11 8 15 20)
              (17 2 23 6 9)
              (12 25 4 19 14)
              (3 18 13 24 5)))

(PDC-test 5 '((1 14 9 20 3)
              (24 19 2 15 10)
              (13 8 23 4 21)
              (18 25 6 11 16)
              (7 12 17 22 5))

(PDC-test 5 '((1 16 21 10 7)
              (22 11 8 15 20)
              (17 2 23 6 9)
              (12 25 4 19 14)
              (3 18 13 24 4)) |#