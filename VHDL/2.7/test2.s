mvn r1 , #1
mov r2 , #2 
umull r3 , r4 , r1 , r2 
smull r3 , r4 , r1 , r2    

@ e3e01001
@ e3a02002
@ e0843291
@ e0c43291

@ signal MEMORY : MEM := ( 0 => X"e3e01001",
@ 1 => X"e3a02002",
@ 2 => X"e0843291",
@ 3 => X"e0c43291",
@ others => X"00000000"

@ ); 