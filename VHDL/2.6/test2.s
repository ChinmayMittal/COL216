mov r2 , #32 
mov r5 , #32  
str r5 , [ r2 ] ,  #4
ldrh r3 , [ r5 , #2 ]

@ e3a02020
@ e3a05020
@ e4825004
@ e1d530b2

@ signal MEMORY : MEM := ( 0 => X"e3a02020",
@ 1 => X"e3a05020",
@ 2 => X"e4825004",
@ 3 => X"e1d530b2",
@ others => X"00000000"

@ ); 