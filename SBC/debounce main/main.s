.include "gpio.s"
.include "sleep.s"


.global _start

_start:
	MemoryMap
	setPinGPIOOut led
	@setChIn
	SetPinGPIOHigh led
	setPinGPIOIn bVoltar

	loop:
		readPinGPIO bVoltar
		cmp r0, #0
		bne verifica
		b loop

    
	verifica: 
		debounce bVoltar
		cmp r0, #0
		beq ascende
		SetPinGPIOHigh led
    	
	ascende:
		SetPinGPIOLow led
		b loop

		
	/* loop:
	    	readPinGPIO bVoltar 	@ Leitura do botão
	    	cmp r0, #0 		@ se o botão for 0 ir para verifica
	    	beq verifica
	    	b loop 	 			
		
	verifica:
		nanoSleep timeZero, time800ms	@ Tempo de confirmação, caso o usuário mantenha pressionado
		readPinGpio bVoltar		@ Ler novamente o botão
		cmp r0, #0 	
		beq exit
		SetPinGPIOHigh led
		b verifica	
		
	exit:
		SetPinGPIOLow led
		b loop
	*/	






.data 
	timeZero: 	.word	0 @ 0 Segundos
	time1s:		.word 	1 @ 1 Segundos 
	time1ms: 	.word	1000000  @ 1 Milissegundos
	time3ms:	.word	3000000  @ 3 Milissegundos
	time5ms:	.word	5000000  @ 5 Milissegundos 
	time15ms:	.word 	15000000 @ 15 Milissegundos
	time800ms:	.word	800000000 @ 800 Milissegundos
	time150us:	.word	150000 @ 150 us
	time60us:	.word	60000 @ 150 us
	timespecnano:	.word 	1000000
	time100ms:	.word	100000000
	devmem: .asciz "/dev/mem"

	@ endereço de memória dos registradores do gpio / 4096
	gpioaddr: .word 0x1C20 @0x01C20800 / 0x1000 (4096) @Endereço base do GPIO / 0x1000

	pagelen: .word 0x1000 @4096

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
	bVoltar: .word 0X10
	    .word 7
	    .word 0x00
	    .word 28
	@PA10
	bOk: .word 0X10
	    .word 10
	    .word 0x04
	    .word 8
	@PA20
	bSeguir: .word 0X10
	    .word 20
	    .word 0x08
	    .word 16

	@Chaves
	  
    @PA6
	ch1: .word 0x10
	    .word 6
	    .word 0x00
	    .word 24
    @PA1
	ch2: .word 0x10
	    .word 1
	    .word 0x04
	    .word 4
    @PA0
	ch3: .word 0x10
	    .word 0
	    .word 0x08
	    .word 0
    @PA3 
	ch4: .word 0x10
	    .word 3
	    .word 0x00
	    .word 12
	
	    
	    
	led: .word 0x10
	.word 9
	.word 0x04
	.word 4 
