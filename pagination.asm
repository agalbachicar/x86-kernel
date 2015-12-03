;#########################################################################
;@file		pagination.asm
;@brief		Librería que me permite cargar la paginacion según los requerimientos del ejercicio
;	    	Intel x86 compatible en 32 bit. 
;@author	Agustin Alba Chicar
;@date		Octubre, 2015
;#########################################################################


;********************************************************************************
; Simbolos externos y globales
;********************************************************************************
%include	"pagination.inc"

; Símbolos de sys_tables
EXTERN		PDPT
EXTERN		pdptKernel
EXTERN		pdptTask1
EXTERN		pdptTask2
EXTERN		pdptTask3
EXTERN		pdptTask4


GLOBAL		int32CreatePaginationTables
GLOBAL		init32CreateTasksPaginationTables
;********************************************************************************
; Defines
;********************************************************************************


;********************************************************************************
; Datos inicializados
;********************************************************************************

;********************************************************************************
; Datos no inicializados
;********************************************************************************
USE32						;Modelo de 32 bit
SECTION		.init32 	

;********************************************************************************
; @fn		int32CreatePaginationTables
; @brief	Crea la estructura de las paginas segun el modelo de memoria deseado
; @details	Lo hace para un modelo de paginacion PAE de 4KB de tamaño de pagina.
; 		Posee 3 tablas de paginas, 1 tabla de directorio de pagina y 1 tabla 
; 		de punteros de directorios de paginas. Cada una de las tablas de paginas
;		posee capacidad de mapear 0x200 bloques de 4KB cada. Lo atributos
;		de las tablas de paginas y directorios de paginas son Supervisor, R&W
;		y presentes, mientras que las entradas de la PDTP es simplemente presente.
;********************************************************************************
int32CreatePaginationTables:
	;Cargamos las entradas en las tablas de paginas del rango 0x000000 - 0x100000 validas
	mov 	eax, TP0 + ((0xF4000 / PAGE_SIZE)) * PAE_ENTRY_SIZE	; Cargo en la posicion de la memoria para la inicializacion una entrada valida
	mov 	ebx, 0xF4000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0xF4000 + PAGE_SIZE
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	;Cargamos las entradas en las tablas de paginas del rango 0x100000 - 0x200000 validas
	mov 	eax, TP0 + (0x100000 / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x100000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x101000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x102000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x103000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx
; Tablas de paginacion para las que se van a cargar ante fallos de pagina	
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x104000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx		;1
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x105000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx		;2					
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x106000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx		;3
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x107000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx		;4
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x108000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx		;5
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x109000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx		;6
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x10A000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx		;7
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x10B000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx		;8
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x10C000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx		;9
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x10D000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx		;10
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x10E000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx		;11
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x10F000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx		;12	
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x110000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx		;13
	
	mov 	eax, TP0 + (0x140000 / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x140000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x140000 + PAGE_SIZE
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx		
	mov 	eax, TP0 + (0x150000 / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x150000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x150000 + PAGE_SIZE
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx
	;Cargamos las entradas en las tablas de paginas del rango 0x200000 - 0x400000 validas
	mov 	eax, TP1 + ((0x200000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x200000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x200000 + PAGE_SIZE
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP1 + ((0x210000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x210000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x210000 + PAGE_SIZE
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx			
	mov 	eax, TP1 + ((0x220000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x220000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x220000 + PAGE_SIZE
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx
	
	mov 	eax, TP1 + ((0x230000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x230000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	ebx, 0x230000 + PAGE_SIZE
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx
	
	mov 	eax, TP1 + ((0x280000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xB8000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0xB8000 + PAGE_SIZE
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	;Cargamos las entradas en las tablas de paginas del rango 0xA00000 - 0xC00000 validas	
	mov 	eax, TP2 + ((0xA00000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA00000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA01000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA01000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx		
	mov 	eax, TP2 + ((0xA02000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA02000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA03000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA03000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA04000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA04000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx		
	mov 	eax, TP2 + ((0xA05000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA05000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA06000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA06000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA07000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA07000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA08000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA08000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA09000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA09000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	
	mov 	eax, TP2 + ((0xA10000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA10000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA11000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA11000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx		
	mov 	eax, TP2 + ((0xA12000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA12000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA13000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA13000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx
	mov 	eax, TP2 + ((0xA14000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA14000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA15000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA15000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA16000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA16000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA17000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA17000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA18000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA18000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA19000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA19000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	
	mov 	eax, TP2 + ((0xA20000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA20000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA21000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA21000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx		
	mov 	eax, TP2 + ((0xA22000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA22000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA23000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA23000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx
	mov 	eax, TP2 + ((0xA24000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA24000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA25000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA25000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA26000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA26000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA27000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA27000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA28000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA28000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA29000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA29000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	

	
	mov 	eax, TP2 + ((0xA30000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA30000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA31000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA31000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx		
	mov 	eax, TP2 + ((0xA32000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA32000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA33000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA33000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx
	mov 	eax, TP2 + ((0xA34000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA34000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA35000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA35000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA36000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA36000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA37000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA37000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA38000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA38000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	mov 	eax, TP2 + ((0xA39000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA39000
	add 	ebx, ENTRY_ATTRIBUTE
	mov	[eax], ebx	
	
	;Cargamos la TDP
	mov 	eax, TDP			; Cargo la tabla de directorio de paginas
	mov 	ebx, TP0			; Cargo la tabla de paginas de 0x000000 a 0x200000
	add	ebx, ENTRY_ATTRIBUTE		; Sumo los atributos
	mov 	[eax], ebx			; Cargo en TDP la primer dirección de la tabla de paginas
	
	mov 	eax, TDP + PAE_ENTRY_SIZE	; Coloco el puntero en la segunda entrada de la tabla de directorio de paginas
	mov 	ebx, TP1			; Cargo la tabla de paginas de 0x200000 - 0x400000
	add 	ebx, ENTRY_ATTRIBUTE		; Sumo los atributos
	mov 	[eax], ebx			; Cargo en TDP la segunda dirección de la tabla de paginas

	mov 	eax, TDP + 5*PAE_ENTRY_SIZE	; Coloco el puntero en la segunda entrada de la tabla de directorio de paginas
	mov 	ebx, TP2			; Cargo la tabla de paginas de 0xA00000 - 0xC00000
	add 	ebx, ENTRY_ATTRIBUTE		; Sumo los atributos
	mov 	[eax], ebx			; Cargo en TDP la segunda dirección de la tabla de paginas
	
	;Cargamos la PDPT
	mov 	eax, PDPT
	mov	ebx, TDP
	add 	ebx, 1
	mov 	[eax], ebx
	ret


;********************************************************************************
; @fn		init32CreateTasksPaginationTables()
; @brief	Crea la estructura de las paginas para las tareas a utilizar
; @details	Las tareas están en las direcciones físicas 0xA00000 y 0xA10000 y 0xA20000.
;		Se van a colocar las páginas de la siguiente forma:
;			Primer pagina va a ser para código
;			Segunda pagina para datos inicializados
;			Tercera pagina para datos no inicializados
;			Cuarta pagina para stack de usuario
;			Quinta pagina para stack de kernel
;			DPT0 de paginacion de la tarea
;			PT0 de paginacion, donde incluimos las systables y algo de código de kernel
;			PT1 de paginacion, donde incluimos código y datos de kernel
;			PT2 de paginacion, donde incluimos la paginacion de la tarea misma
;			La PDPT irá en código de kernel.
;********************************************************************************
init32CreateTasksPaginationTables:
; Tarea 1, PDPT
	mov 	eax, pdptTask1
	mov	ebx, TASK1_DPT0_ADDRESS
	or 	ebx, PTDP_ATTRIBUTE
	mov 	[eax], ebx
; Tarea 1, DPT0
	mov 	eax, TASK1_DPT0_ADDRESS		; Cargo la tabla de directorio de paginas
	mov 	ebx, TASK1_PT0_ADDRESS		; Cargo la tabla de paginas de 0x000000 a 0x200000
	or	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE		; Sumo los atributos
	mov 	[eax], ebx			; Cargo en TDP la primer dirección de la tabla de paginas
	
	mov 	eax, TASK1_DPT0_ADDRESS + PAE_ENTRY_SIZE	; Coloco el puntero en la segunda entrada de la tabla de directorio de paginas
	mov 	ebx, TASK1_PT1_ADDRESS		; Cargo la tabla de paginas de 0x200000 - 0x400000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE		; Sumo los atributos
	mov 	[eax], ebx			; Cargo en TDP la segunda dirección de la tabla de paginas

	mov 	eax, TASK1_DPT0_ADDRESS + 5*PAE_ENTRY_SIZE	; Coloco el puntero en la segunda entrada de la tabla de directorio de paginas
	mov 	ebx, TASK1_PT2_ADDRESS		; Cargo la tabla de paginas de 0xA00000 - 0xC00000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE		; Sumo los atributos
	mov 	[eax], ebx			; Cargo en TDP la segunda dirección de la tabla de paginas
; Tarea 1, TP0
	mov 	eax, TASK1_PT0_ADDRESS + (0x100000 / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x100000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x101000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx	
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x102000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx	
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x103000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x104000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x105000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx
	mov 	eax, TASK1_PT0_ADDRESS + (0x140000 / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x140000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x140000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx		
	mov 	eax, TASK1_PT0_ADDRESS + (0x150000 / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x150000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x150000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx
; Tarea 1, TP1
	mov 	eax, TASK1_PT1_ADDRESS + ((0x200000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x200000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x200000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
	mov 	eax, TASK1_PT1_ADDRESS + ((0x210000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x210000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x210000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx			
	mov 	eax, TASK1_PT1_ADDRESS + ((0x220000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x220000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x220000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx
	
	mov 	eax, TASK1_PT1_ADDRESS + ((0x230000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x230000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x230000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx
	
	mov 	eax, TASK1_PT1_ADDRESS + ((0x280000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xB8000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0xB8000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
; Tarea 1, TP2
	mov 	eax, TASK1_PT2_ADDRESS + ((0xA00000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA00000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx	
	mov 	eax, TASK1_PT2_ADDRESS + ((0xA01000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA01000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx		
	mov 	eax, TASK1_PT2_ADDRESS + ((0xA02000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA02000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
	mov 	eax, TASK1_PT2_ADDRESS + ((0xA03000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA03000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
	mov 	eax, TASK1_PT2_ADDRESS + ((0xA04000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA04000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx		
	mov 	eax, TASK1_PT2_ADDRESS + ((0xA05000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA05000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx	
	mov 	eax, TASK1_PT2_ADDRESS + ((0xA06000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA06000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx		
	mov 	eax, TASK1_PT2_ADDRESS + ((0xA07000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA07000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx	
	mov 	eax, TASK1_PT2_ADDRESS + ((0xA08000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA08000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx	
	mov 	eax, TASK1_PT2_ADDRESS + ((0xA09000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA09000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx	
;-----------------------------------------------------
; Tarea 2, PDPT
	mov 	eax, pdptTask2
	mov	ebx, TASK2_DPT0_ADDRESS
	add 	ebx, PTDP_ATTRIBUTE
	mov 	[eax], ebx
; Tarea 2, DPT0
	mov 	eax, TASK2_DPT0_ADDRESS		; Cargo la tabla de directorio de paginas
	mov 	ebx, TASK2_PT0_ADDRESS		; Cargo la tabla de paginas de 0x000000 a 0x200000
	add	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE		; Sumo los atributos
	mov 	[eax], ebx			; Cargo en TDP la primer dirección de la tabla de paginas
	
	mov 	eax, TASK2_DPT0_ADDRESS + PAE_ENTRY_SIZE	; Coloco el puntero en la segunda entrada de la tabla de directorio de paginas
	mov 	ebx, TASK2_PT1_ADDRESS		; Cargo la tabla de paginas de 0x200000 - 0x400000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE		; Sumo los atributos
	mov 	[eax], ebx			; Cargo en TDP la segunda dirección de la tabla de paginas

	mov 	eax, TASK2_DPT0_ADDRESS + 5*PAE_ENTRY_SIZE	; Coloco el puntero en la segunda entrada de la tabla de directorio de paginas
	mov 	ebx, TASK2_PT2_ADDRESS		; Cargo la tabla de paginas de 0xA00000 - 0xC00000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE		; Sumo los atributos
	mov 	[eax], ebx			; Cargo en TDP la segunda dirección de la tabla de paginas
; Tarea 2, TP0
	mov 	eax, TASK2_PT0_ADDRESS + (0x100000 / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x100000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x101000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x102000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x103000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x104000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x105000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	mov 	eax, TASK2_PT0_ADDRESS + (0x140000 / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x140000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x140000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx		
	mov 	eax, TASK2_PT0_ADDRESS + (0x150000 / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x150000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x150000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
; Tarea 2, TP1
	mov 	eax, TASK2_PT1_ADDRESS + ((0x200000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x200000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x200000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
	mov 	eax, TASK2_PT1_ADDRESS + ((0x210000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x210000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x210000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx			
	mov 	eax, TASK2_PT1_ADDRESS + ((0x220000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x220000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x220000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx		
	
	mov 	eax, TASK2_PT1_ADDRESS + ((0x230000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x230000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x230000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
	
	
	mov 	eax, TASK2_PT1_ADDRESS + ((0x280000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xB8000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0xB8000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
; Tarea 2, TP2
	mov 	eax, TASK2_PT2_ADDRESS + ((0xA10000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA10000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx	
	mov 	eax, TASK2_PT2_ADDRESS + ((0xA11000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA11000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx		
	mov 	eax, TASK2_PT2_ADDRESS + ((0xA12000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA12000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
	mov 	eax, TASK2_PT2_ADDRESS + ((0xA13000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA13000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
	mov 	eax, TASK2_PT2_ADDRESS + ((0xA14000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA14000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx		
	mov 	eax, TASK2_PT2_ADDRESS + ((0xA15000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA15000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx	
	mov 	eax, TASK2_PT2_ADDRESS + ((0xA16000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA16000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx		
	mov 	eax, TASK2_PT2_ADDRESS + ((0xA17000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA17000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx	
	mov 	eax, TASK2_PT2_ADDRESS + ((0xA18000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA18000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx	
	mov 	eax, TASK2_PT2_ADDRESS + ((0xA19000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA19000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx	
;-----------------------------------------------------
; Tarea 3, PDPT
	mov 	eax, pdptTask3
	mov	ebx, TASK3_DPT0_ADDRESS
	add 	ebx, PTDP_ATTRIBUTE
	mov 	[eax], ebx
; Tarea 3, DPT0
	mov 	eax, TASK3_DPT0_ADDRESS		; Cargo la tabla de directorio de paginas
	mov 	ebx, TASK3_PT0_ADDRESS		; Cargo la tabla de paginas de 0x000000 a 0x200000
	add	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE		; Sumo los atributos
	mov 	[eax], ebx			; Cargo en TDP la primer dirección de la tabla de paginas
	
	mov 	eax, TASK3_DPT0_ADDRESS + PAE_ENTRY_SIZE	; Coloco el puntero en la segunda entrada de la tabla de directorio de paginas
	mov 	ebx, TASK3_PT1_ADDRESS		; Cargo la tabla de paginas de 0x200000 - 0x400000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE		; Sumo los atributos
	mov 	[eax], ebx			; Cargo en TDP la segunda dirección de la tabla de paginas

	mov 	eax, TASK3_DPT0_ADDRESS + 5*PAE_ENTRY_SIZE	; Coloco el puntero en la segunda entrada de la tabla de directorio de paginas
	mov 	ebx, TASK3_PT2_ADDRESS		; Cargo la tabla de paginas de 0xA00000 - 0xC00000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE		; Sumo los atributos
	mov 	[eax], ebx			; Cargo en TDP la segunda dirección de la tabla de paginas
; Tarea 3, TP0
	mov 	eax, TASK3_PT0_ADDRESS + (0x100000 / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x100000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x101000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x102000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x103000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x104000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x105000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	mov 	eax, TASK3_PT0_ADDRESS + (0x140000 / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x140000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x140000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx		
	mov 	eax, TASK3_PT0_ADDRESS + (0x150000 / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x150000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x150000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
; Tarea 3, TP1
	mov 	eax, TASK3_PT1_ADDRESS + ((0x200000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x200000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x200000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
	mov 	eax, TASK3_PT1_ADDRESS + ((0x210000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x210000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x210000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx			
	mov 	eax, TASK3_PT1_ADDRESS + ((0x220000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x220000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x220000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx		
	
	mov 	eax, TASK3_PT1_ADDRESS + ((0x230000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x230000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x230000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx		
	
	
	mov 	eax, TASK3_PT1_ADDRESS + ((0x280000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xB8000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0xB8000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
; Tarea 3, TP2
	mov 	eax, TASK3_PT2_ADDRESS + ((0xA20000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA20000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx	
	mov 	eax, TASK3_PT2_ADDRESS + ((0xA21000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA21000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx		
	mov 	eax, TASK3_PT2_ADDRESS + ((0xA22000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA22000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
	mov 	eax, TASK3_PT2_ADDRESS + ((0xA23000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA23000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
	mov 	eax, TASK3_PT2_ADDRESS + ((0xA24000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA24000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx		
	mov 	eax, TASK3_PT2_ADDRESS + ((0xA25000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA25000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx	
	mov 	eax, TASK3_PT2_ADDRESS + ((0xA26000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA26000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx		
	mov 	eax, TASK3_PT2_ADDRESS + ((0xA27000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA27000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx	
	mov 	eax, TASK3_PT2_ADDRESS + ((0xA28000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA28000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx	
	mov 	eax, TASK3_PT2_ADDRESS + ((0xA29000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA29000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx
;-----------------------------------------------------
; Tarea 4, PDPT
	mov 	eax, pdptTask4
	mov	ebx, TASK4_DPT0_ADDRESS
	add 	ebx, PTDP_ATTRIBUTE
	mov 	[eax], ebx
; Tarea 4, DPT0
	mov 	eax, TASK4_DPT0_ADDRESS		; Cargo la tabla de directorio de paginas
	mov 	ebx, TASK4_PT0_ADDRESS		; Cargo la tabla de paginas de 0x000000 a 0x200000
	add	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE		; Sumo los atributos
	mov 	[eax], ebx			; Cargo en TDP la primer dirección de la tabla de paginas
	
	mov 	eax, TASK4_DPT0_ADDRESS + PAE_ENTRY_SIZE	; Coloco el puntero en la segunda entrada de la tabla de directorio de paginas
	mov 	ebx, TASK4_PT1_ADDRESS		; Cargo la tabla de paginas de 0x200000 - 0x400000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE		; Sumo los atributos
	mov 	[eax], ebx			; Cargo en TDP la segunda dirección de la tabla de paginas

	mov 	eax, TASK4_DPT0_ADDRESS + 5*PAE_ENTRY_SIZE	; Coloco el puntero en la segunda entrada de la tabla de directorio de paginas
	mov 	ebx, TASK4_PT2_ADDRESS		; Cargo la tabla de paginas de 0xA00000 - 0xC00000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE		; Sumo los atributos
	mov 	[eax], ebx			; Cargo en TDP la segunda dirección de la tabla de paginas
; Tarea 4, TP0
	mov 	eax, TASK4_PT0_ADDRESS + (0x100000 / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x100000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x101000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x102000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x103000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x104000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x105000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	mov 	eax, TASK4_PT0_ADDRESS + (0x140000 / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x140000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x140000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx		
	mov 	eax, TASK4_PT0_ADDRESS + (0x150000 / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x150000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x150000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
; Tarea 4, TP1
	mov 	eax, TASK4_PT1_ADDRESS + ((0x200000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x200000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x200000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
	mov 	eax, TASK4_PT1_ADDRESS + ((0x210000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x210000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x210000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx			
	mov 	eax, TASK4_PT1_ADDRESS + ((0x220000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x220000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x220000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx		
	
	mov 	eax, TASK4_PT1_ADDRESS + ((0x230000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0x230000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0x230000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx		
	
	
	mov 	eax, TASK4_PT1_ADDRESS + ((0x280000 -0x200000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xB8000
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx
	add 	eax, PAE_ENTRY_SIZE
	mov 	ebx, 0xB8000 + PAGE_SIZE
	or 	ebx, ATTRIBUTE_GLOBAL | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
; Tarea 3, TP2
	mov 	eax, TASK4_PT2_ADDRESS + ((0xA30000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA30000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx	
	mov 	eax, TASK4_PT2_ADDRESS + ((0xA31000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA31000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx		
	mov 	eax, TASK4_PT2_ADDRESS + ((0xA32000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA32000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
	mov 	eax, TASK4_PT2_ADDRESS + ((0xA33000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA33000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx	
	mov 	eax, TASK4_PT2_ADDRESS + ((0xA34000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA34000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE
	mov	[eax], ebx		
	mov 	eax, TASK4_PT2_ADDRESS + ((0xA35000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA35000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx	
	mov 	eax, TASK4_PT2_ADDRESS + ((0xA36000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA36000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx		
	mov 	eax, TASK4_PT2_ADDRESS + ((0xA37000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA37000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx	
	mov 	eax, TASK4_PT2_ADDRESS + ((0xA38000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA38000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx	
	mov 	eax, TASK4_PT2_ADDRESS + ((0xA39000 -0xA00000) / PAGE_SIZE) * PAE_ENTRY_SIZE
	mov 	ebx, 0xA39000
	or 	ebx, ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_READ
	mov	[eax], ebx
	
	ret