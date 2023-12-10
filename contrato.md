# Retornos
Cada grupo de funções só podem retornar dados em regs especifícos
- As funções do *GPIO* só podem retornar dados em regs R0-R2
- As funções *UTILS* só podem retornar dados em regs R3-R4

# Parâmetros
Cada grupo de funções só podem pegar parâmetros de regs especifícos
- As funções de *TELA* e *DISPLAY* só podem usar os regs R0-R2 como parâmetros, exceto as que pegam os dados direto da UART (podem usar R13)
- As funções de *GPIO* só podem usar os regs R3-R4 como parâmetros
- As funções de *UTILS* só pode usar os regs R5-R6 como parâmetros

# Mapeamentos
- R8 é o endereço base para o *GPIO*
- R9 é o endereço base para o *UART*

# Dados da UART
- R13 é o registrador que deverá conter os dados da UART

# Regs livres para uso e temporários
- R7, R10-R12, R14-R15

