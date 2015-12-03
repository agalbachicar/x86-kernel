;#########################################################################
;@file		system.inc
;@brief		Defines comunes para los tipos de system
;	    	Intel x86 compatible en 32 bit. 
;@author	Agustin Alba Chicar
;@date		Octubre, 2015
;#########################################################################


;********************************************************************************
; Defines
;********************************************************************************

%define		TASKS_NUMBER		5

%define		PRIORITY_MAXIMUM	9
%define		TASK_INDEX_ARRAY_SIZE	(PRIORITY_MAXIMUM+1)

%define		SYSTEM_API_SLEEP	0x00
%define		SYSTEM_API_GET_TIME	0x01
%define		SYSTEM_API_CLS		0x02
%define		SYSTEM_API_PRINT	0x03
%define		SYSTEM_API_CHANGE_PRIO	0x04
%define		SYSTEM_API_GETCHAR	0x05
%define		SYSTEM_API_GETTASKPRIO	0x06
%define		SYSTEM_API_SETTASKPRIO	0x07
%define		SYSTEM_API_MAX		SYSTEM_API_SETTASKPRIO

%define		SYSTEM_HAS_RTC		1				; Se utiliza para actualizar el reloj con el RTC o hacerlo mediante la cuenta de ticks

%define		SYSTEM_INT_GATE_NUM	0x80
%define		SYSTEM_SCHED_NUM	0x20
;********************************************************************************
; Tipos de dato
;********************************************************************************

;********************************************************************************
;@struct	tssType
;@brief		Definicion de la estructura de la TSS
;********************************************************************************
STRUC tssType
	.link:		resd	1	; Se toca a nivel WORD
	.esp0:		resd	1	; Se toca a nivel DWORD
	.ss0:		resd	1	; Se toca a nivel WORD
	.esp1:		resd	1	; Se toca a nivel DWORD
	.ss1:		resd	1	; Se toca a nivel WORD
	.esp2:		resd	1	; Se toca a nivel DWORD
	.ss2:		resd	1	; Se toca a nivel WORD
	.cr3:		resd	1	; Se toca a nivel DWORD
	.eip:		resd	1	; Se toca a nivel DWORD
	.eflags:	resd	1	; Se toca a nivel DWORD
	.eax:		resd	1	; Se toca a nivel DWORD
	.ecx:		resd	1	; Se toca a nivel DWORD
	.edx:		resd	1	; Se toca a nivel DWORD
	.ebx:		resd	1	; Se toca a nivel DWORD
	.esp:		resd	1	; Se toca a nivel DWORD
	.ebp:		resd	1	; Se toca a nivel DWORD
	.esi:		resd	1	; Se toca a nivel DWORD
	.edi:		resd	1	; Se toca a nivel DWORD
	.es:		resd	1	; Se toca a nivel WORD
	.cs:		resd	1	; Se toca a nivel WORD
	.ss:		resd	1	; Se toca a nivel WORD
	.ds:		resd	1	; Se toca a nivel WORD
	.fs:		resd	1	; Se toca a nivel WORD
	.gs:		resd	1	; Se toca a nivel WORD
	.ldtr:		resd	1	; Se toca a nivel WORD
	.reserved	resw	1	; No se utiliza, esta reservado
	.iopOffset:	resw	1	; Se toca a nivel WORD
	.size:
ENDSTRUC

;********************************************************************************
;@struct	taskContextType
;@brief		Definicion de la estructura de la TSS
;********************************************************************************
STRUC taskContextType
	.esp0:		resd	1	; Se toca a nivel DWORD
	.topOfStack0	resd	1	; Se toca a nivel DWORD
	.ss0:		resd	1	; Se toca a nivel WORD
	.cr3:		resd	1	; Se toca a nivel DWORD
	.eax:		resd	1	; Se toca a nivel DWORD
	.ecx:		resd	1	; Se toca a nivel DWORD
	.edx:		resd	1	; Se toca a nivel DWORD
	.ebx:		resd	1	; Se toca a nivel DWORD
	.ebp:		resd	1	; Se toca a nivel DWORD
	.esi:		resd	1	; Se toca a nivel DWORD
	.edi:		resd	1	; Se toca a nivel DWORD
	.es:		resd	1	; Se toca a nivel WORD
	.ds:		resd	1	; Se toca a nivel WORD
	.fs:		resd	1	; Se toca a nivel WORD
	.gs:		resd	1	; Se toca a nivel WORD
	.size:
ENDSTRUC

;********************************************************************************
;@struct	taskType
;@brief		Estructura de datos de una tarea
;********************************************************************************
STRUC taskType
	.priority	resd	1	; Prioridad de la tarea, van de 0-9 y 0 significa que esta dormida
	.oldPriority	resd	1	; Prioridad que tenia la tarea antes de pasar al estado dormida
	.ticksToWakeUp	resd	1	; Cantidad de ticks para que se despierte. Opera en caso que se haya mandado a dormir.
	.context	resb	taskContextType.size	; Contexto de la tarea
	.size:
ENDSTRUC

;********************************************************************************
;@struct	timeType
;@brief		Estructura de datos que mantiene la hora del sistema
;********************************************************************************
STRUC timeType
	.year:		resd	1	; Año
	.month:		resd	1	; Mes	
	.date:		resd	1	; Dia
	.hour:		resd	1	; Hora
	.minute:	resd	1	; Minutos
	.second:	resd	1	; Segundos
	.milisecond:	resd	1	; Milisegundos
	.size:
ENDSTRUC
