bits	64
; Print the row, starting with the first letters of every word
; "abc def ghi" -> "adg"
section	.data

buflen      equ 20 + 1        ; длина буфера = макс. длина строки+1 (определена в условии)
in_buf:     times buflen db 0 ; буфер ввода
out_buf:    times buflen db 0 ; буфер вывода

section .text
global  _start

_start:
    ; конвенция: rdi, rsi, rdx, rcx, r8, r9, stack
    ; eax - тип операции
    ; rdi - откуда (destination, поток)
    ; rsi - адрес буфера
    ; rdx - длина буфера

    ; чтение из потока ввода 
    xor     eax, eax     ; eax = 0 - read  (0 - read, 1 - write)
    xor     edi, edi     ; edi = 0 - stdin (0 - stdin, 1 - stdout, 2 - stderr)
    mov     esi, in_buf  ; esi - адрес буфера ввода
    mov     edx, buflen  ; edx - длина буфера
    syscall

; проверка на верное число считанных символов (eax > 0, иначе выходим)
.check_correct:
    or      eax, eax ; 
    jle     .exit

; обработка строки 
.process_string:
    ; mov   ecx, 0
    xor     ecx, ecx    ; ecx = MAX_INT (while True)
    xor     r10, r10    ; r10 - индекс в in_buf   (i)
    xor     r11, r11    ; r11 - индекс в out_buf  (j)
    mov     r9, 1       ; r9  - пробельный флаг (прошлый символ был пробельный - 1)

.process_symbol:
    mov     rsi, in_buf
    mov     al, byte[rsi + r10]
    
    cmp     al, 10 ; al == '\n'
    je      .is_delimiter
    cmp     al, 32 ; al == ' '
    je      .is_delimiter

    cmp     al, 0  ; al == '\0', строка ввода кончилась
    je      .aftercount 

    jmp     .is_letter

.is_delimiter:
    mov     r9, 1
    jmp     .continue
    
; "abc 123" - "a1"
.is_letter:
    ; если r9 == 0, то это символ внутри слова, не копируем
    cmp     r9, 1
    jne     .continue

    ; r9 == 0 -> нужно скопировать символ
    ; копирование в буфер вывода
    mov     rsi, out_buf
    mov     byte[rsi + r11], al
    inc     r11
    xor     r9, r9

; переход к селдующему символу буфера ввода
.continue:
    inc     r10
    loop    .process_symbol

.aftercount:
    ; подготовка к подсчёту длины вывода 
    ; (rsi - адрес буфера вывода)
    mov     rsi, out_buf

; подсчёт длины выходной строки (длина = последний индекс в строке вывода)
.count_length:
    mov     edx, r11d

; вывод в stdout
; rax, rdi, rsi, rdx
.print_output:
    mov     eax, 1       ; eax = 1 - write
    mov     edi, 1       ; edi = 1 - stdout
    mov     esi, out_buf ;
                         ; edx - длина выходной строки (получена в метке .count_length)
    syscall
    mov     ebx, 0

; return <exit-code>;
.exit:
    mov     edi, ebx     ; ebx - exit-code
    mov     eax, 60      ; eax = 60 - call "return"
    syscall
