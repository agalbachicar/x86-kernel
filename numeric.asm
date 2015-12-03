;#########################################################################
;@file		numeric.asm
;@brief		Libreria para trabajar con numeros en general
;	    	Intel x86 compatible en 32 bit. 
;@author	Agustin Alba Chicar
;@date		Octubre, 2015
;#########################################################################


;********************************************************************************
; Simbolos externos y globales
;********************************************************************************

GLOBAL		numericGetRandomNumber
GLOBAL		numericRandomLoadSeed


;********************************************************************************
; Defines
;********************************************************************************
%define		NUMERIC_RANDOM_MULTIPLIER	0x3141		;Multiplicador
%define		NUMERIC_RANDOM_OFFSET		0x11235813	;Sumando
;********************************************************************************
; Datos inicializados
;********************************************************************************
section		.data

;********************************************************************************
;@var		numericSeed
;@brief		Variable estatica que utiliza la libreria para mantener la semilla
;	   	de los numeros aleatorios.
;********************************************************************************	
numericSeed	dd	0x0

;********************************************************************************
; Datos no inicializados
;********************************************************************************

USE32
section		.library


;********************************************************************************
;@fn		numericRandomLoadSeed(void)
;@brief		Permite cargar la semilla con el valor de la cuenta del timer
;********************************************************************************	
numericRandomLoadSeed:
	  push 		ebp
	  mov		ebp, esp		; Cargo el valor de esp por si me interrupen	  	  	
	  push		eax			; Guard el valor de eax en la pila
	  rdtsc					; Cargo el valor de la cuenta del timer en eax
	  mov		[numericSeed], eax	; Paso el valor del timer a la semilla
	  pop		eax			; Retorno eax
	  pop		ebp			; Pop ebp
	  ret
;********************************************************************************
;@fn		numericGetRandomNumber(void)
;@brief		Calcula un numero pseudo aleatorio a partir de la cuenta del timer.
;@details	La cuenta la efectua como la siguiente operación:
;		numeroAleatorio = seed * NUMERIC_RANDOM_MULTIPLIER + NUMERIC_RANDOM_OFFSET
;@retval	Numero aleatorio de 32bit en eax
;********************************************************************************		
numericGetRandomNumber:
	  push 		ebp
	  mov		ebp, esp		; Cargo el valor de esp por si me interrupen
	  push		ebx			; Guardo el valor de ebx en la pila ya que lo voy a usar para la multiplicacion
	  push		edx			; Guardo el valor de edx en la pila ya que se ve afectado por la multiplicacion
	  mov		eax, [numericSeed]	; Paso el numero de la semilla a eax
	  mov		ebx, NUMERIC_RANDOM_MULTIPLIER	; Cargo el valor del multiplicador en ebx
	  mul		bx			; Multiplico eax con bx
	  add		eax, NUMERIC_RANDOM_OFFSET ; Sumo el offset
	  mov		[numericSeed], eax	; Guardo nuevamente en la semilla
	  pop		edx			; Retorno el valor de edx
	  pop		ebx			; Retorno el valor de ebx
	  pop		ebp			; Pop ebp
	  ret	