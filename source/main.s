.section    .init
.globl     _start

_start:
    b       main

.section .text

checkArgument:
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
  mov pc, lr

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

//r3 - address of ascii characters
//r2 - return value. binary value
//r5 - counter
convertASCIItoBinary:
	mov r5, #0
  mov r2, #0b0
	aloop:
		ldrb r1, [r3, r5]

		teq  r1, #49
		lsleq r6, r5
		orreq r2, r6
		addeq r5, #1
		beq aloop

		teq r1, #48
		addeq r5, #1
		beq aloop
    bne wnferror

		cmp r1, #0
		beq endloop
	wnferror:
		mov r3, r5
		ldr r3, =wrongnumberformat
		mov r0, r3
		b 	readStringLength
		b	WriteStringUART

		mov r3, r5
		mov r5, #0
		b	aloop
	endloop:
	mov pc, lr


//r2 - address of binary value
//r3 - temporary value
//r4 - return value of buffer
//r5 - address of ASCII characters
convertBinarytoASCII:
	mov r5, #0	//bit counter
	mov r6, #0
	bloop:
		ldrb r4, [r3, r5]
		cmp  r4, #0 //check for null ter
		beq bendloop //end of binary value

		sub r4, r4, #48 //convert to ascii value
		lsl r6, r6, #1
		add r6, r6, r4

		add r5, r5, #1

		b bloop

	bendloop:
		mov pc, lr

//r0 - location of buffer
//r1 - length of string



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
  //bl checkArgument
  mov r7, #2

  ldr r3, =firstbinary
  bl readStringLength
  bl WriteStringUART

  ldr r0, =firstbinarybuffer
  mov r1, #256
  bl ReadLineUART
  //r2 - length of buffer
  //r3 - address of ascii characters
  //r4 - return value. binary value
  mov r2, #256
  ldr r3, =firstbinarybuffer
  bl convertASCIItoBinary




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


wrongcommand:
	.asciz "\r\nPlease enter a valid command!"
