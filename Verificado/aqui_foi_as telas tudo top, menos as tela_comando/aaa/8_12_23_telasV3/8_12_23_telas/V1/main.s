.include "gpio.s"
.include "sleep.s"
.include "display_lcd.s"

@ Chamar as funções do display
.global _start

_start:
	MemoryMap
	
	setOut
	.ltorg
	initDisplay
	@ETATE
	WriteChar #0b01010100
	WriteChar #0b01000101
	WriteChar #0b01010011
	WriteChar #0b01010100
	WriteChar #0b01000101
	.ltorg
	@clearDisplay
	@setInitialCursorPos
	
	
	@AQSTE
	mov r2, #0
	bl setCursorPos
	@AQ
	WriteChar #0b01000001
	WriteChar #0b01010001
	@WriteChar #0b01000101
	.ltorg
	
	
	mov r2, #40
	bl setCursorPos
	@clearDisplay
	@ETA
	WriteChar #0b01000101
	WriteChar #0b01010100
	WriteChar #0b01000001
	@WriteChar #0b01010001
	.ltorg
	@Encerramento do programa
	MOV R0, #0
    	MOV R7, #1
    	SVC 0
	
.data 
	timeZero: 	.word	0 @ 0 Segundos
	time1ms: 	.word	1000000  @ 1 Milissegundo
	time3ms:	.word	3000000  @ 3 Milissegundos
	time5ms:	.word	5000000  @ 5 Milissegundos 
	time15ms:	.word 	15000000 @ 15 Milissegundos
	time150us:	.word	150000 @ 150 us
	time60us:	.word	60000 @ 150 us
	timespecnano:	.word 	1000000
	time100ms:	.word	100000000
	devmem: .asciz "/dev/mem"

	@ endereço de memória dos registradores do gpio / 4096
	gpioaddr: .word 0x1C20 @0x01C20800 / 0x1000 (4096) @Endereço base do GPIO / 0x1000

	pagelen: .word 0x1000 @4096

	@ Pinos precisam de 4 campos offset reg_data, offset dentro do reg_data, offset reg_select, offset dentro do reg_select
	db7: .word 0xE8 
		.word 7 
		.word 0xD8
		.word 28 
	db6: .word 0xE8 
		.word 6 
		.word 0xD8
		.word 24 
	db5: .word 0xE8 
		.word 9 
		.word 0xDC
		.word 4 
	db4: .word 0xE8 
		.word 8 
		.word 0xDC
		.word 0 
	E: .word 0x10 
		.word 18 
		.word 0x08
		.word 8 
	RS: .word 0x10 
		.word 2 
		.word 0x00
		.word 8 
