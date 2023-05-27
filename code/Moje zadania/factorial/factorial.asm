.data
n: .word 0
sum: .word 1
msg: .asciiz "Podaj jaka silnie chcesz policzyc: "
result: .asciiz "Wynik: "

.text
main:
	# wypisanie info 
	li $v0, 4
	la $a0, msg
	syscall

	li $v0, 5
	syscall
	sw $v0, n

	addi $t0, $zero, 1 # int i = 1
	lw $t1, n # ladowanie n 
	lw $t2, sum # int sum = 1 
loop: 
	bge $t0, $t1, exit_print # i <= n
	mul $t2, $t2, $t0 # sum = sum * i
	sw $t2, sum
	addi $t0, $t0, 1 
	j loop

exit_print:
	# wypisanie info 
	li $v0, 4
	la $a0, result
	syscall
	
	li $v0, 1
	lw $a0, sum
	syscall
	
	li $v0, 10
	syscall
