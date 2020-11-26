org 700h
start:
    mov ax,0002h    ;очищаем экран
    int 10h
        xor dx,dx
        call SetCursorPos   ;устанавливаем курсор
                                 
        mov bp, msg
        mov cx, 24
        call PrintMes   ;Вывод на экран строки msg
         
        mov dl,0
        mov dh,1
        call SetCursorPos   ;переводим курсор на одну строку вниз
        mov bp, helper
        mov cx,77
        call PrintMes       ;Вывод на экран строки helper
         
Option:                     ;Выбор - загрузить текст из четвертого сектора или начать новый
        mov ah,10h
        int 16h
        cmp ah, 3Bh         ;Если нажата клавиша F1 - загружаем текст
        jz Load_text
        cmp al, 0Dh         ;Если нажата клавиша Enter - печатаем текст
        jz Print_text
    jmp Option
         
Load_text:                  ;Загрузка текста
    mov ax,0000h
        mov es,ax
        mov bx,string         
        mov ch,0            ;номер цилиндра - 0
        mov cl,4            ;начальный сектор - 4
        mov dh,0            ;номер головки - 0
        mov dl,80h          ;жесткий диск - 80h
        mov al,01h          ;кол-во читаемых секторов -1
        mov ah,02h
        int 13h
        xor dl,dl
        mov dh,3
        call SetCursorPos
        mov bp, string
        mov cx, 256
        call PrintMes
        mov si,255
        add dl, 15          ;256-80*3=16
        add dh,3
        call SetCursorPos
        jmp Command
         
Print_text:
        xor dx,dx
        add dh,3
        call SetCursorPos   ;получаем позицию курсора
        mov si,0            ;Печать символов
Command: 
    mov ah,10h
        int 16h
        cmp al, 1Bh     ;Если нажата клавиша Esc - выход из приложения
        jz Esc
        cmp al, 0Dh     ;Если нажата клавиша Enter - переход на новую строку
        jz Caret
        cmp ah, 0Eh     ;Если нажата клавиша BackSpase - удалить символ
        jz Delete_symbol
        cmp ah, 3Ch     ;Если нажата клавиша F2- сохранить текст
        jz Save_text
        cmp si, 256
        jz Command
        mov [string + si],al
        inc si
        mov ah,09h
        mov bx,0004h
        mov cx,1
        int 10h
        add dl,1
        call SetCursorPos
    jmp Command
         
Caret:  ;переход на новую строку
    add dh,1
    xor dl,dl
        call SetCursorPos
        jmp Command
         
Save_text:  ;запись текста в 4 сектор
    mov ax,0000h
        mov es,ax
    mov ah, 03h
    mov al,1
    mov ch,0
    mov cl,4
    mov dh,0
    mov dl,80h
    mov bx, string
    int 13h
    jmp Command
         
Delete_symbol: ;удаление символа после нажатия BackSpase
    cmp dl,0
    jne Delete
    cmp dh,3
    jz Command
    sub dh,1
    mov dl,79
    jmp Cursor_Pos
Delete:     sub dl,1            ;сдвигаем курсор влево
Cursor_Pos: 
    call SetCursorPos
    mov al,20h          ;вместо уже напечатанного символа выводим пробел
    mov [string + si],al ;стираем символ в строке
    mov ah,09h
        mov bx,0004h
        mov cx,1
        int 10h
        cmp si,0
        jz Command
        dec si              ;уменьшаем кол-во напечатанных символов
    jmp Command
Esc:     
        jmp 0000:0500h      ;возвращаемся во второй сектор
         
;===================== Подпрограммы ===================================
  PrintMes:                ;в регистре  bp - строка, в регистре cx - длина этой строки
        mov bl,04h          ;в регистре  bl- атрибут
        mov ax,1301h
        int 10h
        ret
        ;----------------------------------
  SetCursorPos:                                     ;установка курсора
        mov ah,2h
        xor bh,bh
        int 10h 
        ret
             
        ;===================== выводимые сообщения===================== 
        msg db 'This is a text writer...',0 
        helper db 'To print text - press Enter, to load text - press F1, to save text - press F2',0
        string db 256 dup(?)    ;буфер для вводимого сообщения
