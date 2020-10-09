format PE console

include 'win32a.inc'

entry start

section '.data' data readable writable

        strElemInArray       db '[%d] = ', 0
        strIntSc             db '%d', 0
        strNmb               db '%d, ', 0
        strBeginBracketArr   db '[', 0
        strEndBracketArr     db ']', 10, 0
        strAArray            db 'A array: ', 0
        strBArray            db 'B array: ', 0
        strTypeInSizeofArray db 'Type in size of array: ', 0
        strSizeIsIncorrect   db '%d size is incorrect!', 10, 0

        pointStack      dd ?
        aArray          rd 100
        bArray          rd 100
        arrayASize      dd 0
        arrayBSize      dd 0
        tmp             dd ?
        tmpArrB         dd ?
        aFirst          dd ?
        aLast           dd ?
        i               dd ?

        NULL = 0

section '.code' code readable executable

;_________________________Main()___________________________
        start:
                push strTypeInSizeofArray
                call [printf]

                ;Получаем длину массива
                push arrayASize
                push strIntSc
                call [scanf]

                ;Проверка корректности ввода
                mov  eax, [arrayASize]
                cmp  eax, 0
                jle   incorrectSize

                cmp  eax, 100
                jg  incorrectSize

                ;Ввод массива А
                push [arrayASize]
                push aArray
                call readArray

                ;Генерация массива В
                push [arrayASize]
                push aArray
                push bArray
                call genArrayB

                ;Вывод в консоль массива А
                push strAArray
                call [printf]

                push [arrayASize]
                push aArray
                call printArray

                ;Вывод в консоль массива В
                push strBArray
                call [printf]

                push [arrayBSize]
                push bArray
                call printArray

                jmp finish

        incorrectSize:
                push [arrayASize]
                push strSizeIsIncorrect
                call [printf]

        finish:
                call [getch]

                push NULL
                call ExitProcess
;___________________________Main()___________________________


;___________________________ReadArray()___________________________
        readArray:
                push eax
                mov  eax, esp
                push ecx
                push edx

                xor  ecx, ecx
                mov  edx, [ss:eax+8+0]

        arrInputCycle:
                mov  [pointStack], eax
                mov  [tmp], edx
                mov  [i], ecx

                cmp  ecx, [ss:eax+8+4]
                jge  arrInputCycleEnd

                ;Получаем значение элементов
                push ecx
                push strElemInArray
                call [printf]

                push [tmp]
                push strIntSc
                call [scanf]

                mov  ecx, [i]
                inc  ecx
                mov  edx, [tmp]
                add  edx, 4
                mov  eax, [pointStack]
                jmp  arrInputCycle

        arrInputCycleEnd:
                sub  eax, 8
                mov  esp, eax
                pop  edx
                pop  ecx
                pop  eax

        ret
;___________________________ReadArray()___________________________


;___________________________GenArrayB()___________________________

        genArrayB:
                push eax
                mov  eax, esp
                push ecx
                push edx
                push ebx

                mov  edx, [ss:eax+8+4]
                mov  ebx, [ss:eax+8+0]

                ;Читаем значение первого элемента массива А
                mov  ecx, [edx]
                mov  [aFirst], ecx

                ;Читаем значение последнего элемента массива А
                mov  ecx, [ss:eax+8+8]
                mov  ecx, [edx+(ecx-1)*4]
                mov  [aLast], ecx

                xor  ecx, ecx

        arrBGenerCycle:
                mov  [tmp], edx
                mov  [tmpArrB], ebx
                mov  [i], ecx

                cmp  ecx, [ss:eax+8+8]
                jge  arrBGenerCycleEnd

                ;Проверяем, равен ли элемент первому или последнему элементу массива А
                mov  ecx, [aFirst]
                cmp  [edx], ecx
                je  nextElemArrA

                mov  ecx, [aLast]
                cmp  [edx], ecx
                je  nextElemArrA

                mov  ecx, [edx]
                mov  [ebx], ecx

                add  ebx, 4
                inc  [arrayBSize]

        nextElemArrA:
                mov  ecx, [i]
                inc  ecx
                add  edx, 4
                jmp  arrBGenerCycle


        arrBGenerCycleEnd:
                sub  eax, 12
                mov  esp, eax

                pop  ebx
                pop  edx
                pop  ecx
                pop  eax

        ret

;___________________________GenArrayB()___________________________


;___________________________printArray()___________________________

        printArray:
                push eax
                mov  eax, esp
                push ecx
                push edx

                mov  [pointStack], eax

                push strBeginBracketArr
                call [printf]

                mov  eax, [pointStack]

                xor  ecx, ecx
                mov  edx, [ss:eax+8+0]

        printArrayCycle:
                mov  [tmp], edx
                mov  [i], ecx

                cmp  ecx, [ss:eax+8+4];
                jge  printArrayCycleEnd

                mov  ecx, [edx]
                push ecx
                push strNmb
                call [printf]

                mov  edx, [tmp]
                add  edx, 4
                mov  ecx, [i]
                inc  ecx
                mov  eax, [pointStack]
                jmp  printArrayCycle

        printArrayCycleEnd:
                push strEndBracketArr
                call [printf]

                mov  eax, [pointStack]

                sub  eax, 8
                mov  esp, eax
                pop  edx
                pop  ecx
                pop  eax

        ret

;___________________________printArray()___________________________


section '.idata' data readable import

        library kernel, 'kernel32.dll',\
                msvcrt, 'msvcrt.dll'

        import kernel,\
               ExitProcess, 'ExitProcess'

        import msvcrt,\
               printf, 'printf',\
               scanf, 'scanf',\
               getch, '_getch'