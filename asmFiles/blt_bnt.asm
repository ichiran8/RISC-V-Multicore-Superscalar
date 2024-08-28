li $10, -8
li $11, -5

blt $10, $11, end

mv $12, $10

halt

end:
    mv $12, $11
    halt
