NASM := nasm -f elf64 -l
LD := ld -s -o
SRC := printf

.PHONY: all clean

main:
	sudo $(NASM) $(SRC).lst $(SRC).asm
	sudo $(LD) $(SRC) $(SRC).o
