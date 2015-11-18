; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion HSL 2                                      ;
;                                                                           ;
; ************************************************************************* ;

; void ASM_hsl2(uint32_t w, uint32_t h, uint8_t* data, float hh, float ss, float ll)

global ASM_hsl2

extern malloc
extern free

section .rodata

align 16
cmp360: DD 0.0, 360.0, 0.0, 0.0
cmp1: DD 0.0, 0.0, 1.0, 1.0
fabs: DD 0x7FFFFFFF, 0x7FFFFFFF, 0x7FFFFFFF, 0x7FFFFFFF
sesenta: DD 60.0, 60.0, 60.0, 60.0
mask255: DD 255.0, 255.0, 255.0, 255.0

label510: DD 510.0

align 16
label255: DD 255.0001

align 16
dos: DD 2.0

section .text

ASM_hsl2:

	push rbp
    mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	
	; edi <- ancho en pixeles
	; esi <- alto en pixeles
	; rdx <- puntero a matriz
	; xmm0 <- hh
	; xmm1 <- ss
	; xmm2 <- ll

	MOV RBX, RDX 			; puntero a la matriz

	;Me armo el sumador en xmm0 :   | LL | SS | HH | 0 |
	PSLLDQ XMM0, 4
	PSLLDQ XMM1, 8
	PSLLDQ XMM2, 12
	POR XMM0, XMM1
	POR XMM0, XMM2

	;Calculo cantidad de iteraciones (voy a iterar pixel a pixel)
	
	MOV R12d, EDI 			; ancho en pixeles
	SHL R12, 2 				; ancho en bytes
	MOV R13d, ESI  			; cantidad de filas

	XOR R14, R14 			; inicializo contador de columnas (offset)

	;Creo vector donde voy a guardar los float A H S L
	MOV RDI, 16
	CALL malloc
	MOV R15, RAX 			; r15 <- puntero al vector auxiliar

	;Cargo las mascaras una sola vez
	MOVDQA XMM8, [cmp360]
	MOVDQA XMM10, [cmp1]
	XORPD XMM12, XMM12 ; lo uso para comparar con 0
	MOVSS XMM15, [dos]
	MOVDQA XMM14, [sesenta]



	.ciclo_filas:
			.ciclo_columnas:


			; Convierto rgb a hsl y guardo en vector auxiliar
			MOV RDI, RBX
			MOV RSI, R15

			; Pusheo para preservarlo
			MOVDQU [RSP], XMM0
			SUB RSP, 16

			CALL rgbTOhsl

			ADD RSP, 16
			MOVDQU XMM0, [RSP]

			;Cargo vector en xmm1
			MOVDQU XMM1, [R15]			; xmm1 | L | S | H | A
			;Sumo los parametros 
			ADDPS XMM1, XMM0 			; xmm1 | L+ll | S+ss | H+hh | A

			;Creo una copia en xmm2
			MOVDQU XMM2, XMM1

			;Comparaciones

			;1) Caso H+hh >= 360
			MOVDQU XMM9, XMM8 			; xmm9  | 0 | 0 | 360 | 0 |
			CMPPS XMM9, XMM1, 2         ; es CMP LE  less or equal:  xmm9 | X | X |  360 <= H+hh ? | X | 
			PAND XMM9, XMM8 			; xmm9 | 0 | 0 | 360 | 0 |  o  | 0 | 0 | 0 | 0 | si dio true o false
			SUBPS XMM1, XMM9 			; resto 360 si era mayor o igual a 360

			;2) Casos S+ss >= 1 y L+ll >= 1
			MOVDQU XMM9, XMM10 			; xmm9  | 1 | 1 | 0 | 0 |
			MOVDQU XMM11, XMM10 		; xmm11  | 1 | 1 | 0 | 0 |
			CMPPS XMM9, XMM1, 2 		; | 1<= L+ll | 1<= S+ss | X | X |
			PAND XMM11, XMM9 			; si dio true, queda el 1, sino se pone en 0
			MOVDQU XMM2, XMM11			; xmm2 | 1 si 1<= L+ll, sino 0 |  1 si 1<= S+ss, sino 0 | X | X |
			CMPPS XMM12, XMM2, 0		; comparo EQ con 0  xmm12 | =0? | =0? | x | x |
			PAND XMM12, XMM1 			; si era 0, va a poner en xmm12 los valores originales de L y S, sino 0
			ADDPS XMM2, XMM12			; Si habia puesto un 0 (no se habia cumplido la condicion), sumo los 							 ; valores originales, sino sumo 0. (importan solo las partes de L y S)
			SHUFPS XMM1, XMM2, 228      ; Reestablezco A y H (las partes bajas), y cargo las partes altas de 							 ; xmm2 en xmm1 (L y S) que modifique con las mascaras.
			
			XORPD XMM12, XMM12 			; lo voy a volver a usar para comparar con 0
			MOVDQU XMM2, XMM1 			; voy a volver a usar la copia para las mascaras

			;3) Casos < 0	
			CMPPS XMM2, XMM12, 1 		; | L+ll < 0 | S+ss < 0 | H+hh < 0 | X |
			MOVDQU XMM9, XMM8 			; xmm9  | 0 | 0 | 360 | 0 |
			PAND XMM9, XMM2 			; xmm9  | 0 | 0 | 360 o 0 segun xmm2 | 0 |
			ADDPS XMM1, XMM9   			; Sumo 360 a H si era menor a 0
			PANDN XMM2, XMM1   			; Si habia dado 1 en L , 0 AND L = 0 (lo mismo para S)
										; Si habia dado 0 en L, 1 AND L = L (lo mismo para S)
			SHUFPS XMM1, XMM2, 228      ; Sin modificar las partes bajas, cargo las partes altas de 							   	    ; xmm2 en xmm1 (L y S) que modifique con las mascaras.

			; Cargo en memoria

			MOVDQU [R15], XMM1
			MOV RDI, R15
			MOV RSI, RBX

			CALL hslTOrgb

			LEA RBX, [RBX + 4]			; Actualizo puntero al pixel
			ADD R14, 4					; avanzo aL proximo pixel
			CMP R14, R12 				; me fijo si llegue al final de la fila
			JNE .ciclo_columnas

		XOR R14, R14 			; reinicio el offset
		DEC R13
		CMP R13, 0
		JNE .ciclo_filas		; repito para la proxima fila

	MOV RDI, R15
	CALL free

 	pop r15
 	pop r14
 	pop r13
 	pop r12
 	pop rbx
	pop rbp

	ret
  

	rgbTOhsl:

		; Cargo primer pixel en la parte baja de xmm0
		MOV EAX, [RDI]
		PINSRD XMM0, EAX, 0

		; Desempaqueto
		XORPD XMM9, XMM9
		PUNPCKLBW XMM0, XMM9	
		PUNPCKLWD XMM0, XMM9					;	|	B	|	G	|	R	|	A	| xmm0

		; Convierto a float
		CVTDQ2PS XMM0, XMM0

		; Guardo A pues no se modifica
		MOVSS [RSI], XMM0

		; Calculo de maximos y minimos
		PSRLDQ XMM0, 4
		MOVSS XMM3, XMM0 						;	|	x	|	x	|	x	|	B	| xmm3		
		PSRLDQ XMM0, 4
		MOVSS XMM2, XMM0	 					;	|	x	|	x	|	x	|	G	| xmm2	
		PSRLDQ XMM0, 4
		MOVSS XMM1, XMM0	 					;	|	x	|	x	|	x	|	R	| xmm1
	
		MOVSS XMM4, XMM1
		MAXSS XMM4, XMM2
		MAXSS XMM4, XMM3 		 				;	|	x	|	x	|	x	| cmax | xmm4	
		
		MOVSS XMM5, XMM1
		MINSS XMM5, XMM2
		MINSS XMM5, XMM3 		 				;	|	x	|	x	|	x	| cmin | xmm5		

		MOVSS XMM6, XMM4
		SUBSS XMM6, XMM5	 		 			;	|	x	|	x	|	x	| 	d 	| xmm6

		; Calculo de H

		; Inicio registros y cargo mascaras
		XORPD XMM7, XMM7


		; if cmax = blue, guardo la cuenta de xmm11, sino 0
		MOVSS XMM9, XMM3
		CMPSS XMM9, XMM4, 0 		 			;	|	x	|	x	|	x	| CMAX=B? | xmm9
		
		;Cuenta para blue:
		MOVSS XMM11, XMM1
		SUBSS XMM11, XMM2
		DIVSS XMM11, XMM6
		ADDSS XMM11, XMM15  					; +2
		ADDSS XMM11, XMM15						; +2
		MULSS XMM11, XMM14						; *60

		PAND XMM9, XMM11
		MOVSS XMM7, XMM9

		; if cmax = green, actualizo por la cuenta de xmm11, sino dejo el blue
		MOVSS XMM9, XMM2
		CMPSS XMM9, XMM4, 0		 			;	|	x	|	x	|	x	| CMAX=G? | xmm9

		;Cuenta para green:
		MOVSS XMM11, XMM3
		SUBSS XMM11, XMM1
		DIVSS XMM11, XMM6
		ADDSS XMM11, XMM15						; +2
		MULSS XMM11, XMM14						; *60

		MOVDQU XMM13, XMM9	 				;	|	x	|	x	|	x	| CMAX=G? | xmm10
		PANDN XMM13, XMM7					; si dio 0 guardo lo que habia en xmm7, sino un 0
		MOVSS XMM7, XMM13					; actualizo xmm7 por el valor anterior
		PAND XMM9, XMM11						
		ADDSS XMM7, XMM9					; si habia dado true, cargo la cuenta de G, sino queda la anterior

		; if cmax = red, actualizo por la cuenta de xmm11, sino dejo el blue
		MOVSS XMM9, XMM1
		CMPSS XMM9, XMM4, 0		 			;	|	x	|	x	|	x	| CMAX=R? | xmm9

		;Cuenta para red:
		MOVSS XMM11, XMM2
		SUBSS XMM11, XMM3
		DIVSS XMM11, XMM6
		ADDSS XMM11, XMM15  					; +2
		ADDSS XMM11, XMM15						; +2
		ADDSS XMM11, XMM15						; +2
		MULSS XMM11, XMM14						; *60


		MOVDQU XMM13, XMM9	 				;	|	x	|	x	|	x	| CMAX=G? | xmm10
		PANDN XMM13, XMM7					; si dio 0 guardo lo que habia en xmm7, sino un 0
		MOVSS XMM7, XMM13					; actualizo xmm7 por el valor anterior
		PAND XMM9, XMM11						
		ADDSS XMM7, XMM9					; si habia dado true, cargo la cuenta de G, sino queda la anterior

		; Caso cmax = cmin
		MOVSS XMM9, XMM4
		CMPSS XMM9, XMM5, 0
		PANDN XMM9, XMM7
		MOVSS XMM7, XMM9

		; me fijo si me pase de 360
		PSRLDQ XMM8, 4
		MOVSS XMM9, XMM8 					;	|	x	|	x	|	x	| 360.0 | xmm9
		CMPSS XMM9, XMM7, 2 				;	|	x	|	x	|	x	| 360<=H? | xmm9
		PAND XMM9, XMM8
		PSLLDQ XMM8, 4
		SUBSS XMM7, XMM9

		MOVSS [RSI+4], XMM7

		; Calculo de L
		MOVSS XMM7, XMM4
		ADDSS XMM7, XMM5
		DIVSS XMM7, [label510]

		MOVSS [RSI+12], XMM7

		; Calculo de S

		MULSS XMM7, XMM15
		PSRLDQ XMM10, 8
		SUBSS XMM7, XMM10
		PAND XMM7, [fabs]
		MOVSS XMM11, XMM10
		PSLLDQ XMM10, 8
		SUBSS XMM11, XMM7
		MOVSS XMM7, XMM6
		DIVSS XMM7, XMM11
		DIVSS XMM7, [label255]

		; Caso cmax = cmin
		MOVSS XMM9, XMM4
		CMPSS XMM9, XMM5, 0
		PANDN XMM9, XMM7
		MOVSS XMM7, XMM9

		MOVSS [RSI+8], XMM7

		ret

	hslTOrgb:

		; Calculo de c, x y m

		MOVSS XMM1, [RDI+4] 		; H 	
		MOVSS XMM2, [RDI+8]			; S
		MOVSS XMM3, [RDI+12] 		; L

		; Calculo C en xmm4
									; Partes Bajas: (31:0)

		MOVSS XMM7, XMM3 			; xmm7 = l
		MULSS XMM7, XMM15  			; xmm7 = l*2
		PSRLDQ XMM10, 8 			; shifteo para usar el 1
		SUBSS XMM7, XMM10 			; xmm7 = l*2 - 1
		PAND XMM7, [fabs] 			; xmm7 = fabs (l*2 - 1)
		MOVSS XMM4, XMM10 			; xmm4 = 1 
		PSLLDQ XMM10, 8
		SUBSS XMM4, XMM7 			; xmm4 = 1 - fabs (l*2 - 1)
		MULSS XMM4, XMM2 			; xmm4 = (1 - fabs (l*2 - 1)) * s

		; Calculo X en xmm5

		MOVSS XMM7, XMM1 			; xmm7 = h
		DIVSS XMM7, XMM14 			; xmm7 = h/60
		MOVSS XMM9, XMM7 			; xmm9 = h/60
		DIVSS XMM9, XMM15 			; xmm9 = (h/60) / 2
		CVTTSS2SI EAX, XMM9 		; eax = (int) (h/60) / 2
		CVTSI2SS XMM9, EAX 			; xmm9 = (h/60) / 2 (sin decimales)
		MULSS XMM9, XMM15 			; multiplico el cociente por 2 para despues restar y obtener el resto
		SUBSS XMM7, XMM9			; xmm7 = fmod (h/60, 2)
		PSRLDQ XMM10, 8 			; shifteo para usar el uno
		SUBSS XMM7, XMM10 			; xmm7 = fmod (h/60, 2) - 1
		MOVSS XMM5, XMM10			; xmm5 = 1
		PSLLDQ XMM10, 8
		PAND XMM7, [fabs] 			; xmm7 = fabs( fmod (h/60, 2) - 1 )
		SUBSS XMM5, XMM7 			; xmm5 = 1 - fabs( fmod (h/60, 2) - 1 )
		MULSS XMM5, XMM4 			; xmm5 = (1 - fabs( fmod (h/60, 2) - 1 )) * c

		; Calculo M en xmm6

		MOVSS XMM7, XMM4 			; xmm7 = c
		DIVSS XMM7, XMM15 			; xmm7 = c / 2 	
		MOVSS XMM6, XMM3		
		SUBSS XMM6, XMM7 			; xmm6 = l - ( c/2 )

		; Calculo de RGB

									;		| R | G | B | A |
		PSLLDQ XMM4, 8 				; xmm4  | ? | C | 0 | 0 |
		MOVSS XMM4, XMM5 			; xmm4  | ? | C | 0 | x |		
		PSLLDQ XMM4, 4 	 			; xmm4  | C | 0 | X | 0 |
		MOVSS XMM5, [RDI]		
		MOVSS XMM4, XMM5	 		; xmm4  | C | 0 | X | A |

		MOVUPS XMM5, XMM4	 		; xmm5  | C | 0 | X | A |
		SHUFPS XMM1, XMM1, 0 		; xmm1  | H | H | H | H |
		PSRLDQ XMM8, 4
		MOVSS XMM13, XMM8			; xmm13 | ? | ? | ? | 360 |
		PSLLDQ XMM8, 4
		SHUFPS XMM13, XMM13, 0 		; xmm13 | 360 | 360 | 360 | 360 |	
									; xmm14 | 60 | 60 | 60 | 60 | (cargado al principio del programa)

		; Arranco tomando el caso h entre 300 y 360. (xmm4 = | C | x | 0 | A | )								

		; Caso h < 300?
		SUBPS XMM13, XMM14  		; xmm13 | 300 | 300 | 300 | 300 |
		MOVUPS XMM9, XMM1 			; xmm9  | H | H | H | H |
		CMPPS XMM9, XMM13, 1 		; xmm9  | H<300? | H<300? | H<300? | H<300? |
		SHUFPS XMM5, XMM5, 108 		; xmm5  | x | 0 | C | A | 
		; Si da true, reinicio xmm4, sino, lo dejo como estaba. (con el pandn)
		; Si da true, guardo en xmm7 los nuevos valores, sino guardo 0s, y los sumo a xmm4. 
		MOVUPS XMM7, XMM5			; xmm7  | x | 0 | C | A |  
		PAND XMM7, XMM9 			
		PANDN XMM9, XMM4
		MOVUPS XMM4, XMM9
		ADDPS XMM4, XMM7

		; Caso h < 240?
		SUBPS XMM13, XMM14  		; xmm13 | 240 | 240 | 240 | 240 |
		MOVUPS XMM9, XMM1 			; xmm9  | H | H | H | H |
		CMPPS XMM9, XMM13, 1 		; xmm9  | H<240? | H<240? | H<240? | H<240? |
		SHUFPS XMM5, XMM5, 180 		; xmm5  | 0 | x | C | A | 
		; Si da true, reinicio xmm4, sino, lo dejo como estaba. (con el pandn)
		; Si da true, guardo en xmm7 los nuevos valores, sino guardo 0s, y los sumo a xmm4. 
		MOVUPS XMM7, XMM5			
		PAND XMM7, XMM9 			
		PANDN XMM9, XMM4
		MOVUPS XMM4, XMM9
		ADDPS XMM4, XMM7

		; Caso h < 180?
		SUBPS XMM13, XMM14  		; xmm13 | 180 | 180 | 180 | 180 |
		MOVUPS XMM9, XMM1 			; xmm9  | H | H | H | H |
		CMPPS XMM9, XMM13, 1 		; xmm9  | H<180? | H<180? | H<180? | H<180? |
		SHUFPS XMM5, XMM5, 216 		; xmm5  | 0 | C | x | A | 
		; Si da true, reinicio xmm4, sino, lo dejo como estaba. (con el pandn)
		; Si da true, guardo en xmm7 los nuevos valores, sino guardo 0s, y los sumo a xmm4. 
		MOVUPS XMM7, XMM5			
		PAND XMM7, XMM9 			
		PANDN XMM9, XMM4
		MOVUPS XMM4, XMM9
		ADDPS XMM4, XMM7

		; Caso h < 120?
		SUBPS XMM13, XMM14  		; xmm13 | 120 | 120 | 120 | 120 |
		MOVUPS XMM9, XMM1 			; xmm9  | H | H | H | H |
		CMPPS XMM9, XMM13, 1 		; xmm9  | H<120? | H<120? | H<120? | H<120? |
		SHUFPS XMM5, XMM5, 108 		; xmm5  | x | C | 0 | A | 
		; Si da true, reinicio xmm4, sino, lo dejo como estaba. (con el pandn)
		; Si da true, guardo en xmm7 los nuevos valores, sino guardo 0s, y los sumo a xmm4. 
		MOVUPS XMM7, XMM5			
		PAND XMM7, XMM9 			
		PANDN XMM9, XMM4
		MOVUPS XMM4, XMM9
		ADDPS XMM4, XMM7

		; Caso h < 60?
		SUBPS XMM13, XMM14  		; xmm13 | 60 | 60 | 60 | 60 |
		MOVUPS XMM9, XMM1 			; xmm9  | H | H | H | H |
		CMPPS XMM9, XMM13, 1 		; xmm9  | H<60? | H<60? | H<60? | H<60? |
		SHUFPS XMM5, XMM5, 180 		; xmm5  | C | X | 0 | A | 
		; Si da true, reinicio xmm4, sino, lo dejo como estaba. (con el pandn)
		; Si da true, guardo en xmm7 los nuevos valores, sino guardo 0s, y los sumo a xmm4. 
		MOVUPS XMM7, XMM5			
		PAND XMM7, XMM9 			
		PANDN XMM9, XMM4
		MOVUPS XMM4, XMM9
		ADDPS XMM4, XMM7

		; Calculo de Escala
		SHUFPS XMM6, XMM6, 0 
		ADDPS XMM4, XMM6 			; sumo M a cada componente
		MULPS XMM4, [mask255] 		; multiplico por 255 cada componente
		MOVSS XMM5, [RDI]
		MOVSS XMM4, XMM5	 		; restauro A

		; En xmm4 tengo | R | G | B | A |
		CVTPS2DQ XMM4, XMM4			; los convierto a enteros
		PACKUSDW XMM4, XMM12 		; empaqueto cada componente a byte
		PACKUSWB XMM4, XMM12 

		PEXTRD [RSI], XMM4, 0

		ret