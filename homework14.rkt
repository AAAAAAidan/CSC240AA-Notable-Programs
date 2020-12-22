; Aidan Zamboni
; Homework 14

; Prints a pyramid of a given character for
; a given amount of lines.
( define ( printPyramid Char Count )
   ( buildPyramid Char Count 0 )
)

; Uses seperate counters to track how many
; spaces and pyramid characters to print.
( define ( buildPyramid Char CharCount SpaceCount )
   ( if ( = CharCount 0 )
        ( void )
        ( begin
           ( buildPyramid Char ( - CharCount 1 ) ( + SpaceCount 1 ) )
           ( printChars " " SpaceCount )
           ( printChars Char ( - ( * CharCount 2 ) 1 ) )
           ( newline )
        )
   )
)

; Prints a character a specified amount of times.
( define ( printChars Char Count )
   ( if ( = Count 0)
        ( void )
        ( begin
           ( display Char )
           ( printChars Char ( - Count  1 ) )
        )
   )
)

( printPyramid "A" 42 )
