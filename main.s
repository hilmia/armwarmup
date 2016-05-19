.section    .init
.globl     _start

_start:
    b       main

.section .text


//r3 is always going to contain the address of string
readStringLength:
		mov r5, #0
	loop_start:
		ldrb r4, [r3, r5]
		add r5, #1
		teq r4, #0
		bne loop_start
	loop_end:
		mov r0, r3
		mov r1, r5
mov pc, lr

//helper subroutines
checkArgument:
  push {lr}
  CALoop:
  ldr r3, =commandprompt

  bl	readStringLength
  bl	WriteStringUART

  ldr r0, =commandpromptbuffer
  mov r1, #256
  bl ReadLineUART
  mov r1, r0
  ldr r0, =commandpromptbuffer

  cmp r1, #3
  bgt checkNaA

  checkAND:
  ldrb r1, [r0]
  cmp r1, #65
  bne checkOR

  ldrb r1, [r0, #1]
  cmp r1, #78
  bne checkOR
  ldrb r1, [r0, #2]
  cmp r1, #68
  bne checkNaA
  ldrb r1, [r0, #3]
  cmp r1, #0
  moveq r7, #1
  beq done
  bne checkNaA

  checkOR:
  ldrb r1, [r0]
  cmp r1, #79
  bne checkNaA
  ldrb r1, [r0, #1]
  cmp r1, #82
  bne checkNaA
  ldrb r1, [r0, #2]
  cmp r1, #0
  moveq r7, #2
  beq done

  checkNaA:
  ldr r3, =wrongcommand
  mov r0, r3
  bl readStringLength
  bl	WriteStringUART
  b CALoop
  done:
  pop {lr}
  mov pc, lr
//r3 - address of ascii characters
//r2 - return value. binary value
//r5 - counter starting at the length of the string
convertASCIItoBinary:
  push {lr}
  mov r8, #0
  mov r7, #1
  mov r2, #0

  ASCIILoop:
    ASCII_Loop_Check:
    cmp     r8, r0
    beq     endloop

    ldrb  r1, [r3, r5] //Load starting value (starts at LSB)

    cmp     r1, #49
    mov     r7, #1
    lsleq   r7, r7, r8
    orreq   r2, r2, r7
    subeq   r5, #1
    addeq   r8, #1
    beq     ASCIILoop

    checkZero:
    cmp     r1, #48
    subeq   r5, #1
    addeq   r8, #1
    beq     ASCIILoop



	wnferror:
		mov r3, r5
		ldr r3, =wrongnumberformat
		mov r0, r3
		bl 	readStringLength
		bl	WriteStringUART
    mov r2, #-1
	endloop:
    pop {lr}
    mov pc, lr


convertBinarytoASCII:
  push {lr}
    //r10 - Longest Binary value
    
    //r2 - address of binary value
    mov r5, #0
loop:

    ldrb r3, [r2, r5]   //loaad next byte from memory

    cmp r3, #1          //check for null terminator
    break:
    bne pzero
    ldr r0, =printone
    b endBALoop
    pzero:
    ldr r0, =printzero

    endBALoop:
    add r5, #1
    mov r1, #1

    bl WriteStringUART
    cmp r5, r10
    blt loop

	bendloop:
    pop {lr}
		mov pc, lr


main:
	mov     	sp, #0x8000 // Initializing the stack pointer
	bl		EnableJTAG // Enable JTAG
	bl		InitUART    // Initialize the UART

  // You can use WriteStringUART and ReadLineUART functions here after the UART initializtion.

  //Print Creators of Program
	ldr r3, =creators
	bl	readStringLength
	bl	WriteStringUART
  //Get argument (AND or OR) and store in r7
  bl checkArgument
  ldr r8, =logicstorage
  str r7, [r8]



  firstbinaryprint:
    ldr r3, =firstbinary
    bl readStringLength
    bl WriteStringUART

    ldr r0, =firstbinarybuffer
    mov r1, #256
    bl ReadLineUART
    mov r5, r0
    sub r5, #1
    mov r2, #256
    ldr r3, =firstbinarybuffer
    mov r10, r0
    bl convertASCIItoBinary
    cmp r2, #-1
    beq firstbinaryprint
    ldr r1, =binarystorage
    str r2, [r1]

  secondbinaryprint:
    ldr r3, =secondbinary
    bl readStringLength
    bl WriteStringUART

    ldr r0, =secondbinarybuffer
    mov r1, #256
    bl ReadLineUART
    mov r5, r0
    sub r5, #1
    mov r2, #256
    ldr r3, =secondbinarybuffer
    cmp r0, r10
    movgt r10, r0
    bl convertASCIItoBinary
    cmp r2, #-1
    beq secondbinaryprint
    ldr r8, =binarystorage
    ldr r1, [r8]


  ldr r8, =logicstorage
  ldr r7, [r8]
  cmp r7, #1
  bne doOR

  doAND:
    and r0,r1 ,r2
    b end
  doOR:
    orr r0, r1,r2

  end:
  ldr r2, =logicstorage
  str r0, [r2]
check:
  ldr r3, =printvalue
  bl readStringLength
  bl WriteStringUART

  ldr r2, =logicstorage
  bl convertBinarytoASCII


haltLoop$:
	b	haltLoop$



.section .data
.align 4

//Buffers

firstbinarybuffer:
  .rept 256
  .byte 0
  .endr

secondbinarybuffer:
  .rept 256
  .byte 0
  .endr

commandpromptbuffer:
  .rept 256
  .byte 0
  .endr

binarystorage:
  .rept 32
  .byte 0
  .endr

logicstorage:
  .rept 32
  .byte 0
  .endr


creators:
	.asciz "\r\nCreator Names: Riaz Ali and Hilmi Abou-Saleh"

commandprompt:
	.asciz "\r\nPlease enter a command: "

firstbinary:
	.asciz "\r\nPlease enter the first binary number: "

secondbinary:
	.asciz "\r\nPlease enter the second binary number: "


wrongnumberformat:
	.asciz "\r\nWrong number format!"

printvalue:
	.asciz "\r\nThe result is: "

wrongcommand:
	.asciz "\r\nPlease enter a valid command!"

printone:
  .asciz "1"
printzero:
  .asciz "0"
