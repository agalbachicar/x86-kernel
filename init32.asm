;#########################################################################
;
;@file		init32.asm
;@brief		Este archivo contiene la inicializacion de 32 bits del sistema
;	    	Intel x86 compatible en 16 bit. 
;@author	Agustin Alba Chicar
;@date		Septiembre, 2015
;@details	Este archivo incorpora el binario generado por init16.bin.
;		En dicho archivo se pasa de modo real a protegido y en 
;		el inicio del codigo despues de la inclusión ya estamos en modo
;		protegido. Lo siguiente a hacer seria colocar la ldt e idt a gusto
;		y comenzar con el programa normalmente.
;#########################################################################

%include		"system.inc"

GLOBAL			Entry
GLOBAL			start


;Sibolos de interrupciones
EXTERN		interruptLoadHandlers
EXTERN		interrruptLoadKeyboardCallback
;Simbolos de fifo
EXTERN		fifoInit
EXTERN		fifoPush
EXTERN		fifoPop
;Simbolos del driver de teclado
EXTERN		keyboardInitFIFO
EXTERN		keyboardRead
EXTERN		keyboardISRHandler
EXTERN		keyboardGetChar

;Símbolos del linker script
EXTERN			__reset_vector

EXTERN			__init32_VMA_start
EXTERN			__init32_LMA_init
EXTERN			__init32_LMA_end
EXTERN			_init32_size

EXTERN			__sys_tables_VMA_start
EXTERN			__sys_tables_LMA_init
EXTERN			__sys_tables_LMA_end
EXTERN			_sys_tables_size

EXTERN			__pagination_VMA_start
EXTERN			__pagination_LMA_init
EXTERN			__pagination_LMA_end
EXTERN			_pagination_size

EXTERN			__stack_init
EXTERN			_stack_size

EXTERN			__main32_VMA_start
EXTERN			__main32_LMA_init
EXTERN			__main32_LMA_end
EXTERN			_main32_size

EXTERN			__initialized_data_VMA_start
EXTERN			__initialized_data_LMA_init
EXTERN			__initialized_data_LMA_end
EXTERN			_initialized_data_LMA_size

EXTERN			__not_initialized_data_VMA_start
EXTERN			__not_initialized_data_LMA_init
EXTERN			__not_initialized_data_LMA_end
EXTERN			_not_initialized_data_LMA_size

EXTERN 			__library_VMA_start
EXTERN 			__library_LMA_init
EXTERN			__library_LMA_end
EXTERN			_library_LMA_size

EXTERN 			__shared_VMA_start
EXTERN 			__shared_LMA_init
EXTERN			__shared_LMA_end
EXTERN			_shared_LMA_size

EXTERN			__task1_code_start
EXTERN			__task1_code_LMA_init
EXTERN			__task1_code_LMA_end
EXTERN			_task1_code_LMA_size

EXTERN			__task1_initialized_data_start
EXTERN			__task1_initialized_data_LMA_init
EXTERN			__task1_initialized_data_LMA_end
EXTERN			_task1_initialized_data_LMA_size

EXTERN			__task1_not_initialized_data_start
EXTERN			__task1_not_initialized_data_LMA_init
EXTERN			__task1_not_initialized_data_LMA_end
EXTERN			_task1_not_initialized_data_LMA_size

EXTERN			__task2_code_start
EXTERN			__task2_code_LMA_init
EXTERN			__task2_code_LMA_end
EXTERN			_task2_code_LMA_size

EXTERN			__task2_initialized_data_start
EXTERN			__task2_initialized_data_LMA_init
EXTERN			__task2_initialized_data_LMA_end
EXTERN			_task2_initialized_data_LMA_size

EXTERN			__task2_not_initialized_data_start
EXTERN			__task2_not_initialized_data_LMA_init
EXTERN			__task2_not_initialized_data_LMA_end
EXTERN			_task2_not_initialized_data_LMA_size

EXTERN			__task3_code_start
EXTERN			__task3_code_LMA_init
EXTERN			__task3_code_LMA_end
EXTERN			_task3_code_LMA_size

EXTERN			__task3_initialized_data_start
EXTERN			__task3_initialized_data_LMA_init
EXTERN			__task3_initialized_data_LMA_end
EXTERN			_task3_initialized_data_LMA_size

EXTERN			__task3_not_initialized_data_start
EXTERN			__task3_not_initialized_data_LMA_init
EXTERN			__task3_not_initialized_data_LMA_end
EXTERN			_task3_not_initialized_data_LMA_size


EXTERN			__task4_code_start
EXTERN			__task4_code_LMA_init
EXTERN			__task4_code_LMA_end
EXTERN			_task4_code_LMA_size

EXTERN			__task4_initialized_data_start
EXTERN			__task4_initialized_data_LMA_init
EXTERN			__task4_initialized_data_LMA_end
EXTERN			_task4_initialized_data_LMA_size

EXTERN			__task4_not_initialized_data_start
EXTERN			__task4_not_initialized_data_LMA_init
EXTERN			__task4_not_initialized_data_LMA_end
EXTERN			_task4_not_initialized_data_LMA_size

EXTERN			__task1_user_stack_init
EXTERN			__task1_kernel_stack_init
EXTERN			_task1_user_stack_size
EXTERN			_task1_kernel_stack_size

EXTERN			__task2_user_stack_init
EXTERN			__task2_kernel_stack_init
EXTERN			_task2_user_stack_size
EXTERN			_task2_kernel_stack_size

EXTERN			__task3_user_stack_init
EXTERN			__task3_kernel_stack_init
EXTERN			_task3_user_stack_size
EXTERN			_task3_kernel_stack_size

EXTERN			__task4_user_stack_init
EXTERN			__task4_kernel_stack_init
EXTERN			_task4_user_stack_size
EXTERN			_task4_kernel_stack_size

EXTERN			__scheduler_stack_init
EXTERN			_scheduler_stack_size

;Simbolos de sys_tables
EXTERN			GDT32
EXTERN			GDTR32
EXTERN			nullSelector
EXTERN			codeKernelSelector
EXTERN			codeUserSelector
EXTERN			dataKernelSelector
EXTERN			dataUserSelector
EXTERN			tssInitSelector
EXTERN			tssTask1Selector
EXTERN			tssTask2Selector
EXTERN			tssTask3Selector
EXTERN			tssTask4Selector
EXTERN			callKernelGateSelector

EXTERN			IDT
EXTERN			IDTR

EXTERN			IDT_keyPressed

EXTERN			PDPT
EXTERN			pdptKernel
EXTERN			pdptTask1
EXTERN			pdptTask2
EXTERN			pdptTask3
EXTERN			pdptTask4

EXTERN			tssInit
EXTERN			tssTask1
EXTERN			tssTask2
EXTERN			tssTask3
EXTERN			tssTask4

;Simbolos del main32
EXTERN			main32Start

;Simbolos de pagination
EXTERN			int32CreatePaginationTables
EXTERN			init32CreateTasksPaginationTables

;Simbolos de system
EXTERN			systemConfigure1MSTick
EXTERN			systemLoadTickHandler
EXTERN			systemLoadIntGateHandler
EXTERN			systemInitKernel


EXTERN			systemTasks

;Simbolos de tasks
EXTERN			task1Code
EXTERN			task2Code
EXTERN			task3Code
EXTERN			task4Code

;Simbolos de exception 
EXTERN			exceptionLoadHandlers

;Simbolos de interruption
EXTERN			interruptLoadHandlers

EXTERN			systemTest
;********************************************************************************
; Defines
;********************************************************************************
%define		TASK_1_PRIORITY		2
%define		TASK_2_PRIORITY		2
%define		TASK_3_PRIORITY		2
%define		TASK_4_PRIORITY		9
%define		TASK_IDLE_PRIORITY	1

;********************************************************************************
; Seccion de codigo de inicializacion
;********************************************************************************
USE16
SECTION 	.reset_vector					; Reset vector del procesador

Entry:								; Punto de entrada definido en el linker
	jmp 	dword start					; Punto de entrada de mi BIOS
	times   16-($-Entry) db 0				; Relleno hasta el final de la ROM

;********************************************************************************
; Seccion de codigo de inicializacion de 16 bit
;********************************************************************************
USE32
SECTION 	.init16
;********************************************************************************
; Punto de entrada de la aplicacion tras el reset vector
;********************************************************************************
start:			

	INCBIN "debug/init16.bin"					; Binario de 16 bits
	mov 	eax, __init32_VMA_start					; Genero un salto absoluto para poder pasar a la seccion init32
	jmp	eax
	
;********************************************************************************
; Seccion de codigo de inicializacion de 32 bit
;********************************************************************************	
USE32
SECTION		.init32

start32:
init32MoveLMAToVMA:
; Me encargo de mover desde la LMA a la VMA la memoria, sección a sección.
; En el caso de lo que es datos no inicializados los dejamos en 0x00
	call	moveLMAToVMA

init32LoadDescriptors:
; Cargamos los descriptores de la GDT con las entradas de las TSS.
; Luego, cargamos las TSSs en sí. Cargamos los Handlers de las interrupciones y excepcciones
; de la IDT.
	call	loadGlobalDescriptors				; Cargo los descriptores de la GDT
	call	exceptionLoadHandlers				; Cargo los handlers de excepciones
	call	interruptLoadHandlers				; Cargo los handlers de interupciones	  
	
	call	systemConfigure1MSTick				; Configuro el tick de 1ms
	call	systemLoadTickHandler				; Configuro el tick handler
	call	systemLoadIntGateHandler			; Configuro el int gate handler
	  
init32LoadNewGDT:
; Cargamos la nueva GDT para lo que es código de modo protegido	
	lgdt	[GDTR32]
	
init32LoadNewIDT:
; Cargamos la IDT para lo que es código de modo protegido
	lidt	[IDTR]	
	
init32InitPIC:
; Inicializamos el controlador de interrupciones y generamos un salto intersegmento para
; limpiar el prefetch queue del procesador tras haber cargado una nueva GDT
	mov 	bx, 0x2028					; Base de los PICS
	call 	init32PIC					; Inicializo controlador de interrupciones
	mov 	al, 0xFC 					; Esto es habilito teclado y timer tick. Todo lo demas esta deshabilitado. Cada bit es una entrada de interrupcion.
	out 	0x21, al					; Mando al puerto la máscara de la interrupción
	jmp 	codeKernelSelector:init32Continue	

init32Continue:
; Destino tras el salto intersegmento.
init32InitRegisters:
; Cargamos los registros de proposito general	
	mov 	ax, dataKernelSelector
	mov 	ss, ax						; Inicializo selector de pila
	mov 	ds, ax						; Inicializo selector de pila
	mov 	es, ax						; Inicializo selector de pila
	mov 	esp, __scheduler_stack_init			; Inicializo la pila
	add	esp, _scheduler_stack_size
	
	call	loadTSSStructures				; Cargo las estructuras de las TSS
	
	mov 	eax, tssInitSelector				; Cargo la direccion de la TSS inicial
	ltr 	ax						; Cargo el task register
	
init32PAEPagination:	
;Realizo la inicializacion de paginacion	
	call	int32CreatePaginationTables
	call	init32CreateTasksPaginationTables
	
	mov 	eax, cr4					;Muevo a eax el registro CR4
	or	eax, 0x20					;Coloco el bit PAE a 1
	mov 	cr4, eax					;Mando el dato a CR4
	mov 	eax, pdptKernel					;Cargo el puntero
	mov 	cr3, eax					;Lo paso a CR3
	mov 	eax, cr0
	or	eax, 0x80000000 
	mov 	cr0, eax
	
init32Keyboard:
	push	DWORD keyboardISRHandler
	call 	interrruptLoadKeyboardCallback			; Cargo el callback del handler de teclado
	add	esp, 4
	call	keyboardInitFIFO				; Inicializo la FIFO del teclado
	
	call	systemInitKernel				; Llamo a que el Kernel se inicialice, no debiera retornar.
init32Idle:
;No debiera volver a este bloque de codigo
	
	nop
	jmp	init32Idle

;********************************************************************************
;@fn		init32PIC()
;@brief		Inicializacion del controlador de interrupciones
;@details	Corre la base de los tipos de interrupción de ambos PICs 8259A 
;		de la PC a los 8 tipos consecutivos a partir de los valores base 
;		que recibe en BH para el PIC Nº1 y BL para el PIC Nº2.
;		A su retorno las Interrupciones de ambos PICs están deshabilitadas.
;********************************************************************************		
init32PIC:
				; Inicialización PIC Nº1
				; ICW1
	mov	al, 11h         ; IRQs activas x flanco, cascada, y ICW4
	out     20h, al  
				; ICW2
	mov     al, bh          ; El PIC Nº1 arranca en INT tipo (BH)
	out     21h, al
				; ICW3
	mov     al, 04h         ; PIC1 Master, Slave ingresa Int.x IRQ2
	out     21h, al
				; ICW4
	mov     al, 01h         ; Modo 8086
	out     21h, al
				; Antes de inicializar el PIC Nº2, deshabilitamos 
				; las Interrupciones del PIC1
	mov     al, 0FFh
	out     21h, al
				; Ahora inicializamos el PIC Nº2
				; ICW1
	mov     al, 11h        	; IRQs activas x flanco,cascada, y ICW4
	out     0A0h, al  
				; ICW2
	mov    	al, bl          ; El PIC Nº2 arranca en INT tipo (BL)
	out     0A1h, al
				; ICW3
	mov     al, 02h         ; PIC2 Slave, ingresa Int x IRQ2
	out     0A1h, al
				; ICW4
	mov     al, 01h         ; Modo 8086
	out     0A1h, al
				; Enmascaramos el resto de las Interrupciones 
				; (las del PIC Nº2)
	mov     al, 0FFh
	out     0A1h, al
	ret

;********************************************************************************
;@fn		moveLMAToVMA()
;@brief		Se encarga de mover todas las secciones de código y de datos desde
;		la LMA a la VMA final
;********************************************************************************		
moveLMAToVMA:
	mov 	esi, __sys_tables_LMA_init
	mov 	edi, __sys_tables_VMA_start
	mov	ecx, __sys_tables_LMA_end
	sub	ecx, __sys_tables_LMA_init				; Calculo tamaño
	rep	movsb
	
; Limpio las tablas de paginacion
	mov     ax, 0x00
	mov	edi, 0x101000
	mov	ecx, 0x5000
clearPaginationTables:
	stosb
	loop 	clearPaginationTables	  
	
; Muevo las memoria de la LMA a la VMA
	mov 	esi, __pagination_LMA_init
	mov 	edi, __pagination_VMA_start
	mov	ecx, __pagination_LMA_end
	sub	ecx, __pagination_LMA_init			; Calculo tamaño
	rep	movsb	
	
	mov 	esi, __main32_LMA_init
	mov 	edi, __main32_VMA_start
	mov	ecx, __main32_LMA_end
	sub	ecx, __main32_LMA_init				; Calculo tamaño
	rep	movsb			

	mov 	esi, __initialized_data_LMA_init
	mov 	edi, __initialized_data_VMA_start
	mov	ecx, __initialized_data_LMA_end
	sub	ecx, __initialized_data_LMA_init		; Calculo tamaño
	rep	movsb	
	
	mov 	esi, __library_LMA_init
	mov 	edi, __library_VMA_start
	mov	ecx, __library_LMA_end
	sub	ecx, __library_LMA_init				; Calculo tamaño
	rep	movsb		

	mov 	esi, __shared_LMA_init
	mov 	edi, __shared_VMA_start
	mov	ecx, __shared_LMA_end
	sub	ecx, __shared_LMA_init				; Calculo tamaño
	rep	movsb	
	
	mov 	ax, 0x00
	mov 	edi, __not_initialized_data_VMA_start
	mov	ecx, __not_initialized_data_LMA_end
	sub	ecx, __initialized_data_LMA_init
	rep	stosb
	; Tarea 1 -------------------------------------------------------------
	mov 	esi, __task1_code_LMA_init
	mov 	edi, __task1_code_start
	mov	ecx, __task1_code_LMA_end
	sub	ecx, __task1_code_LMA_init			; Calculo tamaño
	rep	movsb

	mov 	esi, __task1_initialized_data_LMA_init
	mov 	edi, __task1_initialized_data_start
	mov	ecx, __task1_initialized_data_LMA_end
	sub	ecx, __task1_initialized_data_LMA_init		; Calculo tamaño
	rep	movsb		

	mov 	ax, 0x00
	mov 	edi, __task1_not_initialized_data_start
	mov	ecx, __task1_not_initialized_data_LMA_end
	sub	ecx, __task1_not_initialized_data_LMA_init
	rep	stosb
	; Tarea 2 -------------------------------------------------------------
	mov 	esi, __task2_code_LMA_init
	mov 	edi, __task2_code_start
	mov	ecx, __task2_code_LMA_end
	sub	ecx, __task2_code_LMA_init			; Calculo tamaño
	rep	movsb

	mov 	esi, __task2_initialized_data_LMA_init
	mov 	edi, __task2_initialized_data_start
	mov	ecx, __task2_initialized_data_LMA_end
	sub	ecx, __task2_initialized_data_LMA_init		; Calculo tamaño
	rep	movsb		
	
	mov 	ax, 0x00
	mov 	edi, __task2_not_initialized_data_start
	mov	ecx, __task2_not_initialized_data_LMA_end
	sub	ecx, __task2_not_initialized_data_LMA_init
	rep	stosb
	; Tarea 3 -------------------------------------------------------------
	mov 	esi, __task3_code_LMA_init
	mov 	edi, __task3_code_start
	mov	ecx, __task3_code_LMA_end
	sub	ecx, __task3_code_LMA_init			; Calculo tamaño
	rep	movsb

	mov 	esi, __task3_initialized_data_LMA_init
	mov 	edi, __task3_initialized_data_start
	mov	ecx, __task3_initialized_data_LMA_end
	sub	ecx, __task3_initialized_data_LMA_init		; Calculo tamaño
	rep	movsb		
	
	mov 	ax, 0x00
	mov 	edi, __task3_not_initialized_data_start
	mov	ecx, __task3_not_initialized_data_LMA_end
	sub	ecx, __task3_not_initialized_data_LMA_init
	rep	stosb
	; Tarea 4 -------------------------------------------------------------
	mov 	esi, __task4_code_LMA_init
	mov 	edi, __task4_code_start
	mov	ecx, __task4_code_LMA_end
	sub	ecx, __task4_code_LMA_init			; Calculo tamaño
	rep	movsb

	mov 	esi, __task4_initialized_data_LMA_init
	mov 	edi, __task4_initialized_data_start
	mov	ecx, __task4_initialized_data_LMA_end
	sub	ecx, __task4_initialized_data_LMA_init		; Calculo tamaño
	rep	movsb		
	
	mov 	ax, 0x00
	mov 	edi, __task4_not_initialized_data_start
	mov	ecx, __task4_not_initialized_data_LMA_end
	sub	ecx, __task4_not_initialized_data_LMA_init
	rep	stosb
		
	ret

;********************************************************************************
;@fn		loadGlobalDescriptors()
;@brief		Se encarga de cargar los descriptores de la GDT
;********************************************************************************			
loadGlobalDescriptors:
	mov 	eax, tssInit
	mov 	ebx, GDT32
	add	ebx, tssInitSelector
	add	ebx, 2
	mov 	[ebx], ax
	shr 	eax, 16
	mov 	ebx, GDT32
	add	ebx, tssInitSelector
	add	ebx, 4
	mov 	[ebx], al
	mov 	ebx, GDT32
	add	ebx, tssInitSelector
	add	ebx, 7
	mov 	[ebx], ah
	ret

;********************************************************************************
;@fn		loadTSSStructures()
;@brief		Se encarga de cargar las estructuras de las diferentes TSS y contextos
;@details	Primero coloca las TSS a 0 en todos los casos, luego carga la de
;		cada una de las tareas y finaliza con el scheduler
;********************************************************************************			
loadTSSStructures:
	mov 	ebp, esp
	
	;********************************************************************************
	; Inicializo las estructuras de la tss a 0
	mov 	eax, 0x00
	mov 	edi, tssInit
	mov	ecx, tssType.size
	rep	stosb
	;********************************************************************************
	; Cargo todo a 0 en las estructuras de las tareas
	mov 	eax, 0x00
	mov 	edi, systemTasks
	mov	ecx, taskType.size*TASKS_NUMBER
	rep	stosb
	;********************************************************************************
	; Cargo la tss de la tarea inicial
	mov 	esi, tssInit
	mov 	eax, __scheduler_stack_init
	add	eax, _scheduler_stack_size		
	mov 	DWORD [esi + tssType.esp0], eax
	mov 	DWORD [esi + tssType.ss0], dataKernelSelector
	mov	DWORD [esi + tssType.cr3], pdptKernel
	mov 	DWORD [esi + tssType.eip], systemInitKernel
	mov 	DWORD [esi + tssType.eflags], 0x200
	mov 	DWORD [esi + tssType.es], dataUserSelector + 3
	mov 	DWORD [esi + tssType.cs], codeUserSelector + 3
	mov 	DWORD [esi + tssType.ss], dataUserSelector + 3
	mov 	DWORD [esi + tssType.ds], dataUserSelector + 3
	mov 	DWORD [esi + tssType.fs], dataUserSelector + 3
	mov 	DWORD [esi + tssType.gs], dataUserSelector + 3
	;********************************************************************************
	; Cargo los datos de la tarea 1
	mov 	esi, DWORD systemTasks
	mov 	[esi + taskType.priority], DWORD TASK_1_PRIORITY
	mov 	[esi + taskType.context + taskContextType.cr3], DWORD pdptTask1
	mov 	[esi + taskType.context + taskContextType.es], DWORD dataUserSelector + 3
	mov 	[esi + taskType.context + taskContextType.ds], DWORD dataUserSelector + 3
	mov 	[esi + taskType.context + taskContextType.fs], DWORD dataUserSelector + 3
	mov 	[esi + taskType.context + taskContextType.gs], DWORD dataUserSelector + 3	
	mov 	[esi + taskType.context + taskContextType.ss0], DWORD dataKernelSelector
	mov 	esp, __task1_kernel_stack_init
	add	esp, _task1_kernel_stack_size
	mov 	[esi + taskType.context + taskContextType.topOfStack0], esp
	mov 	ax, dataKernelSelector
	mov 	ss, ax
	push 	DWORD (dataUserSelector + 3)	;SS3
	mov 	eax, __task1_user_stack_init
	add 	eax, _task1_user_stack_size
	push 	eax				;ESP3
	push 	DWORD 0x200			;EFLAGS
	push 	DWORD (codeUserSelector + 3)	;CS
	push 	DWORD task1Code			;EIP
	mov 	[esi + taskType.context + taskContextType.esp0], esp
	;********************************************************************************
	; Cargo los datos de la tarea 2	
	add	esi, taskType.size
	mov 	[esi + taskType.priority], DWORD TASK_2_PRIORITY
	mov 	[esi + taskType.context + taskContextType.cr3], DWORD pdptTask2
	mov 	[esi + taskType.context + taskContextType.es], DWORD dataUserSelector + 3
	mov 	[esi + taskType.context + taskContextType.ds], DWORD dataUserSelector + 3
	mov 	[esi + taskType.context + taskContextType.fs], DWORD dataUserSelector + 3
	mov 	[esi + taskType.context + taskContextType.gs], DWORD dataUserSelector + 3	
	mov 	[esi + taskType.context + taskContextType.ss0], DWORD dataKernelSelector
	mov 	esp, __task2_kernel_stack_init
	add	esp, _task2_kernel_stack_size
	mov 	[esi + taskType.context + taskContextType.topOfStack0], esp
	mov 	ax, dataKernelSelector
	mov 	ss, ax
	push 	DWORD (dataUserSelector + 3)	;SS3
	mov 	eax, __task2_user_stack_init
	add 	eax, _task2_user_stack_size
	push 	eax				;ESP3
	push 	DWORD 0x200			;EFLAGS
	push 	DWORD (codeUserSelector + 3)	;CS
	push 	DWORD task2Code			;EIP
	mov 	[esi + taskType.context + taskContextType.esp0], esp
	;********************************************************************************
	; Cargo los datos de la tarea 3
	add	esi, taskType.size
	mov 	[esi + taskType.priority], DWORD TASK_3_PRIORITY
	mov 	[esi + taskType.context + taskContextType.cr3], DWORD pdptTask3
	mov 	[esi + taskType.context + taskContextType.es], DWORD dataUserSelector + 3
	mov 	[esi + taskType.context + taskContextType.ds], DWORD dataUserSelector + 3
	mov 	[esi + taskType.context + taskContextType.fs], DWORD dataUserSelector + 3
	mov 	[esi + taskType.context + taskContextType.gs], DWORD dataUserSelector + 3
	mov 	[esi + taskType.context + taskContextType.ss0], DWORD dataKernelSelector
	mov 	esp, __task3_kernel_stack_init
	add	esp, _task3_kernel_stack_size
	mov 	[esi + taskType.context + taskContextType.topOfStack0], esp
	mov 	ax, dataKernelSelector
	mov 	ss, ax
	push 	DWORD (dataUserSelector + 3)	;SS3
	mov 	eax, __task3_user_stack_init
	add 	eax, _task3_user_stack_size
	push 	eax				;ESP3
	push 	DWORD 0x200			;EFLAGS
	push 	DWORD (codeUserSelector + 3)	;CS
	push 	DWORD task3Code			;EIP
	mov 	[esi + taskType.context + taskContextType.esp0], esp
	;********************************************************************************
	; Cargo los datos de la tarea 4
	add	esi, taskType.size
	mov 	[esi + taskType.priority], DWORD TASK_4_PRIORITY
	mov 	[esi + taskType.context + taskContextType.cr3], DWORD pdptTask4
	mov 	[esi + taskType.context + taskContextType.es], DWORD dataUserSelector + 3
	mov 	[esi + taskType.context + taskContextType.ds], DWORD dataUserSelector + 3
	mov 	[esi + taskType.context + taskContextType.fs], DWORD dataUserSelector + 3
	mov 	[esi + taskType.context + taskContextType.gs], DWORD dataUserSelector + 3
	mov 	[esi + taskType.context + taskContextType.ss0], DWORD dataKernelSelector
	mov 	esp, __task4_kernel_stack_init
	add	esp, _task4_kernel_stack_size
	mov 	[esi + taskType.context + taskContextType.topOfStack0], esp
	mov 	ax, dataKernelSelector
	mov 	ss, ax
	push 	DWORD (dataUserSelector + 3)	;SS3
	mov 	eax, __task4_user_stack_init
	add 	eax, _task4_user_stack_size
	push 	eax				;ESP3
	push 	DWORD 0x200			;EFLAGS
	push 	DWORD (codeUserSelector + 3)	;CS
	push 	DWORD task4Code			;EIP
	mov 	[esi + taskType.context + taskContextType.esp0], esp
	;********************************************************************************
	; Cargo los datos de la tarea 5 que no se utiliza	
	add	esi, taskType.size
	mov 	[esi + taskType.priority], DWORD TASK_IDLE_PRIORITY
	mov 	[esi + taskType.context + taskContextType.cr3], DWORD pdptKernel
	mov 	[esi + taskType.context + taskContextType.es], DWORD dataUserSelector
	mov 	[esi + taskType.context + taskContextType.ss0], DWORD dataUserSelector
	mov 	[esi + taskType.context + taskContextType.ds], DWORD dataUserSelector
	mov 	[esi + taskType.context + taskContextType.fs], DWORD dataUserSelector
	mov 	[esi + taskType.context + taskContextType.gs], DWORD dataUserSelector
	; Para el caso de la tarea inicial del Kernel voy a hacer un unico call por lo que la pila estara offseteada en 8!
	mov 	esp, __scheduler_stack_init
	add	esp, _scheduler_stack_size		
	sub 	esp, 4
	mov 	[esi + taskType.context + taskContextType.topOfStack0], esp
	;********************************************************************************
	
	;Restauro la pila
	mov 	esp, ebp

	ret
