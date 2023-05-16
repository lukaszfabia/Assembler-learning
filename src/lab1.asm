.data
input:  .space 80
prompt: .asciiz "\nPodaj ciag znaków> "
drukuj: .asciiz "\nWczytany ciag    > "

.text
main:
    # wyswietlenie zapytania
    li $v0, 4           # wywołanie systemowe dla drukowania łańcucha
    la $a0, prompt      # adres łańcucha (etykieta prompt)
    syscall

    # wczytanie ciągu znakowego
    li $v0, 8           # wywołanie systemowe dla wczytania łańcucha
    la $a0, input       # adres bufora (etykieta input)
    li $a1, 80         # maksymalna liczba znaków do wczytania
    syscall

    # wyswietlenie komunikatu drukuj i wczytanego ciągu
    li $v0, 4           # wywołanie systemowe dla wydrukowania łańcucha
    la $a0, drukuj      # adres łańcucha (etykieta drukuj)
    syscall

    li $v0, 4           # wywołanie systemowe dla wydrukowania łańcucha
    la $a0, input       # adres łańcucha (etykieta input)
    syscall

stop:
    li $v0, 10          # zakończ
    syscall
