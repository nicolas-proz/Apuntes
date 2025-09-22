extern strncmp
;########### SECCION DE DATOS
section .data
str_CLT: db 'CLT', 0
str_RBO: db 'RBO', 0
;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
USUARIO_ID_OFFSET EQU 0
USUARIO_NIVEL_OFFSET EQU 4
USUARIO_SIZE EQU 8

CASO_CATEGORIA_OFFSET EQU 0
CASO_ESTADO_OFFSET EQU 4
CASO_USUARIO_OFFSET EQU 8
CASO_SIZE EQU 16

SEGMENTACION_CASOS0_OFFSET EQU 0
SEGMENTACION_CASOS1_OFFSET EQU 8
SEGMENTACION_CASOS2_OFFSET EQU 16
SEGMENTACION_SIZE EQU 24

ESTADISTICAS_CLT_OFFSET EQU 0
ESTADISTICAS_RBO_OFFSET EQU 1
ESTADISTICAS_KSC_OFFSET EQU 2
ESTADISTICAS_KDT_OFFSET EQU 3
ESTADISTICAS_ESTADO0_OFFSET EQU 4
ESTADISTICAS_ESTADO1_OFFSET EQU 5
ESTADISTICAS_ESTADO2_OFFSET EQU 6
ESTADISTICAS_SIZE EQU 7

global resolver_automaticamente

;void resolver_automaticamente(funcionCierraCasos* funcion, caso_t* arreglo_casos, caso_t* casos_a_revisar, int largo)
resolver_automaticamente:
    push rbx
    push r12
    push r13
    push r14
    push r15

    sub rsp, 16          ; espacio para variables locales, mantiene alineación

    mov r12, rdi         ; funcion
    mov r13, rsi         ; arreglo_casos
    mov r14, rdx         ; casos_a_revisar

    xor rbx, rbx         ; índice i
    mov DWORD [rsp], ecx      ; largo
    mov QWORD [rsp+8], 0      ; índice casos_a_revisar

.for_loop:
    mov eax, DWORD [rsp]
    cmp ebx, eax
    je .fin

    mov rax, rbx
    imul rax, CASO_SIZE
    lea r15, [r13 + rax]

    mov rsi, [r15 + CASO_USUARIO_OFFSET]
    mov edi, DWORD [rsi + USUARIO_NIVEL_OFFSET]

    cmp edi, 1
    je .check_nivel
    cmp edi, 2
    je .check_nivel
    jmp .no_cambio

.check_nivel:
    mov rdi, r15
    call r12
    cmp ax, 1
    je .caso_1
    cmp ax, 0
    je .caso_0
    jmp .no_cambio

.caso_1:
    mov WORD [r15 + CASO_ESTADO_OFFSET], 1
    jmp .siguiente

.caso_0:
    lea rdi, [r15 + CASO_CATEGORIA_OFFSET]
    lea rsi, [rel str_CLT]
    mov rdx, 4
    call strncmp
    cmp eax, 0
    je .estado_2

    lea rdi, [r15 + CASO_CATEGORIA_OFFSET]
    lea rsi, [rel str_RBO]
    mov rdx, 4
    call strncmp
    cmp eax, 0
    je .estado_2

.no_cambio:
    mov rsi, QWORD [rsp+8]      ; índice
    imul rsi, CASO_SIZE
    lea rdi, [r14 + rsi]

    mov rdx, [r15]
    mov [rdi], rdx
    mov rdx, [r15 + 8]
    mov [rdi + 8], rdx

    inc QWORD [rsp+8]
    jmp .siguiente

.estado_2:
    mov DWORD [r15 + CASO_ESTADO_OFFSET], 2
    jmp .siguiente

.siguiente:
    inc rbx
    jmp .for_loop

.fin:
    add rsp, 16
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
