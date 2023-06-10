.data
buffer1: .space 20   # Bufor dla pierwszego tekstu
buffer2: .space 20    # Bufor dla drugiego tekstu
result: .space 20     # Bufor dla wyniku
prompt1: .asciiz "Podaj pierwszy tekst: "
prompt2: .asciiz "Podaj drugi tekst:    "
count_msg: .asciiz "\nLiczba jednakowych znakow: "
memory_msg: .asciiz "\nZaalokowana pamiec na stosie: " 
info: .asciiz "Zawartosc stosu - wypisana wg. lifo: "
prompt3: .asciiz "\nPodaj najpierw dluzszy tekst potem krotszy\n"

.text
main:	
	# prompt z pierwszym tekstem
	li $v0, 4
	la $a0, prompt1
	syscall
	
	# wczytanie 1 tekstu
	li $v0, 8
	la $a0, buffer1
	li $a1, 20
	syscall
	
	# prompt z drugim tekstem 
	li $v0, 4
	la $a0, prompt2
	syscall
	
	# wczytanie 2 tekstu
	li $v0, 8
	la $a0, buffer2
	li $a1, 20
	syscall
	
	# rezerwacja stalych rejestrow w ktorych beda dlugosci
	move $s1, $zero
	move $s0, $zero
	move $s7, $zero # rejestr do przechowania pamieci zaalokowanej na stosie licze w ten sposob ze sumuje rzeczy polozone na stosie
	# ale aktualizuje jak zdejmuje no bo zawsze zostanie 1bajt na stosie wiec to nie mialoby sensu chyba 
	
	# obliczenie dlugosci z funkcji dla buffer1/2
	la $a0, buffer1
	jal len
	move $s1, $v0
	
	
	la $a0, buffer2
	jal len
	move $s0, $v0
	
	
checkin:
	# buffer2>buffer1
	bgt $s0, $s1, prepare_var 
	j continue
	
prepare_var: 
	# zamiana tablic
	la $a0, buffer1
	la $a1, buffer2
	jal swap
	

continue:
	addiu $s2, $zero, '*' # rozne 
	addiu $s3, $zero, '-' # te same 
	
	# dodanie '0' na stack dlaczego dlatego ze to bedzie stopka stosu bo jesli bysmy chcieli 
	# sczytywac tak jak w tablicy to tam nie ma 0 tylko wskoczy nam stack overflow 
	addiu $s4, $zero, '0'
	sb $s4, 0($sp)
	addiu $sp, $sp, -1
	addiu $s7, $s7, 1
	
	# czyszczenie s4
	move $s4, $zero
	
	# upadate dla dlugosci ciagow 
	la $a0, buffer1
	jal len
	move $s1, $v0
	
	la $a0, buffer2
	jal len
	move $s0, $v0
	
	li $s6, -1

	
compression:
	lbu $t1, buffer1($s1)
	lbu $t2, buffer2($s0)
 
	beqz $t2, copy # teraz mamy pewnosc ze buffer2<buffer1
	
	# dekrementacja wskaznikow do tablic
	subiu $s0, $s0, 1
	subiu $s1, $s1, 1
	
	# jesli sa takie same to skaczemy labela same
	beq $t1, $t2, same
	
	# zapisanie "*" na stosie
	sb $s2, 0($sp)
	addiu $sp, $sp, -1
	addiu $s7, $s7, 1
	j compression
	

	
same:
	# zapisanie "-" na stosie
	sb $s3, 0($sp)
	# zabranie jednego bajta 
	addiu $sp, $sp, -1
	addiu $s7, $s7, 1
	addi $s6, $s6, 1 # counter ++
	j compression
	
	
copy:
	# kopiowanie zawartosci stosu do resulta
	lbu $t0, 0($sp)
	addiu $sp, $sp, 1
	beq $t0, '0', end
	sb $t0, result($s0)
	addiu $s0, $s0, 1
	j copy
		
end: 
	# dolaczenie 0 na koniec tablicy czyli tej stopki stosu
	la $a0, result
	move $t0, $v0
	addiu $t1, $zero, '0'
	addiu $sp, $sp, 1
	sb $t1, result($t0)
	
	# pokazanie wiadomosci z zawartoscia stosu
	li $v0, 4
	la $a0, info
	syscall
	
	# sama zawartosc stosu
	li $v0, 4
	la $a0, result
	syscall
	
	
	# pokazanie wiadmosci z iloscia takich samych znakow 
	li $v0, 4
	la $a0, count_msg
	syscall
	
	# pokazanie wyniku countera
	li $v0, 1
	move $a0, $s6
	syscall
	
	# pokozanie wiad z pamiecia 
	li $v0, 4
	la $a0, memory_msg
	syscall
	
	# pokazanie ile pamieci zostalo z zaalokowane 
	li $v0, 1
	subiu $s7, $s7, 1
	move $a0, $s7
	syscall
	
	# koniec programu 
	li $v0, 10
	syscall
	
	
#functions
len:
	move $v0, $zero
	loop_len:
		lb $t0, ($a0)  # Zmiana na lb zamiast lbu
        	beqz $t0, end_fun_len
        	addiu $a0, $a0, 1
        	addiu $v0, $v0, 1
        j loop_len

end_fun_len:
	sub $v0, $v0, 1
	jr $ra
    
swap:
	swap_loop:
		lb $t0, ($a0)
		lb $t1, ($a1)
		
		beqz $t1, end_fun_swap
		
		sb $t0, ($a1)
		sb $t1, ($a0)
		
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		j swap_loop
		
end_fun_swap:
	jr $ra
	
