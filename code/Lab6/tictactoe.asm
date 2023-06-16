.data 
# tablice/ciagi znakow
player_name: .space 30
grid: .space 36
sign_set: .byte 'x', 'o'
choiced_sign: .space 1
computer_sign: .space 1

# zmienne int
amount_rounds: .word 0
human_score: .word 0
computer_score: .word 0

# napisy
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
divider: .asciiz "\n-----------------------------------\n\n"
computer_msg: .asciiz "Komputer wybral pozycje: "
start_grid: .asciiz "1 | 2 | 3\n----------\n4 | 5 | 6\n----------\n7 | 8 | 9\n"


# zarezerwowane rejestry: s0

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


	addi $s0, $zero, 1 # ustawienie numeru rundy na 1
	lw $s1, amount_rounds # wczytanie ilosci rund
	game_loop:
		beq $s0, $s1, exit # jesli numer rundy jest rowny ilosci rund to zakoncz gre

		# wypisanie podzialki
		jal print_divider

		# wypisanie planszy
		jal print_grid
		addi $s0, $s0, 1 # zwiekszenie numeru rundy o 1
	j game_loop


exit:
	li $v0, 10
	syscall


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
	li $v0, 4
	la $a0, start_grid
	syscall

	li $v0, 4
	la $a0, grid
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

