@ Arquitetura e Organização de Computadores - 2021.2
@ Professor: Robson Linhares
@ Alunos: Gabriel Reis Nolasco Ferreira e Kaique Messias Ribeiro
@ Enunciado 2
@
@ ==========================================================================
@
@ Instruções:
@ 1. Para alternar entre o modo relógio e alarme, pressione 15 (3,2) para relógio e 16 (3,3) para alarme.
@ 2. Data e hora padrão são 20-12-2020 0:0:0.
@
@ ==========================================================================
@
@ Problemas conhecidos:
@ 1. A edição não foi implementada a tempo. 
@    O alarme pode ser editado apenas no codigo, mas, apesar disto, funciona adequadamente.
@    O Alarme está definido para 00:01:00. (um minuto) 
@ 2. Existe um problema visual, quando os segundos do relogio chegam a 59 e o minuto é alterado, o número 8
@    é exibido no ultimo digito do relogio. Este digito persiste até o contador de segundos ser == 10.
@ 3. Ao alternar para o modo alarme, os segundos do relogio aparecem no topo, é um bug visual, não conseguimos 
@    resolver a tempo.
@ 4. Ao retornar ao modo relógio, os minutos aparecem zerados, é apenas um bug visual, quando são incrementados,
@    voltam a ter seus valores corretos, a contagem não é perdida.
@ 5. Em alguns momentos, o programa congela, acreditamos ser um bug do ARMSIM.
@
@===========================================================================
@


.equ Sec1,                                      1000                    @ 1 segundo
.equ Sec10,                                     10000                   @ 10 segundos   
.equ Top15bitRange,                             0x0000ffff              @ Range de bits 15 a 0
.equ EmbestTimerMark,                           0x7fff                  @ Marcação do Embest Timer
.equ SWI_GetTicks,                              0x6d                    @ SWI para obter o valor do contador de ticks
.equ SWI_acender_segmentos,                     0x200                   @ SWI para acender os segmentos
.equ SWI_checar_botao_preto,                    0x202                   @ SWI para checar o botão preto
.equ SWI_checar_botao_azul_pressionado,         0x203                   @ SWI para checar o botão azul pressionado
.equ SWI_escreve_no_LCD,                        0x204                   @ SWI para escrever no LCD
.equ SWI_escreve_int_no_LCD,                    0x205                   @ SWI para escrever um inteiro no LCD
.equ SWI_liga_LCD,                              0x206                   @ SWI para ligar o LCD (apagar o que está escrito)


swi SWI_liga_LCD
mov r3, #0
mov r4, #0

dois_pontos: .asciz ":"

traco: .asciz "-"


inicializa_relogio:                                     @ Inicializa o relógio com data e hora padrão
        mov r0, #1                                             
        mov r1, #1                                      
        mov r2, #20
        swi SWI_liga_LCD                                @ Liga o LCD (apaga o que está escrito)
        swi SWI_escreve_int_no_LCD
        
        mov r0, #3                                      
        mov r1, #1
        ldr r2, =traco
        swi SWI_escreve_no_LCD                          @ Escrevendo - no LCD

        mov r0, #4                                      
        mov r1, #1
        mov r2, #12
        swi SWI_escreve_int_no_LCD                      @ Escrevendo 12 no LCD

        mov r0, #6                                      
        mov r1, #1
        ldr r2, =traco
        swi SWI_escreve_no_LCD                          @ Escrevendo - no LCD

        mov r0, #7                                      
        mov r1, #1
        ldr r2, =2020
        swi SWI_escreve_int_no_LCD                      @ Escrevendo 2020 no LCD

        mov r0, #14                                    
        mov r1, #1
        mov r2, #0
        swi SWI_escreve_int_no_LCD                      @ Escrevendo 0 (hora) no LCD

        mov r0, #16                                     
        mov r1, #1
        ldr r2, =dois_pontos
        swi SWI_escreve_no_LCD                          @ Escrevendo : no LCD

        mov r0, #17                                     
        mov r1, #1
        mov r2, #0
        swi SWI_escreve_int_no_LCD                      @ Escrevendo 0 (minuto) no LCD

        
        mov r0, #19                                     
        mov r1, #1
        ldr r2, =dois_pontos
        swi SWI_escreve_no_LCD                          @ Escrevendo : no LCD

        mov r0, #20                                    
        mov r1, #1
        mov r2, #0
        swi SWI_escreve_int_no_LCD                      @ Escrevendo 0 (segundo) no LCD

        b modo_relogio                                  @ Vai ao modo relógio


@ Acende os segmentos do display de 8 segmentos para formar a letra 'C'
modo_relogio:    
                               
        mov r0, #0
        add r0, r0, #0x80                           @ Segmento A
        add r0, r0, #0x01                           @ Segmento G
        add r0, r0, #0x04                           @ Segmento E
        add r0, r0, #0x08                           @ Segmento D

        swi SWI_acender_segmentos                   @ Acender os segmentos

        b mostra_data                               @ Vai ao mostra data

@ Mostra a data no LCD
mostra_data:
          
        mov r0, #1
        mov r1, #1
        mov r2, #20                             @ Escrevendo 20 (dia) no LCD
        
        
        swi SWI_escreve_int_no_LCD
        
        mov r0, #3
        mov r1, #1
        ldr r2, =traco                          @ Escrevendo - no LCD

        swi SWI_escreve_no_LCD

        mov r0, #4
        mov r1, #1
        mov r2, #12                             @ Escrevendo 12 (mes) no LCD

        swi SWI_escreve_int_no_LCD

        mov r0, #6
        mov r1, #1
        ldr r2, =traco                          @ Escrevendo - no LCD

        swi SWI_escreve_no_LCD

        mov r0, #7
        mov r1, #1
        ldr r2, =2020                           @ Escrevendo 2020 (ano) no LCD

        swi SWI_escreve_int_no_LCD
        mov r2, #0

        b mostra_horas                          @ Vai ao mostra horas


@ Mostra as horas no display e incrementa o contador de horas
mostra_horas:

        mov r0, #20                             @ Coluna 20 do LCD     
        mov r1, #1                               
        add r6, r6, #1                          @ Incrementa o contador de segundos
        mov r2, r6                              @ r6 responsável por guardar os segn    
        cmp r2, #59                             @ Verifica se o contador de segundos é igual a 59
        beq incrementa_minuto                   @ Se for, incrementa o contador de minutos
        swi SWI_escreve_int_no_LCD       

        ldr r3, =Sec1                           @ r3 guarda o valor de 1 segundo a ser usado pelo contador de segundos
        
        b checar_botao                          @ Vai ao checar botão

@ Checar qual botão foi pressionado
checar_botao:
        
        swi SWI_checar_botao_azul_pressionado           @ Checar se o botão azul foi pressionado
        cmp r0, #16384                                  @ Botão 15 (3,2) pressionado?
        beq inicializa_relogio                          @ Se sim, então modo relógio
        cmp r0, #32768                                  @ Botão 16 (3,3) pressionado?
        beq modo_alarme                                 @ Se sim, então modo alarme

        b Wait                                          @ Senão, volta a contar os segundos

@ incrementa o contador de minutos
incrementa_minuto:

        mov r0, #19
        mov r1, #1
        ldr r2, =dois_pontos                    @ Escreve : no LCD
        swi SWI_escreve_no_LCD
                                 
        mov r0, #17
        mov r1, #1
        add r7, r7, #1                          @ Incrementa o contador de minutos
        mov r2, r7                              @ r7 responsável por guardar os minutos
        cmp r2, #59                             @ Verifica se o contador de minutos é igual a 59        
        beq incrementa_hora                     @ Se for, incrementa o contador de horas
        swi SWI_escreve_int_no_LCD

        b verifica_alarme                       @ Vai ao verifica alarme

@ incrementa o contador de horas
incrementa_hora:

        mov r3, #0
        mov r0, #16
        mov r1, #1
        ldr r2, =dois_pontos                    @ Escreve : no LCD
        swi SWI_escreve_no_LCD
                                 
        mov r0, #14
        mov r1, #1
        add r8, r8, #1                          @ Incrementa o contador de horas
        mov r2, r8                              @ r8 responsável por guardar as horas
        cmp r2, #23                             @ Verifica se o contador de horas é igual a 23
        b seta_zero_hora                        @ Se for, seta o contador de horas para 0
        swi SWI_escreve_int_no_LCD

        b seta_zero_minutos                     @ Vai ao seta zero minutos

verifica_alarme:
        mov r6, #0                              @ Zera o contador de segundos
        add r0, r7, r8                          @ Soma minutos e hora atuais
        cmp r7, r9                              @ Verifica se o contador de minutos é igual ao horario do alarme
        beq soar_alarme                         @ Se for, acende os dois LEDs indicando o alarme

        b checar_botao                          @ Senão, vai ao checar botão


seta_zero: 
        mov r6, #0                              @ Zera o contador de segundos
        b mostra_horas

seta_zero_minutos:
        mov r7, #0                              @ Zera o contador de minutos
        mov r6, #0
        b mostra_horas

seta_zero_hora:
        mov r8, #0                              @ Zera o contador de horas
        mov r7, #0
        mov r6, #0
        b mostra_horas


@Acende os segmentos do display de 8 segmentos para formar a letra 'A'
modo_alarme:      
                        
        mov r0, #0
        add r0, r0, #0x80                           @ Segmento A
        add r0, r0, #0x40                           @ Segmento B
        add r0, r0, #0x20                           @ Segmento C
        add r0, r0, #0x04                           @ Segmento E
        add r0, r0, #0x02                           @ Segmento F
        add r0, r0, #0x01                           @ Segmento G

        swi SWI_acender_segmentos                   @ Acender os segmentos

        b mostra_alarme                             @ Mostra o alarme no LCD

@ Mostra a hora do alarme no display
mostra_alarme:
        mov r0, #1
        swi 0x208                                   @apaga linha 1
        mov r9, #0
        swi SWI_liga_LCD                            @ Liga o LCD
        mov r0, #10                                 @ Coluna 10 do LCD 
        mov r1, #2                                  

        mov r2, #0
        swi SWI_escreve_int_no_LCD                  @ Escreve 0 no LCD
        add r9, r9, r2                              @ r9 guarda o horário do alarme
        mov r0, #11
        mov r1, #2

        ldr r2, =dois_pontos                        @ Escreve : no LCD

        swi SWI_escreve_no_LCD

        mov r0, #12                                
        mov r1, #2
        mov r2, #1                                 @ Minutos padrão do alarme || Altere aqui para alterar o alarme

        add r9, r9, r2                             @ r9 guarda o horario do alarme somando hora e minuto
        
        swi SWI_escreve_int_no_LCD    

        b checar_botao                             @ Vai ao checar botão


@ Acende os dois LEDs indicando o alarme
soar_alarme:
        mov r0, #0x02
        swi 0x201               
        mov r0, #0x01
        swi 0x201              
        mov r0, #0x03
        swi 0x201

        ldr r3, =Sec10                                @ Tempo de 10 segundos
        b wait_led                                    @ Espera 10 segundos para apagar os LEDs


@ Espera 10 segundos para apagar os LEDs do alarme
wait_led:
	stmfd	sp!, {r0-r5,lr}	
	ldr	r4, =0x00007FFF	        @ Mascara de 15 bit
	SWI	SWI_GetTicks	        @ Get current time
	and	r1, r0, r4		@ Ajusta time para 15-bit			
Wloop_led:
	SWI	SWI_GetTicks	        @ Get current time
	and	r2, r0 ,r4		@ Ajusta time para 15-bit
	cmp	r2, r1
	blt	Roll_led		
	sub	r5, r2, r1		@ verifica se o tempo ja passou
	bal	CmpLoop_led
Roll_led:	sub r5, r4, r1	        @calcula tempo passado
	add	r5, r5, r2
CmpLoop_led:	cmp r5, r3	        @ verifica se o tempo ja se esgotou
	blt	Wloop_led		@ sContinua com o delay	
Xwait_led:	
        mov r0, #0x00                   @ Apaga os LEDs
        swi 0x201
        b mostra_horas                  @ Quando o segundo esgota, vai ao mostra hora



@ Conta 1 segundo (código original retirado do manual do ARMSIM e modificado)
Wait:
	stmfd	sp!, {r0-r5,lr}	
	ldr	r4, =0x00007FFF	        @ Mascara de 15 bit
	SWI	SWI_GetTicks	        @ Get current time
	and	r1, r0, r4		@ Ajusta time para 15-bit			
Wloop:
	SWI	SWI_GetTicks	        @ Get current time
	and	r2, r0 ,r4		@ Ajusta time para 15-bit
	cmp	r2, r1
	blt	Roll			@ rolled above 15 bits
	sub	r5, r2, r1		@ verifica se o tempo ja passou
	bal	CmpLoop
Roll:	sub	r5, r4, r1	        @compute rolled elapsed time
	add	r5, r5, r2
CmpLoop:	cmp r5, r3	        @ verifica se o tempo ja se esgotou
	blt	Wloop			@ Continua com o delay	
Xwait:	
        
        b mostra_horas                  @ Quando o segundo esgota, vai ao mostra horas