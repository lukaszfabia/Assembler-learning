.data
prompt1: .asciiz "Podaj koniec przedzialu: "
.text
main:
    li $v0, 4
    la $a0, prompt1
    syscall
    
    li $v0, 5
    syscall
    move $s2, $v0

    addi $s1, $zero, 1 # [1, k] i = 1
while:
    bgt $s1, $s2, end
    # wywolanie funkcji i wstawienie do v0 sumy dzielnikow 
    jal is_perfect
    #v0 - suma dzielnikow 
    beq $v0, $s1, print_pos
    addi $s1, $s1, 1 # i++
    j while


is_perfect:
    li $t0, 0  # sum=0
    li $t1, 1  # i=1
loop:
    move $s0, $s1
    beq $t1, $s0, set_var
    div $s0, $t1  # $s0 / $t1
    mfhi $t3  # $t3 = $s0 % $t1
    beqz $t3, add_to_sum
    addi $t1, $t1, 1  # i++
    j loop  # if $i <= liczba then goto loop

set_var:
    move $v0, $t0
    jr $ra

add_to_sum:
    add $t0, $t0, $t1 # sum+=i
    addi $t1, $t1, 1 #i++
    j loop

print_pos:
    li $v0, 1
    move $a0, $s1
    syscall

    li $v0, 11
    la $a0, ' '
    syscall
    
    addi $s1, $s1, 1
    j while

end:
    li $v0, 10
    syscall
