; floppy sector 2

bits 16
org 0x0
 
main: 
  call scr_clear
  mov si, msgact
  call print_string

  mov ah, 0 ; read key
  int 0x16
  cmp ah, 0x3b
  jz .enc
  cmp ah, 0x3c
  jz .dec
  jmp main

.enc:
  mov si, msgenc
  call print_string
  call print_placeholder

  mov edx, 0
.enc_read:
  mov ah, 0
  int 0x16

  mov byte [buffer+edx], al
  inc edx

  cmp al, 0xd
  jz .enc_read_done
  cmp edx, 0x200
  jz .enc_read_done

  mov bx, dx
  and bx, 0x3f
  jnz .skip_nl

  push ax
  mov si, msgnl
  call print_string
  pop ax

.skip_nl:
  mov ah, 0xe
  mov bx, 7
  int 0x10

  jmp .enc_read

.enc_read_done:
  mov word [dlen], dx
  call scr_clear

  mov si, msgpss
  call print_string

  mov edx, 0
.enc_read_pass:
  mov ah, 0
  int 0x16

  mov byte [passwd+edx], al
  inc edx

  cmp al, 0xd
  jz .enc_pass_done
  cmp edx, 0x20
  jz .enc_pass_done

  mov ah, 0xe
  mov al, '*'
  mov bx, 7
  int 0x10

  jmp .enc_read_pass

.enc_pass_done:
  mov byte [passwd+edx], 0
  mov word [plen], dx

  mov si, msgsct
  call print_string

.enc_read_sect:
  mov ah, 0
  int 0x16

  cmp ah, 0xa
  jg .enc_read_sect
  cmp ah, 0x2
  jl .enc_read_sect

  dec ah
  mov byte [sect], ah

  mov ah, 0xe
  mov bx, 7
  int 0x10

  mov si, msgwrk
  call print_string

  mov ah, 0
  int 0x16

.dec:

  jmp main

scr_clear:
  mov ah, 0
  mov al, 3 ; set 80x25 color text, also clears screen
  int 0x10
  ret

print_string:
  lodsb
  cmp al, 0
  je .done

  mov ah, 0xe
  mov bx, 7
  int 0x10

  jmp print_string

.done:
  ret

print_placeholder:
  xor edx, edx
  mov ah, 3 ; read cursor pos and size...
  mov bh, 0 ; video page
  int 0x10
  push edx

  mov dx, 8
.loop:
  mov al, '.'
  mov cx, 0x40
  mov ah, 9
  mov bx, 7
  int 0x10

  mov si, msgnl
  call print_string

  dec dx
  jnz .loop

  mov ah, 2 ; set cursor pos
  mov bh, 0
  pop edx
  int 0x10

  ret

; data
sect    db 0
dlen    dw 0
plen    dw 0
passwd  times 32 db 0
buffer  times 512 db 0
msgact  db 13,10,'Actions:    F1 - encrypt    F2 - decrypt',13,10,10,0
msgenc  db 'Enter the message you want to encrypt:',13,10,10,0
msgpss  db 13,10,'Enter secret password: ',0
msgsct  db 13,10,'        Select sector: ',0
msgwrk  db 13,10,10,'Working... ',0
msgnl   db 13,10,0

; pad and sign the boot sector
        times 1024-($-$$) db 0
