li $10, 8

li $11, 5


li $16, 1000 # for loop limit

add $12, $11, $10

sw $12, 0x100($0)
LOOP:
    lw $15, 0x100($0)     
    
    bge $15, $16, END # we check if it is greater than or equal to 
    
    add $15, $15, $10 # add 8 to the loaded value

    sub $15, $15, $11

    sw $15, 0x100($0)

    beq $0, $0, LOOP

END:

    HALT

org 0x200
halt