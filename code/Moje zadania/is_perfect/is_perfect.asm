.data
prompt1: .asciiz "Podaj liczbe i sprawdz, czy jest doskonala: "
liczba: .word 0
.text
main:
    li $v0, 4
    la $a0, prompt1
    syscall
    
    li $v0, 5
    syscall
    sw $v0, liczba

    jal is_perfect
    lw $t0, liczba
    beq $v0, $t0, print_pos

    li $v0, 11
    la $a0, 'n'
    syscall

    j end

is_perfect:
    li $t0, 0  # sum=0
    li $t1, 1  # i=1
loop:
    lw $s0, liczba
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
    addi $t1, $t1, 1
    j loop

print_pos:
    li $v0, 11
    la $a0, 't'
    syscall

end:
    li $v0, 10
    syscall
