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
    Coloca 0000 em d7-d4 e dá enable
    Coloca 0001 em d7-d4 e dá enable
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


/* !!!!!!!!!!!!!!!!!! AVALIAR MUDAR PARA FUNÇÃO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
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
cursorShiftRight:
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
	bx lr 


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



/*
    ------------------------------------------------
                Escreve um caracter
    ------------------------------------------------
    Em R1 deve estar o parametro que indica o caracter que deverá ser escrito
    Recebe um valor que corresponde ao caracter a ser exibido. Por exemplo:
    01010100 para escrever o T
*/
WriteCharLCD:
    MOV R9, R1
    SetPinGPIOHigh RS

    @ Primeira parte dos dados
    MOV R2, #7 @ Informa qual o bit vou ler primeiro. Aqui estou vendo se o o bit 7 (da dir para esq) é 1 ou 0
    BL mascaraBit  @ Retorna em R0 o estado que o pino deverá assumir
    @ # Informo que é o pino db7 no reg R3
    ldr R3, =db7 @TALVEZ N FUNCIONE
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg R4
    mov r4, r0
    BL setStatePinGPIO

    MOV R2, #6
    BL mascaraBit  @ Retorna em R0 o estado que o pino deverá assumir
    @ # Informo que é o pino db6
    ldr R3, =db6 @TALVEZ N FUNCIONE
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    mov r4, r0
    BL setStatePinGPIO

    MOV R2, #5
    BL mascaraBit  @ Retorna em R0 o estado que o pino deverá assumir
    @ # Informo que é o pino db5
    ldr R3, =db5 @TALVEZ N FUNCIONE
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    mov r4, r0
    BL setStatePinGPIO

    MOV R2, #4
    BL mascaraBit  @ Retorna em R0 o estado que o pino deverá assumir
    @ # Informo que é o pino db4
    ldr R3, =db4 @TALVEZ N FUNCIONE
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    mov r4, r0
    BL setStatePinGPIO

    enableDisplay

    @ Segunda parte dos dados
    MOV R2, #3
    BL mascaraBit  @ Retorna em R0 o estado que o pino deverá assumir
    @ # Informo que é o pino db7
    ldr R3, =db7 @TALVEZ N FUNCIONE
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    mov r4, r0
    BL setStatePinGPIO

    MOV R2, #2
    BL mascaraBit  @ Retorna em R0 o estado que o pino deverá assumir
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
    BL mascaraBit @ Retorna em R0 o estado que o pino deverá assumir
    @ # Informo que é o pino db4
    ldr R3, =db4 @TALVEZ N FUNCIONE
    @ # Informo se o pino deve ir para HIGH ou LOW, coloco 0 ou 1 no reg
    mov r4, r0
    BL setStatePinGPIO

    enableDisplay
    bx lr


/* 
    ------------------------------------------------
        Escreve um caracter número no display
    ------------------------------------------------
    Em R1 deve estar o parametro que indica o número que deverá ser escrito
    Recebe um valor que corresponde ao caracter a ser exibido. Por exemplo:
    00000111 para escrever o 7.
    Como eu trato números como valores inteiros.
*/
WriteNumberLCD:
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário

    add R1, #48, R1 @# 00110000(48) + number = 0011 0111 = asc para 7
    bl WriteCharLCD

    ldr lr,[sp,#0]
    add sp, sp, #8
    
    bx lr


/* Macro para evitar trechos longos e repetidos de código na inicialização do LCD */
.macro FunctionSetParcial
    SetPinGPIOLow db7
    SetPinGPIOLow db6
    SetPinGPIOHigh db5
    SetPinGPIOHigh db4
    enableDisplay
.endm





// ==================================================================================================================================================== //
// ============================================================BLOCO DE FUNÇÕES ALTAS================================================================== //
// ==================================================================================================================================================== //

/* 
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

    @ Espera-se que eu nunca use esta função para ir para a posição 0 (Talvez eu remova ela)
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



/* 
    ------------------------------------------------ 
            Escreve a temperatura no display
    ------------------------------------------------
    Supõe que os dados da UART estão no reg R12.
    Escreve como o exemplo: S04 TEMP: 23ºC
*/
WriteTemperatureLCD:
    @ Salvo o endereço de quem chamou a função, pois vou entrar em outras funções aqui dentro. O lr inicial seria perdido
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário

    setInitialCursorPos @ Zera todo o cursor para conseguir escrever direito
    clearDisplay @ Para garantir que não vai ter lixo na tela
    @ Escreve S
    mov R1, #0b01010011
    bl WriteCharLCD

    @ ================ TRECHO PARA ESCREVER O Nº DO SENSOR
    @ FAZ A MASCARA PARA PEGAR APENAS O NÚMERO DO SENSOR E JOGA EM R3
    @ CHAMAR AQUI A MASCARA
    mov R3, R12 @ Parametro da função !!!!! (ESSE R12 está errado, deverá ser onde estiver após a mascara)
    bl SeparaDezenaUnidadeV2@ Dezena em r4 e unidade em r5
    mov r1, r4 @ coloco a dezena como parametro
    @ Escreve a dezena correspondente ao número do sensor. Ex: caso fosse o nº21, iria escrever 2
    bl WriteNumberLCD
    @ Escreve a unidade correspondente ao número do sensor. Ex: caso fosse o nº21, iria escrever 1
    mov r1, r5 @ pego o valor da unidade e coloco como parametro
    bl WriteNumberLCD
    @ ==============

    cursorShiftRight@ Suponndo que dá o espaço
    @ ESCREVE 'TEMP'
    mov R1, #0b01010100 @ T
    bl WriteCharLCD
    mov R1, #0b01000101 @ E
    bl WriteCharLCD
    mov R1, #0b01001101 @ M
    bl WriteCharLCD
    mov R1, #0b01010000 @ P
    bl WriteCharLCD

    @ Escreve :
    mov R1, #0b00111010
    bl WriteCharLCD
    cursorShiftRight@ Suponndo que dá o espaço

    @ ================ TRECHO PARA ESCREVER O VALOR DA TEMPERATURA
    @ FAZ A MASCARA PARA PEGAR APENAS O VALOR DA TEMPERATURA
    @ CHAMAR AQUI A MASCARA
    mov R3, R12 @ Parametro da função !!!!! (ESSE R12 está errado, deverá ser onde estiver após a mascara)
    SeparaDezenaUnidadeV2@ Dezena em r0 e unidade em r1
    mov r1, r0 @ coloco a dezena como parametro
    @ Escreve a dezena correspondente a temperatura. Ex: caso fosse o nº21, iria escrever 2
    bl WriteNumberLCD
    @ Escreve a unidade correspondente a temperatura. Ex: caso fosse o nº21, iria escrever 1
    mov r1, r5 @ pego o valor da unidade e coloco como parametro
    bl WriteNumberLCD
    @ ==============

    @ Escreve º
    mov R1, #0b11011111
    bl WriteCharLCD
    @ Escreve C
    mov R1, #0b01000011
    bl WriteCharLCD

    @ Tiro o lr da stack
    ldr lr,[sp,#0]
    add sp, sp, #8
    bx lr

/* Escreve a umidade
*/

/* Escreve a situação do sensor
*/


