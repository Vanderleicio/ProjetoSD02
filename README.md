# Projeto de Sensor Digital em FPGA utilizando Comunicação Serial, Utilizando uma Interface Homem-Máquina.

### Desenvolvedores
------------

- [Vanderleicio Junior](https://github.com/Vanderleicio)
- [Washington Oliveira Júnior](https://github.com/wlfoj#-washington-oliveira-junior-)
- [Wagner Alexandre](https://github.com/WagnerAlexandre)
- [Lucas Gabriel](https://github.com/lucasxgb)

### Tutor 
------------

- [Thiago Cerqueira de Jesus](https://github.com/thiagocj)

### Sumário 
------------
+ [Introdução](#introdução)
+ [Características da Solução](#características-da-solução)
+ &nbsp;&nbsp;&nbsp;[Materiais Utilizados](#materiais-utilizados)
+ &nbsp;&nbsp;&nbsp;[Arquitetura do Computador](#arquitetura-do-computador)
+ &nbsp;&nbsp;&nbsp;[Instruções Utilizadas](#instruções-utilizadas)
+ &nbsp;&nbsp;&nbsp;[Mapeamento](#mapeamento)
+ &nbsp;&nbsp;&nbsp;[Display](#display)
+ &nbsp;&nbsp;&nbsp;[Uart](#uart)
+ [Como Executar](#como-executar)
+ [Comandos](#comandos)
+ [Testes](#Testes)
+ [Conclusões](#conclusões)
+ [Referências](#referências)

-------

# O sistema
## Introdução

Este documento descreve a continuação do desenvolvimento de um sistema digital para controle de ambientes. O projeto está dividido em duas etapas, o leitor pode encontrar a descrição da implementação da primeira etapa [Clicando aqui (Primeira Etapa)](https://github.com/Vanderleicio/ProjetoSD01). A segunda etapa, visa desenvolver uma interface homem-máquina que, receba comandos, se comunique com a FPGA, receba respostas e exiba essas respostas no Display LCD. Essa interface, deve substitituir a implementada na primeira etapa utilizando a linguagem de programação C, atendendo os mesmos requisitos. Desta vez o prótotipo será embutido em um computador de placa única (SBC) a Orange Pi PC Plus. Uma das restrições do projeto, é que seja a solução seja escrita em Assembly, linguagem que corresponde ao conjunto de instruções de uma arquitetura específica.

A Orange PI PC PLUS possui o processador AllWinner H3, baseado na arquitetura ARM Cortex-A7, parte da família ARMv7. Essa arquitetura, presente em dispositivos como smartphones, tablets e IoT, suporta instruções de 32 bits. Esse tamanho das instruções permite ao processador lidar com uma ampla gama de operações, desde cálculos aritméticos até manipulação de memória. Nesse sentido, toda a construção da solução foi fundamentada nas instruções do ARMv7. As instruções específicas utilizadas serão melhor detalhadas nas próximas seções, oferecendo uma visão mais aprofundada do papel crucial dessas instruções na funcionalidade da solução.

## Características da Solução
----------



### Materiais utilizados
----------

[FPGA]

[ORANGE PI]
gpuio

### Arquitetura do Computador

A Orange PI PC plus.
Allwinner H3 
- CPU: quad-core  ARM Cortex A7

arquitetura ARMv7


----------



### Mapeamento
----------

A Orange PI apresenta uma série de pinos de entrada e saída controláveis, além dos pinos específicos na SBC, como os pinos UART_TX e UART_RX, cada um com finalidades definidas. No contexto da nossa interface, o controle preciso da pinagem é crucial, pois a manipulação e transmissão de dados são essenciais para a funcionalidade principal da interface. 


No entanto, as instruções do ARMv7 não têm conhecimento direto dos pinos GPIO. Portanto, para interagir com esses pinos no assembly, é necessário acessar diretamente os registradores associados a eles, realizando leituras e escritas em locais específicos na memória. No ambiente Linux, o arquivo */dev/mem*, fornece um ponteiro que permite acessar diretamente a memória. Para realizar esse mapeamento de memória, são utilizadas chamadas de sistema, as chamadas syscall, que permitem aos programas solicitar serviços ao kernel. Nesse contexto, a syscall utilizada é a mmpa2, responsável por mapear os endereços do GPIO ou pinos específicos no espaço de memória.


Para realizar a chamada do mmpa2, é importante que alguns registradores que são utilizados como parâmetros estejam preenchidos, são eles:
- `R0`: Dica para o endereço virtual que será utilizado, caso seja nullo, o linux escolherá
- `R1`: Comprimento da região de memória, multiplo de 4096, que é o tamanho da página de memória
- `R2`: Proteção de memória
- `R3`: Descritor de arquivo, usado para abrir o *dev/mem*
- `R5`: O endereço do GPIO / 4096, o endereço do gpio divido pelo tamanho da página de memória, utilizado para calcular o deslocamento necessário para mapear um endereço físico no espaço de memória virtual.


Os dados que são utilizados no R0, R1 e R5 são passados na seção .data.




### Display
--------------


### Uart
--------------

## Como Executar
--------------

### Comandos
--------------
Ao todo existem 7 comandos:
- Comando 0 | Posição 0000: Solicita a situação atual do sensor.
- Comando 1 | Posição 0001: Solicita a medidade de temperatura atual do sensor.
- Comando 2 | Posição 0010: Solicita a medida de umidade atual.
- Comando 3 | Posição 0011: Ativa sensoriamento continuo de temperatura.
- Comando 4 | Posição 0100: Ativa sensoriamento continuo de umidade.
- Comando 5 | Posição 0101: Desativa sensoriamento continuo de temperatura.
- Comando 6 | Posição 0110: Desativa o sensoriamento continuo de unmidade.

Para enviar um comando, são necessarios dois passos:
+ 1: Acessar a tela de comandos, pressionando o botão "comando", e posicionar as chaves ao numero relativo (em binario) ao sensor a ser enviado e pressionar o botão "seguir".
+ 2: Posiconar as chaves o valor do comando (em binario) a ser enviado e pressionar o botão "seguir". 


## Testes
--------------


## Conclusões


--------------
## Referências


