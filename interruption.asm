;#########################################################################
;
;@file		interruption.asm
;@brief		Handlers de interrupciones
;	    	Intel x86 compatible en 32 bit. 
;@author	Agustin Alba Chicar
;@date		Agosto, 2015
;@details	
;#########################################################################

USE32							; Modelo de 32 bits

;********************************************************************************
; Simbolos externos y globales
;********************************************************************************
EXTERN		IDT
EXTERN		dataKernelSelector

GLOBAL		interruptLoadHandlers
GLOBAL		interrruptLoadKeyboardCallback
;********************************************************************************
; Defines
;********************************************************************************

;********************************************************************************
; Datos no inicializados
;********************************************************************************

;********************************************************************************
; Datos inicializados
;********************************************************************************
SECTION 	.data

interruptionKeyboardCallback	dd	0x00	; Callback a llamar en la funcion de interrupcion por teclado

;********************************************************************************
; Codigo de las excepciones
;********************************************************************************
SECTION  	.main32 		progbits

;********************************************************************************
; @fn		loadInterruptHandlers
; @brief	Carga la definicion de los handlers de las interrupciones en la IDT
;********************************************************************************
interruptLoadHandlers:
	push	ebp
	mov	ebp, esp
	push	eax
	mov	eax, interruptKeyboardHandler
	mov	[IDT + 0x21*8], ax		;Parte baja
	shr	eax, 16				;Roto 16bit
	mov	[IDT + 0x21*8 + 6], ax		;Parte alta
	pop	eax
	pop	ebp
	ret
	
;********************************************************************************
; @fn		interrruptLoadKeyboardCallback(void (*)(void))
; @brief	Setter de la funcion a llamar en el momento que se produce un keyboard interrupt
;********************************************************************************	
interrruptLoadKeyboardCallback:
	push	ebp
	mov	ebp, esp
	push	eax
	mov	eax, [ebp + 8]			; Obtengo el valor recibido como handler
	mov	[interruptionKeyboardCallback], eax
	pop	eax
	pop	ebp
	ret
;********************************************************************************
; @fn		interruptKeyboardHandler(void)
; @brief	Handler de interrupcion de teclado
; @details	Lee el scan code del teclado y le manda al PIC el End Of Interrupt.
;	  	En caso que haya callback, se llama al callback y despues se retorna
;********************************************************************************
interruptKeyboardHandler:
	  push		ds				; Push a los registros de datos
	  push		es  	
	  push		fs
	  push 		gs
	  pushad					; Push del resto de los registros
	  mov		ax, dataKernelSelector		; Cargo el selector de datos del Kernel
	  mov 		ds, ax				; 
	  mov 		es, ax
	  
	  mov		eax, [interruptionKeyboardCallback]
	  cmp		eax, 0x00	; Cargo el puntero a funcion y evaluo si el pf es NULL
	  jne		interruptionKeyboardCallbackLoad
	  in		al, 0x60	;Leo el puerto
	  mov		al, 0x20	;PIC EOI: End Of Interrupt
	  out		0x20, al	;
	  jmp		interruptKeyboardHandlerEnd
	  
interruptionKeyboardCallbackLoad:
	  call		eax		; Llamo al puntero a funcion
	  
interruptKeyboardHandlerEnd:	  
	  popad
	  pop 		gs
	  pop 		fs
	  pop 		es
	  pop 		ds	  
	  iret				; Retorno de la interrupcion
	  
	  
	  