floppy.img: zero.img loader.asm main.asm
	nasm loader.asm -o loader.bin
	nasm main.asm -o main.bin
	cat loader.bin main.bin zero.img > floppy.img

zero.img:
	dd if=/dev/zero of=zero.img bs=512 count=9

clean:
	rm -f *.bin floppy.img

emu:
	qemu-system-i386 -fda floppy.img -boot a

.PHONY: clean emu
