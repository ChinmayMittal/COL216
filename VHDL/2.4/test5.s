@@ check if power of two
mov r1 , #4
movs r0, r1 
beq out 
sub r2, r1, #1 
ands r2, r1, r2 
movne r0, #0
moveq r0, #1
out:

