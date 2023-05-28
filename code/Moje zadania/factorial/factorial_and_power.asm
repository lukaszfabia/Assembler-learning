.data
x: .word 0
sum: .word 1
msg: .asciiz "Podaj jaka silnie chcesz policzyc: "
msg1: .asciiz "Podaj wykladnik: "
msg2: .asciiz "Co chesz policzyć (silnia(0), potega(1)): "
msg3: .asciiz "Podaj podstawe: "
msg4: .asciiz "\nczy kontynuowac nie(0), tak(1): "
msg5: .asciiz "nie poprawna komenda wybierz 0 albo 1\n"
result: .asciiz "Wynik: "
which: .word 0

.text
main:
	addi $t0, $zero, 1
	sw $t0, sum
	
	li $v0, 4
	la $a0, msg2
	syscall
	
	li $v0, 5
	syscall 
	sw $v0, which 
	
choice:
	lw $t0, which
	beq $t0, 0, factorial
	beq $t0, 1, power
	j choice

power:
	# wypisanie info 
	li $v0, 4
	la $a0, msg3
	syscall

	li $v0, 5
	syscall
	sw $v0, x
	
	li $v0, 4
	la $a0, msg1
	syscall

	li $v0, 5
	syscall
	move $t1, $v0 
	
	addi $t0, $zero, 0

	lw $t2, x
	lw $t3, sum
for:
	bge $t0, $t1, exit_print
	mul $t3, $t3, $t2
	sw $t3, sum
	addi $t0, $t0, 1
	j for


factorial:
	# wypisanie info 
	li $v0, 4
	la $a0, msg
	syscall

	li $v0, 5
	syscall
	sw $v0, x

	addi $t0, $zero, 1 # int i = 1
	lw $t1, x # ladowanie x 
	lw $t2, sum # int sum = 1 
loop: 
	bgt $t0, $t1, exit_print # i <= n
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
	
continue:
	li $v0, 4
	la $a0, msg4
	syscall
	
	li $v0, 5
	syscall
	move $t0, $v0 
	beq $t0, 1, main
	beq $t0, 0, end
	
	li $v0, 4
	lw $a0, msg5
	syscall
	j continue
	
end:
	li $v0, 10
	syscall
