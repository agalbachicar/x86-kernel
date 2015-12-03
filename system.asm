;#########################################################################
;@file		system.asm
;@brief		Libreria para el manejo del sistema en general.
;	    	Intel x86 compatible en 32 bit. 
;@author	Agustin Alba Chicar
;@date		Octubre, 2015
;#########################################################################

;********************************************************************************
; Simbolos externos y globales
;********************************************************************************

%include	"system.inc"

;Simbolos de puertos
EXTERN 		portWrite
EXTERN 		portRead

;Simbolos de keyboard
EXTERN		keyboardGetChar

;Simbolos de sys_tables
EXTERN		dataKernelSelector
EXTERN		tssInitSelector

EXTERN		IDT
EXTERN		IDT_timer

EXTERN		tssInit

;Simbolos de video
EXTERN		videoClearScreen
EXTERN		videoPrint

;Simbolos de RTC
EXTERN		RTC_Service

GLOBAL		systemConfigure1MSTick
GLOBAL		systemGetTickCount
GLOBAL		systemInitKernel
GLOBAL		systemLoadTickHandler
GLOBAL		systemLoadIntGateHandler

GLOBAL		systemSleep
GLOBAL		systemEnableInterrupts
GLOBAL		systemDisableInterrupts

GLOBAL		systemTasks

;********************************************************************************
; Defines
;********************************************************************************

USE32


%define		PIC_EOI_VALUE		0x20
%define		PIC_EOI_PORT		0x20

%define		currentTaskIndex	ebp+8
%define		lastTaskId		ebp+8
%define		priorityLevel		ebp+12

;********************************************************************************
; Datos no inicializados
;********************************************************************************
SECTION		.bss

; Array de tareas 
systemTasks:			resb	taskType.size*TASKS_NUMBER
; Indice de prioridades
systemLastTaskIdPriority:	resd	TASK_INDEX_ARRAY_SIZE
; Vector de punteros a funcion de las system call
systemAPIHandlers:		resd	(SYSTEM_API_MAX+1)
;Estructura donde se mantiene el tiempo del sistema
systemTime:			resb	timeType.size*1
; Valor de retorno
systemReturnValue		resd	1

;********************************************************************************
; Datos inicializados
;********************************************************************************
SECTION		.data

systemTickCount		dd	0x00	; Contador de ticks

systemNewTaskOffset	dd 	0x00   ;Salto indirecto para cambiar de tarea.
systemNewTaskSelector	dw 	0x00

SECTION		.library

;********************************************************************************
;@fn		systemSleep(void)
;@brief		Duermo hasta que ocurra una interrupcion y retorno
;********************************************************************************	  
systemSleep:
	    hlt
	    ret
;********************************************************************************
;@fn		systemEnableInterrupts(void)
;@brief		Habilito las interrupciones
;********************************************************************************	  	    
systemEnableInterrupts:
	    sti
	    ret
;********************************************************************************
;@fn		systemDisableInterrupts(void)
;@brief		Deshabilito las interrupciones
;********************************************************************************	  	    	    
systemDisableInterrupts:
	    cli
	    ret	  

;********************************************************************************
;@fn		systemGetTickCount(void)
;@brief		Obtengo la cuenta de ticks
;@retval	systemTickCount
;********************************************************************************    
systemGetTickCount:
	    mov		eax, [systemTickCount]
	    ret

;********************************************************************************
;@fn		systemInitKernel(void)
;@brief		Genero las inicializaciones finales para que arranque el kernel y me mantengo
;		en la tarea inicial
;********************************************************************************    
systemInitKernel:
; Inicializo el vector de indice de tareas por prioridad
	mov	esi, systemLastTaskIdPriority
	mov	ecx, TASK_INDEX_ARRAY_SIZE
	mov	eax, 4
	mul	ecx
	add	esi, eax
systemInitKernelLoop:
	sub	esi, 4
	mov	[esi], DWORD TASKS_NUMBER
	loop	systemInitKernelLoop

	call	systemLoadSysCalls	; Cargo los punteros a funcion de las system calls
	call	systemResetTime		; Seteo un valor inicial en la hora
; Habilito las interrupciones	
	call	systemEnableInterrupts
	
systemInitKernelWaitForTick:
	nop;	hlt
	jmp	systemInitKernelWaitForTick

;********************************************************************************
;@fn		systemDisableInterrupts(void)
;@brief		Reprogramar 8254 para que interrumpa 1000 veces por segundo
;********************************************************************************
systemConfigure1MSTick:
	    push	ebp
	    mov		ebp, esp
	    push	eax
	    
	    push	DWORD 0x34	; Escribir palabra de control en 8254.
	    push	DWORD 0x43	; Timer/Counter 0, ewcribir ambos bytes.
	    call	portWrite	
	    add		esp, 8
	    
	    push	DWORD (1193182/100)&0xFF; Escribir parte baja del divisor en timer 0.
	    push	DWORD 0x40
	    call	portWrite
	    add		esp, 8
	    
	    push	DWORD (1193182/100)>>8; Escribir parte alta del divisor en timer 0.
	    push	DWORD 0x40
	    call	portWrite
	    add		esp, 8
	    
	    pop		eax
	    pop		ebp
	    ret

	    
;********************************************************************************
; @fn		systemLoadTickHandler()
; @brief	Carga la definicion de los handlers de las interrupciones en la IDT
;********************************************************************************
systemLoadTickHandler:
	    push	ebp
	    mov		ebp, esp
	    push	eax
	    mov		eax, systemTickHandler
	    mov		[IDT + SYSTEM_SCHED_NUM*8], ax		;Parte baja
	    shr		eax, 16				;Roto 16bit
	    mov		[IDT + SYSTEM_SCHED_NUM*8 + 6], ax		;Parte alta
	    pop		eax
	    pop		ebp
	    ret
;********************************************************************************
; @fn		systemLoadIntGateHandler()
; @brief	Carga el handler de interrupcion para la API en la IDT
;********************************************************************************
systemLoadIntGateHandler:
	    push	ebp
	    mov		ebp, esp
	    push	eax
	    mov		eax, systemIntGateHandler
	    mov		[IDT + SYSTEM_INT_GATE_NUM*8], ax		;Parte baja
	    shr		eax, 16				;Roto 16bit
	    mov		[IDT + SYSTEM_INT_GATE_NUM*8 + 6], ax		;Parte alta
	    pop		eax
	    pop		ebp
	    ret

;********************************************************************************
;@fn		systemTickHandler(void) || systemSchedulerInit(void)
;@brief		Handler de interrupcion del TICK
;********************************************************************************   
systemSchedulerInit:   
systemTickHandler:
; 	    xchg	bx, bx
	    ; Realizo el push del selector de datos y de uno de uso general. Coloco el selector de Kernel de codigo
	    push	eax				; Push de los registros necesarios para identificar quien soy
	    push 	ds
	    
	    mov 	ax, dataKernelSelector		; Coloco el selector de Kernel
	    mov 	ds, ax
	    
	    ; Envio el EOI al PIC
	    call	systemSendEOI				    

	    ; Servicios de Kernel
	    call	systemIncTick			; Incremento la cuenta de los ticks
	    call	systemDecrementTaskTicks	; Ejecuto la actualizacion de los ticks a correr para poder restaurar los sleeps de las tareas
%if	(SYSTEM_HAS_RTC == 0)	    
	    call	systemUpdateTime		; Actualizo la cuenta del tiempo
%endif	    

	    ; Obtengo la tarea actual donde estoy parado
	    call	systemGetCurrentTask		; Obtengo la tarea actual, ejecuto esta comprobación para verificar
	    cmp		eax, TASKS_NUMBER		; que estoy trabjando con tareas. Podría no estar.
	    je		systemEndOfHandler
	    
	    ; Salvo el contexto de la tarea
	    push 	DWORD [esp]		; DS
	    push	DWORD [esp + 8]	; EAX
	    push 	DWORD eax		; taskId
	    call	systemSaveCurrentContext
	    add		esp, 12
	    
; 	    xchg	bx, bx
	    
	    ; Como a esta altura ya coloque eax y ds de quien me llamo en la pila puedo popearlos
	    add		esp, 8
	    
	    ; Obtengo la proxima tarea a ejecutar
	    call	systemGetNextTask
	    cmp		eax, TASKS_NUMBER
	    je		systemEndOfHandler	    
	    
; 	    xchg	bx, bx
	    
	    ; Cargo el nuevo contexto en la tss
	    mov 	esi, systemTasks
	    mov 	ebx, taskType.size
	    mul 	ebx
	    add		esi, eax
	    
	    ; Comienzo con el copiado de registros
	    mov 	ebx, [esi +taskType.context + taskContextType.ebx]
	    mov 	ecx, [esi +taskType.context + taskContextType.ecx]
	    mov 	edx, [esi +taskType.context + taskContextType.edx]
	    mov 	edi, [esi +taskType.context + taskContextType.edi]
	    mov 	ebp, [esi +taskType.context + taskContextType.ebp]    
	    
	    ; Copiado de registros de segmento
	    mov 	eax, [esi +taskType.context + taskContextType.es]
	    mov 	es, ax
	    mov 	eax, [esi +taskType.context + taskContextType.fs]
	    mov 	fs, ax
	    mov 	eax, [esi +taskType.context + taskContextType.gs]
	    mov 	gs, ax

	    ; Copiado de CR3
	    mov 	eax, [esi +taskType.context + taskContextType.cr3]
	    mov 	cr3, eax
	    
	    ; Copiado de pila de nivel 0
; 	    mov 	eax, [esi +taskType.context + taskContextType.ss0]
; 	    mov 	ss, ax
	    mov 	esp, [esi +taskType.context + taskContextType.esp0]

	    ; Hago el incremento condicional en la pila para salvar en la tss
	    mov 	eax, esp
	    add		eax, 4
	    mov 	eax, [eax]
	    and		eax, 0x3
	    cmp		eax, 0
	    je		systemSchedulerInc12
	    mov 	eax, esp
	    add 	eax, 20
	    mov 	[tssInit + tssType.esp0], eax
	    jmp		systemSchedulerMovEnd
	    
systemSchedulerInc12:
	    mov 	eax, esp
	    add 	eax, 12
	    mov 	[tssInit + tssType.esp0], eax
	    
systemSchedulerMovEnd:
	    ; Cargo el selector de codigo de la tarea que me interrupio en la pila!
	    mov 	eax, [esi +taskType.context + taskContextType.ds]
	    push	eax
	    ; Ya que tengo la pila de nivel 0 coloco en la pila eax y esi
	    mov 	eax, [esi +taskType.context + taskContextType.eax]
	    push 	eax
	    mov 	esi, [esi +taskType.context + taskContextType.esi]

	    ; Se recupera eax y el ds
	    pop 	eax
	    pop 	ds

;	    xchg	bx, bx
	    iret

systemEndOfHandler:
	    xchg	bx, bx
	    nop
	    jmp		systemEndOfHandler

;********************************************************************************
;@fn		uint32_t systemGetCurrentTask(void)
;@brief		Obtengo el id de la tarea actual que estoy ejecutando
;@retval	Devuelve el id de la tarea que se está ejecutando
;******************************************************************************** 	    
systemGetCurrentTask:
	    push 	ebp
	    mov		ebp, esp
	    push	ecx
	    push	ebx
	    push	esi
	    
	    mov 	eax, cr3
	    
; 	    str 	ax                    		; Obtengo el valor del task register
; 	    and		eax, 0x0000FFFF			; Andeo la parte alta	    

	    ; Posiciono el puntero al final del vector de las tareas 
	    mov		ecx, TASKS_NUMBER 		; Cargo el numero de tareas
	    mov		esi, systemTasks		; Cargo en el source index el puntero al inicio de la tabla de tareas
	    add		esi, (TASKS_NUMBER-1)*taskType.size ; Incremento esi hasta la última tarea de la tabla
systemGetCurrentTaskLoop:
	    ;Comparo el selector de tarea con el actual
;             mov		ebx, [esi + taskType.tssSelector]; Obtengo el selector de la tarea
;             cmp		ax, bx				; Comparo los selectores

	    mov		ebx, [esi + taskType.context + taskContextType.cr3]; Obtengo el cr3 de la tarea            
            cmp		eax, ebx				; Comparo el cr3
            
            je		systemGetCurrentTaskEnd	
            sub		esi, taskType.size		; Decremento el puntero para comparar con la siguiente tarea
	    loop	systemGetCurrentTaskLoop
	    ; Si llegue hasta acá quiere decir que no coincidio ninguno por lo que colocamos en ecx el valor tope
	    mov		ecx, TASKS_NUMBER+1
systemGetCurrentTaskEnd:	    
	    mov 	eax, ecx			; Cargo el valor de retorno
	    dec		eax
	    pop 	esi
	    pop 	ebx
	    pop 	ecx
	    pop 	ebp
	    ret
;********************************************************************************
;@fn		void systemSaveCurrentContext(uint32_t taskIndex, uint32_t eax, uint32_t ds)
;@brief		Realizo el salvado del contexto
;@param		taskIndex	es el indice de la tarea actual
;@param		eax		es el valor de eax al ingresar a la interrupcion
;@param		ds		es el valor del data segment al ingresar a la interrupcion
;******************************************************************************** 	
systemSaveCurrentContext:
	    push	ebp
	    mov 	ebp, esp

	    ; Cargo en la pila todos los registros
	    push	edi
	    push 	ebx
	    push	ecx
	    push 	edx
	    push	esi
	    ;Cargo en la pila los registros de segmento pero alineados
	    mov 	ax, es
	    and		eax, 0xFFFF
	    push	eax
	    mov 	ax, fs
	    and		eax, 0xFFFF
	    push	eax
	    mov 	ax, gs
	    and		eax, 0xFFFF
	    push	eax	    
	    ; Me posiciono sobre el el contexto
	    mov 	edi, systemTasks
	    mov 	eax, [ebp + 8]
	    mov 	ebx, taskType.size
	    mul		ebx
	    add		edi, eax
	    
	    ; Copio los registros de uso general y de segmento
	    pop 	eax
	    mov 	[edi + taskType.context + taskContextType.gs], eax
	    pop 	eax
	    mov 	[edi + taskType.context + taskContextType.fs], eax	    	    
	    pop 	eax
	    mov 	[edi + taskType.context + taskContextType.es], eax 
	    mov 	eax, [ebp + 16]
	    mov 	[edi + taskType.context + taskContextType.ds], eax 	    
	    pop 	eax
	    mov 	[edi + taskType.context + taskContextType.esi], eax   
	    pop 	eax
	    mov 	[edi + taskType.context + taskContextType.edx], eax	    
	    pop 	eax
	    mov 	[edi + taskType.context + taskContextType.ecx], eax
	    pop 	eax
	    mov 	[edi + taskType.context + taskContextType.ebx], eax
	    mov 	eax, [ebp + 12]
	    mov 	[edi + taskType.context + taskContextType.eax], eax
	    pop 	eax
	    mov 	[edi + taskType.context + taskContextType.edi], eax	    	    
	    pop 	eax
	    mov 	[edi + taskType.context + taskContextType.ebp], eax

	    mov 	eax, esp
	    add 	eax, (4   + 4      + 4   + 4  + 4   + 4)	; EIP   taskId   EAX   DS   DS    EAX
	    mov 	[edi + taskType.context + taskContextType.esp0], eax 
	    
	    ret
;********************************************************************************
;@fn		uint32_t systemGetNextTask(void)
;@brief		Recorre todas las tareas buscando la proxima tarea de un nivel de prioridad
;		determinado a partir de lastTaskId
;@return	El indice de la tarea a ejecutar o TASKS_NUMBER si no hay
;********************************************************************************
systemGetNextTask:
	    push 	ebp
	    mov		ebp, esp
	    push	ecx
	    push 	edx
	    push	esi
	    
	    mov		ecx, PRIORITY_MAXIMUM		; Cargo la maxima prioridad
	    
systemGetNextTaskLoop:	    
	    mov		esi, systemLastTaskIdPriority	; Cargo el puntero al array de id de tareas por prioridad
	    mov		eax, 4
	    mul		ecx
	    add		esi, eax
	    
	    push	ecx				; Cargo el nivel de prioridad
	    push	DWORD [esi]			; Cargo el id de tarea para esta prioridad
	    call	systemGetNextTaskByPriority
	    add		esp, 8
	    mov		[esi], eax			; Guardo el id de la proxima tarea
	    
	    cmp		eax, TASKS_NUMBER		; Comparo la respuesta para saber si el id es valido
	    jne		systemGetNextTaskEnd
	    
	    sub 	esi, 4				; Decremento el puntero el tamaño de los indices
	    
	    loop	systemGetNextTaskLoop
	    ; Si llego aca quiere decir que no encontre tarea que schedulizar lo cual es un bug!!!
	    mov		eax, TASKS_NUMBER
systemGetNextTaskEnd:
	    pop 	esi
	    pop 	edx
	    pop 	ecx
	    pop 	ebp
	    ret	    
;********************************************************************************
;@fn		uint32_t systemGetNextTaskByPriority(uint32_t lastTaskId, uint32_t priorityLevel)
;@brief		Recorre todas las tareas buscando la proxima tarea de un nivel de prioridad
;		determinado a partir de lastTaskId
;@param		lastTaskId	Es el indice dentro del vector de tareas de la última tarea que corrio
;@param		priorityLevel	Es el valor de prioridad a comparar
;@return	El indice de la tarea a ejecutar o TASKS_NUMBER si no hay
;********************************************************************************
systemGetNextTaskByPriority:
	    push 	ebp
	    mov		ebp, esp
	    sub		esp, 4				; Reservo un dword para un indice	    
	    push 	ebx
	    push	ecx
	    push	edx
	    push 	esi
	    
	    mov		ecx, TASKS_NUMBER		; Cargo el valor de items a iterar
	    mov		edx, [lastTaskId]		; Cargo el indice de la última tarea que corrio
	    
systemGetNextTaskBPLoop:
	    cmp		edx, 0
	    jne		systemGetNextTaskBPLoadPointer
	    mov		edx, TASKS_NUMBER		; Cargo el la posicion al final del vector
systemGetNextTaskBPLoadPointer:	    
	    dec		edx
	    mov 	[ebp-4], edx			; Guardo el indice
	    
	    mov		esi, systemTasks		; Posiciono el puntero
	    mov		eax, edx
	    mov		ebx, taskType.size
	    mul		ebx
	    add		esi, eax
	    
	    mov		eax, [esi + taskType.priority]	;Comparo la prioridad
	    cmp		eax, [priorityLevel]
	    je		systemGetNextTaskBPEnd
	    
	    mov		edx, [ebp-4]
	    cmp		edx, [lastTaskId]		;Comparo con el lastTaskId para saber si pegue la vuelta en el array
	    je		systemGetNextTaskBPNotFound
	    
	    loop	systemGetNextTaskBPLoop
systemGetNextTaskBPNotFound:	    
	    ; Si alcanzo este punto es porque no hay tarea con la prioridad requerida
	    mov 	[ebp-4], DWORD TASKS_NUMBER
systemGetNextTaskBPEnd:
	    mov		eax, [ebp-4]
	    pop 	esi
	    pop 	edx
	    pop 	ecx
	    pop 	ebx
	    add		esp, 4				; Restauro el stack frame	    
	    pop 	ebp
	    ret
;********************************************************************************
;@fn		void systemSendEOI(void)
;@brief		Envia el End Of Interrupt al PIC
;******************************************************************************** 
systemSendEOI:
	    push	DWORD PIC_EOI_VALUE		; Genero el EOI para el PIC
	    push	DWORD PIC_EOI_PORT
	    call	portWrite
	    add		esp, 8	
	    ret
;********************************************************************************
;@fn		systemIncTick(void)
;@brief		Incremento la cuenta de los ticks
;********************************************************************************    
systemIncTick:
	    push 	eax
	    mov		eax, [systemTickCount]
	    inc 	eax
	    mov         [systemTickCount], eax
	    pop 	eax
	    ret	
;********************************************************************************
;@fn		systemDecrementTaskTicks(void)
;@brief		Decremento la cuenta 
;********************************************************************************	    
systemDecrementTaskTicks: 
	    push	ebp
	    mov		ebp, esp
	    push	ecx
	    push	esi
	    
	    mov		ecx, TASKS_NUMBER
	    mov		esi, systemTasks

systemDecrementTaskTicksLoop:
	    cmp		[esi + taskType.priority], DWORD 0	; Testeo la prioridad
	    jne		systemDecrementTaskTicksDoLoop
	    mov 	eax, [esi + taskType.ticksToWakeUp]
	    cmp		eax, 0				; Testeo los ticks que quedan para actualizar
	    je		systemDecrementTaskTicksDoLoop
	    dec 	eax
	    cmp		eax, 0				; Testeo si producto del decremento tengo que restaurar la prioridad
	    mov		[esi + taskType.ticksToWakeUp], eax
	    jne		systemDecrementTaskTicksDoLoop	
	    mov		eax, [esi + taskType.oldPriority]; Restauro la prioridad de la tarea
	    mov		[esi + taskType.priority], eax
systemDecrementTaskTicksDoLoop:	    
	    add		esi, taskType.size
	    loop	systemDecrementTaskTicksLoop
	    
	    pop 	esi
	    pop 	ecx
	    pop 	ebp
	    ret
;********************************************************************************
;@fn		systemLoadSysCalls(void)
;@brief		Se cargan los punteros a funcion de las system calls
;********************************************************************************    
systemLoadSysCalls:
	    push	ebp
	    mov		ebp, esp
	    push	esi
	    
	    mov 	esi, systemAPIHandlers
	    mov		[esi], DWORD systemSysCallSleep
	    add		esi, 4
	    mov 	[esi], DWORD systemSysCallGetTime
	    add		esi, 4
	    mov 	[esi], DWORD systemSysCallClearScreen
	    add		esi, 4
	    mov 	[esi], DWORD systemSysCallPrint
	    add		esi, 4
	    mov 	[esi], DWORD systemSysCallChangeTaskPriority
	    add		esi, 4
	    mov 	[esi], DWORD systemCallGetChar
	    add		esi, 4
	    mov 	[esi], DWORD systemCallGetTaskPriority
	    add		esi, 4
	    mov 	[esi], DWORD systemCallSetTaskPriority
	    
	    pop 	esi
	    pop  	ebp
	    ret	    
;********************************************************************************
;@fn		systemIncTick(void)
;@brief		Incremento la cuenta de los ticks
;********************************************************************************   
systemIntGateHandler:
	    push	ds				; Push a los registros de datos
	    push	es  	
	    push	fs
	    push 	gs
	    push 	ebx
	    mov		bx, dataKernelSelector		; Cargo el selector de datos del Kernel
	    mov 	ds, bx
	    mov 	es, bx
	    
	    cmp		eax, SYSTEM_API_MAX		; Comparo contra el mayor caso
	    ja		systemIntGateHandlerError
	    call	[systemAPIHandlers + eax*4]	; Ejecuto la system call llamada
	    
systemIntGateHandlerError:
systemIntGateHandlerEnd:
	    pop 	ebx
	    pop 	gs
	    pop 	fs
	    pop 	es
	    pop 	ds

	    mov 	eax, [systemReturnValue]
	    
	    iret
    
;********************************************************************************
;@fn		systemSysCallSleep(void)
;@brief		Implementacion de la system call de sleep
;@brief		Los argumentos estan en la pila
;********************************************************************************    
systemSysCallSleep:
	    push 	ebp
	    mov		ebp, esp
	    push	ebx
	    push	edx
	    push	esi
	    
	    call	systemGetCurrentTask		; Obtengo el indice de la tarea actual
	    cmp		eax, TASKS_NUMBER		
	    je		systemSysCallSleepEnd
	    
	    call	systemDisableInterrupts		; Deshabilito las interrupciones
	    
	    mov		esi, systemTasks		; Me posiciono sobre la tarea
	    mov		ebx, taskType.size
	    mul		ebx
	    add		esi, eax
	    
	    mov		eax, [esi + taskType.priority]	; Salvo la prioridad que tenia y cargo los ticks a esperar la interrupcion
	    mov		[esi + taskType.oldPriority], eax
	    mov		[esi + taskType.priority], DWORD 0
	    
	    ; Cargo el valor de ticks a esperar en la tarea
			      ;ESP  EIP  EBX GS    FS   ES   DS   EIP  CS  EFLAGS  ESPx
	    mov		eax, [ebp + 4  + 4  + 4  + 4  + 4  + 4  + 4  + 4 + 4     + 4]	; Obtengo el puntero al ESP en el momento que llamo a la int 80
	    add		eax, 4				; Incremento el stack en 4 ya que ahi tengo el atributo previo al llamdo del wrapper!
	    mov		eax, [eax]			; Obtengo el valor del tack 
	    mov		[esi + taskType.ticksToWakeUp], eax
	    
	    call	systemEnableInterrupts		; Deshabilito las interrupciones
	    
	    int 	SYSTEM_SCHED_NUM		; Llamo al scheduler
	    
	    call	systemRestoreTopOfStack		; Restauro el stack pointer de la tss
	    
systemSysCallSleepEnd:
	    pop 	esi
	    pop 	edx
	    pop 	ebx
	    pop 	ebp
	    ret
;********************************************************************************
;@fn		systemSysCallGetTime(void)
;@brief		Cargo la estructa del tiempo con la que hay en el kernel
;********************************************************************************
systemSysCallGetTime:
	    push 	ebp
	    mov		ebp, esp
	    push	ecx
	    push 	edx
	    push	esi
	    push	edi
	    
	    	
	    ; Cargo el valor de ticks a esperar en la tarea
	    ;                 ESP  EIP  EBX GS    FS   ES   DS   EIP  CS  EFLAGS  ESPx
	    mov		eax, [ebp + 4  + 4  + 4  + 4  + 4  + 4  + 4  + 4 + 4     + 4]; Obtengo el puntero al ESP en el momento que llamo a la int 80
	    add		eax, 4				; Incremento el stack en 4 ya que ahi tengo el atributo previo al llamdo del wrapper!
	    mov		edi, [eax]			; Obtengo el valor del stack 	    
%if	(SYSTEM_HAS_RTC==0)	    
	    mov		esi, systemTime			; Me posiciono sobre la tarea
	    
	    mov		ecx, timeType.size
	    rep		movsb				; Realizo la copia
%else
	    mov 	eax, 0				; Cargo en AL = 0 para obtener la fecha
	    mov 	edx, 0
	    call 	RTC_Service			; Llamo al servicio de RTC_Service
	    cmp 	cl, 0				; Evaluo si CL tuvo un error o no
	    jne		systemSysCallGetTimeError
	    mov   	[edi + timeType.year], dh	; Muevo el año
	    mov   	[edi + timeType.month], dl	; Muevo el mes
	    mov   	[edi + timeType.date], ah	; Muevo el dia
	    ;Cambio de formato
	    push 	DWORD [edi + timeType.year];
	    call	systemPBCDToBin
	    add		esp, 4
	    mov 	[edi + timeType.year], eax

	    push 	DWORD [edi + timeType.month];
	    call	systemPBCDToBin
	    add		esp, 4
	    mov 	[edi + timeType.month], eax
	    
	    push 	DWORD [edi + timeType.date];
	    call	systemPBCDToBin
	    add		esp, 4
	    mov 	[edi + timeType.date], eax
	    
	    mov 	eax, 1				; Cargo en AL = 1 para obtener la hora
	    mov 	edx, 0
	    call 	RTC_Service			; Llamo al servicio de RTC_Service
	    cmp 	cl, 0				; Evaluo si CL tuvo un error o no	    
	    mov   	[edi + timeType.hour], dl	; Muevo el hora
	    mov   	[edi + timeType.minute], ah	; Muevo el minutos
	    mov   	[edi + timeType.second], al	; Muevo el segundos
	    ;Cambio de formato
	    push 	DWORD [edi + timeType.hour];
	    call	systemPBCDToBin
	    add		esp, 4
	    mov 	[edi + timeType.hour], eax

	    push 	DWORD [edi + timeType.minute];
	    call	systemPBCDToBin
	    add		esp, 4
	    mov 	[edi + timeType.minute], eax
	    
	    push 	DWORD [edi + timeType.second];
	    call	systemPBCDToBin
	    add		esp, 4
	    mov 	[edi + timeType.second], eax	    
	    
	    jmp		systemSysCallGetTimeEnd
	    
systemSysCallGetTimeError:
	    ;TODO
	    
%endif
systemSysCallGetTimeEnd:
	    pop 	edi
	    pop 	esi
	    pop 	edx
	    pop 	ecx
	    pop 	ebp
	    ret
	    
;********************************************************************************
;@fn		systemPBCDToBin(uint32_t value)
;@brief		A partir de un bcd empaquetado de 2 cifras lo convierto en binario
;@param		value	es el valor a convertir
;@retval	El binario convertido
;********************************************************************************	    	    
systemPBCDToBin:
	    push 	ebp
	    mov 	ebp, esp
	    push 	ebx
	    push 	edx

	    mov 	eax, [ebp + 8]
	    and		eax, 0x000000F0
	    shr 	eax, 4
	    mov 	ebx, 10
	    mul 	ebx
	    mov 	ebx, [ebp + 8]
	    and 	ebx, 0x0000000F
	    add		eax, ebx
	    
	    pop 	edx
	    pop 	ebx
	    pop 	ebp
	    ret
	    
;********************************************************************************
;@fn		systemSysCallGetTime(void)
;@brief		Cargo la estructa del tiempo con la que hay en el kernel
;********************************************************************************	    
systemUpdateTime:
	    push 	ebp
	    mov		ebp, esp
	    push 	esi
	    push 	edi
	    mov		esi, systemTime			; Me posiciono sobre la estructura
	    ;Incremento milisegundos
	    mov 	edi, timeType.milisecond
	    add		edi, esi
	    mov 	eax, [edi]
	    inc 	eax
	    cmp		eax, 1000
	    jb		systemUpdateTimeLoadAndEnd
	    mov 	[edi], DWORD 0
	    ;Incremento segundos
	    mov 	edi, timeType.second
	    add		edi, esi	    
	    mov 	eax, [edi]
	    inc 	eax
	    cmp		eax, 60
	    jb		systemUpdateTimeLoadAndEnd
	    mov 	[edi], DWORD 0
	    ;Incremento minutos
	    mov 	edi, timeType.minute
	    add		edi, esi	    
	    mov 	eax, [edi]
	    inc 	eax
	    cmp		eax, 60
	    jb		systemUpdateTimeLoadAndEnd
	    mov 	[edi], DWORD 0	    
	    ;Incremento horas
	    mov 	edi, timeType.hour
	    add		edi, esi	    
	    mov 	eax, [edi]
	    inc 	eax
	    cmp		eax, 24
	    jb		systemUpdateTimeLoadAndEnd
	    mov 	[edi], DWORD 0	    	    
	    ;Incremento dias, para eso consulto el mes primero
	    ;Se consulta si el mes es febrero por lo 28. Luego por lo meses con 30 ya que son menos
	    mov		eax, [esi + timeType.month]
	    cmp		eax, 2
	    je		systemUpdateTimeFrebruary
	    cmp		eax, 4
	    je		systemUpdateTimeMonthWith30
	    cmp		eax, 6
	    je		systemUpdateTimeMonthWith30
	    cmp		eax, 9
	    je		systemUpdateTimeMonthWith30
	    cmp		eax, 11
	    je		systemUpdateTimeMonthWith30
	    ; Es un mes con 31!
	    mov 	edi, timeType.date
	    add		edi, esi	    
	    mov 	eax, [edi]
	    inc 	eax
	    cmp		eax, 32
	    jb		systemUpdateTimeLoadAndEnd
	    jmp		systemUpdateTimeIncMonth
systemUpdateTimeFrebruary:
	    mov 	edi, timeType.date
	    add		edi, esi	    
	    mov 	eax, [edi]
	    inc 	eax
	    cmp		eax, 29
	    jb		systemUpdateTimeLoadAndEnd
	    jmp		systemUpdateTimeIncMonth
systemUpdateTimeMonthWith30:
	    mov 	edi, timeType.date
	    add		edi, esi	    
	    mov 	eax, [edi]
	    inc 	eax
	    cmp		eax, 31
	    jb		systemUpdateTimeLoadAndEnd
	    ; Incremento de mes
systemUpdateTimeIncMonth:
	    mov 	[edi], DWORD 1
	    mov 	edi, timeType.month
	    add		edi, esi	    
	    mov 	eax, [edi]
	    inc 	eax
	    cmp		eax, 13
	    jb		systemUpdateTimeLoadAndEnd
	    mov 	[edi], DWORD 1
	    ; Incremento de año
	    mov 	edi, timeType.year
	    add		edi, esi	    
	    mov 	eax, [edi]
	    inc 	eax
systemUpdateTimeLoadAndEnd:
	    mov 	[edi], eax
systemUpdateTimeEnd:
	    pop 	edi
	    pop 	esi
	    pop 	ebp
	    ret
;********************************************************************************
;@fn		systemResetTime(void)
;@brief		Cargo la estructura de tiempo con un valor fake
;********************************************************************************	    
systemResetTime:
	    push 	ebp
	    mov 	ebp, esp
	    push 	edi
	    
	    mov 	edi, systemTime
	    mov 	[edi + timeType.milisecond], DWORD 0
	    mov 	[edi + timeType.second], DWORD 0
	    mov 	[edi + timeType.minute], DWORD 0
	    mov 	[edi + timeType.hour], DWORD 19
	    mov 	[edi + timeType.date], DWORD 1
	    mov 	[edi + timeType.month], DWORD 11
	    mov 	[edi + timeType.year], DWORD 2015
	    
	    pop 	edi
	    pop 	ebp
	    ret
;********************************************************************************
;@fn		systemSysCallClearScreen(void)
;@brief		Redirecciono a la función de la API de video
;********************************************************************************	    
systemSysCallClearScreen:
	    push 	ebp
	    mov 	ebp, esp
	    call	videoClearScreen
	    pop 	ebp
	    ret
;********************************************************************************
;@fn		systemSysCallPrint(void)
;@brief		Redirecciono a la función de la API de video
;********************************************************************************		    
systemSysCallPrint:
	    push 	ebp
	    mov 	ebp, esp
	    push 	eax
	    ;                 ESP  EIP  EBX GS    FS   ES   DS   EIP  CS  EFLAGS  ESPx	    
	    mov		eax, [ebp + 4  + 4  + 4  + 4  + 4  + 4  + 4  + 4 + 4     + 4]; Obtengo el puntero al ESP en el momento que llamo a la int 80
	    add		eax, 16
	    ; Tengo en eax la dirección del atributo con el que se llamo a la systemCall
	    push	DWORD [eax]
	    sub		eax, 4
	    push	DWORD [eax]
	    sub		eax, 4
	    push	DWORD [eax]
	    sub		eax, 4
	    push	DWORD [eax]
	    sub		eax, 4
	    call	videoPrint
	    add		esp, 16
	    
	    pop 	eax
	    pop 	ebp
	    ret
;********************************************************************************
;@fn		systemSysCallChangeTaskPriority(void)
;@brief		Cambio la prioridad de una tarea. La system call es llamada como:
;		void changePriority(uint32_t taskId, uint32_t taskPriority)
;@details	La ejecucion de esta systemCall a un taskId que no existe no tiene efecto.
;		La ejecucion con un taskPriority fuera de rango no tiene efecto así como, 
;		tambien es lo mismo que la tarea ejecute sleep(0) si la prioridad es 0.
;		Puede producir un cambio de contexto ya que se llama el scheduler tras
;		realizar el cambio de prioridades
;********************************************************************************		    
systemSysCallChangeTaskPriority:
	    push 	ebp
	    mov 	ebp, esp
	    push	ebx
	    push 	edx
	    push	esi
	    push 	edi
	    
	    ;Obtengo la prioridad y evaluo el rango
	    ;                 ESP  EIP  EBX GS    FS   ES   DS   EIP  CS  EFLAGS  ESPx
	    mov		esi, [ebp + 4  + 4  + 4  + 4  + 4  + 4  + 4  + 4 + 4     + 4]; Obtengo el puntero al ESP en el momento que llamo a la int 80
	    add		esi, 8
	    ; Validaciones
	    mov 	eax, [esi]
	    cmp		eax, PRIORITY_MAXIMUM
	    ja		systemSysCallChangeTaskPriorityEnd
	    mov 	eax, [esi - 4]
	    cmp 	eax, TASKS_NUMBER
	    jae		systemSysCallChangeTaskPriorityEnd
	    ; Paro las interrupciones y ejecuto el cambio de prioridades
	    call	systemDisableInterrupts	; Paro las interrupciones
	    
	    mov 	edi, systemTasks	; Direcciono el vector de tareas
	    mov 	ebx, taskType.size
	    mul		ebx
	    add		edi, eax
	    mov 	eax, [esi]		; Obtengo la prioridad a colocarle a la tarea
	    mov 	[edi + taskType.oldPriority], DWORD eax
	    mov 	ebx, [edi + taskType.oldPriority]
	    cmp		ebx, 0			; Evaluo si la tarea estaba dormida por algo en particular por lo que la dejamos con esa prioridad
	    je		systemSysCallChangeTaskPriorityRunSched
	    mov 	[edi + taskType.priority], DWORD eax
	    
systemSysCallChangeTaskPriorityRunSched:
	    call	systemEnableInterrupts	; Restauro las interrupciones
	    
	    int 	SYSTEM_SCHED_NUM	; Llamo al scheduler para que efectue el cambio de contexto

	    call	systemRestoreTopOfStack	; Restauro el stack pointer de la tss
systemSysCallChangeTaskPriorityEnd:	    
	    pop 	edi
	    pop 	esi
	    pop 	edx
	    pop 	ebx
	    pop 	ebp	    
	    ret
	    
;********************************************************************************
;@fn		systemRestoreTopOfStack(void)
;@brief		Restauro en la tss el top of stack para retornar correctamente la proxima vez al ser interrumpido
;********************************************************************************		    	    
systemRestoreTopOfStack:
	    push 	ebp
	    mov 	ebp, esp
	    pushad
	    push 	edi
	    push 	esi
	    
	    ; Obtengo la tarea actual donde estoy parado
	    call	systemGetCurrentTask		; Obtengo la tarea actual, ejecuto esta comprobación para verificar
	    cmp		eax, TASKS_NUMBER		; que estoy trabjando con tareas. Podría no estar.
	    je		systemRestoreTopOfStackEnd
	    
	    ; Me muevo en la estructura de tareas
	    mov 	esi, systemTasks
	    mov 	ebx, taskType.size
	    mul 	ebx
	    add 	esi, eax
	    ; Me muevo en la tss
	    mov		edi, tssInit
	    add 	edi, tssType.esp0
	    ; Realizo al copia
	    mov 	eax, [esi + taskType.context + taskContextType.topOfStack0]
	    mov 	[edi], eax

systemRestoreTopOfStackEnd:
	    pop 	esi
	    pop 	edi
	    popad
	    pop 	ebp
	    ret
;********************************************************************************
;@fn		systemCallGetChar(void)
;@brief		Obtengo un byte de la fifo del teclado. Se la llama como getChar(char *value)
;********************************************************************************		    	    
systemCallGetChar:
	    push 	ebp
	    mov 	ebp, esp
	    ;Obtengo el puntero
	    mov		eax, [ebp + 4  + 4  + 4  + 4  + 4  + 4  + 4  + 4 + 4     + 4]; Obtengo el puntero al ESP en el momento que llamo a la int 80
	    add		eax, 4
	    
	    push	DWORD [eax]			; Cargo la direccion del puntero en eax al dato
	    call	keyboardGetChar			; Obtengo el caracter
	    add		esp, 4
	    
	    mov 	[systemReturnValue], eax
	  
	    pop 	ebp
	    ret	    

;********************************************************************************
;@fn		systemCallGetTaskPriority(void)
;@brief		Obtiene la prioridad de una tarea por su id
;********************************************************************************		    	    
systemCallGetTaskPriority:
	    push 	ebp
	    mov 	ebp, esp
	    push 	ebx
	    push 	edx
	    push 	esi
	    
	    ;Obtengo el puntero
	    mov		eax, [ebp + 4  + 4  + 4  + 4  + 4  + 4  + 4  + 4 + 4     + 4]; Obtengo el puntero al ESP en el momento que llamo a la int 80
	    add		eax, 4
	    mov 	eax, [eax]
	    ; Comparo el valor del taskId para estar seguro que no accedo a memoria erronea
	    cmp		eax, TASKS_NUMBER
	    jb		systemCallGetTaskPriorityOKArgument
	    mov 	[systemReturnValue], DWORD TASKS_NUMBER
	    jmp		systemCallGetTaskPriorityEnd
	    
systemCallGetTaskPriorityOKArgument:
	    ; Obtengo el valor de la prioridad basado en el id
	    mov 	esi, systemTasks
	    mov 	ebx, eax
	    mov 	eax, taskType.size
	    mul		ebx
	    add		esi, eax
	    mov		eax, [esi + taskType.priority]
	    mov 	[systemReturnValue], eax
	    
systemCallGetTaskPriorityEnd:	 
	    pop 	esi
	    pop 	edx
	    pop 	ebx
	    pop 	ebp
	    ret	    
;********************************************************************************
;@fn		systemCallSetTaskPriority(void)
;@brief		Setea la prioridad de una tarea por su id
;********************************************************************************		    	    
systemCallSetTaskPriority:
	    push 	ebp
	    mov 	ebp, esp
	    push 	ebx
	    push 	edx
	    push 	edi
	    push 	esi
	    ;Obtengo el puntero
	    mov		eax, [ebp + 4  + 4  + 4  + 4  + 4  + 4  + 4  + 4 + 4     + 4]; Obtengo el puntero al ESP en el momento que llamo a la int 80
	    add		eax, 4
	    mov 	eax, [eax]
	    ; Comparo el valor del taskId para estar seguro que no accedo a memoria erronea
	    cmp		eax, TASKS_NUMBER
	    jb		systemCallSetTaskPriorityOKArgument
	    mov 	[systemReturnValue], DWORD TASKS_NUMBER
	    jmp		systemCallSetTaskPriorityEnd
	    
systemCallSetTaskPriorityOKArgument:
	    ; Obtengo el valor de la prioridad basado en el id
	    mov		esi, [ebp + 4  + 4  + 4  + 4  + 4  + 4  + 4  + 4 + 4     + 4]; Obtengo el puntero al ESP en el momento que llamo a la int 80
	    add		esi, 8
	    mov 	edi, systemTasks
	    mov		ebx, eax
	    mov 	eax, taskType.size
	    mul		ebx
	    add		edi, eax
	    mov 	eax, [esi]
	    mov		[edi + taskType.priority], eax
	    mov 	[systemReturnValue], DWORD 0x0
	    
systemCallSetTaskPriorityEnd:	 
	    pop 	esi
	    pop 	edi
	    pop 	edx
	    pop 	ebx
	    pop 	ebp
	    ret	 	    