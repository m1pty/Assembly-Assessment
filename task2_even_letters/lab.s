bits	64
; Напечатать строку, в которой вырезаны нечётные буквы слов (буквы в слове номеруются с 1)
; "abc def ghi" -> "beh"
section	.data

buflen      equ 20 + 1        ; длина буфера = макс. длина строки+1 (определена в условии)
in_buf:     times buflen db 0 ; буфер ввода
out_buf:    times buflen db 0 ; буфер вывода

section .text
global  _start

_start:
    ; чтение из потока ввода 
    xor     eax, eax     ; eax = 0 - read
    xor     edi, edi     ; edi = 0 - stdin
    mov     esi, in_buf  ; esi - адрес буфера ввода
    mov     edx, buflen  ; edx - длина буфера
    syscall

; проверка на верное число считанных символов (eax > 0, иначе выходим)
.check_correct:
    or      eax, eax
    jle     .exit

; обработка строки 
.process_string:
    xor     ecx, ecx    ; ecx = MAX_INT (while True)
    xor     r10, r10    ; r10 - индекс в in_buf
    xor     r11, r11    ; r11 - индекс в out_buf
    xor     r9, r9      ; r9  - номер буквы в слове

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

; " abc" -> r9 = 0, 
; " 123"
.is_delimiter:
    xor     r9, r9
    jmp     .continue
    
.is_letter:
    ; проверка на чётность знакового
    inc     r9

    mov     r8, 1   ; const(1)

    and     r8, r9  ; 
    cmp     r8, 1
    je      .continue

    ; копирование в буфер вывода
    mov     rsi, out_buf
    mov     byte[rsi + r11], al
    inc     r11

.continue:
    inc     r10
    loop    .process_symbol

.aftercount: 
    ; (rsi - адрес буфера вывода)
    mov     rsi, out_buf

; подсчёт длины выходной строки (длина = последний индекс в строке вывода)
.count_length:
    mov     edx, r11d

; вывод в stdout
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
