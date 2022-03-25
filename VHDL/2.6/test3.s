mov r1 , #32
mov r2 , #288 
strh r2 , [ r1 ]
strh r2 , [ r1 , #2 ]
ldr r3 , [ r1 ]
ldrb r3 ,   [ r1 , #1]  

@ e3a01020
@ e3a02e12
@ e1c120b0
@ e1c120b2
@ e5913000
@ e5d13001

@ signal MEMORY : MEM := ( 0 => X"e3a01020",
@ 1 => X"e3a02e12",
@ 2 => X"e1c120b0",
@ 3 => X"e1c120b2",
@ 4 => x"e5913000" , 
@ 5 => x"e5d13001" , 
@ others => X"00000000"
@ ); 