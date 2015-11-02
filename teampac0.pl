
%%%%%%%%%%%%
% Comportamento ZigZag Pacman
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
:- use_module(library(lists)).


%pacman(Clock, ClockLimit, Score, Me, Partner, OtherTeam, HomeBase , HisBase, FreeCells, MyP, MYSupP, HisP, HisSupP, Decisao) :-

pacman0(_,_,_,(_,X,Y,_,_),_,_,_,_,Free,_,_,_,_,Dec) :-
	findall(D,(viz(D,(X,Y),Viz),member(Viz,Free)),L),
	random_member(Dec,L).


viz(0,(X,Y),(X,NY)) :-
	NY is Y + 1.
viz(180,(X,Y),(X,NY)) :-
	NY is Y - 1.
viz(90,(X,Y),(NX,Y)) :-
	NX is X + 1.
viz(270,(X,Y),(NX,Y)) :-
	NX is X - 1.


