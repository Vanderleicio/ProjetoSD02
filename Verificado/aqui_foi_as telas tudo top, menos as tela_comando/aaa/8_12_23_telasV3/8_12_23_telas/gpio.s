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



@ Preciso de uma função que seta o pino de saída em ALTO. recebe o pino como parametro
@SetPinGPIOHigh
.macro SetPinGPIOHigh pino
    ldr r1, =\pino		@ Offset do registrador data
    ldr r1, [r1] 		@ Carregando valor

    add r1, #0x800		@ Adicionar o offset padrão do gpio
    ldr r6, [r8, r1]            @ Acessar pinos com deslocamento

    ldr r2, =\pino
    add r2, #4			
    ldr r2, [r2]		@Deslocamento dentro do registrador data

    mov r0, #0x01		@Registrador pra servir como máscara
    lsl r0, r0, r2		@r0 tem 1 somente no bit que é para ser high
                                
    orr r6, r6, r0		@Somente o bit correspondente é setado como 1 e os outros não são alterados.
    str r6, [r8, r1]            @Carrega a configuração
.endm


@ Preciso de uma função que seta o pino de saída em BAIXO. recebe o pino como parametro
@SetPinGPIOLow
.macro SetPinGPIOLow pino
    ldr r1, =\pino		@ Offset do registrador data
    ldr r1, [r1] 		@ Carregando valor

    add r1, #0x800		@ Adicionar o offset padrão do gpio
    ldr r6, [r8, r1]            @Acessar pinos com deslocamento

    ldr r2, =\pino
    add r2, #4			
    ldr r2, [r2]		@Deslocamento dentro do registrador data

    mov r0, #0x01		@Registrador pra servir como máscara
    lsl r0, r0, r2		@r0 tem 1 somente no bit que é para ser low
                                
    bic r6, r6, r0		@Somente o bit correspondente é setado como 0 e os outros não são alterados.
    str r6, [r8, r1]            @Carrega a configuração
.endm

@ Preciso de uma função que seta o pino como saída. recebe o pino como parametro
@setPinGPIOOut
.macro setPinGPIOOut pino
    ldr r2, =\pino 		@ Primeiro valor do .data do pino
    add r2, #8			@ Offset do registrador select
    ldr r2, [r2] 		@ Carrega o valor
    
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
.endm

@ Preciso de uma função que seta o pino como entrada. recebe o pino como parametro
@setPinGPIOIn
.macro setPinGPIOIn pino
    ldr r2, =\pino 		@ Primeiro valor do .data do pino
    add r2, #8			@ Offset do registrador select
    ldr r2, [r2] 		@ Carrega o valor
    
    add r2, #0x800		@ Adicionar o offset padrão do gpio

    ldr r1, [r8, r2] 		@ Valor no registrador select

    ldr r3, =\pino 		@ Endereço do deslocamento específico para o pino
    add r3, #12 		@ Deslocamento para a posição do offset dentro do registrador select
    ldr r3, [r3] 		@ Carrega o valor

    mov r0, #0b111 		@ Registrador a ser usado como máscara
    lsl r0, r3 			@ Desloca para a posicao da máscara (Onde os 3 bits do pino estarão)
    bic r1, r0 			@ Limpa os bits 000(input)

    str r1, [r8, r2] 		@ Salva novamente no endereço
.endm

.macro readPinGPIO pino
    ldr r1, =\pino		@ Offset do registrador data
    ldr r1, [r1] 		@ Carregando valor

    add r1, #0x800		@ Adicionar o offset padrão do gpio
    ldr r6, [r8, r1]            @ Acessar pinos com deslocamento

    ldr r2, =\pino
    add r2, #4			
    ldr r2, [r2]		@Deslocamento dentro do registrador data

    mov r0, #0x01		@Registrador pra servir como máscara
    lsl r0, r0, r2		@r0 tem 1 somente no bit que é para ser lido
                                
    and r0, r6			@Somente o bit correspondente é setado como 1 se no reg também estiver como 1, ou zero caso contrário.
    lsr r0, r2			@Armazena em r0 o valor que está no pino
.endm

@ Preciso de uma função que seta o pino de saída para o valor passado (0 ou 1). Recebe o high ou low e recebe o id do pino
@setStatePinGPIO (Usando reg R3 para o pino e R4 para o high ou low)

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
	setPinGPIOOut E
.endm


/* Aqui eu verifico se o botão foi pressionado
Se o botão foi pressionado R4 vai ser 1
Se não, vai ser 0
*/
debounce:
	readPinGPIO bOk @ O estado fica em r0
	CMP r8, #0
	BEQ SLEEEP @ Se o botão for 0 (acionado), vou para o sleep
	mov r4, #0
	B END
	SLEEEP:
		nanoSleep timeZero, time60us
		readPinGPIO bOk @ O estado fica em r0
		CMP r8, #0
		
	END:
	
	@ volta

