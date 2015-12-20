# What the hell this thing does?

Well, this is just a project for the Digital Techniques signature at Electronics Engineering in UTN FRBA, Argentina. This program initializes a x86 Intel compatible processor,
thanks to Dario Alpern for the code of the initialization, and then runs some API initialization for running a minimalistic kernel with five tasks. Some system calls are implemented,
pagination, keyboard handler and other features. I have to thank Diego Garcia for the code of the RTC too.

Enjoy it!

PS: I will translate the comments in code to English for better understanding of people and I will make a wiki for keeping things right.


# Tools

This code has been done with:

  - Bochs x86 Emulator 2.6.2
  - Kate: 3.8.4
  - NASM version 2.10.01 compiled on Jun 14 2012
  - GNU Make 3.81
  - Several cups of coffe
  - Time, effort and frustration
  - Google!

# Contenido de cada archivo:

  - memory_map.txt: it has a description of the application memory map.
  - init16.asm: it has the real mode initialization.
  - init32.asm: it has the protected mode initialization. 
  - exception.asm: it has some exception handlers and some application code to work with pagination and display some error messages.
  - interruption.asm: is has some exception handlers such as keyboard and tick.
  - fifo.asm y fifo.inc: a FIFO API.
  - keyboard.asm y keyboard.inc: a Keyboard API.
  - numeric.asm: some number handler API.
  - pagination.asm y pagination.inc: it has code to initialize the pagination structures of the involved tasks.
  - sys_tables.asm: it has the GDT and IDT description. It also containes some other descriptors for the application and memory control.
  - system.asm: all the Kernel.
  - tasks.asm: the tasks code and memory.
  - tss.inc: some defines and structure definitions.
  - video.asm y video.inc: video memory manager.
  - main32.asm: main app code. However it is not used right now.


----------------------------------------------------------------------------------------------------------------------------------------------------------

# System Calls

To create a system call follow these steps:
  * Write the system call code. Define an ID in the system.inc file and modify the maximum ID define
  * Modify the code of the function systemLoadSysCalls in system.asm and add in the correct position the label of the new implementation function.
  * Write a wrapper like this:
```asm
wrapper:      
	mov 	eax, SYSTEM_API_SYSCALL_ID
	int 	0x80
	ret
```	  
----------------------------------------------------------------------------------------------------------------------------------------------------------

# Initial task or Idle task

The idle task loads some kernel configurations and it just does a `hlt` and  `jmp $-1` to reduce the CPU power consumption when no other task has to use the processing time slice. It must be set with priority 1.

----------------------------------------------------------------------------------------------------------------------------------------------------------
