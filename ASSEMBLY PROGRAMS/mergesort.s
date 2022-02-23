.global merge_sort
.extern div
.extern merge_main
.text
mov r2 , #11
@@@ r1 => unsorted list, r2 => list size , r3 => comparison mode , r4 => duplicate removal option , => returns the output list in r1 , and size in r2                      
merge_sort:
    cmp r2 , #1   
    movle pc , lr  @@2 if size of list is one or less, the list is already sorted, r1 and r2 have the output needed 
    @@@@ SAVING ON STACK @@@@ 
    str lr , [sp,#-4]!
    str r1 , [sp,#-4]!
    str r2 , [sp,#-4]!
    str r3 , [sp,#-4]!
    str r4 , [sp,#-4]!
    @@@@    @@@@@@  @@@@ 
    mov r0 , r2   @@ divident 
    mov r1 , #2 @@ divisor 
    bl div
    mov r8 , r0 @@ quotient, length of first half of the list 
    @@@ RESTORING @@@@@    
    ldr r4 , [sp]
    add sp , sp  , #4
    ldr r3 , [sp]
    add sp , sp  , #4   
    ldr r2 , [sp]
    add sp , sp  , #4
    ldr r1 , [sp]
    add sp , sp  , #4
    ldr lr, [sp]
    add sp , sp  , #4
    @@@@@@@@@@@@@@@@@    
    mov r9 , #4  
    mov r6 , r8 @@ length of first half of the list  
    sub r7 , r2 , r6 @@@ length of second half of the list 
    mul r8 , r8 , r9 
    add r8 , r1 , r8 @@@ starting address of second half list   
    mov r9 , r1  @@@ starting address of first half list 
    @@@@ SAVING ON STACK @@@@ 
    str lr , [sp,#-4]!
    str r1 , [sp,#-4]!
    str r2 , [sp,#-4]!
    str r3 , [sp,#-4]!
    str r4 , [sp,#-4]!
    str r6 , [sp,#-4]! @@@ length of first list 
    str r9 , [sp,#-4]! @@@ starting address of first list 
    @@@@    @@@@@@  @@@@ 
    mov r1 , r8 @@ second list 
    mov r2 , r7  @@ r3 , r4 are already there 
    bl merge_sort  @@ sort first half recursively 
    ldr r8 , [sp]  @@@ starting address of first half list , restored 
    add sp , sp , #4 
    ldr r9 , [sp] @@@ length of first half list, restored 
    add sp , sp , #4 
    str r1 , [sp,#-4]! @@ saving the address of the sorted second half 
    str r2 , [sp,#-4]! @@@ saving length of sorted second half 
    mov r1 , r8  @@ first half list  
    mov r2 , r9 @@@ length of first half list
    ldr r4 , [sp,#8] @@ get the comparison mode from the stack 
    ldr r3 , [sp,#12] @@ get the duplicate removal token from the stack
    bl merge_sort  @@ returns ans list in  r1 , and length in r2, sorts the first half of the list 
    mov r3 , r2 @@ length of first list , first list already in r1 
    ldr r0 , =newList @@ will store the output of merged list   
    ldr r4 , [sp] @@ length of second sorted list 
    add sp , sp  , #4
    ldr r2 , [sp] @@@ second sorted list   
    add sp , sp , #4
    mov r7 , #0  
    ldr r6 , [sp] @@ duplicate removal 
    ldr r5 , [sp,#4] @@ comp mode 
    bl merge_main @@ returns length of ans (merged_list) in r7
    ldr r1 , [sp , #12] 
    mov r8 , r7 @@@ storing length of merged list 
    ldr r0 , =newList @@ address of merged list 
copyList: @@@ copy the merged list to the inital list 
    cmp  r7 , #0 
    beq copyDone
    ldr r2 , [r0]
    str r2 , [r1]
    sub r7 , r7 , #1 
    add r0 , r0 , #4
    add r1 , r1 , #4
    bal copyList   
copyDone: @@@ restoring local valriables 
    @@@ RESTORING @@@@@    
    ldr r4 , [sp]
    add sp , sp  , #4
    ldr r3 , [sp]
    add sp , sp  , #4   
    ldr r2 , [sp]
    add sp , sp  , #4
    ldr r1 , [sp]
    add sp , sp  , #4
    ldr lr, [sp]
    add sp , sp  , #4
    @@@@@@@@@@@@@@@@@  
    @@@ preparing the answer registers 
    mov r2 , r8 @@ length of sorted list 
    mov pc , lr 


.data
newList:  .space  500
.end