	.text
	.global PortAHandler
	.global Uart0Handler
	.global Timer0AHandler
	.global Timer0BHandler
	.global Timer1AHandler
	.global randomizor
	.global calcPeriod
	.global board_init
	.global uart_init
	.global timer_init
	.global print_board
	.global pause_game
	.global nextLevel
	.global keypad_init
	.global read_character
	.global output_string
	.global output_character
	.global dterFlyLoc
	.global illuminate_LEDs
	.global illuminate_RGB_LED
	.global getScore
	.global getTime

;startScreen-------------------------------------------
startScreen:  .string 0xD, 0xA, "|---------------------------------------------|", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                   Frogger                   |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|            Press Enter to start             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|---------------------------------------------|", 0
;pauseScreen-------------------------------------------
pauseScreen:  .string 0xD, 0xA, "|---------------------------------------------|", 0xD, 0xA,"| PAUSED                                      |", 0xD, 0xA,"|                              Legend         |", 0xD, 0xA,"|       Score            |: Vertical Wall     |", 0xD, 0xA,"|  Moving Up:  +10       -: Horizontal Wall   |", 0xD, 0xA,"|  Moving Down:-10       a: Alligator’s Back  |", 0xD, 0xA,"|  Home:       +50       A: Alligator’s Mouth |", 0xD, 0xA,"|  Time:       +10       L: Log               |", 0xD, 0xA,"|  Fly:        +100      O: Lily Pad          |", 0xD, 0xA,"|  Level:      +250      &: Frog              |", 0xD, 0xA,"|                        T: Turtle            |", 0xD, 0xA,"|     Controls           C: Car               |", 0xD, 0xA,"|        W               #: Truck             |", 0xD, 0xA,"|      A S D             +: Fly               |", 0xD, 0xA,"|   (Press any button on keypad to resume)    |", 0xD, 0xA,"|---------------------------------------------|", 0
;gameover-------------------------------------------
gameover:  	  .string 0xD, 0xA, "|---------------------------------------------|",0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                  Game Over                  |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|          Do you want to continue?           |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|             	Press 'Y' or 'N'               |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|---------------------------------------------|", 0

;board-------------------------------------------------
info:		.string "     |Level:00 Time:00 Lives:0 Score:00000         |     ", 0
border:		.string "     |---------------------------------------------|     ", 0
home1:		.string "     |*********************************************|     ", 0
home2:		.string "     |*****     *****     *****     *****     *****|     ", 0
middle:		.string "                                                         ", 0
safeZone:	.string "     |.............................................|     ", 0
newPage:	.string "|", 0
newLine:	.string "|", 0xD, 0xA, "|", 0
save_cursor: .string 0x1B,"[s", 0
hide_cursor: .string 0x1B, "[?25l",0
restore_cursor: .string 0x1B, "[u", 0

;keypad---------------------------------------------
U0LSR:  .equ 0x18			; UART0 Line Status Register
CLOCK:  .equ 0x608			; GPIO offset to enable clock
DIR:	.equ 0x400			; GPIO offset to choose direction
DIGITAL:.equ 0x51C			; GPIO offset to enable digital pin
DATA:	.equ 0x3FC			; GPIO offset to data register

;offsets-----------------------------------------------
frogger:	.equ 0x0
moveDir:	.equ 0x4
level:		.equ 0x5
time:		.equ 0x6
lives:		.equ 0x7
score:		.equ 0x8
homeFrogs:	.equ 0xC
GameOver:	.equ 0xD
underFrog:	.equ 0xE
gameBoard:	.equ 0xF

row1:		.equ 243
row2:		.equ 300
row3:		.equ 357
row4:		.equ 414

row5:		.equ 528
row6:		.equ 585
row7:		.equ 642
row8:		.equ 699
row9:		.equ 756
row10:		.equ 813

safe1:		.equ 197

resetFrog:  .equ 898

;objects-----------------------------------------------
car:		.string "     C", 0
truck:		.string "  ####", 0
lilypad:	.string "     O", 0
turtle:		.string "    TT", 0
log:		.string "LLLLLL", 0
alligator:	.string "aaaaaA", 0
homeh: 		.string "HHHHH",0
fly: 		.string "+++++",0
nofly:		.string "     ",0
;generate fly

gen_fly:
	STMFD SP!, {r0-r4, lr}
	BL random_number
	BL dterFlyLoc
	ADD r4, r0, #safe1
	BL random_number
	CMP r0, #2
	BGT no_fly
	ADD r0, r9, r4
	LDRB r3,[r0]
	CMP r3, #0x48
	BEQ end_fly
	ADR r1, fly
	MOV r2, #1
	BL store_string
	B end_fly
no_fly:
	CMP r0, #40
	BGT remove_fly
	B end_fly
remove_fly:
	ADD r0, r9, r4
	LDRB r3, [r0]
	CMP r3, #0x48
	BEQ end_fly
	ADD r0, r9, r4
	ADR r1, nofly
	MOV r2, #1
	BL store_string
end_fly:
	LDMFD sp!, {r0-r4, lr}		;restores registers used
	MOV pc, lr



;****
;Handles interupt from keypad
;
;****
PortAHandler:
	STMFD SP!, {r0-r4, lr}

	;--------Clears Intrrupt---------------
	MOV r1, #0x4000			;PortA address
	MOVT r1, #0x4000
	LDR r0, [r1, #0x41C]
	ORR r0, #0x3C			;Sets bits 2-5
	STR r0, [r1, #0x41C]	;GPIOICR (GPIO Interrupt Clear)
	;--------------------------------------

	MOV r0, #0xC
	BL output_character
	ADR r0, pauseScreen
	BL output_string
	MOV r0, #0xC000				;UART0 base address
	MOVT r0, #0x4000
	LDR r1, [r0, #0x30]			;offset UARTCTL
	EOR r1, #0x200				;disable UART0
	STR r1, [r0, #0x30]
	BL pause_game

	LDMFD sp!, {r0-r4, lr}		;restores registers used
	BX lr

;****
;Uart0Handler
;
;****
Uart0Handler:
	STMFD SP!, {r0-r3, lr}
	MOV r1, #0xC000			;load the memory address
    MOVT r1, #0x4000		; base address #0x4000C000
    LDRB r0, [r1]
;----------------------------Check for the user input, Branch accordinly---------
	CMP r0, #0x77	;w
	BEQ up
	CMP r0, #0x61	;a
	BEQ left
	CMP r0, #0x73	;s
	BEQ down
	CMP r0, #0x64	;d
	BEQ right
EndUARTHandler:
	STRB r1, [r9, #moveDir]
;Clear interrupt-----------------------------------------------------------------
	MOV r0, #0xC000			;UART0 base address
	MOVT r0, #0x4000
	LDR r1, [r0, #0x44]		;offset UARTICR
	ORR r1, #0x10			;Clear UART0's interrupt
	STR r1, [r0, #0x44]

;--------------------------------------------------------------------------------

	LDMFD SP!, {r0-r3, lr}
	BX lr
;-----------------------------Direction labels----------------------
up:
	MOV r1, #0
	SUB r1, r1, #57
	LDR r2, [r9, #score]
	LDRSB r0, [r9, #moveDir]
	CMP r0, r1
	BEQ EndUARTHandler
	ADD r2, r2, #10
	STR r2, [r9, #score]
	B EndUARTHandler
left:
	MOV r1, #-1
	B EndUARTHandler
down:
	MOV r1, #57
	LDR r2, [r9, #score]
	LDRB r0, [r9, #moveDir]
	CMP r0, r1
	BEQ EndUARTHandler
	SUB r2, r2, #10
	STR r2, [r9, #score]
	B EndUARTHandler
right:
	MOV r1, #1
	B EndUARTHandler
;-------------------------------------------------------------------------------

;****
;Timer0AHandler
;
;****
Timer0AHandler:
	STMFD SP!, {r0-r3, lr}

	BL update_boardSlow
	BL gen_fly
;Clear interrupt-----------------------------------------------------------------
	MOV r0, #0x6000				;WideTimer0 base address
	MOVT r0, #0x4003
	LDR r1, [r0, #0x24]			;offset GPTMICR
	ORR r1, #0x001				;Clears Timer0A's interrupt
	STR r1, [r0, #0x24]
;--------------------------------------------------------------------------------
	LDMFD SP!, {r0-r3, lr}
	BX lr

;****
;Timer0BHandler
;
;****
Timer0BHandler:
	STMFD SP!, {r0-r3, lr}

	BL update_boardFast

	LDRSB r0, [r9, #moveDir]
	LDR r1, [r9, #frogger]
	ADD r0, r1
	STMFD SP!, {r0}
	BL check_hazards
	LDMFD SP!, {r0}
	CMP r1, #1
	STMFD SP!, {r1}
	IT NE
	BLNE move_frog
	IT EQ
	BLEQ reset_frog
	LDMFD SP!, {r1}
	CMP r1, #0x2
	IT EQ
	MOVEQ r3, #50
	BEQ got_home
	CMP r1, #0x06
	IT EQ
	MOVEQ r3, #150
	BEQ got_home
	B skip_home
got_home:
	LDR r0, [r9, #score]
	ADD r0, r3
	STR r0, [r9, #score]

	LDR r0, [r9, #frogger]
	STMFD SP!, {r0}
	ADD r0, r9, #resetFrog
	BL move_frog

	LDRB r0, [r9, #time]
	BL getScore
	LDR r1, [r9, #score]
	ADD r0, r1
	STR r0, [r9, #score]

	STMFD SP!, {r0-r3}
	LDRB r0, [r9, #level]
	BL getTime
	STRB r0, [r9, #time]
	LDMFD SP!, {r0-r3}
	LDMFD SP!, {r0}

	;STMFD SP!, {r0-r3}
	;BL nextLevel
	;LDMFD SP!, {r0-r3}


move_left:
	SUB r0, #1
	LDRB r2, [r0]
	CMP r2, #0x2a ;*
	BNE move_left
	Add r0, #1
	ADR r1, homeh
	MOV r2, #1
	BL store_string
	LDRB r0, [r9, #homeFrogs]
	ADD r0, #1
	STRB r0, [r9, #homeFrogs]
skip_home:
	MOV r0, #0
	STRB r0, [r9, #moveDir]

	BL print_board
;Clear interrupt-----------------------------------------------------------------
	MOV r0, #0x6000				;WideTimer0 base address
	MOVT r0, #0x4003
	LDR r1, [r0, #0x24]			;offset GPTMICR
	ORR r1, #0x100				;Clears Timer0B's interrupt
	STR r1, [r0, #0x24]
;--------------------------------------------------------------------------------
	LDMFD SP!, {r0-r3, lr}
	BX lr

;****
;Timer1AHandler
;
;****
Timer1AHandler:
	STMFD SP!, {r0-r3, lr}

	LDRB r0, [r9, #time]
	SUB r0, #1
	CMP r0, #0
	STRB r0, [r9, #time]
	BNE skipGameOver
gameOver:
	MOV r0, #1
	STRB r0, [r9, #GameOver]
skipGameOver:

;Clear interrupt-----------------------------------------------------------------
	MOV r0, #0x7000				;WideTimer1 base address
	MOVT r0, #0x4003
	LDR r1, [r0, #0x24]			;offset GPTMICR
	ORR r1, #0x001				;Clears Timer1A's interrupt
	STR r1, [r0, #0x24]

	LDMFD SP!, {r0-r3, lr}
	BX lr


;****
;uart_init initializes UART0 for interrupts.
;
;Parameters:
;
;Returns:
;****
uart_init:
	STMFD SP!, {lr}

;System Control-----------------------------------------------------------------
	MOV r0, #0xE000				;System Control base address
	MOVT r0, #0x400F
	LDR r1, [r0, #0x618]		;offset RCGCUART
	ORR r1, #0x1				;enabled and provide clock to UART0
	STR r1, [r0, #0x618]

	LDR r1, [r0, #0x608]		;offset RCGCGPIO
	ORR r1, #0x1				;enabled and provide clock to PortA
	STR r1, [r0, #0x608]

;UART0--------------------------------------------------------------------------
	MOV r0, #0xC000				;UART0 base address
	MOVT r0, #0x4000
	LDR r1, [r0, #0x30]			;offset UARTCTL
	BIC r1, #0x1				;disable UART0
	STR r1, [r0, #0x30]

	MOV r1, #8					;Set Interger Baud-Rate Divisor for 115,200 baud (store 8)
	STRH r1, [r0, #0x24]		;offset UARTIBRD

	MOV r1, #44					;Set Fractional Baud-Rate Divisor for 115,200 baud (store 44)
	STRH r1, [r0, #0x28]		;offset UARTFBRD

	LDR r1, [r0, #0xFC8]		;offset UARTCC
	BIC r1, #0xF				;Setting clock source to system clock
	STR r1, [r0, #0xFC8]

	MOV r1, #0x60				;Use 8-bit word length, 1 stop bit, no parity
	STRB r1, [r0, #0x2C]		;offset UARTLCRH

	LDR r1, [r0, #0x38]			;offset UARTIM
	ORR r1, #0x10				;Setting RXIM to 1 to enable Intrrupts
	STR r1, [r0, #0x38]

	MOV r1, #0x301				;enables uart for transmit and receive of data
	STRH r1, [r0, #0x30]		;offset UARTCTL

;PortA--------------------------------------------------------------------------
	MOV r0, #0x4000				;PortA base address
	MOVT r0, #0x4000
	MOV r1, #0x3				;Make PA0 and PA1 as Digital Ports
	STRB r1, [r0, #0x51C]		;offset GPIOAFSEL

	MOV r1, #0x3				;Change PA0 and PA1 to Use an Alternate Function
	STRB r1, [r0, #0x420]		;offset GPIODEN

	MOV r1, #0x11				;Configure PA0 and PA1 for UART
	STR r1, [r0, #0x52C]		;offset GPIOPCTL

;NVIC---------------------------------------------------------------------------
	MOV r0, #0xE000				;NVIC base address
	MOVT r0, #0xE000
	LDR r1, [r0, #0x100]		;offset EN0
	ORR r1, #0x20				;Enables interrupts for UART0 in the NVIC
	STR r1, [r0, #0x100]		;offset EN0

	LDMFD SP!, {lr}
	mov pc, lr

;****
;timer_init
;
;Parameters:
;
;Returns:
;****
timer_init:
	STMFD SP!, {lr}

;System Control-----------------------------------------------------------------
	MOV r0, #0xE000				;System Control base address
	MOVT r0, #0x400F

	LDR r1, [r0, #0x65C]		;offset RCGCTIMER
	ORR r1, r1, #0x03			;enables clock to WideTimer0 and WideTimer1
	STR r1, [r0, #0x65C]

;WideTimer0-------------------------------------------------------------------------
	MOV r0, #0x6000				;WideTimer0 base address
	MOVT r0, #0x4003

	LDR r1, [r0, #0xC]			;offset GPTMCTL
	BIC r1, #0x100				;Disables TimerA and TimerB
	BIC r1, #0x001
	STR r1, [r0, #0xC]

	LDR r1, [r0, #0x0]			;offset GPTMCFG
	BIC r1, #0x7				;sets WideTimer0 to 32bit mode
	ORR r1, #0x4
	STR r1, [r0, #0x0]

	LDR r1, [r0, #0x4]			;offset GPTMTAMR
	BIC r1, #0x3				;sets TimerA to Periodic Mode
	ORR r1, #0x2
	STR r1, [r0, #0x4]

	LDR r1, [r0, #0x8]			;offset GPTMTBMR
	BIC r1, #0x3				;sets TimerB to Periodic Mode
	ORR r1, #0x2
	STR r1, [r0, #0x8]

;getPeriod-------------------------------------------------------------------------
	STMFD SP!, {r0, lr}
	LDRB r0, [r9, #level]
	BL calcPeriod				;r0 = calcPeriod(level)
	MOV r1, r0					;MOV r1, period
	LDMFD SP!, {r0, lr}
;----------------------------------------------------------------------------------

								;TimerB Period = calcPeriod(level)
	STR r1, [r0, #0x2C]			;offset GPTMTBILR

	ADD r1, r1					;TimerA Period = calcPeriod(level) * 2
	STR r1, [r0, #0x28]			;offset GPTMTAILR

	LDR r1, [r0, #0x18]			;offset GPTMIMR
	ORR r1, #0x1				;Enables TimerA and TimerB for Interrupts
	ORR r1, #0x100
	STR r1, [r0, #0x18]

;WideTimer1-------------------------------------------------------------------------
	MOV r0, #0x7000				;WideTimer1 base address
	MOVT r0, #0x4003

	LDR r1, [r0, #0xC]			;offset GPTMCTL
	BIC r1, #0x100				;Disables TimerA and TimerB
	BIC r1, #0x001
	STR r1, [r0, #0xC]

	LDR r1, [r0, #0x0]			;offset GPTMCFG
	BIC r1, #0x7				;sets WideTimer1 to 32bit mode
	ORR r1, #0x4
	STR r1, [r0, #0x0]

	LDR r1, [r0, #0x4]			;offset GPTMTAMR
	BIC r1, #0x3				;sets TimerA to Periodic Mode
	ORR r1, #0x2
	STR r1, [r0, #0x4]

	LDR r1, [r0, #0x8]			;offset GPTMTBMR
	BIC r1, #0x3				;sets TimerB to Periodic Mode
	ORR r1, #0x2
	STR r1, [r0, #0x8]

	MOV r1, #0x2400				;TimerA Period (16,000,000 = 1 second @ 16Mhz (16,000 ticks per second))
	MOVT r1, #0x00F4
	STR r1, [r0, #0x28]			;offset GPTMTAILR

	MOV r1, #0xFFFF				;TimerB Period (8,000 = 1/2 second @ 16Mhz (16,000 ticks per second))
	MOVT r1, #0x0000
	STR r1, [r0, #0x2c]			;offset GPTMTBILR

	LDR r1, [r0, #0x18]			;offset GPTMIMR
	ORR r1, #0x001				;Enables TimerA for Interrupts
	STR r1, [r0, #0x18]

	LDR r1, [r0, #0xC]			;offset GPTMCTL
	ORR r1, #0x100				;Enables TimerB
	STR r1, [r0, #0xC]

;NVIC--------------------------------------------------------
	MOV r0, #0xE000				;NVIC base address
	MOVT r0, #0xE000

	LDR r1, [r0, #0x108]		;offset EN2
	ORR r1, r1, #0xC0000000		;Set 30-31 bit to enable Timer0A, Timer0B for interrupts
	STR r1, [r0, #0x108]

	LDR r1, [r0, #0x10C]		;offset EN3
	ORR r1, r1, #0x1			;Set 0 bit to enable Timer1A for interrupts
	STR r1, [r0, #0x10C]

	LDR r1, [r0, #0x45C]		;offset PRI23
	BIC r1, #0x00E00000			;Makes Timer0A top priority
	BIC r1, #0xE0000000
	ORR r1, #0x20000000			;Makes Timer0B lowest priority
	STR r1, [r0, #0x45C]

	LDR r1, [r0, #0x460]		;offset PRI24
	BIC r1, #0xE0
	ORR r1, #0x10				;Makes Timer1A middle priority
	STR r1, [r0, #0x460]

	LDMFD SP!, {lr}
	mov pc, lr

;****
;nextLevel
;
;Parameters:
;
;Returns:
;****
nextLevel:
	STMFD SP!, {lr}

	ADD r0, r9, #safe1
	ADR r1, nofly
	MOV r2, #1
	STMFD SP!, {r0-r2}
	BL store_string
	LDMFD SP!, {r0-r2}

	ADD r0, #10
	STMFD SP!, {r0-r2}
	BL store_string
	LDMFD SP!, {r0-r2}

	ADD r0, #10
	STMFD SP!, {r0-r2}
	BL store_string
	LDMFD SP!, {r0-r2}

	ADD r0, #10
	STMFD SP!, {r0-r2}
	BL store_string
	LDMFD SP!, {r0-r2}

	LDR r0, [r9, #score]
	ADD r0, #250
	STR r0, [r9, #score]

;getPeriod-------------------------------------------------------------------------
	LDRB r0, [r9, #level]
	ADD r0, #1
	STRB r0, [r9, #level]
	BL calcPeriod				;r0 = calcPeriod(level)
	MOV r1, r0					;MOV r1, period
;----------------------------------------------------------------------------------

;updatePeriod----------------------------------------------------------------------
	MOV r0, #0x6000				;WideTimer0 base address
	MOVT r0, #0x4003
								;TimerB Period = calcPeriod(level)
	STR r1, [r0, #0x2C]			;offset GPTMTBILR

	ADD r1, r1					;TimerA Period = calcPeriod(level) * 2
	STR r1, [r0, #0x28]			;offset GPTMTAILR
;----------------------------------------------------------------------------------

	LDRB r0, [r9, #level]
	BL getTime
	STRB r0, [r9, #time]

	MOV r0, #0
	STRB r0, [r9, #homeFrogs]

	LDMFD SP!, {lr}
	mov pc, lr


;****
;read_character receives a character from Putty.
;
;Parameters:
;
;Returns:
;r0: asciiChar
;****
read_character:
	STMFD SP!,{r1-r2, lr}	; Store register lr on stack

	MOV r2, #0xC000			; Store the starting address of
	MOVT r2, #0x4000		; the UART Data register

loopRC:
	LDRB r1,[r2, #U0LSR] 	; Load the UART Status Register to r1
	BIC r1, r1, #0xEF		; Clear all but the RxFE bits
	CMP r1, #0x10			; Compare RxFE to 1.  If 1, loop back
	BEQ loopRC				; Otherwise, read the character

	LDR r0, [r2]			; Loads the character input to r0

	LDMFD sp!, {r1-r2, lr}
	mov pc, lr


;****
;pause_game
;
;Parameters:
;
;Returns:
;****
pause_game:
	STMFD SP!, {lr}

	MOV r0, #0x6000				;WideTimer0 base address
	MOVT r0, #0x4003

	LDR r1, [r0, #0xC]			;offset GPTMCTL
	EOR r1, #0x100				;Enables/Disables TimerA and TimerB
	EOR r1, #0x001
	STR r1, [r0, #0xC]

	MOV r0, #0x7000				;WideTimer1 base address
	MOVT r0, #0x4003

	LDR r1, [r0, #0xC]			;offset GPTMCTL
	EOR r1, #0x001				;Enables/Disables TimerA
	STR r1, [r0, #0xC]

	MOV r1, #0x5000			;sets r1 to PortF address
	MOVT r1, #0x4002
	LDRB r0, [r1, #0x3FC]	;sets the colors to light up
	EOR r0, #10
	STRB r0, [r1, #0x3FC]	;sets the colors to light up

	LDMFD SP!, {lr}
	mov pc, lr

;****
;board_init
;
;Parameters:
;
;Returns:
;****
board_init:
	STMFD SP!, {r4, lr}

;stores board-------------------------------------------------
	MOV r0, #0xC
	BL output_character
	ADR r0,  hide_cursor
	BL output_string
	ADR r0, save_cursor
	BL output_string

	ADD r0, r9, #gameBoard
	MOV r2, #1
	ADR r1, info
	BL store_string

	ADR r1, border
	BL store_string

	ADR r1, home1
	BL store_string
	ADR r1, home2
	BL store_string

	ADR r1, middle
	BL store_string
	ADR r1, middle
	BL store_string
	ADR r1, middle
	BL store_string
	ADR r1, middle
	BL store_string

	ADR r1, safeZone
	BL store_string

	ADR r1, middle
	BL store_string
	ADR r1, middle
	BL store_string
	ADR r1, middle
	BL store_string
	ADR r1, middle
	BL store_string
	ADR r1, middle
	BL store_string
	ADR r1, middle
	BL store_string

	ADR r1, safeZone
	BL store_string

	ADR r1, border
	BL store_string

;initilize variables-------------------------------------------------
	ADD r0, r9, #gameBoard
	ADD r0, #883				;(rowSize)57 * (numRows - 1)15 + (halfRow)28
	STR r0, [r9, #frogger]		;initilizing pointer to frogger
	LDRB r1, [r0]
	STRB r1, [r9, #underFrog]	;saving char under frogger
	MOV r1, #0x26				;r1 = &
	STRB r1, [r0]				;putting frogger on board

	MOV r0, #0
	STRB r0, [r9, #moveDir]		;moveDir = 0
	STRB r0, [r9, #level]		;level = 0
	STR r0, [r9, #score]		;score = 0
	STRB r0, [r9, #GameOver]	;paused = 0
	STRB r0, [r9, #homeFrogs]	;homeFrogs = 0


	STMFD SP!, {r0-r3}
	LDRB r0, [r9, #level]
	BL getTime
	STRB r0, [r9, #time]		;time = 60
	LDMFD SP!, {r0-r3}

	MOV r0, #4
	STRB r0, [r9, #lives]		;lives = 4

	BL update_info				;upadtes info with newly initilized values

;generate objects----------------------------------------------------
	MOV r4, #200
genLoop:
	BL update_boardFast
	BL update_boardSlow
	SUB r4, #1
	CMP r4, #0
	BNE genLoop

	LDMFD SP!, {r4, lr}
	mov pc, lr

;****
;print_board
;
;Parameters:
;
;Returns:
;****
print_board:
	STMFD SP!, {r4-r6, lr}
	BL update_info

	ADD r4, r9, #gameBoard
	ADD r4, #6
	ADD r5, r4, #45
	ADD r6, r4, #957		;(numRows)18 * (rowSize)57 - (bufferSize)12

	ADR r0, restore_cursor
	BL output_string

	ADR r0, newPage			;r0 = "NP|"
	BL output_string

boardLoop:					;prints everyRow of the board from memory
	LDRB r0, [r4], #1		;loads char from r4 to r0 and increments address in r4
	BL output_character		;outputs the char from r0
	CMP r4, r5				;when (startOfRow)r4 == (endOfRow)r5 increamentRow
	BNE boardLoop
	CMP r4, r6				;when (startOfBoard)r4 == (endOfBoard)r6 break
 	BEQ endboardLoop

	ADR r0, newLine			;r0 = '|\n|'
	BL output_string

							;skips the buffer and increaments row
	ADD r4, #12				;bufferSize = 12
	ADD r5, #57				;rowSize = 57
	B boardLoop
endboardLoop:

	MOV r0, #0x7C			;r0 = '|'
	BL output_character

	LDMFD SP!, {r4-r6, lr}
	mov pc, lr

;****
;output_character
;
;Parameters:
;r0: character
;
;Returns:
;****
output_character:
	STMFD SP!, {lr}

	MOV r2, #0xC000			;Moves the address of UART0 to r2
	MOVT r2, #0x4000
characterLoop:
	LDRB r1, [r2, #0x18]	;Loads UART0 Line Status Register to r1
	AND r1, r1, #0x20		;Isolates the TxFF bit
	CMP r1, #0x20			;If TxFF bit is set loop
	BEQ characterLoop

	STRB r0, [r2]			;Stores the data from UART0 to r0

	LDMFD SP!, {lr}
	mov pc, lr

;****
;output_string
;
;Parameters:
;r0: string address
;
;Returns:
;****
output_string:
	STMFD SP!, {r4, lr}
	MOV r4, r0

stringLoop:
	LDRB r0, [r4], #1		;loads char from r0 and increments address in r4
	CMP r0, #0				;if r0 has null char end else loop
	BEQ exitLoop
	BL output_character		;outputs the char from r0
	B stringLoop
exitLoop:

	LDMFD SP!, {r4, lr}
	mov pc, lr

;****
;store_string: Stores a null terminated string from one address to another address without the null terminator
;
;Parameters:
;r0: store address
;r1: string address
;r2: direction (1 right)(-1 left)
;
;Returns:
;r0: store address + string size
;****
store_string:
	STMFD SP!, {lr}

storeChar:
	LDRB r3, [r1], #1			;Loads char from address
	CMP r3, #0					;If null break
	BEQ endStore
	STRB r3, [r0]				;Stores char to new address
	ADD r0, r2
	B storeChar					;loop
endStore:

	LDMFD SP!, {lr}
	mov pc, lr

;****
;store_decimal
;
;Parameters:
;r0: unsigned int
;r1: store address
;
;Returns:
;****
store_decimal:
	STMFD SP!, {r4, lr}
	MOV r4, r1

hexToDec:
	MOV r1, r0					;r1 = unsigned int
	MOV r0, #10					;r0 = 10
	BL div_and_mod				;Divides r1 by r0
	ORR r1, r1, #0x30			;Makes remainder ascii character
	STRB r1, [r4], #-1			;Stores in memory (least significant bit to most significant bit)
	CMP r0, #0
	BNE hexToDec			;loops until number is stored in memory

	LDMFD SP!, {r4, lr}
	mov pc, lr

;****
;update_board
;
;Parameters:
;
;Returns:
;****
update_boardSlow:
	STMFD SP!, {lr}

	MOV r2, #1
	ADR r1, turtle
	ADD r0, r9, #row2

	BL gen_obj
	BL move_row

	MOV r2, #-1
	ADR r1, log
	ADD r0, r9, #row3
	ADD r0, #56

	BL gen_obj
	BL move_row

	MOV r2, #1
	ADR r1, truck
	ADD r0, r9, #row5

	BL gen_obj
	BL move_row

	MOV r2, #-1
	ADR r1, truck
	ADD r0, r9, #row8
	ADD r0, #56

	BL gen_obj
	BL move_row

	MOV r2, #-1
	ADR r1, truck
	ADD r0, r9, #row10
	ADD r0, #56

	BL gen_obj
	BL move_row
	LDMFD SP!, {lr}
	mov pc, lr

;****
;update_board
;
;Parameters:
;
;Returns:
;****
update_boardFast:
	STMFD SP!, {lr}

	MOV r2, #-1
	ADR r1, alligator
	ADD r0, r9, #row1
	ADD r0, #56

	BL gen_obj
	BL move_row

	MOV r2, #1
	ADR r1, lilypad
	ADD r0, r9, #row4

	BL gen_obj
	BL move_row

	MOV r2, #1
	ADR r1, car
	ADD r0, r9, #row9

	BL gen_obj
	BL move_row

	MOV r2, #1
	ADR r1, car
	ADD r0, r9, #row7

	BL gen_obj
	BL move_row

	MOV r2, #-1
	ADR r1, car
	ADD r0, r9, #row6
	ADD r0, #56

	BL gen_obj
	BL move_row

	LDMFD SP!, {lr}
	mov pc, lr

;****
;update_info
;
;Parameters:
;
;Returns:
;****
update_info:
	STMFD SP!, {r4, lr}
	ADD r4, r9, #gameBoard

	MOV r0, r4
	ADR r1, info
	MOV r2, #1
	BL store_string

	ADD r1, r4, #13
	LDRB r0, [r9, #level]
	BL store_decimal

	ADD r1, r4, #21
	LDRB r0, [r9, #time]
	BL store_decimal

	ADD r1, r4, #29
	LDRB r0, [r9, #lives]
	BL store_decimal

	ADD r1, r4, #41
	LDR r0, [r9, #score]
	BL store_decimal

	LDMFD SP!, {r4, lr}
	mov pc, lr

;****
;move_frog
;moves the frog
;
;Parameters:
;r0: new address
;
;Returns:
;****
move_frog:
	STMFD SP!, {lr}
	MOV r2, r0

	LDR r0, [r9, #frogger]
	LDRB r1, [r9, #underFrog]
	STRB r1, [r0]				;restores char under frogger

	STR r2, [r9, #frogger]		;moving frogger
	LDRB r1, [r2]
	STRB r1, [r9, #underFrog]	;saving char under frogger
	MOV r1, #0x26				;r1 = &
	STRB r1, [r2]				;putting frogger on board

	LDMFD SP!, {lr}
	mov pc, lr

;****
;delays the program
;
;Parameters:
;
;Returns:
;****
delay:
	STMFD SP!, {r0, lr}		;loads registers going to be used

	MOV r0, #0x00ff			;r1: delayNum = 0xff
delayloopOS:
	SUB r0, r0, #1			;delayNum--
	CMP r0, #0				;while(delayNum > 0)
	BNE delayloopOS

	LDMFD sp!, {r0, lr}		;restores registers used
	mov pc, lr				;moves the link register to the program counter

;Parameters:
;r0: ledPattern
;
;Returns:
;****
illuminate_RGB_LED:
	STMFD SP!, {r0-r3, lr}	;loads registers going to be used
	MOV r2, #0xE000			;sets r2 to SYSCTL_RCGC address
	MOVT r2, #0x400F
	MOV r1, #0x5000			;sets r1 to PortF address
	MOVT r1, #0x4002

	LDRB r3, [r2, #CLOCK]
	ORR r3, #0x20			;sets the 6th bit in r3
	STRB r3, [r2, #CLOCK]	;enables the clock for portF
	MOV r3, #0xE			;sets the first 3 pins in r3

	BL delay

	STRB r3, [r1, #DIR]		;sets the direction to the pins to output
	STRB r3, [r1, #DIGITAL]	;sets the pins to digital
	STRB r3, [r1, #DATA]	;sets the colors to light up

	LDMFD sp!, {r0-r3, lr}	;restores registers used
	mov pc, lr				;moves the link register to the program counter

;****
;illuminate_LEDs lights the leds on the board depending on the the set bits in r0
;
;Parameters:
;
;Returns:
;****
illuminate_LEDs:
	STMFD SP!, {r0-r3, lr}	;loads registers going to be used
	MOV r2, #0xE000			;sets r2 to SYSCTL_RCGC address
	MOVT r2, #0x400F
	MOV r1, #0x5000			;sets r1 to PortB address
	MOVT r1, #0x4000
	AND r0, r0, #0xF		;clear all bits except for the first 4bit

	LDRB r3, [r2, #CLOCK]
	ORR r3, #0x2			;sets the 2nd bit in r3
	STRB r3, [r2, #CLOCK]	;enables the clock for PortB
	MOV r3, #0xF			;sets the first 4 bits in r3

	BL delay

	STRB r3, [r1, #DIR]		;sets the direction to the pins to output
	STRB r3, [r1, #DIGITAL]	;sets the pins to digital
	MOV r0, #0xF
	STRB r0, [r1, #DATA]	;sets the leds to light up

	LDMFD sp!, {r0-r3, lr}	;restores registers used
	mov pc, lr				;moves the link register to the program counter

;****
;reset_frog
;returns frogger back to the start
;
;Parameters:
;
;Returns:
;****
reset_frog:
	STMFD SP!, {lr}
	ADD r0, r9, #resetFrog
	BL move_frog
	LDRB r0, [r9, #lives]
	SUB r0, #1
	MOV r1, #0
	CMP r0, #0
	IT EQ
	MOVEQ r1, #1
	STRB r1, [r9, #GameOver]
	STRB r0, [r9, #lives]

	STMFD SP!, {r0-r3}
	LDRB r0, [r9, #level]
	BL getTime
	STRB r0, [r9, #time]		;time = 60
	LDMFD SP!, {r0-r3}

	MOV r1, #0x5000			;sets r1 to PortB address
	MOVT r1, #0x4000
	LDRB r0, [r1, #DATA]	;sets the leds to light up
	LSR r0, #1
	STRB r0, [r1, #DATA]	;sets the leds to light up


	LDMFD SP!, {lr}
	mov pc, lr

;****
;check_hazards
;
;Parameters: make r0 = new address
;
;Returns:
;r1: bool: fly, Home, hazard r0 = 110
;Fly found : 110 =0x06
;home : 010	= 0x02
;hazard : 001 =0x01
;safe : 000  = 0x00
;****
check_hazards:
	STMFD SP!, {lr}
	LDRB r3, [r0]
	CMP r3, #0x07C   ;|
	BEQ breakHazard		; if | then set hazard and end the game-play
	CMP r3, #0x02D   ;-	if not check for -
	BEQ breakHazard	 ; if it is - set hazard and end the game-play

;Checking Bounds--------------------------------------------------------
	ADD r2, r9, #gameBoard
CheckingBounds:
	MOV r1, #0
	CMP r0, r2
	BLO wrongRow1
	ADD r1, #1
wrongRow1:
	SUB r1, #1
	ADD r2, #57

	CMP r0, r2
	BHI wrongRow2
	ADD r1, #1
wrongRow2:
	SUB r1, #1

	CMP r1, #0
	BNE CheckingBounds

	SUB r2, #51
	CMP r0, r2
	BLO wrongRow3
	ADD r1, #1
wrongRow3:
	SUB r1, #1
	ADD r2, #44

	CMP r0, r2
	BHI wrongRow4
	ADD r1, #1
wrongRow4:
	SUB r1, #1

	CMP r1, #0
	BNE breakHazard

;-----------------------------------------------------------------------

	ADD r2, r9, #gameBoard ;point r2 to the head of gameboard
	ADD r2, #228		;Add 285 to check if it is in home row

	CMP r0, r2	 		;Compare with home row
	BLS home			;if greater than 285 it is in home row.
	ADD r2, r9, #gameBoard ;point r2 to the head of gameboard
	ADD r2, #528
	CMP r0, r2		;if greater it lower half
	BHI lower
	B upper

upper:
	CMP r3, #0x020   ; ' '
	BEQ breakHazard
	CMP r3, #0x41    ;A
	BEQ breakHazard
	MOV r1, #0x00
	B end_Hazard
lower:
   CMP r3, #0x023   ;#
   BEQ breakHazard
   CMP r3, #0x043   ;C
   BEQ breakHazard
   MOV r1, #0x00
	B end_Hazard
home:
	CMP r3, #0x02A   ;*
	BEQ breakHazard
	CMP r3, #0x048   ;H
	BEQ breakHazard
	CMP r3, #0x02B   ;+
	BEQ fly_found
	MOV r1, #0x02
	B end_Hazard
fly_found:
	MOV r1, #0x06
	B end_Hazard

breakHazard:
	mov r1, #1
	B end_Hazard

end_Hazard:
	LDMFD SP!, {lr}
	mov pc, lr


;****
;move_row
;
;Parameters:
;r0: rowPointer
;r2: direction
;
;Returns:
;****
move_row:
	STMFD SP!, {r4-r6, lr}
	MOV r1, #0x20
	MOV r3, #51

	LDR r5, [r9, #frogger]
	LDRB r4, [r9, #underFrog]
	STRB r4, [r5]

	MOV r6, #0
	CMP r5, r0
	BLO notInRow
	ADD r6, r2
notInRow:
	SUB r6, r2

rowLoop:
	LDRB r4, [r0]
	STRB r1, [r0]
	MOV r1, r4
	ADD r0, r2
	SUB r3, #1
	CMP r3, #0
	BNE rowLoop

	LDR r5, [r9, #frogger]
	LDRB r4, [r5]

	STMFD SP!, {r0, r2-r3}
	MOV r0, r5
	BL check_hazards
	LDMFD SP!, {r0, r2-r3}

	STRB r4, [r9, #underFrog]
	MOV r4, #0x26
	STRB r4, [r5]


	ADD r4, r9, #row5
	CMP r5, r4
	BHI bottomHalf
	MOV r1, #0
	CMP r5, r0
	BHI rowNot
	ADD r6, r2
rowNot:
	SUB r6, r2

	CMP r6, #2
	BEQ here
	CMP r6, #0
	BNE bottomHalf

here:
	ADD r5, r2
	MOV r0, r5
	BL move_frog
	MOV r1, #0
bottomHalf:
	CMP r1, #1
	IT EQ
	BLEQ reset_frog

	LDMFD SP!, {r4-r6, lr}
	mov pc, lr

;****
;gen_obj
;
;Parameters:
;r0: rowPointer
;r1: objectPointer
;r2: direction
;
;Returns:
;****
gen_obj:
	STMFD SP!, {lr}
	CMP r2, #1
	BEQ genRight
	CMP r2, #-1
	BEQ genLeft
genRight:
	LDRB r3, [r0, #5]
	B genBreak
genLeft:
	LDRB r3, [r0, #-5]
genBreak:

	CMP r3, #0x20
	BNE noGen

	STMFD SP!, {r0-r2}
	BL random_number
	MOV r3, r0
	LDMFD SP!, {r0-r2}


	CMP r3, #90
	BLT noGen
	BL store_string

noGen:
	LDMFD SP!, {lr}
	mov pc, lr

;****
;random_number
;
;Parameters:
;
;Returns:
;r0: random number
;****
random_number:
	STMFD SP!, {lr}
	MOV r1, #0x7000				;WideTimer1 base address
	MOVT r1, #0x4003

	LDR r0, [r1, #0x54]			;offset GPTMTBV
	BL randomizor				;Puts value from TimerB through randomizer

	LDMFD SP!, {lr}
	mov pc, lr

;****
;Initilizes keypad for interrupt
;
;****
keypad_init:
	STMFD SP!, {r0-r4, lr}		;loads registers going to be used

	MOV r0, #0xE000			;SYSCTL_RCGC address
	MOVT r0, #0x400F

	LDRB r3, [r0, #CLOCK]	;enables the clock for PortA & PortD
	ORR r3, #0x09			;sets the 1st bit and 4th bit in r0
	STRB r3, [r0, #CLOCK]	;enables the clock for PortA & PortD


	MOV r2, #0x7000			;PortD address
	MOVT r2, #0x4000

	MOV r3, #0x0F			;sets the first 4 bits in r3
	STRB r3, [r2, #DIR]		;sets PortD pins to output
	STRB r3, [r2, #DIGITAL]	;sets PortD pins to digital
	STRB r3, [r2, #DATA]	;outputs a signal in PortD


	MOV r1, #0x4000			;PortA address
	MOVT r1, #0x4000

	LDRB r3, [r1, #DIR]
	BIC r3, #0x3C
	STRB r3, [r1, #DIR]		;sets PortA pins to input

	LDRB r3, [r1, #DIGITAL]
	ORR r3, #0x3C
	STRB r3, [r1, #DIGITAL]	;sets PortA pins to digital

	LDRB r3, [r1, #0x404]
	BIC r3, #0x3C			;Enables edge sensitive triggering
	STRB r3, [r1, #0x404]	;PortA GPIOIS (GPIO Interrupt Sense)

	LDRB r3, [r1, #0x408]
	BIC r3, #0x3C			;Allows GPIOIEV to determine trigger
	STRB r3, [r1, #0x408]	;PortA GPIOIBE (GPIO Interrupt Both Edges)

	LDRB r3, [r1, #0x40C]
	ORR r3, #0x3C			;Enables a rising edge interrupt
	STRB r3, [r1, #0x40C]	;PortA GPIOIEV (GPIO Interrupt Event)

	LDRB r3, [r1, #0x410]
	ORR r3, #0x3C			;Allows the intrrupt to be triggered
	STRB r3, [r1, #0x410]	;PortA GPIOIM (GPIO Interrupt Mask)


	MOV r1, #0xE000			;NVIC (Nested Vector Interrupt Controller)
	MOVT r1, #0xE000

	MOV r3, #0x21			;Enables interrupt in NVIC for PortA
	STRB r3, [r1, #0x100]	;NVIC offset to EN0

	LDMFD sp!, {r0-r4, lr}		;restores registers used
	MOV pc, lr

;****
;Divids the number and returns the quoteint and remainder
;Parameters:
;r0 = Divisor
;r1 = Dividend
;
;Returns:
;r0 = quoteint
;r1 = remainder
;****
div_and_mod:
	STMFD r13!, {r2-r12, r14}

	; Your code for the signed division/mod routine goes here.
	; The dividend is passed in r1 and the divisor in r0.
	; The quotient is returned in r0 and the remainder in r1.

					;r0 = Divisor
					;r1 = Dividend
	MOV r2, #0		;Quotient = 0
	MOV r3, #15		;Counter = 15
	MOV r4, #0		;NegitiveCounter = 0

ifDividendNeg:
	CMP r1, #0		;If not negative move to next section
	BGE ifDivisorNeg

	RSB r1, r1, #0	;Makes Dividend Positive
	ADD r4, r4, #1	;NegitiveCounter++

ifDivisorNeg:
	CMP r0, #0		;If not negative move to next section
	BGE else

	RSB r0, r0, #0	;Makes Divisor Positive
	ADD r4, r4, #1	;NegitiveCounter++

else:
	LSL r0, r0, #15 ;Shifts Divisor by 15 bits

loop:
	SUB r1, r1, r0	;Dividend = Dividend - Divisor

PositiveRemainder:
	CMP r1, #0		;If Dividend < 0 GoTo Negative else Positive
	BLT NegativeRemainder

	LSL r2, r2, #1	;Shifts a 1 in the Quotient
	ADD r2, r2, #1
	B Return

NegativeRemainder:
	ADD r1, r1, r0	;Restores Dividend
	LSL r2, r2, #1	;Shifts Quotient left

Return:
	LSR r0, r0, #1	;Shifts Divisor Right
	SUB r3, r3, #1	;Counter--
	CMP r3, #0		;If Counter >= 0 GoTo loop else endLoop
	BGE loop

endLoop:
	MOV r0, r2		;MOV Quotient to R0

isNegativeTrue:
	CMP r4, #1		;Checks if final answer should be negative
	BNE isNegativeFalse

	RSB r0, r0, #0	;Makes Quotient negative

isNegativeFalse:

	LDMFD r13!, {r2-r12, r14}
	MOV pc, lr



