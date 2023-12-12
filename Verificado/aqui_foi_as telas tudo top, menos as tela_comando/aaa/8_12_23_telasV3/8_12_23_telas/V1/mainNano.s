

@!!!!!!!!!!!!!!!!!!!!!!!!!!!! ANALISAR TIRAR A STACK



/* 
    ------------------------------------------------
    Função que faz separa o valor em dezenas e unidades
    ------------------------------------------------
    Esta função serve para auxiliar a função de escrever números no display, pois 
    sabendo qual é o digito da dezena e qual é o digito da unidade só será preciso passa-los
    pro comando (db7 a db4).
    !! Só funciona para valores entre 1 e 99
    Se r3 for 54, r0 será 5 e r1 será 4

    Registradores de Parâmetros e Retornos:
    	* r3 -> reg que possui o valor a ser convertido (Parametro)
    	* r0 -> Dezena (Retorno)
    	* r1 -> Unidade (Retorno)
*/
SeparaDezenaUnidadeV2:
    @ Colocando na pilha r8 e r7
    @sub sp, sp, #16
    @stur r8,[sp,#8] @ Usado como temporário
    @stur r7,[sp,#0] @ Usado como temporário

    mov r0, #0 @ guarda o digito da dezena (Será retornado)
    mov r7, #0 @ Guarda o digito da unidade (Será retornado)

    CMP r3, #0 @ Teste para o caso de passar 0 em r3
    BEQ RETURN @ Teste para o caso de passar 0 em r3
    WHILE2:
        add r7, r7, #10 @ Aumenta uma dezena
        add r0, r0, #1 @ Aumenta o digito da dezena
        sub r8, r3, r7 @ r8 = r3 - r7
        CMP r8, #10
        BGE WHILE2 @ Se o resultado for maior ou igual a 10, continue
    mov r1, r8 @ Quando saio do laço, já tenho a resposta do valor menos a dezena, que é a unidade, em r8
    RETURN:
        @ Retirando da pilha r8 e r7
        @ldur r8,[sp,#8]
        @ldur r7,[sp,#0]
        @add sp, sp, #16
        bx lr

