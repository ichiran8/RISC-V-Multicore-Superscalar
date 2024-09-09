li $10, 5
li $11, 8

bne $10, $11, end
sw $11, 0x100($10)

halt

end:
    sw $10, 0x100($11)
    halt
