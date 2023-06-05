# Szyfr przestawieniowy permutacyjny.#
### Napisz program, który będzie szyfrował i deszyfrował wpisany ciąg znaków. ###
1. Którą operację wykonać: S – szyfrowanie, D – deszyfrowanie
2. 8 znakowy klucz przekształcenia zawierający cyfry z przedziału od 1 do 8:
3. Tekst jawny (co najwyżej 50 znaków), jeśli operacją jest szyfrowanie lub 
kryptogram o długości do 50 znaków, jeśli operacją jest deszyfrowanie

**Założenia**:
* z ciągu znaków należy usunąć znaki iterpunkcyjne oraz cyfry i przekszałcić resztę do duży liter.

**Przykład**:
Niech d = 4, zaś f jest permutacją (kluczem) o wartości (2431), tj. 
f(1) = 4, f(2) = 1, f(3) = 3, f(4) = 2. 
Wówczas tekst jawny M = KRYPTOANALIZA zostanie zaszyfrowany jako: RPYKONATLZIAA.
Deszyfrowanie: d = 4, klucz – permutacja odwrotna – (4132), tj.
f(1) = 2, f(2) = 4, f (3) = 3, f(4) = 1
Szyfrogram: RPYKONATLZIAA zostanie zdeszyfrowany do tekstu jawnego: 
KRYPTOANALIZA

  
