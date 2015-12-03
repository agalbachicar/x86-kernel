#----------------------------------------------------------------------
# @file		Makefile
# @author	Agustin Alba Chicar
# @brief	Makefile for compiling, configuring, etc.
# @details	See make help for details
#----------------------------------------------------------------------

## Variable definitions
#Assembler
AC		= nasm
AFLAGS		= -felf32
A_BIN_FLAGS	= -f bin
#C
CC		= gcc
CFLAGS		= -c -m32 -O0 -nostdlib -Wall
#Linker
LD		= ld
LFLAGS		= -z max-page-size=0x01000 --oformat=binary -m elf_i386
LDSCRIPT	= linker.lds
ODFLAGS		= -CprsSx --prefix-addresses
#ROM
ROM_NAME	= mi_rom
#Objetos, colocar los archivos .o que sean necesarios con su respectiva
#linea debajo de generate para lograr la dependencia correcta
OBJS		= init32.o sys_tables.o main32.o port.o video.o exception.o pagination.o numeric.o fifo.o interruption.o keyboard.o system.o tasks.o rtc.o shared.o
#main32.o 
#Output dir
OUTPUT_DIR	= debug/
#Bochs file
BOCHS_CFG	= bochsrc

ROM_LOCATION	= 0x000F0000

##Inicio de la dependencias
all:		create_output_dir generate

.PHONY :	help
help:
	@echo	''
	@echo	'Uso: '
	@echo 	'  make all:      		Compila y patchea'
	@echo	'  make help:     		Muestra la ayuda'
	@echo   '  make generate: 		Idem all'
	@echo	'  make dump:     		Muestra archivo binario de imagen'
	@echo   '  make edit:     		Muestra todos los archivos para edicion'
	@echo   '  make bochs:    		Ejecuta el bochs, pero primero limpia y compila todo'
	@echo	'  make clean:    		Elimina archivos auxiliares'	
	@echo	'  make create_output_dir: 	Crea el directorio de salida en caso de no existir'
	@echo	' '	
	
.PHONY : generate	
generate:  $(ROM_NAME).bin $(ROM_NAME).elf
	@echo	''
	@echo	'-----> Generando listados de hexadecimales y ELFs'
	hexdump -C $(addprefix $(OUTPUT_DIR), $(ROM_NAME).bin) > $(addprefix $(OUTPUT_DIR), $(ROM_NAME)_hexdump.txt)
	objdump $(ODFLAGS) $(addprefix $(OUTPUT_DIR), $(ROM_NAME).elf) > $(addprefix $(OUTPUT_DIR), $(ROM_NAME)_objdump.txt)
	readelf -a $(addprefix $(OUTPUT_DIR), $(ROM_NAME).elf) > $(addprefix $(OUTPUT_DIR), $(ROM_NAME)_readelf.txt)
	@echo	''


$(ROM_NAME).bin: $(OBJS)
	@echo	''
	@echo	'-----> Linkeando objetos en formato binario'
	$(LD) $(LFLAGS) -o $(addprefix $(OUTPUT_DIR), $@) $(addprefix $(OUTPUT_DIR), $(OBJS)) -T $(LDSCRIPT) -e Entry 
	
$(ROM_NAME).elf: $(OBJS)
	@echo	''
	@echo	'---> Linkeando objetos en formato ELF'
	$(LD) -z max-page-size=0x01000 -m elf_i386 -T $(LDSCRIPT) -e Entry $(addprefix $(OUTPUT_DIR), $(OBJS)) -o $(addprefix $(OUTPUT_DIR), $@)
	
init16.bin: init16.asm
	@echo	''
	@echo	'---> Compilando init16.asm'
	$(AC) -f bin $< -o debug/init16.bin -l debug/init16.lst -DROM_LOCATION=$(ROM_LOCATION)
	
init32.o: init32.asm init16.bin sys_tables.o port.o video.o exception.o pagination.o
	@echo	''
	@echo	'---> Compilando init32.asm'
	$(AC) $(AFLAGS) $< -o $(addprefix $(OUTPUT_DIR), $@) -l $(addprefix $(OUTPUT_DIR), init32.lst) 	

sys_tables.o: sys_tables.asm
	@echo	''
	@echo	'---> Compilando sys_tables.asm'
	$(AC) $(AFLAGS) $< -o $(addprefix $(OUTPUT_DIR), $@) -l $(addprefix $(OUTPUT_DIR), sys_tables.lst) 	

main32.o: main32.asm
	@echo	''
	@echo	'---> Compilando main32.asm'
	$(AC) $(AFLAGS) $< -o $(addprefix $(OUTPUT_DIR), $@) -l $(addprefix $(OUTPUT_DIR), main32.lst) 	

port.o: port.asm
	@echo	''
	@echo	'---> Compilando port.asm'
	$(AC) $(AFLAGS) $< -o $(addprefix $(OUTPUT_DIR), $@) -l $(addprefix $(OUTPUT_DIR), port.lst) 	

video.o: video.asm
	@echo	''
	@echo	'---> Compilando video.asm'
	$(AC) $(AFLAGS) $< -o $(addprefix $(OUTPUT_DIR), $@) -l $(addprefix $(OUTPUT_DIR), video.lst) 	
	
exception.o: exception.asm
	@echo	''
	@echo	'---> Compilando exception.asm'
	$(AC) $(AFLAGS) $< -o $(addprefix $(OUTPUT_DIR), $@) -l $(addprefix $(OUTPUT_DIR), exception.lst) 	

pagination.o: pagination.asm
	@echo	''
	@echo	'---> Compilando pagination.asm'
	$(AC) $(AFLAGS) $< -o $(addprefix $(OUTPUT_DIR), $@) -l $(addprefix $(OUTPUT_DIR), pagination.lst)
	
numeric.o: numeric.asm
	@echo	''
	@echo	'---> Compilando numeric.asm'
	$(AC) $(AFLAGS) $< -o $(addprefix $(OUTPUT_DIR), $@) -l $(addprefix $(OUTPUT_DIR), numeric.lst) 	
	
fifo.o: fifo.asm
	@echo	''
	@echo	'---> Compilando fifo.asm'
	$(AC) $(AFLAGS) $< -o $(addprefix $(OUTPUT_DIR), $@) -l $(addprefix $(OUTPUT_DIR), fifo.lst) 	
	
interruption.o: interruption.asm
	@echo	''
	@echo	'---> Compilando interruption.asm'
	$(AC) $(AFLAGS) $< -o $(addprefix $(OUTPUT_DIR), $@) -l $(addprefix $(OUTPUT_DIR), interruption.lst) 	

keyboard.o: keyboard.asm
	@echo	''
	@echo	'---> Compilando keyboard.asm'
	$(AC) $(AFLAGS) $< -o $(addprefix $(OUTPUT_DIR), $@) -l $(addprefix $(OUTPUT_DIR), keyboard.lst) 	
	
system.o: system.asm
	@echo	''
	@echo	'---> Compilando system.asm'
	$(AC) $(AFLAGS) $< -o $(addprefix $(OUTPUT_DIR), $@) -l $(addprefix $(OUTPUT_DIR), system.lst) 	

tasks.o: tasks.asm
	@echo	''
	@echo	'---> Compilando tasks.asm'
	$(AC) $(AFLAGS) $< -o $(addprefix $(OUTPUT_DIR), $@) -l $(addprefix $(OUTPUT_DIR), tasks.lst) 	
	
rtc.o: rtc.asm	
	@echo	''
	@echo	'---> Compilando rtc.asm'
	$(AC) $(AFLAGS) $< -o $(addprefix $(OUTPUT_DIR), $@) -l $(addprefix $(OUTPUT_DIR), rtc.lst) 	
	
shared.o: shared.asm
	@echo	''
	@echo	'---> Compilando shared.asm'
	$(AC) $(AFLAGS) $< -o $(addprefix $(OUTPUT_DIR), $@) -l $(addprefix $(OUTPUT_DIR), shared.lst) 	
	
.PHONY : dump
dump: 
	@echo	''
	@echo	'---> Realizando el dump de la imagen'
	hexdump $(OUTPUT_DIR)$(ROM_NAME).img

.PHONY : edit
edit:
	@echo	''
	@echo	'---> Abriendo todos los archivos'
	kate *.asm $(LDSCRIPT) $(BOCHS_CFG) Makefile &
	
.PHONY : bochs
bochs:  clean all
	@echo	''
	@echo	'---> Ejecutando el bochs'
	bochs -f $(BOCHS_CFG) -q

.PHONY : create_output_dir
create_output_dir:
	@echo	''
	@echo	'---> Creando directorio de salida'
	mkdir -p $(OUTPUT_DIR)

.PHONY : clean
clean:
	@echo	''
	@echo	'---> Limpieza de archivos'
	rm -f *~
	rm -f -r $(OUTPUT_DIR)*

	