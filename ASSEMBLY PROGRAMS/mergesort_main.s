.equ SWI_EXIT, 0x18
.extern input_number
.extern output_number
.extern output_new_line
.extern merge_sort 
.text
@@@@@@GET LENGTH OF INPUT LIST @@@@@@@@@@@@@@@
ldr r2 , =input_prompt1
bl print
bl input_number 
mov r7 , r0  @@@ storing list length in r7 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@ READING FIRST LIST IN A @@@@@@@@@@@@@
ldr r1 , =A @@@ to store the list of pointers 
ldr r2 , =A_string @@@ to store the strings itself
bl read_list
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@ GETTING MODE OF COMPARISON @@@@@@@@@
ldr r2 , =input_prompt3
bl print 
bl input_number
str r0 , [sp,#-4]! @@@ preserving it on stack 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@ GETTING DUPLICATE REMOVAL TOKEN @@@@@@@@@
ldr r2 , =input_prompt4
bl print 
bl input_number
str r0 , [sp,#-4]! @@@ preserving it on stack 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
ldr r1 , =A @@@  list 
mov r2 , r7  @@@@ length of  list 
ldr r4 , [sp] @@@ restoring duplicate token 
add sp , sp ,#4
ldr r3 , [sp] @@@ restoring mode of comparison 
add sp , sp , #4
bl merge_sort @@@ returns the sorted list in r1 and the length in r2 
str r1 , [sp,#-4]!  @@@ preserving r2 and r1 on the stack 
str r2 ,  [sp,#-4]!
mov r7 , r2 @@@ length of the sorted list 
ldr r2 , =output_prompt2
bl print
mov r0 , r7
bl output_number
bl output_new_line
ldr r2 , =output_prompt
bl print 
ldr r2 , [sp]
add sp , sp  , #4
ldr r1 , [sp]
add sp , sp  , #4
@@@@ we require the starting address and the length of the output list to print the answer ( sorted strings )
mov r0 , r1
mov r1 , r7@@ length of output , from r7 
print_ans: cmp r1 , #0 @@@ length of output remaining 
      beq exit  
      ldr r2 , [r0]  @@@ address of string to print 
      str r0, [sp,#-4]!
      str r1, [sp,#-4]!
      bl print 
      ldr r2 , =space
      bl print
      ldr r1 , [sp]
      add sp , sp , #4 
      ldr r0 , [sp]
      add sp , sp , #4
      add r0 , r0 , #4
      sub r1 , r1 , #1 @@@ one less string left to print 
      bal print_ans


@@@exiting the program @@@@@
exit:  mov r1 , #0 
mov  r0 , #SWI_EXIT
swi 0x123456
@@@@@@@@@@@@@@@@@@@@@@@@@@@
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
@@@@@@@@@@@@@
@@@2  r0 for numbers , r1 address of list pointer , r2 string pool  
read_list:
      cmp r0 , #0 
      moveq pc , lr 
      str r2 , [r1] @@@ starting address of string 
      add r1 , r1 , #4  @@@ to store next string 
      str lr, [sp,#-4]!
      str r0, [sp,#-4]!
      str r1, [sp,#-4]!
      str r2, [sp,#-4]!
      bl readChar
      @ ldr r2 , [sp] @@@ read char maintains r2 at required position 
      add sp , sp , #4 
      ldr r1 , [sp]
      add sp , sp , #4 
      ldr r0 , [sp]
      add sp , sp , #4 
      ldr lr , [sp]
      add sp , sp , #4 
      sub r0 , r0 , #1 
      bal read_list 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@ expects address to store string in r2 
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
add r2 , r2 , #1
mov pc, lr
@@@@@@@@@@@@@@@@@@@@@
.data
params: .word 0, 0, 0
A:  .space 200 
A_string:  .space 500 
C:  .space 200 
input_prompt1:  .ascii "Please enter the length of the list, followed by the strings , one in each line\n\0"
output_prompt: .ascii "The sorted list: \0"
output_prompt2:  .ascii "The length of the sorted list: \0"
input_prompt3:  .ascii "Enter the mode of comparison (0 (case insensitive) / 1 (case sensitive)): \0"
input_prompt4:  .ascii "Enter the 1(remove duplicates) / 0( don't remove duplicates): \0"
space: .ascii " \0"
.end