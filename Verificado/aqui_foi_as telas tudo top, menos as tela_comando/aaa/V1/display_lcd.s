// ==================================================================================================================================================== //
// ============================================================BLOCO DE FUNÇÕES BASE=================================================================== //
// ==================================================================================================================================================== //




/* 
    ------------------------------------------------
            Define as configurações do display
    ------------------------------------------------
    Informa se os dados são transmitidos por 9 bits ou por 4 bits
    Informa se vou usar uma ou duas linhas
    Informa qual a fonte usada pelos caracteres, a menor (5x8) ou maior (5x10)
    !! Não dá para usar a fonte maior e ter duas linhas
*/ 
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


/* 
    ------------------------------------------------
                Limpa a tela do display 
    ------------------------------------------------
    Coloca 0000 dá enable
    Coloca 0001 dá enable
*/
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


/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
    (os tempos que estão aqui devem estar em .data)
    ------------------------------------------------
        Informa ao display para executar a instrução
    ------------------------------------------------
    Dá o pulso de enable para o display observar os 4 bits
*/
.macro enableDisplay
    SetPinGPIOHigh E
    nanoSleep timeZero, time1ms
    SetPinGPIOLow E
    @nanoSleep timeZero, time1ms @ !!! Confirmar a necessidade desse último timer em low por tanto tempo, talvez só precise fazer o gpiolow
.endm


/* 
    ------------------------------------------------
            Coloca o cursor na  posição 0
    ------------------------------------------------
*/
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


/* 
    ------------------------------------------------
    Desloca posição do cursor para direita em 1 caracter
    ------------------------------------------------
*/ 
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

/* 
    ------------------------------------------------
    Desloca posição do cursor para esquerda em 1 caracter
    ------------------------------------------------
*/ 
.macro cursorShiftLeft
	SetPinGPIOLow RS
    @SetPinGPIOLow RW

	SetPinGPIOLow db7
	SetPinGPIOLow db6
	SetPinGPIOLow db5
	SetPinGPIOHigh db4
	enableDisplay @ 0001

	@SetPinGPIOLow db7 @ 0 para deslocar o cursor, 1 para a exibição/tela
	SetPinGPIOLow db6 @ 1 para direita e 0 para esquerda
	@SetPinGPIOLow db5 
	@SetPinGPIOLow db4 
	enableDisplay @ 00xx
.endm


/* 
    ------------------------------------------------
                Desliga o display
    ------------------------------------------------
*/ 
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


/* 
    ------------------------------------------------
                Liga o display
    ------------------------------------------------
*/ 
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


/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ------------------------------------------------
            Verifica se o LCD está ocupado
    ------------------------------------------------
    Serve para verificar se o LCD está realizando alguma instrução.
    Só posso mandar outro comando quando a busyflag for 0.
    A busyFlag vai estar em db7.
    !!! Posso colocar para ele esperar pelo tempo máximo que pode ficar
    na instrução, aí não teria que verificar o busyflag
*/ 
.macro ReadBusyFlag
    @ Seta os pinos como entrada

    SetPinGPIOLow RS
    @SetPinGPIOHigh RW
    enableDisplay
.endm


/* 
    ------------------------------------------------
            Definindo o modo de entrada
    ------------------------------------------------
    Define que o cursor é deslocado para direita/esquerda sempre que escrever um carcter
    Define se o cursor será movimentado ou o display
*/ 
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







/*=================================================================================================================*/

/*
    ------------------------------------------------
    Função que faz uma mascara para obter o valor de um bit
    ------------------------------------------------
    Registradores de Parâmetros e Retornos:
    	* r9 -> reg que possui o bit a ser lido
    	* r2 -> posição a ser analisada em r9
    	* r0 -> valor de retorno (se o bit era 1 ou 0)
*/
@ Chamo com bl ou blx
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

/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ------------------------------------------------
                Escreve um caracter
    ------------------------------------------------
    Recebe um valor que corresponde ao caracter a ser exibido. Por exemplo:
    01010100 para escrever o T
*/
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

/* Macro para evitar trechos longos e repetidos de código na inicialização do LCD */
.macro FunctionSetParcial
    SetPinGPIOLow db7
    SetPinGPIOLow db6
    SetPinGPIOHigh db5
    SetPinGPIOHigh db4
    enableDisplay
.endm





/* (PARTE ESPECIFICA DO PROJETO) Muda a tipo de tela de Recebimento para Envio 
*/
.macro mem
.endm

// ==================================================================================================================================================== //
// ============================================================BLOCO DE FUNÇÕES ALTAS================================================================== //
// ==================================================================================================================================================== //

/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ------------------------------------------------
    Desloca posição do cursor para posição determinada
    ------------------------------------------------
Faz o deslocamento de 1 em 1 unidade para a direita até atingir a posição especificada.
pos é um  valor absoluto, ou seja, ele não leva em conta a posição atual do cursor e sim a posição em relação a posição 0
pos precisa estar entre 1 e 32 
*/     
setCursorPos:
    MOV R9, R2
    setInitialCursorPos @ Preciso jogar o cursor na posição inicial, pois pos não é relativo
    
    CMP R9, #0 @ Para ver se não entro no while
    BGT WHILE3
    bx lr
    
    WHILE3:
        cursorShiftRight
        SUB R9, #1
        CMP R9, #0
        BGT WHILE3
        bx lr


/*  
    ------------------------------------------------ 
    Inicializa o display, como sugere o datasheet 
    ------------------------------------------------
*/
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



/* Escreve a temperatura 
*/

/* Escreve a umidade
*/

/* Escreve a situação do sensor
*/


