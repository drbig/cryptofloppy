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
  cmp al, 0x8       ; Backspace
  jnz .skip_bksp    ;
  sub edx, 0x2      ; just decrease the counter
.skip_bksp:
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
  mov byte [buffer+edx], 0  ; append null byte
  mov word [dlen], dx       ; save data length

  call scr_clear
  call read_pass
  call read_sect

  mov si, msgwrk
  call print_string

  call encrypt

  call flp_reset
  mov dh, 3         ; write
  call flp_op       ;

  mov ah, 0         ; wait for key
  int 0x16          ;

  jmp main

.dec:
  call read_pass
  call read_sect

  mov si, msgwrk
  call print_string

  call flp_reset
  mov dh, 2         ; read
  call flp_op       ;

  call decrypt

  mov si, msgstr
  call print_string
  mov si, buffer
  call print_string
  mov si, msgend
  call print_string

  mov ah, 0         ; wait for key
  int 0x16          ;

  jmp main

read_pass:
  mov si, msgpss
  call print_string

  mov edx, 0        ; character counter
.loop:
  mov ah, 0         ; read key
  int 0x16          ;

  cmp al, 0xd       ; Enter
  jz .done          ;

  mov byte [passwd+edx], al ; save character
  inc edx                   ; increment counter

  cmp edx, 0x20     ; counter = 32
  jz .done          ;

  mov ah, 0xe       ; echo the traditional '*'
  mov al, '*'       ;
  mov bx, 7         ;
  int 0x10          ;

  jmp .loop

.done:
  mov byte [passwd+edx], 0  ; append null byte
  dec edx                   ; we actually want last index
  mov word [plen], dx       ; save pass length

  ret

read_sect:
  mov si, msgsct
  call print_string

.loop:
  mov ah, 0         ; read key
  int 0x16          ;

  cmp ah, 0xa       ; filter the key so that
  jg .loop          ; only 1 - 9 is valid
  cmp ah, 0x2       ;
  jl .loop          ;

  dec ah              ; fix key read
  add ah, 0x4         ; offset (code uses 4 sectors)
  mov byte [sect], ah ; save the sector number

  mov ah, 0xe       ; echo the number
  mov bx, 7         ;
  int 0x10          ;

  ret

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

flp_reset:          ; Reset the floppy drive
  mov ax, 0         ;
  mov dl, 0         ; Drive=0 (=A)
  int 0x13          ;
  jnc .done         ; ERROR => reset again

  mov si, msgferr
  call print_string
  jmp flp_reset

.done:
  ret

flp_op:
  mov ax, 0x1000      ; ES:BX = 1000:bx
  mov es, ax          ;
  mov bx, buffer

  mov ah, dh          ; ah indicates 2 = load, 3 = write
  mov al, 1           ; Load 1 sector
  mov ch, 0           ; Cylinder=0
  mov cl, byte [sect] ; Sector
  mov dh, 0           ; Head=0
  mov dl, 0           ; Drive=0
  int 0x13            ; Read!
  jnc .done           ; ERROR => Try again

  mov si, msgferr
  call print_string
  jmp flp_op

.done:
  mov si, msgfok
  call print_string

  ret

encrypt:
  mov ecx, 0x0
  mov edx, 0x0
  mov si, buffer

.loop:
  lodsb

  mov bl, byte [passwd+edx]
  xor al, bl
  mov byte [buffer+ecx], al
  xor al, bl
  cmp al, 0x0
  jz .done

  inc ecx
  inc edx
  mov ax, word [plen]
  cmp dx, ax
  jnz .skip_rset
  mov edx, 0x0
.skip_rset:
  jmp .loop

.done:
  ret

decrypt:
  mov ecx, 0x0
  mov edx, 0x0
  mov si, buffer

.loop:
  lodsb

  mov bl, byte [passwd+edx]
  xor al, bl
  mov byte [buffer+ecx], al
  cmp al, 0x0
  jz .done

  inc ecx
  inc edx
  mov ax, word [plen]
  cmp dx, ax
  jnz .skip_rset
  mov edx, 0x0
.skip_rset:
  jmp .loop

.done:
  ret

; data
sect    db 0
dlen    dw 0
plen    dw 0
passwd  times 32 db 0
buffer  times 512 db 0

msgact  db 13,10,'cryptoFloppy v0.0.2 (2015-01-16) by dRbiG',13,10
        db 'Code at: https://github.com/drbig/cryptofloppy',13,10,10
        db 'Actions:   F1 - encrypt   F2 - decrypt   F3 - reboot',13,10,0
msgenc  db 13,10,'Enter the message you want to encrypt:',13,10,10,0
msgpss  db 13,10,'Enter secret password: ',0
msgsct  db 13,10,'        Select sector: ',0
msgwrk  db 13,10,10,'Working...',0
msgnl   db 13,10,0
msgferr db ' floppy error...',0
msgfok  db ' done.',13,10,10,0
msgstr  db 'START OF MESSAGE',13,10,0
msgend  db 13,10,'END OF MESSAGE',0

; pad the full-sector lengths, so that when we go over
; will know we need to update the number here and the
; number of sectors loaded in loader.asm
        times 1536-($-$$) db 0
