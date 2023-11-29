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
    bic r1, r0 			@ Limpa os bits

    str r1, [r8, r2] 		@ Salva novamente no endereço
.endm

@ Preciso de uma função que seta o pino de saída para o valor passado (0 ou 1). Recebe o high ou low e recebe o id do pino
@setStatePinGPIO (Usando reg R3 para o pino e R4 para o high ou low)
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
    bl


.data
timespecsec: .word 0
timespecnano: .word 100000000
devmem: .asciz "/dev/mem"

@ mem address of gpio register / 4096
gpioaddr: .word 0x1C20 @0x01C20800 / 0x1000 (4096) @Endereço base do GPIO / 0x1000

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
	.word 5 
	.word 0xDC
	.word 4 
db4: .word 0xE8 
	.word 4 
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
.text