;#########################################################################
;
;@file		exception.asm
;@brief		Handlers de excepciones
;	    	Intel x86 compatible en 32 bit. 
;@author	Agustin Alba Chicar
;@date		Octubre, 2015
;@details	
;#########################################################################

USE32							; Modelo de 32 bits

;********************************************************************************
; Simbolos externos y globales
;********************************************************************************

%include 	"video.inc"
%include 	"pagination.inc"

GLOBAL		exceptionLoadHandlers
GLOBAL		exceptionSetNewPagePointer
GLOBAL		exceptionSetNewDestinationPointer

;Simbolos de video
EXTERN			videoPrint
EXTERN			videoClearScreen

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
EXTERN			tssSchedulerSelector
EXTERN			callKernelGateSelector
EXTERN			IDT

;********************************************************************************
; Defines
;********************************************************************************
%define			ERROR_CODE_DIVIDE_BY_ZERO	'a'
%define			ERROR_CODE_DEBUG		'b'
%define			ERROR_CODE_NON_MASKABLE		'c'
%define			ERROR_CODE_BREAKPOINT		'd'
%define			ERROR_CODE_OVERFLOW		'e'
%define			ERROR_CODE_RANGE_EXCEEDED	'f'
%define			ERROR_CODE_INVALID_OPCODE	'g'
%define			ERROR_CODE_DEVICE_NOT_AVAILABLE	'h'
%define			ERROR_CODE_DOUBLE_FAULT		'i'
%define			ERROR_CODE_COPROCESSOR_SEG_OV	'j'
%define			ERROR_CODE_INVALID_TSS		'k'
%define			ERROR_CODE_SEGMENT_NOT_PRESENT	'l'
%define			ERROR_CODE_STACK_SEGMENT	'm'
%define			ERROR_CODE_GENERAL_PROTECTION	'n'
%define			ERROR_CODE_PAGE_FAULT		'o'
%define			ERROR_CODE_X87_FLOATING_POINT	'p'
%define			ERROR_CODE_ALIGNMENT_CHECK_IDT	'q'
%define			ERROR_CODE_MACHINE_CHECK	'r'
%define			ERROR_CODE_SIMD			's'
%define			ERROR_CODE_VIRTUALIZATION	't'
%define			ERROR_CODE_SECURITY		'u'

;********************************************************************************
; Datos inicializados
;********************************************************************************
SECTION  	.data
exceptionMessage	db "e",NULL

pfPointer		dd	0x00	; Puntero a la tabla de directorio
pfPTP			dd	0x00	; Puntero a la tabla de pagina
pageNewTablePointer	dd	0x00	; Puntero a la nueva tabla de paginacion a crear
pageDestinationPointer	dd	0x00	; Puntero a la nueva dirección fisica a marcar


;********************************************************************************
; Codigo de las excepciones
;********************************************************************************
SECTION  	.main32 		progbits

;********************************************************************************
; @fn		exceptionLoadHandlers()
; @brief	Carga la definicion de los handlers de las excepciones en la IDT
;********************************************************************************
exceptionLoadHandlers:
	mov	eax, divideByZeroErrorHandler
	mov	[IDT + 0x0 * 8], ax		;Parte baja
	shr	eax, 16					;Roto 16bit
	mov	[IDT+ 0x0 * 8 + 6], ax		;Parte alta

	mov	eax, debugHandler
	mov	[IDT + 0x1 * 8], ax		;Parte baja
	shr	eax, 16					;Roto 16bit
	mov	[IDT+ 0x1 * 8 + 6], ax		;Parte alta
	
	mov	eax, nonmaskableInterruptHandler
	mov	[IDT + 0x2 * 8], ax		;Parte baja
	shr	eax, 16					;Roto 16bit
	mov	[IDT+ 0x2 * 8 + 6], ax		;Parte alta
	
	mov	eax, breakpointHandler
	mov	[IDT + 0x3 * 8], ax		;Parte baja
	shr	eax, 16					;Roto 16bit
	mov	[IDT+ 0x3 * 8 + 6], ax		;Parte alta
		
	mov	eax, overflowHandler
	mov	[IDT + 0x4 * 8], ax		;Parte baja
	shr	eax, 16					;Roto 16bit
	mov	[IDT+ 0x4 * 8 + 6], ax		;Parte alta
		
	mov	eax, boundRangeExceededHandler
	mov	[IDT + 0x5 * 8], ax		;Parte baja
	shr	eax, 16					;Roto 16bit
	mov	[IDT+ 0x5 * 8 + 6], ax		;Parte alta
		
	mov	eax, invalidOpCodeHandler
	mov	[IDT + 0x6 * 8], ax		;Parte baja
	shr	eax, 16					;Roto 16bit
	mov	[IDT+ 0x6 * 8 + 6], ax		;Parte alta
		
	mov	eax, deviceNotAvailalbleHandler
	mov	[IDT + 0x7 * 8], ax		;Parte baja
	shr	eax, 16					;Roto 16bit
	mov	[IDT+ 0x7 * 8 + 6], ax		;Parte alta
		
	mov	eax, doubleFaultHandler
	mov	[IDT + 0x8 * 8], ax		;Parte baja
	shr	eax, 16					;Roto 16bit
	mov	[IDT+ 0x8 * 8 + 6], ax		;Parte alta
		
	mov	eax, coprocessorSegmentOverrunHandler
	mov	[IDT + 0x9 * 8], ax		;Parte baja
	shr	eax, 16					;Roto 16bit
	mov	[IDT+ 0x9 * 8 + 6], ax		;Parte alta
		
	mov	eax, invalidTSSHandler
	mov	[IDT + 0xA * 8], ax		;Parte baja
	shr	eax, 16					;Roto 16bit
	mov	[IDT+ 0xA * 8 + 6], ax		;Parte alta
		
	mov	eax, segmentNotPresentHandler
	mov	[IDT + 0xB * 8], ax		;Parte baja
	shr	eax, 16					;Roto 16bit
	mov	[IDT+ 0xB * 8 + 6], ax		;Parte alta
		
	mov	eax, stackSegmentFaultHandler
	mov	[IDT + 0xC * 8], ax		;Parte baja
	shr	eax, 16					;Roto 16bit
	mov	[IDT+ 0xC * 8 + 6], ax		;Parte alta
	
	mov	eax, generalProtectionFaultHandler
	mov	[IDT + 0xD * 8], ax		;Parte baja
	shr	eax, 16					;Roto 16bit
	mov	[IDT+ 0xD * 8 + 6], ax		;Parte alta
		
	mov	eax, pageFaultHandler
	mov	[IDT + 0xE * 8], ax		;Parte baja
	shr	eax, 16					;Roto 16bit
	mov	[IDT+ 0xE * 8 + 6], ax		;Parte alta
		
	mov	eax, x87FloatingPointExceptionHandler
	mov	[IDT + 0x10 * 8], ax		;Parte baja
	shr	eax, 16					;Roto 16bit
	mov	[IDT+ 0x10 * 8 + 6], ax		;Parte alta
		
	mov	eax, alignmentCheckIDTHandler
	mov	[IDT + 0x11 * 8], ax		;Parte baja
	shr	eax, 16					;Roto 16bit
	mov	[IDT+ 0x11 * 8 + 6], ax		;Parte alta
		
	mov	eax, machineCheckHandler
	mov	[IDT + 0x12 * 8], ax		;Parte baja
	shr	eax, 16					;Roto 16bit
	mov	[IDT+ 0x12 * 8 + 6], ax		;Parte alta
		
	mov	eax, simdFloatingPointExceptionHandler
	mov	[IDT + 0x13 * 8], ax		;Parte baja
	shr	eax, 16					;Roto 16bit
	mov	[IDT+ 0x13 * 8 + 6], ax		;Parte alta
		
	mov	eax, virtualizationExceptionHandler
	mov	[IDT + 0x14 * 8], ax		;Parte baja
	shr	eax, 16					;Roto 16bit
	mov	[IDT+ 0x14 * 8 + 6], ax		;Parte alta
		
	mov	eax, securityExceptionHandler
	mov	[IDT + 0x1E * 8], ax		;Parte baja
	shr	eax, 16					;Roto 16bit
	mov	[IDT+ 0x1E * 8 + 6], ax		;Parte alta
	
	ret

;********************************************************************************
; @fn		exceptionSetNewPagePointer(void *newPagePointer)
; @brief	Setter de la direccion de memoria para la nueva tabla de paginacion
;********************************************************************************	
exceptionSetNewPagePointer:
	push	ebp				; Guardo los registros
	mov	ebp, esp
	push 	eax
	push	ebx
	mov	eax, [ebp + 8]			; Cargo el valor en eax
	mov	ebx, pageNewTablePointer	; Obtengo el valor del puntero a la nueva tabla de paginacion
	mov	[ebx], eax			; Cargo el valor que recibi
	pop	ebx
	pop	eax
	pop	ebp
	ret
;********************************************************************************
; @fn		exceptionSetNewDestinationPointer(void *newPagePointer)
; @brief	Setter de la direccion de memoria para la nueva direccion paginada (fisica no lineal)
;********************************************************************************	
exceptionSetNewDestinationPointer:
	push	ebp				; Guardo los registros
	mov	ebp, esp
	push 	eax
	push	ebx
	mov	eax, [ebp + 8]			; Cargo el valor en eax
	mov	ebx, pageDestinationPointer	; Obtengo el valor del puntero a la nueva tabla de paginacion
	mov	[ebx], eax			; Cargo el valor que recibi
	pop	ebx
	pop	eax
	pop	ebp
	ret
	
;********************************************************************************
; @fn		divideByZeroErrorHandler
; @brief	Handler de excepcion de division por cero
;********************************************************************************
divideByZeroErrorHandler:
	xchg	bx,bx
	mov	al, ERROR_CODE_DIVIDE_BY_ZERO
	jmp	undefinedHandlerException

;********************************************************************************
; @fn		debugHandler
; @brief	Handler de excepcion de debug
;********************************************************************************	
debugHandler:
	xchg	bx,bx
	mov	al, ERROR_CODE_DEBUG
	jmp	undefinedHandlerException

;********************************************************************************
; @fn		nonmaskableInterruptHandler
; @brief	Handler de excepcion de interrupcion no enmascarable
;********************************************************************************	
nonmaskableInterruptHandler:
	xchg	bx,bx		;Magix breakpoint
	mov	al, ERROR_CODE_NON_MASKABLE
	jmp	undefinedHandlerException

;********************************************************************************
; @fn		breakpointHandler
; @brief	Handler de excepcion de breakpoint
;********************************************************************************	
breakpointHandler:
	xchg	bx,bx
	mov	al, ERROR_CODE_BREAKPOINT
	jmp	undefinedHandlerException

;********************************************************************************
; @fn		overflowHandler
; @brief	Handler de excepcion de overflow
;********************************************************************************
overflowHandler:
	xchg	bx,bx
	mov	al, ERROR_CODE_OVERFLOW
	jmp	undefinedHandlerException

;********************************************************************************
; @fn		boundRangeExceededHandler
; @brief	Handler de excepcion de bound range exceeded
;********************************************************************************	
boundRangeExceededHandler:
	xchg	bx,bx
	mov	al, ERROR_CODE_RANGE_EXCEEDED
	jmp	undefinedHandlerException

;********************************************************************************
; @fn		boundRangeExceededHandler
; @brief	Handler de excepcion de opcode invalido
;********************************************************************************		
invalidOpCodeHandler:
	xchg	bx,bx
	mov	al, ERROR_CODE_INVALID_OPCODE
	jmp	undefinedHandlerException

;********************************************************************************
; @fn		deviceNotAvailalbleHandler
; @brief	Handler de excepcion de dispositivo invalido
;********************************************************************************			
deviceNotAvailalbleHandler:
	xchg	bx,bx
	mov	al, ERROR_CODE_DEVICE_NOT_AVAILABLE
	jmp	undefinedHandlerException
	
;********************************************************************************
; @fn		doubleFaultHandler
; @brief	Handler de excepcion de doble falta
;********************************************************************************				
doubleFaultHandler:
	xchg	bx,bx
	mov	al, ERROR_CODE_DOUBLE_FAULT
	jmp	undefinedHandlerException

;********************************************************************************
; @fn		coprocessorSegmentOverrunHandler
; @brief	Handler de excepcion de overrun de segmento de coprocesador
;********************************************************************************					
coprocessorSegmentOverrunHandler:
	xchg	bx,bx
	mov	al, ERROR_CODE_COPROCESSOR_SEG_OV
	jmp	undefinedHandlerException

;********************************************************************************
; @fn		invalidTSSHandler
; @brief	Handler de excepcion de TSS invalido
;********************************************************************************						
invalidTSSHandler:
	xchg	bx,bx
	mov	al, ERROR_CODE_INVALID_TSS
	jmp	undefinedHandlerException

;********************************************************************************
; @fn		segmentNotPresentHandler
; @brief	Handler de excepcion de segmento no presente
;********************************************************************************							
segmentNotPresentHandler:
	xchg	bx,bx
	mov	al, ERROR_CODE_SEGMENT_NOT_PRESENT
	jmp	undefinedHandlerException

;********************************************************************************
; @fn		stackSegmentFaultHandler
; @brief	Handler de excepcion de segmento de stack
;********************************************************************************
stackSegmentFaultHandler:
	xchg	bx,bx
	mov	al, ERROR_CODE_STACK_SEGMENT
	jmp	undefinedHandlerException

;********************************************************************************
; @fn		generalProtectionFaultHandler
; @brief	Handler de excepcion de proteccion general
;********************************************************************************
generalProtectionFaultHandler:
	xchg	bx,bx
	mov	al, ERROR_CODE_GENERAL_PROTECTION
	jmp	undefinedHandlerException

;********************************************************************************
; @fn		pageFaultHandler
; @brief	Handler de excepcion de fallo de pagina
;********************************************************************************
pageFaultHandler:
	xchg	bx, bx
	push	ebx
	push	eax
	mov	eax, [esp + 16]	; Obtengo el codigo de error
	and	eax, PTDP_ATTRIBUTE; Aplico una and para concer el estado de presencia de la dirección lineal que se desea acceder
	jnz	pageFaultPresent; Como la pagina esta presente el problema es otro
	
; Evaluo si la entrada de la PDPT esta presente
pageFaultTestPDPT:
	mov	eax, cr2	; Paso a eax el valor de la direccion lineal que produjo el fallo de pagina
	shr	eax, PDPT_ROTATION_BITS; Roto 30 bits
	and	eax, PDPT_ENTRY_MASK	; Andeo para comparar y evaluar si hay una entrada presente en los punteros a tabla de directorio de paginas
	mov	ebx, PAE_ENTRY_SIZE; Paso a ebx el valor de 8
	mul	ebx		; Multiplico por el numero de bytes de las entradas de la PDPT
	mov	ebx, cr3	; Traigo el valor de CR3 = PDPT a ebx
	add	eax, ebx	; Incremento el puntero eax a ebx
	mov	[pfPointer], eax; Cargo el puntero
	mov	ebx, [eax]	; Cargo el contenido de esa entrada y evaluo si está presente
	and	ebx, PTDP_ATTRIBUTE; Andeo
	jz	pageFaultDirectoryAbscent
;Tengo que evaluar si la entrada de tabla de pagina existe o no
pageFaultTestDPT:
	mov	eax, cr2	; Paso nuevamente la dirección lineal a eax
	shr	eax, DPT_ROTATION_BITS; Roto
	and	eax, TABLE_OFFSET_MASK	; Aplico la mascara para quedarme con la dirección lineal correcta
	mov	ebx, PAE_ENTRY_SIZE
	mul	ebx		; Multiplico por 8	
	mov	ebx, [pfPointer]; Paso ebx la dirección que esta en la tabla de punteros de tablas de directorios
	mov	ebx, [ebx]
	and 	ebx, TABLE_ENTRY_MASK; Aplico mascara para manter la direccion y olvidarme de los atributos
	add	eax, ebx	; Puntero en eax a la tabla de directorios para evaluar la tabla de paginas si esta presente y con permisos
	mov	[pfPointer], eax; Guardo el puntero al directorio de paginas
	mov	ebx, [eax]	; Aca tengo en ebx el puntero a la tabla de paginas si es que existe
	and 	ebx, PTDP_ATTRIBUTE; Aplico la and para chequear que la tabla de paginas este presente
	jz	pageFaultPageTableAbscent	
;Tengo que evaluar si hay entrada de pagina
pageFaultTestPT:	
	mov	eax, cr2	; Paso nuevamente la direccion lineal
	shr	eax, PT_ROTATION_BITS; Roto
	and 	eax, TABLE_OFFSET_MASK; Aplico mascara
	mov	ebx, PAE_ENTRY_SIZE; Cargo el tamaño de entrada
	mul	ebx		; Multiplico
	mov	ebx, [pfPointer]; Obtengo el puntero a la entrada de la tabla de paginas
	mov	ebx, [ebx]
	and 	ebx, TABLE_ENTRY_MASK; Aplico la mascara por los atributos
	add	eax, ebx	; Sumo el offset
	mov	ebx, [pageDestinationPointer]; Obtengo la nueva direccion
	or	ebx, ENTRY_ATTRIBUTE; Aplico los atributos
	mov	[eax], ebx	; Cargo la direccion de la nueva pagina
	mov	ebx, [pageDestinationPointer]; Obtengo la vieja direccion
	add	ebx, PAGE_SIZE	; Sumo el tamaño de pagina
	mov 	[pageDestinationPointer], ebx
	jmp	pageFaultEnd	; Termino
	
pageFaultDirectoryAbscent:
; Faltaba la entrada de directorio y en eax tengo la dirección del offset donde cargar la nueva entrada
; Debo crear: tabla de directorio, tabla de pagina y entrada de la pagina.
; En eax tengo la direccion de memoria a donde debiera dejar la dirección de la tabla de directorio
	mov	ebx, [pageNewTablePointer] ; Paso a ebx el puntero a la tabla de directorios
	or	ebx, PTDP_ATTRIBUTE; Aplico una or a ebx para colocar los atributos
	mov	[eax], ebx	; Cargo el puntero en ebx a la tabla de atributos
	mov	eax, [pageNewTablePointer] ; Obtengo el anterior puntero, le sumo el tamaño de una pagina y lo vuelvo a cargar en el puntero
	mov	[pfPointer], eax
	add	eax, PAGE_SIZE
	mov	[pageNewTablePointer], eax
	mov	eax, cr2	; Obtengo la dirección lineal que genero 
	shr	eax, DPT_ROTATION_BITS; Roto la dirección 12 bits para quedarme con el offset de la dirección 
	and	eax, TABLE_OFFSET_MASK; Andeo para quedarme con los bits
	mov	ebx, PAE_ENTRY_SIZE
	mul	ebx		; Multiplico por 8 y ya tengo el offset en eax de la entrada de pagina
	mov	ebx, [pfPointer]; Obtengo el puntero y me voy a mover el offset
	add	eax, ebx	; Tengo entonces en eax la dirección en donde debo cargar el puntero a la entrada de página
	
pageFaultPageTableAbscent:
; Tengo entrada en la PDPT para la tabla de directorio pero en la tabla de directorio no tengo una entrada
; a una tabla de directorio valida. Entonces simplemente lo que hacemos es crear una tabla con una entrada valida
; En eax tengo la direccion de memoria a donde debiera dejar la dirección de la tabla de paginas
	mov	ebx, [pageNewTablePointer] ; Paso a ebx el puntero a la tabla de paginas
	or	ebx, ENTRY_ATTRIBUTE; Aplico una or a ebx para colocar los atributos
	mov	[eax], ebx	; Cargo el puntero en ebx a la tabla de pagianas
	mov	eax, [pageNewTablePointer] ; Obtengo el anterior puntero, le sumo el tamaño de una pagina y lo vuelvo a cargar en el puntero
	mov	[pfPointer], eax
	add	eax, PAGE_SIZE
	mov	[pageNewTablePointer], eax
	
pageFaultPageTableWrite:	
	mov	eax, cr2	; Obtengo la dirección lineal que genero 
	shr	eax, PT_ROTATION_BITS; Roto la dirección 12 bits para quedarme con el offset de la dirección 
	and	eax, TABLE_OFFSET_MASK; Andeo para quedarme con los bits
	mov	ebx, PAE_ENTRY_SIZE
	mul	ebx		; Multiplico por 8 y ya tengo el offset en eax de la entrada de pagina
	mov	ebx, [pfPointer]; Obtengo el puntero y me voy a mover el offset
	add	eax, ebx	; Tengo entonces en eax la dirección en donde debo cargar el puntero a la entrada de página
	mov 	ebx, [pageDestinationPointer]
	or	ebx, ENTRY_ATTRIBUTE
	mov 	[eax], ebx	; Cargo ya con los atributos la nueva direccion de la pagina
	mov 	ebx, [pageDestinationPointer]
	add	ebx, PAGE_SIZE
	mov 	[pageDestinationPointer], ebx
	jmp	pageFaultEnd
	
pageFaultEnd:	
	mov 	eax, cr3
	mov 	cr3, eax
	pop	eax		; Restauro edx
	pop	ebx		; Restauro ebx
	add	esp, 4		; Restauro la pila por el error code pusheado
	xchg	bx, bx
	iret
	
pageFaultPresent:
	nop	
	jmp	$-1
	
;********************************************************************************
; @fn		x87FloatingPointExceptionHandler
; @brief	Handler de excepcion de unidad de punto flotante
;********************************************************************************
x87FloatingPointExceptionHandler:
	xchg	bx,bx
	mov	al, ERROR_CODE_X87_FLOATING_POINT
	jmp	undefinedHandlerException
	
;********************************************************************************
; @fn		alignmentCheckIDTHandler
; @brief	Handler de excepcion de check de alineacion de IDT
;********************************************************************************
alignmentCheckIDTHandler:
	xchg	bx,bx
	mov	al, ERROR_CODE_ALIGNMENT_CHECK_IDT
	jmp	undefinedHandlerException
	
;********************************************************************************
; @fn		machineCheckHandler
; @brief	Handler de excepcion de check de maquina
;********************************************************************************
machineCheckHandler:
	xchg	bx,bx
	mov	al, ERROR_CODE_MACHINE_CHECK
	jmp	undefinedHandlerException

;********************************************************************************
; @fn		simdFloatingPointExceptionHandler
; @brief	Handler de excepcion de SIMD
;********************************************************************************
simdFloatingPointExceptionHandler:
	xchg	bx,bx
	mov	al, ERROR_CODE_SIMD
	jmp	undefinedHandlerException
	
;********************************************************************************
; @fn		virtualizationExceptionHandler
; @brief	Handler de excepcion de virtualizacion
;********************************************************************************
virtualizationExceptionHandler:
	xchg	bx,bx
	mov	al, ERROR_CODE_VIRTUALIZATION
	jmp	undefinedHandlerException

;********************************************************************************
; @fn		securityExceptionHandler
; @brief	Handler de excepcion de seguridad
;********************************************************************************
securityExceptionHandler:
	xchg	bx,bx
	mov	al, ERROR_CODE_SECURITY
	jmp	undefinedHandlerException

;********************************************************************************
; @fn		undefinedHandlerException
; @brief	El código llega a este punto cuando no tiene un handler definido
;		para la excepcion pero la interrupcion se produce
;********************************************************************************
undefinedHandlerException:
	xchg		bx,bx		;Magix breakpoint
	call		videoClearScreen
	push		VIDEO_WORD_FOREGROUND_RED_MASK | VIDEO_WORD_INTENSITY_MASK
	push		0
	push		0
	mov		[exceptionMessage], al
	push		exceptionMessage
	call		videoPrint
	add		esp, 16
	hlt
	jmp		$-1
	iret
	