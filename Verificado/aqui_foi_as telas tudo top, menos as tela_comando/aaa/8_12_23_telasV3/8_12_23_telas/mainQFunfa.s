.equ PROT_READ, 1
.equ PROT_WRITE, 2
.equ MAP_SHARED, 1
.equ S_RDWR, 0666

@ Chamar as funções do display
.global _start


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

.macro setOut
	setPinGPIOOut db7
	setPinGPIOOut db6
	setPinGPIOOut db5
	setPinGPIOOut db4
	setPinGPIOOut RS
	setPinGPIOOut E
.endm

.macro nanoSleep timesec timenano
    ldr r0, =\timesec   @ COLOCA AQUI OQ ESSE CARA FAZ
    ldr r1, =\timenano      @ COLOCA AQUI OQ ESSE CARA FAZ
    mov r7, #162    @ #sys_nanosleep = 162 é o valor que precisa estar em r7 para o SO entender que se trata de um sleep
    svc 0
.endm

.macro enableDisplay
    SetPinGPIOHigh E
    nanoSleep timeZero, time1ms
    SetPinGPIOLow E
    @nanoSleep timeZero, time1ms @ !!! Confirmar a necessidade desse último timer em low por tanto tempo, talvez só precise fazer o gpiolow
.endm

.macro FunctionSetParcial
    SetPinGPIOLow db7
    SetPinGPIOLow db6
    SetPinGPIOHigh db5
    SetPinGPIOHigh db4
    enableDisplay
.endm

.macro FunctionSet
	SetPinGPIOLow RS
    @SetPinGPIOLow RW
    @@ Parte 1
	SetPinGPIOLow db7
	SetPinGPIOLow db6
	SetPinGPIOHigh db5
	SetPinGPIOLow db4 @ 1 para informar que os dados são mandados em 8bit e 0 para 4 bits
	enableDisplay @ db7-db4  0 0 1 0
    @@ Parte 2
	SetPinGPIOHigh db7 @ 1 para 2 linhas e 0 para uma linha
	SetPinGPIOLow db6 @ Fonte de caracters: 1 para 5x10 pontos e 0 para 5x8 pontos
	@SetPinGPIOLow db5
	@SetPinGPIOLow db4
	enableDisplay @ db7-db4  1 1 x x
.endm

.macro clearDisplay
	SetPinGPIOLow RS
    @SetPinGPIOLow RW
    @ Parte 1
	SetPinGPIOLow db7
	SetPinGPIOLow db6
	SetPinGPIOLow db5
	SetPinGPIOLow db4
	enableDisplay
    @ Parte 2
	@SetPinGPIOLow db7
	@SetPinGPIOLow db6
	@SetPinGPIOLow db5
	SetPinGPIOHigh db4
	enableDisplay
.endm


.macro EntryModeSet
	SetPinGPIOLow RS
    @SetPinGPIOLow RW
    @@@ Parte 1 
	SetPinGPIOLow db7
	SetPinGPIOLow db6
	SetPinGPIOLow db5
	SetPinGPIOLow db4
	enableDisplay
    @@@ Parte 2 
	@SetPinGPIOLow db7
	SetPinGPIOHigh db6
	SetPinGPIOHigh db5 @ 1 para direita e 0 para esquerda
	@SetPinGPIOLow db4  @ Move o cursor em vez da tela
	enableDisplay 
.endm

.macro DisplayOn
    @@@ Parte 1
    SetPinGPIOLow db7
    SetPinGPIOLow db6
    SetPinGPIOLow db5
    SetPinGPIOLow db4
    enableDisplay
    @@@ Parte 2
    SetPinGPIOHigh db7
    SetPinGPIOHigh db6 @ liga o display
    SetPinGPIOHigh db5 @ exibe o cursor
    SetPinGPIOLow db4 @ O carcter indicado pelo cursor não pisca
    enableDisplay
.endm

.macro DisplayOff
    @@@ Parte 1
    SetPinGPIOLow db7
    SetPinGPIOLow db6
    SetPinGPIOLow db5
    SetPinGPIOLow db4
    enableDisplay
    @@@ Parte 2
    SetPinGPIOHigh db7
    SetPinGPIOLow db6 @ Desliga o display
    SetPinGPIOLow db5 @ Oculta o cursor
    SetPinGPIOLow db4 @ O carcter indicado pelo cursor não pisca
    enableDisplay
.endm

.macro initDisplay
    nanoSleep timeZero, time100ms

    SetPinGPIOLow RS
    @SetPinGPIOLow RW

    FunctionSetParcial
    .ltorg
    nanoSleep timeZero, time5ms @ Aguarda por mais de 4.1ms

    FunctionSetParcial
    nanoSleep timeZero, time150us @ Aguarda por mais de 100us
    .ltorg 
    FunctionSetParcial
    nanoSleep timeZero, time150us @ Aguarda por mais de 100us
    @@@@@@@@@@@@@@@@@@@@@@ APÒS AQUI DEVO VER O BF @@@@@@@@@@@@@@@@@@@@@@

    @@@ FunctionSet !!(É esse o que vale)!! OK
    SetPinGPIOLow db7
    SetPinGPIOLow db6
    SetPinGPIOHigh db5
    SetPinGPIOLow db4 @ Indica que os dados são de 4 em 4 bits
    .ltorg 
    enableDisplay
    nanoSleep timeZero, time150us @ Aguarda por mais de 100us
    
    
    FunctionSet
    nanoSleep timeZero, time60us @ Aguarda por mais de 100us
    
    DisplayOff
    nanoSleep timeZero, time60us @ Aguarda por mais de 100us
    
    clearDisplay
    nanoSleep timeZero, time3ms @ Aguarda por mais de 100us
    
    EntryModeSet
    nanoSleep timeZero, time60us @ Aguarda por mais de 100us
    @@@ O procedimento indicado acaba aqui @@@
    DisplayOn
    nanoSleep timeZero, time60us @ Aguarda por mais de 100us
    EntryModeSet
    .ltorg @ OQ é isso?
.endm

setStatePinGPIO:
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

mascaraBit: 
    @ Colocando na pilha r5 e r7
    @sub sp, sp, #16
    @str r5,[sp,#8]
    @stur r7,[sp,#0]

    mov r5, #1 @Crio uma maskara em r5  ...0000001
	lsr r7, r9, r2 @ Pego r9, desloco r8 bits para a esquerda e guardo no temporario r7
    and r0, r7, r5 @ Aplico a mascara para obter o valor no bit menos significativo

    @ Retirando da pilha r5 e r7
    @ldur r5,[sp,#8]
    @ldur r7,[sp,#0]
    @add sp, sp, #16

    bx lr @ Retorno o PC para quem chamou a função

.macro WriteChar char
    MOV R9, \char
    SetPinGPIOHigh RS

    @ Primeira parte dos dados
    MOV R2, #7 @ Informa qual o bit vou ler primeiro. Aqui estou vendo se o o bit 7 (da dir para esq) é 1 ou 0
    BL mascaraBit @ O valor vai estar em R0
    @ # Informo que é o pino db7 no reg R3
    ldr R3, =db7 @TALVEZ N FUNCIONE
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg R4
    mov r4, r0
    BL setStatePinGPIO

    MOV R2, #6
    BL mascaraBit
    @ # Informo que é o pino db6
    ldr R3, =db6 @TALVEZ N FUNCIONE
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    mov r4, r0
    BL setStatePinGPIO

    MOV R2, #5
    BL mascaraBit
    @ # Informo que é o pino db5
    ldr R3, =db5 @TALVEZ N FUNCIONE
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    mov r4, r0
    BL setStatePinGPIO

    MOV R2, #4
    BL mascaraBit
    @ # Informo que é o pino db4
    ldr R3, =db4 @TALVEZ N FUNCIONE
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    mov r4, r0
    BL setStatePinGPIO

    enableDisplay

    @ Segunda parte dos dados
    MOV R2, #3
    BL mascaraBit
    @ # Informo que é o pino db7
    ldr R3, =db7 @TALVEZ N FUNCIONE
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    mov r4, r0
    BL setStatePinGPIO

    MOV R2, #2
    BL mascaraBit
    @ # Informo que é o pino db6
    ldr R3, =db6 @TALVEZ N FUNCIONE
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    mov r4, r0
    BL setStatePinGPIO

    MOV R2, #1
    BL mascaraBit
    @ # Informo que é o pino db5
    ldr R3, =db5 @TALVEZ N FUNCIONE
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    mov r4, r0
    BL setStatePinGPIO @ Faz a mudança de estado do pino

    MOV R2, #0
    BL mascaraBit
    @ # Informo que é o pino db4
    ldr R3, =db4 @TALVEZ N FUNCIONE
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    mov r4, r0
    BL setStatePinGPIO

    enableDisplay

.endm

.macro setInitialCursorPos
	SetPinGPIOLow RS
    @SetPinGPIOLow RW

	SetPinGPIOLow db7
	SetPinGPIOLow db6
	SetPinGPIOLow db5
	SetPinGPIOLow db4
	enableDisplay @ 0000

	@SetPinGPIOLow db7
	@SetPinGPIOLow db6
	SetPinGPIOHigh db5
	@SetPinGPIOLow db4
	enableDisplay @ 001x
.endm

.macro cursorShiftRight
	SetPinGPIOLow RS
    @SetPinGPIOLow RW

	SetPinGPIOLow db7
	SetPinGPIOLow db6
	SetPinGPIOLow db5
	SetPinGPIOHigh db4
	enableDisplay @ 0001

	@SetPinGPIOLow db7 @ 0 para deslocar o cursor, 1 para a exibição/tela
	SetPinGPIOHigh db6 @ 1 para direita e 0 para esquerda
	@SetPinGPIOLow db5 
	@SetPinGPIOLow db4 
	enableDisplay @ 01xx
.endm

WHILE:
        cursorShiftRight
        nanoSleep timeZero, time150us @@ Preciso mesmo disso aqui??? Tirar depois 
        SUB R0, #1
        CMP R0, #0
        BGT WHILE
        
.macro setCursorPos pos
    MOV R0, \pos
    setInitialCursorPos @ Preciso jogar o cursor na posição inicial, pois pos não é relativo
    cursorShiftRight
    nanoSleep timeZero, time150us @@ Preciso mesmo disso aqui??? Tirar depois 
    SUB R0, #1
    CMP R0, #0
    BGT WHILE
.endm

        
_start:
	MemoryMap
	
	setOut
	.ltorg
	initDisplay
	WriteChar #70
	
	setCursorPos #24
	WriteChar #76
	

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
