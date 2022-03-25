mov r1 , #128
mov r2 , #32 
str r1 , [ r2 ]
ldrsb r1 , [ r2 ] 

@ e3a01080
@ e3a02020
@ e5821000
@ e1d210d0

@ signal MEMORY : MEM := ( 0 => X"e3a01080",
@ 1 => X"e3a02020",
@ 2 => X"e5821000",
@ 3 => X"e1d210d0",
@ others => X"00000000"
@ );