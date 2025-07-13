li $10, 5
li $11, 8
li $15, 16

sw $10, 0x100($11)
jal $12, end

sw $11, 0x100($11)


end:
    sw $12, 0x100($15)
    lw $17, 0x100($15)
    add $17, $17, $12
    halt

org 0x200
halt