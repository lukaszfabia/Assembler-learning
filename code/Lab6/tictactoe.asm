.data 
# tablice/ciagi znakow
player_name: .space 30
grid: .space 36
sign_set: .byte 'x', 'o'
choiced_sign: .space 1
computer_sign: .space 1
corners_indexes: .word 0, 8, 24, 32

# zmienne int
amount_rounds: .word 0
human_score: .word 0
computer_score: .word 0
position: .word 0

# napisy
computer: .asciiz "Komputer"
prompt_player_name: .asciiz "Podaj swoje imie: "
prompt_amount_rounds: .asciiz "Podaj ilosc rund: "
prompt_position: .asciiz "\n\nPodaj pozycje: "
win_msg: .asciiz "Wygrales!"
lose_msg: .asciiz "Przegrales!"
draw_msg: .asciiz "Remis!"
end_msg: .asciiz "Koniec gry!"
round_msg: .asciiz "Runda: "
choice_msg: .asciiz "Wybierz swoj znak 'x' albo 'o': "
divider: .asciiz "\n-----------------------------------\n\n"
computer_msg: .asciiz "Komputer wybral pozycje: "
start_grid: .asciiz "1 | 2 | 3\n----------\n4 | 5 | 6\n----------\n7 | 8 | 9\n"


# zarezerwowane rejestry: s0, s1

.text
main:
	li $v0, 4
    la $a0, prompt_player_name
    syscall

    li $v0, 8
    la $a0, player_name
	li $a1, 30
    syscall

	# pobranie ilosci rund
	jal get_rounds

	# pobranie znaku od gracza
	jal get_sign

	# ustawienie znaku komputera
	jal get_computer_sign


	addi $s0, $zero, 0 # ustawienie numeru rundy na 1
	lw $s1, amount_rounds # wczytanie ilosci rund
	game_loop:
		# wypisanie podzialki
		jal print_divider

		# wyczyszczenie tablicy
		jal clear_grid
        j round

        after_round:
		addi $s0, $s0, 1 # zwiekszenie numeru rundy o 1
	    bne $s0, $s1, game_loop # jesli numer rundy jest rowny ilosci rund to zakoncz gre


exit:
	li $v0, 10
	syscall
# jedna runda gry    
round:
    jal check_win
    move $t0, $v0 # zapisanie wyniku do rejestru
    beq $t0, 1, end_of_round # jesli wynik jest rowny 1 to wygrana

    jal check_draw
    move $t0, $v0 # zapisanie wyniku do rejestru
    beq $t0, 1, end_of_round # jesli wynik jest rowny 1 to remis

    jal print_grid # wypisanie planszy
    jal get_player_move # pobranie ruchu gracza
    jal print_grid # wypisanie planszy
    j get_computer_move # pobranie ruchu komputera
    after_computer_move:
    j round

    end_of_round:
        j upgrade_results
        after_upgrade_results:
            jal print_stats

        j after_round

get_computer_move:
    #sprawdzenie czy komputer moze wygrac
    addi $t0, $zero, 0 # $t0 - iterator pętli
    addi $t2, $zero, 0 # $t2 - iterator pętli
    can_i_win_loop:
            beq $t0, 36, can_i_win_end # jesli i == 36 to jest remis
            lb $t1, grid($t0) # wczytaj znak z tablicy
            addiu $t2, $t0, 49
            beq $t2, $t1, can_i_win1
            # jesli to sie nie spelni to przejdz do nastepnego znaku
            addi $t0, $t0, 4 # zwiększ i o 4
            j can_i_win_loop
            can_i_win1:
                lb $t1, computer_sign
                sb $t1, grid($t0)
                jal check_win
                beq $v0, 1, after_computer_move # to wygral komputer
                sb $t2, grid($t0) # grid[i] = '0' + i + 1;
                addi $t0, $t0, 4 # zwiększ i o 4
                j can_i_win_loop

    can_i_win_end:

    #blokowanie wygranej gracza
    addi $t0, $zero, 0 # $t0 - iterator pętli
    addi $t2, $zero, 0 # $t2 - iterator pętli
    can_i_block:
        beq $t0, 36, can_i_block_end # jesli i == 36 to jest remis
        lb $t1, grid($t0) # wczytaj znak z tablicy
        addiu $t2, $t0, 49
        beq $t2, $t1, can_i_block1
        # jesli to sie nie spelni to przejdz do nastepnego znaku
        addi $t0, $t0, 4 # zwiększ i o 4
        j can_i_block
        can_i_block1:
            lb $t1, choiced_sign
            sb $t1, grid($t0)
            jal check_win
            beq $v0, 1, block # to wygral komputer
            sb $t2, grid($t0) # grid[i] = '0' + i + 1;
            addi $t0, $t0, 4 # zwiększ i o 4
            j can_i_block
        block:
            lb $t1, computer_sign
            sb $t1, grid($t0)
            j after_computer_move

    can_i_block_end:
    
    # zajecie srodka

    li $t0, 16
    lb $t1, grid($t0)
    beq $t1, '5', take_middle
    j try_to_take_corner
    take_middle:
        lb $t1, computer_sign
        sb $t1, grid($t0)
        j after_computer_move

    try_to_take_corner:
        addi $t0, $zero, 0 # iterator dla corners_indexes
        take_corner_loop:
            beq $t0, 16, take_corner_end # jesli i == 4 to jest remis
            lw $t1, corners_indexes($t0) # wczytaj znak z tablicy
            lb $t2, grid($t1)
            addiu $t3, $t0, 49 # '0'+i+1
            beq $t2, $t3, take_corner1
            # jesli to sie nie spelni to przejdz do nastepnego znaku
            addi $t0, $t0, 4 # zwiększ i o 1
            j take_corner_loop
            take_corner1:
                lb $t2, computer_sign
                sb $t2, grid($t1)
                j after_computer_move




    take_corner_end:
    
    #zajecie czegos innego
        addi $t0, $zero, 0 # iterator dla corners_indexes
        take_something_loop:
            beq $t0, 36, after_computer_move
            lb $t1, grid($t0)
            addiu $t2, $t0, 49
            beq $t1, $t2, take_something1
            addi $t0, $t0, 4
            j take_something_loop
            take_something1:
                lb $t1, computer_sign
                sb $t1, grid($t0)
                j after_computer_move

    j after_computer_move

upgrade_results:
    jal check_draw
    beq $v0, 1, after_upgrade_results

    jal check_win
    lb $t0, choiced_sign($zero)
    beq $v1, $t0, upgrade_human_score
    j upgrade_computer_score

    upgrade_human_score:
        lw $t0, human_score
        addi $t0, $t0, 1
        sw $t0, human_score
        j after_upgrade_results

    upgrade_computer_score:
        lw $t0, computer_score
        addi $t0, $t0, 1
        sw $t0, computer_score
        j after_upgrade_results 

check_draw:
    addi $t0, $zero, 0 # $t0 - iterator pętli
    check_draw_loop:
        beq $t0, 36, its_draw # jesli i == 36 to jest remis
        lb $t1, grid($t0) # wczytaj znak z tablicy
        addi $t0, $t0, 4 # zwiększ i o 4
        beq $t1, 'o', check_draw_loop
        beq $t1, 'x', check_draw_loop
        j its_not_draw
    its_not_draw:
        li $v0, 0
        jr $ra

    its_draw:
        li $v0, 1
        jr $ra

check_win:
    # implementacja sprawdzania wygranej
    li $t0, 0                 # $t0 - iterator pętli
    la $t1, sign_set          # $t1 - wskaźnik na zbiór znaków
    lbu $t2, ($t1)            # $t2 - pierwszy znak 'x'
    lbu $t3, 1($t1)           # $t3 - drugi znak 'o'
    move $s2, $t2             # $s0 - mark (inicjalizacja pierwszym znakiem 'x')

    for_loop:
        slti $t4, $t0, 2          # Sprawdź warunek i < 2
        beq $t4, $zero, exit_loop # Jeśli i >= 2, zakończ pętlę

    # Sprawdź wszystkie możliwe kombinacje zwycięstwa
        la $t5, grid
        lb $t6, ($t5)             # grid[0]
        lb $t7, 4($t5)            # grid[1]
        lb $t8, 8($t5)            # grid[2]
        beq $t6, $s2, check_win_condition1
        j check_win_condition2

    check_win_condition1:
        beq $t7, $s2, check_win_condition1_2
        j check_win_condition2

    check_win_condition1_2:
        beq $t8, $s2, win_found

    check_win_condition2:
        lb $t6, 12($t5)            # grid[3]
        lb $t7, 16($t5)            # grid[4]
        lb $t8, 20($t5)            # grid[5]
        beq $t6, $s2, check_win_condition3
        j check_win_condition4

    check_win_condition3:
        beq $t7, $s2, check_win_condition3_2
            j check_win_condition4

    check_win_condition3_2:
        beq $t8, $s2, win_found

    check_win_condition4:
        lb $t6, 24($t5)            # grid[6]
        lb $t7, 28($t5)            # grid[7]
        lb $t8, 32($t5)            # grid[8]
        beq $t6, $s2, check_win_condition5
        j check_win_condition6

    check_win_condition5:
        beq $t7, $s2, check_win_condition5_2
        j check_win_condition6

    check_win_condition5_2:
        beq $t8, $s2, win_found

    check_win_condition6:
        lb $t6, 0($t5)             # grid[0]
        lb $t7, 12($t5)            # grid[3]
        lb $t8, 24($t5)            # grid[6]
        beq $t6, $s2, check_win_condition7
        j check_win_condition8

    check_win_condition7:
        beq $t7, $s2, check_win_condition7_2
        j check_win_condition8

    check_win_condition7_2:
        beq $t8, $s2, win_found

    check_win_condition8:
        lb $t6, 4($t5)             # grid[1]
        lb $t7, 16($t5)            # grid[4]
        lb $t8, 28($t5)            # grid[7]
        beq $t6, $s2, check_win_condition9
        j check_win_condition10

    check_win_condition9:
        beq $t7, $s2, check_win_condition9_2
        j check_win_condition10

    check_win_condition9_2:
        beq $t8, $s2, win_found

    check_win_condition10:
        lb $t6, 8($t5)            # grid[2]
        lb $t7, 20($t5)            # grid[5]
        lb $t8, 32($t5)            # grid[8]
        beq $t6, $s2, check_win_condition11
        j check_win_condition12

    check_win_condition11:
        beq $t7, $s2, check_win_condition11_2
        j check_win_condition12

    check_win_condition11_2:
        beq $t8, $s2, win_found

    check_win_condition12:
        lb $t6, 0($t5)            # grid[0]
        lb $t7, 16($t5)            # grid[4]
        lb $t8, 32($t5)            # grid[8]
        beq $t6, $s2, check_win_condition13
        j check_win_condition14

    check_win_condition13:
        beq $t7, $s2, check_win_condition13_2
        j check_win_condition14

    check_win_condition13_2:
        beq $t8, $s2, win_found

    check_win_condition14:
        lb $t6, 8($t5)            # grid[2]
        lb $t7, 16($t5)            # grid[4]
        lb $t8, 24($t5)            # grid[6]
        beq $t6, $s2, check_win_condition15
        j increment_iterator

    check_win_condition15:
        beq $t7, $s2, check_win_condition15_2
        j increment_iterator

    check_win_condition15_2:
        beq $t8, $s2, win_found

    increment_iterator:
        addiu $t0, $t0, 1         # i++
	    move $s2, $t3 # zmiana znaku
        j for_loop

    win_found:
        li $v0, 1                 # Ustawienie wartości zwrotnej na true
        move $v1, $s2             # Zapisanie zwycięskiego znaku do $v1
        jr $ra                    # Powrót z funkcji

    exit_loop:
        li $v0, 0                 # Ustawienie wartości zwrotnej na false
        jr $ra                    # Powrót z funkcji
print_stats:
    # wypisanie statystyk w stylu "imie: wynik - wynik :komputer"
    li $v0, 4
    la $a0, computer
    syscall 

    li $v0, 11
    la $a0, '-'
    syscall

    li $v0, 4
    la $a0, player_name
    syscall

    li $v0, 1
    lw $a0, computer_score
    syscall

    li $v0, 11
    la $a0, ':'
    syscall

    li $v0, 1
    lw $a0, human_score
    syscall
    
    jr $ra

clear_grid:
    # czyszczenie tablicy
    addiu $t0, $zero, 0
    addiu $t1, $zero, '1'
    clear_loop:
        beq $t0, 36, clear_loop_end
        sb $t1, grid($t0)
        addiu $t1, $t1, 1
        addiu $t0, $t0, 4

        j clear_loop
    clear_loop_end:
        jr $ra
get_player_move:
    li $v0, 4
    la $a0, prompt_position
    syscall

    li $v0, 5
    syscall

    blt $v0, 1, get_player_move # jesli pozycja jest mniejsza od 1 to powrot do wprowadzania pozycji
    bgt $v0, 9, get_player_move # jesli pozycja jest wieksza od 9 to powrot do wprowadzania pozycji

    subi $t0, $v0, 1 # szukamy indeksu w tablicy
    mul $t0, $t0, 4 # mnozymy indeks przez 4

    lb $t3, grid($t0) # wczytujemy znak z tablicy

    beq $t3, 'x', get_player_move # jesli znak jest rowny 'x' to powrot do wprowadzania pozycji
    beq $t3, 'o', get_player_move # jesli znak jest rowny 'o' to powrot do wprowadzania pozycji

    lb $t1, choiced_sign($zero) # wczytanie znaku gracza
    sb $t1, grid($t0) # wpisanie znaku gracza do tablicy
    jr $ra


get_computer_sign:
	lb $t0, choiced_sign
	beq $t0, 120, set_o # jesli wybrano 'x' to ustaw znak komputera na 'o'
	beq $t0, 111, set_x # jesli wybrano 'o' to ustaw znak komputera na 'x'
	set_o:
		li $t0, 111
		sb $t0, computer_sign
		jr $ra
	
	set_x:
		li $t0, 120
		sb $t0, computer_sign
		jr $ra


print_grid:
	# wypisywanie planszy
    addi $t0, $zero, 0
    addi $t2, $zero, 1
	print_grid_loop:
        beq $t0, 36, print_grid_loop_end
        lbu $t1, grid($t0)

        # drukowanie elementu
        li $v0, 11
        move $a0, $t1
        syscall

        # postawienie spacji
        li $v0, 11
        la $a0, ' '
        syscall

        beq $t2, 3, new_lane
        beq $t2, 6, new_lane
        j skip_new_lane

        new_lane:
            li $v0, 11
            la $a0, '\n'
            syscall

        skip_new_lane:
            addi $t2, $t2, 1
            addiu $t0, $t0, 4

        j print_grid_loop

    print_grid_loop_end:
        li $v0, 4
        la $a0, divider
        syscall

	    jr $ra
print_divider:
	li $v0, 4
	la $a0, divider
	syscall

	jr $ra
get_rounds:
	# pobieranie ilosci rund
    li $v0, 4
    la $a0, prompt_amount_rounds
    syscall

    li $v0, 5
    syscall

    blt $v0, 1, get_rounds # jesli ilosc rund jest mniejsza od 1 to powrot do wprowadzania ilosci rund
    bgt $v0, 5, get_rounds # jesli ilosc rund jest wieksza od 5 to powrot do wprowadzania ilosci rund
    sw $v0, amount_rounds

	jr $ra

get_sign:
	# pobranie znaku od gracza
	li $v0, 4
    la $a0, choice_msg
    syscall

	li $v0, 12
	syscall
	beq $v0, 120, set_sign # jesli wybrano 'x' to ustaw znak gracza na 'x'
	beq $v0, 111, set_sign # jesli wybrano 'o' to ustaw znak gracza na 'o'
	j get_sign # jesli wybrano inny znak to powrot do wprowadzania znaku

	set_sign:
		sb $v0, choiced_sign
		jr $ra
