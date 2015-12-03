;#########################################################################
;@file		fifo.inc
;@brief		Defines para la API  de FIFO
;	    	Intel x86 compatible en 32 bit. 
;@author	Agustin Alba Chicar
;@date		Octubre, 2015
;#########################################################################


;********************************************************************************
; Defines
;********************************************************************************

%define		EFIFO_FULL	0x01	;Fifo llena
%define		EFIFO_EMPTY	0x02	;Fifo vacia
%define		EFIFO_OK	0x00	;Operacion con la FIFO ok

;********************************************************************************
; Tipos de dato
;********************************************************************************

;********************************************************************************
;@struct	fifoType
;@brief		Estructura que permite manejar una FIFO
;@details	pData es el puntero al origen de los datos
;		pHead es el puntero al dato insertado último en la FIFO
;		pTail es el puntero al primer dato insertado y el primero en salir
;		items es el numero de items que tiene la FIFO
;		sizeOfData es el numero de bytes por item de la FIFO
;********************************************************************************	
STRUC fifoType
  .pData:	resd	1
  .cHead:	resd	1
  .cTail: 	resd	1
  .items:	resd	1
  .sizeOfData:	resd	1
  .size:
ENDSTRUC