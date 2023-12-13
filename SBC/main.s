.include "sleep.s"
.include "utils.s"
.include "gpio.s"
.include "display_lcd.s"
.include "telas.s"



.global _start

_start:
    MemoryMap @ Mapeando o GPIO
    setOut @ Setandos os pinos de saída
    setIn @ Setando os pinos de entrada
    initDisplay @ Configurando o display LCD

	@Encerramento do programa
	MOV R0, #0
    MOV R7, #1
    SVC 0




.data 
	timeZero: 	.word	0 @ 0 Segundos
    time800ms:  .word   800000000 @ 8000 Milisegundos
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
	uartaddr: .word 0x1C28 
	pagelen: .word 0x1000 @4096
	uart3:	.word 0x04 @rx e tx estão no mesmo offset
		.word 20 @tx
		.word 24 @rx
	@ Pinos precisam de 4 campos NESTA ORDEM: offset reg_data, offset dentro do reg_data, offset reg_select, offset dentro do reg_select
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
		@PA 10
		
	@Botões ficam em 1 e qnd apertados vão pra 0
	@PA7 
	bCancel: .word 0X10
	    .word 7
	    .word 0x00
	    .word 28
	@PA 10
	bScreen: .word 0X10
	    .word 10
	    .word 0x04
	    .word 8
	@PA20
	bConfirm: .word 0X10
	    .word 20
	    .word 0x08
	    .word 16
	@Chaves ficam em 1 e qnd apertados vão pra 0
	@PA3 
	sh4: .word 0X10
	    .word 3
	    .word 0x00
	    .word 12
	    
	@PA0
	sh3: .word 0X10
	    .word 0
	    .word 0x00
	    .word 0
	    
	@PA1 
	sh2: .word 0X10
	    .word 1
	    .word 0x00
	    .word 4
	    
	@PA6 
	sh1: .word 0X10
	    .word 6
	    .word 0x00
	    .word 24
	    
	led: .word 0x10
	.word 9
	.word 0x04
	.word 4 
