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
    nanoSleep timeZero, time1ms @ !!! Confirmar a necessidade desse último timer em low por tanto tempo, talvez só precise fazer o gpiolow
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
parametro está em r2
*/     
setCursorPos:
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário
    
    MOV R9, R2
    setInitialCursorPos @ Preciso jogar o cursor na posição inicial, pois pos não é relativo

    @ Espera-se que eu nunca use esta função para ir para a posição 0 (Talvez eu remova ela)
    CMP R9, #0 @ Para ver se não entro no while
    BGT WHILE3
    bx lr

    WHILE3:
        bl cursorShiftRight
        SUB R9, #1
        CMP R9, #0
        BGT WHILE3
        
        ldr lr,[sp,#0]
    	add sp, sp, #8
    	
        bx lr






/* Escreve a umidade
*/

/* Escreve a situação do sensor
*/

  
    
    
    

