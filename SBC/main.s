.include "sleep.s"
.include "utils.s"
.include "gpio.s"
.include "display_lcd.s"
.include "telas.s"



.global _start

_start:

	@Encerramento do programa
	MOV R0, #0
    MOV R7, #1
    SVC 0
