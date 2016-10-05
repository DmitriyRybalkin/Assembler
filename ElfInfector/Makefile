all_progs: vir.o victim.o 
	ld -m elf_i386 -s vir.o -o vir
	ld -m elf_i386 -s victim.o -o victim
vir.o: vir.s
	as --32 -s vir.s -o vir.o
victim.o: victim.s
	as --32 -s victim.s -o victim.o
clean:
	rm *.o
	rm victim
	rm vir
	rm infectvictim