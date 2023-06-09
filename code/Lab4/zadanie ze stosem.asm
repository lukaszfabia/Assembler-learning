.data
buffer1: .space 20   # Bufor dla pierwszego tekstu
buffer2: .space 20    # Bufor dla drugiego tekstu
result: .space 20     # Bufor dla wyniku
prompt1: .asciiz "Podaj pierwszy tekst: "
prompt2: .asciiz "Podaj drugi tekst:    "
count_msg: .asciiz "\nLiczba jednakowych znakow: "
memory_msg: .asciiz "\nZaalokowana pamiec na stosie:" 
info: .asciiz "Zawartosc stosu - wypisana wg. lifo: "
prompt3: .asciiz "\nPodaj najpierw dluzszy tekst potem krotszy\n"

.text
main:
	# prompt3 
	li $v0, 4
	la $a0, prompt3
	syscall
	
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
length_of_first:
	# wyznaczenie dlugosci pierwszego ciagu
	lbu $t0, buffer1($s1)
	beqz $t0, length_of_sec
	addiu $s1, $s1, 1
	j length_of_first
	
	
length_of_sec:
	# wyznaczenie dlugosci drugiego ciagu
	lbu $t0, buffer2($s0)
	beqz $t0, continue
	addiu $s0, $s0, 1
	j length_of_sec
	

continue:
	# podaj pierwszy ciag dluzszy niz drugi
	blt $s1, $s0, main
	# korekta na indeksy 
	subiu $s1, $s1, 1 # dla pierwszego 
	subiu $s0, $s0, 1 # dla drugiego 
	
	addiu $s2, $zero, '*' # rozne 
	addiu $s3, $zero, '-' # te same 
	
	# dodanie '0' na stack dlaczego dlatego ze to bedzie stopka stosu bo jesli bysmy chcieli 
	# sczytywac tak jak w tablicy to tam nie ma 0 tylko wskoczy nam stack overflow 
	addiu $s4, $zero, '0'
	sb $s4, 0($sp)
	addiu $sp, $sp, -1
	addiu $s7, $s7, 1
	move $s4, $zero
	
	
compression:
	lbu $t1, buffer1($s1)
	lbu $t2, buffer2($s0)

	# powinno brac ten ktory sie szybciej konczy 
	#beqz $t1, copy # nie dzila 
	beqz $t2, copy # dziala gdy gdy buffer1>buffer2
	
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
	j compression
	
	
	move $s0, $zero
	move $s1, $zero
copy:
	# kopiowanie zawartosci stosu do resulta
	lbu $t0, 0($sp)
	addiu $sp, $sp, 1
	beq $t0, '0', end
	sb $t0, result($s0)
	addiu $s0, $s0, 1
	j copy
		
end: 
	# pokazanie wiadomosci z zawartoscia stosu
	li $v0, 4
	la $a0, info
	syscall
	
	move $s0, $zero
	
len_res:
	# wyznaczenie dlugosci ciagu znakowego
	lbu $t0, result($s0)
	beqz $t0, next
	addiu $s0, $s0, 1
	j len_res

next:
	subiu $s0, $s0, 2 # <= dlugosc tablicy -2 
	move $s1, $zero # zmienna do przechowania ilosci "-"
	move $s3, $zero # wskaźnik do poruszania sie w tablicy
	addiu $s4, $zero, '-'
result_loop:
	bgt $s3, $s0, print_info # i<= len(res)-2
	lbu $t0, result($s3)
	beq $t0, $s4, counter # jesli element w tablicy jest '-' to inkrementujemy zmienna od takich samych
	print:
	# pokazanie zawartosci stosu wg. lifo
	li $v0, 11
	move $a0, $t0
	syscall
	
	addiu $s3, $s3, 1 # przesuwamy sie po tablicy
	j result_loop
	
counter: 
	addiu $s1, $s1, 1 
	j print
	
print_info:	
	# pokazanie wiadmosci z iloscia takich samych znakow 
	li $v0, 4
	la $a0, count_msg
	syscall
	
	# pokazanie wyniku countera
	li $v0, 1
	move $a0, $s1
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
