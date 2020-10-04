; Tkachenko Eduard
; Вариант 6
; Необходимо составить массив B из элементов A, которые кратны введенному числу x.

format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strVecSize   db 'size of vector? ', 0
        strX         db 'x? ', 0
        strA         db 'A: ', 10, 0
        strB         db 10, 'B: ', 10, 0
        strEmptyVectorB db 10, 'The array B is empty.', 0
        strIncorSize db 'Incorrect size of vector = %d', 10, 0
        strVecElemI  db '[%d]? ', 0
        strScanInt   db '%d', 0
        strVecElemOut  db '[%d] = %d', 10, 0

        vec_size_A   dd 0
        vec_size_B   dd 0
        x            dd ?
        i            dd ?
        tmp          dd ?
        tmpStack     dd ?
        vecA         rd 100
        vecB         rd 100
;--------------------------------------------------------------------------
section '.code' code readable executable
start:
; 1) vector input
        call VectorInput
        call xInput
; 2) get vector multiples

        call vectorMultiples

; 4) print vector out
        call VectorOutA
        call VectorOutB
finish:
        call [getch]

        push 0
        call [ExitProcess]
;--------------------------------------------------------------------------
xInput:
        push strX
        call [printf]
        add esp, 4

        push x
        push strScanInt
        call [scanf]
        add esp, 8

        ret

;--------------------------------------------------------------------------
VectorInput:
        push strVecSize
        call [printf]
        add esp, 4

        push vec_size_A
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [vec_size_A]
        cmp eax, 0
        jle fail
        cmp eax, 100
        jg fail
        jmp getVector

fail:
        push [vec_size_A]
        push strIncorSize
        call [printf]
        call [getch]
        push 0
        call [ExitProcess]

getVector:
        xor ecx, ecx            ; ecx = 0
        mov ebx, vecA           ; ebx = &vecA
getVecLoop:
        mov [tmp], ebx
        cmp ecx, [vec_size_A]
        jge endInputVector       ; to end of loop

        ; input element
        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getVecLoop
endInputVector:
        ret
;--------------------------------------------------------------------------
vectorMultiples:
        xor ecx, ecx            ; ecx = 0
        mov [tmpStack], esp
        mov ebx, vecA           ; ebx = &vecA
        mov edi, vecB
multiplesVecLoop:
        cmp ecx, [vec_size_A]
        je endMultiplesVector      ; to end of loop

        mov eax, [ebx]
        xor edx, edx

        cmp [x], 0
        je xIsZero

        div [x]
        cmp edx, 0
        jne nextIteration

        jmp addElement

xIsZero:
        cmp eax, 0
        je addElement
        jmp nextIteration

addElement:
        mov eax, [ebx]
        mov [edi], eax
        inc [vec_size_B]
        add edi, 4
        jmp nextIteration

nextIteration:
        inc ecx
        add ebx, 4
        jmp multiplesVecLoop

endMultiplesVector:
        mov edi, [tmpStack]
        ret
;--------------------------------------------------------------------------
VectorOutA:
        push strA
        call [printf]
        add esp, 4

        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, vecA           ; ebx = &vecB

putVecLoopA:
        mov [tmp], ebx
        cmp ecx, [vec_size_A]
        je endOutputVectorA      ; to end of loop
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecLoopA
endOutputVectorA:
        mov esp, [tmpStack]
        ret
;--------------------------------------------------------------------------
VectorOutB:
        cmp [vec_size_B], 0
        je OutputEmptyVectorB

        push strB
        call [printf]
        add esp, 4

        mov [tmpStack], esp
        xor ecx, ecx            ; ecx = 0
        mov ebx, vecB           ; ebx = &vecB
putVecLoopB:
        mov [tmp], ebx
        cmp ecx, [vec_size_B]
        je endOutputVectorB      ; to end of loop
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecLoopB
OutputEmptyVectorB:
        push strEmptyVectorB
        call [printf]
        add esp, 4
        jmp endOutputVectorB
endOutputVectorB:
        mov esp, [tmpStack]
        ret
;-------------------------------third act - including HeapApi--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'