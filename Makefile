floppy.bin: loader.asm main.asm
	nasm loader.asm -o loader.bin
	nasm main.asm -o main.bin
	cat loader.bin main.bin > floppy.bin

clean:
	rm *.bin

emu:
	qemu-system-i386 -fda floppy.bin -boot a

.PHONY: clean emu
