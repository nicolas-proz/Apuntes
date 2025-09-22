extern strcmp
global invocar_habilidad

; Completar las definiciones o borrarlas (en este ejercicio NO serán revisadas por el ABI enforcer)
DIRENTRY_NAME_OFFSET EQU 0
DIRENTRY_PTR_OFFSET EQU 16
DIRENTRY_SIZE EQU 24

FANTASTRUCO_DIR_OFFSET EQU 0
FANTASTRUCO_ENTRIES_OFFSET EQU 8
FANTASTRUCO_ARCHETYPE_OFFSET EQU 16
FANTASTRUCO_FACEUP_OFFSET EQU 24
FANTASTRUCO_SIZE EQU 32

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text

; void invocar_habilidad(void* carta, char* habilidad);
invocar_habilidad:
    ; rdi = void* card
    ; rsi = char* habilidad
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    push r15
    push rbx
    sub rsp, 8

    mov r12, rdi       ; r12 = card
    mov r13, rsi       ; r13 = habilidad
    xor r14, r14       ; r14 = i = 0

    mov r15w, WORD [r12 + FANTASTRUCO_ENTRIES_OFFSET] ; len

.for:
    cmp r14w, r15w
    je .fin_ciclo

    ; ----- ACCESO CORRECTO A actual -----
    mov rsi, [r12 + FANTASTRUCO_DIR_OFFSET]   ; rsi = __dir (puntero al array de punteros)
    mov rbx, [rsi + r14*8]                     ; rbx = actual = dir[i]
    ; -----------------------------------

    lea rdi, [rbx + DIRENTRY_NAME_OFFSET]     ; actual->ability_name
    mov rsi, r13                              ; habilidad
    call strcmp
    test eax, eax
    jne .siguiente

    mov rdx, [rbx + DIRENTRY_PTR_OFFSET]      ; actual->ability_ptr
    mov rdi, r12                              ; pasar carta donde se encontró
    call rdx
    mov rax, 1
    jmp .terminar

.siguiente:
    inc r14
    jmp .for

.fin_ciclo:
    mov rax, [r12 + FANTASTRUCO_ARCHETYPE_OFFSET] ; card->__archetype
    cmp rax, 0
    je .terminar
    mov rdi, rax
    mov rsi, r13
    call invocar_habilidad

.terminar:
    add rsp, 8
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    ret


