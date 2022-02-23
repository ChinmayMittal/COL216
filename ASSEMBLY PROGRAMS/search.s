	.text
_Start:	mov r0, #1		@ set starting point, i = 1, j = 1
	mov r1, #1			@ j = 1
	ldr r5, =R			@ pointer to result area
	bl search			@ make first call, search (1, 1)
	mov r0, #0
	strb r0, [r5]		@ null terminate the result string
	bl Prnt			@ call print routine
	mov r0, #0x18
	swi 0x123456		@ exit the program
search: str lr, [sp,#-4]!	@ push lr on stack
	str r0, [sp,#-4]!	@ push i on stack
	str r1, [sp,#-4]!	@ push j on stack
	add r2, r1, r0,LSL #3	@ r2 gets 8*i+j
	ldr r3, =V
	ldrb r4, [r3, r2]	@ r4 has V[i,j]
	cmp r4, #1
	beq Ret0			@ return failure, if already visited
 	mov r4, #1
	strb r4, [r3, r2]	@ mark as visited
	ldr r3, =M
	ldrb r4, [r3, r2]	@ r4 has M[i,j]
	cmp r4, #'B
	beq Ret0			@ return failure, boundary cell found
	cmp r4, #'X
	beq Ret0			@ return failure, occupied cell found
	cmp r4, #'F
	bne L1			@ not final cell, need further search
	add r0, r0, #'0		@ get ascii code of index i
	strb r0, [r5], #1	@ append to the result string
	add r0, r1, #'0		@ get ascii code of index j
	strb r0, [r5], #1	@ append to the result string
	b Ret1			@ return success
L1:	ldr r0, [sp,#4]
	ldr r1, [sp]
	add r0, r0, #1
	bl search			@ search(i+1,j)
	cmp r0, #1
	bne L2
	mov r0, #'N			@ ascii code of 'N' (North)
	strb r0, [r5], #1	@ append to the result string
	b Ret1
L2:	ldr r0, [sp,#4]
	ldr r1, [sp]
	add r1, r1, #1
	bl search			@ search(i,j+1)
	cmp r0, #1
	bne L3
	mov r0, #'W			@ ascii code of 'W' (West)
	strb r0, [r5], #1	@ append to the result string
	b Ret1
L3: 	ldr r0, [sp,#4]
	ldr r1, [sp]
	sub r0, r0, #1
	bl search			@ search(i-1,j)
	cmp r0, #1
	bne L4
	mov r0, #'S			@ ascii code of 'S' (South)
	strb r0, [r5], #1	@ append to the result string
	b Ret1
L4: 	ldr r0, [sp,#4]
	ldr r1, [sp]
	sub r1, r1, #1
	bl search			@ search(i,j-1)
	cmp r0, #1
	bne Ret0
	mov r0, #'E			@ ascii code of 'E' (East)
	strb r0, [r5], #1	@ append to the result string
	b Ret1
Ret0:	mov r0, #0			@ 0 for failure
	ldr lr, [sp, #8]		@ get lr from stack
	add sp, sp, #12		@ remove stack frame
	mov pc, lr
Ret1:	mov r0, #1			@ 1 for success
	ldr lr, [sp, #8]		@ get lr from stack
	add sp, sp, #12		@ remove stack frame
	mov pc, lr
Prnt:	str lr, [sp,#-4]!	@ push lr in stack	
	ldr r1, =param		@ adress of parameter area
	mov r4, #1			@ file #1 is stdout
	str r4, [r1]
	ldr r4, =R 			@ address of string to be printed
	str r4, [r1, #4] 
	mov r4, #20			@ number of bytes
	str r4,[r1,#8]
	mov r0, #5			@ code for write
	swi 0x123456
	ldr lr, [sp], #4		@ pop lr from stack
	mov pc, lr
	.data
M:	.ascii "BBBBBBBBBSOXOXOBBXOOOOXBBOOXOOXBBOXFOXOBBOXOOXOBBOXXOXOBBBBBBBBB"
V:	.word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
param:	.word 0, 0, 0
R:	.space 20
	.end
