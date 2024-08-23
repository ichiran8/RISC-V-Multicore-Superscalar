org 0x000
mult:
    ori $sp, $0, 0xFFFC
    li $10, 5
    li $11, 58
    push $10
    push $11

    pop $11 // I t hink stack uses last in first out
    pop $10

    add $5, $0, $11 # temporary variable for loop control 
    li $6, 0
    blt $11, $0, negative
    j loop 
negative:
    neg $5, $5
    j loop
loop: 
    beq $0, $5, end # loop control 
    add $6, $6, $10 # multiply in effect
    addi $5, $5, -1 # decrement the loop control variable
    j loop # loop back
end:
    push $6
    HALT

##################

