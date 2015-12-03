;#########################################################################
;@file		video.asm
;@brief		Libreria para el manejo de la memoria de video
;	    	Intel x86 compatible en 32 bit. 
;@author	Agustin Alba Chicar
;@date		Octubre, 2015
;#########################################################################

;********************************************************************************
; Simbolos externos y globales
;********************************************************************************
GLOBAL		videoClearScreen
GLOBAL		videoPrint


%include	"video.inc"

;********************************************************************************
; Defines
;********************************************************************************
%define		VIDEO_MEMORY_START			0x280000;0xB8000
%define		VIDEO_MEMORY_COLUMNS			80
%define		VIDEO_MEMORY_ROWS			25
%define		VIDEO_MEMORY_WORD_SIZE			(VIDEO_MEMORY_COLUMNS * VIDEO_MEMORY_ROWS)
%define		VIDEO_MEMORY_SIZE			(2 * VIDEO_MEMORY_WORD_SIZE)

%define		VIDEO_WORD_CHARACTER_MASK		0x00FF

%define		string					(ebp+8)
%define		column					(ebp+12)
%define		row					(ebp+16)
%define		attribute				(ebp+20)

;********************************************************************************
; Datos no inicializados
;********************************************************************************

;********************************************************************************
; Datos inicializados
;********************************************************************************


USE32
SECTION		.library

;********************************************************************************
;@fn		videoClearScreen(void)
;@brief		Borra la memoria de video. Para ello carga el inicio y el fin de
;		la memoria de video y va cargando 0x00 en ella
;********************************************************************************	  
videoClearScreen:
	  push 		ebp
	  mov		ebp, esp	;Cargo el valor de esp por si me interrupen	  	  
	  pushad
	  push		edi
	  
	  mov		ax, VIDEO_CHARACTER_CLEAN	; Cargo en ax el valor del caracter limpio
	  mov		edi, VIDEO_MEMORY_START		; Coloco el inicio de la memoria de video
	  mov		ecx, VIDEO_MEMORY_WORD_SIZE	; Coloco el tamaño en words de la memoria de video
clrscrStore:
	  stosw						; Itero cargando un word en la memoria de video
	  loop		clrscrStore	  
	  pop		edi
	  popad
	  pop		ebp
	  ret
;********************************************************************************
;@fn		videoPrint(char *string, int32_t column, int32_t row, int32_t attribute)
;@brief		Imprime un string en la memoria de video, en fila y columna deseada con los atributos elegidos
;@param		string		([ebp + 8])	Puntero a un string. Debe terminar en '\0'
;@param		column		([ebp + 12])	Numero de columna donde se lo desea utilizar
;@param		row		([ebp + 16])	Numero de fila donde se lo desea utilizar
;@param		attribute 	([ebp + 20])	Atributo del caracter que se vaya a utilizar
;********************************************************************************	  	  
videoPrint:
	  push		ebp		;Guado ebp
	  mov		ebp, esp	;Cargo el valor de esp por si me interrupen	  
; 	  push		eax
; 	  push		ebx
; 	  push		edx
	  pushad
	  push		edi
	  push 		esi
	  
	  mov		esi, [string]	;Cargo el valor del puntero al string
	  ;Calculo el offset de memoria necesario para hacer la copia de los bytes a la memoria de video
	  ;La cuenta es ( filas * (TAMAÑO_DE_FILA) + columnas ) * 2
	  xor		eax, eax	; Pongo a cero eax
	  mov		eax, [row] 	; Muevo el numero de filas
	  mov		ebx, VIDEO_MEMORY_COLUMNS ; Cargo el numero de columnas en una fila
	  mul		ebx		; Multiplico eax con ebx
	  add		eax, [column] ; Agrego el numero de columnas
	  shl		eax, 1		; Genero la multiplicacion x2 con una rotacion a izquierda
	  
	  ;Cargo el inicio de la memoria de video
	  mov		edi, eax 	; Cargo el inicio de la memoria
	  add		edi, VIDEO_MEMORY_START	; Aumento con el offset de memoria
	  ;Cargo el valor del atributo
	  mov		edx, [attribute]
printChar:
;Iteracion a interacion se va moviendo el source index gracias a lodsb avanzando sobre el string que obtuve
	  lodsb				; Cargo el valor del caracter actual
	  or		al, al		; Evaluo si el caracter es nulo
	  jz		printEnd
	  mov		[edi], al	; Cargo el ASCII
	  mov		[edi+1], dl	; Cargo el atributo
	  add		edi, 2		; Incremento edi en 2 para avanzar a la siguiente word
	  jmp     	printChar	; Sigo imprimiendo el resto
;Fin de la impresion
printEnd:
	  pop 		esi
	  pop		edi	  
	  popad
; 	  pop		edx
; 	  pop		ebx
; 	  pop		eax
	  pop		ebp		; Devuelvo ebp
	  ret	  
	  