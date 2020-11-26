macro align value { db value-1 - ($ + value-1) mod (value) dup 0 }
HEADS = 1
SPT = 4	;4 сектора по 512 байт
Begin:
	file "fboot.bin",512 ; загрузчик
	file "fkernel.bin" ; первый файл, типа оболочка shell
	align 512
	file "fwriter.bin" ; второй файл - текстовый редатор
	align 512
	align HEADS*SPT*512
