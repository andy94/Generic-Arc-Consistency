    Ursache Andrei - 322CA - 26 mai 2015
	----------------------------------------------------------------------------
	Proiect anul 2, semestrul al doilea, Paradigme de programare
	Limbaj ales: Prolog
	
	############################     ATENTIE !!!    ############################
	Temele sunt verificate pe VMChecker. Nu incercati sa copiati codul, deoarece
	VMChecker verifica si sursele existente pe GitHub. In plus, fiecare tema va 
	ajuta foarte mult daca incercati sa o realizati singuri. Asa ca, daca ai
	ajuns aici pentru a cauta o tema, iti recomand calduros sa inchizi tab-ul cu 
	GitHub si sa te apuci singur de ea. Spor!
	----------------------------------------------------------------------------

    
    Ideea generala si implementare:
	
		In realizarea temei am utilizat algoritmii pusi la dispozitie in enuntul
	temei precum si diverse documentatii (http://www.swi-prolog.org/ sau 
	http://www.learnprolognow.org/) pentru anumite functii predefinite sau pur
	si simplu pentru informare.
	
		Algoritmul GAC3 primeste ca input o lista de variabile (de exemplu [X,
	Y,...]), domeniile de valori pentru fiecare variabila, 
	constrangerile si hyperarcele. Avand in vedere aceasta definire "abstracta"
	a variabilelor, prima problema de care m-am lovit a fost cautarea unei 
	variabile in lista de variabile (pentru aflarea indexului si determinarea 
	domeniului de valori). Daca as fi aplicat direct functia nth0 as fi obtinut
	toate pozitiile din lista valide (deoarece, fiind vorba de variabile, 
	acestea pot lua orice valoare). In acest sens, am creeat o functie speciala
	care compara un element dintro lista simbolic pentru a obtine rezultatul 
	asteptat.
		Am creat o functie revise care se aplica pentru o variabila si o 
	constrangere. Aceasta functie limiteaza domeniul de valori a variabilei 
	astfel incat constrangerea sa poate fi satisfacuta (sa existe valori 
	corecte si pentru celelalte variabile) in toate cazurile.
		Cu ajutorul acestei functii, in algoritmul GAC3 se limiteaza (daca
	este cazul) domeniul variabilei din hyperarcul curent (apoi, recursiv 
	pentru fiecare hyperarc). Daca domeniul a fost limitat trebuie sa vedem daca
	celelalte constrangeri mai sunt satisfiabile cu domeniul actual. In acest
	sens, extrag o lista de constrangeri ce contin variabila curenta. Apoi 
	pentru fiecare constrangere de acest tip, se creeaza un nou hyperarc si
	se introduce in lista de hyperarce (la final).
		Pentru generarea constrangerilor care respecta conditia si a 
	hyperarcelor am folosit setof.
		Dupa rularea algoritmului, in functie de hyperarcele de input se 
	obtin domeniile limitate de aceste constrangeri.
		
		Algoritmul MAC, spre deosebire de primul, descopera toate solutiile
	posibile care satisfac constrangerile date. Mai intai se creeaza o lista de
	hyperarce pentru constrangeri si se obtine cu ajutorul GAC3 lista de domeni
	restranse pentru variabile. Apoi, se incearca atribuirea pe rand a unei 
	valori pentru o variabila. Dupa fiecare astfel de atribuire se restrang din
	nou domeniile pentru variabile (pentru a nu cauta in intreg spatiul de 
	stari).
		Acest lucru il realizez cu functia rec ce se apeleaza recursiv. Functia
	primeste o variabila curenta si ii  atribuie o valoare din domeniul sau. 
	Apoi se extrag constrangerile ce contin acea variabila si se creeaza noile 
	hyperarce, dupa care se restrang domeniile variabilelor folosind GAC3. Daca
	mai sunt variabile neinstantiate (aici folosesc var(*)) atunci se apeleaza 
	recursiv functia cu noile domenii. In caz contrar se initializeaza solutia
	ca fiind toate posibilitatile de valori corespunzatoare domeniilor actuale
	(practic, formate dintr-o singura valoare).
		In acest mod, se obtin pe rand toate solutiile care satisfac 
	constrangerile initiale.
	
    (!!!)   Alte detalii referitoare la implementarea temei se gasesc in 
            fisierul sursa.

    Andrei Ursache
