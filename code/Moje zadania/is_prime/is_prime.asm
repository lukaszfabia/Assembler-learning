.data 
n: .word 0
neg: .asciiz "\nNie"
pos: .asciiz "\nTak"
prompt: .asciiz "Podaj liczbe: "
help: .word 0

.text
main:
	li $v0, 4
	la $a0, prompt
	syscall
	
	li $v0, 5
	syscall
	sw $v0, n
	
	addi $t0, $zero, 2 # int i = 2
	lw $t1, n # ladowanie n 
	blt $t1, $t0, exit_neg
	sub $t5, $t1, 1
	sw $t5, help

loop: 
	bgt $t0, $t5, exit_print # i < n
	div  $t1, $t0
	mfhi $s0
	move $t3, $s0
	beqz $t3, exit_neg # return false if n mod i == 0
	addi $t0, $t0, 1 
	j loop

exit_print:
	# wypisanie info 
	li $v0, 4
	la $a0, pos
	syscall
	
	li $v0, 10
	syscall
	
exit_neg:
	# wypisanie info 
	li $v0, 4
	la $a0, neg
	syscall
	
	li $v0, 10
	syscall
	
