
BUILDMODE ?= debug

CC := x86_64-elf-gcc

ZIGMAIN := kernel/oriole.zig
ZIGSRC := $(shell find kernel -name '*.zig')
ZIGLIB := obj/liboriole.a

ASMSRC := $(shell find asm -name '*.asm')
ASMOBJ := $(patsubst %.asm,%.o,$(ASMSRC))

.PHONY: all clean test

all: oriole.iso

%.o: %.asm
	nasm -felf64 -o $@ $<

$(ZIGLIB): $(ZIGSRC)
	zig build-lib $(ZIGMAIN) --output-dir obj -target x86_64-freestanding

oriole.elf: $(ASMOBJ) $(ZIGLIB)
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
