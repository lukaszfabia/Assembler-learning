.data 
grid: .word '1 ' '2 ' '3 ' '4 ' '5 ' '6 ' '7 ' '8 ' '9 '
prompt: .asciiz "Wybierz znak 'x', 'o': "
input: .asciiz "Wybierz pole: "
win: .asciiz "\nWygrales"
lose: .asciiz "\nPrzegrales"
rounds: .asciiz "\nIle rund ma byc rozegrane(1-5): "

.text
how_many_rounds:
    li $v0, 4
    la $a0, rounds
    syscall

    li $v0, 5
    syscall
    move $s0, $v0
    li $t0, 5
    li $t1, 1
    #sprawdzamy czy liczba jest z przedzialu [1,5]
    bgt $s0, $t0, how_many_rounds
    blt $s0, $t1, how_many_rounds

    jal display_grid

    j end
    addi $t0, $zero, 0
    loop: 
        beq $t0, $s0, end
        jal game
        addi $t0, $t0, 1
        j loop

#s0 i s1 zajete
game:
# s3 rejestr przechowujacy znak gracza 
    li $v0, 4
    la $a0, prompt
    syscall

    li $v0, 11
    syscall
    move $s3, $v0

    #sprawdzenie poprawnosci wprowadzonych danych 
    beq $s3, 'x', good
    beq $s3, 'o', good
    j game  

    good:
        jr $ra 





# wyswietlenie tablicy - funkcja 
display_grid:
    la $t0, grid    # Ładuje adres tablicy do rejestru $t0
    li $t1, 0       # Inicjalizuje licznik wierszy
print_grid:
    beq $t1, 3, end_displaying    # Jeśli licznik wierszy osiągnie wartość 3, zakończ

    li $t2, 0       # Inicjalizuje licznik kolumn

print_row:
     beq $t2, 3, next_row   # Jeśli licznik kolumn osiągnie wartość 3, przejdź do następnego wiersza

    lw $a0, ($t0)       # Ładuje wartość z pamięci na podstawie adresu w $t0 do $a0
    li $v0, 11          # System call 11 - Wypisz znak
    syscall

    addiu $t2, $t2, 1   # Inkrementuje licznik kolumn
    addiu $t0, $t0, 4   # Przesuwa adres do następnego słowa (4 bajty)

    j print_row         # Skok do etykiety print_row

next_row:
    li $a0, 10          # Wartość ASCII dla znaku nowej linii
    li $v0, 11          # System call 11 - Wypisz znak
    syscall

    addiu $t1, $t1, 1   # Inkrementuje licznik wierszy

    j print_grid        # Skok do etykiety print_grid

end_displaying:
    jr $ra

end:
    li $v0, 10
    syscall