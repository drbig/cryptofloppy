# cryptoFloppy

![The Secret Floppy](https://raw.github.com/drbig/cryptofloppy/master/cryptofloppy.jpg)

*x86 bare-metal password-protected notepad on a single floppy*

## Features

 - All you need is an i386 personal computer with a floppy drive
 - No Operating System required
 - Encrypt and decrypt up to *9* 512-character long messages
 - All data is stored on that single floppy
 - Perfect for dead-drops
 - *Advanced* encryption will protect your secrets
 - Simple interface, no manual required

![Super Secret UI](https://raw.github.com/drbig/cryptofloppy/master/ui.gif)

## And seriously

I wanted to try out writing something low-level in Assembly for x86. I thought writing a bootloader would be a nice exercise, but after I've written the first stage I had this idea for something more *fun*. Hence the cryptoFloppy.

TL;DR:

 - This is a for-fun project
 - It actually works - tested on a real computer (I'm that brave)
 - The 'encryption' for now is a simple XOR
 - I'd happily include a proper cipher, there is still *plenty* of space left
 - Anyone up for the challenge of writing a modern cipher for x86 protected mode? :)
 - UI can always use more love
 - People actually knowing what they doing are welcome to improve the code in terms of performance, readability and general best practices
 - I've tried to comment the code

#### Building and testing

For building on Unix-like systems you'll need NASM, dd and make. There is make target for testing for which you'll need QEMU - of course you can test on real hardware too.

Example build and test session:

    $ make clean floppy.img emu

This will clean the bin files, assemble the sources, create a zero-filled file (space for saving the messages), bundle up the floppy image and run it via `qemu-system-i386`.

Writing the image to a real floppy is just (adjust the floppy drive device as needed):

    $ dd if=floppy.img of=/dev/fd0

This may also work on a USB thumb drive, but I haven't tested it.

#### Licensing

Seriously? Standard two-clause BSD license, see LICENSE.txt for details.

Copyright (c) 2015 Piotr S. Staszewski
