mov r1 , #2
mov r2 , #12 
mov r3 , #1  
str r1 , [ r2 , r3 , LSL #4  ]
ldr r5 , [ r2 , r3 , LSL #4 ]

@ e3a01002
@ e3a0200c
@ e3a03001
@ e7821203
@ e7925203

@ signal MEMORY : MEM := ( 0 => X"e3a01002",
@ 1 => X"e3a0200c",
@ 2 => X"e3a03001",
@ 3 => x"e7821203" , 
@ 4 => x"e7925203" , 
@ others => X"00000000"
@ ); 