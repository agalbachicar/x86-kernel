;#########################################################################
;@file		keyboard.inc
;@brief		Defines de para el manejo de teclado. Tanto puertos como scan codes
;		y su respectivo valor en ASCII
;	    	Intel x86 compatible en 32 bit. 
;@author	Agustin Alba Chicar
;@date		Octubre, 2015
;#########################################################################


;********************************************************************************
; Defines
;********************************************************************************
%define		KEYBOARD_PORT_DIRECTION_STATUS		0x64
%define		KEYBOARD_PORT_DIRECTION_VALUE		0x60
%define		PIC_EOI_PORT				0x20
%define		PIC_EOR_VALUE				0x20
%define		KEYBOARD_ACTIVITY_MASK			0x01


%define		KEYBOARD_SCAN_CODE_IN_ESC		0x01
%define		KEYBOARD_SCAN_CODE_IN_0			0X0B
%define		KEYBOARD_SCAN_CODE_IN_1			0X02
%define		KEYBOARD_SCAN_CODE_IN_2			0X03
%define		KEYBOARD_SCAN_CODE_IN_3			0X04
%define		KEYBOARD_SCAN_CODE_IN_4			0X05
%define		KEYBOARD_SCAN_CODE_IN_5			0X06
%define		KEYBOARD_SCAN_CODE_IN_6			0X07
%define		KEYBOARD_SCAN_CODE_IN_7			0X08
%define		KEYBOARD_SCAN_CODE_IN_8			0X09
%define		KEYBOARD_SCAN_CODE_IN_9			0X0A
%define		KEYBOARD_SCAN_CODE_IN_A			0X1E
%define		KEYBOARD_SCAN_CODE_IN_B			0X30
%define		KEYBOARD_SCAN_CODE_IN_C			0X2E
%define		KEYBOARD_SCAN_CODE_IN_D			0X20
%define		KEYBOARD_SCAN_CODE_IN_E			0X12
%define		KEYBOARD_SCAN_CODE_IN_F			0X21
%define		KEYBOARD_SCAN_CODE_IN_G			0X22
%define		KEYBOARD_SCAN_CODE_IN_H			0X23
%define		KEYBOARD_SCAN_CODE_IN_I			0X17
%define		KEYBOARD_SCAN_CODE_IN_J			0X24
%define		KEYBOARD_SCAN_CODE_IN_K			0X25
%define		KEYBOARD_SCAN_CODE_IN_L			0X26
%define		KEYBOARD_SCAN_CODE_IN_M			0X32
%define		KEYBOARD_SCAN_CODE_IN_N			0X31
%define		KEYBOARD_SCAN_CODE_IN_O			0X18
%define		KEYBOARD_SCAN_CODE_IN_P			0X19
%define		KEYBOARD_SCAN_CODE_IN_Q			0X10
%define		KEYBOARD_SCAN_CODE_IN_R			0X13
%define		KEYBOARD_SCAN_CODE_IN_S			0X1F
%define		KEYBOARD_SCAN_CODE_IN_T			0X14
%define		KEYBOARD_SCAN_CODE_IN_U			0X16
%define		KEYBOARD_SCAN_CODE_IN_V			0X2F
%define		KEYBOARD_SCAN_CODE_IN_W			0X11
%define		KEYBOARD_SCAN_CODE_IN_X			0X2D
%define		KEYBOARD_SCAN_CODE_IN_Y			0X15
%define		KEYBOARD_SCAN_CODE_IN_Z			0X2C
%define		KEYBOARD_SCAN_CODE_IN_CAPS_LOCK		0x3A
%define		KEYBOARD_SCAN_CODE_IN_LSHIFT		0x2A
%define		KEYBOARD_SCAN_CODE_IN_RSHIFT		0x36

%define		KEYBOARD_ASCII_ESC			0x1A
%define		KEYBOARD_ASCII_0			'0'
%define		KEYBOARD_ASCII_1			'1'
%define		KEYBOARD_ASCII_2			'2'
%define		KEYBOARD_ASCII_3			'3'
%define		KEYBOARD_ASCII_4			'4'
%define		KEYBOARD_ASCII_5			'5'
%define		KEYBOARD_ASCII_6			'6'
%define		KEYBOARD_ASCII_7			'7'
%define		KEYBOARD_ASCII_8			'8'
%define		KEYBOARD_ASCII_9			'9'
%define		KEYBOARD_ASCII_A			'a'
%define		KEYBOARD_ASCII_B			'b'
%define		KEYBOARD_ASCII_C			'c'
%define		KEYBOARD_ASCII_D			'd'
%define		KEYBOARD_ASCII_E			'e'
%define		KEYBOARD_ASCII_F			'f'
%define		KEYBOARD_ASCII_G			'g'
%define		KEYBOARD_ASCII_H			'h'
%define		KEYBOARD_ASCII_I			'i'
%define		KEYBOARD_ASCII_J			'j'
%define		KEYBOARD_ASCII_K			'k'
%define		KEYBOARD_ASCII_L			'l'
%define		KEYBOARD_ASCII_M			'm'
%define		KEYBOARD_ASCII_N			'n'
%define		KEYBOARD_ASCII_O			'o'
%define		KEYBOARD_ASCII_P			'p'
%define		KEYBOARD_ASCII_Q			'q'
%define		KEYBOARD_ASCII_R			'r'
%define		KEYBOARD_ASCII_S			's'
%define		KEYBOARD_ASCII_T			't'
%define		KEYBOARD_ASCII_U			'u'
%define		KEYBOARD_ASCII_V			'v'
%define		KEYBOARD_ASCII_W			'w'
%define		KEYBOARD_ASCII_X			'x'
%define		KEYBOARD_ASCII_Y			'y'
%define		KEYBOARD_ASCII_Z			'z'

%define		KEYBOARD_ASCII_a_A_OFFSET		('A'-'a')

%define		KEYBOARD_KEYS				40

%define		KEYBOARD_FIFO_ITEM_SIZE			1
%define		KEYBOARD_FIFO_ITEMS			5

;********************************************************************************
; Tipos de datos
;********************************************************************************

;********************************************************************************
;@struct	keyboardKeyType
;@brief		Tipo de dato que conclomera scan code de entrada y su 
;		respectivo valor ASCII
;********************************************************************************
STRUC keyboardKeyType
.scanCodeIn	: resb 1 
.ascii		: resb 1
.size:
ENDSTRUC

