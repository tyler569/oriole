BUILDMODE ?= debug

CC := x86_64-elf-gcc

ZIGMAIN := kernel/main.zig
ZIGSRC := $(shell find kernel -name '*.zig')
ZIGLIB := obj/oriole.o

ASMSRC := $(shell find asm -name '*.asm')
ASMOBJ := $(patsubst %.asm,%.o,$(ASMSRC))
CSRC := $(shell find asm -name '*.c')
COBJ := $(patsubst %.c,%.o,$(CSRC))

OBJECTS := $(ASMOBJ) $(COBJ)

.PHONY: all clean test

all: oriole.iso

%.o: %.asm
	mkdir -p $(dir $@)
	nasm -felf64 -o $@ $<

%.o: %.c
	mkdir -p $(dir $@)
	x86_64-nightingale-gcc -o $@ -c $< -ffreestanding -Wall -Werror

$(ZIGLIB): $(ZIGSRC)
	mkdir -p $(dir $@)
	zig build-obj $(ZIGMAIN) -femit-bin=$@ -target x86_64-freestanding -mno-red-zone -mcmodel=kernel

oriole.elf: $(OBJECTS) $(ZIGLIB)
	ld -g -nostdlib -o $@ -T link.ld $^

oriole.iso: oriole.elf grub.cfg
	mkdir -p isodir/boot/grub
	cp grub.cfg isodir/boot/grub
	cp oriole.elf isodir/boot/
	grub2-mkrescue -o $@ isodir/
	rm -rf isodir

clean:
	rm -f asm/*.o
	rm -rf obj
	rm -f oriole.elf
	rm -f oriole.iso
