.data
prompt_lim: .asciiz "Podaj granice przyblizenia: "
res_msg: .asciiz "Wartosc liczby pi: "
sign: .float 1.0
curr: .float 1.0
pi: .float 0.0
two: .float 2.0
one: .float 1.0
four: .float 4.0

.text
main:
    # wyswietlenie prompta
    li $v0, 4
    la $a0, prompt_lim
    syscall

    l.s $f0, sign
    l.s $f1, curr
    l.s $f2, pi
    #wczytanie wartosci 
    li $v0, 5
    syscall
    # przy ~500 000<granicach rzuca wyjtkiem ze jest out of range
    # druga sprawa jest taka ze dalej ~500 000 jako wart. granicy wynik jest ten sam 3.1415906 jakby sie wzielo double to moze by moglo policzyc dokladniej 
    li $t0, 500000
    li $t4, 0
    blt $v0, $t4, main
    bgt $v0, $t0, main
    # wywolanie funkcji
    move $a0, $v0
    jal find_pi
    
    l.s $f6, four
    mul.s $f12, $f6, $f12
    s.s $f12, pi
    # pokazanie msg res
    li $v0, 4
    la $a0, res_msg
    syscall
    
    # pokazanie wyniku 
    li $v0, 2
    l.s $f12, pi
    syscall

end:   
    li $v0, 10
    syscall

.globl find_pi
find_pi:
    # stale 
    l.s $f3, two
    l.s $f4, one
    #$f0, sign;  $f1, curr; $f3, two; $f4, one
    subu $sp, $sp, 8 # rezerwacja pamieci na stosie 
    s.s $f2, 0($sp)  # result 
    sw $ra, 4($sp) # adres powrotu

    beqz $a0, end_finding # jak limit osiagnie 0 to przejdziemy do obliczen
    subi $a0, $a0, 1 # limit -- 

    # przygotowanie wartosci do przekazania 
    mul.s $f2, $f3, $f1 # 2*curr
    sub.s $f2, $f2, $f4 # 2*curr-1
    div.s $f2, $f0, $f2 # sign/2*curr-1

    add.s $f1, $f1, $f4 # update dla curr
    neg.s $f0, $f0 # -sign

    jal find_pi
    #policzenie wart danego ulamka 
    add.s $f12, $f12, $f2
end_finding:
    lw $ra, 4($sp)
    l.s $f2, 0($sp)
    addi $sp, $sp, 8
    jr $ra 
