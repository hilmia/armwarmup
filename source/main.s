//Assignment 1 - CPSC 359 Spring 2016
//Assignment completed by Hilmi Abou-Saleh and Riaz Ali
//Program works as expected.
//Only issue that exists is program will always print 32 bit results


.section    .init
.globl     _start

_start:
    b       main

.section .text


//readStringLength - Looks at length of string
//r3 - contains address of string
//r0 - returns address of string
//r1 - returns length of string
readStringLength:
		mov r5, #0 //Counter
	readStringLength_loop:
		ldrb r4, [r3, r5]
		add r5, #1
    //If null then stop loop, otherwise keep going
		teq r4, #0
		bne readStringLength_loop
    //loop end
		mov r0, r3
		mov r1, r5
    mov pc, lr


//checkArgument - checks if input is AND or OR
//does printing within function
//Subroutine isn't general.
//r7 - returns AND (1), OR (0), or if invalid (-1).
checkArgument:
  push {lr}
  CALoop:
  //Prints prompt for command
  ldr r3, =commandprompt
  bl	readStringLength
  bl	WriteStringUART

  ldr r0, =commandpromptbuffer
  mov r1, #256
  bl ReadLineUART
  mov r1, r0 //Move length to r1, to match program
  ldr r0, =commandpromptbuffer

  //If length is greater than 3, then it is not a valid argument

  cmp r1, #3
  bgt checkNaA

  checkAND:
  //Check if char 0 = 'A' if not, check OR
  ldrb r1, [r0]
  cmp r1, #65
  bne checkOR

  //Check if char 1 = 'B' if not, check OR
  ldrb r1, [r0, #1]
  cmp r1, #78
  bne checkOR

  //Check if char 2 = 'C' if not, not a command
  ldrb r1, [r0, #2]
  cmp r1, #68
  bne checkNaA

  //If all three match, then check if char 3 is null

  ldrb r1, [r0, #3]
  cmp r1, #0
  //If so mov value 0 to r7 and finish subroutine
  moveq r7, #1
  beq done
  //On not equal, it means AND+{char} which is not a valid command
  bne checkNaA

  checkOR:
  //Check if char 0 = 'O' if not, not a command
  ldrb r1, [r0]
  cmp r1, #79
  bne checkNaA

  //Check if char 1 = 'R' if not, not a command
  ldrb r1, [r0, #1]
  cmp r1, #82
  bne checkNaA
  //Check if char 2 = '0' if not, it is not just OR
  ldrb r1, [r0, #2]
  cmp r1, #0

  moveq r7, #2
  beq done

  checkNaA:
  //Get ready to print invalid command
  ldr r3, =wrongcommand
  mov r0, r3
  bl readStringLength
  bl	WriteStringUART
  //Loop until valid command found
  b CALoop

  done:
  pop {lr}
  mov pc, lr
//r3 - address of ascii characters
//r2 - return value. binary value
//r5 - counter starting at the length of the string


//convertASCIItoBinary - converts an ASCII string to a binary value
//r0 - length of ASCII string
//r2 - contains binary value (-1 if Wrong Number Format [wnf])
convertASCIItoBinary:
  push {lr}
  //r8 - incremental counter
  //r5 - decremental counter
  mov r8, #0
  mov r2, #0

  ASCIILoop:
    //Checks r8 (incremental counter) with length of string
    cmp     r8, r0
    beq     endloop
    //Load starting value (starts at LSB)
    ldrb  r1, [r3, r5]
    //Checks if bit + inc counter = 1 (49) or 0 (48)
    cmp     r1, #49
    mov     r7, #1
    //If bit = 1 then this is what happens
    //ex. r7 = 1 we LSL by r8 (the length) to Get:
    //    r7 = 1000 (assuming r8 = 3)
    //    r2 contains the value as of last loop
    //    Assume r2 = 101
    //    OR r2 and r7 =  1101
    lsleq   r7, r8
    orreq   r2, r7
    subeq   r5, #1
    addeq   r8, #1
    beq     ASCIILoop

    //If bit = 0 nothing happens, only counters are updated
  checkZero:
    cmp     r1, #48
    subeq   r5, #1
    addeq   r8, #1
    beq     ASCIILoop


    //Wrong Number Format Error
    //There is a number that is not a zero or one
    //Prints error message and r2 returns -1
  wnferror:
		ldr r0, =wrongnumberformat
		bl 	readStringLength
		bl	WriteStringUART
    mov r2, #-1

	endloop:
    pop {lr}
    mov pc, lr

//convertBinarytoASCII - Takes a binary number and prints the ascii reprensentation
//r5  - incremental counter
//r10 - length of binary value
convertBinarytoASCII:
  push {r1, r4, r5, r6, lr}
  mov r5, #0 //Counter
  //Loads the resulting binary value.
  ldr r2, =result_storage
  ldrb r4, [r2]

binary_ASCII_loop:
  //This rotate prints things in the correct order
  //Commenting it out will display the correct value reversed
  ror  r4, #30

  //Checks if r4, being a value is a zero or one
  tst r4, #1
  ldrne r0, =printone
  ldreq r0, =printzero
  //Printing the zero or one, (one in length always)
  mov r1, #1
  bl WriteStringUART
  //Right shift logical, to get to the next bit and store value
  lsr r4, r4, #1
  ldr r2, =result_storage
  strb r4, [r2]

  add r5, #1
  //Branches back until full 32 bit value has been printed
  cmp r5, #31
  blt binary_ASCII_loop

binary_ASCII_loop_end:
  pop {r1, r4, r5, r6, lr}
	mov pc, lr


main:
	mov     	sp, #0x8000 // Initializing the stack pointer
	bl		EnableJTAG // Enable JTAG
	bl		InitUART    // Initialize the UART

  //Content Begins

  //Print Creators of Program
	ldr r3, =creators
	bl	readStringLength
	bl	WriteStringUART

  start_loop:
  //Get argument (AND or OR) and store in buffer
  bl checkArgument
  ldr r8, =logicstorage
  strb r7, [r8]

  //Print the first binary value
  firstbinaryprint:
    //Prints prompt
    ldr r3, =firstbinary
    bl readStringLength
    bl WriteStringUART
    //Reads input
    ldr r0, =firstbinarybuffer
    mov r1, #256
    bl ReadLineUART
    //Subtracts one from length of string
    mov r5, r0
    sub r5, #1

    mov r2, #256
    ldr r3, =firstbinarybuffer
    //Length of string
    mov r10, r0

    //Checks if ASCIItoBinary finished successfully
    bl convertASCIItoBinary
    cmp r2, #-1
    beq firstbinaryprint
    //Store value if success
    ldr r1, =binarystorage
    strb r2, [r1]

  //Print the second binary value
  secondbinaryprint:
    //Prints prompt
    ldr r3, =secondbinary
    bl readStringLength
    bl WriteStringUART
    //Read line
    ldr r0, =secondbinarybuffer
    mov r1, #256
    bl ReadLineUART

    mov r5, r0
    sub r5, #1
    mov r2, #256
    ldr r3, =secondbinarybuffer
    //r10 = first binary value length
    //Store the larger one's length in r10
    cmp r0, r10
    movgt r10, r0
    bl convertASCIItoBinary
    cmp r2, #-1
    beq secondbinaryprint

  command_prep:
    //Load first binary value in r1
    ldr r8, =binarystorage
    ldrb r1, [r8]
    //Load and/or
    ldr r8, =logicstorage
    ldrb r7, [r8]
    cmp r7, #1
    bne doOR
  doAND:
    and r0,r1 ,r2
    b end
  doOR:
    orr r0, r1,r2
  end:
    ldr r2, =result_storage
    strb r0, [r2]

  check:
    //Prints value
    ldr r3, =printvalue
    bl readStringLength
    bl WriteStringUART
    //Convert binary to ascii with r2 being address
    ldr r2, =result_storage
    bl convertBinarytoASCII
    //Restart until program quits.
    b start_loop

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

result_storage:
  .rept 32
  .byte 0
  .endr

logicstorage:
  .rept 32
  .byte 0
  .endr

//Strings
creators:
	.asciz "\r\nCreator Names: Riaz Ali and Hilmi Abou-Saleh"

commandprompt:
	.asciz "\r\nPlease enter a command: "

firstbinary:
	.asciz "\r\nPlease enter the first binary number: "

secondbinary:
	.asciz "\r\nPlease enter the second binary number: "


wrongnumberformat:
	.asciz "Wrong number format!"

printvalue:
	.asciz "\r\nThe result is: "

wrongcommand:
	.asciz "Please enter a valid command!"

printone:
  .asciz "1"
printzero:
  .asciz "0"
