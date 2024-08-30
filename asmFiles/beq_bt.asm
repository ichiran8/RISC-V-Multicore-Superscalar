li $10, 8
li $11, 8

beq $10, $11, end
sw $10, 0x100($11)



halt

end:
    sw $11, 0x100($10)

    halt
