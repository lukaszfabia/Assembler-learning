.data
input:   .space 80
prompt:  .asciiz "\nPodaj ciag znakow> "
star:    .asciiz "*"
output:  .asciiz "\nZmodyfikowany ciag znakow> "

.text
main:
    # wyswietlenie zapytania
    li $v0, 4           # wywo�anie systemowe dla drukowania �a�cucha
    la $a0, prompt      # adres �a�cucha (etykieta prompt)
    syscall

    # wczytanie ci�gu znakowego
    li $v0, 8           # wywo�anie systemowe dla wczytania �a�cucha
    la $a0, input       # adres bufora (etykieta input)
    li $a1, 80         # maksymalna liczba znak�w do wczytania
    syscall

    # zast�pienie liczb gwiazdkami
    move $t0, $a0       # przechowanie adresu pocz�tku ci�gu znak�w w $t0

    replace_numbers:
        lb $t1, 0($t0)          # wczytanie znaku z bufora
        beqz $t1, stop       # zako�czenie, je�li napotkano znak zerowy (koniec ci�gu)

        li $t2, 48             # warto�� kodu ASCII cyfry '0'
        li $t3, 57             # warto�� kodu ASCII cyfry '9'

        blt $t1, $t2, skip_replace   # przej�cie, je�li znak jest mniejszy ni� '0'
        bgt $t1, $t3, skip_replace   # przej�cie, je�li znak jest wi�kszy ni� '9'

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
        addi $t0, $t0, 1        # zwi�kszenie adresu bufora o 1
        j replace_numbers

    stop:
        li $v0, 10          # zako�cz
        syscall
