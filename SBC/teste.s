LOOP_PRINCIPAL:
@ Verifico se chegou algo na uart
bl isUartReceived
cmp r1, #1
@ Se tiver chego algo, exibo a tela correspondente
BEQ EXIBE_RECEBIDO
@ Se não tiver recebido algo eu verifico o botão
debouncePin bOk
cmp r7, #1
@ Se o botão tiver sido pressionado, vou para a tela de comando
BEQ TEL_COMANDO
@ Se não estiver pressionado, volto refaço o processo
b LOOP_PRINCIPAL

TEL_COMANDO:
    bl TELA_COMANDO_MAIS_EXTERNA
    @ Quando saio da tela, já devo enviar os dados pela UART
    bl sendUart
    b LOOP_PRINCIPAL

EXIBE_RECEBIDO:
    bl SELECAO_TELA
    b LOOP_PRINCIPAL
