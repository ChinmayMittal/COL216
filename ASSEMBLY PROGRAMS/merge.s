.equ SWI_EXIT, 0x18
.extern input_number
.extern output_number
.extern output_new_line
.text
@@@@@@GET LENGTH OF FIRST LIST @@@@@@@@@@@@@@@
ldr r2 , =input_prompt1
bl print
bl input_number 
mov r7 , r0  @@@ storing first list length in r7 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@ READING FIRST LIST IN A @@@@@@@@@@@@@
ldr r1 , =A @@@ to store the list of pointers 
ldr r2 , =A_string @@@ to store the strings itself
bl read_list
@@@@@@GET LENGTH OF SECOND LIST @@@@@@@@@@@@@@@
ldr r2 , =input_prompt2
bl print
bl input_number
mov r8 , r0  @@@ storing first list length in r7 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@READING SECOND LIST IN B  @@@@@@@@@@@@@@@@
ldr r1 , =B @@@ to store the list of pointers 
ldr r2 , =B_string @@ to store the strings itself
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
ldr r1 , =A @@@ first list 
ldr r2 , =B @@@ second list 
mov r3 , r7  @@@@ length of first list 
mov r4 , r8 @@@ lenght of second list 
ldr r0 , =C  @@@ output list 
ldr r6 , [sp] @@@ restoring duplicate token 
add sp , sp ,#4
ldr r5 , [sp] @@@ restoring mode of comparison 
add sp , sp , #4
bl merge_main
ldr r2 , =output_prompt2
bl print
mov r0 , r7
bl output_number
bl output_new_line
ldr r2 , =output_prompt
bl print 

@@@@ we require the starting address and the lenght of the output list to print the answer 
ldr r0 , =C 
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
@@@@@ merge r0 => address of store , r1 => address of first list , r2 => address of second list , r3 => len of first list , r4 => length of second list , r5 => mode of comparison , r6 => remove duplicates , r7 => strings count in ans 
merge_main:  mov r7 , #0 
merge:  cmp r3 , #0 @@@ checking for length of first list 
       beq first_list_left
       cmp r4 , #0  @@@@ checking for length of second left 
       beq first_list_left
       @@@@@ preserving lr , r0 -> r7 
       str lr, [sp,#-4]!
       str r0, [sp,#-4]!
       str r1, [sp,#-4]!
       str r2, [sp,#-4]!
       str r3, [sp,#-4]!
       str r4, [sp,#-4]!
       str r5, [sp,#-4]!
       str r6, [sp,#-4]!
       str r7, [sp,#-4]!
       @@@@@@@@@@@@@@@@@@@@
       mov r0 , r5  @@ mode for compare 
       ldr r1 , [r1] @@@ getting string address from list address
       ldr r2 , [r2] @@@@ gettting string address from list address
       bl compare 
       mov r9 , r0 @@@ moving the result to r9 
       @@@@@ restoring , r7 -> r0  , lr 
       ldr r7 , [sp] 
       add sp , sp  , #4 
       ldr r6 , [sp] 
       add sp , sp  , #4 
       ldr r5 , [sp] 
       add sp , sp  , #4 
       ldr r4 , [sp] 
       add sp , sp  , #4 
       ldr r3 , [sp] 
       add sp , sp  , #4        
       ldr r2 , [sp] 
       add sp , sp  , #4 
       ldr r1 , [sp] 
       add sp , sp  , #4 
       ldr r0 , [sp] 
       add sp , sp  , #4 
       ldr lr , [sp ] 
       add sp , sp , #4 
       @@@@@ @@@@@ @@@@@ @@@@@ 
       cmp r6 , #1
       beq remove_duplicate @@@ handle this case seperately 
back_from_duplicate_handler: 
       str r5, [sp,#-4]! @@@ preserving mode of comparison 
       str r6, [sp,#-4]! @@@ preserving r6 
       ldr r5 , [r1] @@@@ first list's  string address 
       ldr r6 , [r2]  @@@@ second list's string address
       cmp r9 , #1
       bne first_string
       str r6 , [r0]  @@@ push address to r0 
       ldr r6, [sp] @@@ restoring r6  
       add sp , sp  , #4 
       ldr r5 , [sp] @@@ restoring mode of comparison 
       add sp , sp  , #4 
       add r0 , r0 , #4 @@@ update string list ans pointer
       add r7 , r7 , #1 @@@ length of outputlist  
       sub r4 , r4 , #1 @@@ one string done 
       add r2 , r2 , #4  @@@ move to the next string in the list 
       bal merge 
first_string: str r5 , [r0]
              ldr r6, [sp] @@@ restoring r6  
              add sp , sp  , #4 
              ldr r5 , [sp] @@@ restoring mode of comparison 
              add sp , sp  , #4 
              add r0 , r0 , #4  @@@ update string list ans pointer
              add r7 , r7 , #1 @@@ length of outputlist 
              sub r3 , r3 , #1
              add r1 , r1 , #4
              bal merge 
remove_duplicate:        
       cmp r7 , #0 
       beq back_from_duplicate_handler @@@ since no list is inserted proceed as normal 
       @@@@@ preserving lr , r0 -> r5 
       str lr, [sp,#-4]!
       str r0, [sp,#-4]!
       str r1, [sp,#-4]!
       str r2, [sp,#-4]!
       str r3, [sp,#-4]!
       str r4, [sp,#-4]!
       str r5, [sp,#-4]!
       str r6, [sp,#-4]!
       str r7, [sp,#-4]!
       @@@@@@@@@@@@@@@@@@@@
       cmp r9 , #1
       beq second_string_duplicate @@@ second string is to be inserted and duplicates to be handled 
       @@@@ first  string is placed if it is not equal to previously placed string
        
       ldr r1 , [r1]
       ldr r2 , [ r0, #-4] @@@ previous string
       mov r0 , r5  @@ mode for compare 
       bl compare 
       mov r9 , r0 @@@ moving result to r0 
       @@@@@ restoring , r7 -> r0  , lr @@@@@@@
       ldr r7 , [sp] 
       add sp , sp  , #4 
       ldr r6 , [sp] 
       add sp , sp  , #4 
       ldr r5 , [sp] 
       add sp , sp  , #4 
       ldr r4 , [sp] 
       add sp , sp  , #4 
       ldr r3 , [sp] 
       add sp , sp  , #4        
       ldr r2 , [sp] 
       add sp , sp  , #4 
       ldr r1 , [sp] 
       add sp , sp  , #4 
       ldr r0 , [sp] 
       add sp , sp  , #4 
       ldr lr , [sp ] 
       add sp , sp , #4 
       @@@@@ @@@@@ @@@@@ @@@@@ 
       cmp r9 , #0 
       bne place_first_String
       @@@ don't place first string   
       sub r3 , r3 , #1
       add r1 , r1 , #4
       bal merge 
place_first_String: 
       ldr r9 , [r1]   
       str r9 , [r0]
       add r0 , r0 , #4  @@@ update string list ans pointer
       add r7 , r7 , #1 @@@ length of outputlist 
       sub r3 , r3 , #1
       add r1 , r1 , #4
       bal merge            
second_string_duplicate: @@@ second string is placed if it is not equal to previously placed string 
        
        ldr r1 , [r2]
        ldr r2 , [r0,#-4] @@@ previous string
        mov r0 , r5  @@ mode for compare 
       bl compare 
       mov r9 , r0 @@@ moving result to r0 
       @@@@@ restoring , r7 -> r0  , lr @@@@@@@
       ldr r7 , [sp] 
       add sp , sp  , #4 
       ldr r6 , [sp] 
       add sp , sp  , #4 
       ldr r5 , [sp] 
       add sp , sp  , #4 
       ldr r4 , [sp] 
       add sp , sp  , #4 
       ldr r3 , [sp] 
       add sp , sp  , #4        
       ldr r2 , [sp] 
       add sp , sp  , #4 
       ldr r1 , [sp] 
       add sp , sp  , #4 
       ldr r0 , [sp] 
       add sp , sp  , #4 
       ldr lr , [sp ] 
       add sp , sp , #4 
       @@@@@ @@@@@ @@@@@ @@@@@ 
       cmp r9 , #0 
       bne place_second_String
       @@@ don't place second string   
       sub r4 , r4 , #1
       add r2 , r2 , #4
       bal merge                
place_second_String: 
       ldr r9 , [r2]   
       str r9 , [r0]
       add r0 , r0 , #4  @@@ update string list ans pointer
       add r7 , r7 , #1 @@@ length of outputlist 
       sub r4 , r4 , #1
       add r2 , r2 , #4
       bal merge        
first_list_left:  cmp  r3 , #0
                  beq second_list_left
                  cmp r6 , #1
                  beq first_list_left_duplicates @@@ handle duplicate insertion and remaining elements of first list 
back_to_first_list_left:         @@@@ normal insertion of first list's string      
                  ldr r8 , [r1] @@@@ load string address 
                  str r8 , [r0] @@@@@ send it to answer list 
                  add r0 , r0 , #4
                  add r7 , r7 , #1
                  add r1 , r1 , #4
                  sub r3 , r3 , #1
                  bal first_list_left
first_list_left_duplicates:
                  cmp r7 , #0 
                  beq back_to_first_list_left
                  @@@@@ preserving lr , r0 -> r7 
                  str lr, [sp,#-4]!
                  str r0, [sp,#-4]!
                  str r1, [sp,#-4]!
                  str r2, [sp,#-4]!
                  str r3, [sp,#-4]!
                  str r4, [sp,#-4]!
                  str r5, [sp,#-4]!
                  str r6, [sp,#-4]!
                  str r7, [sp,#-4]!
                  @@@@@@@@@@@@@@@@@@@@
                  
                  ldr r1 , [r1]
                  ldr r2 , [ r0, #-4] @@@ previous string
                  mov r0 , r5  @@ mode for compare 
                  bl compare 
                  mov r9 , r0 @@@ moving result to r0 
                  @@@@@ restoring , r7 -> r0  , lr @@@@@@@
                  ldr r7 , [sp] 
                  add sp , sp  , #4 
                  ldr r6 , [sp] 
                  add sp , sp  , #4 
                  ldr r5 , [sp] 
                  add sp , sp  , #4 
                  ldr r4 , [sp] 
                  add sp , sp  , #4 
                  ldr r3 , [sp] 
                  add sp , sp  , #4        
                  ldr r2 , [sp] 
                  add sp , sp  , #4 
                  ldr r1 , [sp] 
                  add sp , sp  , #4 
                  ldr r0 , [sp] 
                  add sp , sp  , #4 
                  ldr lr , [sp ] 
                  add sp , sp , #4 
                  @@@@@ @@@@@ @@@@@ @@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                  cmp r9 , #0 
                  bne place_first_String_left_list
                  @@@ don't place first string   
                  sub r3 , r3 , #1
                  add r1 , r1 , #4
                  bal first_list_left
place_first_String_left_list: 
                  ldr r9 , [r1]   
                  str r9 , [r0]
                  add r0 , r0 , #4  @@@ update string list ans pointer
                  add r7 , r7 , #1 @@@ length of outputlist 
                  sub r3 , r3 , #1
                  add r1 , r1 , #4 
                  bal first_list_left                 
second_list_left: cmp r4 , #0   
                  moveq pc , lr@@@@  merge call over 
                  cmp r6 , #1
                  beq second_list_left_duplicates @@@ handle duplicate insertion and remaining elements of second list 
back_to_second_list_left:         @@@@ normal insertion of second list's string 
                  ldr r8 , [r2] @@@@ load string address 
                  str r8 , [r0]@@@@@ send it to answer list 
                  add r0 , r0 , #4
                  add r7 , r7 , #1
                  add r2 , r2 , #4 
                  sub r4 , r4 , #1
                  bal second_list_left
second_list_left_duplicates: 
                  cmp r7 , #0 
                  beq back_to_second_list_left
                   @@@@@ preserving lr , r0 -> r7 
                  str lr, [sp,#-4]!
                  str r0, [sp,#-4]!
                  str r1, [sp,#-4]!
                  str r2, [sp,#-4]!
                  str r3, [sp,#-4]!
                  str r4, [sp,#-4]!
                  str r5, [sp,#-4]!
                  str r6, [sp,#-4]!
                  str r7, [sp,#-4]!
                  @@@@@@@@@@@@@@@@@@@@
                  
                  ldr r1 , [r2]
                  ldr r2 , [ r0, #-4] @@@ previous string
                  mov r0 , r5  @@ mode for compare 
                  bl compare 
                  mov r9 , r0 @@@ moving result to r0
                  @@@@@ restoring , r7 -> r0  , lr @@@@@@@
                  ldr r7 , [sp] 
                  add sp , sp  , #4 
                  ldr r6 , [sp] 
                  add sp , sp  , #4 
                  ldr r5 , [sp] 
                  add sp , sp  , #4 
                  ldr r4 , [sp] 
                  add sp , sp  , #4 
                  ldr r3 , [sp] 
                  add sp , sp  , #4        
                  ldr r2 , [sp] 
                  add sp , sp  , #4 
                  ldr r1 , [sp] 
                  add sp , sp  , #4 
                  ldr r0 , [sp] 
                  add sp , sp  , #4 
                  ldr lr , [sp ] 
                  add sp , sp , #4 
                  @@@@@ @@@@@ @@@@@ @@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                  bne place_second_String_left_list
                  @@@ don't place first string   
                  sub r4 , r4 , #1
                  add r2 , r2 , #4
                  bal second_list_left    
place_second_String_left_list: 
                  ldr r9 , [r2]   
                  str r9 , [r0]
                  add r0 , r0 , #4  @@@ update string list ans pointer
                  add r7 , r7 , #1 @@@ length of outputlist 
                  sub r4 , r4 , #1
                  add r2 , r2 , #4 
                  bal second_list_left                                                   
@@@@@@ compare method uses r0 , r1 , r2 as inputs and r3 and r4 internally 
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
T:         cmp r4 , #97 
            blt TE
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
@@@@@@@@@@@@@ expects address to store string in r2 
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
A:  .space 100 
B:  .space 100
A_string:  .space 100 
B_string:  .space 100
C:  .space 200 
input_prompt1:  .ascii "Please enter the length of the first list, followed by the strings (sorted), one in each line\n\0"
output_prompt: .ascii "The merged list: \0"
output_prompt2:  .ascii "The length of the merged list: \0"
input_prompt2: .ascii "Please enter the length of the second list followed by the strings(sorted), one in each line\n\0"
input_prompt3:  .ascii "Enter the mode of comparison (0 (case insensitive) / 1 (case sensitive)): \0"
input_prompt4:  .ascii "Enter the 1(remove duplicates) / 0( don't remove duplicates): \0"
space: .ascii " \0"
.end