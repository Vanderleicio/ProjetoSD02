.include "sleep.s"
.include "utils.s"
.include "gpio.s"
.include "display_lcd.s"
.include "telas.s"


.global _start


_start:
    @ 0011001 1011 01000
    mov r13, #0
    //====SIMULANDO UM DADO RECEBIDO DA UART PARA JOGAR NAS TELAS====//
    // DADOS
    mov r14, #0b0011001 @ Colocando o valor do DADO recebido (25)
    lsl r14, #9 @ Deslocando o comando para o bit
    add r13, r13, r14 @Coloca o valor do comando na posição correta
    // COMANDO
    mov r14, #0b1011 @ Colocando o valor do COMANDO recebido (11)
    lsl r14, #5 @ Deslocando o comando para o bit
    add r13, r13, r14 @Coloca o valor do comando na posição correta
    // Nº SENSOR
    mov r14, #0b01000 @ Colocando o valor do número do sensor recebido (8)
    add r13, r13, r14 @Coloca o valor do comando na posição correta
    
    @ TIRAR UMA TELA POR VEZ PARA TESTAR
    bl TELA_SITUACAO_SENSOR_ERRO
    @bl TELA_SITUACAO_SENSOR_OK
    @bl TELA_DESLIGA_CONTINUO_UMID
    @bl TELA_DESLIGA_CONTINUO_TEMP
    @bl TELA_COMANDOS
    @bl TELA_UMIDADE
    @bl TELA_TEMPERATURA
	
    
    @Encerramento do programa
	MOV R0, #0
    MOV R7, #1
    SVC 0
