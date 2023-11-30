.equ PROT_READ, 1
.equ PROT_WRITE, 2
.equ MAP_SHARED, 1
.equ S_RDWR, 0666

@ Chamar as funções do display
.global _start

.MemoryMap
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

.setOut
	setPinGPIOOut db7
	setPinGPIOOut db6
	setPinGPIOOut db5
	setPinGPIOOut db4
	setPinGPIOOut RS
	setPinGPIOOut E
.endm

_start:
	MemoryMap
	
	setOut
	.ltorg

	@initDisplay
	@WriteChar #74
	
	@Acender LED
	setPinGPIOOut PA8
	SetPinGPIOHigh PA8

	@setCursorPos #24
	@WriteChar #82
	

	@Encerramento do programa
	MOV R0, #0
    	MOV R7, #1
    	SVC 0
	
.data 
	timeZero: 	.word	0 @ 0 Segundos
	time1ms: 	.word	1000000  @ 1 Milissegundo
	time5ms:	.word	5000000  @ 5 Milissegundos 
	time15ms:	.word 	15000000 @ 15 Milissegundos
	time150us:	.word	150000 @ 150 us
	timespecnano:	.word 	1000000
	
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
	PA8: .word 0x10
		.word 8
		.word 0x04
		.word 0