section .text

global _start

_start:         mov rdi, Msg
                call printf

                mov rax, 0x3c
                xor rdi, rdi
                syscall

printf:         xor r10, r10
                xor r11, r11

.next           cmp r10, MsgLen
                je .Done

                cmp byte Msg[r10], '%'
                jne .usual

.usual          mov rax, rdi[r11]
                mov ExtraBuf[r10], rax
                inc r11
                inc r10
                call CheckExtraBuf

                jmp .next

.Done           mov rax, 0x01
                mov rdi, 1
                mov rsi, Msg
                mov rdx, r11
                syscall

                ret


;--------------------------------------
; Entry: r11 = ExtraBuffFill
; Exit: r11 = 0, if extra buffer over flow
;       nothing otherwise
; Expects: nothing
; Destroys: nothing
;--------------------------------------
CheckExtraBuf:  cmp r11, EXTRABUFLEN
                je .PrintBuf

                jmp .Nothing


.PrintBuf       push rax
                push rdi
                push rsi
                push rdx

                mov rax, 0x01
                mov rdi, 1
                mov rsi, Msg
                mov rdx, 256
                syscall

                xor r11, r11

                pop rdx
                pop rsi
                pop rdi
                pop rax

.Nothing        ret


section .data

EXTRABUFLEN     equ 256
ExtraBuf        times 256 db 0
Msg:            db "__HELLO ", 0x0a
MsgLen          equ $ - Msg


