;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text
extern contar_casos_por_nivel
extern malloc

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


;segmentacion_t* segmentar_casos(caso_t* arreglo_casos, int largo)
global segmentar_casos
contar_casos_por_nivel: ; rdi = caso_t* arreglo_casos, esi = largo , edx = nivel
    push rbp
    mov rbp, rsp
    
    xor r8, r8      ; cantidad
    xor r9, r9      ; indice i

.for:
    cmp r9d, esi
    je .fin_ciclo
    mov eax, r9d 
    imul rax, CASO_SIZE
    lea r10, [rdi + rax]
    mov r11, [r10 + CASO_USUARIO_OFFSET]
    mov r10d, DWORD [r11 + USUARIO_NIVEL_OFFSET]
    cmp r10d, edx
    jne .siguiente
    inc r8
    jmp .siguiente

.siguiente:
    inc r9
    jmp .for

.fin_ciclo:
    cmp r8, 0
    je .es_null
    imul r8, CASO_SIZE
    mov rdi, r8
    call malloc
    jmp .fin


.es_null:
     xor rax, rax
     jmp .fin

.fin:
    pop rbp
    ret

segmentar_casos: ; rdi = arreglo_casos, esi = largo
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    mov rbx, rdi    ; Arreglo_casos
    mov r12d, esi   ; largo del arreglo

    mov edx, 0
    call contar_casos_por_nivel
    mov r13, rax    ; casos nivel 0

    mov rdi, rbx
    mov esi, r12d
    mov edx, 1
    call contar_casos_por_nivel
    mov r14, rax    ; casos nivel 1

    mov rdi, rbx
    mov esi, r12d
    mov edx, 2
    call contar_casos_por_nivel
    mov r15, rax    ; casos nivel 2

    mov rdi, SEGMENTACION_SIZE
    call malloc
    ; rax tiene la solucion 

    xor r8, r8      
    xor r9, r9      ; indices arreglos r13, r14, r15
    xor r10, r10

    xor r11, r11    ; indice iterador i

.for:
    cmp r11d, r12d
    je .fin

    mov rdi, r11
    imul rdi, CASO_SIZE
    lea rcx, [rbx + rdi]
    mov rsi, [rcx + CASO_USUARIO_OFFSET]
    mov ecx, DWORD [rsi + USUARIO_NIVEL_OFFSET]

    cmp ecx, 0
    je .if_nivel_0
    cmp ecx, 1
    je .if_nivel_1
    jmp .if_nivel_2

.if_nivel_0:
    mov rdi, r8
    imul rdi, CASO_SIZE
    lea rcx, [r13 + rdi]
    mov rdi, r11
    imul rdi, CASO_SIZE
    lea rsi, [rbx + rdi] 

    mov rdi, [rsi]
    mov [rcx], rdi

    mov rdi, [rsi + 8]
    mov [rcx + 8], rdi
    inc r8
    jmp .siguiente

.if_nivel_1:
    mov rdi, r9
    imul rdi, CASO_SIZE
    lea rcx, [r14 + rdi]
    mov rdi, r11
    imul rdi, CASO_SIZE
    lea rsi, [rbx + rdi] 

    mov rdi, [rsi]
    mov [rcx], rdi

    mov rdi, [rsi + 8]
    mov [rcx + 8], rdi
    inc r9
    jmp .siguiente

.if_nivel_2:
    mov rdi, r10
    imul rdi, CASO_SIZE
    lea rcx, [r15 + rdi]
    mov rdi, r11
    imul rdi, CASO_SIZE
    lea rsi, [rbx + rdi] 

    mov rdi, [rsi]
    mov [rcx], rdi

    mov rdi, [rsi + 8]
    mov [rcx + 8], rdi
    inc r10
    jmp .siguiente

.siguiente:
    inc r11
    jmp .for

.fin:
    mov [rax + 0], r13   ; solucion->casos_nivel_0 = cero
    mov [rax + 8], r14   ; solucion->casos_nivel_1 = uno
    mov [rax + 16], r15  ; solucion->casos_nivel_2 = dos
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

