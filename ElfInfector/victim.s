
.data
message:	
.string "Oh, no! Why me?!\n"
endstring=.-message

.global _start

_start:  
  //call message
  movl	$endstring, %edx
  movl	$message, %ecx
  xorl	%ebx, %ebx
  movl	$0x4, %eax
  int	$0x80

  //exit
  movl	$0x1, %eax
  xorl	%ebx, %ebx
  int	$0x80