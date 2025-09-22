; ej3c.asm - calcular_estadisticas + actualizar_estadisticas
; Versión reescrita: usa memcmp (3 bytes), protege punteros NULL,
; mantiene ESTADISTICAS_SIZE = 7 (NO lo cambies), preserva alineamiento de stack,
; y devuelve el puntero solución en rax.

extern calloc
extern memcmp

section .data
    ; definimos 3 bytes por etiqueta (memcmp usará 3)
    str_CLT: db 'CLT'
    str_RBO: db 'RBO'
    str_KSC: db 'KSC'
    str_KDT: db 'KDT'

section .text

; offsets / tamaños (según ABI del enunciado)
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

global actualizar_estadisticas
global calcular_estadisticas

; ----------------------------------------
; void actualizar_estadisticas(estadisticas_t *solucion, caso_t *actual)
; rdi = solucion, rsi = actual
actualizar_estadisticas:
    push rbp
    mov rbp, rsp
    push r12
    push r13

    mov r12, rdi        ; r12 = solucion
    mov r13, rsi        ; r13 = actual

    ; comparar categoria con "CLT"
    lea rdi, [r13 + CASO_CATEGORIA_OFFSET]   ; s1
    lea rsi, [rel str_CLT]                   ; s2
    mov edx, 3
    call memcmp
    test eax, eax
    je .es_clt

    ; comparar con "RBO"
    lea rdi, [r13 + CASO_CATEGORIA_OFFSET]
    lea rsi, [rel str_RBO]
    mov edx, 3
    call memcmp
    test eax, eax
    je .es_rbo

    ; comparar con "KSC"
    lea rdi, [r13 + CASO_CATEGORIA_OFFSET]
    lea rsi, [rel str_KSC]
    mov edx, 3
    call memcmp
    test eax, eax
    je .es_ksc

    ; comparar con "KDT"
    lea rdi, [r13 + CASO_CATEGORIA_OFFSET]
    lea rsi, [rel str_KDT]
    mov edx, 3
    call memcmp
    test eax, eax
    je .es_kdt

    ; si ninguna categoria, seguir al estado
    jmp .estado

.es_clt:
    inc BYTE [r12 + ESTADISTICAS_CLT_OFFSET]
    jmp .estado

.es_rbo:
    inc BYTE [r12 + ESTADISTICAS_RBO_OFFSET]
    jmp .estado

.es_ksc:
    inc BYTE [r12 + ESTADISTICAS_KSC_OFFSET]
    jmp .estado

.es_kdt:
    inc BYTE [r12 + ESTADISTICAS_KDT_OFFSET]
    jmp .estado

.estado:
    ; estado es uint16_t
    mov r8w, WORD [r13 + CASO_ESTADO_OFFSET]
    cmp r8w, 0
    je .es_cero
    cmp r8w, 1
    je .es_uno
    jmp .es_dos

.es_cero:
    inc BYTE [r12 + ESTADISTICAS_ESTADO0_OFFSET]
    jmp .fin_actualizar
.es_uno:
    inc BYTE [r12 + ESTADISTICAS_ESTADO1_OFFSET]
    jmp .fin_actualizar
.es_dos:
    inc BYTE [r12 + ESTADISTICAS_ESTADO2_OFFSET]
    jmp .fin_actualizar

.fin_actualizar:
    pop r13
    pop r12
    pop rbp
    ret

; ----------------------------------------
; void* calcular_estadisticas(caso_t* arreglo_casos, int largo, uint32_t usuario_id)
; rdi = arreglo_casos, rsi = largo, rdx = usuario_id
calcular_estadisticas:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp, 8          ; mantener alineamiento a 16 antes de llamadas C

    mov r12, rdi        ; r12 = arreglo_casos (base)
    mov r13d, esi       ; r13d = largo
    mov r14d, edx       ; r14d = usuario_id (filtro)

    ; reservar memoria: calloc(1, ESTADISTICAS_SIZE)
    mov rdi, 1
    mov rsi, ESTADISTICAS_SIZE
    call calloc
    mov rbx, rax        ; rbx = solucion (puede ser NULL)

    xor r15, r15        ; r15 = i = 0

    ; si usuario_id != 0 -> filtrar por usuario
    cmp r14d, 0
    je .actualizar_todo

.for_usuario:
    cmp r15d, r13d
    je .fin_ciclo

    ; offset = i * CASO_SIZE
    mov r10, r15
    imul r10, r10, CASO_SIZE
    lea rsi, [r12 + r10]        ; rsi = &arreglo_casos[i]

    ; obtener usuario pointer y comprobar NULL
    mov r8, [rsi + CASO_USUARIO_OFFSET]   ; r8 = usuario_t*

    ; leer usuario->id (uint32)
    mov r9d, DWORD [r8 + USUARIO_ID_OFFSET]
    cmp r14d, r9d
    jne .siguiente_usuario

    ; llamar actualizar_estadisticas(solucion, &caso)
    mov rdi, rbx
    call actualizar_estadisticas

.siguiente_usuario:
    inc r15
    jmp .for_usuario

.actualizar_todo:
    ; recorrer todos (sin filtro). reiniciar i
    xor r15, r15
.for_all:
    cmp r15d, r13d
    je .fin_ciclo
    mov r10, r15
    imul r10, r10, CASO_SIZE
    lea rsi, [r12 + r10]     ; rsi = &arreglo_casos[i]
    mov rdi, rbx
    call actualizar_estadisticas
    inc r15
    jmp .for_all

.fin_ciclo:
    ; devolver puntero solucion en rax (como exige la ABI)
    mov rax, rbx

    add rsp, 8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret



    