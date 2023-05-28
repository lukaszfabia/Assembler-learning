.data
a:           .word 0
b:           .word 0
c:           .word 0
d:           .word 0
continuing:  .word 0
which:       .word 0
msg_b:       .asciiz "Podaj b: "
msg_c:       .asciiz "Podaj c: "
msg_d:       .asciiz "Podaj d: "
msg_result:  .asciiz "Wynik a="
msg_continue: .asciiz "\nCzy kontynuowac? (0 - nie, 1 - tak): "
msg_expression: .asciiz "Z ktorego wyrazenia policzyc: "
div_exc: .asciiz "div/0!\n"
msg_wrong_number: .asciiz  "Nie poprawna komenda!\n"

.text    
loop:
    # wypisanie wiadomosci i wczytanie zmiennej b
    li $v0, 4 # rezerwujemy pamiec 
    la $a0, msg_b # ladowanie do adresu zero wiadomosci msg_b
    syscall # i robimy printa wiadomosci 
    
    li $v0, 5 # wczytujemy od usera liczbe typu int  
    syscall # wywolanie systemowe
    sw $v0, b # zapis rejestru f0 do zmiennej b

    # wpisanie wiadomosci i wczytanie zmiennej c
    li $v0, 4
    la $a0, msg_c
    syscall
    li $v0, 5
    syscall 
    sw $v0, c

    # Wypisanie wiadomosci i wczytanie zmiennej d
    li $v0, 4
    la $a0, msg_d
    syscall
    li $v0, 5
    syscall 
    sw $v0, d

    # Pokaz msg expression
    li $v0, 4
    la $a0, msg_expression
    syscall 
    # wczytaj do zmiennej which inta 
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
    # tu moze byc problem (dzielenie) wynik ktory zostanie zapisany do a to bedzie podloga z tego wyniku prawdziwego
    # + d nie moze byc zerem bo nie mozna dzielnic
    # moze wystapic overflow przy mnozeniu jesli wyniku nie bedzie dalo sie zakodwać na 32 bitach ?
    lw $t0, c # ladujemy do rejstru wart c
    lw $t1, b # ladujemy do rejstru wart b
    sub $t0, $t0, $t1 # odjemujemy i przypisujemy wynik do rejestru $t0
    lw $t2, d # ladujemy do rejstru wart d
    beq $t2, 0, div_exception
    div $t0, $t0, $t2 # dzielimy i nadpisujemy do rejestru t0
    sw $t0, a # zapisujemy do zmiennej a wart. z rejestru t
    j print_result # wykonujemy skok do etykiety wypisujacej wynik

calculate_2:
    # a = (c - d) * b
    lw $t0, c
    lw $t1, d
    sub $t0, $t0, $t1
    lw $t2, b
    mul $t2, $t0, $t2
    sw $t2, a
    j print_result

calculate_3:
    # a = b * c - 2 * d
    lw $t0, b
    lw $t1, c
    mul $t0, $t0, $t1 # mnozymy rejestry t0, t1 do zapisujemy do rejestru t0
    addi $t2, $zero, 2 # dodajemy do rejestru t3 2 <=> int t3 = 2
    lw $t3, d 
    mul $t3, $t3, $t2 # mnozymy to co jest w rejestrze t3 i t2 i nadpisujemy rejstr t3
    sub $t0, $t0, $t3 # odejmujemy i robimy podobnie to poprzedniego 
    sw $t0, a # zapisujemy wynik do zmiennej a 
    j print_result # skok do labela print_result zeby wypisal wynik

print_result:
    # wypisanie wiadomości "wynik: "
    li $v0, 4
    la $a0, msg_result
    syscall

    # wypisanie wyniku
    li $v0, 1 # w rejestrze v0 ustawiamy wartosc 1, przeznaczona dla liczby typu int, niezbedne przy pokazaniu wyniku 
    lw $a0, a # ladowanie do adresu zmiennej a 
    syscall # wywolanie rejstru v0, a nim mamy info ze chcemy wyswitelic inta 

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
