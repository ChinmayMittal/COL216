.equ SWI_EXIT, 0x18

@@@@@@ taking user input through prompts @@@@@@
ldr r2 , =p
bl print
ldr r2  , =read @inputspace for first string 
bl readChar
ldr r2 , =n
bl print
ldr r2 , =xyz  @ input space for second string 
bl readChar
ldr r2 , =m 
bl print
ldr r2 , =mode @@ reads mode 0/1
bl readChar
ldr r1  , =read
ldr r2  , =xyz
ldr r0 , =mode 
ldrb r0 , [r0]
cmp r0 , #'0
bne H
mov r0 , #0 @@ 1 for case sensetive , 0 for case insensitive 
bl compare 
bal z
H: mov r0 , #1
bl compare 
@@@@@@ XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX @@@@@@

@@@@printing result to stdin @@@@@@@ 
z: mov r4 , r0 @@ result shifted to r4 
cmp r4 , #1 
bne zero
ldr r2 , =s
bl print
bal exit
zero: cmp r4 , #0
bne minus
ldr r2 , =e
bl print 
bal exit 
minus: ldr r2 , =f
bl print
@@@exiting the program @@@@@
exit:  mov r1 , #0 
mov  r0 , #SWI_EXIT
swi 0x123456
@@@@@@@@@@@@@@@@@@@@@@@@@@@@
compare: cmp r0 , #0 @ checking for mode of comparison if 0 then insensitive else , case sensitive 
         beq  I
         bal S
I:         ldrb r3, [r1] 
           ldrb  r4, [r2]
           cmp r3 , #0 
           beq first_over
           cmp r4 , #0 
           beq more
           cmp  r3 , #97
           blt T
           sub r3 , r3 , #32
T:         cmp r8 , r4 
            bgt TE
            sub r4 , r4 , #32 
TE:          cmp r3,r4
           blt less
           bgt more
            add r1,r1,#1
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
@@@@@@@@@@@@@@@@@@@@@@@@
readChar : mov r0 , #6 @@ read CODE
ldr r3, =params 
mov r1 , #0   
str r1 , [r3] @@@ 0 for stdin  
mov r1 , #1 
str r1 , [r3 , #8] @@@ read 1 byte   
str r2 , [r3 , #4]
mov r1,r3
swi 0x123456
ldrb r3 , [r2]
add r2 , r2 , #1
cmp r3 , #13
bne readChar
mov r3 , #0
sub r2 , r2 , #1
strb r3 , [r2 ]
ldrb r3 , [r2]
mov pc, lr
@@@@@@@@@@@@@@@@@@@@@@@@@@
print: mov r0 , #5 
ldr r3, =params 
mov r1 , #1
str r1 , [r3]
str r1 , [r3 ,#8]
str r2 , [r3 , #4]
mov r1 , r3
ldrb r4 , [r2]
cmp r4 , #0 
beq K
swi 0x123456
add r2 , r2 , #1
bal print
K: mov pc , lr 
        .data
    params: .word 0, 0, 0
    disp: .byte 100
    xyz: .space 100
    read: .space 100
    mode: .space 4
    p:  .ascii "enter first string followed by [enter]:\0"
    n: .ascii "enter second string followed by [enter]:\0:"
    m:  .ascii "enter mode 0(case insensitive)/1(case sensitive) followed by [enter]:\0"
    f:  .ascii "first string is smaller than the second string\0"
    e:  .ascii "first string is equal to the second string\0"
    s:  .ascii "first string is larger than the second the string \0"