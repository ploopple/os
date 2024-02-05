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

.PHONY: all clean build r d docker-build docker-run lldb

all: clean build

clean:
	rm -rf build/*

build:
	as -g --32 src/kernel/arch/x86/boot.s -o build/boot.o
	as -g --32 src/kernel/arch/x86/crti.s -o build/crti.o
	as -g --32 src/kernel/arch/x86/crtn.s -o build/crtn.o
	gcc $(CFLAGS) src/kernel/main.c -o build/kernel.o
	ld -T src/kernel/arch/x86/linker.ld -m elf_i386 -o build/os build/boot.o build/kernel.o build/crti.o build/crtn.o 

r: build/os
	qemu-system-i386 -kernel build/os

d: build/os
	qemu-system-i386 -s -S -kernel build/os

docker-build: Dockerfile
	docker build -t os .

docker-run: Dockerfile
	docker run --cap-add=SYS_PTRACE  -it -v .:/os os

gdb: build/os
	gdb build/os -ex "target remote host.docker.internal:1234"
