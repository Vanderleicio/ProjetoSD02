.include "utils.s"
.include "sleep.s"
.include "gpioNovo.s"
.include "display_lcd.s"
.include "telas.s"
.include "uart.s"

@ Chamar as funções do display
.global _start


_start:
@INICIALIZAÇÃO GERAL
	MemoryMap	
	setOut
	setIn

	initDisplay
	
	MemoryMapUart
	inicializarUART

@FIM DA INICIALIZAÇÃO GERAL
    	
    	bl resetFifo
    	
    	mov r1, #0b01000101
    	bl WriteCharLCD
    	
    	bl TELA_DESLIGA_CONTINUO_UMID
    	
    /*
    	whileReadUart1:
	
	mov r2, #0xC00	@ Deslocamento padrão dos módulos UART
	add r2, #0x0014	@ Deslocamento para o registrador LSR (Line Status)
	
	ldr r3, [r9, r2] 	@ Carrega o reg UART_LSR (Line Status)

    	mov r1, #0b1	@ Máscara para ler o último bit
    	and r1, r3

    	cmp r1, #0b1
    	beq ler	@ Se for 1, quer dizer que o segundo byte já chegou então posso lê-lo
    	b whileReadUart1	@ Se não for, fico checando até que seja
	
	ler:
	   bl readUart
	   
	bl SEL_TELA
	*/
    	
	
    @ Testar apertando bem rápido o botão para ver oq acontece (ele deveria continuar no loop)
    LOOP_PRINCIPAL:
        @ LOOP para ficar olhando se pressionei o botão de confirm
        debouncePin bConfirm
        cmp r7, #1 @ Verifico se foi pressionado
        BEQ ASCENDE @ Se tiver pressionado e passado no teste do debounce, pulo para ascender o led
        @ Se não tiver passado, desligo ele

        B LOOP_PRINCIPAL
        ASCENDE: @ Ascende e desligo o programa
            bl TELA_COMANDOS  
	    LOOP_PRINCIPAL2:
		@ LOOP para ficar olhando se pressionei o botão de confirm
		debouncePin bConfirm
		cmp r7, #1 @ Verifico se foi pressionado
		BEQ ASCENDE2 @ Se tiver pressionado e passado no teste do debounce, pulo para ascender o led
		@ Se não tiver passado, desligo ele

		B LOOP_PRINCIPAL2
		ASCENDE2: @ Ascende e desligo o programa
		    bl TELA_SITUACAO_SENSOR_ERRO  
	
	/*
	@teste1:

	    @ 0011001 1011 01000
	    @mov r12, #0
	    //====SIMULANDO UM DADO RECEBIDO DA UART PARA JOGAR NAS TELAS====//
	    // DADOS
	    mov r14, #34 @ Colocando o valor do DADO recebido (25)
	    lsl r14, #9 @ Deslocando o comando para o bit
	    add r12, r12, r14 @Coloca o valor do comando na posição correta
	    // COMANDO
	    mov r14, #0b1011 @ Colocando o valor do COMANDO recebido (11)
	    lsl r14, #5 @ Deslocando o comando para o bit
	    add r12, r12, r14 @Coloca o valor do comando na posição correta
	    // Nº SENSOR
	    mov r14, #15 @ Colocando o valor do número do sensor recebido (8)
	    add r12, r12, r14 @Coloca o valor do comando na posição correta

    @bl DesligaUmidContinuos @ Parte da linha de cima
    @mov r1, #0b01000101
    @bl WriteCharLCD
    @bl jumpLine
   
	@bl TELA_COMANDOS
	@bl TELA_DESLIGA_CONTINUO_UMID
	*/
	
	
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
	time800ms:  .word   800000000 @ 800 Milisegundos
	time150us:	.word	150000 @ 150 us
	time60us:	.word	60000 @ 150 us
	timespecnano:	.word 	1000000
	time100ms:	.word	100000000
	time150ms:	.word	150000000
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
