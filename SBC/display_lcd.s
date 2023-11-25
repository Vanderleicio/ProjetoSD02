// ==================================================================================================================================================== //
// ============================================================BLOCO DE FUNÇÕES BASE=================================================================== //
// ==================================================================================================================================================== //

/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ------------------------------------------------
    Setando os pinos que vão para o display como saída 
    ------------------------------------------------
*/



/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ------------------------------------------------
    Setando os pinos que vão para o display como entrada 
    ------------------------------------------------
    Esta macro só serve para auxiliar na leitura do busyflag
*/



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
    SetPinGPIOLow RW
    @@ Parte 1
	SetPinGPIOLow db7
	SetPinGPIOLow db6
	SetPinGPIOHigh db5
	SetPinGPIOLow db4 @ 1 para informar que os dados são mandados em 8bit e 0 para 4 bits
	enableDisplay @ db7-db4  0 0 1 0
    @@ Parte 2
	SetPinGPIOLow db7 @ 1 para 2 linhas e 0 para uma linha
	SetPinGPIOLow db6 @ Fonte de caracters: 1 para 5x10 pontos e 0 para 5x8 pontos
	@SetPinGPIOHigh db5
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
    SetPinGPIOLow RW
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
    nanoSleep timeZero, time1ms @ !!! Confirmar a necessidade desse último timer em low por tanto tempo, talvez só precise fazer o gpiolow
.endm


/* 
    ------------------------------------------------
            Coloca o cursor na  posição 0
    ------------------------------------------------
*/
.macro setInitialCursorPos
	SetPinGPIOLow RS
    SetPinGPIOLow RW

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
.macro shiftRightCursor
	SetPinGPIOLow RS
    SetPinGPIOLow RW

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
.macro shiftLeftCursor
	SetPinGPIOLow RS
    SetPinGPIOLow RW

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
    SetPinGPIOHigh RW
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
    SetPinGPIOLow RW
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
    @ INSERIR AQUI
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg R4
    @ INSERIR AQUI
    BL setStatePinGPIO

    MOV R2, #6
    BL mascaraBit
    @ # Informo que é o pino db6
    @ INSERIR AQUI
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    @ INSERIR AQUI
    BL setStatePinGPIO

    MOV R2, #5
    BL mascaraBit
    @ # Informo que é o pino db5
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    BL setStatePinGPIO

    MOV R2, #4
    BL mascaraBit
    @ # Informo que é o pino db4
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    BL setStatePinGPIO

    enableDisplay

    @ Segunda parte dos dados
    MOV R2, #3
    BL mascaraBit
    @ # Informo que é o pino db7
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    BL setStatePinGPIO

    MOV R2, #2
    BL mascaraBit
    @ # Informo que é o pino db6
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    BL setStatePinGPIO

    MOV R2, #1
    BL mascaraBit
    @ # Informo que é o pino db5
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    BL setStatePinGPIO @ Faz a mudança de estado do pino

    MOV R2, #0
    BL mascaraBit
    @ # Informo que é o pino db4
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
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
.macro setCursorPos pos
    MOV R0, \pos
    setInitialCursorPos @ Preciso jogar o cursor na posição inicial, pois pos não é relativo
    WHILE:
        cursorShiftRight
        nanoSleep timeZero, time150us @@ Preciso mesmo disso aqui??? Tirar depois 
        SUB R0, #1
        CMP R0, #0
        BGT WHILE
.endm


/*  
    ------------------------------------------------ 
    Inicializa o display, como sugere o datasheet 
    ------------------------------------------------
*/
.macro initDisplay
    nanoSleep timeZero, time15ms

    SetPinGPIOLow RS
    SetPinGPIOLow RW

    FunctionSetParcial
    nanoSleep timeZero, time5ms @ Aguarda por mais de 4.1ms

    FunctionSetParcial
    nanoSleep timeZero, time150us @ Aguarda por mais de 100us

    FunctionSetParcial

    @@@@@@@@@@@@@@@@@@@@@@ APÒS AQUI DEVO VER O BF @@@@@@@@@@@@@@@@@@@@@@

    @@@ FunctionSet !!(É esse o que vale)!! OK
    SetPinGPIOLow db7
    SetPinGPIOLow db6
    SetPinGPIOHigh db5
    SetPinGPIOLow db4 @ Indica que os dados são de 4 em 4 bits
    enableDisplay

    FunctionSet
    DisplayOff
    clearDisplay
    EntryModeSet
    @@@ O procedimento indicado acaba aqui @@@
    DisplayOn
    EntryModeSet
	.ltorg
.endm



/* Escreve a temperatura 
*/

/* Escreve a umidade
*/

/* Escreve a situação do sensor
*/