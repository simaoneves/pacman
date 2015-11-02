%%%%%%%%%%%%
% Comportamento  Pacman 1001
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% se puder ir emfrente avanca
pacman1001(_,_,_,(_,X,Y,Dec,_),_,_,_,_,Free,_,_,_,_,Dec) :-
	viz(Dec,(X,Y),Viz),
	member(Viz,Free).

% senao tenta ir para uma orientacao ao acaso, preferencialmente
% que nao seja pela inversa da actual, procurando novo corredor
pacman1001(_,_,_,(_,X,Y,Dir,_),_,_,_,_,Free,_,_,_,_,Dec) :-
	findall(D,(viz(D,(X,Y),Viz),member(Viz,Free)),L),
	dirAcasoPrefNaoVoltarAtras(L,Dir,Dec).

% se orientacao inversa for a unica
dirAcasoPrefNaoVoltarAtras([Dec],_,Dec).

% senao escolha uma ao acaso diferente da inversa da actual
% O predicao builtin select/3 selecciona um elemento de uma
% lista, devolvendo tambem a lista sem o elemento seleccionado.
dirAcasoPrefNaoVoltarAtras(Possiveis,D,Dec) :-
	inverte(D,Inv),
	select(Inv,Possiveis,L),
	random_member(Dec,L).

% casa vizinha a norte
viz(0,(X,Y),(X,NY)) :-
	NY is Y + 1.

% casa vizinha a sul
viz(180,(X,Y),(X,NY)) :-
	NY is Y - 1.

% casa vizinha a leste
viz(90,(X,Y),(NX,Y)) :-
	NX is X + 1.

% casa vizinha a oeste
viz(270,(X,Y),(NX,Y)) :-
	NX is X - 1.

% as orientacoes inversas

%  a inversa de leste eh oeste 
inverte(90,270).

% a inversa de norte eh sul
inverte(0,180).

% a inversa de sul eh norte
inverte(180,0).

% a inversa de oeste eh leste
inverte(270,90).