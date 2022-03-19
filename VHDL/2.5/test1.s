mov r1, #1
mov r2, #3
add r3 , r1 , r2 , LSL #3

@ e3a01001
@ e3a02003
@ e0813182

@ signal MEMORY : MEM := ( 0 => X"e3a01001",
@ 1 => X"e3a02003",
@ 2 => X"e0813182",
@ others => X"00000000"
@ ); 