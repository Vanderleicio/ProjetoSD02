.macro MemoryMap
	LDR R0, =devmem @ R0 = nome do arquivo
	MOV R1, #2 @ O_RDWR (permissao de leitura e escrita pra arquivo)
	MOV R7, #5 @ sys_open
	SVC 0
	MOV R4, R0 @ salva o descritor do arquivo.

	@sys_mmap2
	MOV R0, #0 @ NULL (SO escolhe o endereco)
	LDR R1, =pagelen
	LDR R1, [R1] @ tamanho da pagina de memoria
	MOV R2, #3 @ protecao leitura ou escrita
	MOV R3, #1 @ memoria compartilhada
	LDR R5, =gpioaddr @ endereco GPIO / 4096
	LDR R5, [R5]
	MOV R7, #192 @sys_mmap2
	SVC 0
	MOV R8, R0
.endm


labelPinHigh:
@=======PUT PILHA
    sub sp, sp, #24
    str r0, [sp, #16]
    str r2, [sp, #8]
    str r6, [sp, #0]
@=======PUT PILHA

    add r1, #0x800		@ Adicionar o offset padrão do gpio
    ldr r6, [r8, r1]            @ Acessar pinos com deslocamento

    ldr r2, =\pino
    add r2, #4			
    ldr r2, [r2]		@Deslocamento dentro do registrador data

    mov r0, #0x01		@Registrador pra servir como máscara
    lsl r0, r0, r2		@r0 tem 1 somente no bit que é para ser high
                                
    orr r6, r6, r0		@Somente o bit correspondente é setado como 1 e os outros não são alterados.
    str r6, [r8, r1]            @Carrega a configuração

@=======POP PILHA
    ldr r0, [sp, #16]
    ldr r2, [sp, #8]
    ldr r6, [sp, #0]
    add sp, sp, #24
@=======POP PILHA

    bx lr


@ Preciso de uma função que seta o pino de saída em ALTO. recebe o pino como parametro
@SetPinGPIOHigh
.macro SetPinGPIOHigh pino
    
    sub sp, sp, #8
    str r1, [sp, #0]

    ldr r1, =\pino
    ldr r1, [r1]
    
    bl labelPinHigh

    ldr r1, [sp, #0]
    add sp, sp, #8
.endm

labelPinLow:
@=======PUT PILHA
    sub sp, sp, #24
    str r0, [sp, #16]
    str r2, [sp, #8]
    str r6, [sp, #0]
@=======PUT PILHA
    add r1, #0x800		@ Adicionar o offset padrão do gpio
    ldr r6, [r8, r1]            @Acessar pinos com deslocamento

    ldr r2, =\pino
    add r2, #4			
    ldr r2, [r2]		@Deslocamento dentro do registrador data

    mov r0, #0x01		@Registrador pra servir como máscara
    lsl r0, r0, r2		@r0 tem 1 somente no bit que é para ser low
                                
    bic r6, r6, r0		@Somente o bit correspondente é setado como 0 e os outros não são alterados.
    str r6, [r8, r1]            @Carrega a configuração
@=======POP PILHA
    ldr r0, [sp, #16]
    ldr r2, [sp, #8]
    ldr r6, [sp, #0]
    add sp, sp, #24
@=======POP PILHA
    bx lr


@ Preciso de uma função que seta o pino de saída em BAIXO. recebe o pino como parametro
@SetPinGPIOLow
.macro SetPinGPIOLow pino
    sub sp, sp, #8
    str r1, [sp, #0]

    ldr r1, =\pino		@ Offset do registrador data
    ldr r1, [r1] 		@ Carregando valor

    bl labelPinLow

    ldr r1, [sp, #0]
    add sp, sp, #8

.endm

labelPinOut:
@=======PUT PILHA
    sub sp, sp, #24
    str r0, [sp, #16]
    str r1, [sp, #8]
    str r3, [sp, #0]
@=======PUT PILHA
    add r2, #0x800		@ Adicionar o offset padrão do gpio
    
    ldr r1, [r8, r2] 		@ Valor no registrador select

    ldr r3, =\pino 		@ Endereço do deslocamento específico para o pino
    add r3, #12 		@ Deslocamento para a posição do offset dentro do registrador select
    ldr r3, [r3] 		@ Carrega o valor

    mov r0, #0b111 		@ Registrador a ser usado como máscara
    lsl r0, r3 			@ Desloca para a posicao da máscara (Onde os 3 bits do pino estarão)
    bic r1, r0 			@ Limpa os bits

    mov r0, #1 			@ 1 para deslocar e setar como 001(output)
    lsl r0, r3 			@ Deslocamento de acordo com o data do pino
    orr r1, r0 			@ Seta o bit como 1

    str r1, [r8, r2] 		@ Salva novamente no endereço
@=======POP PILHA
    ldr r0, [sp, #16]
    ldr r1, [sp, #8]
    ldr r3, [sp, #0]
    add sp, sp, #24
@=======POP PILHA
    bx lr


@ Preciso de uma função que seta o pino como saída. recebe o pino como parametro
@setPinGPIOOut
.macro setPinGPIOOut pino
    sub sp, sp, #8
    str r2, [sp, #0]

    ldr r2, =\pino 		@ Primeiro valor do .data do pino
    add r2, #8			@ Offset do registrador select
    ldr r2, [r2] 		@ Carrega o valor

    bl labelPinOut

    ldr r2, [sp, #0]
    add sp, sp, #8   

.endm


labelPinIn:
@=======PUT PILHA
    sub sp, sp, #24
    str r0, [sp, #16]
    str r1, [sp, #8]
    str r3, [sp, #0]
@=======PUT PILHA
    add r2, #0x800		@ Adicionar o offset padrão do gpio

    ldr r1, [r8, r2] 		@ Valor no registrador select

    ldr r3, =\pino 		@ Endereço do deslocamento específico para o pino
    add r3, #12 		@ Deslocamento para a posição do offset dentro do registrador select
    ldr r3, [r3] 		@ Carrega o valor

    mov r0, #0b111 		@ Registrador a ser usado como máscara
    lsl r0, r3 			@ Desloca para a posicao da máscara (Onde os 3 bits do pino estarão)
    bic r1, r0 			@ Limpa os bits 000(input)

    str r1, [r8, r2] 		@ Salva novamente no endereço

@=======POP PILHA
    ldr r0, [sp, #16]
    ldr r1, [sp, #8]
    ldr r3, [sp, #0]
    add sp, sp, #24
@=======POP PILHA
    bx lr


@ Preciso de uma função que seta o pino como entrada. recebe o pino como parametro
@setPinGPIOIn
.macro setPinGPIOIn pino
    sub sp, sp, #8
    str r2, [sp, #0]

    ldr r2, =\pino 		@ Primeiro valor do .data do pino
    add r2, #8			@ Offset do registrador select
    ldr r2, [r2] 		@ Carrega o valor

    bl labelPinIn

    ldr r2, [sp, #0]
    add sp, sp, #8   

.endm

@ Retorna o valor lido no pino R0
labelreadPin:
@=======PUT PILHA
    sub sp, sp, #8
    str r6, [sp, #0]
@=======PUT PILHA

    add r1, #0x800		@ Adicionar o offset padrão do gpio
    ldr r6, [r8, r1]            @ Acessar pinos com deslocamento

    mov r0, #0x01		@Registrador pra servir como máscara
    lsl r0, r0, r2		@r0 tem 1 somente no bit que é para ser lido
                                
    and r0, r6			@Somente o bit correspondente é setado como 1 se no reg também estiver como 1, ou zero caso contrário.
    lsr r0, r2			@Armazena em r0 o valor que está no pino

@=======POP PILHA
    ldr r6, [sp, #0]
    add sp, sp, #8
@=======POP PILHA
    bx lr


.macro readPinGPIO pino

    sub sp, sp, #16
    str r1, [sp, #0]
    str r2, [sp, #8]


    ldr r1, =\pino		@ Offset do registrador data
    ldr r1, [r1] 		@ Carregando valor

    ldr r2, =\pino
    add r2, #4			
    ldr r2, [r2]		@Deslocamento dentro do registrador data

    bl labelreadPin

    ldr r2, [sp, #8]
    ldr r1, [sp, #0]
    add sp, sp, #16

.endm

@ Preciso de uma função que seta o pino de saída para o valor passado (0 ou 1). Recebe o high ou low e recebe o id do pino
@setStatePinGPIO (Usando reg R3 para o pino e R4 para o high ou low)
setStatePinGPIO:

@=======PUT PILHA
    sub sp, sp, #32
    str r0, [sp, #24]
    str r1, [sp, #16]
    str r6, [sp, #8]
    str r7, [sp, #0]
@=======PUT PILHA

    mov r6, r3			@Copio o endereço do pino para r6
    ldr r6, [r6]

    add r6, #0x800		@ Adicionar o offset padrão do gpio
    ldr r7, [r8, r6]            @ Acessar pinos com deslocamento

    mov r1, r3
    add r1, #4			
    ldr r1, [r1]		@Deslocamento dentro do registrador data

    mov r0, r4			@Registrador pra servir como máscara

    cmp r0, #0      		@Compara o valor em r0 com zero
    beq setOff    		@Desvia para a operacao de se o valor a ser setado é 0 setOff
	
    lsl r0, r0, r1		@r0 tem 1 somente no bit que é para ser high                         
    orr r7, r7, r0		@Somente o bit correspondente é setado como 1 e os outros não são alterados.
	
    b end

    setOff:
    mov r0, #1
    lsl r0, r0, r1		@r0 tem 1 somente no bit que é para ser low                          
    bic r7, r7, r0		@Somente o bit correspondente é setado como 0 e os outros não são alterados.
	
    end:
    str r7, [r8, r6]    @Carrega a configuração
    bx lr

@=======POP PILHA
    ldr r0, [sp, #24]
    ldr r1, [sp, #16]
    ldr r6, [sp, #8]
    ldr r7, [sp, #0]
    add sp, sp, #32
@=======POP PILHA


/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ------------------------------------------------
    Setando os pinos que vão para o display como saída 
    ------------------------------------------------
*/
.macro setOut
	setPinGPIOOut db7
	setPinGPIOOut db6
	setPinGPIOOut db5
	setPinGPIOOut db4
	setPinGPIOOut RS
.endm

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
