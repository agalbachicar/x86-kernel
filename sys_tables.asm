;#########################################################################
;
;@file		sys_tables.asm
;@brief		Este archivo contiene la descripcion de las tablas de 
;		segmentacion, en modelo FLAT, las tablas de la IDT
;	    	Intel x86 compatible en 32 bit. 
;@author	Agustin Alba Chicar
;@date		Septiembre, 2015
;@details	
;#########################################################################

USE32						;Modelo de 32 bit


;********************************************************************************
; Símbolos externos e inclusiones
;********************************************************************************

%include	"system.inc"

GLOBAL		GDT32
GLOBAL		GDTR32
GLOBAL		nullSelector
GLOBAL		codeKernelSelector
GLOBAL		codeUserSelector
GLOBAL		dataKernelSelector
GLOBAL		dataUserSelector
GLOBAL		tssInitSelector

GLOBAL		IDT
GLOBAL		IDTR

GLOBAL		IDT_keyPressed
GLOBAL		IDT_timer
GLOBAL		IDT_intGate

GLOBAL		PDPT
GLOBAL		pdptKernel
GLOBAL		pdptTask1
GLOBAL		pdptTask2
GLOBAL		pdptTask3
GLOBAL		pdptTask4

GLOBAL		tssInit


;********************************************************************************
; Alineacion y seccion
;********************************************************************************
SECTION		.sys_tables 	progbits
ALIGN 4

;********************************************************************************
; GDT de 32bit, modo protegido, modelo flat
;********************************************************************************
GDT32:
nullSelector		equ	$-GDT32		;Selector nulo de 32bit
			dq	0x0
codeKernelSelector  	equ 	$-GDT32		;Selector de codigo de 32bit para Kernel
			dw 	0xFFFF 
			dw 	0x0000
			db 	0x00
			db 	0x9A
			db 	0xCF
			db 	0
codeUserSelector  	equ 	$-GDT32		;Selector de codigo de 32bit para Usuario
			dw	0xFFFF 
			dw	0x0000
			db	0x00
			db	0xFA
			db	0xCF
			db	0
dataKernelSelector  	equ 	$-GDT32		;Selector de datos de 32bit para Kernel
			dw 	0xFFFF 
			dw 	0x0000
			db 	0x00
			db 	0x92
			db 	0xCF
			db 	0	
dataUserSelector  	equ 	$-GDT32		;Selector de datos de 32bit para Usuario
			dw 	0xFFFF 
			dw 	0x0000
			db 	0x00
			db 	0xF2
			db 	0xCF
			db 	0
tssInitSelector		equ 	$-GDT32
			dw	104-1
			dw	0
			db	0
			db	89h
			dw	0		
			
GDT32_LENGTH 	equ 	$-GDT32		;Tamaño de la tabla de GDT32

GDTR32:					;Registro de 
			dw 	GDT32_LENGTH-1
			dd 	GDT32

;********************************************************************************
; IDT
;********************************************************************************	

IDT:
IDT_divideByZeroError:
	dw	0			;Handler 0
	dw	codeKernelSelector
	db	0
	db	0x8F
	dw	0
	
IDT_debug:
	dw	0			;Handler 1
	dw	codeKernelSelector
	db	0
	db	0x8F
	dw	0
	
IDT_nonmaskableInterrupt:
	dw	0			;Handler 2
	dw	codeKernelSelector
	db	0
	db	0x8F
	dw	0
	
IDT_breakpoint:
	dw	0			;Handler 3
	dw	codeKernelSelector
	db	0
	db	0x8F
	dw	0
	
IDT_overflow:
	dw	0			;Handler 4
	dw	codeKernelSelector
	db	0
	db	0x8F
	dw	0
	
IDT_boundRangeExceeded:
	dw	0			;Handler 5
	dw	codeKernelSelector
	db	0
	db	0x8F
	dw	0
	
IDT_invalidOpCode:
	dw	0			;Handler 6
	dw	codeKernelSelector
	db	0
	db	0x8F
	dw	0
	
IDT_deviceNotAvailalble:
	dw	0			;Handler 7
	dw	codeKernelSelector
	db	0
	db	0x8F
	dw	0
	
IDT_doubleFault:
	dw	0			;Handler 8
	dw	codeKernelSelector
	db	0
	db	0x8F
	dw	0
	
IDT_coprocessorSegmentOverrun:
	dw	0			;Handler 9
	dw	codeKernelSelector
	db	0
	db	0x8F
	dw	0
	
IDT_invalidTSS:
	dw	0			;Handler 10
	dw	codeKernelSelector
	db	0
	db	0x8F
	dw	0
	
IDT_segmentNotPresent:
	dw	0			;Handler 11
	dw	codeKernelSelector
	db	0
	db	0x8F
	dw	0
	
IDT_stackSegmentFault:
	dw	0			;Handler 12
	dw	codeKernelSelector
	db	0
	db	0x8F
	dw	0
	
IDT_generalProtectionFault:
	dw	0			;Handler 13
	dw	codeKernelSelector
	db	0
	db	0x8F
	dw	0
	
IDT_pageFault:
	dw	0			;Handler 14
	dw	codeKernelSelector
	db	0
	db	0x8F
	dw	0
	
IDT_reservedException15:		;Handler 15
	dd	0,0
	
IDT_x87FloatingPointException:
	dw	0			;Handler 16
	dw	codeKernelSelector
	db	0
	db	0x8F
	dw	0
	
IDT_alignmentCheckIDT:
	dw	0			;Handler 17
	dw	codeKernelSelector
	db	0
	db	0x8F
	dw	0
	
IDT_machineCheck:
	dw	0			;Handler 18
	dw	codeKernelSelector
	db	0
	db	0x8F
	dw	0
	
IDT_simdFloatingPointException:
	dw	0			;Handler 19
	dw	codeKernelSelector
	db	0
	db	0x8F
	dw	0
	
IDT_virtualizationException:
	dw	0			;Handler 20
	dw	codeKernelSelector
	db	0
	db	0x8F
	dw	0
	
IDT_reservedExceptions21To29:
	dd	0,0		;Handlers 21
	dd	0,0		;Handlers 22
	dd	0,0		;Handlers 23
	dd	0,0		;Handlers 24
	dd	0,0		;Handlers 25
	dd	0,0		;Handlers 26
	dd	0,0		;Handlers 27
	dd	0,0		;Handlers 28
	dd	0,0		;Handlers 29
	
IDT_securityException:
	dw	0			;Handler 29
	dw	codeKernelSelector
	db	0
	db	0x8F
	dw	0
	
IDT_reservedException31:
	dd	0,0			;Handler 31
	
IDT_timer:	
	dw	0			;Handler 32
	dw	codeKernelSelector
	db	0
	db	0x8E
	dw	0	
	
;Fin de excepciones, comienzo de interrupciones
IDT_keyPressed:
	dw 	0			;Handler 33
	dw 	codeKernelSelector
	db 	0
	db 	0x8E
	dw 	0
	
IDT_reserved:
	times (0x80 - 0x22) dq	0x00
	
IDT_intGate:
	dw 	0			;Handler 80
	dw 	codeKernelSelector
	db 	0
	db 	0xEE
	dw 	0
	
IDT_SIZE    	equ 	$-IDT

IDTR:
	dw 	IDT_SIZE-1
        dd 	IDT
        
ALIGN 32
; Es el puntero a las tablas de directorios de pagina.
PDPT:
pdptKernel:
	dq	0
	dq	0
	dq	0
	dq	0

pdptTask1:
	dq	0
	dq	0
	dq	0
	dq	0

pdptTask2:
	dq	0
	dq	0
	dq	0
	dq	0
	
pdptTask3:
	dq	0
	dq	0
	dq	0
	dq	0
	
pdptTask4:
	dq	0
	dq	0
	dq	0
	dq	0	
; Reservo lugar para las estructuras de las tss	
tssInit:	resb	tssType.size*1

