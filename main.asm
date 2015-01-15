; floppy sector 2

bits 16
org 0x0
 
main: 
  call scr_clear
  mov si, msgact
  call print_string

  mov ah, 0         ; read key
  int 0x16          ;
  cmp ah, 0x3b      ; F1
  jz .enc           ;
  cmp ah, 0x3c      ; F2
  jz .dec           ;
  cmp ah, 0x3d      ; F3
  jz .reboot        ;
  jmp main

.reboot:
  db 0xea           ; yeah, machine code for
  dw 0x0, 0xffff    ; far jump to 0xffff

.enc:
  mov si, msgenc
  call print_string
  call print_placeholder

  mov edx, 0        ; character counter
.enc_read:
  mov ah, 0         ; read key
  int 0x16          ;

  mov byte [buffer+edx], al ; save character
  inc edx                   ; increment counter

  cmp al, 0xd       ; Enter
  jz .enc_read_done ;
  cmp edx, 0x200    ; counter = 512
  jz .enc_read_done ;

  mov bx, dx        ; copy counter to dx
  and bx, 0x3f      ; counter % 64
  cmp bx, 0x0       ;
  jnz .skip_nl      ; if != 0 skip new line

  push ax           ; save the character
  mov si, msgnl     ; print newline
  call print_string ;
  pop ax            ; restore

.skip_nl:
  mov ah, 0xe       ; echo the key read
  mov bx, 7         ;
  int 0x10          ;

  jmp .enc_read

.enc_read_done:
  mov word [dlen], dx ; save data length
  call scr_clear

  mov si, msgpss
  call print_string

  mov edx, 0        ; character counter
.enc_read_pass:
  mov ah, 0         ; read key
  int 0x16          ;

  mov byte [passwd+edx], al ; save character
  inc edx                   ; increment counter

  cmp al, 0xd       ; Enter
  jz .enc_pass_done ;
  cmp edx, 0x20     ; counter = 32
  jz .enc_pass_done ;

  mov ah, 0xe       ; echo the traditional '*'
  mov al, '*'       ;
  mov bx, 7         ;
  int 0x10          ;

  jmp .enc_read_pass

.enc_pass_done:
  mov byte [passwd+edx], 0  ; append null byte
  mov word [plen], dx       ; save pass length

  mov si, msgsct
  call print_string

.enc_read_sect:
  mov ah, 0         ; read key
  int 0x16          ;

  cmp ah, 0xa       ; filter the key so that
  jg .enc_read_sect ; only 1 - 9 is valid
  cmp ah, 0x2       ;
  jl .enc_read_sect ;

  dec ah              ; now we have the proper number
  mov byte [sect], ah ; save the sector number

  mov ah, 0xe       ; echo the number
  mov bx, 7         ;
  int 0x10          ;

  mov si, msgwrk
  call print_string

  mov ah, 0         ; wait for key
  int 0x16          ;

.dec:

  jmp main

scr_clear:
  mov ah, 0         ; set video mode
  mov al, 3         ; 80x25 color text 
  int 0x10          ; also clears screen
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
  xor edx, edx      ; clear edx
  mov ah, 3         ; read cursor pos (and size)
  mov bh, 0         ; video page
  int 0x10          ;
  push edx          ; save the cursor pos

  mov dx, 8         ; line counter
.loop:
  mov al, '.'       ; print '.'
  mov cx, 0x40      ; 64 times
  mov ah, 9         ;
  mov bx, 7         ;
  int 0x10          ;

  mov si, msgnl     ; print new line
  call print_string ;

  dec dx            ; next line
  jnz .loop         ; if != 0

  mov ah, 2         ; set cursor pos
  mov bh, 0         ; to
  pop edx           ; the saved value
  int 0x10          ;

  ret

; data
sect    db 0
dlen    dw 0
plen    dw 0
passwd  times 32 db 0
buffer  times 512 db 0
msgact  db 13,10,'Actions:   F1 - encrypt   F2 - decrypt   F3 - reboot',13,10,10,0
msgenc  db 'Enter the message you want to encrypt:',13,10,10,0
msgpss  db 13,10,'Enter secret password: ',0
msgsct  db 13,10,'        Select sector: ',0
msgwrk  db 13,10,10,'Working... ',0
msgnl   db 13,10,0

; pad the full-sector lengths, so that when we go over
; will know we need to update the number here and the
; number of sectors loaded in loader.asm
        times 1024-($-$$) db 0
