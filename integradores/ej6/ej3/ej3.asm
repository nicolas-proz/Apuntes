extern malloc

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

; tuit_t **trendingTopic(usuario_t *usuario, uint8_t (*esTuitSobresaliente)(tuit_t *));
global cant_tweets
global trendingTopic
cant_tweets:
    push rbp
    mov rbp, rsp

    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp, 8

    mov r12, rdi        ; usuario_t* user
    mov r13, rsi        ; funcion
    xor r14, r14        ; cantidad de tweets

    mov r8, [r12 + USUARIO_FEED_OFFSET]     
    mov r15, [r8 + FEED_FIRST_OFFSET]       ; actual

    mov ebx, DWORD [r12 + USUARIO_ID_OFFSET] ; usuario_id

.while:
    cmp r15, 0
    je .fin
    mov rdi, [r15 + PUBLICACION_VALUE_OFFSET]
    mov r9d, DWORD [rdi + TUIT_ID_AUTOR_OFFSET]
    cmp r9d, ebx
    jne .siguiente
    call r13
    cmp al, 1
    jne .siguiente
    inc r14
    jmp .siguiente
    

.siguiente:
    mov r15, [r15 + PUBLICACION_NEXT_OFFSET]
    jmp .while

.fin:
    mov rax, r14
    add rsp, 8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret

trendingTopic:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp, 8

    mov r12, rdi    ;user
    mov r13, rsi    ;funcion

    call cant_tweets
    cmp rax, 0
    je .vacio
    
    add rax, 1
    imul rax, 8
    mov rdi, rax
    call malloc

    mov rbx, rax    ; tuit_t** trending
    xor r14, r14    ; indice = 0

    mov rdi, [r12 + USUARIO_FEED_OFFSET]
    mov r15, [rdi + FEED_FIRST_OFFSET]              ;actual
    mov r12d, DWORD [r12 + USUARIO_ID_OFFSET]       ;id

.while:
    cmp r15, 0
    je .actualizar_respuesta
    mov rdi, [r15 + PUBLICACION_VALUE_OFFSET]
    mov esi, DWORD [rdi + TUIT_ID_AUTOR_OFFSET]
    cmp esi, r12d
    jne .siguiente

    call r13
    cmp al, 1
    jne .siguiente
    mov rdi, [r15 + PUBLICACION_VALUE_OFFSET]
    mov [rbx + r14*8], rdi
    inc r14
    jmp .siguiente

.siguiente:
    mov r15, [r15 + PUBLICACION_NEXT_OFFSET]
    jmp .while

.vacio:
    xor rax, rax
    jmp .fin

.actualizar_respuesta:
    mov QWORD [rbx + r14*8], 0
    mov rax, rbx
    jmp .fin

.fin:
    add rsp, 8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret
