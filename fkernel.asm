org 500h                ;этот сектор будет загружаться по адресу 0000:0500h
message:
    mov ax, 0002h   ;очищаем экран
        int 10h
         
    mov dx,0h
    call SetCursorPos
        mov bp, msg
        mov cx, 20
        mov bl,04h                  
        xor bh,bh
        mov ax,1301h
        int 10h         ;вывод приглашения к вводу команды
         
        add dh,2            ;переводим курсор на один пункт вниз для ввода команды
        call SetCursorPos
        mov si,0
         
Command: 
    mov ah,10h
        int 16h
        cmp ah, 0Eh     ;Если нажата клавиша BackSpase - удалить символ
        jz Delete_symbol
        cmp al, 0Dh
        jz Input_Command
        mov [string+si],al
        inc si
        mov ah,09h
        mov bx,0004h
        mov cx,1
        int 10h
        add dl,1
    call SetCursorPos
    jmp Command
         
Input_Command:      ;Если нажат Enter, то переходим в третий сектор
    mov ax,cs
    mov ds,ax
    mov es,ax
    mov di,string
    push si     ;так как содержание регистра si меняется, сохраним в стеке
    mov si,write
    mov cx,5
    rep cmpsb ;сравниваем строки - если команда write, то переходим
    je wrt
    pop si
    jmp Command
         
Delete_symbol:
    cmp dl,0
    jz Command
    sub dl,1        ;сдвигаем курсор влево
    call SetCursorPos
    mov al,20h      ;вместо уже напечатанного символа выводим пробел
    mov [string + si],al ;стираем символ в строке
    mov ah,09h
    mov bx,0004h
        mov cx,1
        int 10h
        dec si          ;уменьшаем кол-во напечатанных символов
    jmp Command
         
wrt:    mov ax,0000h
        mov es,ax
        mov bx,700h         
        mov ch,0            ;номер цилиндра - 0
        mov cl,03h          ;начальный сектор - 3
        mov dh,0            ;номер головки - 0
        mov dl,80h          ;жесткий диск - 80h
        mov al,01h          ;кол-во читаемых секторов -1
        mov ah,02h
        int 13h
    jmp 0000:0700h
 
SetCursorPos:        ;установка курсора
        mov ah,2h
        xor bh,bh
        int 10h 
        ret
 
msg db 'Input the command...',0
write db 'write',0
string db 5 dup(?) ;буфер для ввода команды
