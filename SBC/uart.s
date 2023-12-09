.section .text
.global _start


.macro MemoryMapUart
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
	LDR R5, =uartaddr @ endereco uart / 4096
	LDR R5, [R5]
	MOV R7, #192 @sys_mmap2
	SVC 0
	MOV R9, R0
.endm

setPinsUart:
@=======PUT PILHA
    sub sp, sp, #40
    str r0, [sp, #32]
    str r1, [sp, #24]
    str r2, [sp, #16]
    str r3, [sp, #8]
    str r4, [sp, #0]
@=======PUT PILHA

    ldr r2, =uart3		@ Carrega o offset base do registrador select do uart3
    ldr r2, [r2] 		@ Carrega o valor
    
    add r2, #0x800		@ Adicionar o offset padrão do uart

    ldr r1, [r8, r2] 		@ Valor no registrador select

    ldr r3, =uart3 		@ Endereço do deslocamento específico para o pino tx
    add r3, #4 			@ Deslocamento para a posição do offset dentro do registrador select
    ldr r3, [r3] 		@ Carrega o valor
    
    ldr r4, =uart3 		@ Endereço do deslocamento específico para o pino rx
    add r4, #8 			@ Deslocamento para a posição do offset dentro do registrador select
    ldr r4, [r4] 		@ Carrega o valor

    mov r0, #0b100 		@ Registrador a ser usado como máscara
    lsl r0, r3 			@ Desloca para a posicao da máscara (Onde os 3 bits do pino estarão) tx
    bic r1, r0 			@ Limpa os bits 011(input)
    
    lsl r0, r4 			@ Desloca para a posicao da máscara (Onde os 3 bits do pino estarão) rx
    bic r1, r0 			@ Limpa os bits 011(input)

    str r1, [r8, r2] 		@ Salva novamente no endereço

@=======POP PILHA
    ldr r0, [sp, #32]
    ldr r1, [sp, #24]
    ldr r2, [sp, #16]
    ldr r3, [sp, #8]
    ldr r4, [sp, #0]
    add sp, sp, #40
@=======POP PILHA

    bx lr


.macro inicializarUART    
    bl setPinsUart
    
    @zerar o reset do uart3 
    mov r2, #0x02D8   		@ Carregar o registrador referente ao reset do uart3
    add r2, #0x0  		@ Adicionar o offset padrão do uart
     
    ldr r1, [r8, r2] 		@ Valor no registrador select

    mov r0, #0b1 		@ Registrador a ser usado como máscara
    lsl r0, #19 		@ Desloca para a posicao da máscara (Onde os 3 bits do pino estarão) tx
    bic r1, r0 			@ Coloca 1 no bit para desabilitar o reset do uart3

    str r1, [r8, r2] 		@ Salva novamente no endereço
    
    
    @Retirar o reset do uart3 
    mov r2, #0x02D8   		@ Carregar o registrador referente ao reset do uart3
    add r2, #0x0  		@ Adicionar o offset padrão do uart
     
    ldr r1, [r8, r2] 		@ Valor no registrador select

    mov r0, #0b1 		@ Registrador a ser usado como máscara
    lsl r0, #19 		@ Desloca para a posicao da máscara (Onde os 3 bits do pino estarão) tx
    orr r1, r0 			@ Coloca 1 no bit para desabilitar o reset do uart3

    str r1, [r8, r2] 		@ Salva novamente no endereço
    

    @=====Setar O periph0
    mov r2, #0x000   		@ Carregar o registrador referente ao reset do uart3
    add r2, #0x0028
    
    ldr r1, [r8, r2] 		@ Valor no registrador select

    mov r0, #0b1 		@ Registrador a ser usado como máscara
    lsl r0, #31		@ Desloca para a posicao da máscara 
   
    orr r1, r0
    
    str r1, [r8, r2] 		@ Salva novamente no endereço


    @=====Setar o APB2
    mov r2, #0x000   		@ Carregar o registrador referente ao reset do uart3
    add r2, #0x0058
    
    ldr r1, [r8, r2] 		@ Valor no registrador select

    mov r0, #0b10 		@ Registrador a ser usado como máscara
    lsl r0, #24			@ Desloca para a posicao da máscara 
   
    orr r1, r0
    
    str r1, [r8, r2] 		@ Salva novamente no endereço


    @=====Alterar gating
    mov r2, #0x000   		@ Carregar o registrador referente ao reset do uart3
    add r2, #0x006C
    
    ldr r1, [r8, r2] 		@ Valor no registrador select

    mov r0, #0b1 		@ Registrador a ser usado como máscara
    lsl r0, #19 		@ Desloca para a posicao da máscara 
   
    orr r1, r0
    
    str r1, [r8, r2] 		@ Salva novamente no endereço


    @====TRABALHANDO COM A UART PROPRIAMENTE======
	
    MemoryMapUart
    
    @ Habilita o FIFO
    mov r0, #0x0008 
    add r0, #0xC00   
    
    mov r1, #1
    
    ldr r2, [r9, r0] @ Carrega o reg UART_FCR
    orr r2, r2, r1
    str r2, [r9, r0]

    @======Configurar para alterar o baudrate
    mov r2, #0x000C   		@ Carregar o registrador referente ao uart_lcr
    add r2, #0xC00  		@ Adicionar o offset padrão do uart
     
    ldr r1, [r9, r2] 		@ Valor no registrador UART_LCR
    
    mov r0, #0b10000000	        @ Habilita o DLL para leitura/escrita do baudrate
    orr r1, r0 			@ Coloca 1 no sétimo bit
    str r1, [r9, r2] 		@ Salva novamente no endereço


    @============Configurar uart_lcr
    mov r2, #0x000C   		@ Carregar o registrador referente ao uart_lcr
    add r2, #0xC00  		@ Adicionar o offset padrão do uart
     
    ldr r1, [r9, r2] 		@ Valor no registrador UART_LCR

    mov r0, #0b11 		@ Registrador a ser usado como máscara. Coloca o 11 para definir como 8 bits
    orr r1, r0 		        @ Coloca 11 nos 2 últimos bits

    str r1, [r9, r2] 		@ Salva novamente no endereço


    @ Calculo do divisor do Baud Rate
    @ (600MHz / ( 9600 ∗ 16 )) = 3906.25
    @ = 111101000010.01 em binario


    @=======Carregar o baudrate DLL (LSB)
    mov r2, #0x000   		@ Carregar o registrador referente ao uart_dll
    add r2, #0xC00  		@ Adicionar o offset padrão do uart
     
    ldr r1, [r9, r2] 		@ Valor no registrador UART_DLL
    
    mov r11, #0b11111111
    bic r1, r11
    
    mov r0, #0b01000010
    orr r1, r0 
    
    str r1, [r9, r2] 		@ Salva novamente no endereço

    @=======Carregar o baudrate DLH (MSB)
    mov r2, #0x0004   		@ Carregar o registrador referente ao uart_dll
    add r2, #0xC00  		@ Adicionar o offset padrão do uart
     
    ldr r1, [r9, r2] 		@ Valor no registrador UART_DLL
    
    mov r11, #0b11111111
    bic r1, r11
    
    mov r0, #0b1111
    orr r1, r0
    
    str r1, [r9, r2] 		@ Salva novamente no endereço


    @=====Habilitar leitura/escrita do buffer na uart
    mov r2, #0x000C   		@ Carregar o registrador referente ao uart_lcr
    add r2, #0xC00  		@ Adicionar o offset padrão do uart
     
    ldr r1, [r9, r2] 		@ Valor no registrador UART_LCR
    
    mov r0, #0b10000000		@ Habilita o buffer da uart
    bic r1, r0 			@ Coloca 0 no sétimo bit
    str r1, [r9, r2] 		@ Salva novamente no endereço


    @ Escreve 8 bits na UART
    mov r2, #0xC00
    mov r1, #0b00101010
    str r1, [r9, r2] @ Carrega o reg UART_RBR
    
    
.endm
