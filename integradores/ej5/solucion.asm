; Definiciones comunes
TRUE  EQU 1
FALSE EQU 0

; Identificador del jugador rojo
JUGADOR_ROJO EQU 1
; Identificador del jugador azul
JUGADOR_AZUL EQU 2

; Ancho y alto del tablero de juego
tablero.ANCHO EQU 10
tablero.ALTO  EQU 5

; Marca un OFFSET o SIZE como no completado
; Esto no lo chequea el ABI enforcer, sirve para saber a simple vista qué cosas
; quedaron sin completar :)
NO_COMPLETADO EQU -1

extern strcmp

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
carta.en_juego EQU 0
carta.nombre   EQU 1
carta.vida     EQU 14
carta.jugador  EQU 16
carta.SIZE     EQU 18

tablero.mano_jugador_rojo EQU 0
tablero.mano_jugador_azul EQU 8
tablero.campo             EQU 16
tablero.SIZE              EQU 416

accion.invocar   EQU 0
accion.destino   EQU 8
accion.siguiente EQU 16
accion.SIZE      EQU 24

; Variables globales de sólo lectura
section .rodata

; Marca el ejercicio 1 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - hay_accion_que_toque
global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db TRUE

; Marca el ejercicio 2 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - invocar_acciones
global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db TRUE

; Marca el ejercicio 3 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contar_cartas
global EJERCICIO_3_HECHO
EJERCICIO_3_HECHO: db TRUE

section .text

; Dada una secuencia de acciones determinar si hay alguna cuya carta tenga un
; nombre idéntico (mismos contenidos, no mismo puntero) al pasado por
; parámetro.
;
; El resultado es un valor booleano, la representación de los booleanos de C es
; la siguiente:
;   - El valor `0` es `false`
;   - Cualquier otro valor es `true`
;
; ```c
; bool hay_accion_que_toque(accion_t* accion, char* nombre);
; ```
global hay_accion_que_toque
hay_accion_que_toque:
	; rdi = accion_t*  accion
	; rsi = char*      nombre
	push rbp
	mov rbp, rsp
	push r12		
	push r13
	push r15
	sub rsp, 8

	mov r15, 0		; res = false
	mov r12, rdi    ; accion
	mov r13, rsi    ; nombre

.while:
	cmp r12, 0
	je .fin
	mov r8, [r12 + accion.destino]    ; dest
	lea rdi, [r8 + carta.nombre]
	mov rsi, r13

	call strcmp

	cmp rax, 0                         ; break
	je .found
	mov r12, [r12 + accion.siguiente]
	jmp .while

.found:
	inc r15
	jmp .fin

.fin:
	mov rax, r15
	add rsp, 8
	pop r15
	pop r13
	pop r12
	pop rbp
	ret


; Invoca las acciones que fueron encoladas en la secuencia proporcionada en el
; primer parámetro.
;
; A la hora de procesar una acción esta sólo se invoca si la carta destino
; sigue en juego.
;
; Luego de invocar una acción, si la carta destino tiene cero puntos de vida,
; se debe marcar ésta como fuera de juego.
;
; Las funciones que implementan acciones de juego tienen la siguiente firma:
; ```c
; void mi_accion(tablero_t* tablero, carta_t* carta);
; ```
; - El tablero a utilizar es el pasado como parámetro
; - La carta a utilizar es la carta destino de la acción (`accion->destino`)
;
; Las acciones se deben invocar en el orden natural de la secuencia (primero la
; primera acción, segundo la segunda acción, etc). Las acciones asumen este
; orden de ejecución.
;
; ```c
; void invocar_acciones(accion_t* accion, tablero_t* tablero);
; ```
global invocar_acciones
invocar_acciones:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; rdi = accion_t*  accion
	; rsi = tablero_t* tablero
	push rbp
	mov rbp, rsp

	push r12 
	push r13
	push r14
	sub rsp, 8

	mov r12, rdi        ; accion
	mov r13, rsi        ; tablero

.while:
	cmp r12, 0
	je .fin
	mov r14, [r12 + accion.destino]
	mov r8b, [r14 + carta.en_juego]
	cmp r8b, 0
	je .siguiente
	mov r8, [r12 + accion.invocar]
	mov rdi, r13
	mov rsi, r14
	call r8
	mov r8w, [r14 + carta.vida]
	cmp r8w, 0
	je .sin_vida
	mov r12, [r12 + accion.siguiente]
	jmp .while

.sin_vida:
	mov BYTE [r14 + carta.en_juego], 0
	mov r12, [r12 + accion.siguiente]
	jmp .while

.siguiente:
	mov r12, [r12 + accion.siguiente]
	jmp .while

.fin:
	mov rsi, r13
	add rsp, 8
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

; Cuenta la cantidad de cartas rojas y azules en el tablero.
;
; Dado un tablero revisa el campo de juego y cuenta la cantidad de cartas
; correspondientes al jugador rojo y al jugador azul. Este conteo incluye tanto
; a las cartas en juego cómo a las fuera de juego (siempre que estén visibles
; en el campo).
;
; Se debe considerar el caso de que el campo contenga cartas que no pertenecen
; a ninguno de los dos jugadores.
;
; Las posiciones libres del campo tienen punteros nulos en lugar de apuntar a
; una carta.
;
; El resultado debe ser escrito en las posiciones de memoria proporcionadas
; como parámetro.
;
; ```c
; void contar_cartas(tablero_t* tablero, uint32_t* cant_rojas, uint32_t* cant_azules);
; ```
global contar_cartas
; contar_cartas:
; rdi = tablero_t* tablero
; rsi = uint32_t* cant_rojas
; rdx = uint32_t* cant_azules

contar_cartas:

    push rbp
    mov rbp, rsp
    push r12        ; jugador azul
    push r13        ; jugador rojo

	mov dword [rsi], 0
	mov dword [rdx], 0

	xor r8, r8      ; indice i
	xor r9, r9		; indice j

	mov rcx, [rdi + tablero.mano_jugador_azul]
	mov r12b, [rcx + carta.jugador]

	mov rcx, [rdi + tablero.mano_jugador_rojo]
	mov r13b, [rcx + carta.jugador]

.for_i:
	cmp r8, tablero.ALTO
	je .fin
	xor r9, r9

.for_j:
	cmp r9, tablero.ANCHO
	je .fin_fila

	lea  rcx, [rdi + tablero.campo]    
	
	mov  rax, r8
	imul rax, tablero.ANCHO*8          
	mov  r10, r9
	imul r10, 8                        
	add  rax, r10                      

	mov r10, [rcx + rax] 
	cmp r10, 0
	je .next_posicion
	jmp .if_posicion

.next_posicion:
	inc r9
	jmp .for_j

.if_posicion:
	mov r11b, [r10 + carta.en_juego]
	cmp r11b, 0
	jne .if_en_juego
	jmp .next_posicion

.if_en_juego:
	mov r11b , [r10 + carta.jugador]
	cmp r11b, r12b
	je .es_azul
	cmp r11b, r13b
	je .es_rojo
	jmp .next_posicion

.es_azul:
	add dword [rdx], 1
	jmp .next_posicion

.es_rojo:
	add dword [rsi], 1
	jmp .next_posicion


.fin_fila:
	inc r8
	jmp .for_i

.fin:
	pop r13
	pop r12
	pop rbp
	ret




    

    

