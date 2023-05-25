.data
input:   .space 80
prompt:  .asciiz "\nPodaj ciag znakow> "
star:    .asciiz "*"
output:  .asciiz "\nZmodyfikowany ciag znakow> "

.text
main:
    # wyswietlenie zapytania
    li $v0, 4           # wywo³anie systemowe dla drukowania ³añcucha
    la $a0, prompt      # adres ³añcucha (etykieta prompt)
    syscall

    # wczytanie ci¹gu znakowego
    li $v0, 8           # wywo³anie systemowe dla wczytania ³añcucha
    la $a0, input       # adres bufora (etykieta input)
    li $a1, 80         # maksymalna liczba znaków do wczytania
    syscall

    # zast¹pienie liczb gwiazdkami
    move $t0, $a0       # przechowanie adresu pocz¹tku ci¹gu znaków w $t0

    replace_numbers:
        lb $t1, 0($t0)          # wczytanie znaku z bufora
        beqz $t1, stop       # zakoñczenie, jeœli napotkano znak zerowy (koniec ci¹gu)

        li $t2, 48             # wartoœæ kodu ASCII cyfry '0'
        li $t3, 57             # wartoœæ kodu ASCII cyfry '9'

        blt $t1, $t2, skip_replace   # przejœcie, jeœli znak jest mniejszy ni¿ '0'
        bgt $t1, $t3, skip_replace   # przejœcie, jeœli znak jest wiêkszy ni¿ '9'

        # wypisanie gwiazdki
        li $v0, 4
        la $a0, star
        syscall

        j continue

        skip_replace:
        # wypisanie aktualnie pomijanego znaku
        li $v0, 11
        move $a0, $t1
        syscall

        continue:
        addi $t0, $t0, 1        # zwiêkszenie adresu bufora o 1
        j replace_numbers

    stop:
        li $v0, 10          # zakoñcz
        syscall
