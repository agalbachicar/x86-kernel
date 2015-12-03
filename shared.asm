;#########################################################################
;@file		shared.asm
;@brief		Libreria con wrappers de systems calls
;	    	Intel x86 compatible en 32 bit. 
;@author	Agustin Alba Chicar
;@date		Noviembre, 2015
;#########################################################################

;********************************************************************************
; Simbolos externos y globales
;********************************************************************************
%include	"system.inc"
%include	"video.inc"

GLOBAL		print
GLOBAL		cls
GLOBAL		getTime
GLOBAL		sleep
GLOBAL		printNumberToArray
GLOBAL		getChar
GLOBAL		getTaskPriority
GLOBAL		setTaskPriority
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
SECTION		.shared

;********************************************************************************
;@fn		void sleep(uint32_t ticks)
;@brief		Wrapper de la sys call sleep
;@param		tick 	es el numero de ticks a poner en sleep a la tarea
;********************************************************************************
sleep:
	  mov		eax, SYSTEM_API_SLEEP
	  int		0x80
	  ret
;********************************************************************************
;@fn		void cls(void)
;@brief		Wrapper de la sys call cls
;********************************************************************************	  
cls:
	  mov 		eax, SYSTEM_API_CLS
	  int		0x80
	  ret
;********************************************************************************
;@fn		void print(char *string, int32_t column, int32_t row, int32_t attribute)
;@brief		Wrapper de la sys call print
;@param		string	es el puntero al string a imprimir
;@param		column	es la columna donde se imprime la informacion
;@param		row	es la fila donde se imprime la informacion
;@param		attribute	es el atributo de los caracteres que imprimen la informacion
;********************************************************************************  
print:
	  mov 		eax, SYSTEM_API_PRINT
	  int		0x80
	  ret
;********************************************************************************
;@fn		void getTime(timeType *time)
;@brief		Wrapper de la sys call getTime
;@param		time	es un puntero a la estructura de la fecha donde se carga toda la informacion
;********************************************************************************
getTime:
	  mov		eax, SYSTEM_API_GET_TIME
	  int		0x80
	  ret
;********************************************************************************
;@fn		int getChar(char *value)
;@brief		Wrapper de la sys call getTime
;@param		time	es un puntero a la estructura de la fecha donde se carga toda la informacion
;********************************************************************************
getChar:	
	  mov		eax, SYSTEM_API_GETCHAR
	  int		0x80
	  ret	  
;********************************************************************************
;@fn		int getTaskPriority(uint32_t taskId)
;@brief		Wrapper de la sys call getTaskPriority
;@param		taskId	es el id de la tarea a obenerle la prioridad
;@retval	La prioridad de la tarea o PRIORITY_MAXIMUM+1 si no esta ese id de tarea
;********************************************************************************
getTaskPriority:
	  mov		eax, SYSTEM_API_GETTASKPRIO
	  int		0x80
	  ret	
;********************************************************************************
;@fn		void setTaskPriority(uint32_t taskId, uint32_t priority)
;********************************************************************************	  
setTaskPriority:
	  mov		eax, SYSTEM_API_SETTASKPRIO
	  int		0x80
	  ret	
;********************************************************************************
;@fn		printNumberToArray(uint32_t number, char *array)
;@brief		Imprime sobre el array un numero number de 4 bytes. Agrega el NULL al final
;@details	El mayor numero es 4294967295 que son 10 digitos por lo que array
;		debe ser de 11 caracteres en caso de tener que usarse todo el rango.
;@param		number	es el numero a convertir
;@param		array	es puntero al buffer sobre el que se va a escribir
;********************************************************************************
printNumberToArray:
	  push		ebp
	  mov		ebp, esp
	  sub		esp, 4		; Reservamos una variable
	  pushad
	  push		edi
	  
	  ; Lo primero es obtener la cantidad de digitos que tiene la variable
	  mov		[ebp - 4], DWORD 0; Cargo en cero el contador de digitos
	  mov		eax, [ebp + 8]	; Obtengo el numero
	  
printNumberToArrayDigitsLoop:
	  mov		ebx, [ebp - 4]	; Incrementamos el contador
	  inc 		ebx
	  mov		[ebp - 4], ebx
	    
	  mov 		edx, 0		; Dividimos
	  mov		ebx, 10
	  div		ebx
	  push		edx		; Guardamos en el stack dl
	  cmp		eax, 0
	  jne		printNumberToArrayDigitsLoop
	  
	  mov 		edi, [ebp + 12]	; Obtengo el puntero al array
	  mov 		ecx, [ebp - 4]	; Cargo en ecx el numero de digitos
	  
printNumberToArrayStackToArrayLoop:
	  pop		eax		; Obtengo en al el ultimo digito
 	  add		al, '0'		; Sumo el offset del cero
 	  mov		[edi], al	; Cargo en el array
 	  inc 		edi		; Incremento edi
 	  dec		ecx		; Decremento ecx
 	  cmp		ecx, 0		; Testeo el contador para cargar el proximo valor
 	  jne		printNumberToArrayStackToArrayLoop
 	  
	  ; Cargo en edi el null pointer
 	  mov		[edi], BYTE NULL	
	  
	  pop		edi
	  popad
	  add		esp, 4		; Liberamos la variable
	  pop 		ebp
	  ret	  