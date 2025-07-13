// assume x10 is current days, current month is x11, x12 is current year, and x15 is days
count: 
    ori $sp, $0, 0xFFFC
    li $10, 16
    li $11, 8
    li $12, 2024

    addi $11, $11, -1 // current month - 1

    li $7, 30 // 30

    push $11
    push $7

    jal mult // 30 * (current day - 1)

    pop $15 // value is stored here

    addi $12, $12, -2000

    li $7, 365
    push $12
    push $7

    jal mult // 365 * (current year - 200)

    pop $30

    add $15, $15, $30

    add $15, $15, $10

    push $15

    HALT // return the program 

mult:
    pop $28 // I t hink stack uses last in first out
    pop $29

    add $5, $0, $29 # temporary variable for loop control 
    li $6, 0
    blt $29, $0, negative
    j loop 
negative:
    neg $5, $5
    j loop
loop: 
    beq $0, $5, end # loop control 
    add $6, $6, $28 # multiply in effect
    addi $5, $5, -1 # decrement the loop control variable
    j loop # loop back
end:
    push $6
    ret

##################


org 0x200
halt
