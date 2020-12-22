; Aidan Zamboni (AID)
; Program 12b
; Functions for playing Connect 4.
; Uses markers "A" and "V". "A" goes first.
; AIDMakeMove works with either marker.

; Table of Contents
; PART 12A ------------------------- 32
;   Function 1 - AIDGetCell -------- 34
;   Function 2 - AIDSetCell -------- 52
; PART 12B ------------------------- 80
;   Function a - AIDStartGame ------ 82
;   Function b - AIDMarkMove ------- 102
;   Function c - AIDShowGame ------- 130
;   Function d - AIDMakeMove ------- 144
;   Function e - AIDLegalMoveP ----- 159
;   Function f - AIDWinP ----------- 174
;   Function g - AIDWillWinP ------- 201
; HELPERS -------------------------- 228
;   Helper 1 --- AIDWillLoseP ------ 230
;   Helper 2 --- AIDSwitchMarker --- 257
;   Helper 3 --- AIDGetEmptyRow ---- 266
;   Helper 4 --- AIDCountStreak ---- 278
;   Helper 5 --- AIDGetWinningMove - 295
;   Helper 6 --- AIDGetLosingMove -- 307
;   Helper 7 --- AIDRandomMove ----- 319
;   Helper 8 --- AIDGetValidRandom - 330
; TESTERS -------------------------- 348
;   Tester ----- AIDPlayGame ------- 350
;   Initializers ------------------- 372

; PART 12A

; 12a - Function 1
; Returns the item at the given grid location in a list of lists.
(define (AIDGetCell Matrix Row Col)
  (if (or (null? Matrix) (> Row 7))
    ()
    (if (<= Row 1)
      (if (= Row 1)
        (AIDGetCell (car Matrix) (- Row 1) Col)
        (if (= Col 1)
          (car Matrix)
          (AIDGetCell (cdr Matrix) Row (- Col 1))
        )
      )
      (AIDGetCell (cdr Matrix) (- Row 1) Col)
    )
  )
)

; 12a - Function 2
; Returns a new matrix with the given grid location reset to the
; value of the given item.
(define (AIDSetCell Matrix Row Col Item)
  (if (null? Matrix)
    ()
    (if (<= Row 1)
      (if (= Row 1)
        (cons
          (AIDSetCell (car Matrix) (- Row 1) Col Item)
          (cdr Matrix)
        )
        (if (= Col 1)
          (cons Item (cdr Matrix))
          (cons
            (car Matrix)
            (AIDSetCell (cdr Matrix) Row (- Col 1) Item)
          )
        )
      )
      (cons
        (car Matrix)
        (AIDSetCell (cdr Matrix) (- Row 1) Col Item)
      )
    )
  )
)

; PART 12B

; 12b - Function a
; Initalizes the game grid
; Assumes "A" will go first
(define (AIDStartGame)
  (begin
    (set! AIDGame '("A"
                    ("-" "-" "-" "-" "-" "-" "-") ; Row 1, the bottom row
                    ("-" "-" "-" "-" "-" "-" "-") ; Row 2
                    ("-" "-" "-" "-" "-" "-" "-") ; Row 3
                    ("-" "-" "-" "-" "-" "-" "-") ; Row 4
                    ("-" "-" "-" "-" "-" "-" "-") ; Row 5
                    ("-" "-" "-" "-" "-" "-" "-") ; Row 6, the top row
                   ))
    (display "I predict this will be over in ")
    (display (+ (random 39) 4)) ; Random integer between 4 and 42
    (display " turns.\n")
    #t
  )
)

; 12b - Function b
; Returns the next move in a game and updates the grid
(define (AIDMarkMove Col)
  (begin
    (set! AIDGame
      (cons
        (AIDSwitchMarker) ; Next turn's player marker
        (AIDSetCell
          (cdr AIDGame) ; The game grid matrix
          (AIDGetEmptyRow 1 Col) ; A row of the game grid
          Col ; A column of the game grid
          (car AIDGame) ; The current player marker
        )
      )
    )
    (if (AIDWinP Col) ; Check if the move resulted in a win
      (begin
        (AIDShowGame)
        (display "Winner: ")
        (display (AIDSwitchMarker))
        (newline)
        (set! AIDGameState 0) ; Only used when testing
      )
    )
    Col
  )
)

; 12b - Function c
; Displays the current game grid
(define (AIDShowGame)
  (begin
    (display (car (cdr (cdr (cdr (cdr (cdr (cdr AIDGame)))))))) (newline);
    (display (car (cdr (cdr (cdr (cdr (cdr  AIDGame))))))) (newline);
    (display (car (cdr (cdr (cdr (cdr AIDGame)))))) (newline);
    (display (car (cdr (cdr (cdr AIDGame))))) (newline);
    (display (car (cdr (cdr AIDGame)))) (newline);
    (display (car (cdr AIDGame))) (newline);
    #t
  )
)

; Function d
; Returns the next move by the bot
; Checks for a winning move
; Checks for a losing move
; Otherwise places semi-randomly
(define (AIDMakeMove)
  (if (AIDGetWinningMove 1)
    (AIDMarkMove (AIDGetWinningMove 1))
    (if (AIDGetLosingMove 1)
      (AIDMarkMove (AIDGetLosingMove 1))
      (AIDMarkMove (AIDRandomMove))
    )
  )
)

; 12b - Function e
; Returns true if a move in the specified collumn is legal
(define (AIDLegalMoveP Col)
  (if (and
       (> Col 0)
       (and
         (< Col 8)
         (equal? (AIDGetCell (cdr AIDGame) 6 Col) "-")
       )
      )
    #t
    #f
  )
)

; 12b - Function f
; Returns true if the last move in the specified column resulted in a win
(define (AIDWinP Col)
  (if (or
        (>= (AIDCountStreak (- (AIDGetEmptyRow 1 Col) 1) Col 0 "vd" (AIDGetCell (cdr AIDGame) (- (AIDGetEmptyRow 1 Col) 1) Col)) 4) ; Check for vertical win
        (or
          (>= (+
                  (AIDCountStreak (- (AIDGetEmptyRow 1 Col) 1) (- Col 1) 0 "hl" (AIDGetCell (cdr AIDGame) (- (AIDGetEmptyRow 1 Col) 1) Col))
                  (AIDCountStreak (- (AIDGetEmptyRow 1 Col) 1) (+ Col 1) 1 "hr" (AIDGetCell (cdr AIDGame) (- (AIDGetEmptyRow 1 Col) 1) Col))
          ) 4) ; Check for horizontal win
          (or
            (>= (+
                  (AIDCountStreak (- (AIDGetEmptyRow 1 Col) 0) (+ Col 1) 0 "dur" (AIDGetCell (cdr AIDGame) (- (AIDGetEmptyRow 1 Col) 1) Col))
                  (AIDCountStreak (- (AIDGetEmptyRow 1 Col) 2) (- Col 1) 1 "dll" (AIDGetCell (cdr AIDGame) (- (AIDGetEmptyRow 1 Col) 1) Col))
            ) 4) ; Check for diagonal / win
            (>= (+
                  (AIDCountStreak (- (AIDGetEmptyRow 1 Col) 2) (+ Col 1) 0 "dlr" (AIDGetCell (cdr AIDGame) (- (AIDGetEmptyRow 1 Col) 1) Col))
                  (AIDCountStreak (- (AIDGetEmptyRow 1 Col) 0) (- Col 1) 1 "dul" (AIDGetCell (cdr AIDGame) (- (AIDGetEmptyRow 1 Col) 1) Col))
            ) 4) ; Check for diagonal \ win
          )
        )
      )
    #t
    #f
  )
)

; Function g
; Returns true if a move in the specified column will result in a win
(define (AIDWillWinP Col)
  (if (or
        (>= (AIDCountStreak (- (AIDGetEmptyRow 1 Col) 1) Col 1 "vd" (car AIDGame)) 4) ; Check for vertical win
        (or
          (>= (+
                  (AIDCountStreak (- (AIDGetEmptyRow 1 Col) 0) (- Col 1) 0 "hl" (car AIDGame))
                  (AIDCountStreak (- (AIDGetEmptyRow 1 Col) 0) (+ Col 1) 1 "hr" (car AIDGame))
          ) 4) ; Check for horizontal win
          (or
            (>= (+
                  (AIDCountStreak (+ (AIDGetEmptyRow 1 Col) 1) (+ Col 1) 0 "dur" (car AIDGame))
                  (AIDCountStreak (- (AIDGetEmptyRow 1 Col) 1) (- Col 1) 1 "dll" (car AIDGame))
            ) 4) ; Check for diagonal / win
            (>= (+
                  (AIDCountStreak (- (AIDGetEmptyRow 1 Col) 1) (+ Col 1) 0 "dlr" (car AIDGame))
                  (AIDCountStreak (+ (AIDGetEmptyRow 1 Col) 1) (- Col 1) 1 "dul" (car AIDGame))
            ) 4) ; Check for diagonal \ win
          )
        )
      )
    #t
    #f
  )
)

; HELPERS

; Helper 1
; Returns true if a move in the specified column will result in a loss
(define (AIDWillLoseP Col Turns)
  (if (or
        (>= (AIDCountStreak (- (AIDGetEmptyRow 1 Col) 1) Col 1 "vd" (AIDSwitchMarker)) 4) ; Check for vertical win
        (or
          (>= (+
                  (AIDCountStreak (+ (- (AIDGetEmptyRow 1 Col) 1) Turns) (- Col 1) 0 "hl" (AIDSwitchMarker))
                  (AIDCountStreak (+ (- (AIDGetEmptyRow 1 Col) 1) Turns) (+ Col 1) 1 "hr" (AIDSwitchMarker))
          ) 4) ; Check for horizontal win
          (or
            (>= (+
                  (AIDCountStreak (+ (- (AIDGetEmptyRow 1 Col) 0) Turns) (+ Col 1) 0 "dur" (AIDSwitchMarker))
                  (AIDCountStreak (+ (- (AIDGetEmptyRow 1 Col) 2) Turns) (- Col 1) 1 "dll" (AIDSwitchMarker))
            ) 4) ; Check for diagonal / win
            (>= (+
                  (AIDCountStreak (+ (- (AIDGetEmptyRow 1 Col) 2) Turns) (+ Col 1) 0 "dlr" (AIDSwitchMarker))
                  (AIDCountStreak (+ (- (AIDGetEmptyRow 1 Col) 0) Turns) (- Col 1) 1 "dul" (AIDSwitchMarker))
            ) 4) ; Check for diagonal \ win
          )
        )
      )
    #t
    #f
  )
)

; Helper 2
; Returns the opposing marker
(define (AIDSwitchMarker)
  (if (equal? (car AIDGame) "A")
    "V" ; Villain's marker
    "A" ; Aidan's marker (Though it doesn't actually matter which marker the bot uses)
  )
)

; Helper 3
; Returns the first empty row in a column
(define (AIDGetEmptyRow Row Col)
  (if (equal? (AIDGetCell (cdr AIDGame) Row Col) "-")
    Row
    (if (< Row 8)
      (AIDGetEmptyRow (+ Row 1) Col)
      7
    )
  )
)

; Helper 4
; Returns the count of markers in a row in a specified direction
(define (AIDCountStreak Row Col Count Direction Player)
  (if (equal? (AIDGetCell (cdr AIDGame) Row Col) Player)
    (case Direction
      [("vd") (AIDCountStreak (- Row 1) Col (+ Count 1) Direction Player)] ; Vertical down
      [("hl") (AIDCountStreak Row (- Col 1) (+ Count 1) Direction Player)] ; Horizontal left
      [("hr") (AIDCountStreak Row (+ Col 1) (+ Count 1) Direction Player)] ; Horizontal right
      [("dur") (AIDCountStreak (+ Row 1) (+ Col 1) (+ Count 1) Direction Player)] ; Diagonal upper right
      [("dlr") (AIDCountStreak (- Row 1) (+ Col 1) (+ Count 1) Direction Player)] ; Diagonal lower right
      [("dll") (AIDCountStreak (- Row 1) (- Col 1) (+ Count 1) Direction Player)] ; Diagonal lower left
      [("dul") (AIDCountStreak (+ Row 1) (- Col 1) (+ Count 1) Direction Player)] ; Diagonal upper left
    )
    Count
  )
)

; Helper 5
; Returns the column of a winning move, if it exists
(define (AIDGetWinningMove Col)
  (if (and (AIDLegalMoveP Col) (AIDWillWinP Col))
    Col
    (if (< Col 8)
      (AIDGetWinningMove (+ Col 1))
      #f
    )
  )
)

; Helper 6
; Returns the column of a losing move, if it exists
(define (AIDGetLosingMove Col)
  (if (and (AIDLegalMoveP Col) (AIDWillLoseP Col 1))
    Col
    (if (< Col 8)
      (AIDGetLosingMove (+ Col 1))
      #f
    )
  )
)

; Helper 7
; Returns a random column using the following strategy:
; Prioritizes playing in the middle three columns
; Otherwise, plays in a random column
(define (AIDRandomMove)
  (if (and (AIDLegalMoveP 3) (and (AIDLegalMoveP 4) (AIDLegalMoveP 5)))
    (AIDGetValidRandom 0 3 3 0) ; Random integer between 3 and 5
    (AIDGetValidRandom 0 1 7 0) ; Random integer between 1 and 7
  )
)

; Helper 8
; Returns the a random column in the specified range
; Avoids illegal moves
; Avoids playing into a losing position when possible
; Ends in the case of a draw
(define (AIDGetValidRandom Col Min Range Count)
  (if (AIDLegalMoveP Col)
    (if (and (AIDWillLoseP Col 2) (< Count 100))
      (AIDGetValidRandom 0 1 7 (+ Count 1)) ; Column is not safe
      Col ; Marker will be placed here
    )
    (if (< Count 200)
      (AIDGetValidRandom (+ (random Range) Min) Min Range (+ Count 1)) ; Column is not legal
      (exit (display "It's a draw! Exiting program.")) ; Ends infinite loop in the case of a full grid
    )
  )
)

; TESTERS

; Tester
; The below function is used to run test games between the bot and the user
; It is not used in any of the above functions
; It is only used when explicitly called by the user
(define (AIDPlayGame)
  (begin
    (display "Turn: ") (display (car AIDGame)) (newline)
    (if (equal? (car AIDGame) "A")
      (AIDMakeMove)
      ;(AIDMakeMove)
      (AIDMarkMove (read))
      ;(AIDMarkMove (+ (random 7) 1))
    )
    (if (= AIDGameState 1) ; Determined by (Set! AIDGameState 0) on line 123
      (begin
        (AIDShowGame)
        (AIDPlayGame)
      )
    )
  )
)

; Initializers
; Used to set up a test game
(define AIDGame 0)
(define AIDGameState 1)
(AIDStartGame)
(AIDPlayGame)
