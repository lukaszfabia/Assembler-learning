.data 
# tablice/ciagi znakow
player_name: .space 30
grid: .space 9
sign_set: .byte 'x', 'o'
choiced_sign: .space 1
computer_sign: .space 1
corners_indexes: .word 0, 2, 6, 8

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
win_msg: .asciiz "\nWygrales!\n\n"
lose_msg: .asciiz "\nPrzegrales!\n\n"
draw_msg: .asciiz "\nRemis!\n\n"
end_msg: .asciiz "\n\nKoniec gry!"
round_msg: .asciiz "\n\nRunda: "
choice_msg: .asciiz "Wybierz swoj znak 'x' albo 'o': "
divider: .asciiz "\n\n-----------------------------------\n\n"
small_divider: .asciiz "\n------\n"
computer_msg: .asciiz "Komputer wybiera pozycje\n\n"


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
        li $v0, 4
        la $a0, round_msg
        syscall

        li $v0, 1
        addi $t0, $s0, 1
        move $a0, $t0
        syscall

		# wypisanie podzialki
		jal print_divider

		# wyczyszczenie tablicy
		jal clear_grid
        j round

        after_round:
		addi $s0, $s0, 1 # zwiekszenie numeru rundy o 1
	    bne $s0, $s1, game_loop # jesli numer rundy jest rowny ilosci rund to zakoncz gre


exit:
    li $v0, 4
    la $a0, end_msg
    syscall
    
	li $v0, 10
	syscall
# jedna runda gry    
round:
    jal print_grid # wypisanie planszy
    # done 
    jal check_win
    move $t0, $v0 # zapisanie wyniku do rejestru
    beq $t0, 1, end_of_round # jesli wynik jest rowny 1 to wygrana
    # done 
    jal check_draw
    move $t0, $v0 # zapisanie wyniku do rejestru
    beq $t0, 1, end_of_round # jesli wynik jest rowny 1 to remis

    jal get_player_move # pobranie ruchu gracza
    jal print_grid # wypisanie planszy

    jal check_win
    move $t0, $v0 # zapisanie wyniku do rejestru
    beq $t0, 1, end_of_round # jesli wynik jest rowny 1 to wygrana
    # done 
    jal check_draw
    move $t0, $v0 # zapisanie wyniku do rejestru
    beq $t0, 1, end_of_round # jesli wynik jest rowny 1 to remis

    # wypisanie komunikatu o ruchu komputera
    li $v0, 4
    la $a0, computer_msg
    syscall

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
    move $s4, $zero
    move $s5, $zero
    can_i_win_loop:
            beq $s5, 9, can_i_win_end 
                lb $t1, grid($s5) # wczytaj znak z tablicy
                addi $t0, $s5, 0 # zapisanie iteracji do $t0
                addi $s4, $t0, 1 # $t2 = i + 1
                addu $s4, $s4, '0' # $t2 = '0' + i + 1
                    bne $s4, $t1, can_i_win1

                        lb $t1, computer_sign($zero)
                        sb $t1, grid($s5)
                        jal check_win

                        beq $v0, 1, after_computer_move # to wygral komputer
                            sb $s4, grid($s5) # grid[i] = '0' + i + 1;
                            addi $s5, $s5, 1 # zwiększ i o 1
                            j can_i_win_loop
            can_i_win1:
                addi $s5, $s5, 1 # zwiększ i o 1
                j can_i_win_loop

    can_i_win_end:

    #blokowanie wygranej gracza - chyba dziala 
    move $s4, $zero # $s4 - dla przechowania znaku z tablicy
    move $s5, $zero # $s5 - dla przechowania znaku z tablicy
    can_i_block: 
        beq $s5, 9, can_i_block_end # jesli i == 36 to jest remis
            lb $t1, grid($s5) # wczytaj znak z tablicy
            addi $t3, $s5, 0 # skopiuj i do $t3
            addi $s4, $t3, 1 # $s4 = i + 1
            addu $s4, $s4, '0' # $s4 = '0' + i + 1
                beq $s4, $t1, can_i_block1
                    addi $s5, $s5, 1 # zwiększ i o 1
                    j can_i_block
                    can_i_block1:
                        lb $t1, choiced_sign
                        sb $t1, grid($s5)
                        jal check_win
                            beq $v0, 1, block # sprawdzenie czy gracz moze wygrac
                                sb $s4, grid($s5) # grid[i] = '0' + i + 1;
                                addi $s5, $s5, 1 # zwiększ i o 1
                                j can_i_block
                            block:
                                lb $t2, computer_sign # Wczytaj wartość choiced do $t1
                                sb $t2, grid($s5)
                                j after_computer_move

    can_i_block_end:
    move $s5, $zero # $s5 - dla przechowania znaku z tablicy
    ########################################################   
    # zajecie srodka - dziala bardzo dobrze !!!

    li $t0, 4
    lb $t1, grid($t0)
    beq $t1, '5', take_middle
    j try_to_take_corner

    take_middle:
        lb $t1, computer_sign($zero)
        sb $t1, grid($t0)
        j after_computer_move



    #####################################################
    # zajecie rogu - dziala bardzo dobrze !!!
    try_to_take_corner:
        addi $t3, $zero, 0 # $t0 - iterator pętli
        addi $t0, $zero, 0 # iterator dla corners_indexes
        move $s4, $zero
        take_corner_loop:
            beq $t0, 16, take_corner_end 
            lw $t1, corners_indexes($t0) # wczytaj znak z tablicy
            lb $t2, grid($t1)
            addi $s4, $t1, 1 # $s4 = i + 1
            addu $s4, $s4, '0' # $s4 = '0' + i + 1
            beq $t2, $s4, take_corner1
            # jesli to sie nie spelni to przejdz do nastepnego znaku
            addi $t0, $t0, 4 # zwiększ i o 4 (bo 4 bajty na inta)
            addi $t3, $t3, 1 # zwiększ i o 1
            j take_corner_loop
            take_corner1:
                lb $t4, computer_sign($zero)
                sb $t4, grid($t1)
                j after_computer_move

    take_corner_end:

    ##############################################
    #zajecie czegos innego - to dziala bardzo dobrze !!!
        addi $t0, $zero, 0 # iterator dla corners_indexes
        move $s4, $zero
        take_something_loop:
            beq $t0, 9, end_taking_something 
            lb $t1, grid($t0)
            addi $s4, $t0, 1 # $s4 = i + 1
            addu $s4, $s4, '0' # $s4 = '0' + i + 1
            beq $t1, $s4, take_something1
            addi $t0, $t0, 1
            j take_something_loop
            take_something1:
                lb $t3, computer_sign($zero)
                sb $t3, grid($t0)
                j after_computer_move

    end_taking_something:

        j after_computer_move

upgrade_results:
    jal check_draw
    beq $v0, 1, show_msg

    jal check_win
    lb $t0, choiced_sign($zero)
    beq $v1, $t0, upgrade_human_score
    j upgrade_computer_score

    upgrade_human_score:
        li $v0, 4
        la $a0, win_msg
        syscall

        lw $t0, human_score
        addi $t0, $t0, 1
        sw $t0, human_score
        j after_upgrade_results

    upgrade_computer_score:
        li $v0, 4
        la $a0, lose_msg
        syscall

        lw $t0, computer_score
        addi $t0, $t0, 1
        sw $t0, computer_score
        j after_upgrade_results 

    show_msg:
        li $v0, 4
        la $a0, draw_msg
        syscall
        j after_upgrade_results

check_draw:
    addi $t0, $zero, 0 # $t0 - iterator pętli
    check_draw_loop:
        lbu $t1, grid($t0) # wczytaj znak z tablicy
        beqz $t1, its_draw # jesli sie skonczylo to jest remis
        addiu $t0, $t0, 1 # zwiększ i o 1
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
    # $v0 = zwraca 1 jesli wygrana, 0 jesli nie
    # $v1 = zwraca wygrany znak
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
        lb $t6, 0($t5)             # grid[0]
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
        lb $t6, 1($t5)             # grid[1]
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
    addiu $t1, $zero, '1'
    addi  $t0, $zero, 0
    clear_loop:
        beq $t0, 9, clear_loop_end
        sb $t1, grid($t0)
        addiu $t1, $t1, 1
        addi $t0, $t0, 1

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
        beq $t2, 10, print_grid_loop_end
        lbu $t1, grid($t0)
        # drukowanie elementu
        li $v0, 11
        move $a0, $t1
        syscall

        beq $t2, 3, skip_divider
        beq $t2, 6, skip_divider
        beq $t2, 9, skip_divider
        # postawienie spacji
        li $v0, 11
        la $a0, '|'
        syscall

        skip_divider:

        beq $t2, 3, new_lane
        beq $t2, 6, new_lane
        j skip_new_lane

        new_lane:
            li $v0, 4
            la $a0, small_divider
            syscall


        skip_new_lane:
            addi $t2, $t2, 1
            addiu $t0, $t0, 1

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
