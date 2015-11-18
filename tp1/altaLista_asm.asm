
; ESTUDIANTE
	global estudianteCrear
	global estudianteBorrar
	global menorEstudiante
	global estudianteConFormato
	global estudianteImprimir
	
; ALTALISTA y NODO
	global nodoCrear
	global nodoBorrar
	global altaListaCrear
	global altaListaBorrar
	global altaListaImprimir

; AVANZADAS
	global edadMedia
	global insertarOrdenado
	global filtrarAltaLista

; YA IMPLEMENTADAS EN C
	extern string_iguales
	extern insertarAtras
	extern malloc
	extern free
	extern printf
	extern fopen
	extern fclose
	extern fprintf
;AUXILIARES
	global string_longitud
	global string_copiar
	global string_menor

; /** DEFINES **/    >> SE RECOMIENDA COMPLETAR LOS DEFINES CON LOS VALORES CORRECTOS
	%define NULL 	0
	%define TRUE 	1
	%define FALSE 	0

	%define ALTALISTA_SIZE     		16
	%define OFFSET_PRIMERO 			0
	%define OFFSET_ULTIMO  			8

	%define NODO_SIZE     			24
	%define OFFSET_SIGUIENTE   		0
	%define OFFSET_ANTERIOR   		8
	%define OFFSET_DATO 			16

	%define ESTUDIANTE_SIZE  		20
	%define OFFSET_NOMBRE 			0
	%define OFFSET_GRUPO  			8
	%define OFFSET_EDAD 			16


section .rodata


section .data

msg: db "%s",10,9,"%s",10,9,"%d",10,0
abrir: db "a",0
vacia: db '<vacia>',10,0

section .text

;/** FUNCIONES OBLIGATORIAS DE ESTUDIANTE **/    >> PUEDEN CREAR LAS FUNCIONES AUXILIARES QUE CREAN CONVENIENTES
;---------------------------------------------------------------------------------------------------------------

	; estudiante *estudianteCrear( char *nombre, char *grupo, unsigned int edad );
	estudianteCrear:
	; rdi <- nombre rsi <- grupo edx <- edad
		; COMPLETAR AQUI EL CODIGO

		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14
		push r15
		sub rsp, 8

		mov r12,rdi
		mov r13,rsi
		mov edx,edx
		xor r14,r14
		mov r14d,edx
		call string_copiar; copio el nombre
		mov r15,rax; guardo el puntero del nombre que copie
		mov rdi, r13; guardo el puntero del grupo que me pasan
		call string_copiar; copio el grupo
		mov rbx,rax; guardo el puntero al grupo que copie
		mov rdi, ESTUDIANTE_SIZE
		call malloc; pido memoria
		
		mov  [rax+ OFFSET_NOMBRE],r15; le paso a nombre el puntero al nombre que copie
		mov  [rax+ OFFSET_GRUPO], rbx;le paso a grupo el puntero del grupo que copie
		mov  [rax+OFFSET_EDAD],r14d; le paso a edad, la edad que me pasaron por parametro
		
		add rsp, 8
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret


	; void estudianteBorrar( estudiante *e );
	estudianteBorrar:
		; rdi <- puntero a la struct
		; COMPLETAR AQUI EL CODIGO
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14
		push r15
		sub rsp, 8

		
		mov r12, [rdi + OFFSET_GRUPO]; guardo puntero del grupo
		mov r13, rdi; guardo puntero struct
		mov rdi,r12
		call free; borro el grupo
		mov rdi, [r13 +OFFSET_NOMBRE]
		call free; borro el nombre
		mov rdi,r13; 
		call free;borro struct
		
		add rsp, 8
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret

	; bool menorEstudiante( estudiante *e1, estudiante *e2 ){
	menorEstudiante:
		; rdi<- e1, rsi <-e2
		; COMPLETAR AQUI EL CODIGO
		; si los nombres son distintos va bien, si son iguales compara las edades al reves
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14
		push r15
		sub rsp, 8

		mov r12, rdi; salvo e1
		mov r13, rsi; salvo e2
		mov rdi, [r12+OFFSET_NOMBRE]; me fijo si son iguales
		mov rsi, [r13+OFFSET_NOMBRE]
		call string_iguales
		cmp qword rax, TRUE; si nombre(e1) = nombre(e2)
		je .chequearedad
		mov rdi, [r12+OFFSET_NOMBRE]; me fijo si hay uno menor que otro
		mov rsi, [r13+OFFSET_NOMBRE]
		call string_menor
		cmp qword rax, TRUE
		je .True
		jmp .False

		.chequearedad:
				mov r14d, [r12+OFFSET_EDAD]
				cmp r14d,[r13+OFFSET_EDAD]
				jle .True
				jmp .False
	
		

		.False:
		
				mov rax, FALSE; else false
				jmp .pop
		
		.True:
				mov rax, TRUE
				

					
		.pop:
		add rsp, 8
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret
	; void estudianteConFormato( estudiante *e, tipoFuncionModificarString f )
	estudianteConFormato:
		; COMPLETAR AQUI EL CODIGO
		; rdi<- puntero est, rsi<- f
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14
		push r15
		sub rsp, 8

		mov r12, rdi
		mov r13, rsi
		mov rdi, [r12+ OFFSET_NOMBRE]
		call rsi
		mov rdi, [r12+ OFFSET_GRUPO]
		mov rsi, r13
		call rsi
		
		add rsp, 8
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret


	; void estudianteImprimir( estudiante *e, FILE *file )
	estudianteImprimir:
		; COMPLETAR AQUI EL CODIGO
		; rdi<- puntero a la struct, rsi<- puntero a file
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14
		push r15
		sub rsp, 8
		
		mov r12, rsi;guardo parametros que me pasan
		mov r13, rdi
		mov rdi, rsi; guardo file
		xor rsi, rsi; seteo en 0 rsi
		mov rsi, msg; paso msg por rsi
		mov rdx, [r13+ OFFSET_NOMBRE]; paso nombre a rdx
		mov rcx, [r13 +OFFSET_GRUPO]; paso grupo a rcx
		mov r8d, [r13 +OFFSET_EDAD]; paso edad a r8
		call fprintf; llamo fprintf

		add rsp, 8
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret

;/** FUNCIONES DE ALTALISTA Y NODO **/    >> PUEDEN CREAR LAS FUNCIONES AUXILIARES QUE CREAN CONVENIENTES
;--------------------------------------------------------------------------------------------------------

	; nodo *nodoCrear( void *dato )
	nodoCrear:
		; COMPLETAR AQUI EL CODIGO
		;rdi<- *dato
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14
		push r15
		sub rsp, 8

		mov r13,rdi
		mov rdi, NODO_SIZE
		call malloc
		mov qword [rax+ OFFSET_SIGUIENTE], NULL
		mov qword [rax+ OFFSET_ANTERIOR], NULL
		mov [rax+ OFFSET_DATO], r13	

		add rsp, 8
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret
	; void nodoBorrar( nodo *n, tipoFuncionBorrarDato f )
	nodoBorrar:
		; COMPLETAR AQUI EL CODIGO
		; rdi<- puntero al nodo, rsi<-puntero a la funcion 
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14
		push r15
		sub rsp, 8

		mov r12,rdi
		mov qword [rdi + OFFSET_SIGUIENTE], NULL
		mov qword [rdi+ OFFSET_ANTERIOR], NULL
		mov qword rdi, [r12+ OFFSET_DATO]
		call rsi	
		mov rdi, r12
		call free
		
		add rsp, 8
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret


; altaLista *altaListaCrear( void )
	altaListaCrear:
		; COMPLETAR AQUI EL CODIGO
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14
		push r15
		sub rsp, 8
		
		mov rdi, ALTALISTA_SIZE
		call malloc
		mov qword [rax + OFFSET_PRIMERO], NULL
		mov qword [rax + OFFSET_ULTIMO], NULL

		add rsp, 8
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret

	; void altaListaBorrar( altaLista *l, tipoFuncionBorrarDato f )
	altaListaBorrar:
		; COMPLETAR AQUI EL CODIGO
		;rdi<- puntero a struct, rsi<- funcion que borra el dato
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14
		push r15
		sub rsp, 8
			
		mov r13,rdi; guardo la lista
		mov r14,rsi; guardo funcion
		cmp qword [rdi+ OFFSET_PRIMERO], NULL; me fijo si la lista es vacia
		je .borrarvacia
		mov r12, [rdi+ OFFSET_ULTIMO] ; guardo ultimo nodo en r12
		
		.chequear:
				cmp qword [r12+ OFFSET_ANTERIOR], NULL; me fijo si solo hay un elemento
				jne .noesultimo
				mov rdi, r12; me guardo el nodo
				mov rsi, r14; guardo funcion 
				call nodoBorrar
				mov rdi, r13
				mov rsi, r14
				call free
				jmp .pops
				
		.noesultimo:
				mov r15, [r12+ OFFSET_ANTERIOR]; salvo nodo anterior
				mov rdi, r12; borro ultimo nodo
				mov rsi,r14
				call nodoBorrar
				mov [r13+ OFFSET_ULTIMO], r15
				mov r12,r15
				jmp .chequear

		.borrarvacia:
			mov rdi, r13
			call free
						
		

		.pops:
		add rsp, 8
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret
		
	; void altaListaImprimir( altaLista *l, char *archivo, tipoFuncionImprimirDato f )
	altaListaImprimir:
		; COMPLETAR AQUI EL CODIGO
		; rdi<- lista, rsi<- archivo, rdx<- funcion
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14
		push r15
		sub rsp, 8

		mov r12, rsi
		mov r13, rdx
		mov r14, [rdi+ OFFSET_PRIMERO]
		mov rdi, r12
		mov rsi, abrir
		call fopen
		mov r12,rax
		cmp qword r14, NULL
		je .listavacia
		
		.ciclo:
			cmp qword r14, NULL; me fijo si es null
			je .pops
			mov rdi, [r14+ OFFSET_DATO]; guardo dato
			mov rsi, r12; guardo file
			call r13; llamo a lo que me pasan por parametro
			mov r14, [r14+ OFFSET_SIGUIENTE]; avanzo
			jmp .ciclo
		

		.listavacia:
				mov rdi, r12
				mov rsi, vacia; paso vacia por rsi
				call fprintf; llamo fprintf
				
						
		
		.pops:
			mov rdi,r12; paso el file para hacer close
			call fclose
			add rsp, 8
			pop r15
			pop r14
			pop r13
			pop r12
			pop rbx
			pop rbp
			ret

;/** FUNCIONES AVANZADAS **/    >> PUEDEN CREAR LAS FUNCIONES AUXILIARES QUE CREAN CONVENIENTES
;----------------------------------------------------------------------------------------------
; float edadMedia( altaLista *l )
	edadMedia:
		; COMPLETAR AQUI EL CODIGO
		; rdi<-puntero a lista
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14
		push r15
		sub rsp, 8

		cmp  qword [rdi+ OFFSET_PRIMERO], NULL; si la lista esta vacia, devuelvo 0
		je .cero
		mov r12, [rdi+ OFFSET_PRIMERO]; guardo el primer nodo
		xor r14,r14
		xor r15,r15
		

		.ciclo:
			mov r13, [r12 + OFFSET_DATO]; me guardo el nodo
			add r15d, [r13+ OFFSET_EDAD]; sumo edad
			inc r14d
			cmp qword [r12 + OFFSET_SIGUIENTE], NULL
			je .fin
			mov rbx, [r12+ OFFSET_SIGUIENTE]
			mov r12,rbx
			jmp .ciclo
		
		.fin:
			
			xorps xmm0, xmm0
			xorps xmm1, xmm1
			cvtsi2ss xmm0, r15d
			cvtsi2ss xmm1, r14d
			divss xmm0, xmm1
			jmp .pops		
		
		.cero:
			xorps  xmm0, xmm0
			
	
		.pops:
		add rsp, 8
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret
		 
	; void insertarOrdenado( altaLista *l, void *dato, tipoFuncionCompararDato f )
	insertarOrdenado:
		; COMPLETAR AQUI EL CODIGO
		; rdi<- lista, rsi<- dato, rdx<- funcion
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14
		push r15
		sub rsp, 8

		mov r12,rdi; salvo parametros
		mov r13,rsi
		mov r14, rdx
		mov r15, [r12+OFFSET_PRIMERO]
		cmp qword r15, NULL; me fijo si es vacia la lista
		je .insertarvacia
		jmp .noesvacia

		.noesvacia:; aca contemplo los casos si hay queinsertar al principio o al final
				mov rdi, r13
				mov rsi, [r15+OFFSET_DATO]
				call r14
		          	cmp qword rax, TRUE
                		je .insertaradelanteunnodo
              			mov rdi, r13;; se que no va adelante, me fijo si lo tengo que mandar al final
                		mov r15, [r12+OFFSET_ULTIMO]; cuidado aca pierdo mi primer nodo
				mov rsi, [r15+OFFSET_DATO]
				call r14
				cmp qword rax, FALSE; si da false ya inserto en el fondo, si no tengo que loopear entre los nodos del medio
				je .insertaratrasunnodo
                		mov r15, [r12+OFFSET_PRIMERO]; recupero mi primer nodo para poder loopear en los del medio
 				mov rbx, [r15+OFFSET_SIGUIENTE]
  				jmp .insertarconnnodos

		.insertarvacia:; funciona
				mov rdi, r13
				call nodoCrear
				mov [r12+OFFSET_PRIMERO],rax; pongo primero y ultimo en null 
				mov [r12+OFFSET_ULTIMO],rax		
				jmp .pops

		.insertarconunnodo:;funciona 
				mov rdi, r13
				mov rsi, [r15+OFFSET_DATO]
				call r14 ; llamo a f
				cmp qword rax, TRUE
				je .insertaradelanteunnodo
				jmp .insertaratrasunnodo
	

		.insertaradelanteunnodo:;funciona 
					mov rdi, r13
					call nodoCrear
					mov [rax+ OFFSET_SIGUIENTE], r15
					mov [r12+ OFFSET_PRIMERO], rax
					mov [r15+OFFSET_ANTERIOR], rax
					jmp .pops



		.insertaratrasunnodo:; funciona
					mov rdi, r13
					call nodoCrear
					mov [rax+OFFSET_ANTERIOR],r15
					mov [r12+OFFSET_ULTIMO], rax
					mov [r15+OFFSET_SIGUIENTE], rax
					jmp .pops

			
                      
		.insertarconnnodos:; aca recorro hasta encontrar el nodo del medio 
					mov rdi, r13
					mov rsi, [rbx+OFFSET_DATO]
					call r14;
					cmp qword rax,TRUE
					je .insertarnnodos
					mov r15, rbx
					mov rbx, [rbx+OFFSET_SIGUIENTE]
					jmp .insertarconnnodos


			

		 .insertarnnodos:; aca hago la insercion del nodo del medio
					mov rdi, r13
					call nodoCrear
					mov [rax+ OFFSET_ANTERIOR], r15
					mov [rax+ OFFSET_SIGUIENTE], rbx
					mov [r15+OFFSET_SIGUIENTE], rax
					mov [rbx+ OFFSET_ANTERIOR],rax
					
					
			
                      
                    				
					

		.pops:
		add rsp, 8
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret

	

; void filtrarAltaLista( altaLista *l, tipoFuncionCompararDato f, void *datoCmp )
		filtrarAltaLista:
		; COMPLETAR AQUI EL CODIGO
		; rdi< lista , rsi<- funcion , rdx <- datocmp
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14
		push r15
		sub rsp, 8
		
		mov r12, rdi; salvo mis parametros en registros
		mov r13,rsi
		mov r14, rdx
		mov r15, [r12+OFFSET_PRIMERO]; me guardo el primer nodo
		cmp r15,NULL
		je .casobase
		mov rbx, [r15+ OFFSET_SIGUIENTE]; me guardo el nodo siguiente a mi actual
		jmp .casobase

		.casobase:	
				cmp qword r15, NULL; me fijo si llegue al final o la lista esta vacia
				je .pops
				mov rdi, [r15+OFFSET_DATO]; guardo dato del nodo
				mov rsi, r14; cargo datocmp
				call r13
				cmp qword rax, TRUE; me fijo si da true, no hago nada
				je .avanzarr15
				cmp qword [r15+OFFSET_ANTERIOR], NULL; me fijo si estoy en el primernodo
				je .esprimero
				cmp qword [r15+OFFSET_SIGUIENTE], NULL; me fijo si estoy en el ultimo nodo y hay mas de un nodo
				je .borrarultimo
				jmp .borrarintermedio; si no estoy en el primero
				


		.esprimero:
				cmp qword [r15+OFFSET_SIGUIENTE], NULL; me fijo si me queda un solo nodo 
				je .hayunnodo
				jmp .borrarprimero


	
		
		.hayunnodo:; funciona
				
				mov rdi, r15
				mov rsi, estudianteBorrar
				call nodoBorrar
				mov qword [r12+ OFFSET_PRIMERO], NULL
				mov qword [r12+ OFFSET_ULTIMO], NULL
				jmp .pops
		
		.haynnodos:
				mov rdi, [r15+OFFSET_DATO]
				mov rsi, r14
				call r13
				cmp qword rax, TRUE; si da true tengo que avanzar
				je .avanzar
				cmp qword [r15+OFFSET_ANTERIOR], NULL; me fijo si estoy parado en el primer nodo
				je .borrarprimero
				cmp qword [r15+OFFSET_SIGUIENTE], NULL; no estoy en el primero y  me fijo si estoy parado en el ultimo nodo
				je .borrarultimo
				jmp .borrarintermedio

		.borrarprimero:
				mov rbx, [r15+OFFSET_SIGUIENTE]
				cmp qword rbx, NULL; si el anterior es null y el siguiente de mi actual son null, estoy en caso que queda un nodo
				je .hayunnodo
				mov [r12+ OFFSET_PRIMERO], rbx; actualizo primero
				mov qword [rbx+ OFFSET_ANTERIOR], NULL; pongo el anterior del siguiente a eliminar como null
				mov qword [r15+OFFSET_SIGUIENTE], NULL
				mov rdi, r15
				mov rsi, estudianteBorrar
				call nodoBorrar
				mov r15, rbx
				mov rbx, [rbx+OFFSET_SIGUIENTE]
				jmp .avanzar; como no llegue al final sigo avanzando

		.borrarultimo:
				cmp qword [r15+ OFFSET_ANTERIOR], NULL; me fijo si mi anterior es null
				je .hayunnodo
				mov rbx, [r15+OFFSET_ANTERIOR]
				mov qword [r12+OFFSET_ULTIMO], rbx; pongo como ultimo el anterior del que tengo que borrar
				mov qword [rbx+OFFSET_SIGUIENTE], NULL
				mov rdi, r15
				mov rsi, estudianteBorrar
				call nodoBorrar
				jmp .pops

		.borrarintermedio:
				mov rdi,r15; salvo r15
				mov rbx, [r15+OFFSET_ANTERIOR]
				mov r15, [r15+OFFSET_SIGUIENTE]; avanzo r15
				mov [rbx+ OFFSET_SIGUIENTE], r15
				mov [r15+OFFSET_ANTERIOR], rbx
				mov rsi, estudianteBorrar
				call nodoBorrar
				mov rbx, [r15+OFFSET_SIGUIENTE]; vuelvo a poner rbx como siguiente de r15 (mi actual)
				jmp .avanzar
		
		.avanzarr15:
				mov r15, [r15+OFFSET_SIGUIENTE]
				jmp .casobase		
		.avanzar:
				cmp qword r15, NULL
				je .pops
				mov rbx, [r15+OFFSET_SIGUIENTE]
				cmp qword rbx, NULL
				je .casobase
				mov rbx, r15
				mov rbx, [rbx+OFFSET_SIGUIENTE]
				jmp .casobase
				
				
		.pops:
		add rsp, 8
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret

			
;AUXILIARES
	;unsigned char string_longitud( char *s );
	; COMPLETAR AQUI EL CODIGO
		string_longitud:
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14
		push r15
		sub rsp, 8

				
		
		xor rax,rax; seteo contador en 0
		
		
		.ciclo: 
			cmp byte [rdi], NULL
			je .fin
			inc rdi	
			inc rax
			jmp .ciclo

		
		.fin:		
		add rsp, 8
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret
;char *string_copiar( char *s );
	;s<-rdi
	string_copiar:
	; COMPLETAR AQUI EL CODIGO
		
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14
		push r15
		sub rsp, 8
		
		xor r12,r12
		mov r13, rdi
		call string_longitud
		mov rdi, rax
		inc rdi
		call malloc; en rax tengo el puntero a la primera posicion de memoria
		mov r14,rax
			
		.ciclo:
		mov r15b, [r13+r12]; empiezo a moverme dentro del string
		mov byte [r14+r12], r15b; lo copio en rax
		cmp r15b, NULL
		je .fin
		inc r12
		jmp .ciclo		
		
		.fin:
		mov rax, r14
		
		add rsp, 8
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret


;bool string_menor( char *s1, char *s2 );
	; s1<- rdi s2<- rsi
	; COMPLETAR AQUI EL CODIGO
		string_menor:
		push rbp
		mov rbp, rsp
		push rbx
		push r12
		push r13
		push r14
		push r15
		sub rsp, 8

		mov r12, rdi; salvo puntero a la primer letra primer palabra
		mov r13, rsi; salvo puntero a la primer letra segunda palabra
		call string_iguales; me fijo si son iguales
		cmp  rax, TRUE; si son iguales devuelvo false
		je .False
		
		.loop:
			cmp byte [r12], NULL; primer palabra NULL
			je .True
			cmp byte [r13], NULL ; segunda palabra NULL y primer palabra NO NULL
			je .False
			mov  al, [r12]
			mov  bl, [r13]
			cmp byte al, bl; las dos distintas de NULL
			je .incrementar
			jl .True
			jmp .False

		
		.incrementar:
			inc r12
			inc r13
			jmp .loop
		.False:
			mov rax, FALSE
			jmp .pop
			
		.True:
			mov rax, TRUE
			

		.pop:
		add rsp, 8
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbx
		pop rbp
		ret
