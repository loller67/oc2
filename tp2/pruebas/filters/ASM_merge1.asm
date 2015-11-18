; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Merge 1                                    ;
;                                                                           ;
; ************************************************************************* ;



; void ASM_merge1(uint32_t w, uint32_t h, uint8_t* data1, uint8_t* data2, float value)
global ASM_merge1


section .rodata

uno: DD 1.0, 1.0, 1.0, 1.0

section .text

ASM_merge1:

	push rbp
    mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14

	; edi <- ancho en pixeles
	; esi <- alto en pixeles
	; rdx <- puntero a m1
	; rcx <- puntero a m2
	; xmm0 <- value

	MOV R14, RCX 			; puntero a m2
	MOV EBX, EDI 			; ancho en pixeles
	SHL EBX, 2				; ancho en bytes
	MOV ECX, ESI  			; cantidad de filas

	XOR R12, R12 			; inicializo contador de columnas
	XOR R13, R13			; inicializo contador de filas
	XORPD XMM9, XMM9		; lo voy a usar para pack y unpack

	SHUFPS XMM0, XMM0, 0    						; 	| value	| value	| value	| value | xmm0
	MOVUPS XMM14, XMM0
	MOVUPS XMM15, [uno]
	SUBPS XMM15, XMM14    					; 	| 1- value	| 1- value	| 1- value	| 1- value | xmm15

	.ciclo_filas:
		.ciclo_columnas:

			MOVDQU XMM1, [RDX + R12]				; | 4to	| 3ro | 2do | 1ro |  xmm1   (m1)
			MOVDQU XMM5, [R14 + R12]				; | 4to	| 3ro | 2do | 1ro |  xmm5	(m2)

			; Desempaquetado pixeles m1

			MOVDQU XMM3, XMM1						; | 4to	| 3ro | 2do | 1ro |	 xmm3
			PUNPCKLBW XMM1, XMM9					; |    2do    |    1ro    |	 xmm1
			PUNPCKHBW XMM3, XMM9					; |    4to    |    3ro    |	 xmm3

			MOVDQU XMM2, XMM1						; |    2do    |    1ro    |	 xmm2
			MOVDQU XMM4, XMM3						; |    4to    |    3ro    |	 xmm4
			PUNPCKLWD XMM1, XMM9					; |          1ro          |	 xmm1
			PUNPCKHWD XMM2, XMM9					; |          2do          |	 xmm2
			PUNPCKLWD XMM3, XMM9					; |          3ro          |	 xmm3
			PUNPCKHWD XMM4, XMM9					; |          4to          |	 xmm4

			; Desempaquetado pixeles m2

			MOVDQU XMM7, XMM5						; | 4to	| 3ro | 2do | 1ro |	 xmm7
			PUNPCKLBW XMM5, XMM9					; |    2do    |    1ro    |	 xmm5
			PUNPCKHBW XMM7, XMM9					; |    4to    |    3ro    |	 xmm7

			MOVDQU XMM6, XMM5						; |    2do    |    1ro    |	 xmm6
			MOVDQU XMM8, XMM7						; |    4to    |    3ro    |	 xmm8
			PUNPCKLWD XMM5, XMM9					; |          1ro          |	 xmm5
			PUNPCKHWD XMM6, XMM9					; |          2do          |	 xmm6
			PUNPCKLWD XMM7, XMM9					; |          3ro          |	 xmm7
			PUNPCKHWD XMM8, XMM9					; |          4to          |	 xmm8

			; Conversiones de enteros de 4bytes a floats

			CVTDQ2PS XMM1, XMM1
			CVTDQ2PS XMM2, XMM2
			CVTDQ2PS XMM3, XMM3
			CVTDQ2PS XMM4, XMM4
			CVTDQ2PS XMM5, XMM5
			CVTDQ2PS XMM6, XMM6
			CVTDQ2PS XMM7, XMM7
			CVTDQ2PS XMM8, XMM8

			; Operaciones

			MOVSS XMM10, XMM1				;	|	x	|	x	|	x	|	A	| xmm10
			MULPS XMM1, XMM0				;	| B*value |	G*value	| R*value | A*value	| xmm1
			MULPS XMM5, XMM15				;	| B*(1-value) |	G*(1-value)	| R*(1-value) | A*(1-value)	| xmm5
			ADDPS XMM1, XMM5		;	| B*v + B*(1-v) | G*v + G*(1-v)	| R*v + R*(1-v) | A*v + A*(1-v) | xmm1
			MOVSS XMM1, XMM10		;	| B*v + B*(1-v) | G*v + G*(1-v)	| R*v + R*(1-v) | 		A 		| xmm1

			MOVSS XMM10, XMM2				;	|	x	|	x	|	x	|	A	| xmm10
			MULPS XMM2, XMM0				;	| B*value |	G*value	| R*value | A*value	| xmm2
			MULPS XMM6, XMM15				;	| B*(1-value) |	G*(1-value)	| R*(1-value) | A*(1-value)	| xmm6
			ADDPS XMM2, XMM6		;	| B*v + B*(1-v) | G*v + G*(1-v)	| R*v + R*(1-v) | A*v + A*(1-v) | xmm2
			MOVSS XMM2, XMM10		;	| B*v + B*(1-v) | G*v + G*(1-v)	| R*v + R*(1-v) | 		A 		| xmm2

			MOVSS XMM10, XMM3				;	|	x	|	x	|	x	|	A	| xmm10
			MULPS XMM3, XMM0				;	| B*value |	G*value	| R*value | A*value	| xmm3
			MULPS XMM7, XMM15				;	| B*(1-value) |	G*(1-value)	| R*(1-value) | A*(1-value)	| xmm7
			ADDPS XMM3, XMM7		;	| B*v + B*(1-v) | G*v + G*(1-v)	| R*v + R*(1-v) | A*v + A*(1-v) | xmm3
			MOVSS XMM3, XMM10		;	| B*v + B*(1-v) | G*v + G*(1-v)	| R*v + R*(1-v) | 		A 		| xmm3

			MOVSS XMM10, XMM4				;	|	x	|	x	|	x	|	A	| xmm10
			MULPS XMM4, XMM0				;	| B*value |	G*value	| R*value | A*value	| xmm4
			MULPS XMM8, XMM15				;	| B*(1-value) |	G*(1-value)	| R*(1-value) | A*(1-value)	| xmm8
			ADDPS XMM4, XMM8		;	| B*v + B*(1-v) | G*v + G*(1-v)	| R*v + R*(1-v) | A*v + A*(1-v) | xmm4
			MOVSS XMM4, XMM10		;	| B*v + B*(1-v) | G*v + G*(1-v)	| R*v + R*(1-v) | 		A 		| xmm4

			; Conversiones de floats a dword integers

			CVTTPS2DQ XMM1, XMM1
			CVTTPS2DQ XMM2, XMM2
			CVTTPS2DQ XMM3, XMM3
			CVTTPS2DQ XMM4, XMM4

			; Empaquetado

			PACKUSDW XMM1, XMM2					; |    2do    |    1ro    |	 xmm1
			PACKUSDW XMM3, XMM4					; |    4to    |    3ro    |	 xmm3

			PACKUSWB XMM1,XMM3					; | 4to	| 3ro | 2do | 1ro |  xmm1

			; Guardo en memoria

			MOVDQU [RDX + R12], XMM1

			ADD R12, 16			; avanzo a los proximos 4 pixeles
			CMP R12D, EBX 		; me fijo si llegue al final de la fila
			JNE .ciclo_columnas

		LEA RDX, [RDX+R12]		; actualizo el puntero a la matriz 1
		LEA R14, [R14+R12]		; actualizo el puntero a la matriz 2	

		XOR R12, R12			; reinicio el offset
		INC R13
		CMP R13D, ECX
		JNE .ciclo_filas		; repito para la proxima fila
 	
 	pop r14
 	pop r13
 	pop r12
 	pop rbx
	pop rbp
	ret