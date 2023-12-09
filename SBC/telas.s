/*
    ------------------------------------------------
        Escreve COMANDO na segunda linha do display
    ------------------------------------------------
    Esta é uma função auxiliar para ser exibida nas telas
    de recebimento de dados da UART
    O exemplo de como seria exibido:
                xxxxxxxxxxxx
                   COMANDO

*/
EscreveComandoNaSegundaLinha:
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário
    
    bl cursorShiftRight
    bl cursorShiftRight
    bl cursorShiftRight
    bl cursorShiftRight
    @ Escreve C
    mov R1, #0b01000011
    bl WriteCharLCD
    @ Escreve O
    mov R1, #0b01001111
    bl WriteCharLCD
    @ Escreve M
    mov R1, #0b01001101
    bl WriteCharLCD
    @ Escreve A
    mov R1, #0b01000001
    bl WriteCharLCD
    @ Escreve N
    mov R1, #0b01001110
    bl WriteCharLCD
    @ Escreve D
    mov R1, #0b01000100
    bl WriteCharLCD
    @ Escreve O
    mov R1, #0b01001111
    bl WriteCharLCD
	
	bl cursorShiftRight

    @ Tiro o lr da stack
    ldr lr,[sp,#0]
    add sp, sp, #8
	bx lr


/*
    ------------------------------------------------
        Escreve a temperatura no formato indicado
    ------------------------------------------------
                S01 TEMP:21ºC
                xxxxxxxxxxxx

    R13 -> É o dado recebido da UART. Todo o conjunto dos 2 bytes recebidos  
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
    mov R5, R13 @ Parametro da função
    bl pegaNumSensor@ PEGANDO O NÚMERO DO SENSOR EM R3
    mov R5, R3
    bl SeparaDezenaUnidadeV2 @ Dezena em r4 e unidade em r5
    mov r1, r3 @ coloco a dezena como parametro
    @ Escreve a dezena correspondente ao número do sensor. Ex: caso fosse o nº21, iria escrever 2
    bl WriteNumberLCD
    @ Escreve a unidade correspondente ao número do sensor. Ex: caso fosse o nº21, iria escrever 1
    mov r1, r4 @ pego o valor da unidade e coloco como parametro
    bl WriteNumberLCD
    @ ==============

    bl cursorShiftRight@ Suponndo que dá o espaço
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
    bl cursorShiftRight@ Suponndo que dá o espaço

    @ ================ TRECHO PARA ESCREVER O VALOR DA TEMPERATURA
    @ FAZ A MASCARA PARA PEGAR APENAS O VALOR DA TEMPERATURA
    @ CHAMAR AQUI A MASCARA
    mov R5, R13 @ Parametro da função 
    bl pegaNumDados
    mov r5, r3
    bl SeparaDezenaUnidadeV2@ Dezena em r0 e unidade em r1
    mov r1, R3 @ coloco a dezena como parametro
    @ Escreve a dezena correspondente a temperatura. Ex: caso fosse o nº21, iria escrever 2
    bl WriteNumberLCD
    @ Escreve a unidade correspondente a temperatura. Ex: caso fosse o nº21, iria escrever 1
    mov r1, r4 @ pego o valor da unidade e coloco como parametro
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

/*
    ------------------------------------------------
        Escreve a umidade no formato indicado
    ------------------------------------------------
                S01 UMID:21%
                xxxxxxxxxxxx

    R13 -> É o dado recebido da UART. Todo o conjunto dos 2 bytes recebidos  
*/
WriteHumidityLCD:
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
    mov R5, R13 @ Parametro da função
    bl pegaNumSensor@ PEGANDO O NÚMERO DO SENSOR EM R3
    mov R5, R3
    bl SeparaDezenaUnidadeV2 @ Dezena em r4 e unidade em r5
    mov r1, r3 @ coloco a dezena como parametro
    @ Escreve a dezena correspondente ao número do sensor. Ex: caso fosse o nº21, iria escrever 2
    bl WriteNumberLCD
    @ Escreve a unidade correspondente ao número do sensor. Ex: caso fosse o nº21, iria escrever 1
    mov r1, r4 @ pego o valor da unidade e coloco como parametro
    bl WriteNumberLCD
    @ ==============

    bl cursorShiftRight@ Suponndo que dá o espaço
    @ ESCREVE 'UMID'
    mov R1, #0b01010101 @ U
    bl WriteCharLCD
    mov R1, #0b01001101 @ M
    bl WriteCharLCD
    mov R1, #0b01001001 @ I
    bl WriteCharLCD
    mov R1, #0b01000100 @ D
    bl WriteCharLCD

    @ Escreve :
    mov R1, #0b00111010
    bl WriteCharLCD
    bl cursorShiftRight@ Suponndo que dá o espaço

    @ ================ TRECHO PARA ESCREVER O VALOR DA TEMPERATURA
    @ FAZ A MASCARA PARA PEGAR APENAS O VALOR DA TEMPERATURA
    @ CHAMAR AQUI A MASCARA
    mov R5, R13 @ Parametro da função 
    bl pegaNumDados
    mov r5, r3
    bl SeparaDezenaUnidadeV2@ Dezena em r0 e unidade em r1
    mov r1, R3 @ coloco a dezena como parametro
    @ Escreve a dezena correspondente a temperatura. Ex: caso fosse o nº21, iria escrever 2
    bl WriteNumberLCD
    @ Escreve a unidade correspondente a temperatura. Ex: caso fosse o nº21, iria escrever 1
    mov r1, r4 @ pego o valor da unidade e coloco como parametro
    bl WriteNumberLCD
    @ ==============

    @ Escreve %
    mov R1, #0b00100101
    bl WriteCharLCD

    @ Tiro o lr da stack
    ldr lr,[sp,#0]
    add sp, sp, #8
    bx lr



/*
    ------------------------------------------------
        Parte de cima da tela para inserir o comando
    ------------------------------------------------
                S:00 C:00
                xxxxxxxxxxxx

    R2 -> É onde está o num do sensor(5 bits mais altos) e o codigo do comando(4 bits mais baixos)
    EX. Primeiro num sensor e depois comando 01010 1100
*/ 
PARTE_DE_CIMA_TELA_COMANDOS:
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário
    @====================Parte de cima====================@
    @ Escreve S
    mov R1, #0b01010011
    bl WriteCharLCD
    @ Escreve :
    mov R1, #0b00111010
    bl WriteCharLCD
    @ Escreve o nº do sensor
    @ ================ TRECHO PARA ESCREVER O NUM Do sensor
    @ CHAMAR AQUI A MASCARA
    lsr r5, r2, #4@ Desloco para a direita para remover os 4 bits do comando
    bl SeparaDezenaUnidadeV2@ Dezena em r0 e unidade em r1
    mov r1, r3 @ coloco a dezena como parametro
    @ Escreve a dezena correspondente a temperatura. Ex: caso fosse o nº21, iria escrever 2
    bl WriteNumberLCD
    @ Escreve a unidade correspondente a temperatura. Ex: caso fosse o nº21, iria escrever 1
    mov r1, r4 @ pego o valor da unidade e coloco como parametro
    bl WriteNumberLCD
    @ espaço 5x
    bl cursorShiftRight
    bl cursorShiftRight
    bl cursorShiftRight
    bl cursorShiftRight
    
    
    
    @ Escreve C
    mov R1, #0b01000011
    bl WriteCharLCD
    @ Escreve :
    mov R1, #0b00111010
    bl WriteCharLCD
    @ Escreve o nº do comando
    @ ================ TRECHO PARA ESCREVER O NUM Do comando
    @ CHAMAR AQUI A MASCARA
    and r5, r2, #0b1111@ Faço and para pegar apenas os 4 últimos bits 
    bl SeparaDezenaUnidadeV2@ Dezena em r0 e unidade em r1
    mov r1, r3 @ coloco a dezena como parametro
    @ Escreve a dezena correspondente a temperatura. Ex: caso fosse o nº21, iria escrever 2
    bl WriteNumberLCD
    @ Escreve a unidade correspondente a temperatura. Ex: caso fosse o nº21, iria escrever 1
    mov r1, r4 @ pego o valor da unidade e coloco como parametro
    bl WriteNumberLCD
    
    ldr lr,[sp,#0]
    add sp, sp, #8
    bx lr



/*
    ------------------------------------------------
        Parte de baixo da tela para inserir o comando
    ------------------------------------------------
                xxxxxxxxxxxxxxxx
                VOLTAR OK SEGUIR
*/ 
PARTE_DE_BAIXO_TELA_COMANDOS:
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário
    
    @ Escreve V
    mov R1, #0b01010110
    bl WriteCharLCD
    @ Escreve O
    mov R1, #0b01001111
    bl WriteCharLCD
    @ Escreve L
    mov R1, #0b01001100
    bl WriteCharLCD
    @ Escreve T
    mov R1, #0b01010100
    bl WriteCharLCD
    @ Escreve A
    mov R1, #0b01000001
    bl WriteCharLCD
    @ Escreve R
    mov R1, #0b01010010
    bl WriteCharLCD
    
    bl cursorShiftRight
    
    @ Escreve O
    mov R1, #0b01001111
    bl WriteCharLCD
    @ Escreve K
    mov R1, #0b01001011
    bl WriteCharLCD
    
    bl cursorShiftRight
    
	.ltorg
    @ Escreve S
    mov R1, #0b01010011
    bl WriteCharLCD
    @ Escreve E
    mov R1, #0b01000101
    bl WriteCharLCD
    @ Escreve G
    mov R1, #0b01000111
    bl WriteCharLCD
    @ Escreve U
    mov R1, #0b01010101
    bl WriteCharLCD
    @ Escreve I
    mov R1, #0b01001001
    bl WriteCharLCD
    @ Escreve R
    mov R1, #0b01010010
    bl WriteCharLCD
    
    
    ldr lr,[sp,#0]
    add sp, sp, #8
    bx lr

@========================================================================================================================================@
@========================================================== Bloco para as telas =========================================================@
@========================================================================================================================================@

/*
    ------------------------------------------------
        Exibe a tela de temperatura no formato indicado
    ------------------------------------------------
                S01 TEMP:21ºC
                   COMANDO

    R13 -> É o dado recebido da UART. Todo o conjunto dos 2 bytes recebidos  
*/
TELA_TEMPERATURA:
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário
    
    bl WriteTemperatureLCD @ Parte da linha de cima
    bl jumpLine
    bl EscreveComandoNaSegundaLinha @ Parte da linha debaixo
    
    ldr lr,[sp,#0]
    add sp, sp, #8
    bx lr


/*
    ------------------------------------------------
        Exibe a tela de temperatura no formato indicado
    ------------------------------------------------
                S01 UMID:21%
                   COMANDO

    R13 -> É o dado recebido da UART. Todo o conjunto dos 2 bytes recebidos  
*/
TELA_UMIDADE:
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário
    
    bl WriteHumidityLCD @ Parte da linha de cima
    bl jumpLine
    bl EscreveComandoNaSegundaLinha @ Parte da linha debaixo
    
    ldr lr,[sp,#0]
    add sp, sp, #8
    bx lr


/*
    ------------------------------------------------
    Exibe a tela de inserir comando no formato indicado
    ------------------------------------------------
                S:00 C:00
                VOLTAR OK SEGUIR

    R2 -> É onde está o num do sensor(5 bits mais altos) e o codigo do comando(4 bits mais baixos)
    EX. Primeiro num sensor e depois comando 01010 1100
*/
TELA_COMANDOS:
    sub sp, sp, #8
    str lr,[sp,#0] @ Usado como temporário
    
    bl PARTE_DE_CIMA_TELA_COMANDOS @ Parte da linha de cima
    bl jumpLine
    bl PARTE_DE_BAIXO_TELA_COMANDOS @ Parte da linha debaixo
    
    ldr lr,[sp,#0]
    add sp, sp, #8
    bx lr

/*
    ------------------------------------------------------------------------------------------------
    Exibe a tela de desligamento do continuo de temperatura no formato indicado
    ------------------------------------------------------------------------------------------------
                                        S01 TEMPC:OFF
                                           COMANDO

    R13 -> É o dado recebido da UART. Todo o conjunto dos 2 bytes recebidos  
*/
TELA_DESLIGA_CONTINUO_TEMP:


/*
    ------------------------------------------------------------------------------------------------
    Exibe a tela de desligamento do continuo de umidade no formato indicado
    ------------------------------------------------------------------------------------------------
                                        S01 UMIDC:OFF
                                           COMANDO

    R13 -> É o dado recebido da UART. Todo o conjunto dos 2 bytes recebidos  
*/
TELA_DESLIGA_CONTINUO_UMID:


/*
    -------------------------------------------------------------
    Exibe a tela com a situação atual do sensor no formato indicado
    -------------------------------------------------------------
                        S01:OK            OU       S01:ERR 
                        COMANDO                    COMANDO

    R13 -> É o dado recebido da UART. Todo o conjunto dos 2 bytes recebidos  
*/
TELA_SITUACAO_SENSOR: