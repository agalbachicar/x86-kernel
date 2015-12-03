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

1.- memory_map.txt: contiene la descripcion del mapa de memoria de la aplicacion

2.- init16.asm: contiene las inicializaciones de modo real

3.- init32.asm: inicializaciones de modo protegido.

4.- exception.asm: contiene el codigo que permite cargar los handlers de excepciones y el desarrollo de los mismos

5.- interruption.asm:  contiene el codigo que permite cargar los handlers de interrupciones y algunos desarrollos

6.- fifo.asm y fifo.inc: api que permite manejar una fifo.

7.- keyboard.asm y keyboard.inc: api que permite manejar el teclado.

8.- numeric.asm: api de uso matematico.

9.- pagination.asm y pagination.inc: contiene el codigo encargado de crear las tablas de paginacion en la inicializaciones

10.- sys_tables.asm: contiene la GDT, IDT y demás descritores principales de control de memoria y de programa.

11.- system.asm: todo lo relativo al Kernel.

12.- tasks.asm: codigo y memoria de las tareas.

13.- tss.inc: contiene la descripcion de la estructura de la tss.

14.- video.asm y video.inc: api para el control de la memoria de video.

15.- main32.asm: codigo de aplicacion principal. En este ejercicio aun no se lo ha utilizado.


----------------------------------------------------------------------------------------------------------------------------------------------------------

# System Calls

  1.- Para crear una system call, escribir el código de la misma. Definir un ID de SYSCALL en system.inc y modificar el maximo.
  2.- Ir a la función systemLoadSysCalls y agregar en la posición correspondiente (segun el ID colocado que debe ser consecutivo) la etiqueta del inicio.
  3.- El wrapper debe ser de la forma:

      wrapper:      
	  mov 	eax, SYSTEM_API_SYSCALL_ID
	  int 	0x80
	  ret
----------------------------------------------------------------------------------------------------------------------------------------------------------

# Tarea inicial

La tarea inicial carga algunas cosas del kernel y luego hace un hlt - jmp para reducir el consumo de la cpu en caso de tener tareas que no utilicen el 
espacio de procesamiento. Siempre debe estar con prioridad 1

----------------------------------------------------------------------------------------------------------------------------------------------------------