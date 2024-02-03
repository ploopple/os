CFLAGS = \
	-pedantic \
	-fno-builtin \
	-nostdlib \
	-o2 \
	-g \
	-ffreestanding \
	-Wall \
	-Wextra \
	-Werror \
	-m32 \
	-fno-exceptions \
	-fno-leading-underscore \
	-c 

.PHONY: all clean build run debug

all: clean build run

clean:
	rm -rf build/*

build:
	x86_64-elf-as -g --32 src/kernel/arch/x86/boot.s -o build/boot.o
	x86_64-elf-as -g --32 src/kernel/arch/x86/crti.s -o build/crti.o
	x86_64-elf-as -g --32 src/kernel/arch/x86/crtn.s -o build/crtn.o
	x86_64-elf-gcc $(CFLAGS) src/kernel/main.c -o build/kernel.o
	x86_64-elf-ld -g -T src/kernel/arch/x86/linker.ld -m elf_i386 -o build/os build/boot.o build/kernel.o build/crti.o build/crtn.o 

run: build/os
	qemu-system-x86_64 -kernel build/os

debug: build/os
	qemu-system-x86_64 -s -S -kernel build/os