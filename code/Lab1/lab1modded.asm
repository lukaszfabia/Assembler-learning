.data 
star : .asciiz "*"
prompt: .asciiz "Podaj liczbe: "
.text
main:
	# wczytanie liczby
    	li $v0, 4           # wywo³anie systemowe dla drukowania ³añcucha
    	la $a0, prompt      # adres ³añcucha (etykieta prompt)
    	syscall
    	
    	li $v0, 5           # wywo³anie systemowe dla wczytania liczby ca³kowitej
    	syscall
    	move $t1, $v0       # przypisanie wczytanej liczby do $t1

	addi $t0, $zero, 0 # int i=0
while:
	beqz $t1, exit # dzia³aj az to co jest w t1 nie bedzie 0 
	div $t1, $t1, 10 # number / = 10
	# wypisanie gwiazdki
	li $v0, 4
	la $a0, star
	syscall
	addi $t0, $t0, 1 # i++
	j while # skaczemy do while dopoki nasz if nie przerwie 

exit:
	li $v0, 10
	syscall