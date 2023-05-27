.data 
prompt: .asciiz "Podaj koniec przedzialu: "
amount: .word 0
k: .word 0
space: .asciiz " " 
.text
	li $v0, 4
	la $a0, prompt
	syscall
	
	li $v0, 5
	syscall
	sw $v0, amount 
	
	addi $t0, $zero, 0 # int k = 1
	lw $t1, amount 
while:
	addi $t0, $t0, 1 # k++ musimy to zrobic na poczatku bo k jako zmienna globalna trafi do funkcji primes
	bgt $t0, $t1, exit
	sw $t0, k
	jal primes
	skip:
	j while
	
exit:
	li $v0, 10
	syscall
	
primes:
	addi $t2, $zero, 2 # int i = 2
	lw $t3, k
	blt $t3, $t2, skip # i<2 to skip 
	sub $t4, $t3, 1 # zapis liczby iteracji loop k-1
loop: 
	bgt $t2, $t4, exit_print # i < n
	div  $t3, $t2 # k/i 
	mfhi $s0 # zapis reszty z tego dzielenia 
	move $t5, $s0 # przesuwamy reszte do t5
	beqz $t5, skip # return false if n mod i == 0
	addi $t2, $t2, 1 #i++
	j loop

exit_print:
	# wypisanie info
    	li $v0, 1
    	lw $a0, k
    	syscall
	
	li $v0, 4
	la $a0, space
	syscall
    	j while
