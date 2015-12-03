;#########################################################################
;@file		tasks.asm
;@brief		Codigo propio de las tareas. En este archivo se van a crear las tareas y definir la memoria para las mismas
;	    	Intel x86 compatible en 32 bit. 
;@author	Agustin Alba Chicar
;@date		Octubre, 2015
;#########################################################################

;********************************************************************************
; Simbolos externos y globales
;********************************************************************************
%include	"system.inc"
%include	"video.inc"

;Simbolos de shared
EXTERN		print
EXTERN		cls
EXTERN		getTime
EXTERN		sleep
EXTERN		printNumberToArray
EXTERN		getChar
EXTERN		getTaskPriority
EXTERN		setTaskPriority

GLOBAL		task1Code
GLOBAL		task2Code
GLOBAL		task3Code
GLOBAL		task4Code

;********************************************************************************
; Defines
;********************************************************************************

;********************************************************************************
; Datos inicializados
;********************************************************************************
SECTION		.task1_initialized_data

task1Message	db "Tarea 1. Impresion de fecha.", NULL

SECTION		.task2_initialized_data

task2Message	db "Tarea 2. Impresion de hora.", NULL

SECTION		.task3_initialized_data

task3Message	db "Tarea 3. Contador.", NULL

SECTION		.task4_initialized_data

task4Message	db "Tarea 4. Gestor de prioridades de tareas.", NULL
task4Help	db "Tarea 1: [q, a]. Tarea 2: [w, s]. Tarea 3: [e, d]. [Sube, Baja]", NULL
task4Task1Str	db "Tarea 1: ", NULL
task4Task2Str	db "Tarea 2: ", NULL
task4Task3Str	db "Tarea 3: ", NULL
task4PrioStr	db NULL,NULL
task4Char	db NULL

;********************************************************************************
; Datos no inicializados
;********************************************************************************
SECTION		.task1_not_initialized_data

task1Time:		resb	timeType.size*1
task1PrintBuffer	resb	9		; XX/XX/XX NULL

SECTION		.task2_not_initialized_data

task2Time:		resb	timeType.size*1
task2PrintBuffer	resb	9		; YY:YY:YY NULL

SECTION		.task3_not_initialized_data
;Contador de la tarea 3
task3Counter:		resd	1
task3NumberBuffer:	resb	11

SECTION		.task4_not_initialized_data

;Vector que contiene las prioridades de las otras tareas
task4Priorities:	resd	3

;********************************************************************************
; Codigo
;********************************************************************************

SECTION		.task1_code

;********************************************************************************
;@fn		task1Code()
;@brief		Imprime la fecha
;********************************************************************************
task1Code:
task1CodeInit: 
; 	  nop
; 	  jmp		task1CodeInit
; 	  
; 	  
	  push		DWORD VIDEO_WORD_FOREGROUND_BLUE_MASK | VIDEO_WORD_FOREGROUND_RED_MASK | VIDEO_WORD_FOREGROUND_GREEN_MASK | VIDEO_WORD_INTENSITY_MASK
	  push		DWORD 0
	  push		DWORD 0	  
	  push		DWORD task1Message
	  call		print
	  add		esp, 16	  
	  
task1Loop:
	  push		DWORD task1Time	; Obtengo la hora
	  call		getTime
	  add		esp, 4 	  
	  
	  mov		esi, task1Time
	  mov		edi, task1PrintBuffer
	  
	  mov		eax, [esi + timeType.date]	; Cargo el dia
	  push		edi
	  push		eax
	  call		printNumberToArray
	  add		esp, 8
	  
	  mov		eax, [esi + timeType.date]
	  cmp		eax, 10
	  jae		task1IncESIDate2
	  inc		edi
	  jmp		task1LoadBarDate
task1IncESIDate2:	  
	  add		edi, 2
task1LoadBarDate:	  
	  mov		[edi], BYTE '/'
	  inc 		edi
	  
	  mov		eax, [esi + timeType.month]	; Cargo el mes
	  push		DWORD edi
	  push		eax
	  call		printNumberToArray
	  add		esp, 8

	  mov		eax, [esi + timeType.month]
	  cmp		eax, 10
	  jae		task1IncESIMonth2
	  inc		edi
	  jmp		task1LoadBarMonth
task1IncESIMonth2:	  
	  add		edi, 2
task1LoadBarMonth:	  
	  mov		[edi], BYTE '/'
	  inc 		edi

	  mov		eax, [esi + timeType.year]	; Cargo el año
	  push		DWORD edi
	  push		eax
	  call		printNumberToArray
	  add		esp, 8

	  mov		eax, [esi + timeType.year]
	  cmp		eax, 10
	  jae		task1IncESIYear2
	  inc		edi
	  jmp		task1LoadBarYear
task1IncESIYear2:	  
	  add		edi, 2
task1LoadBarYear:	  
	  mov		[edi], BYTE NULL
	  inc 		edi

	  push		DWORD VIDEO_WORD_FOREGROUND_BLUE_MASK | VIDEO_WORD_FOREGROUND_RED_MASK | VIDEO_WORD_FOREGROUND_GREEN_MASK | VIDEO_WORD_INTENSITY_MASK
	  push		DWORD 1
	  push		DWORD 0	  
	  push		DWORD task1PrintBuffer
	  call		print
	  add		esp, 16
	  
	  jmp		task1Loop


SECTION		.task2_code

;********************************************************************************
;@fn		task2Code()
;@brief		Imprime la hora
;********************************************************************************
task2Code:
task2CodeInit:
	  push		DWORD VIDEO_WORD_FOREGROUND_BLUE_MASK | VIDEO_WORD_FOREGROUND_RED_MASK | VIDEO_WORD_FOREGROUND_GREEN_MASK | VIDEO_WORD_INTENSITY_MASK
	  push		DWORD 5
	  push		DWORD 0	  
	  push		DWORD task2Message
	  call		print
	  add		esp, 16
	  
task2Loop:
	  push		DWORD task2Time	; Obtengo la hora
	  call		getTime
	  add		esp, 4 	  
	  
	  mov		esi, task2Time
	  mov		edi, task2PrintBuffer
	  
	  mov		eax, [esi + timeType.hour]	; Cargo la hora
	  push		edi
	  push		eax
	  call		printNumberToArray
	  add		esp, 8
	  
	  mov		eax, [esi + timeType.hour]
	  cmp		eax, 10
	  jae		task2IncESIHour2
	  inc		edi
	  jmp		task2LoadBarHour
task2IncESIHour2:	  
	  add		edi, 2
task2LoadBarHour:	  
	  mov		[edi], BYTE ':'
	  inc 		edi
	  
	  mov		eax, [esi + timeType.minute]	; Cargo los minutos
	  push		DWORD edi
	  push		eax
	  call		printNumberToArray
	  add		esp, 8  

	  mov		eax, [esi + timeType.minute]
	  cmp		eax, 10
	  jae		task2IncESIMinute2
	  inc		edi
	  jmp		task2LoadBarMinute
task2IncESIMinute2:	  
	  add		edi, 2
task2LoadBarMinute:	  
	  mov		[edi], BYTE ':'
	  inc 		edi

	  mov		eax, [esi + timeType.second]	; Cargo los segundos
	  push		DWORD edi
	  push		eax
	  call		printNumberToArray
	  add		esp, 8

	  mov		eax, [esi + timeType.second]
	  cmp		eax, 10
	  jae		task2IncESISecond2
	  inc		edi
	  jmp		task2LoadBarSecond
task2IncESISecond2:	  
	  add		edi, 2
task2LoadBarSecond:	  
	  mov		[edi], BYTE NULL
	  inc 		edi

	  push		DWORD VIDEO_WORD_FOREGROUND_BLUE_MASK | VIDEO_WORD_FOREGROUND_RED_MASK | VIDEO_WORD_FOREGROUND_GREEN_MASK | VIDEO_WORD_INTENSITY_MASK
	  push		DWORD 6
	  push		DWORD 0	  
	  push		DWORD task2PrintBuffer
	  call		print
	  add		esp, 16
	  
	  jmp		task2Loop

SECTION		.task3_code

;********************************************************************************
;@fn		task3Code()
;@brief		Codigo de la tarea 3. Se imprime un contador en pantalla
;********************************************************************************
task3Code:
task3CodeInit:
	  push		DWORD VIDEO_WORD_FOREGROUND_BLUE_MASK | VIDEO_WORD_FOREGROUND_RED_MASK | VIDEO_WORD_FOREGROUND_GREEN_MASK | VIDEO_WORD_INTENSITY_MASK
	  push		DWORD 10
	  push		DWORD 0	  
	  push		DWORD task3Message
	  call		print
	  add		esp, 16

task3IncNumber: 	  
 	  mov		eax, [task3Counter]
 	  inc 		eax
 	  mov		[task3Counter], eax
 	  
 	  push		DWORD task3NumberBuffer 	  
 	  push		eax
 	  call		printNumberToArray
 	  add		esp, 8

task3PrintNumber:
	  push		DWORD VIDEO_WORD_FOREGROUND_BLUE_MASK | VIDEO_WORD_FOREGROUND_RED_MASK | VIDEO_WORD_FOREGROUND_GREEN_MASK | VIDEO_WORD_INTENSITY_MASK
	  push		DWORD 11
	  push		DWORD 0	  
	  push		DWORD task3NumberBuffer
	  call		print
	  add		esp, 16
	  jmp		task3IncNumber	  	  

SECTION		.task4_code

;********************************************************************************
;@fn		task4Code()
;@brief		Codigo de la tarea 4. Permite leyendo del teclado, que se aumente
;		o reduzca la prioridad de las tareas.
;		Con Q incrementamos la prioridad de la tarea 1
;		Con A decrementamos la prioridad de la tarea 1
;		Con W incrementamos la prioridad de la tarea 2
;		Con S decrementamos la prioridad de la tarea 2
;		Con E incrementamos la prioridad de la tarea 3
;		Con D decrementamos la prioridad de la tarea 3
;********************************************************************************
task4Code:
task4CodeInit:	
	  
	  call		cls

task4GetTasksPriorities:
	  mov		esi, task4Priorities	; Cargo el inicio del vector
	  mov		ecx, 3
	  mov		ebx, 0
	  
task4GetTasksPrioritiesLoop:	  		; Itero obteniendo las prioridades
	  push		ebx
	  call		getTaskPriority
	  add		esp, 4
	  mov		[esi], eax
	  add		esi, 4
	  inc 		ebx
	  loop		task4GetTasksPrioritiesLoop
	  
task4PrintMessages:	  
	  push		DWORD VIDEO_WORD_FOREGROUND_BLUE_MASK | VIDEO_WORD_FOREGROUND_RED_MASK | VIDEO_WORD_FOREGROUND_GREEN_MASK | VIDEO_WORD_INTENSITY_MASK
	  push		DWORD 14
	  push		DWORD 0	  
	  push		DWORD task4Message
	  call		print
	  add		esp, 16
	  
	  
	  push		DWORD VIDEO_WORD_FOREGROUND_BLUE_MASK | VIDEO_WORD_FOREGROUND_RED_MASK | VIDEO_WORD_FOREGROUND_GREEN_MASK | VIDEO_WORD_INTENSITY_MASK
	  push		DWORD 15
	  push		DWORD 0	  
	  push		DWORD task4Help
	  call		print
	  add		esp, 16
	  
	  push		DWORD VIDEO_WORD_FOREGROUND_BLUE_MASK | VIDEO_WORD_FOREGROUND_RED_MASK | VIDEO_WORD_FOREGROUND_GREEN_MASK | VIDEO_WORD_INTENSITY_MASK
	  push		DWORD 16
	  push		DWORD 0	  
	  push		DWORD task4Task1Str
	  call		print
	  add		esp, 16	  
	  
	  push		DWORD VIDEO_WORD_FOREGROUND_BLUE_MASK | VIDEO_WORD_FOREGROUND_RED_MASK | VIDEO_WORD_FOREGROUND_GREEN_MASK | VIDEO_WORD_INTENSITY_MASK
	  push		DWORD 17
	  push		DWORD 0	  
	  push		DWORD task4Task2Str
	  call		print
	  add		esp, 16
	  
	  push		DWORD VIDEO_WORD_FOREGROUND_BLUE_MASK | VIDEO_WORD_FOREGROUND_RED_MASK | VIDEO_WORD_FOREGROUND_GREEN_MASK | VIDEO_WORD_INTENSITY_MASK
	  push		DWORD 18
	  push		DWORD 0	  
	  push		DWORD task4Task3Str
	  call		print
	  add		esp, 16	  
  
	   	  
	  call		task4Print1Priority
	  call		task4Print2Priority 
	  call		task4Print3Priority	
	  
task4GetChar:	  

	  push		DWORD 10
	  call		sleep
	  add		esp, 4
	  
	  push		DWORD task4Char
	  call		getChar
	  add		esp, 4	  
	  cmp		eax, 0xFF
	  je		task4GetChar
	  mov		al, [task4Char]
	  
	  cmp		al, 'e'
	  je		task4IncTask3Prio
	  cmp		al, 'd'
	  je		task4DecTask3Prio
	  
	  cmp		al, 'w'
	  je		task4IncTask2Prio
	  cmp		al, 's'
	  je		task4DecTask2Prio
	  
	  cmp		al, 'q'
	  je		task4IncTask1Prio
	  cmp		al, 'a'
	  je		task4DecTask1Prio
	  
	  jmp		task4GetChar
	  
task4IncTask3Prio:
	  mov		eax, [task4Priorities + 8]
	  cmp		eax, PRIORITY_MAXIMUM
	  jae		task4GetChar
	  inc 		eax
	  mov 		[task4Priorities + 8], eax
	  push		eax
	  push		DWORD 2
	  call		setTaskPriority
	  call		task4Print3Priority
	  jmp		task4GetChar
	  
task4DecTask3Prio:
	  mov		eax, [task4Priorities + 8]
	  cmp		eax, 0
	  je		task4GetChar
	  dec 		eax
	  mov 		[task4Priorities + 8], eax
	  push		eax
	  push		DWORD 2
	  call		setTaskPriority
	  add		esp, 8
	  call		task4Print3Priority
	  jmp		task4GetChar

task4IncTask2Prio:
	  mov		eax, [task4Priorities + 4]
	  cmp		eax, PRIORITY_MAXIMUM
	  jae		task4GetChar
	  inc 		eax
	  mov 		[task4Priorities + 4], eax
	  push		eax
	  push		DWORD 1
	  call		setTaskPriority
	  call		task4Print2Priority
	  jmp		task4GetChar
	  
task4DecTask2Prio:
	  mov		eax, [task4Priorities + 4]
	  cmp		eax, 0
	  je		task4GetChar
	  dec 		eax
	  mov 		[task4Priorities + 4], eax
	  push		eax
	  push		DWORD 1
	  call		setTaskPriority
	  add		esp, 8
	  call		task4Print2Priority
	  jmp		task4GetChar
	  
task4IncTask1Prio:
	  mov		eax, [task4Priorities]
	  cmp		eax, PRIORITY_MAXIMUM
	  jae		task4GetChar
	  inc 		eax
	  mov 		[task4Priorities], eax
	  push		eax
	  push		DWORD 0
	  call		setTaskPriority
	  call		task4Print1Priority
	  jmp		task4GetChar
	  
task4DecTask1Prio:
	  mov		eax, [task4Priorities]
	  cmp		eax, 0
	  je		task4GetChar
	  dec 		eax
	  mov 		[task4Priorities], eax
	  push		eax
	  push		DWORD 0
	  call		setTaskPriority
	  add		esp, 8
	  call		task4Print1Priority
	  jmp		task4GetChar

;********************************************************************************
;@fn		void task4Print3Priority()
;@brief		Codigo que se encargar de imprimir la prioridad de la tarea 3
;********************************************************************************
task4Print3Priority:
	  push		ebp
	  mov 		ebp, esp
	  push		esi
	  ; Cargo la posicion del vector de prioridades con su offset
	  mov		esi, task4Priorities + 8	
	  ; Imprimo el vector sobre un array de chars
 	  push		DWORD task4PrioStr 	  
 	  push		DWORD [esi]
 	  call		printNumberToArray
 	  add		esp, 8
 	  ; Imprimo el vector en pantalla
	  push		DWORD VIDEO_WORD_FOREGROUND_BLUE_MASK | VIDEO_WORD_FOREGROUND_RED_MASK | VIDEO_WORD_FOREGROUND_GREEN_MASK | VIDEO_WORD_INTENSITY_MASK
	  push		DWORD 18
	  push		DWORD 9  
	  push		DWORD task4PrioStr
	  call		print
	  add		esp, 16
	  ; Libero pila
	  pop		esi
	  pop		ebp
	  ret
;********************************************************************************
;@fn		void task4Print2Priority()
;@brief		Codigo que se encargar de imprimir la prioridad de la tarea 2
;********************************************************************************
task4Print2Priority:
	  push		ebp
	  mov 		ebp, esp
	  push		esi
	  ; Cargo la posicion del vector de prioridades con su offset  
	  mov		esi, task4Priorities + 4
	  ; Imprimo el vector sobre un array de chars
 	  push		DWORD task4PrioStr 	  
 	  push		DWORD [esi]
 	  call		printNumberToArray
 	  add		esp, 8
 	  ; Imprimo el vector en pantalla
	  push		DWORD VIDEO_WORD_FOREGROUND_BLUE_MASK | VIDEO_WORD_FOREGROUND_RED_MASK | VIDEO_WORD_FOREGROUND_GREEN_MASK | VIDEO_WORD_INTENSITY_MASK
	  push		DWORD 17
	  push		DWORD 9  
	  push		DWORD task4PrioStr
	  call		print
	  add		esp, 16
	  ; Libero pila
	  pop		esi
	  pop		ebp
	  ret
;********************************************************************************
;@fn		void task4Print1Priority()
;@brief		Codigo que se encargar de imprimir la prioridad de la tarea 2
;********************************************************************************
task4Print1Priority:
	  push		ebp
	  mov 		ebp, esp
	  push		esi
	  ; Cargo la posicion del vector de prioridades con su offset  
	  mov		esi, task4Priorities
	  ; Imprimo el vector sobre un array de chars
 	  push		DWORD task4PrioStr 	  
 	  push		DWORD [esi]
 	  call		printNumberToArray
 	  add		esp, 8
 	  ; Imprimo el vector en pantalla
	  push		DWORD VIDEO_WORD_FOREGROUND_BLUE_MASK | VIDEO_WORD_FOREGROUND_RED_MASK | VIDEO_WORD_FOREGROUND_GREEN_MASK | VIDEO_WORD_INTENSITY_MASK
	  push		DWORD 16
	  push		DWORD 9  
	  push		DWORD task4PrioStr
	  call		print
	  add		esp, 16
	  ; Libero pila
	  pop		esi
	  pop		ebp
	  ret