; floppy sector 1

bits 16
org 0

  jmp 0x07c0:main

main:
  mov ax, cs
  mov ds, ax
  mov es, ax

  mov si, intro
  call print_string

flp_reset:          ; Reset the floppy drive
  mov ax, 0         ;
  mov dl, 0         ; Drive=0 (=A)
  int 0x13          ;
  jnc flp_read      ; ERROR => reset again

  mov si, msgferr
  call print_string
  jmp flp_reset

flp_read:
  mov ax, 0x1000    ; ES:BX = 1000:0000
  mov es, ax        ;
  mov bx, 0         ;
  
  mov ah, 2         ; Load disk data to ES:BX
  mov al, 2         ; Load 1 sectors
  mov ch, 0         ; Cylinder=0
  mov cl, 2         ; Sector=2
  mov dh, 0         ; Head=0
  mov dl, 0         ; Drive=0
  int 0x13          ; Read!
  jnc .read_ok      ; ERROR => Try again

  mov si, msgferr
  call print_string
  jmp flp_reset

.read_ok:
  mov si, msgfok
  call print_string

  mov ax, 0x1000    ; setup segments
  mov es, ax        ; for the second stage
  mov ds, ax

  jmp 0x1000:0      ; Jump to the program

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

; data
intro   db 13,10,'cryptoFloppy v0.0.1 (2015-01-13) by dRbiG',13,10
        db 'Code at: https://github.com/drbig/cryptofloppy',13,10
        db 13,10,'Loading main program...',0
msgferr db ' floppy error, not good...',0
msgfok  db ' done.',13,10,0


; pad and sign the boot sector
        times 510-($-$$) db 0
        dw 0xAA55
