# cryptoFloppy [![Build Status](https://travis-ci.org/drbig/cryptofloppy.svg?branch=master)](https://travis-ci.org/drbig/cryptofloppy)

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
 - Anyone up for the challenge of writing a modern cipher for x86 ~~protected~~ real mode? :) (yeah, I'm new here)
 - UI can always use more love
 - People actually knowing what they doing are welcome to improve the code in terms of performance, readability and general best practices
 - I've tried to comment the code

#### Building and testing

For building on Unix-like systems you'll need NASM, dd and make. There is make target for testing for which you'll need QEMU - of course you can test on real hardware too.

Example build and test session:

    $ make clean floppy.img emu

This will clean the bin files, assemble the sources, create a zero-filled file (space for saving the messages), bundle up the floppy image and run it via `qemu-system-i386`.

You should obviously always test your image in an emulator *before even thinking about* trying it on a real hardware, as at this level the code may wipe out your harddrives, produce seizure-inducing video and fax your mother a nasty letter. Though most probably bad code will just hang/reboot the machine.

For those brave enough and with an actual vintage working floppy drive writing the image to a real floppy diskette is just (adjust the device path if needed):

    $ dd if=floppy.img of=/dev/fd0

#### Contributing

Fork the repo, hack away and remember to share back by making a Pull Request. All skill levels welcome. Feature ideas short-list:

 - Better UI (and there is a lot under this one)
   - Proper new-line handling when writing the message
   - Cursor keys for editing
   - Character left counter
   - Password confirmation
   - Write confirmation
   - ...
 - ~~Work from any drive (not only A:)~~
 - Read and write more than just 9 sectors
 - Pad messages with random bytes to fill the whole sector

Feel free to add issues with ideas/concerns etc.

If you're a seasoned x86 assembly hacker you may go over the code and apply best practices and optimisations (with comments, so we can learn). Or if you're looking for a challenge - port some [real crypto](http://en.wikipedia.org/wiki/Block_cipher#Blowfish).

#### Learning corner

Links to readings I found useful and/or interesting:

 - [Bootloader introduction](http://www.nondot.org/sabre/os/files/Booting/nasmBoot.txt)
 - [Full bootloader code](http://www.websofia.com/2013/10/writing-your-own-toy-operating-system-first-and-second-stage-bootloaders-together/)
 - [BIOS interrupts](http://stanislavs.org/helppc/idx_interrupt.html)
 - [Agner Fog's manuals](http://www.agner.org/optimize/)
 - [Ciphers for protected mode](http://asmaes.sourceforge.net/)

#### Licensing

Seriously? Standard two-clause BSD license, see LICENSE.txt for details.

Copyright (c) 2015 Piotr S. Staszewski
