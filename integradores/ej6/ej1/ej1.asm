extern malloc
extern strcpy

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

; tuit_t *publicar(char *mensaje, usuario_t *usuario);
global publicar
global agregar
agregar:
    ;rdi = *feed
    ;rsi = *tweet
    push rbp
    mov rbp, rsp
    push r12
    push r13


    mov r12, rdi
    mov r13, rsi

    mov rdi, PUBLICACION_SIZE
    call malloc

    mov [rax + PUBLICACION_VALUE_OFFSET], r13
    mov rdi, [r12 + FEED_FIRST_OFFSET]
    mov [rax + PUBLICACION_NEXT_OFFSET], rdi
    mov [r12 + FEED_FIRST_OFFSET], rax


    pop r13
    pop r12
    pop rbp
    ret

publicar:
    ; rdi = char* mensaje
    ; rsi = usuario_t *user
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

    mov rdi, TUIT_SIZE
    call malloc
    mov rbx, rax        ; tuit_t *tweet = malloc(sizeof(tuit_t));

    mov WORD [rbx + TUIT_FAVORITOS_OFFSET], 0                   ; tweet->favoritos = 0
    mov WORD [rbx + TUIT_RETUITS_OFFSET], 0                     ; tweet->retuits = 0

    mov r8d, [r13 + USUARIO_ID_OFFSET]                          ; user->id
    mov DWORD [rbx + TUIT_ID_AUTOR_OFFSET], r8d                 ; tweet->user_id = user->id

    lea rdi, [rbx + TUIT_MENSAJE_OFFSET]
    mov rsi, r12
    call strcpy                                                 ; tweet->mensaje = mensaje

    mov rdi, [r13 + USUARIO_FEED_OFFSET]
    mov rsi, rbx
    call agregar                                                ; agregar(feed, tweet)

    mov r14d, DWORD [r13 + USUARIO_CANT_SEGUIDORES_OFFSET]      ; r14 = cant_seguidores
    xor r15, r15                                                ; r15 = iterador i
.for:
    cmp r15d, r14d
    je .fin
    mov r8, [r13 + USUARIO_SEGUIDORES_OFFSET]       ; r8 = usuario->seguidores (puntero a punteros)
    mov r9, [r8 + r15*8]                            ; rdi = usuario_t *seguidor = seguidores[i]
    mov rdi, [r9 + USUARIO_FEED_OFFSET]
    mov rsi, rbx
    call agregar
    inc r15
    jmp .for


.fin:
    mov rax, rbx
    add rsp, 8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


