@ A ordem dos imports é esta
.include "utils.s"
.include "sleep.s"
.include "gpio.s"
.include "display_lcd.s"



.global _start

_start:


	@Encerramento do programa
	MOV R0, #0
    	MOV R7, #1
    	SVC 0