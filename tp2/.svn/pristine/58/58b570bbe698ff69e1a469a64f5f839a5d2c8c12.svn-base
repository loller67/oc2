; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Blur 2                                     ;
;                                                                           ;
; ************************************************************************* ;


; void ASM_blur2( uint32_t w, uint32_t h, uint8_t* data ) rdi = w, rsi = h, rdx = *data; w es mult de 4
global ASM_blur2;  edi              esi      rdx
extern malloc
extern free

section .rodata

nueve: DD 9.0, 9.0, 9.0, 9.0

%define pixel_size 4


section .text

ASM_blur2:

	push rbp
	mov rbp, rsp
	push rbx
	push r15
	push r14
	push r13
	push r12
	sub rsp, 8

	mov rbx, rdx	; rbx <- puntero a la imagen


	mov r12d, edi 	; r12 <- ancho en pixeles 
	mov r13d, esi 	; r13 <- alto en pixeles

	mov r14, r12
	shl r14, 2 	 	; r14 <- ancho en bytes

	mov rdi, r14
	call malloc 	; creo un vector del tamaÃ±o de una fila

	mov r11, rax 	; r11 < - puntero al vector temporal que voy a ir corriendo
	mov r15, r11 	; r15 <- puntero al inicio del vector (para retomar del principio)


	mov r8, r13 	; en r8 tengo el contador de la altura
	sub r8, 2		; le resto las nulas porque voy a iterar hasta cantidad de filas - 2
	jle .fin
	
	xor r9, r9
	
	; Cargo primera fila de la imagen en el vector:

	.iniciar_vector:
		MOVDQU XMM0, [RBX + R9*4]				; cargo en xmm0 4 pixeles
		MOVDQU [R11 + R9*4], XMM0 			; guardo 4 pixeles en vector
		ADD R9, 4							; avanzo 4 pixeles
		CMP R9, R12							; me fijo si llegue al final de la fila
		JNE .iniciar_vector

	
	.ciclo_height:  
			;r15=*algodeImagen / r14= rdi=tamaÃ±o fila / r9 contador de columnas/ r8 = contador de filas 
			;rbx = *imagen / r11 = direccion vector temp

				mov r9, r14 	; inicializo decrementador de columnas
				

		; Guardo en eax el primero de la proxima fila, lo uso para modificar el vector auxiliar
		MOV EAX, [RBX + R14]	
		
		.ciclo_wide: 

			;cargo y actualizo pixeles en vector temp y registros:
			
			mov r10, rbx
			MOVDQU XMM0, [r10 + 0]				;xmmo=p03|p02|p01|p00
			MOVDQU XMM1, [r10 + 1*pixel_size]	;xmm1=p04|p03|p02|p01 
			MOVDQU XMM2, [r10 + 2*pixel_size]	;xmm2=p05|p04|p03|p02	

			add r10, r14 				;cambio de linea
			MOVDQU XMM3, [r10 + 0]				;xmm3=p13|p12|p11|p10
			MOVDQU XMM4, [r10 + 1*pixel_size]	;xmm4=p14|p13|p12|p11
			MOVDQU XMM5, [r10 + 2*pixel_size]	;xmm5=p15|p14|p13|p12

			add r10, r14 				;cambio de linea		
			MOVDQU XMM6, [r10 + 0]				;xmm6=p23|p22|p21|p20
			MOVDQU XMM7, [r10 + 1*pixel_size]	;xmm7=p24|p23|p22|p21
			MOVDQU XMM8, [r10 + 2*pixel_size]	;xmm8=p25|p24|p23|p22

			;cambio pixeles del ciclo anterior:
			movdqu xmm15, [r11]
			movdqu [rbx], xmm15

	 		; Guardo el cuarto pixel calculado en el ciclo anterior (para no pisarse cuando levanto datos)
	 		MOV [R11], EAX

			;DESEMPAQUETO PARA PRIMER Y SEGUNDA fila
			XORPD XMM15, XMM15	;LIMPIO XMM15
			
			MOVDQU XMM14, XMM0  
			PUNPCKLBW XMM14, XMM15				;xmm14=| P01:0B0G | P01:0R0A | P00:0B0G | P00:0R0A | 
			PUNPCKHBW XMM0, XMM15				;XMM0= | P03:0B0G | P03:0R0A | P02:0B0G | P02:0R0A | 
			
			MOVDQU XMM13, XMM1  
			PUNPCKLBW XMM13, XMM15				;xmm13=| P02:0B0G | P02:0R0A | P01:0B0G | P01:0R0A | 
			PUNPCKHBW XMM1, XMM15				;XMM1= | P04:0B0G | P04:0R0A | P03:0B0G | P03:0R0A | 
			
			;MOVDQU XMM12, XMM2  
			;PUNPCKLBW XMM12, XMM15				;xmm12=| P03:0B0G | P03:0R0A | P02:0B0G | P02:0R0A | 
			PUNPCKHBW XMM2, XMM15				;XMM2= | P05:0B0G | P05:0R0A | P04:0B0G | P04:0R0A | 
			
			MOVDQU XMM11, XMM3  
			PUNPCKLBW XMM11, XMM15				;xmm11=| P11:0B0G | P11:0R0A | P10:0B0G | P10:0R0A | 
			PUNPCKHBW XMM3, XMM15				;XMM3= | P13:0B0G | P13:0R0A | P12:0B0G | P12:0R0A | 
			
			MOVDQU XMM10, XMM4  
			PUNPCKLBW XMM10, XMM15				;xmm10=| P12:0B0G | P12:0R0A | P11:0B0G | P11:0R0A | 
			PUNPCKHBW XMM4, XMM15				;XMM4= | P14:0B0G | P14:0R0A | P13:0B0G | P13:0R0A | 
			
			;MOVDQU XMM9, XMM5  
			;PUNPCKLBW XMM9, XMM15				;xmm9= | P13:0B0G | P13:0R0A | P12:0B0G | P12:0R0A | 
			PUNPCKHBW XMM5, XMM15				;XMM5= | P15:0B0G | P15:0R0A | P14:0B0G | P14:0R0A | 
			
			
			;(XMM0 12, 9 SE REPITEN, LOS COMENTO)
			;TENGO USADOS 14 13 11 10 0 1 2 3 4 5
			
			;DESEMPAQUETO PARA TERCER FILA:			
			MOVDQU XMM12, XMM6  
			PUNPCKLBW XMM12, XMM15				;xmm12=| P21:0B0G | P21:0R0A | P20:0B0G | P20:0R0A | 
			PUNPCKHBW XMM6, XMM15				;XMM6= | P23:0B0G | P23:0R0A | P22:0B0G | P22:0R0A | 
			
			MOVDQU XMM9, XMM7  
			PUNPCKLBW XMM9, XMM15				;xmm9 =| P22:0B0G | P23:0R0A | P22:0B0G | P22:0R0A | 
			PUNPCKHBW XMM7, XMM15				;XMM7= | P24:0B0G | P24:0R0A | P23:0B0G | P23:0R0A | 
			
			;MOVDQU XMM6, XMM8  		
			;PUNPCKLBW XMM6, XMM15				;xmm6=| P23:0B0G | P23:0R0A | P22:0B0G | P22:0R0A | 
			PUNPCKHBW XMM8, XMM15				;XMM8=| P25:0B0G | P25:0R0A | P24:0B0G | P24:0R0A | 
			
			
			;me QUEDA
			
			;xmm14=| P01:0B0G | P01:0R0A | P00:0B0G | P00:0R0A | 
			;xmm13=| P02:0B0G | P02:0R0A | P01:0B0G | P01:0R0A | 
			;XMM0= | P03:0B0G | P03:0R0A | P02:0B0G | P02:0R0A | 
			;XMM1= | P04:0B0G | P04:0R0A | P03:0B0G | P03:0R0A | 
			;XMM2= | P05:0B0G | P05:0R0A | P04:0B0G | P04:0R0A | 
			
			;xmm11=| P11:0B0G | P11:0R0A | P10:0B0G | P10:0R0A | 
			;xmm10=| P12:0B0G | P12:0R0A | P11:0B0G | P11:0R0A | 
			;XMM3= | P13:0B0G | P13:0R0A | P12:0B0G | P12:0R0A | 
			;XMM4= | P14:0B0G | P14:0R0A | P13:0B0G | P13:0R0A | 
			;XMM5= | P15:0B0G | P15:0R0A | P14:0B0G | P14:0R0A | 
			
			;xmm12=| P21:0B0G | P21:0R0A | P20:0B0G | P20:0R0A | 
			;xmm9 =| P22:0B0G | P22:0R0A | P21:0B0G | P21:0R0A | 
			;XMM6= | P23:0B0G | P23:0R0A | P22:0B0G | P22:0R0A | 
			;XMM7= | P24:0B0G | P24:0R0A | P23:0B0G | P23:0R0A | 
			;XMM8= | P25:0B0G | P25:0R0A | P24:0B0G | P24:0R0A | 
			
			
	;CALCULO PRIMER PIXEL:
			PADDW XMM15, XMM14 	;XMM14 NO LO VUELVO A USAR,			
			PADDW XMM15, XMM13
			PADDW XMM15, XMM0 	;SUME PRIMER FILA			
			PADDW XMM15, XMM11
			PADDW XMM15, XMM10
			PADDW XMM15, XMM3	;SUME SEGUNDA FILA			
			PADDW XMM15, XMM12
			PADDW XMM15, XMM9
			PADDW XMM15, XMM6 	;SUME TERCER FILA
			
			XORPD XMM14, XMM14 	;LO LIMPIO 
			PUNPCKLWD XMM15, XMM14	; XMM15 = PRIMER PIXEL (en int)=
										; | 00BB | 00GG | 00RR | 00AA |
								
			CVTDQ2PS xmm15, xmm15 	;transformo int a single float				
			MOVDQU xmm14, [nueve]
			DIVPS xmm15, xmm14		; xmm15 = rgba promediado falta, arreglar A que no se promedia
			CVTPS2DQ xmm15, xmm15 		;los convierto a int de nuevo 
			xorpd xmm14, xmm14		;limpio xmm14
			PACKUSDW xmm15, xmm14		; |0|0|0|0|w|w|w|w||
			PACKUSWB xmm15, xmm14		; | 0 | 0 | 0 |bbbb|
	
					
	;guardo primer pixel modificado en vector

			PEXTRD [R11 + 4], XMM15, 0

			
	;CALCULO SEGUNDO Y TERCER PIXEL:
			xorpd xmm15, xmm15
			PADDW XMM15, XMM13 	;a xmm13 no lo vuelvo a usar	
			PADDW XMM15, XMM0
			PADDW XMM15, XMM1 ;SUME PRIMER FILA			
			PADDW XMM15, XMM10
			PADDW XMM15, XMM3
			PADDW XMM15, XMM4 ;SUME SEGUNDA FILA			
			PADDW XMM15, XMM9
			PADDW XMM15, XMM6
			PADDW XMM15, XMM7 ;SUME TERCER FILA
			
			XORPD XMM14, XMM14 		;ya esta limpio
			MOVDQU xmm13, xmm15			;(low xmm15 para seg pix/ highxmm13 para tercer)
			PUNPCKLWD XMM15, XMM14	; XMM15 = segundo PIXEL (en int)=
													; | 00BB | 00GG | 00RR | 00AA |
			PUNPCKHWD XMM13, XMM14	; XMM13 = tercer PIXEL (en int)=
													; | 00BB | 00GG | 00RR | 00AA |
													
			CVTDQ2PS xmm15, xmm15 ;transformo int a single float	
			MOVDQU xmm14, [nueve]
			DIVPS xmm15, xmm14				; xmm15 = rgba promediado falta, arreglar A que no se promedia
			XORPD xmm14, xmm14			
			CVTPS2DQ xmm15, xmm15 			;los convierto a int de nuevo 	
			PACKUSDW xmm15, xmm14			; |0|0|0|0|w|w|w|w||
			PACKUSWB xmm15, xmm14			; | 0 | 0 | 0 |bbbb|
			
			CVTDQ2PS xmm13, xmm13 ;transformo int a single float	
			MOVDQU xmm14, [nueve]
			DIVPS xmm13, xmm14				; xmm13 = rgba promediado falta, arreglar A que no se promedia
			XORPD xmm14, xmm14			
			CVTPS2DQ xmm13, xmm13 			;los convierto a int de nuevo 	
			PACKUSDW xmm13, xmm14			; |0|0|0|0|w|w|w|w||
			PACKUSWB xmm13, xmm14			; | 0 | 0 | 0 |bbbb|  xmm13  3er pixel modificado
			
			
	;guardo segundo pixel modificado en vector

			PEXTRD [r11 + 8], XMM15, 0
			
	;guardo tercer pixel modificado en vector

			PEXTRD [r11 + 12], XMM13, 0
			
	;CALCULO CUARTO PIXEL:
			xorpd xmm15, xmm15
			PADDW XMM15, XMM0	
			PADDW XMM15, XMM1
			PADDW XMM15, XMM2 ;SUME PRIMER FILA			
			PADDW XMM15, XMM3
			PADDW XMM15, XMM4
			PADDW XMM15, XMM5 ;SUME SEGUNDA FILA			
			PADDW XMM15, XMM6
			PADDW XMM15, XMM7
			PADDW XMM15, XMM8 ;SUME TERCER FILA
			
			XORPD XMM14, XMM14 		;LO LIMPIO 
			PUNPCKHWD XMM15, XMM14	; XMM15 = CUARTO PIXEL (en int)=
													; | 00BB | 00GG | 00RR | 00AA |
													
			CVTDQ2PS xmm15, xmm15 ;transformo int a single float				
			MOVDQU xmm14, [nueve]
			DIVPS xmm15, xmm14					; xmm15 = rgba promediado falta, arreglar A que no se promedia
			XORPD XMM14, xmm14			
			CVTPS2DQ xmm15, xmm15 			;los convierto a int de nuevo 
			PACKUSDW xmm15, xmm14			; |0|0|0|0|w|w|w|w||
			PACKUSWB xmm15, xmm14			; | 0 | 0 | 0 |bbbb| 4to pixel modificado
			
	; Guardo cuarto pixel modificado en eax,  para cargarlo en el vector en el prox ciclo
			PEXTRD EAX, XMM15, 0
				
	;incremento / decremento variables
			
			add rbx, 4*pixel_size 	; cambio el puntero de los pxeles de la imagen para que apunte a los 4 						   	; siguientes
			add r11, 4*pixel_size

			sub r9, 4*pixel_size 	; si son los ultimos 4 no salta el jmp y pasa a hacer el caso borde				
			CMP R9, 16
			JNE .ciclo_wide	
		
		
	.caso_borde:  ;aunque no uso la etiqueta es para resaltar que es el ultimo caso
				
								
		; cargo pixeles:
		
			MOVDQU XMM0, [rbx + 0]					;xmmo=p03|p02|p01|p00
			
			MOVDQU XMM1, [rbx + r14]				;xmm1=p13|p12|p11|p10

			MOVDQU XMM2, [rbx + r14*2]				;xmm2=p23|p22|p21|p20
		
			;cambio pixeles del ciclo anterior:
			movdqu xmm15, [r11]
			movdqu [rbx], xmm15

	 		; Guardo el cuarto pixel calculado en el ciclo anterior (para no pisarse cuando levanto datos)
	 		MOV [R11], EAX

	;DESEMPAQUETO PARA PRIMER Y SEGUNDA MATRIz
			XORPD XMM15, XMM15			;LIMPIO XMM15
			
			MOVDQU XMM14, XMM0  
			PUNPCKLBW XMM14, XMM15				;xmm14=| P01:0B0G | P01:0R0A | P00:0B0G | P00:0R0A |
			MOVDQU XMM11, XMM14
			psrldq XMM11, 8						;XMM11=| 0000     | 0000     | P01:0B0G | P01:0R0A |		
			PUNPCKHBW XMM0, XMM15				;XMM0= | P03:0B0G | P03:0R0A | P02:0B0G | P02:0R0A |
			MOVDQU XMM10, XMM0
			PSLLDQ XMM10, 8 					;XMM10=| P02:0B0G | P02:0R0A | 0000 	| 0000     |
			
			PADDW XMM0, XMM11
			PADDW XMM0, XMM14
			PADDW XMM0, XMM10  				;XMM0=|SUMA SEGUNDO PIXEL   | SUMA PRIMER PIXEL   |
			
			MOVDQU XMM14, XMM1  
			PUNPCKLBW XMM14, XMM15				;xmm14=| P01:0B0G | P01:0R0A | P00:0B0G | P00:0R0A |
			MOVDQU XMM11, XMM14
			psrldq XMM11, 8						;XMM11=| 0000     | 0000     | P01:0B0G | P01:0R0A |		
			PUNPCKHBW XMM1, XMM15				;XMM1= | P03:0B0G | P03:0R0A | P02:0B0G | P02:0R0A |
			MOVDQU XMM10, XMM1
			PSLLDQ XMM10, 8 					;XMM10=| P02:0B0G | P02:0R0A | 0000 	| 0000     |
			
			PADDW XMM1, XMM11
			PADDW XMM1, XMM14
			PADDW XMM1, XMM10  				;XMM1=|SUMA SEGUNDO PIXEL   | SUMA PRIMER PIXEL   |
			
			MOVDQU XMM14, XMM2  
			PUNPCKLBW XMM14, XMM15				;xmm14=| P01:0B0G | P01:0R0A | P00:0B0G | P00:0R0A |
			MOVDQU XMM11, XMM14
			psrldq XMM11, 8						;XMM11=| 0000     | 0000     | P01:0B0G | P01:0R0A |		
			PUNPCKHBW XMM2, XMM15				;XMM2= | P03:0B0G | P03:0R0A | P02:0B0G | P02:0R0A |
			MOVDQU XMM10, XMM2
			PSLLDQ XMM10, 8 					;XMM10=| P02:0B0G | P02:0R0A | 0000 	| 0000     |
			
			PADDW XMM2, XMM11
			PADDW XMM2, XMM14
			PADDW XMM2, XMM10  				;XMM2=|SUMA SEGUNDO PIXEL   | SUMA PRIMER PIXEL   |
			
			PADDW XMM0, XMM1
			PADDW XMM0, XMM2				;XMM0 = |SUMPRIMER PIX | SUM SEG PIX |
			
			MOVDQU XMM1, XMM0
			
			PUNPCKLWD XMM0, XMM15	; XMM0 = PRIMER PIXEL (en int)=
													; | 00BB | 00GG | 00RR | 00AA |
			PUNPCKHWD XMM1, XMM15	; XMM15 = SEGUNDO PIXEL (en int)=
													; | 00BB | 00GG | 00RR | 00AA |
													
			CVTDQ2PS xmm0, xmm0 ;transformo int a single float	
			CVTDQ2PS xmm1, xmm1
			MOVDQU xmm14, [nueve]
			DIVPS xmm0, xmm14
			DIVPS xmm1, xmm14				; xmm0  y 1 = rgba promediado falta, arreglar A que no se promedia
			CVTPS2DQ xmm0, xmm0
			CVTPS2DQ xmm1, xmm1 			;los convierto a int de nuevo 	
			PACKUSDW xmm0, xmm15			; |0|0|0|0|w|w|w|w||
			PACKUSWB xmm0, xmm15			; | 0 | 0 | 0 |bbbb|
			PACKUSDW xmm1, xmm15			; |0|0|0|0|w|w|w|w||
			PACKUSWB xmm1, xmm15			; | 0 | 0 | 0 |bbbb|
			
			
			; Actualizo ultimos 3 pixeles en la imagen desde el vector

			MOV EDI, [R11 + 4]
			MOV [RBX + 4], EDI

			MOV EDI, [R11 + 8]
			MOV [RBX + 8], EDI

			MOV EDI, [R11 + 12]
			MOV [RBX + 12], EDI

			;guardo primer pixel modificado en vector

			PEXTRD [R11 + 4], XMM0, 0

			;guardo segundo pixel modificado en vector

			PEXTRD [R11 + 8], XMM1, 0

			; guardo el ultimo pixel de la fila sin modificar para reemplazarlo en la proxima

			MOV EDI, [RBX + R14 + 12]
			MOV [R11 + 12], EDI

	;fin_wide:
		;termine el caso borde, incremente / decremento variables para el ciclo height:

		LEA RBX, [RBX + 16]
		MOV R11, R15 			; vuelvo al principio del vector auxiliar
		sub r8, 1
		CMP R8, 0
		JNE .ciclo_height
	
	
	; Cargo en la imagen la anteultima fila que quedo cargada en el vector
 		XOR R9, R9
 		DEC R12 				; porque el ultimo no tengo que modificarlo

 		.copiar_vector:
 		MOV EDI, [R11 + R9*4]
 		MOV [RBX + R9*4], EDI 		
 		INC R9						; proximo pixel
 		CMP R9, R12
 		JNE .copiar_vector
	
	mov rdi, r15
	call free
	
.fin:
	add rsp, 8
	pop r12
	pop r13
	pop r14
	pop r15
	pop rbx	
	pop rbp
 	ret