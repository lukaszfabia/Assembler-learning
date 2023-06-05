# registers
# $t0 - type of operation
# $t1 - key
# $t2 - input string


.data
	key: .space 9
	key_values: .space 9
	input: .space 51
	fixed_input: .space 51
	ciphered_output: .space 51
	offset_part: .space 9
	msg_which: .asciiz "Ktora operacje wykonac: (S) szyfrowanie, (D) deszyfrowanie: "
	msg_d: .asciiz "\nPodaj dlugosc klucza (max 8 cyfr): "
	msg_key: .asciiz "Podaj klucz przeksztalcenia zawierajacy cyfry z przedzialu od 1 do 8: "
	msg_text_for_s: .asciiz "Podaj tekst jawny: "
	msg_text_for_d: .asciiz "Podaj kryptogram: "
	msg_text: .asciiz "\nPodaj tekst to szyfrowania/deszyfrowania: "
	msg_type_error: .asciiz "\nNieprawidlowy typ operacji"
	msg_cipher: .asciiz "Zakodowany tekst: "
	msg_decipher: .asciiz "Zdekodowany tekst: "
	newline: .asciiz "\n"
.text

	main:
	
	# registers
	# t0 - "D"
	# t1 - "S"
	# s0 - input
	input_type:
		# pokazanie wiadomosci z wyborem
		li $v0, 4
		la $a0, msg_which
		syscall
		
		li $v0, 12
		syscall
		
		move $s6, $v0 # zapamietanie wartosci w rejestrze staĹ‚ym 
		
		beq $s6, 'D', input_key
		beq $s6, 'S', input_key
		
		b input_type
		
	# registers
	# s1 - key
	input_key:
		# pokazanie wiadomosci z dlugoscia klucza
		li $v0, 4
		la $a0, msg_d
		syscall
		
		li $v0, 5
		syscall
		
		move $s7, $v0 # zapamietanie wartosci d w s7
		
		# wydrukowanie i wczytanie klucza jako ciagu 
		li $v0, 4
		la $a0, msg_key
		syscall
		
		li $v0, 8 # wywolanie systemowe
		la $a0, key # adres bufora 
		li $a1, 9
		syscall
		
		la $s1, key # zapamietuyjemy sobie key w s1
		
		beq $s6, 'D', input_text_d
		beq $s6, 'S', input_text_s
		
	input_text_d:
		li $v0, 4
		la $a0, msg_text_for_d
		syscall
		j end_of_input_text
		
		
	input_text_s:
		li $v0, 4
		la $a0, msg_text_for_s
		syscall


	end_of_input_text:	
		li $v0, 8 # wywolanie systemowe
		la $a0, input # adres bufora 
		li $a1, 50
		syscall
		
		# wyzerowanie stalych rejestrow 
		move $s2, $zero
		move $s3, $zero
		
	# naprawa stringa 	
	fix_input_loop:
		# A-Z <=>[65, 90]
		lb $t0, input($s2)
    		beqz $t0, end_loop # jesli jest koniec ciagu
    
    		blt $t0, 'A', skip  # jesli mamy znaki <65  
    		bgt $t0, 'z', skip  # jesli mamy znaki >122
    
    		blt $t0, 'a', copy  # jesli mamy duze litery to dodajemy do nowego ciagu  
    		#bgt $t0, 'z', skip
    		sub $t0, $t0, 32    # reszte naprawiamy bo sa nimi male litery 
    		
    	copy:
    		sb $t0, fixed_input($s3) # przechowujemy bajt z $t0
    		addi $s3, $s3, 1 # przesuwamy sie o 1 bajt w starym stringu 
	
	
	skip:
		addiu $s2, $s2, 1 # przesuwamy sie o 1 bajt w nowym 
		j fix_input_loop
	
	end_loop:
		sb $zero, fixed_input($s3)
		la $s2, fixed_input # ladujemy sobie adres nowego str do s2
	
	
	
	load_key:
		move $s2, $zero
		move $s3, $zero
	new_key:
		# ladujemy pierwszy ind tego ciagu 
		lb $t0, key($s2)
		# gdy jest koniec ciagu 
		beqz $t0, end_new_key
		# key[i]-1 w ascii 49 to jest 1 to bedzie ind nowy 
		subiu $t0, $t0, 49
		# przsuwamy klucz o jenda liczbe w tym kluczu z inputa 
		addiu $s2, $s2, '0'
		# zapis wartosci w nowej tablicy na $t0 indeksie 
		sb $s2, key_values($t0)
		# zerowanie $t0
		addiu $t0, $t0, '0'
		# ustawienie znaku 0 na s2 
		subiu $s2, $s2, '0' 
	increment:
		# przesuniecie sie w tablicy o 1 pozyzcje 
		addiu $s2, $s2, 1
		j new_key
	
	
	end_new_key:
		# wyzerowanie stalych rejestrów 
		move $s2, $zero
		move $s3, $zero
		
	cipher_main_loop:
		#wyzerowanie s4 
		move $s4, $zero
		# odczytujemy s3 zapisane pod koniec petli w celu przesuniecia sie o d znakow w ciagu
		addu $s5, $s3, $s7
		#sprawdzenie czy dokladnie 4 znak nie jest zerem 
		subu $s5, $s5, 1 
		# odczytujemy znak z stringa z ind d na poczatek 
		lb $t4, fixed_input($s5)
		# gdy jest koniec tego strigna 
		beqz $t4, copy_rest
		inside_loop:
			# gdy przesunelismy sie w tablicy o d miejsc 
			beq $s4, $s7, c_next
			# ladujemy znak z ind s2 ze str 
			lb $t0, fixed_input($s2)
			# jesli jest 0 to wychodzimy z 2 petli 
			beqz $t0, output_cipher
			# ladujemy sobie pierwsza wartosci z nowego klucza
			lb $t1, key_values($s4)
			# korekta ind 
			subiu $t1, $t1, '0'
			# key[i]-1
			addu $t2, $s3, $t1
			# zapisany znak w $t0 dodajemy na ind $t2 
			sb $t0, ciphered_output($t2)
			# inkrementuejmy tablice fixed input 
			addiu $s2, $s2, 1
			# inkrementuejmy nowy klucz
			addiu $s4, $s4, 1
			j inside_loop
		c_next:	
			# zapisanie w s3 s7 ktore potem uzyjemy	
			addu $s3, $s3, $s7
			j cipher_main_loop
		copy_rest:
			#nowe jesli s2 jest rowne d to wracamy sie do petli main bo chcemy kodowac d(*)textd(*) etc.
			beq $s2, $s7, cipher_main_loop  
			# zaladowanie stringa na s2 ind 
			lb $t0, fixed_input($s2)
			# gdy jest koniec znakow
			beqz $t0, output_cipher
			# zapisanie znaku w nowej tablicy 
			sb $t0, ciphered_output($s2)
			# przesuniecie sei w tablicy o 1 bajt
			addiu $s2, $s2, 1
			j copy_rest
	
	choose_output:
		beq $s6, 'S', output_cipher
		beq $s6, 'D', output_decipher
	
	ans_for_s:
		li $v0, 4
		la $a0, msg_cipher
		syscall
		j final_ans
				
	ans_for_d:
		li $v0, 4
		la $a0, msg_decipher
		syscall
		j final_ans
		
	final_ans:
		li $v0, 4
		la $a0, ciphered_output
		syscall
		
		j finish		

	
	finish:
		li $v0, 10
		syscall
	
