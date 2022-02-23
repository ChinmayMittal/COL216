.equ SWI_EXIT, 0x18
ldr r1  , =A 
ldr r2  , =B
mov r0 , #1 @@ 1 for case sensetive , 0 for case insensitive 
bl compare 

@@@@printing result to stdin 
mov r4 , r0 @@ result shifted to r4 
mov r0 , #5 @@ code for print 
ldr r3  , =params 
mov r1 , #1    
str r1 , [r3] @@@ 1 for stdout   
str r1 , [r3 , #8] @@@ print 1 byte 
ldr r1 , =disp 
str r1 , [r3 , #4] @@@ address of character to print 
cmp r4 , #0
bge P
mov r4 , #45 @@ ascii of -
strb r4 , [r1]  @@@ store at disp byte 
mov r1 , r3   @@@ load the parameters into r1 
swi 0x123456
mov r0 , #5 @@@ resetting r0 because it is changed by the print
@ swi 0x123456
mov r4 , #1  @@@ for printing 1 after -
ldr r1 , =disp @@@ reloading the disp byte 
P: add r4 , r4 , #48 @@@ conversion to ascii  
strb r4 , [r1]
mov r1,r3
swi 0x123456

@@@exiting the program 
mov r1 , #0 
mov  r0 , #SWI_EXIT
swi 0x123456
compare: cmp r0 , #0 @ checking for mode of comparison if 0 then insensitive else , case sensitive 
         beq  I
         bal S
I:         ldrb r3, [r1] 
           ldrb  r4, [r2]
           cmp r3 , #0 
           beq first_over
           cmp r4 , #0 
           beq more
           mov r7 , #32
           mov r8 , #97
           cmp r8 , r3
           bgt T
           sub r3 , r3 , r7
T:         cmp r8 , r4 
            bgt TE
            sub r4 , r4 , r7 
TE:            add r1,r1,#1
           add r2,r2,#1
           bal I
           mov pc,lr
S:   ldrb r3, [r1]
           ldrb  r4, [r2]
           cmp r3 , #0 
           beq first_over
           cmp r4 , #0 
           beq more
           cmp r3,r4
           blt less
           bgt more
           add r1,r1,#1
           add r2,r2,#1
           bal S
           mov pc,lr

first_over: cmp r4, #0 
            beq equal 
            bal less 

equal: mov r0 , #0 
       mov pc , lr 
less: mov r0 , #-1 
      mov pc , lr
more: mov r0 , #1
      mov pc,lr 

        .data
 A:     .ascii "ccc\0"
 B:     .ascii "bab\0"
 params: .word 0, 0, 0
 disp: .byte 100