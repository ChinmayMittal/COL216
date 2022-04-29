mov r1 , #10 
mov r2 , #32 
mul r3 , r1 , r2 
mov r4 , #40
mov r5 , #28 
umlal r5 , r4 , r3 , r2  

@ e3a0100a
@ e3a02020
@ e0030291
@ e3a04028
@ e3a0501c
@ e0a45293

@ signal MEMORY : MEM := ( 0 => X"e3a0100a",
@ 1 => X"e3a02020",
@ 2 => X"e0030291",
@ 3 => X"e3a04028",
@ 4 => x"e3a0501c" , 
@ 5 => x"e0a45293" , 
@ others => X"00000000"

@ ); 