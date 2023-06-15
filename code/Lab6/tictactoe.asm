.data
# zmienne globalne
player_name: .space 20
amount_rounds: .word 0
grid: .space 9
results_for_human: .word 0
results_for_computer: .word 0
position: .word 0
choiced: .byte 1
xoro: .byte 'x', 'o'  # Przechowuje znaki 'x' i 'o'
computer_mark .byte 1 # Przechowuje znak komputera

# prompty dla gracza
computer: .asciiz "Komputer"
prompt_player_name: .asciiz "Podaj swoje imie: "
prompt_amount_rounds: .asciiz "Podaj ilosc rund: "
prompt_position: .asciiz "Podaj pozycje: "
win_msg: .asciiz "Wygrales!"
lose_msg: .asciiz "Przegrales!"
draw_msg: .asciiz "Remis!"
end_msg: .asciiz "Koniec gry!"
round_msg: .asciiz "Runda: "
choice_msg: .asciiz "Wybierz swoj znak 'x' albo 'o': "
divider: .asciiz "-----------------------------------\n"
computer_msg: .asciiz "Komputer wybral pozycje: "


.text
main:
    # pobranie imienia gracza
    li $v0, 4
    la $a0, prompt_player_name
    syscall

    li $v0, 8
    la $a0, player_name
    syscall

enter_amount_rounds:
    # pobranie ilosci rund
    li $v0, 4
    la $a0, prompt_amount_rounds
    syscall

    li $v0, 5
    syscall

    blt $v0, 1, enter_amount_rounds # jesli ilosc rund jest mniejsza od 1 to powrot do wprowadzania ilosci rund
    bgt $v0, 5, enter_amount_rounds # jesli ilosc rund jest wieksza od 5 to powrot do wprowadzania ilosci rund
    sw $v0, amount_rounds

get_char:
    # pobranie znaku gracza
    li $v0, 4
    la $a0, choice_msg
    syscall

    li $v0, 12
    syscall
    beq $v0, 'x', continue # jesli znak jest 'x' to kontynuacja
    beq $v0, 'o', continue # jesli znak jest 'o' to kontynuacja
    j get_char # jesli znak jest inny to powrot do pobierania znaku

continue:
    sb $v0, choiced # zapisanie wyboru gracza

    # drukowanie linii oddzielajacej
    li $v0, 4
    la $a0, divider
    syscall

    # twozenie petli glownej
    li $s0, 0 # licznik rund
    main_loop:
        beq $s0, amount_rounds, end # jesli licznik rund jest rowny ilosci rund to koniec gry
        # pokazanie wiadmosci numerze rundy
        li $v0, 4
        la $a0, round_msg
        syscall
        # i+1 runda
        li $v0, 1
        addi $a0, $s0, 1
        syscall

        # czyszczenie tablicy
        j clear_grid
    after_clear_grid:
        j game # wywolanie pojedynczej rozgrywki 
    after_game:
        j show_stats # pokazanie statystyk
    after_show_stats:
        addi $s0, $s0, 1 # zwiekszenie licznika rund o 1
        j main_loop # powrot do petli glownej

game:
    # implementacja pojedynczej rozgrywki

    jal display_grid # drukowanie tablicy
        while:
            jal check_win # sprawdzenie wygranej
            beq $v0, 1, after_show_stats # jesli wygrana jest inna niz 0 to koniec rozgrywki
            jal human_move
            jal display_grid
            j is_full
        after_checking_is_full:
            # wydrukowanie podzialki miedzy ruchami
            li $v0, 4
            la $a0, divider
            syscall

            jal computer_move
            jal display_grid
            j while


computer_move:
    lb $t0, choiced # pobranie wyboru gracza
    beq $t0, 'x', set_computer_mark_on_o # jesli wybor gracza jest 'x' to ustawienie znaku komputera na 'o'
    beq $t0, 'o', set_computer_mark_on_x # jesli wybor gracza jest 'o' to ustawienie znaku komputera na 'x'

set_computer_mark_on_o:
    li $t0, 'o'
    sb $t0, computer_mark
    j after_set

set_computer_mark_on_x:
    li $t0, 'x'
    sb $t0, computer_mark
    j after_set

after_set:
    # sprawdzenie czy mozna wygrac dokladajac jeden znak
    li $t0, 0                  # $t0 - iterator i
    la $t1, grid               # $t1 - adresa tablicy grid
    li $t2, 1                  # $t2 - wartość do porównania z elementami tablicy grid

    for_for_computer_move1:
        


is_full:
    # sprawdzenie czy tablica jest pelna
    li $t0, 0
    is_full_loop:
        beq $t0, 9, its_full
        lb $t1, grid($t0)
        beq $t1, 'x', is_full_loop
        beq $t1, 'o', is_full_loop
        j its_not_full

    its_full:
        li $v0, 1
        li $a0, 2
        syscall
        j end_checking_is_full

    its_not_full:
        j after_checking_is_full

end_checking_is_full:
    # pokazanie wiadmosci koncowej
    li $v0, 4
    la $a0, draw_msg
    syscall

    j main_loop
#-------------------------------------------
human_move:
    # pokazanie wiadmosci 
    li $v0, 4
    la $a0, prompt_position
    syscall

    li $v0, 5
    syscall
    blt $v0, 1, human_move
    bgt $v0, 9, human_move
    move $s3, $v0

    li $t0, 0
    is_proper_loop:
         beq $t0, 9, its_proper
         # obliczenie indeksu
         sub $t2, $s3, 1
         lb $t1, grid($t2)
         beq $t1, 'x', human_move
         beq $t1, 'o', human_move
         addi $t0, $t0, 1
         j is_proper_loop

    its_proper:
        sub $s3, $s3, 1
        sb $s1, grid($s3)

    # wyzerowanie rejestru
    move $s3, $zero
    jr $ra




#-------------------------------------------
check_win:
    # implementacja sprawdzania wygranej
 li $t0, 0                 # $t0 - iterator pętli
    la $t1, xoro              # $t1 - adresa tablicy xoro
    lbu $t2, ($t1)            # $t2 - pierwszy znak 'x'
    lbu $t3, 1($t1)           # $t3 - drugi znak 'o'
    move $s2, $t2             # $s0 - mark (inicjalizacja pierwszym znakiem 'x')

for_loop:
    slti $t4, $t0, 2          # Sprawdź warunek i < 2
    beq $t4, $zero, exit_loop # Jeśli i >= 2, zakończ pętlę

    # Sprawdź wszystkie możliwe kombinacje zwycięstwa
    la $t5, grid
    lb $t6, ($t5)             # grid[0]
    lb $t7, 1($t5)            # grid[1]
    lb $t8, 2($t5)            # grid[2]
    beq $t6, $s2, check_win_condition1
    j check_win_condition2

check_win_condition1:
    beq $t7, $s2, check_win_condition1_2
    j check_win_condition2

check_win_condition1_2:
    beq $t8, $s2, win_found

check_win_condition2:
    lb $t6, 3($t5)            # grid[3]
    lb $t7, 4($t5)            # grid[4]
    lb $t8, 5($t5)            # grid[5]
    beq $t6, $s2, check_win_condition3
    j check_win_condition4

check_win_condition3:
    beq $t7, $s2, check_win_condition3_2
    j check_win_condition4

check_win_condition3_2:
    beq $t8, $s2, win_found

check_win_condition4:
    lb $t6, 6($t5)            # grid[6]
    lb $t7, 7($t5)            # grid[7]
    lb $t8, 8($t5)            # grid[8]
    beq $t6, $s2, check_win_condition5
    j check_win_condition6

check_win_condition5:
    beq $t7, $s2, check_win_condition5_2
    j check_win_condition6

check_win_condition5_2:
    beq $t8, $s2, win_found

check_win_condition6:
    lb $t6, 0($t5)            # grid[0]
    lb $t7, 3($t5)            # grid[3]
    lb $t8, 6($t5)            # grid[6]
    beq $t6, $s2, check_win_condition7
    j check_win_condition8

check_win_condition7:
    beq $t7, $s2, check_win_condition7_2
    j check_win_condition8

check_win_condition7_2:
    beq $t8, $s2, win_found

check_win_condition8:
    lb $t6, 1($t5)            # grid[1]
    lb $t7, 4($t5)            # grid[4]
    lb $t8, 7($t5)            # grid[7]
    beq $t6, $s2, check_win_condition9
    j check_win_condition10

check_win_condition9:
    beq $t7, $s2, check_win_condition9_2
    j check_win_condition10

check_win_condition9_2:
    beq $t8, $s2, win_found

check_win_condition10:
    lb $t6, 2($t5)            # grid[2]
    lb $t7, 5($t5)            # grid[5]
    lb $t8, 8($t5)            # grid[8]
    beq $t6, $s2, check_win_condition11
    j check_win_condition12

check_win_condition11:
    beq $t7, $s2, check_win_condition11_2
    j check_win_condition12

check_win_condition11_2:
    beq $t8, $s2, win_found

check_win_condition12:
    lb $t6, 0($t5)            # grid[0]
    lb $t7, 4($t5)            # grid[4]
    lb $t8, 8($t5)            # grid[8]
    beq $t6, $s2, check_win_condition13
    j check_win_condition14

check_win_condition13:
    beq $t7, $s2, check_win_condition13_2
    j check_win_condition14

check_win_condition13_2:
    beq $t8, $s2, win_found

check_win_condition14:
    lb $t6, 2($t5)            # grid[2]
    lb $t7, 4($t5)            # grid[4]
    lb $t8, 6($t5)            # grid[6]
    beq $t6, $s2, check_win_condition15
    j increment_iterator

check_win_condition15:
    beq $t7, $s2, check_win_condition15_2
    j increment_iterator

check_win_condition15_2:
    beq $t8, $s2, win_found

increment_iterator:
    addiu $t0, $t0, 1         # i++
    j for_loop

win_found:
    li $v0, 1                 # Ustawienie wartości zwrotnej na true
    jr $ra                    # Powrót z funkcji

exit_loop:
    li $v0, 0                 # Ustawienie wartości zwrotnej na false
    jr $ra                    # Powrót z funkcji
#-------------------------------------------

display_grid:
    # drukowanie tablicy
    li $s1, 0
    display_loop:
        beq $s1, 9, after_display_end # jesli licznik jest rowny 9 to koniec drukowania
        beq $s1, 3, display_new_line # jesli licznik jest rowny 3 to drukowanie nowej linii
        beq $s1, 6, display_new_line # jesli licznik jest rowny 6 to drukowanie nowej linii
        continue_displaying:
        lb $a0, grid($s1) # pobranie komorki tablicy
        li $v0, 11
        syscall
        addi $s1, $s1, 1 # zwiekszenie licznika o 1
        j display_loop # powrot do petli drukujacej
    after_display_end:
        jr $ra
    
display_new_line:
    # drukowanie nowej linii
    li $v0, 4
    la $a0, "\n"
    syscall
    j continue_displaying # powrot do petli drukujacej

clear_grid:
    # czyszczenie tablicy
    li $s1, 0
    clear_loop:
        beq $s1, 9, after_clear_end # jesli licznik jest rowny 9 to koniec czyszczenia
        sb $s1, grid($s1) # wyczyszczenie komorki tablicy
        addi $s1, $s1, 1 # zwiekszenie licznika o 1
        j clear_loop # powrot do petli czyszczacej

show_stats:
    # pokazanie statystyk
    li $v0, 4
    la $a0, divider
    syscall

    li $v0, 4
    la $a0, player_name
    syscall

    li $v0, 4
    la $a0, results_for_human
    syscall

    li $v0, 4
    la $a0, computer
    syscall

    li $v0, 4
    la $a0, results_for_computer
    syscall

    li $v0, 4
    la $a0, divider
    syscall

    j after_show_stats # powrot do miejsca wywolania

end:
    # drukowanie linii oddzielajacej
    li $v0, 4
    la $a0, divider
    syscall

    # drukowanie wiadomosci koncowej
    li $v0, 4
    la $a0, end_msg
    syscall

    # drukowanie linii oddzielajacej
    li $v0, 4
    la $a0, divider
    syscall

    # koniec programu
    li $v0, 10
    syscall





