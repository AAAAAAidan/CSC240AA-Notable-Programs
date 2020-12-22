% Aidan Zamboni
% Program 13
% The player starts at the door to their house.
% The player is hungry and must find something to eat.
% After they eat enough, they must find somewhere to sleep. 
% They can either enter the house or pick up leaves.
% After entering the house, they can pick leaves,
% move forward, or move back. If they move forward,
% they enter the dining hall. In the dining hall, they
% have the same options as the last room. If they move
% forward again, they reach the dining table, where they
% have the option to go back or either eat leaves or cry,
% depending on whether or not they have any leaves to
% eat. After the player eats at least five leaves, they
% become full and can go back to the entrance to find a
% new option to sleep in a pile of leaves for the night.
% If they do this, they get the good ending. The bad
% ending occurs if the player eats more than 10 leaves,
% causing them to get sick. The overall flow may be
% more easily understood through visualization in the
% included graph.

% CSC240 - Sample 'Quest' using knowledge base
% assign the state that will start the program

start_state(entrance).

% define the edges of the finite state diagram

% if the player is full
next_state(entrance,a,good_ending) :-
	stored_answer(leaves_eaten,AmountEaten),
	AmountEaten > 4.
% else the player is still hungry
next_state(entrance,a,entrance).
next_state(entrance,b,hallway).

next_state(hallway,a,hallway).
next_state(hallway,b,dining_hall).
next_state(hallway,c,entrance).

next_state(dining_hall,a,dining_hall).
next_state(dining_hall,b,dining_table).
next_state(dining_hall,c,hallway).

% if the player eats too many leaves
next_state(dining_table,a,bad_ending) :-
	stored_answer(leaves_eaten,AmountEaten),
	stored_answer(leaves_onhand,AmountOnHand),
	NewAmount is AmountEaten + AmountOnHand,
	NewAmount > 10.
% else the player is still okay
next_state(dining_table,a,dining_table).
next_state(dining_table,b,dining_hall).

% code to be executed at the beginning

display_intro :-
	write('Time for dinner!'),nl,
	write('You just got back from a long day of work,'),
	write(' now it is time to find something to eat!'),nl,nl.

initialize :-
	asserta(stored_answer(leaves_found,0)),
	asserta(stored_answer(leaves_onhand,0)),
	asserta(stored_answer(leaves_eaten,0)),
	asserta(stored_answer(have_leaves,no)).

% code to be executed at the end

goodbye :-
	nl,
	stored_answer(leaves_found,Amount),
	write( 'You found ' ),
	write( Amount ),
	write( ' exquisite leaves!' ),nl,
	stored_answer(leaves_eaten,NextAmount),
	write( 'You ate ' ),
	write( NextAmount ),
	write( ' nutritious leaves!' ),nl,
	stored_answer(leaves_onhand,LastAmount),
	write( 'You have ' ),
	write( LastAmount ),
	write( ' beautiful leaves on hand!'), nl.

% code to be executed upon reaching each state

% if the player is hungry
show_state(entrance) :-
	stored_answer(leaves_eaten,AmountEaten),
	AmountEaten < 5,
	write( 'You are on the front porch.' ),nl,
	write( 'Because it is fall and you have neglected to' ),
	write( ' do any yard work, the porch is covered' ),
	write( ' with piles of leaves.' ),nl,
	write( 'What do you want to do?'), nl,
	write( '(a) Pick up some leaves!'),nl,
	write( '(b) Go inside!'),nl,
	write( '(q) Quit the program!'),nl.

% else if the player is full
show_state(entrance) :-
	stored_answer(leaves_eaten,AmountEaten),
	AmountEaten > 4,
	write( 'You are on the front porch.' ),nl,
	write( 'Because it is fall and you have neglected to' ),
	write( ' do any yard work, the porch is covered' ),
	write( ' with piles of leaves.' ),nl,
	write( 'What do you want to do?'), nl,
	write( '(a) Sleep in a pile of leaves!'),nl,
	write( '(b) Go inside!'),nl,
	write( '(q) Quit the program!'),nl.

show_state(hallway) :-
	write( 'You are in the hallway.'),nl,
	write( 'The roof of the house is filled with holes.' ),
	write( ' Because of this, the otherwise empty' ),
	write( ' hallway is littered with leaves.' ),nl,
	write( 'What do you want to do?'), nl,
	write( '(a) Pick up some more leaves!'),nl,
	write( '(b) Go down the hallway!'),nl,
	write( '(c) Go back outside!'),nl,
	write( '(q) Quit the program!'),nl.

show_state(dining_hall) :-
	write( 'You are in the dining hall.' ),nl,
	write( 'There is nothing here but a cardboard box' ),
	write( ' acting as a table, a plastic lawn chair, and' ),
	write( ' some more leaves on the floor.' ),nl,
	write( 'What do you want to do?'), nl,
	write( '(a) Pick up even more leaves!'),nl,
	write( '(b) Sit down at the table!'),nl,
	write( '(c) Go back into the hallway!'),nl,
	write( '(q) Quit the program!'),nl.

% if the player has leaves
show_state(dining_table) :-
	stored_answer(have_leaves,yes),
	write( 'You are sitting at the dining table.' ),nl,
	write( 'It is time to feast!' ),nl,
	write( 'What do you want to do?'),nl,
	write( '(a) Eat some leaves!'),nl,
	write( '(b) Stand back up!'),nl,
	write( '(q) Quit the program!'),nl.

% else if the player does not have leaves
show_state(dining_table) :-
	stored_answer(have_leaves,no),
	write( 'You are sitting at the dining table.' ),nl,
	write( 'Unfortunately, there is nothing to eat.' ),nl,
	write( 'What do you want to do?'),nl,
	write( '(a) Cry.'),nl,
	write( '(b) Stand back up!'),nl,
	write( '(q) Quit the program!'),nl.

% final states do not display a menu - they automatically quit ('q') 

show_state(bad_ending) :-
	write( 'Unfortunately, you got sick from eating too many leaves!' ),nl,
	write( 'Goodbye!' ),nl.

show_state(good_ending) :-
	write( 'You found a nice pile of leaves to sleep in!' ),nl,
	write( 'Goodnight!' ),nl.

get_choice(bad_ending,q).
get_choice(good_ending,q).

% code to be executed for each choice of action from each state

% if the player is hungry
show_transition(entrance,a) :-
	stored_answer(leaves_eaten,AmountEaten),
	AmountEaten < 5,
	write( 'You picked up a leaf! Amazing!' ),nl,
	stored_answer(leaves_found,AmountFound),
	retract(stored_answer(leaves_found,_)),
	NewAmountFound is AmountFound + 1,
	asserta(stored_answer(leaves_found,NewAmountFound)),
	stored_answer(leaves_onhand,AmountOnHand),
	retract(stored_answer(leaves_onhand,_)),
	NewAmountOnHand is AmountOnHand+ 1,
	asserta(stored_answer(leaves_onhand,NewAmountOnHand)),
	retract(stored_answer(have_leaves,_)),
	asserta(stored_answer(have_leaves,yes)).

% else the player is full
show_transition(entrance,a).

show_transition(entrance,b) :-
	write( 'Walking into the house...' ),nl.

show_transition(hallway,a) :-
	write( 'You picked up a leaf! Incredible!' ),nl,
	stored_answer(leaves_found,AmountFound),
	retract(stored_answer(leaves_found,_)),
	NewAmountFound is AmountFound + 1,
	asserta(stored_answer(leaves_found,NewAmountFound)),
	stored_answer(leaves_onhand,AmountOnHand),
	retract(stored_answer(leaves_onhand,_)),
	NewAmountOnHand is AmountOnHand+ 1,
	asserta(stored_answer(leaves_onhand,NewAmountOnHand)),
	retract(stored_answer(have_leaves,_)),
	asserta(stored_answer(have_leaves,yes)).

show_transition(hallway,b) :-
	write( 'Walking into the next room...' ),nl.

show_transition(hallway,c) :-
	write( 'Walking back outside...' ),nl.

show_transition(dining_hall,a) :-
	write( 'You picked up a leaf! Splendid!' ),nl,
	stored_answer(leaves_found,AmountFound),
	retract(stored_answer(leaves_found,_)),
	NewAmountFound is AmountFound + 1,
	asserta(stored_answer(leaves_found,NewAmountFound)),
	stored_answer(leaves_onhand,AmountOnHand),
	retract(stored_answer(leaves_onhand,_)),
	NewAmountOnHand is AmountOnHand+ 1,
	asserta(stored_answer(leaves_onhand,NewAmountOnHand)),
	retract(stored_answer(have_leaves,_)),
	asserta(stored_answer(have_leaves,yes)).

show_transition(dining_hall,b) :-
	write( 'Walking to the table...' ),nl.

show_transition(dining_hall,c) :-
	write( 'Walking into the dining hall...' ),nl.

% if the player has leaves and becomes full
show_transition(dining_table,a) :-
	stored_answer(have_leaves,yes),
	stored_answer(leaves_eaten,AmountEaten),
	stored_answer(leaves_onhand,AmountOnHand),
	NewAmount is AmountEaten + AmountOnHand,
	NewAmount > 4,
	retract(stored_answer(leaves_eaten,_)),
	asserta(stored_answer(leaves_eaten,NewAmount)),
	retract(stored_answer(leaves_onhand,_)),
	asserta(stored_answer(leaves_onhand,0)),
	retract(stored_answer(have_leaves,_)),
	asserta(stored_answer(have_leaves,no)),
	write( 'You ate the leaves! Tasty!' ),nl,
	write( 'Your stomach is full now, time to find a place to rest!' ),nl.

% else if the player has leaves and is still hungry
show_transition(dining_table,a) :-
	stored_answer(have_leaves,yes),
	stored_answer(leaves_eaten,AmountEaten),
	stored_answer(leaves_onhand,AmountOnHand),
	NewAmount is AmountEaten + AmountOnHand,
	retract(stored_answer(leaves_eaten,_)),
	asserta(stored_answer(leaves_eaten,NewAmount)),
	retract(stored_answer(leaves_onhand,_)),
	asserta(stored_answer(leaves_onhand,0)),
	retract(stored_answer(have_leaves,_)),
	asserta(stored_answer(have_leaves,no)),
	write( 'You ate the leaves! Tasty!' ),nl,
	write( 'However, your stomach still yearns for more!' ),nl.

% else if the player does not have leaves
show_transition(dining_table,a) :-
	stored_answer(have_leaves,no),
	write( 'You start to sob uncontrollably!' ),nl.

show_transition(dining_table,b) :-
	write( 'Standing back up...' ),nl.

show_transition(entrance,fail) :-
	write( 'Enter a, b, c, or q.' ),nl.

show_transition(hallway,fail) :-
	write( 'Enter a, b, c, or q.' ),nl.

show_transition(dining_hall,fail) :-
	write( 'Enter a, b, c, or q.' ),nl.

show_transition(dining_table,fail) :-
	write( 'Enter a, b, or q.' ),nl.

% basic finite state machine engine

go :-
	intro,
	start_state(X),
	show_state(X),
	get_choice(X,Y),
	go_to_next_state(X,Y).

intro :-
	display_intro,
	clear_stored_answers,
	initialize.

go_to_next_state(_,q) :-
	goodbye,!.

go_to_next_state(S1,Cin) :-
	next_state(S1,Cin,S2),nl,
	show_transition(S1,Cin),nl,
	show_state(S2),
	get_choice(S2,Cnew),
	go_to_next_state(S2,Cnew).

go_to_next_state(S1,Cin) :-
	\+ next_state(S1,Cin,_),nl,
	show_transition(S1,fail),nl,
	get_choice(S1,Cnew),
	go_to_next_state(S1,Cnew).

get_choice(_,C) :-
	write('Enter a letter followed by a period.'),nl,
	read(C).

% case knowledge base - user responses

:- dynamic(stored_answer/2).

% procedure to get rid of previous responses
% without abolishing the dynamic declaration

clear_stored_answers :- retract(stored_answer(_,_)),fail.
clear_stored_answers.

% I’m not why I chose to revolve my story around leaves,
% but it works.
