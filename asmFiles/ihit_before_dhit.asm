li $9, 0
li $10, 5
li $11, 8

sw $12, 0x100($0)

for:
    lw $15, 0x100($0)     
    bge $15, $10, end
    addi $15, $15, 1
    sw $15, 0x100($0)
    beq $0, $0, for
end:
    halt
