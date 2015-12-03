;#########################################################################
;@file		port.asm
;@brief		Libreria para el manejo de puertos, escritura y lectura de los mismos
;	    	Intel x86 compatible en 32 bit. 
;@author	Agustin Alba Chicar
;@date		Octubre, 2015
;#########################################################################

;********************************************************************************
; Simbolos externos y globales
;********************************************************************************
GLOBAL		portRead
GLOBAL		portWrite
;********************************************************************************
; Defines
;********************************************************************************
%define		port					(ebp+8)
%define		value					(ebp+12)

;********************************************************************************
; Datos no inicializados
;********************************************************************************

;********************************************************************************
; Datos inicializados
;********************************************************************************


USE32
SECTION		.library

;********************************************************************************
;@fn		portRead(uint32_t port)
;@brief		Lee el valor de un puerto y lo deja en al
;@param		port	El valor del puerto a leer
;@return	El valor del puerto (uint8_t) en al
;********************************************************************************
portRead:
	  push		ebp
	  mov		ebp, esp	;Cargo el valor de esp por si me interrupen		  
	  push		edx
	  mov		edx, [port]
	  in		al, dx
	  pop		edx
	  pop		ebp
	  ret

;********************************************************************************
;@fn		portWrite(uint32_t port, uint32_t value)
;@brief		Escribe el valor value en port
;@param		port 	El valor del puerto a escribir
;@param		value 	El valor a escribir en el puerto
;********************************************************************************
portWrite:
	  push		ebp
	  mov		ebp, esp	;Cargo el valor de esp por si me interrupen	 	  
	  push		eax
	  push		edx
	  mov		edx, [port]
	  mov		al, [value]
	  out		dx, al
	  pop		edx
	  pop		eax
	  pop		ebp
	  ret	  
	  