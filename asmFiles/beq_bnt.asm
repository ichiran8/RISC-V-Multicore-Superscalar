li $10, 5
li $11, 8


beq $10, $11, end
sw $10, 0x100($11)

mv $12, $10

halt

end:
    mv $12, $11
    sw $11, 0x100($11)
    halt
