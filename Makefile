all: main

main : printf.o run_print.o
	gcc -no-pie run_print.o printf.o -o main

printf.o : printf.asm
	sudo nasm -f elf64 -g printf.asm -o printf.o

run_print.o : main.cpp
	gcc	-c main.cpp -o run_print.o

clear:
	rm *.o
