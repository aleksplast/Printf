section .text

global MyPrintf

MyPrintf:       pop r15
                push r9
                push r8
                push rcx
                push rdx
                push rsi
                push rbp
                mov rbp, rsp
                add rbp, 8

                push rsi
                mov rsi, rdi
                call StrLen
                pop rsi
                mov r12, rax
                xor r11, r11
                xor r10, r10

NextMain:       cmp r10, r12
                je DoneMain

                cmp byte rdi[r10], '%'
                jne usual

                inc r10
                jmp SpecificatorHandler
GlobalNext:     jmp NextMain

usual:          mov rax, rdi[r10]
                mov ExtraBuf[r11], rax
                inc r11
                inc r10
                call CheckExtraBuf

                jmp NextMain

DoneMain:       call PrintExtraBuff

                pop rbp
                pop rsi
                pop rdx
                pop rcx
                pop r8
                pop r9
                push r15
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

.PrintBuf       call PrintExtraBuff

.Nothing        ret


PrintExtraBuff: push rax
                push rdi
                push rsi
                push rdx

                mov rax, 0x01
                mov rdi, 1
                mov rsi, ExtraBuf
                mov rdx, r11
                syscall

                xor r11, r11

                pop rdx
                pop rsi
                pop rdi
                pop rax

                ret

;------------------------------------------------
; Counting string's lenght
;------------------------------------------------
; Entry:	RSI = ptr of the start
; Exit:		RAX = string's lenght
; Expects:	none
; Destroys: none
;------------------------------------------------
StrLen:	    push rsi
            push rcx
			mov rcx, rsi
            mov byte al, [rsi]

.Next:		cmp byte al, 0x00
			je .Done

			mov byte al, [rsi]
            inc rsi
			jmp .Next

.Done:		mov rax, rsi
			sub rax, rcx

            pop rcx
			pop rsi

			ret


;------------------------------------------------
; Handles specificator in printf
;------------------------------------------------
; Entry:    R10 = symbol after specificator
;           RAX = data to print
;           RDI = string ptr
; Exit:		AX = string's lengh
; Expects:	none
; Destroys: none
;------------------------------------------------

SpecificatorHandler:
            call PrintExtraBuff
            cmp byte rdi[r10], '%'
            je .PercentPrt
            xor rbx, rbx
            mov byte bl, rdi[r10]
            jmp [JmpTable + 8 * (rbx - 'b')]

.PercentPrt mov byte ExtraBuf[r11], '%'
            inc r11

SpecOver:   inc r10

            jmp GlobalNext


Sspecif:    mov rax, [rbp]
            add rbp, 8

            push rax
            push rsi
            push rdx
            push rdi
            push r11

            mov rsi, rax
            call StrLen
            mov rdx, rax
            mov rax, 0x01
            mov rdi, 1
            syscall

            pop r11
            pop rdi
            pop rdx
            pop rsi
            pop rax

            jmp SpecOver

;---------------------------------------------------------

Ospecif:    mov rax, [rbp]
            add rbp, 8

            xor r13, r13
            push rsi
            push rdx
            push rax
			xor rdx, rdx

.Next1:		call CheckExtraBuf
            cmp rax, 0
			je .Done1

			mov rsi, rax
			and rsi, 111b

			add rsi, 30h
			mov DexBuf[r13], rsi
            inc r13

            shr rax, 3
			jmp .Next1

.Done1:     call PrintDex
            pop rax
            pop rdx
            pop rsi

            jmp SpecOver

;---------------------------------------------------------

Cspecif:    mov rax, [rbp]
            add rbp, 8

            call CheckExtraBuf
            mov byte ExtraBuf[r11], al
            inc r11

            jmp SpecOver

;---------------------------------------------------------

Dspecif:    mov rax, [rbp]
            add rbp, 8

            push rax
            push rbx
            push rcx
            push rdx
            push rsi

            xor rcx, rcx
            xor rdx, rdx
            xor r13, r13

.Next3:		call CheckExtraBuf
            xor dx, dx
			cmp ax, 2560d
			jb .Less

			mov cl, 10d
			xor ch, ch
			div cx
			add dl, 30h
			mov byte DexBuf[r13], dl
            inc r13

			jmp .Next3

.Less:		cmp ax, 0h
			je .Done3

			mov cl, 10d
			xor ch, ch
			div cl
            push rax
            xchg ah, al
			add al, 30h
			mov byte DexBuf[r13], al
            inc r13
            pop rax

			xor ah, ah
			jmp .Less

.Done3:	    call PrintDex
            pop rsi
            pop rdx
            pop rcx
            pop rbx
            pop rax

            jmp SpecOver

;---------------------------------------------------------
;------------------------------------------------
; Prints number in DEX to ExtraBuffer
;------------------------------------------------
; Entry:    R11 = extra buf tail
;           R13 = lenght of number
; Exit:		R11 = tail of extra buf
; Expects:	none
; Destroys: r12
;------------------------------------------------
PrintDex:   push rax

.Next       cmp r13, 0
            je .Done
            call CheckExtraBuf
            mov rax, DexBuf[r13 - 1]
            mov ExtraBuf[r11], rax
            dec r13
            inc r11
            jmp .Next

.Done       pop rax
            ret

;---------------------------------------------------------

Bspecif:    mov rax, [rbp]
            add rbp, 8

            push rax
            push rdx
            xor dx, dx
            xor r13, r13

.Next2:		call CheckExtraBuf
            cmp rax, 0
			je .Done2

			shr rax, 1
			jc .PrtZ
			mov byte DexBuf[r13], 0x30
            inc r13
			jmp .Nothing2

.PrtZ:		mov byte DexBuf[r13], 0x31
            inc r13

.Nothing2:  jmp .Next2

.Done2:		call PrintDex
            pop rdx
            pop rax

            jmp SpecOver

;---------------------------------------------------------

Xspecif:    mov rax, [rbp]
            add rbp, 8

            xor r13, r13
            push rsi
            push rdx
            push rax
			xor rdx, rdx

.Next1:		call CheckExtraBuf
            cmp rax, 0
			je .Done1

			mov rsi, rax
			and rsi, 0x000F

			cmp rsi, 0Ah
			jae .PrtSym

			add rsi, 30h
			mov DexBuf[r13], rsi
            inc r13
			jmp .None

.PrtSym:	sub rsi, 0Ah
			add rsi, 41h
			mov DexBuf[r13], rsi
            inc r13

.None       shr rax, 4
			jmp .Next1

.Done1:     call PrintDex
            pop rax
            pop rdx
            pop rsi
            jmp SpecOver

;---------------------------------------------------------


section .data

JmpTable:
.Bspec       dq Bspecif
.Cspec       dq Cspecif
.Dspec       dq Dspecif
times ('o'-'d' - 1)   dq 0
.Ospec       dq Ospecif
times  ('s' - 'o' - 1)   dq 0
.Sspec       dq Sspecif
times ('x' - 's' - 1) dq 0
.Xspec       dq Xspecif


DexBuf          times 256 db 0
EXTRABUFLEN     equ 256
ExtraBuf        times 256 db 0
Number          equ 255
Char            equ 'c'
Msg:            db "__HELLO", 0x0a
                db "What do you love?", 0x0a,
                db 0x00
ASS:            db "YOUR MUM GAY", 0x00
