;#########################################################################
;@file		pagination.asm
;@brief		Defines con las direcciones del mapa de tablas de paginacion y atributos.
;	    	Intel x86 compatible en 32 bit. 
;@author	Agustin Alba Chicar
;@date		Octubre, 2015
;#########################################################################


;********************************************************************************
; Defines
;********************************************************************************

%define		TABLE_OFFSET_MASK	0x1FF
%define		PDPT_ENTRY_MASK		0x3
%define		TABLE_ENTRY_MASK	0xFFFFF000

%define		PAGE_SIZE		0x1000
%define		TABLE_PAGE_ENTRIES	0x200		; Son 512 entradas de paginas
%define		TABLE_DIRECTORY_ENTRIES	0x200		; Son 512 entradas de tablas de paginas
%define		PAE_ENTRY_SIZE		8		; En PAE las entradas pesan 8 bytes


%define		PDPT_ROTATION_BITS	30
%define		DPT_ROTATION_BITS	21
%define		PT_ROTATION_BITS	12	


%define		ATTRIBUTE_PRESENT	0x1
%define		ATTRIBUTE_NOT_PRESENT	0x0

%define		ATTRIBUTE_WRITE		0x2
%define		ATTRIBUTE_READ		0x0

%define		ATTRIBUTE_SUPERVISOR	0x4
%define		ATTRIBUTE_USER		0x0

%define		ATTRIBUTE_WT		0x8
%define		ATTRIBUTE_WB		0x0

%define		ATTRIBUTE_CACHE_EN	0x10
%define		ATTRIBUTE_CACHE_DIS	0x0

%define		ATTRIBUTE_GLOBAL	0x100
%define		ATTRIBUTE_NOT_GLOBAL	0x0

%define		KERNEL_ATTRIBUTE	(ATTRIBUTE_GLOBAL | ATTRIBUTE_CACHE_DIS | ATTRIBUTE_PRESENT | ATTRIBUTE_SUPERVISOR | ATTRIBUTE_WRITE)
%define		TASK_ATTRIBUTE		(ATTRIBUTE_NOT_GLOBAL | ATTRIBUTE_CACHE_DIS | ATTRIBUTE_PRESENT | ATTRIBUTE_USER | ATTRIBUTE_WRITE)

%define		ENTRY_ATTRIBUTE		7		; Presente, Supervisor, Read & Write
%define		PTDP_ATTRIBUTE		ATTRIBUTE_PRESENT;1		; Solo presente



%define		NEW_PAGES_BASE_ADDRESS	0x160000	; Base de direcciones para seguir creando paginas.

%define		TP0			0x101000
%define		TP1			0x102000
%define		TP2			0x103000
%define		TDP			0x104000
%define		NEXT_TABLE_PAGE_POINTER	0x105000

%define		TASK1_DPT0_ADDRESS	0xA06000
%define		TASK1_PT0_ADDRESS	0xA07000
%define		TASK1_PT1_ADDRESS	0xA08000
%define		TASK1_PT2_ADDRESS	0xA09000

%define		TASK2_DPT0_ADDRESS	0xA16000
%define		TASK2_PT0_ADDRESS	0xA17000
%define		TASK2_PT1_ADDRESS	0xA18000
%define		TASK2_PT2_ADDRESS	0xA19000

%define		TASK3_DPT0_ADDRESS	0xA26000
%define		TASK3_PT0_ADDRESS	0xA27000
%define		TASK3_PT1_ADDRESS	0xA28000
%define		TASK3_PT2_ADDRESS	0xA29000

%define		TASK4_DPT0_ADDRESS	0xA36000
%define		TASK4_PT0_ADDRESS	0xA37000
%define		TASK4_PT1_ADDRESS	0xA38000
%define		TASK4_PT2_ADDRESS	0xA39000
