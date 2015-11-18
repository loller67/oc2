; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Merge 2                                    ;
;                                                                           ;
; ************************************************************************* ;

; void ASM_merge2(uint32_t w, uint32_t h, uint8_t* data1, uint8_t* data2, float value)
global ASM_merge2


section .rodata

aux: DD 256.0, 256.0, 256.0, 256.0
mascara: DB 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00
mascara2: DB 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0xFF, 0xFF

section .text

ASM_merge2:

	push rbp
    mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15

	; edi <- ancho en pixeles
	; esi <- alto en pixeles
	; rdx <- puntero a m1
	; rcx <- puntero a m2
	; xmm0 <- value

	MOV R15, RDX			; puntero a m1
	MOV R14, RCX 			; puntero a m2
	MOV EBX, EDI 			; ancho en pixeles
	SHL EBX, 2				; ancho en bytes
	MOV ECX, ESI  			; cantidad de filas

	XOR R12, R12 			; inicializo contador de columnas
	XOR R13, R13			; inicializo contador de filas
	
	XORPD XMM9, XMM9		; lo voy a usar para pack y unpack

	SHUFPS XMM0, XMM0, 0    						; 	| value	| value	| value	| value | xmm0
	MOVUPS XMM15, [aux]
	MULPS XMM0, XMM15    							; 	|	v1	|	v1	|	v1	| 	v1	| xmm0 (floats)
	CVTPS2DQ XMM0, XMM0    							; 	|	v1	|	v1	|	v1	| 	v1	| xmm0 (int de 32b)
	CVTPS2DQ XMM15, XMM15    						; 	|	aux	|	aux	|	aux	|	aux	| xmm15 (int de 32b)
	MOVQ XMM14, XMM15    							; 	|	aux	|	aux	|	aux	|	aux	| xmm14 (int de 32b)
	PSUBD XMM15, XMM0    							; 	|	v2	|	v2	|	v2	| 	v2	| xmm15 (int de 32b)

	PACKUSDW XMM0, XMM0    							; 	|v1|v1|v1|v1|v1|v1|v1|v1| xmm0 (int de 16b)
	
	PACKUSDW XMM15, XMM15    						; 	|v2|v2|v2|v2|v2|v2|v2|v2| xmm15 (int de 16b)

	.ciclo_filas:
		.ciclo_columnas:

			MOVDQU XMM1, [R15 + R12]				; | 4to	| 3ro | 2do | 1ro |  xmm1   (m1)
			MOVDQU XMM5, [R14 + R12]				; | 4to	| 3ro | 2do | 1ro |  xmm5	(m2)

			; Resguardo A de m1

			MOVDQU XMM10, XMM1

			MOVDQU XMM11, [mascara]
			PAND XMM10, XMM11					; 	|X|X|X|A|X|X|X|A|X|X|X|A|X|X|X|A| xmm10 (bytes)

			; Desempaquetado pixeles m1
			XORPD XMM9, XMM9

			MOVDQU XMM3, XMM1						; | 4to	| 3ro | 2do | 1ro |	 xmm3
			PUNPCKLBW XMM1, XMM9					; |    2do    |    1ro    |	 xmm1
			PUNPCKHBW XMM3, XMM9					; |    4to    |    3ro    |	 xmm3

			; Desempaquetado pixeles m2

			MOVDQU XMM7, XMM5						; | 4to	| 3ro | 2do | 1ro |	 xmm7
			PUNPCKLBW XMM5, XMM9					; |    2do    |    1ro    |	 xmm5
			PUNPCKHBW XMM7, XMM9					; |    4to    |    3ro    |	 xmm7

			; Operaciones

			; Multiplico por v1 los pixeles de m1, y por v2 los pixeles de m2

			MOVDQU XMM2, XMM1
			PMULHUW XMM2, XMM0  ;| B*v1 | G*v1 | R*v1 | A*v1 | B*v1 | G*v1 | R*v1 | A*v1 | xmm2 (PARTES ALTAS)
			PMULLW XMM1, XMM0   ;| B*v1 | G*v1 | R*v1 | A*v1 | B*v1 | G*v1 | R*v1 | A*v1 | xmm1 (PARTES BAJAS)
			MOVDQU XMM9, XMM1	;| B*v1 | G*v1 | R*v1 | A*v1 | B*v1 | G*v1 | R*v1 | A*v1 | xmm9 (PARTES BAJAS)
			PUNPCKLWD XMM1, XMM2  					; | B*v1 | G*v1 | R*v1 | A*v1 | (1er pixel m1) xmm1
			PUNPCKHWD XMM9, XMM2  					; | B*v1 | G*v1 | R*v1 | A*v1 | (2do pixel m1) xmm9
			MOVDQU XMM2, XMM9  						; | B*v1 | G*v1 | R*v1 | A*v1 | (2do pixel m1) xmm2

			MOVDQU XMM4, XMM3
			PMULHUW XMM4, XMM0  ;| B*v1 | G*v1 | R*v1 | A*v1 | B*v1 | G*v1 | R*v1 | A*v1 | xmm4 (PARTES ALTAS)
			PMULLW XMM3, XMM0   ;| B*v1 | G*v1 | R*v1 | A*v1 | B*v1 | G*v1 | R*v1 | A*v1 | xmm3 (PARTES BAJAS)
			MOVDQU XMM9, XMM3	;| B*v1 | G*v1 | R*v1 | A*v1 | B*v1 | G*v1 | R*v1 | A*v1 | xmm9 (PARTES BAJAS)
			PUNPCKLWD XMM3, XMM4  					; | B*v1 | G*v1 | R*v1 | A*v1 | (3er pixel m1) xmm3
			PUNPCKHWD XMM9, XMM4  					; | B*v1 | G*v1 | R*v1 | A*v1 | (4to pixel m1) xmm9
			MOVDQU XMM4, XMM9  						; | B*v1 | G*v1 | R*v1 | A*v1 | (4to pixel m1) xmm4

			MOVDQU XMM6, XMM5
			PMULHUW XMM6, XMM15  ;| B*v2 | G*v2 | R*v2 | A*v2 | B*v2 | G*v2 | R*v2 | A*v2 | xmm6 (PARTES ALTAS)
			PMULLW XMM5, XMM15   ;| B*v2 | G*v2 | R*v2 | A*v2 | B*v2 | G*v2 | R*v2 | A*v2 | xmm5 (PARTES BAJAS)
			MOVDQU XMM9, XMM5	 ;| B*v2 | G*v2 | R*v2 | A*v2 | B*v2 | G*v2 | R*v2 | A*v2 | xmm9 (PARTES BAJAS)
			PUNPCKLWD XMM5, XMM6  					; | B*v2 | G*v2 | R*v2 | A*v2 | (1er pixel m2) xmm5
			PUNPCKHWD XMM9, XMM6  					; | B*v2 | G*v2 | R*v2 | A*v2 | (2do pixel m2) xmm9
			MOVDQU XMM6, XMM9  						; | B*v2 | G*v2 | R*v2 | A*v2 | (2do pixel m2) xmm6

			MOVDQU XMM8, XMM7
			PMULHUW XMM8, XMM15  ;| B*v2 | G*v2 | R*v2 | A*v2 | B*v2 | G*v2 | R*v2 | A*v2 | xmm8 (PARTES ALTAS)
			PMULLW XMM7, XMM15   ;| B*v2 | G*v2 | R*v2 | A*v2 | B*v2 | G*v2 | R*v2 | A*v2 | xmm7 (PARTES BAJAS)
			MOVDQU XMM9, XMM7	 ;| B*v2 | G*v2 | R*v2 | A*v2 | B*v2 | G*v2 | R*v2 | A*v2 | xmm9 (PARTES BAJAS)
			PUNPCKLWD XMM7, XMM8  					; | B*v2 | G*v2 | R*v2 | A*v2 | (3er pixel m2) xmm7
			PUNPCKHWD XMM9, XMM8  					; | B*v2 | G*v2 | R*v2 | A*v2 | (4to pixel m2) xmm9
			MOVDQU XMM8, XMM9  						; | B*v2 | G*v2 | R*v2 | A*v2 | (4to pixel m2) xmm8

			; Sumo los pixeles correspondientes

			PADDD XMM1, XMM5 ; con saturacion? pero son numeros
			PADDD XMM2, XMM6
			PADDD XMM3, XMM7
			PADDD XMM4, XMM8

			; Divido cada componente de estos 4 registros (cada componente tiene 4 bytes) por A (256)

			PSRLD XMM1, 8
			PSRLD XMM2, 8
			PSRLD XMM3, 8
			PSRLD XMM4, 8

			; Empaqueto estos 4 pixeles en un solo registro

			PACKUSDW XMM1, XMM2					; |    2do    |    1ro    |	 xmm1
			PACKUSDW XMM3, XMM4					; |    4to    |    3ro    |	 xmm3

			PACKUSWB XMM1,XMM3					; | 4to	| 3ro | 2do | 1ro |  xmm1

			; Reestablezco los componentes A

			MOVDQU XMM11, [mascara2]
			PAND XMM1, XMM11				; 	|X|X|X|0|X|X|X|0|X|X|X|0|X|X|X|0| xmm10 (bytes)
												; X es el resultado de las cuentas anteriores
			POR XMM1, XMM10									

			; Guardo en memoria

			MOVDQU [R15 + R12], XMM1

			ADD R12, 16			; avanzo a los proximos 4 pixeles
			CMP R12D, EBX 		; me fijo si llegue al final de la fila
			JNE .ciclo_columnas

		LEA R15, [R15+R12]		; actualizo el puntero a la matriz 1
		LEA R14, [R14+R12]		; actualizo el puntero a la matriz 2	

		XOR R12, R12			; reinicio el offset
		INC R13
		CMP R13D, ECX
		JNE .ciclo_filas		; repito para la proxima fila

 	pop r15
 	pop r14
 	pop r13
 	pop r12
 	pop rbx
	pop rbp
	ret


  ret