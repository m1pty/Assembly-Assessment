bits	64
; Найти максимальную по модулю разность двух чисел в матрице 
section	.data       ; <----------------------------

n:  db	3
m:  db	5
matrix:
	db	4,  6, 1,  8,  2
	db	1,  2, 3,  4,  5	
	db	0, -7, 3, -1, -1

section .text       ; <----------------------------
global  _start
_start:
    ; rdi, rsi, rdx, rcx, r8, r9, stack
    mov     rdi, matrix
    movzx   rsi, byte[m]
    movzx   rdx, byte[n]
    call    _function

.return:            ; запись эквивалентна "return 0"
    mov     eax, 60 ; системный вызов "return"
    mov     edi, 0  ; код возврата
    syscall

; своя функция
; параметры:    rdi, rsi, rdx, rcx, r8, r9, stack
; возврат через rax
; сохранение:   rbx, rbp, r12, r13, r14, r15

; для работы со стеком обязан быть выделен кадр стека

stored      equ 8 * 5               ; для хранения регистров, сохраняемых по соглашению вызовов
counter     equ stored  + 8         ; для хранение счётчика цикла (rcx)
parameters  equ counter + 8 * 3     ; хранение rdi, rsi, rdx
_function:
    push    rbp              ; указывает на начало кадра стека (BasePointer)
    mov     rbp, rsp         ; указывает на верхушку кадра стека (StackPointer)
    sub     rsp, parameters  ; 

    ; сохраним в кадре стека регистры из соглашения вызовов
    mov     [rbp-stored],    rbx
    mov     [rbp-stored+8],  r12
    mov     [rbp-stored+16], r13
    mov     [rbp-stored+24], r14
    mov     [rbp-stored+32], r15

    ; сохраним параметры 
    mov     [rbp-parameters],    rdi
    mov     [rbp-parameters+8],  rsi
    mov     [rbp-parameters+16], rdx

    ; rdi - matrix, rsi - width, rdx - length
    mov     rax, rsi
    mul     rdx
    mov     r11, rax ; r11 - m*n
    xor     r10, r10 ; r10 - максимальная разность по модулю
    ; xor     r8, r8   ; r8  - индекс первого сравниваемого элемента
    ; xor     r9, r9   ; r9  - индекс второго сравниваемого элемента [r8 + 1, n*m)
    mov     rcx, r11
    sub     rcx, 1

.outer_loop1:
    mov     [rbp-counter], rcx
    sub     rcx, 1
    
.inner_loop:
    movsx   r8, ; <...>
    movsx   r9, ; <...> 
    loop    .inner_loop

.outer_loop2:
    mov     rcx, [rbp-counter]
    loop    .outer_loop1

.exit:
    ; возврат функцией максимального значения модуля разности через rax
    mov     rax, r10

    ; восстановление регистров по соглашению вызовов
    mov     rbx, [rbp-stored]
    mov     r12, [rbp-stored+8]
    mov     r13, [rbp-stored+16]
    mov     r14, [rbp-stored+24]
    mov     r15, [rbp-stored+32] 
    
    ; возвращаем указатель на кадр стека вызвавшей функции и делаем возврат значения
    leave
    ret
