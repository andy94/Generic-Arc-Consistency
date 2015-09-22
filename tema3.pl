%% Paradigme de Programre 2015
%% Tema 3 / Prolog / CSP
%% Ursache Andrei - 322CA - 26 mai 2015

%% Auxiliare -------------------------------------------------------------------

% 1 - pe cine, 2 - cu ce, 3 unde, 4 rez.
replace(_, _, [], []).
replace(O, R, [O|T], [R|T2]) :- replace(O, R, T, T2).
replace(O, R, [H|T], [H|T2]) :- H \= O, replace(O, R, T, T2),!.

%% Inlocuieste o valoare dintr-o lista la un index dat:
%% 1 - lista, 2 - pozitia , 3 - cu ce, 4 - rezultat
replaceByIndex([_|T], 0, X, [X|T]).
replaceByIndex([H|T], I, X, [H|R]):- I > -1, NI is I-1, 
									 replaceByIndex(T, NI, X, R), !.
replaceByIndex(L, _, _, L).

%% Sterge un element dintr-o lista la o pozitie data:
%% 1 - lista, 2 - pozitia , 3 - rezultat
away([G|H],0,H):-!.
away([G|H],N,[G|L]):- N > 0, Nn is N-1 ,!,away(H,Nn,L).

%% Gaseste un element simbolic:
findIndex(Poz,List,Val):- findIndex1(Poz,List,Val, 0),!.
findIndex1(Poz,[],Val, _) :- Poz is -1,!.
findIndex1(Poz,[H|T],Val, Start):- H \== Val , Start1 is Start + 1 ,findIndex1(Poz,T,Val,Start1),!.
findIndex1(Poz,[H|T],Val, Start):- H == Val,Poz is Start,!.

%% Creeaza toate combinatiile posibile folosind un element din fiecare domeniu
%% Din lista de liste -> toate posibilitatile
lists([], []).
lists([[Head|_]|Lists], [Head|L]):-
  lists(Lists, L).
lists([[_,Head|Tail]|Lists], L):-
  lists([[Head|Tail]|Lists], L).

%% GAC -------------------------------------------------------------------------
%% Cazul de baza, nu sunt hyperarce:
gac3(Vars, Domains, Constraints, [], RevisedDomains) :- 
	RevisedDomains = Domains.
	
%% Pentru fiecare hyperarc in parte
gac3(Vars, Domains, Constraints, [hyperarc(X,OthX,CX)|T], RevisedDomains) :-
		findIndex(Poz_X,Vars,X),
		nth0(Poz_X,Domains,Dx),
		%% Dx este domeniul variabilei X
		revise(Vars,X,Dx,Domains,OthX,CX,Modified, DxStar),
		
		%% Daca au avut loc modificari in domeniu
		( (Modified == true) -> (replaceByIndex(Domains,Poz_X,DxStar,RevisedDomains1),!,
			%% Se inlocuieste domeniul cu cel nou (mai mic)
			%% Se extrag constrangerile ce il contin pe X:
			setof(	constraint(ListOfConstrVars, Expression), 
					Poz^( member(constraint(ListOfConstrVars, Expression),Constraints), 
						findIndex(Poz,ListOfConstrVars,X),Poz =\= -1, Expression \==  CX ),  
					Const_With_X ), %% Const_With_X sunt doar constrangerile care il au pe X
									%% si au expresia diferita de cea pentru care am verificat.
			
			%% Se creeaza noile hyperarce:
			setof( 	hyperarc(Var,Ovar,Exp) ,
					List^Poz1^(  member(constraint(List,Exp),Const_With_X), member(Var,List), 
						Var \== X, findIndex(Poz1, List, Var), away(List,Poz1,Ovar) ),
					NewHyp), % NewHyp are noile hiperarce de adaugat
					
			append(T,NewHyp,NewH),
			
			%% Se apeleaza recursiv pentru noile hyperarce
			gac3(Vars,RevisedDomains1,Constraints,NewH,RevisedDomains))
			;
			%% Daca nu au avut loc modificari:
			(gac3(Vars,Domains,Constraints,T,RevisedDomains))).

%% Verifica daca o constragere este satisfiabila pentru valoarea Val a variabielei X			
isSat(Vars,X,Vx,D,LOfVar,Const):-
	X = Vx,
	findall( Dxi ,  ( member(Xi,LOfVar),findIndex(Poz_Xi,Vars,Xi),nth0(Poz_Xi,D,Dxi) )   , Dis ),
	lists(Dis, Pos),
	LOfVar = Pos,
	Const,!.

%% Restrage domeniul variabilei X:
revise(Vars,X,Dx,D,LOfVar,Const,Modified, DxStar) :-
	findall( Vx,( member(Vx,Dx), isSat(Vars,X,Vx,D,LOfVar,Const) ), DxStar),
	length(DxStar,Ldxs), length(Dx,Ldx), ((Ldxs == Ldx, Modified = false, !) ; (Modified = true, !)).

%% Auxiliare -------------------------------------------------------------------
	
%% Verifica daca in lista de liste se afla vreo lista cu un elements
check([]).
check([[_]|T]) :-  check(T).

%% Verifica daca in lista se afla vreo variabila neinstantiata
%% True daca gaseste.
checkVar([]).
checkVar([H|T]) :- \+ var(H), checkVar(T).

listsplit([H|T], H, T).

%% MAC -------------------------------------------------------------------------
solve_csp(Vars, Domains, Constraints,Solution):-
	%% Se verifica arc consistenta la inceput:
	setof( 	hyperarc(Var,Ovar,Exp) ,
			List^Poz1^(  member(constraint(List,Exp),Constraints), member(Var,List), 
				findIndex(Poz1, List, Var), away(List,Poz1,Ovar) ),
			Hyp), % NewHyp are noile hiperarce de adaugat
	
	gac3(Vars, Domains, Constraints, Hyp, NewDomains),
	listsplit(Vars,Varr,_),
	
	%% Se incepe recursivitatea de la prima variabila:
	rec(Varr,Vars,NewDomains,Constraints,Solution).

	
%% Recursiv:
rec(Var,Vars,Domains,Constraints,Solution) :-
	
	findIndex(Poz,Vars,Var),
	nth0(Poz,Domains,Dvar),
	
	%% Verifica daca e inca neinstantiata
	var(Var),
	
	%% Extrage constrangerile in care este implicata:
	setof(	constraint(ListOfConstrVars, Expression), 
			Poz3^( member(constraint(ListOfConstrVars, Expression),Constraints), 
				findIndex(Poz3,ListOfConstrVars,Var),Poz3 =\= -1),  
			Const_With_Var ), % Const_With_Var sunt doar constrangerile care il au pe Var.
	
	%% Creeaza noile hyperarce corespunzatoare
	setof( 	hyperarc(Var2,Ovar2,Exp2) ,
			List2^Poz2^(  member(constraint(List2,Exp2),Const_With_Var), 
				member(Var2,List2), Var2 \== Var , findIndex(Poz2, List2, Var2), away(List2,Poz2,Ovar2) ),
			Hyp2), % NewHyp are noile hiperarce de adaugat
	
	%% Pentru fiecare valoare posibila in parte:
	member(Val,Dvar),
	
	%% Se atribie valoarea:
	once(replaceByIndex(Domains,Poz,[Val],ND)),
	Var = Val,

	%% Se verifica arc consistenta
	once(gac3(Vars, ND, Constraints , Hyp2, NewDomains)),

	%% Daca nu sunt domenii vide
	findIndex(Pozz,NewDomains,[]), Pozz == -1,
	
	%% Daca toate variabilele sunt instantiate:
	(  (once(checkVar(Vars))) ->  once(lists(NewDomains, Solution)) ; 
		
		%% Altfel, apel recursiv:
		( 	member(Varr,Vars), (var(Varr), findIndex(Pozr,Vars,Varr), Pozr > Poz, 
				nth0(Pozr,NewDomains,Dvarr), Dvarr \== [], ! ) -> 
			rec(Varr,Vars,NewDomains,Constraints,Solution) ; false
		)
	).
	
%% einstein/4
einstein(_, _, _, _).