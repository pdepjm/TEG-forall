continente(americaDelSur).
continente(americaDelNorte).
continente(asia).
continente(oceania).

estaEn(americaDelSur, argentina).
estaEn(americaDelSur, brasil).
estaEn(americaDelSur, chile).
estaEn(americaDelSur, uruguay).
estaEn(americaDelNorte, alaska).
estaEn(americaDelNorte, yukon).
estaEn(americaDelNorte, canada).
estaEn(americaDelNorte, oregon).
estaEn(asia, kamtchatka).
estaEn(asia, china).
estaEn(asia, siberia).
estaEn(asia, japon).
estaEn(oceania,australia).
estaEn(oceania,sumatra).
estaEn(oceania,java).
estaEn(oceania,borneo).

jugador(amarillo).
jugador(magenta).
jugador(negro).
jugador(blanco).

aliados(X,Y):- alianza(X,Y).
aliados(X,Y):- alianza(Y,X).
alianza(amarillo,magenta).

%el numero son los ejercitos
ocupa(argentina, magenta, 5).
ocupa(chile, negro, 3).
ocupa(brasil, amarillo, 8).
ocupa(uruguay, magenta, 5).
ocupa(alaska, amarillo, 7).
ocupa(yukon, amarillo, 1).
ocupa(canada, amarillo, 10).
ocupa(oregon, amarillo, 5).
ocupa(kamtchatka, negro, 6).
ocupa(china, amarillo, 2).
ocupa(siberia, amarillo, 5).
ocupa(japon, amarillo, 7).
ocupa(australia, negro, 8).
ocupa(sumatra, negro, 3).
ocupa(java, negro, 4).
ocupa(borneo, negro, 1).

% Usar este para saber si son limitrofes ya que es una relacion simetrica
sonLimitrofes(X, Y) :- limitrofes(X, Y).
sonLimitrofes(X, Y) :- limitrofes(Y, X).

limitrofes(argentina,brasil).
limitrofes(argentina,chile).
limitrofes(argentina,uruguay).
limitrofes(uruguay,brasil).
limitrofes(alaska,kamtchatka).
limitrofes(alaska,yukon).
limitrofes(canada,yukon).
limitrofes(alaska,oregon).
limitrofes(canada,oregon).
limitrofes(siberia,kamtchatka).
limitrofes(siberia,china).
limitrofes(china,kamtchatka).
limitrofes(japon,china).
limitrofes(japon,kamtchatka).
limitrofes(australia,sumatra).
limitrofes(australia,java).
limitrofes(australia,borneo).
limitrofes(australia,chile).

%puedenAtacarse/2 que relaciona dos jugadores si ocupan al menos un par de países que son limítrofes.
puedenAtacarse(Jugador1, Jugador2):-
  ocupa(Pais1,Jugador1,_),
  ocupa(Pais2,Jugador2,_),
  Jugador1 \= Jugador2,
  sonLimitrofes(Pais1, Pais2).

%estaTodoBien/2 que relaciona dos jugadores que, o bien no pueden atacarse, o son aliados.
estaTodoBien(Jugador1,Jugador2):-
  jugador(Jugador1),
  jugador(Jugador2),
  not(puedenAtacarse(Jugador1,Jugador2)).
estaTodoBien(Jugador1,Jugador2):-
  aliados(Jugador1,Jugador2).

%loLiquidaron/1 que se cumple para un jugador si no ocupa ningún país.
loLiquidaron(Jugador):-
  jugador(Jugador),
  not(ocupa(_,Jugador,_)).

%ocupaContinente/2 que relaciona un jugador y un continente si el jugador ocupa todos los países del mismo.
ocupaContinente(Jugador,Continente):-
  jugador(Jugador),
  continente(Continente),
  forall(estaEn(Continente,Pais), ocupa(Pais,Jugador,_)).

%estaPeleado/1 que se cumple para los continentes en los cuales cada jugador ocupa algún país.
estaPeleado(Continente):-
  continente(Continente),
  forall(jugador(Jugador),ocupaUnPaisEn(Jugador,Continente)).

ocupaUnPaisEn(Jugador,Continente):-
  ocupa(Pais,Jugador,_),
  estaEn(Continente,Pais).

%seAtrinchero/1 que se cumple para los jugadores que ocupan países en un único continente.
seAtrinchero(Jugador):-
  ocupaUnPaisEn(Jugador,UnContinente),
  forall(ocupaUnPaisEn(Jugador,Continente), UnContinente = Continente).

%puedeConquistar/2 que relaciona un jugador y un continente si no ocupa dicho continente, pero todos los países del mismo que no tiene son limítrofes a alguno que ocupa y a su vez ese país no es de un aliado.
puedeConquistar(Jugador,Continente):-
  jugador(Jugador),
  continente(Continente),
  not(ocupaContinente(Jugador,Continente)),
  forall(
    paisQueFaltaEn(Pais,Jugador,Continente),
    puedeAtacar(Pais, Jugador)).

paisQueFaltaEn(Pais,Jugador,Continente):-
  estaEn(Continente,Pais),
  not(ocupa(Pais,Jugador,_)).
  
puedeAtacar(Pais,Jugador):-
  ocupa(OtroPais, Jugador,_),
  sonLimitrofes(Pais,OtroPais), 
  ocupa(Pais, Jugador2,_),
  not(aliados(Jugador2,Jugador)).

%elQueTieneMasEjercitos/2 que relaciona un jugador y un país si se cumple que es en ese país que hay más ejércitos que en los países del resto del mundo y a su vez ese país es ocupado por ese jugador.
elQueTieneMasEjercitos(Jugador,Pais):-
  ocupa(Pais,Jugador,CantMayor),
  forall(ocupa(_,_,Cant),CantMayor >= Cant).

% juntan/3 que relaciona dos países y una cantidad, cuando la cantidad representa la suma de los ejércitos en ambos países.
juntan(PaisA, PaisB, Suma):-
  ocupa(PaisA,_,CantA),
  ocupa(PaisB,_,CantB),
  Suma is CantA + CantB.

% seguroGanaContra/2 que relaciona dos países limítrofes de diferentes jugadores y es cierto cuando el primero tiene más del doble de ejércitos que el segundo.
seguroGanaContra(PaisA, PaisB):-
  ocupa(PaisA,_,CantA),
  ocupa(PaisB,_,CantB),
  CantA > 2 * CantB.
% Para no repetir código con el que sigue:
% seguroGanaContra(PaisA, PaisB):-
%     cuantoAgregaParaGanarSeguro(PaisA,PaisB,0).

% cuantoAgregaParaGanarSeguro/3 que relaciona dos países limítrofes de diferentes jugadores y una cantidad, y es cierto cuando esa cantidad es la cantidad de ejércitos que tengo que ponerle al primer país para que le gane seguro al segundo. ¡No repetir lógica!
cuantoAgregaParaGanarSeguro(PaisA, PaisB, Agrega):-
  ocupa(PaisA,_,CantA),
  ocupa(PaisB,_,CantB),
  Agrega is 2 * CantB - CantA.

% Saber si un jugador gana:
gano(Jugador):-
  objetivo(Jugador, Objetivo),
  cumple(Objetivo,Jugador).

cumple(ocuparContinente(Continente),Jugador):-
  ocupaContinente(Jugador,Continente).

cumple(ocuparPaises(CantParaGanar,Continente), Jugador):-
  cuantosPaisesOcupaEn(Jugador,Continente,CantOcupa),
  CantParaGanar =< CantOcupa.

cumple(destruirJugador(Enemigo),_):-
  loLiquidaron(Enemigo).

  % Agregados para presentar functores
objetivo(amarillo, ocuparContinente(asia)).
objetivo(amarillo,ocuparPaises(2, americaDelSur)). 
objetivo(rojo, destruirJugador(negro)). 
objetivo(magenta, destruirJugador(rojo)). 
objetivo(negro, ocuparContinente(oceania)).
objetivo(negro,ocuparContinente(americaDelSur)). 

% Agregados para presentar functores
cuantosPaisesOcupaEn(amarillo, americaDelSur, 1).
cuantosPaisesOcupaEn(amarillo, americaDelNorte, 4).
cuantosPaisesOcupaEn(amarillo, asia, 3).
cuantosPaisesOcupaEn(amarillo, oceania, 0).
cuantosPaisesOcupaEn(magenta, americaDelSur, 2).
cuantosPaisesOcupaEn(magenta, americaDelNorte, 0).
cuantosPaisesOcupaEn(magenta, asia, 0).
cuantosPaisesOcupaEn(magenta, oceania, 0).
cuantosPaisesOcupaEn(negro, americaDelSur, 1).
cuantosPaisesOcupaEn(negro, americaDelNorte, 0).
cuantosPaisesOcupaEn(negro, asia, 1).
cuantosPaisesOcupaEn(negro, oceania, 4).