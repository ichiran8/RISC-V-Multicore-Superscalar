li $10, 5
li $11, 8

bne $10, $11, end

mv $12, $10

halt

end:
    mv $12, $11
    halt
