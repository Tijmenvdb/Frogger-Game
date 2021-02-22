	.text
	.global lab7
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
	.global illuminate_LEDs
	.global illuminate_RGB_LED

startScreen:  .string 0xD, 0xA, "|---------------------------------------------|", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                   Frogger                   |", 0xD, 0xA,"|                     BY                      |", 0xD, 0xA,"|              Tijmen Van Der Beek            |", 0xD, 0xA,"|                 Sakar Pahari                |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|            Press Enter to start             |", 0xD, 0xA,"|    (Press any button on keypad to pause)    |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|---------------------------------------------|", 0
gameover:  	  .string 0xD, 0xA, "|---------------------------------------------|",0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                  Game Over                  |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|          Do you want to continue?           |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|              Press 'Y' or 'N'               |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|                                             |", 0xD, 0xA,"|---------------------------------------------|", 0

lab7:
	STMFD SP!, {lr}
restart:
	MOV r9, #0x0200
	MOVT r9, #0x2000
	BL uart_init
	BL timer_init
	BL illuminate_LEDs
	BL illuminate_RGB_LED
	BL board_init
	BL timer_init
menu_loop
	MOV r0, #0xC
	BL output_character
	ADR r0, startScreen
	BL output_string
	BL read_character
	CMP r0, #0x0D
	BNE menu_loop
	BL keypad_init

	MOV r1, #0x5000			;sets r1 to PortF address
	MOVT r1, #0x4002
	MOV r0, #2
	STRB r0, [r1, #0x3FC]	;sets the colors to light up
	BL pause_game

loop:
	LDRB r0, [r9, #0xC]
	CMP r0, #4
	IT EQ
	BLEQ nextLevel
	LDRB r0, [r9, #0xD]
	CMP r0, #1
	BNE loop

	BL pause_game
	BL print_board
	MOV r0, #0xC
	BL output_character
	ADR r0, gameover
	BL output_string

	MOV r1, #0x5000			;sets r1 to PortF address
	MOVT r1, #0x4002
	MOV r0, #4
	STRB r0, [r1, #0x3FC]	;sets the colors to light up

gameOverLoop:
	BL read_character
	CMP r0, #0x59
	BEQ restart
	CMP r0, #0x79
	BEQ restart
	CMP r0, #0x4E
	BEQ end
	CMP r0, #0x6E
	BEQ end
	B gameOverLoop
end:
	MOV r1, #0x5000			;sets r1 to PortF address
	MOVT r1, #0x4002
	MOV r0, #0
	STRB r0, [r1, #0x3FC]	;sets the colors to light up

	LDMFD SP!, {lr}
	mov pc, lr
