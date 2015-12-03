;#########################################################################
;@file		fifo.asm
;@brief		Libreria para el manejo de una fifo
;	    	Intel x86 compatible en 32 bit. 
;@details	Condiciones de la fifo:
;
;		Vacia: cHead = cTail
;		Llena: (cTail - cHead) % Size = 1
;		Intermedia; otro caso
;
;@author	Agustin Alba Chicar
;@date		Octubre, 2015
;#########################################################################

;********************************************************************************
; Simbolos externos y globales
;********************************************************************************

%include	"fifo.inc"

GLOBAL		fifoInit
GLOBAL		fifoPush
GLOBAL		fifoPop
;********************************************************************************
; Defines
;********************************************************************************


;********************************************************************************
; Datos no inicializados
;********************************************************************************

;********************************************************************************
; Datos inicializados
;********************************************************************************

USE32
SECTION		.library

;********************************************************************************
;@fn		fifoCreate(fifoType *fifo, uint32_t *pData, uint32_t items, uint32_t sizeOfData)
;@brief		Inicializa los datos de una estructura del tipo fifo
;@param		fifo es un puntero a la fifo a inicializar
;@param		data es el puntero al origen del buffer de datos para la FIFO
;@param		items es el numero de items en la fifo
;@param		sizeOfData es el numero de bytes que ocupa cada item
;********************************************************************************	
fifoInit:
	  push 		ebp
	  mov		ebp, esp	;Cargo el valor de esp por si me interrupen	  	  
	  push		eax
	  push		esi
	  mov		esi, [ebp + 8]	; Coloco en esi el puntero a la fifo
	  mov		eax, [ebp + 12] ; Coloco en eax el valor del puntero pData
	  mov		[esi + fifoType.pData], eax; Copio el puntero
	  mov		eax, 0x00	; Cargo un 0 en los contadores de datos
	  mov		[esi + fifoType.cHead], eax
	  mov		[esi + fifoType.cTail], eax
	  mov		eax, [ebp + 16]	; Coloco items en eax
	  mov		[esi + fifoType.items], eax
	  mov		eax, [ebp + 20]	; Coloco sizeOfData en eax
	  mov		[esi + fifoType.sizeOfData], eax
	  pop		esi
	  pop		eax	  
	  pop		ebp
	  ret

;********************************************************************************
;@fn		fifoPush(fifoType *fifo,void *pData)
;@brief		Cargo un dato en la FIFO
;@param		fifo es un puntero a la fifo a colocarle un dato
;@param		pData es el puntero al dato a colocar
;@retval	EFIFO_OK si el dato pudo ser colocado
;@retval	EFIFO_FULL si el dato no pudo ser colocado por condicion de FIFO llena
;********************************************************************************	
fifoPush:
	  push 		ebp
	  mov		ebp, esp	;Cargo el valor de esp por si me interrupen	
	  push		ebx
	  push		ecx
	  push		edx
	  push		esi
	  mov		esi, [ebp + 8]	; Coloco en esi el puntero a la fifo	  
	  ; Corroboro condicion de FIFO llena
	  ; (cTail - cHead) % Size == 1
	  mov 		edx, 0		; Cargo 0 en edx que va a ser el resto de la division
	  mov 		eax, [esi + fifoType.cTail]; Obtengo el contador de tail
	  sub 		eax, [esi + fifoType.cHead]; Obtengo el contador de head
	  add 		eax, [esi + fifoType.items]; Si agrego esta linea va a andar siempre ya que hace positiva siempre la resta y soluciono el problema del signado.
	  mov 		ecx, [esi + fifoType.items]; Cargo el tamaño de la FIFO que es el divisor
	  div 		ecx 		; Divido y evaluo el resto
	  cmp 		edx, 1		; Comparo contra 1, si es 1 quiere decir que la FIFO está llena
	  jz  		fifoPushFifoFull
	  ; Como la FIFO esta en otra condicion podemos hacer la copia de memoria
	  ; Esta copia se realiza desde (fifoType.pData + fifoType.head * fifoType.sizeOfData)
	  
	  mov		eax, [esi + fifoType.cHead]
	  mov		ecx, [esi + fifoType.sizeOfData]
	  mul		ecx
	  add		eax, [esi + fifoType.pData]; Cargo pHead
	  mov		edx, [ebp + 12]	; Cargo el puntero al dato a insertar
	  mov		ecx, [esi + fifoType.sizeOfData]
	  xor		ebx, ebx
fifoPushCopyLoop:			; Copio de a 1 bytes los datos
	  mov		bl, [edx]	
	  mov		[eax], bl
	  add		edx, 1
	  add		eax, 1
	  loop		fifoPushCopyLoop
	  
	  mov		eax, [esi + fifoType.cHead]; Incremento head y evaluo condicion de desborde
	  add		eax, 1
	  cmp		eax, [esi + fifoType.items]
	  jz		fifoPushResetHead
	  mov		[esi + fifoType.cHead], eax
	  jmp		fifoPushEndOk
	  
fifoPushResetHead:
	  mov		eax, 0x00	; Cargo en 0 eax y lo coloco en head
	  mov		[esi + fifoType.cHead], eax
	  jmp		fifoPushEndOk
	  
fifoPushFifoFull:	  
	  mov		eax, EFIFO_FULL	; Cargo el valor de error
	  jmp		fifoPushEnd	; Retorno
	  
fifoPushEndOk:
	  mov		eax, EFIFO_OK	; Cargo el valor de error
	  
fifoPushEnd:
	  pop		esi		; Libero la pila
	  pop		edx
	  pop		ecx
	  pop		ebx
	  pop		ebp
	  ret
	  
;********************************************************************************
;@fn		fifoPop(fifoType *fifo,void *pData)
;@brief		Quito un dato de la FIFO
;@param		fifo es un puntero a la fifo a quitarle un dato
;@param		pData es el puntero a un dato para guardar la lectura
;@retval	EFIFO_OK si el dato pudo ser obtenido
;@retval	EFIFO_EMPTY si el dato no pudo ser colocado por condicion de FIFO vacía
;********************************************************************************	
fifoPop:
	  push 		ebp
	  mov		ebp, esp	;Cargo el valor de esp por si me interrupen	
	  push		ebx
	  push		ecx
	  push		edx
	  push		esi
	  mov		esi, [ebp + 8]	; Coloco en esi el puntero a la fifo	  
	  ; Corroboro condicion de FIFO vacia
	  ; cTail = cHead
	  mov 		eax, [esi + fifoType.cTail]; Obtengo el contador de tail
	  cmp 		eax, [esi + fifoType.cHead]; Obtengo el contador de head y lo comparo directamente contra el tail
	  jz  		fifoPopFifoEmpty
	  ; Como la FIFO esta en otra condicion podemos hacer la copia de memoria
	  ; Esta copia se realiza desde (fifoType.pData + fifoType.cTail * fifoType.sizeOfData)
	  mov		eax, [esi + fifoType.cTail]
	  mov		ecx, [esi + fifoType.sizeOfData]
	  mul		ecx
	  add		eax, [esi + fifoType.pData]; Cargo pHead
	  mov		edx, [ebp + 12]	; Cargo el puntero al dato a insertar
	  mov		ecx, [esi + fifoType.sizeOfData]
	  xor		ebx, ebx
fifoPopCopyLoop:			; Copio de a 1 bytes los datos
	  mov		bl, [eax]	
	  mov		[edx], bl
	  add		edx, 1
	  add		eax, 1
	  loop		fifoPopCopyLoop
	  
	  mov		eax, [esi + fifoType.cTail]; Incremento tail y evaluo condicion de desborde
	  add		eax, 1
	  cmp		eax, [esi + fifoType.items]
	  jz		fifoPopResetTail
	  mov		[esi + fifoType.cTail], eax
	  jmp		fifoPopEndOk
	  
fifoPopResetTail:
	  mov		eax, 0x00	; Cargo en 0 eax y lo coloco en head
	  mov		[esi + fifoType.cTail], eax
	  jmp		fifoPushEndOk	  
	  
fifoPopFifoEmpty:	  
	  mov		eax, EFIFO_EMPTY; Cargo el valor de error
	  jmp		fifoPopEnd	; Retorno
	  
fifoPopEndOk:
	  mov		eax, EFIFO_OK	; Cargo el valor de error
	  
fifoPopEnd:
	  pop		esi		; Libero la pila
	  pop		edx
	  pop		ecx
	  pop		ebx
	  pop		ebp
	  ret

	  
	  