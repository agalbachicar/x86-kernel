;#########################################################################
;@file		keyboard.asm
;@brief		Driver para el manejo del teclado.
;	    	Intel x86 compatible en 32 bit. 
;@details	Hace uso de la libreria de puertos para poder leer el teclado.
;@author	Agustin Alba Chicar
;@date		Octubre, 2015
;#########################################################################

;********************************************************************************
; Simbolos externos y globales
;********************************************************************************
%include	"keyboard.inc"
%include	"fifo.inc"

;Simbolos de sys_tables
EXTERN		dataKernelSelector
;Simbolos de los puertos
EXTERN		portRead
EXTERN		portWrite
;Simbolos de fifo
EXTERN		fifoInit
EXTERN		fifoPush
EXTERN		fifoPop

GLOBAL		keyboardInitFIFO
GLOBAL		keyboardRead
GLOBAL		keyboardISRHandler
GLOBAL		keyboardGetChar

;********************************************************************************
; Defines
;********************************************************************************
USE32

%define		PIC_EOI_VALUE		0x20
%define		PIC_EOI_PORT		0x20

;********************************************************************************
; Datos no inicializados
;********************************************************************************
SECTION		.bss

keyboardKeyFIFO:	resb fifoType.size*1
keyboardKeyFIFOBuffer:	resb (KEYBOARD_FIFO_ITEM_SIZE*KEYBOARD_FIFO_ITEMS)
keyboardChar:		resb 1
;********************************************************************************
; Datos inicializados
;********************************************************************************
SECTION		.data

keyboardScanCodesToASCIITable:
		db 0x00, KEYBOARD_ASCII_ESC, KEYBOARD_ASCII_1, KEYBOARD_ASCII_2, KEYBOARD_ASCII_3, KEYBOARD_ASCII_4
		db KEYBOARD_ASCII_5, KEYBOARD_ASCII_6, KEYBOARD_ASCII_7, KEYBOARD_ASCII_8, KEYBOARD_ASCII_9, KEYBOARD_ASCII_0
		db 0xFF,0xFF,0xFF,0xFF
		db KEYBOARD_ASCII_Q, KEYBOARD_ASCII_W, KEYBOARD_ASCII_E, KEYBOARD_ASCII_R, KEYBOARD_ASCII_T, KEYBOARD_ASCII_Y, KEYBOARD_ASCII_U
		db KEYBOARD_ASCII_I, KEYBOARD_ASCII_O, KEYBOARD_ASCII_P, 0xFF, 0xFF, 0xFF, 0xFF
		db KEYBOARD_ASCII_A, KEYBOARD_ASCII_S, KEYBOARD_ASCII_D, KEYBOARD_ASCII_F, KEYBOARD_ASCII_G, KEYBOARD_ASCII_H, KEYBOARD_ASCII_J
		db KEYBOARD_ASCII_K, KEYBOARD_ASCII_L, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
		db KEYBOARD_ASCII_Z, KEYBOARD_ASCII_X, KEYBOARD_ASCII_C, KEYBOARD_ASCII_V, KEYBOARD_ASCII_B, KEYBOARD_ASCII_N, KEYBOARD_ASCII_M
		
keyboardScanCodesToASCIITableSize: db	$-keyboardScanCodesToASCIITable


SECTION		.library

;********************************************************************************
;@fn		keyboardRead(void)
;@brief		Lee por el teclado y retorna el scan code 
;@return	El scan code leido, sino retorna 0x00
;********************************************************************************	  
keyboardInitFIFO:
	  push		ebp
	  mov		ebp, esp
	  push		eax
	  ; fifoCreate(fifoType *fifo, uint32_t *pData, uint32_t items, uint32_t sizeOfData)
	  ; Cargo en el stack los valores y luego llamo a la funcion
	  push		DWORD KEYBOARD_FIFO_ITEM_SIZE
	  push		DWORD KEYBOARD_FIFO_ITEMS
	  push 		DWORD keyboardKeyFIFOBuffer
	  push 		DWORD keyboardKeyFIFO
	  call		fifoInit
	  add		esp, 16
	  pop		eax
	  pop		ebp
	  ret	  
;********************************************************************************
;@fn		keyboardRead(void)
;@brief		Lee por el teclado y retorna el scan code. Esto lo hace de forma bloqueante!
;@return	El scan code leido, sino retorna 0x00
;********************************************************************************	  
keyboardRead:
	  push		ebp
	  mov		ebp, esp
	  push		KEYBOARD_PORT_DIRECTION_STATUS	;Cargo la direccion a leer en el stack
	  call		portRead			;Leo del puerto
	  add		esp, 4				; Restauro el stack pointer
	  and		al, KEYBOARD_ACTIVITY_MASK	;Aplico la máscara
	  jnz		keyboardReadActivity		;Se produjo actividad
	  mov		eax, 0x00			;Cargo 0 ante falta de actividad
	  jmp		keyboardReadEnd
keyboardReadActivity:
	  push		KEYBOARD_PORT_DIRECTION_VALUE	;Cargo la direccion a leer en el stack
	  call		portRead			;Leo del puerto	
	  add		esp, 4				; Restauro el stack pointer
	  and		eax, 0xFF
keyboardReadEnd:	  
	  pop		ebp
	  ret
	  
;********************************************************************************
;@fn		keyboardISRHandler(void)
;@brief		Implementacion del handler de interrupcion del teclado.
;@details	Lee el scan code. Evalua qeu valor tiene en ASCII y lo manda a la FIFO
;@return	El scan code leido, sino retorna 0x00
;********************************************************************************	  	  
keyboardISRHandler:
	  push 		ebp
	  mov		ebp, esp
	  
	  call		keyboardRead			; Obtengo el valor del teclado
	  cmp		eax, 0xFF			; Comparo eax con 0xFF. Si es 0xFF quiere decir que no habia dato
	  je		keyboardISRHandlerEnd		
	  push		eax				; Obtengo el ascii desde el scan code
	  call		keyboardScanCodeToASCII
	  add		esp, 4				; Balanceo la pila
	  
	  cmp		eax, 0xFF
	  je		keyboardISRHandlerEnd
	  
	  mov		[keyboardChar], eax
	  push		keyboardChar
	  push		DWORD keyboardKeyFIFO		; Cargo la pila con la FIFO
	  call		fifoPush			; Coloco el dato en la FIFO
	  add		esp, 8				; Balanceo la pila

keyboardISRHandlerEnd:	  
	  mov		eax, PIC_EOI_VALUE		; Genero el EOI para el PIC
	  push		eax
	  mov		eax, PIC_EOI_PORT
	  push		eax
	  call		portWrite
	  add		esp, 8
	  
	  pop		ebp
	  ret

;********************************************************************************
;@fn		keyboardGetChar(char *character)
;@brief		Lee de forma bloqueante
;@return	El ASCII code leido, sino retorna 0xFF
;********************************************************************************	  	  
keyboardGetChar:
	  push		ebp
	  mov		ebp,esp
	  push		ebx
keyboardGetCharReadFromFIFO:
	  mov		eax, ebp	; Cargo el puntero para colocar el dato que recibo como argumento
	  add		eax, 8
	  push		DWORD [eax]
	  push		keyboardKeyFIFO	
	  call		fifoPop		; Obtengo un dato de la FIFO
	  add		esp, 8		; Restauro la pila
	  cmp		eax, EFIFO_EMPTY; Si la fifo esta vacia tengo que esperar que haya una interrupcion de teclado
	  jne		keyboardGetCharLoadOk
	  ;nop;hlt			; Me duermo
	  ;jmp		keyboardGetCharReadFromFIFO
	  
	  mov		eax, 0xFF
	  jmp		keyboardGetCharEnd
keyboardGetCharLoadOk:
	  mov		eax, 0x00
keyboardGetCharEnd:
	  pop		ebx
	  pop		ebp
	  ret


;********************************************************************************
;@fn		keyboardScanCodeToASCII(uint32_t scanCode)
;@brief		A partir de un scan code retorna el ASCII correspondiente.
;@details	Obtengo el scanCode y evaluo si el bit 7 está activo, lo que implica
;	  	que es el valor de break code de una de las teclas de interes y me ahorro
;		todas las comparaciones. En caso contrario, lo que hago es comparar directamente
;		contra el valor del scan code y se carga el ASCII correspondiente.
;@return	El ASCII del scan code o sino 0xFF
;********************************************************************************	  	  
keyboardScanCodeToASCII:
	  push		ebp
	  mov		ebp,esp
	  push		esi		; Guardo el source index
	  mov		eax, [ebp + 8]	; Obtengo el scanCode
	  and		eax, 0xFF	; Andeo para las comparaciones
	  sub		eax, [keyboardScanCodesToASCIITableSize]; Le resto a eax el valor de la tabla
	  jns		keyboardScanCodeToASCIINoValue
	  mov		eax, [ebp + 8]
	  and		eax, 0xFF
	  mov		esi, keyboardScanCodesToASCIITable; Cargo la direccion de la tabla
	  mov		al, [esi + eax]; Obtengo el ASCII
	  jmp		keyboardScanCodeToASCIIEnd
keyboardScanCodeToASCIINoValue:
	  mov		eax, 0xFF
keyboardScanCodeToASCIIEnd:	  
	  pop		esi		; Restauro el source index
	  pop		ebp
	  ret