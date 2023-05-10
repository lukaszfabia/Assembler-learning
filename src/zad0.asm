#simple program with two "voids" sub, sum

.data
number1: .word 12
number2: .word 23
space: .asciiz "\n"

.text
main:
   jal sum	
   li $v0, 4  # changed v1 to v0 to print message
   la $a0, space  # changed a2 to a0 to load the message
   syscall
   jal subtraction

    # exit program
    li $v0, 10 
    syscall

# function to add two numbers
sum: 
    # load values of number1 and number2 into $t0 and $t1
    lw $t0, number1
    lw $t1, number2

    # add the values in $t0 and $t1 and store the result in $a0
    add $a0, $t0, $t1

    # print the value of $a0
    addi $v0, $zero, 1
    syscall

    # return from function
    jr $ra
	
# function to subtract two numbers
subtraction: 
    # load values of number1 and number2 into $t0 and $t1
    lw $t0, number1
    lw $t1, number2

    # subtract the value of $t1 from $t0 and store the result in $a0
    sub $a0, $t0, $t1

    # print the value of $a0
    addi $v0, $zero, 1
    syscall

    # return from function
    jr $ra
