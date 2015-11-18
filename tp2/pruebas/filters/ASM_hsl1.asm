; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion HSL 1                                      ;
;                                                                           ;
; ************************************************************************* ;

; void ASM_hsl1(uint32_t w, uint32_t h, uint8_t* data, float hh, float ss, float ll)

global ASM_hsl1

extern malloc
extern free
extern rgbTOhsl
extern hslTOrgb

section .rodata

align 16
cmp360: DD 0.0, 360.0, 0.0, 0.0
cmp1: DD 0.0, 0.0, 1.0, 1.0

section .text

ASM_hsl1:

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




	.ciclo_filas:
			.ciclo_columnas:


			; Convierto rgb a hsl y guardo en vector auxiliar
			MOV RDI, RBX
			MOV RSI, R15

			; Pusheo xmms usados: 0, 8, 10, 12
			MOVDQU [RSP], XMM0
			SUB RSP, 16
			MOVDQU [RSP], XMM8
			SUB RSP, 16
			MOVDQU [RSP], XMM10
			SUB RSP, 16
			MOVDQU [RSP], XMM12
			SUB RSP, 16

			CALL rgbTOhsl

			ADD RSP, 16
			MOVDQU XMM12, [RSP]
			ADD RSP, 16
			MOVDQU XMM10, [RSP]
			ADD RSP, 16
			MOVDQU XMM8, [RSP]
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

			; Pusheo xmms usados: 0, 8, 10, 12
			MOVDQU [RSP], XMM0
			SUB RSP, 16
			MOVDQU [RSP], XMM8
			SUB RSP, 16
			MOVDQU [RSP], XMM10
			SUB RSP, 16
			MOVDQU [RSP], XMM12
			SUB RSP, 16

			CALL hslTOrgb

			ADD RSP, 16
			MOVDQU XMM12, [RSP]
			ADD RSP, 16
			MOVDQU XMM10, [RSP]
			ADD RSP, 16
			MOVDQU XMM8, [RSP]
			ADD RSP, 16
			MOVDQU XMM0, [RSP]

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