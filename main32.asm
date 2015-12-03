;#########################################################################
;@file		main.asm
;@brief		Aplicacion principal
;	    	Intel x86 compatible en 32 bit. 
;@author	Agustin Alba Chicar
;@date		Octubre, 2015
;#########################################################################


;********************************************************************************
; Simbolos externos y globales
;********************************************************************************
%include 	"video.inc"
%include 	"pagination.inc"
%include	"fifo.inc"
%include	"keyboard.inc"

GLOBAL		main32Start
;Simbolos de video
EXTERN		videoClearScreen
EXTERN		videoPrint
;Simbolos de puertos
EXTERN 		portWrite
EXTERN 		portRead
;Simbolos de numeric
EXTERN		numericRandomLoadSeed
EXTERN		numericGetRandomNumber
;Simbolos de exception
EXTERN		exceptionLoadHandlers
EXTERN		exceptionSetNewPagePointer
EXTERN		exceptionSetNewDestinationPointer
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
;Sibmbolos del driver de sistema
EXTERN		systemSleep
EXTERN		systemEnableInterrupts
EXTERN		systemDisableInterrupts
EXTERN		systemConfigure1MSTick
EXTERN		systemGetTickCount
EXTERN		systemLoadTickHandler

;********************************************************************************
; Defines
;********************************************************************************

%define		NEW_PAGE_PHYSICAL_ADDRESS_START		0x160000

USE32
;********************************************************************************
; Datos no inicializados
;********************************************************************************

;********************************************************************************
; Datos inicializados
;********************************************************************************
SECTION 	.data		

initMessage 	db "Testeando tick...", NULL
endMessage 	db "Fin de aplicacion", NULL

;********************************************************************************
; Datos no inicializados
;********************************************************************************
SECTION 	.bss		

main32Data	resd	1
main32Buffer	resb	2
main32TickCount resd	1

;********************************************************************************
; Aplicacion principal de 32bit.
; Me pongo a leer el teclado a la espera de la presion de la tecla ESC. Primero
; testeo que haya actividad en el teclado, luego testeo la tecla propiamente dicha
; y evaluo si es la tecla ESC. Sino escribo la tecla adquirida en pantalla
;********************************************************************************
section 	.main32

main32Start:
; 	  call		exceptionLoadHandlers		; Cargo los handlers de excepciones
; 	  
; 	  call		interruptLoadHandlers		; Cargo los handlers de interupciones	  
  
	  mov		eax, keyboardISRHandler		; Cargo el callback del handler de teclado
	  push		eax
	  call 		interrruptLoadKeyboardCallback
	  add		esp, 4
	  
	  mov		eax, NEXT_TABLE_PAGE_POINTER	; Cargo en eax el valor del puntero a la proxima tabla y lo seteo
	  push		eax
	  call		exceptionSetNewPagePointer
	  add		esp, 4				; Balance de pila	  
	  mov		eax, NEW_PAGE_PHYSICAL_ADDRESS_START; Cargo el valor de la direccion fisica a donde voy a dirigir las paginas nuevas
	  push		eax
	  call		exceptionSetNewDestinationPointer
	  add		esp, 4
	  
	  call		keyboardInitFIFO		; Inicializo la FIFO del teclado
	  
; 	  call		systemConfigure1MSTick		; Configuro el tick de 1ms
; 	  call		systemLoadTickHandler		; Configuro el tick handler
	  call		systemGetTickCount		; Obtengo la cuenta de tick y despues la guardo en la variable
	  mov		[main32TickCount], eax
	  
	  call		systemEnableInterrupts		; Habilito las interrupciones
	  
	  call		videoClearScreen		; Limpio la pantalla y escribo un mensaje
	  push		VIDEO_WORD_FOREGROUND_BLUE_MASK | VIDEO_WORD_FOREGROUND_RED_MASK | VIDEO_WORD_FOREGROUND_GREEN_MASK | VIDEO_WORD_INTENSITY_MASK
	  push		0
	  push		0
	  push		initMessage
	  call		videoPrint
	  add		esp, 16	  

main32MainLoop:
	  call		systemSleep			; Duermo
	  call		systemGetTickCount		; Obtengo la cuenta de tick
	  mov		[main32TickCount], eax		; Cargo la variable
	  cmp		eax, 10000			; Comparo la cuenta de tick contra 100
	  jne		main32MainLoop			
	  
main32EndOfApp:	
	  call		systemDisableInterrupts		;Deshabilito las interrupciones
	  call		videoClearScreen		; Limpio la pantalla y escribo un mensaje
	  push		VIDEO_WORD_FOREGROUND_BLUE_MASK | VIDEO_WORD_FOREGROUND_RED_MASK | VIDEO_WORD_FOREGROUND_GREEN_MASK | VIDEO_WORD_INTENSITY_MASK
	  push		0
	  push		0
	  push		endMessage
	  call		videoPrint
	  add		esp, 16
main32EndOfAppLoop:
	  call		systemSleep
	  jmp		main32EndOfAppLoop
	  

