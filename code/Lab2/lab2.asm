.data
#is_end:      .word 0
a:           .float 0.0
b:           .float 0.0
c:           .float 0.0
d:           .float 0.0
const: 	     .float 2.0 # stala przez ktora bedziemy przemnazac 
continuing:  .word 0
which:       .word 0
msg_b:       .asciiz "Podaj b: "
msg_c:       .asciiz "Podaj c: "
msg_d:       .asciiz "Podaj d: "
msg_result:  .asciiz "Wynik a="
msg_continue: .asciiz "\nCzy kontynuowac? (0 - nie, 1 - tak): "
msg_expression: .asciiz "Z ktorego wyrazenia policzyc: "
msg_wrong_number: .asciiz "Nie poprawna komenda!"
div_exc: .asciiz "div/0!"

.text
loop:
    # wypisanie wiadomosci i wczytanie zmiennej b
    li $v0, 4 # rezerwujemy pamiec 
    la $a0, msg_b # ladowanie do adresu zero wiadomosci msg_b
    syscall # i robimy printa wiadomosci 
    li $v0, 6 # wczytujemy od usera liczbe typu float  
    syscall # wywolanie systemowe
    s.s $f0, b # zapis rejestru f0 do zmiennej b

    # wpisanie wiadomosci i wczytanie zmiennej c
    li $v0, 4
    la $a0, msg_c
    syscall
    li $v0, 6
    syscall 
    s.s $f0, c

    # Wypisanie wiadomosci i wczytanie zmiennej d
    li $v0, 4
    la $a0, msg_d
    syscall
    li $v0, 6
    syscall 
    s.s $f0, d

    # Wczytanie wartosci which
    li $v0, 4
    la $a0, msg_expression
    syscall 
    li $v0, 5
    syscall
    sw $v0, which

    # Sprawdzenie wartosci which
    lw $t0, which # ladujemy do rejestru t0 liczbe ze zmiennej which zeby potem moc uzyc ja w do warunkow 
    beq $t0, 1, calculate_1 # jesli which jest rowny 1 to liczymy z 1 wyrazenia 
    beq $t0, 2, calculate_2 # jesli which jest rowny 2 to liczymy z 2 wyrazenia 
    beq $t0, 3, calculate_3 # jesli which jest rowny 3 to liczymy z 3 wyrazenia  

calculate_1:
    # a = (c - b) / d
    l.s $f0, c # ladujemy do rejstru wart c
    l.s $f1, b # ladujemy do rejstru wart b
    sub.s $f2, $f0, $f1 # odjemujemy i przypisujemy wynik do rejestru $f2
    l.s $f3, d # ladujemy do rejstru wart d
    c.eq.s $f3, $f7 # sprawdzamy czy warunek jest prawdziwy 
    bc1t div_exception # jesli warunek jest true to robimy skok to wyjatku
    div.s $f2, $f2, $f3 # dzielimy i nadpisujemy do rejestru f2
    s.s $f2, a # zapisujemy do zmiennej a wart. z rejestru f2
    j print_result # wykonujemy skok do etykiety wypisujacej wynik

calculate_2:
    # a = (c - d) * b
    l.s $f0, c
    l.s $f1, d
    sub.s $f2, $f0, $f1
    l.s $f3, b
    mul.s $f2, $f2, $f3
    s.s $f2, a
    j print_result

calculate_3:
    # a = b * c - 2 * d
    l.s $f0, b
    l.s $f1, c
    mul.s $f2, $f0, $f1 # mnozymy rejestry f0, f1 do zapisujemy do rejestru f2
    l.s $f3, const # zaladowanie stalej do rejestru f3 coprocesora1 
    l.s $f4, d
    mul.s $f3, $f3, $f4 # mnozymy to co jest w rejestrze f3 i f4 i nadpisujemy rejstr f3
    sub.s $f2, $f2, $f3 # odejmujemy i robimy podobnie to poprzedniego 
    s.s $f2, a # zapisujemy wynik do zmiennej a 
    j print_result # skok do labela print_result zeby wypisal wynik

print_result:
    # wypisanie wiadomości "wynik: "
    li $v0, 4
    la $a0, msg_result
    syscall

    # wypisanie wyniku
    li $v0, 2 # w rejestrze v0 ustawiamy wartosc 2, przeznaczona dla liczby typu float, niezbedne przy pokazaniu wyniku 
    l.s $f12, a # ladowanie do rejstru coprocesora1 f12 zmiennej a 
    syscall # wywolanie rejstru v0, a nim mamy info ze chcemy wyswitelic floata 
  
continue: 

    # wpisanie wiadomosci "Czy kontynuowac? (0 - nie, 1 - tak): "
    li $v0, 4 # ustawiamy sobie rejestr v0 na 4 bitow - przechowanie stringa 
    la $a0, msg_continue # ladujemy do adresu a0 wiadomosc
    syscall # i robimy wywolanie systemowe 

    # wczytanie wartosci continuing
    li $v0, 5 # ustawiamy sobie rejestr v0 na 5 bitow - przechowanie integera 
    syscall # wywolanie systemowe
    sw $v0, continuing # zapisanie do zmiennej continuing stanu z v0 

    # sprawdzenie wartosci continuing
    lw $t0, continuing # ladujemy do t0 zmienna ze stanem 
    beq $t0, 0, end_loop # jesli w t0 jest 0 to skaczemy do etykiety ktora zakonczy loopa 
    beq $t0, 1, loop
    
    j wrong_number # skaczemy do loopa 

end_loop:
    # koniec programu 
    li $v0, 10
    syscall
    
div_exception:
    # wyjatek przy dzieleniu przez 0
    li $v0, 4
    la $a0, div_exc
    syscall
    j continue
    
wrong_number:
    # wyswietlnie komunikatu gdy user podal cos innego niz 1 albo 0
    li $v0, 4
    la $a0, msg_wrong_number
    syscall 
    j continue
