extern malloc
extern free
extern strcpy

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - optimizar
global EJERCICIO_2A_HECHO
EJERCICIO_2A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contarCombustibleAsignado
global EJERCICIO_2B_HECHO
EJERCICIO_2B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1C como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - modificarUnidad
global EJERCICIO_2C_HECHO
EJERCICIO_2C_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ATTACKUNIT_CLASE EQU 0
ATTACKUNIT_COMBUSTIBLE EQU 12
ATTACKUNIT_REFERENCES EQU 14
ATTACKUNIT_SIZE EQU 16

global optimizar
optimizar:
	; rdi = mapa_t           mapa
	; rsi = attackunit_t*    compartida
	; rdx = uint32_t*        fun_hash(attackunit_t*)
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp, 24

	
	mov r12, rdi 		; mapa
	mov r13, rsi		; compartida
	mov r14, rdx		; fun_hash

	xor rbx, rbx

.for_i:
	cmp rbx, 255
	je .fin
	xor r15, r15   		; indice j
.for_j:
	cmp r15, 255
	je .fin_fila

	mov rax, rbx
	imul rax, 255      		; i*255
	add rax, r15        	; i*255 + j
	mov r8, [r12 + rax*8] 	; mapa[i][j]

	mov [rsp], r8  			; guardo actual
	cmp r8, 0				; chekeo guarda null
	je .siguiente

	mov rdi, r8
	call r14
	mov DWORD [rsp + 8], eax
	mov rdi, r13
	call r14

	mov r9d, [rsp + 8]
	cmp r9d, eax
	je .optimizar
	jmp .siguiente

.optimizar:
    ; saltar si actual == compartida
    mov rdi, [rsp]          ; rdi = actual
    cmp rdi, r13
    je .siguiente           ; no optimizo si es la misma instancia

    inc BYTE [r13 + ATTACKUNIT_REFERENCES]   ; compartida->references++
    dec BYTE [rdi + ATTACKUNIT_REFERENCES]   ; actual->references--

    ; chequear si actual->references == 0
    movzx r10d, BYTE [rdi + ATTACKUNIT_REFERENCES]
    test r10d, r10d
    jne .skip_free
    call free               ; liberar actual si quedó sin referencias
.skip_free:

    ; actualizar el mapa[i][j] = compartida
    mov rax, rbx
    imul rax, 255
    add rax, r15
    mov [r12 + rax*8], r13
    jmp .siguiente

.siguiente:
	inc r15
	jmp .for_j

.fin_fila:
	inc rbx
	jmp .for_i

.fin:
	add rsp, 24
    pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

global contarCombustibleAsignado
contarCombustibleAsignado:
	; rdi = mapa_t           mapa
	; rsi = uint16_t*        fun_combustible(char*)
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp, 8

	mov r12, rdi
	mov r13, rsi

	xor ebx, ebx
	xor r14, r14

.for_i:
	cmp r14, 255
	je .fin
	xor r15, r15

.for_j:
	cmp r15, 255
	je .fin_fila

	mov rax, r14
	imul rax, 255
	add rax, r15
	mov r8, [r12 + rax*8]
	cmp r8, 0
	je .siguiente

	mov r9w, WORD [r8 + ATTACKUNIT_COMBUSTIBLE]
	mov WORD [rsp], r9w

	lea rdi, [r8 + ATTACKUNIT_CLASE]

	call r13

	mov r9w, WORD [rsp]
	cmp r9w, ax
	jge .actualizar
	jmp .siguiente

.siguiente:
	inc r15
	jmp .for_j

.actualizar:
	sub r9w, ax
	movzx r9d, r9w
	add ebx, r9d
	jmp .siguiente

.fin_fila:
	inc r14
	jmp .for_i

.fin:
	mov eax, ebx
	add rsp, 8
	pop rbx
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret

global modificarUnidad
modificarUnidad:
	; rdi = mapa_t          mapa
	; sil  = uint8_t        x
	; dl  = uint8_t         y
	; rcx = void*           fun_modificar(attackunit_t*)

	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push rbx
	sub rsp, 16

	mov BYTE [rsp], sil
	mov BYTE [rsp + 8], dl

	mov r12, rdi
	mov r13, rcx
	
	movzx rax, sil
	imul rax, 255
	movzx r9, dl
	add rax, r9
	mov rbx, [r12 + rax*8]     ; actual

	cmp rbx, 0
	je .fin
	movzx r8, BYTE [rbx + ATTACKUNIT_REFERENCES]
	cmp r8, 1
	je .unico

	mov rdi, ATTACKUNIT_SIZE
	call malloc
	mov r14, rax

	lea rdi, [r14 + ATTACKUNIT_CLASE]
	lea rsi, [rbx + ATTACKUNIT_CLASE]
	call strcpy

	mov r8w, WORD [rbx + ATTACKUNIT_COMBUSTIBLE]
	mov [r14 + ATTACKUNIT_COMBUSTIBLE], r8w

	mov BYTE [r14 + ATTACKUNIT_REFERENCES], 1
	dec BYTE [rbx + ATTACKUNIT_REFERENCES]

	mov rdi, r14
	call r13

	mov sil, BYTE [rsp]
	mov dl, BYTE [rsp + 8]

	movzx rax, sil
	imul rax, 255
	movzx r9, dl
	add rax, r9
	mov [r12 + rax*8], r14    ; actual
	jmp .fin

.unico:
	mov rdi, rbx
	call r13
	jmp .fin

.fin:
	add rsp, 16
	pop rbx
	pop r14
	pop r13
	pop r12
	pop rbp
	ret