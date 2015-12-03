SECTIONS
{
	/*Location counter of VMA 				*/
	. = 0xFFFFFFF0;	
	
	/*Seccion vector de reset.				*/
	/*Incluyo a todas las secciones y defino un simbolo	*/
	.reset_vector :
	  AT ( 0xFFFFFFF0 )
	  { *(.reset_vector) __reset_vector = . ; }

	/*Seccion de inicializacion de 16 bit			*/
	. = 0xFFFF0000;	
	.init16 :
	  AT ( 0xFFFF0000 )
	  { *(.init16); }
	  
	/*Seccion de inicializacion de 32 bit			*/
	. = 0x000F4000;
	__init32_VMA_start = .;
	.init32 :
	  AT ( 0xFFFF4000 )
	  { __init32_LMA_init = LOADADDR(.init32);
	    _init32_size = SIZEOF(.init32);
	    *(.init32); 
	    *(.text);
	    __init32_LMA_end = LOADADDR(.init32) + SIZEOF(.init32);}
	
	/*Seccion de tablas					*/
	. = 0x00100000;
	__sys_tables_VMA_start = .;
	.sys_tables :
	  AT ( LOADADDR(.init32) + SIZEOF(.init32) )
	  { __sys_tables_LMA_init = LOADADDR(.sys_tables);
	    _sys_tables_size = SIZEOF(.sys_tables);
	    *(.sys_tables);
	    __sys_tables_LMA_end = LOADADDR(.sys_tables) + SIZEOF(.sys_tables);}
	
	/*Seccion de tablas de paginacion			*/
	. = 0x00101000;
	__pagination_VMA_start = .;
	.pagination :
	  AT ( LOADADDR(.sys_tables) + SIZEOF(.sys_tables) )
	  { __pagination_LMA_init = LOADADDR(.pagination);
	    /*_pagination_size = SIZEOF(.pagination);*/
	    _pagination_size = 0x4000;
	    *(.pagination);
	    __pagination_LMA_end = LOADADDR(.pagination) + SIZEOF(.pagination);}	
	
	/*Seccion de pila					*/
	/*. = 0x00140000;					*/
	/*__stack_init = .;					*/
	/*_stack_size = 32768;					*/
	
	/*Seccion de código principal				*/
	. = 0x00150000;
	__main32_VMA_start = .;
	.main32 :
	  AT ( LOADADDR(.pagination) + SIZEOF(.pagination) )
	  { __main32_LMA_init = LOADADDR(.main32);
	    _main32_size = SIZEOF(.main32);
	    *(.text);
	    __main32_LMA_end = LOADADDR(.main32) + SIZEOF(.main32);}
	
	/*Seccion de datos inicializados			*/
	. = 0x00200000;
	__initialized_data_VMA_start = .;
	.initialized_data :
	  AT( LOADADDR(.main32) + SIZEOF(.main32) )
	  { __initialized_data_LMA_init = LOADADDR(.initialized_data);
	    _initialized_data_LMA_size = SIZEOF(.initialized_data);
	    *(.data);
	    __initialized_data_LMA_end = LOADADDR(.initialized_data) + SIZEOF(.initialized_data);}

        /*Seccion de bibliotecas                                */
        . = 0x00220000;
        __library_VMA_start = .;
        .library :
          AT( LOADADDR(.initialized_data) + SIZEOF(.initialized_data) )
          { __library_LMA_init = LOADADDR(.library);
            _library_LMA_size = SIZEOF(.library);
            *(.library);
            __library_LMA_end = LOADADDR(.library) + SIZEOF(.library);}
            
	/*Seccion de datos no inicializados			*/
	. = 0x00210000;
	__not_initialized_data_VMA_start = .;
	.not_initialized_data :
	  AT( LOADADDR(.library) + SIZEOF(.library) )
	  { __not_initialized_data_LMA_init = LOADADDR(.not_initialized_data);
	    _not_initialized_data_LMA_size = SIZEOF(.not_initialized_data);
	    *(.bss);
	    __not_initialized_data_LMA_end = LOADADDR(.not_initialized_data) + SIZEOF(.not_initialized_data);}

	/*Seccion de codigo de wrappers de system calls		*/
	. = 0x00230000;
	__shared_VMA_start = .;
	.shared :
	  AT( LOADADDR(.not_initialized_data) + SIZEOF(.not_initialized_data) )
	  { __shared_LMA_init = LOADADDR(.shared);
	    _shared_LMA_size = SIZEOF(.shared);
	    *(.shared);
	    __shared_LMA_end = LOADADDR(.shared) + SIZEOF(.shared);}
	    
	/*Seccion de codigo de la tarea 1			*/
	. = 0xA00000;
	__task1_code_start = .;
	.task1_code :
	  AT( LOADADDR(.shared) + SIZEOF(.shared) )
	  { __task1_code_LMA_init = LOADADDR(.task1_code);
	    _task1_code_LMA_size = SIZEOF(.task1_code);
	    *(.task1_code);
	    __task1_code_LMA_end = LOADADDR(.task1_code) + SIZEOF(.task1_code);}	    
	    
	/*Seccion de datos inicializados de la tarea 1		*/
	. = 0xA01000;
	__task1_initialized_data_start = .;
	.task1_initialized_data :
	  AT( LOADADDR(.task1_code) + SIZEOF(.task1_code) )
	  { __task1_initialized_data_LMA_init = LOADADDR(.task1_initialized_data);
	    _task1_initialized_data_LMA_size = SIZEOF(.task1_initialized_data);
	    *(.task1_initialized_data);
	    __task1_initialized_data_LMA_end = LOADADDR(.task1_initialized_data) + SIZEOF(.task1_initialized_data);}	    	    
	    
	/*Seccion de datos no inicializados de la tarea 1	*/
	. = 0xA02000;
	__task1_not_initialized_data_start = .;
	.task1_not_initialized_data :
	  AT( LOADADDR(.task1_initialized_data) + SIZEOF(.task1_initialized_data) )
	  { __task1_not_initialized_data_LMA_init = LOADADDR(.task1_not_initialized_data);
	    _task1_not_initialized_data_LMA_size = SIZEOF(.task1_not_initialized_data);
	    *(.task1_not_initialized_data);
	    __task1_not_initialized_data_LMA_end = LOADADDR(.task1_not_initialized_data) + SIZEOF(.task1_not_initialized_data);}	    	    	    
	    
	    
	/*Seccion de codigo de la tarea 2			*/
	. = 0xA10000;
	__task2_code_start = .;
	.task2_code :
	  AT( LOADADDR(.task1_not_initialized_data) + SIZEOF(.task1_not_initialized_data) )
	  { __task2_code_LMA_init = LOADADDR(.task2_code);
	    _task2_code_LMA_size = SIZEOF(.task2_code);
	    *(.task2_code);
	    __task2_code_LMA_end = LOADADDR(.task2_code) + SIZEOF(.task2_code);}	    
	    
	/*Seccion de datos inicializados de la tarea 2		*/
	. = 0xA11000;
	__task2_initialized_data_start = .;
	.task2_initialized_data :
	  AT( LOADADDR(.task2_code) + SIZEOF(.task2_code) )
	  { __task2_initialized_data_LMA_init = LOADADDR(.task2_initialized_data);
	    _task2_initialized_data_LMA_size = SIZEOF(.task2_initialized_data);
	    *(.task2_initialized_data);
	    __task2_initialized_data_LMA_end = LOADADDR(.task2_initialized_data) + SIZEOF(.task2_initialized_data);}	    	    
	    
	/*Seccion de datos no inicializados de la tarea 2	*/
	. = 0xA12000;
	__task2_not_initialized_data_start = .;
	.task2_not_initialized_data :
	  AT( LOADADDR(.task2_initialized_data) + SIZEOF(.task2_initialized_data) )
	  { __task2_not_initialized_data_LMA_init = LOADADDR(.task2_not_initialized_data);
	    _task2_not_initialized_data_LMA_size = SIZEOF(.task2_not_initialized_data);
	    *(.task2_not_initialized_data);
	    __task2_not_initialized_data_LMA_end = LOADADDR(.task2_not_initialized_data) + SIZEOF(.task2_not_initialized_data);}
	    
	/*Seccion de codigo de la tarea 3			*/
	. = 0xA20000;
	__task3_code_start = .;
	.task3_code :
	  AT( LOADADDR(.task2_not_initialized_data) + SIZEOF(.task2_not_initialized_data) )
	  { __task3_code_LMA_init = LOADADDR(.task3_code);
	    _task3_code_LMA_size = SIZEOF(.task3_code);
	    *(.task3_code);
	    __task3_code_LMA_end = LOADADDR(.task3_code) + SIZEOF(.task3_code);}	    
	    
	/*Seccion de datos inicializados de la tarea 3		*/
	. = 0xA21000;
	__task3_initialized_data_start = .;
	.task3_initialized_data :
	  AT( LOADADDR(.task3_code) + SIZEOF(.task3_code) )
	  { __task3_initialized_data_LMA_init = LOADADDR(.task3_initialized_data);
	    _task3_initialized_data_LMA_size = SIZEOF(.task3_initialized_data);
	    *(.task3_initialized_data);
	    __task3_initialized_data_LMA_end = LOADADDR(.task3_initialized_data) + SIZEOF(.task3_initialized_data);}	    	    
	    
	/*Seccion de datos no inicializados de la tarea 2	*/
	. = 0xA22000;
	__task3_not_initialized_data_start = .;
	.task3_not_initialized_data :
	  AT( LOADADDR(.task3_initialized_data) + SIZEOF(.task3_initialized_data) )
	  { __task3_not_initialized_data_LMA_init = LOADADDR(.task3_not_initialized_data);
	    _task3_not_initialized_data_LMA_size = SIZEOF(.task3_not_initialized_data);
	    *(.task3_not_initialized_data);
	    __task3_not_initialized_data_LMA_end = LOADADDR(.task3_not_initialized_data) + SIZEOF(.task3_not_initialized_data);}
	    

	/*Seccion de codigo de la tarea 4			*/
	. = 0xA30000;
	__task4_code_start = .;
	.task4_code :
	  AT( LOADADDR(.task3_not_initialized_data) + SIZEOF(.task3_not_initialized_data) )
	  { __task4_code_LMA_init = LOADADDR(.task4_code);
	    _task4_code_LMA_size = SIZEOF(.task4_code);
	    *(.task4_code);
	    __task4_code_LMA_end = LOADADDR(.task4_code) + SIZEOF(.task4_code);}	    
	    
	/*Seccion de datos inicializados de la tarea 4		*/
	. = 0xA31000;
	__task4_initialized_data_start = .;
	.task4_initialized_data :
	  AT( LOADADDR(.task4_code) + SIZEOF(.task4_code) )
	  { __task4_initialized_data_LMA_init = LOADADDR(.task4_initialized_data);
	    _task4_initialized_data_LMA_size = SIZEOF(.task4_initialized_data);
	    *(.task4_initialized_data);
	    __task4_initialized_data_LMA_end = LOADADDR(.task4_initialized_data) + SIZEOF(.task4_initialized_data);}	    	    
	    
	/*Seccion de datos no inicializados de la tarea 4	*/
	. = 0xA32000;
	__task4_not_initialized_data_start = .;
	.task4_not_initialized_data :
	  AT( LOADADDR(.task4_initialized_data) + SIZEOF(.task4_initialized_data) )
	  { __task4_not_initialized_data_LMA_init = LOADADDR(.task4_not_initialized_data);
	    _task4_not_initialized_data_LMA_size = SIZEOF(.task4_not_initialized_data);
	    *(.task4_not_initialized_data);
	    __task4_not_initialized_data_LMA_end = LOADADDR(.task4_not_initialized_data) + SIZEOF(.task4_not_initialized_data);}


	/*Punteros de stack para Kernel			*/	    
	__scheduler_stack_init = 0x140000;
	_scheduler_stack_size = 0x1000;

	/*Punteros de stack para la tarea 1			*/
	__task1_user_stack_init = 0xA03000;
	_task1_user_stack_size = 0x1000;
	__task1_kernel_stack_init = 0xA04000;
	_task1_kernel_stack_size = 0x1000;
	
	/*Punteros de stack para la tarea 2			*/
	__task2_user_stack_init = 0xA13000;	    
	_task2_user_stack_size = 0x1000;
	__task2_kernel_stack_init = 0xA14000;
	_task2_kernel_stack_size = 0x1000;
	
	/*Punteros de stack para la tarea 3			*/
	__task3_user_stack_init = 0xA23000;	    
	_task3_user_stack_size = 0x1000;
	__task3_kernel_stack_init = 0xA24000;
	_task3_kernel_stack_size = 0x1000;	

	/*Punteros de stack para la tarea 4			*/
	__task4_user_stack_init = 0xA33000;	    
	_task4_user_stack_size = 0x1000;
	__task4_kernel_stack_init = 0xA34000;
	_task4_kernel_stack_size = 0x1000;	
}