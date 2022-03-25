mov r1 , #32 
mov r2, #64 
str r2 , [ r1 , #4 ] ! 
strb r2 , [ r1 , #-1] 
ldrsh r3 , [ r1 , #-2 ]  

@ e3a01020
@ e3a02040
@ e5a12004
@ e5412001
@ e15130f2

@ signal MEMORY : MEM := ( 0 => X"e3a01020",
@ 1 => X"e3a02040",
@ 2 => X"e5a12004",
@ 3 => X"e5412001",
@ 4 => x"e15130f2" , 
@ others => X"00000000"

@ ); 