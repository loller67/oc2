; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Blur 1                                     ;
;                                                                           ;
; ************************************************************************* ;

; void ASM_blur1( uint32_t w, uint32_t h, uint8_t* data )

global ASM_blur1
extern malloc
extern free

section .data
align 16
nueve: DD 9.0,9.0,9.0,9.0

%define pixel_size 4

section .text

ASM_blur1:

	; edi <- ancho en pixeles, esi<-alto en pixeles, rdx<- puntero a la matriz

	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14 
	push r15
	sub rsp, 8
	
	mov rbx, rdx 		; rbx <- puntero a la imagen

	mov r13d, esi 		; r13 <- alto en pixeles
	sub r13, 2 			; r13 <- alto - 2 (donde tengo que parar)

	mov r15d, edi 		; r15 <- ancho en pixeles

	mov rdi, r15 
	shl rdi, 2
	call malloc 		; creo un vector del tamanio de una fila
	mov r12, rax		; r12<- puntero al vector 
	mov r14, r12		; r14<- puntero al vector 

	XOR R8, R8 			; inicializo contador de filas
	XOR R9, R9 			; inicializo contador de columnas 

	; Cargo primera fila de la imagen en el vector:

	.iniciar_vector:
		MOVDQU XMM0, [RBX + R9*4]				; cargo en xmm0 4 pixeles
		MOVDQU [R12 + R9*4], XMM0 			; guardo 4 pixeles en vector
		ADD R9, 4							; avanzo 4 pixeles
		CMP R9, R15							; me fijo si llegue al final de la fila
		JNE .iniciar_vector

	
	XORPD XMM15, XMM15 						; para hacer unpack
	
	MOV RCX, R15
	SUB RCX, 3 								; rcx <- ancho en pixeles - 3

	; Inicio ciclo:

	.ciclo_filas: 

		XOR R9, R9

		; Guardo en eax el primero de la proxima fila, lo uso para modificar el vector auxiliar
		MOV EAX, [RBX + R15*4]		

	 	.ciclo_columnas: 
	 		
	 		MOVDQU XMM0, [RBX]				; cargo pixeles de la primera fila
	 		MOVDQU XMM2, [RBX + R15*4] 		; cargo pixeles de la segunda fila
	 		MOVDQU XMM4, [RBX + R15*8] 		; cargo pixeles de la tercera fila

	 		; Actualizo valor de la imagen
	 		MOV EDI, [R12]
	 		MOV [RBX], EDI

	 		; Guardo el valor calculado en el ciclo anterior
	 		MOV [R12], EAX

	 		MOVDQU XMM1, XMM0
	 		PUNPCKLBW XMM0, XMM15			; 	|	P1	|	P0	| xmm0
	 		PUNPCKHBW XMM1, XMM15			; 	|	X	|	P2	| xmm1

	 		MOVDQU XMM3, XMM2
	 		PUNPCKLBW XMM2, XMM15			; 	|	P4	|	P3	| xmm2
	 		PUNPCKHBW XMM3, XMM15			; 	|	X	|	P5	| xmm3

	 		MOVDQU XMM5, XMM4
	 		PUNPCKLBW XMM4, XMM15			; 	|	P7	|	P6	| xmm4
	 		PUNPCKHBW XMM5, XMM15			; 	|	X	|	P8	| xmm5

	 		PADDW XMM1, XMM0
	 		PADDW XMM1, XMM2
	 		PADDW XMM1, XMM3
	 		PADDW XMM1, XMM4
	 		PADDW XMM1, XMM5				;	|	X 	|P0+P2+P3+P5+P6+P8| xmm1

	 		PSRLDQ XMM0, 8					; 	|	0	|	P1	| xmm0			
	 		PSRLDQ XMM2, 8					; 	|	0	|	P4	| xmm2	
	 		PSRLDQ XMM4, 8					; 	|	0	|	P7	| xmm4	

	 		PADDW XMM0, XMM2
	 		PADDW XMM0, XMM4
	 		PADDW XMM0, XMM1				;	|	X 	|P1+P4+P7 + P0+P2+P3+P5+P6+P8| xmm0

	 		PUNPCKLWD XMM0, XMM15 			;   | R | G | B | A | (con la suma hecha en cada componente)

	 		CVTDQ2PS XMM0, XMM0				; convierto cada componente a un float
	 		DIVPS XMM0, [nueve]				; divido por 9
	 		CVTPS2DQ XMM0, XMM0 			; convierto cada componente a enteros de 32 bits

	 		; Empaquetado
	 		PACKUSDW XMM0, XMM15 			; | 0 | 0 | 0 | 0 | R | G | B | A |	
	 		PACKUSWB XMM0, XMM15 			; 	|	0	|	0	|	0	|	pixel 	|


	 		; Me guardo el resultado en un registro
	 		PEXTRD EAX, XMM0, 0

	 		; Avanzo al siguiente pixel
	 						
	 		LEA RBX, [RBX + 4]
	 		LEA R12, [R12 + 4]
	
			INC R9
			CMP R9, RCX
			JNE .ciclo_columnas

			; Caso Borde 

			SUB RBX, 4 ; para volver a tomar los ultimos 4 pixeles de la fila

	 		MOVDQU XMM0, [RBX]				; cargo pixeles de la primera fila
	 		MOVDQU XMM2, [RBX + R15*4] 		; cargo pixeles de la segunda fila
	 		MOVDQU XMM4, [RBX + R15*8] 		; cargo pixeles de la tercera fila

	 		; Shifteo uno a la derecha para trabajar con los ultimos 3 pixeles de las filas
	 		PSRLDQ XMM0, 4 
	 		PSRLDQ XMM2, 4 
	 		PSRLDQ XMM4, 4 

			; Actualizo valor de la imagen
	 		MOV EDI, [R12]
	 		MOV [RBX + 4], EDI

	 		; Guardo el valor calculado en el ciclo anterior
	 		MOV [R12], EAX

	 		MOVDQU XMM1, XMM0
	 		PUNPCKLBW XMM0, XMM15			; 	|	P1	|	P0	| xmm0
	 		PUNPCKHBW XMM1, XMM15			; 	|	X	|	P2	| xmm1

	 		MOVDQU XMM3, XMM2
	 		PUNPCKLBW XMM2, XMM15			; 	|	P4	|	P3	| xmm2
	 		PUNPCKHBW XMM3, XMM15			; 	|	X	|	P5	| xmm3

	 		MOVDQU XMM5, XMM4
	 		PUNPCKLBW XMM4, XMM15			; 	|	P7	|	P6	| xmm4
	 		PUNPCKHBW XMM5, XMM15			; 	|	X	|	P8	| xmm5

	 		PADDW XMM1, XMM0
	 		PADDW XMM1, XMM2
	 		PADDW XMM1, XMM3
	 		PADDW XMM1, XMM4
	 		PADDW XMM1, XMM5				;	|	X 	|P0+P2+P3+P5+P6+P8| xmm1

	 		PSRLDQ XMM0, 8					; 	|	0	|	P1	| xmm0			
	 		PSRLDQ XMM2, 8					; 	|	0	|	P4	| xmm2	
	 		PSRLDQ XMM4, 8					; 	|	0	|	P7	| xmm4	

	 		PADDW XMM0, XMM2
	 		PADDW XMM0, XMM4
	 		PADDW XMM0, XMM1				;	|	X 	|P1+P4+P7 + P0+P2+P3+P5+P6+P8| xmm0

	 		PUNPCKLWD XMM0, XMM15 			;   | R | G | B | A | (con la suma hecha en cada componente)

	 		CVTDQ2PS XMM0, XMM0				; convierto cada componente a un float
	 		DIVPS XMM0, [nueve]				; divido por 9
	 		CVTPS2DQ XMM0, XMM0 			; convierto cada componente a enteros de 32 bits

	 		; Empaquetado
	 		PACKUSDW XMM0, XMM15 			; | 0 | 0 | 0 | 0 | R | G | B | A |	
	 		PACKUSWB XMM0, XMM15 			; 	|	0	|	0	|	0	|	pixel 	|

	 		; Me guardo el resultado en un registro
	 		PEXTRD EAX, XMM0, 0

	 		; Actualizo anteultimo pixel de la fila
	 		MOV EDI, [R12 + 4]
	 		MOV [RBX + 8], EDI

	 		; Guardo resultado en el vector
	 		MOV [R12 + 4], EAX

 		; Termine la fila
 		
 		LEA RBX, [RBX + 16]
 		MOV R12, R14 			; vuelvo al principio del vector auxiliar
 		INC R8
 		CMP R8, R13 			; me fijo si complete todas las filas (hasta alto-2)
 		JNE .ciclo_filas


 		; Cargo en la imagen la anteultima fila que quedo cargada en el vector
 		XOR R9, R9
 		DEC R15 				; porque el ultimo no tengo que modificarlo

 		.copiar_vector:
 		MOV EDI, [R12 + R9*4]
 		MOV [RBX + R9*4], EDI 		
 		INC R9						; proximo pixel
 		CMP R9, R15
 		JNE .copiar_vector

 		; libero vector auxiliar
		mov rdi, r14
		call free

	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp	

	ret
