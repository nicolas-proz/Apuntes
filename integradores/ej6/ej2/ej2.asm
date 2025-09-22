extern free

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
TUIT_MENSAJE_OFFSET EQU 0
TUIT_FAVORITOS_OFFSET EQU 140
TUIT_RETUITS_OFFSET EQU 142
TUIT_ID_AUTOR_OFFSET EQU 144
TUIT_SIZE EQU 148

PUBLICACION_NEXT_OFFSET EQU 0
PUBLICACION_VALUE_OFFSET EQU 8
PUBLICACION_SIZE EQU 16

FEED_FIRST_OFFSET EQU 0 
FEED_SIZE EQU 8

USUARIO_FEED_OFFSET EQU 0;
USUARIO_SEGUIDORES_OFFSET EQU 8; 
USUARIO_CANT_SEGUIDORES_OFFSET EQU 16; 
USUARIO_SEGUIDOS_OFFSET EQU 24; 
USUARIO_CANT_SEGUIDOS_OFFSET EQU 32; 
USUARIO_BLOQUEADOS_OFFSET EQU 40; 
USUARIO_CANT_BLOQUEADOS_OFFSET EQU 48; 
USUARIO_ID_OFFSET EQU 52; 
USUARIO_SIZE EQU 56

; void bloquearUsuario(usuario_t *usuario, usuario_t *usuarioABloquear);
global bloquearUsuario 
global borrar
borrar:
    ;rdi = feed
    ;rsi = usuario a bloq
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp, 8

    
    mov r12, rdi                                    ; feed
    mov r14d, DWORD [rsi + USUARIO_ID_OFFSET]       ; id a bloquear
    mov r15, QWORD [r12 + FEED_FIRST_OFFSET]              ; actual
    xor rbx, rbx                                    ; anterior

.while:
    cmp r15, 0                                      ; while actual
    je .fin
    mov rdi, QWORD [r15 + PUBLICACION_VALUE_OFFSET]       ; actual->value
    mov r8d, DWORD [rdi + TUIT_ID_AUTOR_OFFSET]         ; tweet->id_autor
    cmp r8d, r14d                                       ; tweet->id_autor == id_a_bloq?
    jne .siguiente
    cmp rbx, 0                                           ; anterior == NULL?
    je .borrar_first

    mov rdi, r15                                             ; rdi: temp = actual
    mov rsi, QWORD [r15 + PUBLICACION_NEXT_OFFSET]          ; rsi = actual->next
    mov QWORD [rbx + PUBLICACION_NEXT_OFFSET], rsi            ; anterior->next = actual->next
    mov r15, rsi                                        ;    actual = actual->next
    call free                                           ; free(tmp)
    jmp .while


.borrar_first:
    mov rdi, r15                                    ; rdi: tmp = actual
    mov rsi, QWORD [r15 + PUBLICACION_NEXT_OFFSET]        ; rsi = actual->next
    mov QWORD [r12 + FEED_FIRST_OFFSET], rsi              ; feed->first = actual->next
    mov r15, rsi                                    ; actual = actual->next
    call free                                       ; free(tmp)
    jmp .while

.siguiente:
    mov rbx, r15                                    ; anterior = actual
    mov r11, QWORD [r15 + PUBLICACION_NEXT_OFFSET]        ; actual = actual->next
    mov r15, r11
    jmp .while

.fin:
    add rsp, 8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


bloquearUsuario:
    push rbp
    mov rbp, rsp
    push r12
    push r13

    mov r12, rdi
    mov r13, rsi

    mov rdi, QWORD [r12 + USUARIO_FEED_OFFSET]
    mov rsi, r13
    call borrar
    
    xor r8, r8
    mov r8d, DWORD[r12 + USUARIO_CANT_BLOQUEADOS_OFFSET]
    mov r9, QWORD [r12 + USUARIO_BLOQUEADOS_OFFSET]
    mov QWORD [r9 + r8*8], r13
    inc DWORD [r12 + USUARIO_CANT_BLOQUEADOS_OFFSET]

    mov rdi, QWORD [r13 + USUARIO_FEED_OFFSET]
    mov rsi, r12
    call borrar

    pop r13
    pop r12
    pop rbp
    ret
