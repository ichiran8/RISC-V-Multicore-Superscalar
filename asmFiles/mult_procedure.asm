main: 
    ori $sp, $0, 0xFFFC
    ori $7, $0, 0xFFF8
    li $10, 2
    li $11, 5
    li $12, 6
    li $15, 15
    li $16, 8
    push $10
    push $11
    push $12
    push $15
    push $16

    beq $0, $0, mult

// think about the principle, everytime we use the multiplication algorithm, we are subtracting by 8, and only adding 4 back, which means at some point, we will reach the original stack position, and then we would be done

mult:
    beq $7, $sp, endp

    pop $28
    pop $29
    add $5, $0, $29 # temporary variable for loop control 
    
    add $6, $0, $0
    blt $29, $0, negative
    j loop 
negative:
    neg $5, $5
    j loop
loop: 
    beq $0, $5, endloop # loop control 
    add $6, $6, $28 # multiply in effect
    addi $5, $5, -1 # decrement the loop control variable
    beq $0, $0, loop # loop back

endloop:
    push $6
    beq $0, $0, mult
endp: 
    HALT

##################


