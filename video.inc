;#########################################################################
;@file		video.inc
;@brief		Defines de para el manejo de los atributos de la memoria de video
;	    	Intel x86 compatible en 32 bit. 
;@author	Agustin Alba Chicar
;@date		Octubre, 2015
;#########################################################################


;********************************************************************************
; Defines
;********************************************************************************

%define		VIDEO_CHARACTER_CLEAN			0x00
%define		VIDEO_WORD_FOREGROUND_BLUE_MASK		0x01
%define		VIDEO_WORD_FOREGROUND_GREEN_MASK	0x02
%define		VIDEO_WORD_FOREGROUND_RED_MASK		0x04
%define		VIDEO_WORD_INTENSITY_MASK		0x08
%define		VIDEO_WORD_BACKGROUND_BLUE_MASK		0x10
%define		VIDEO_WORD_BACKGROUND_GREEN_MASK	0x20
%define		VIDEO_WORD_BACKGROUND_RED_MASK		0x40
%define		VIDEO_WORD_BLINKING_MASK		0x80

%define		NULL					0x00