; Tkachenko Eduard
; Вариант 26
;

format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strMaxNmb    db 'The maximum parameter of the factorial function, at which the function value does not exceed 10^9: %d', 10, 0  ; Строка для вывода ответа.

        nmb          dd 1 ;Счетчик для поиска максимального параметра(резульата работы программы).
        maxNumber    dd 1000000000 ;Максимальное число для числа Фибоначчи.
        i            dd ? ;Счётчик для поиска числа Фибоначчи с заданным номером.
;--------------------------------------------------------------------------
section '.code' code readable executable
start:
        call getMaxNmb
        push eax
        push strMaxNmb
        call [printf]

finish:
        call [getch]

        push 0
        call [ExitProcess]
;--------------------------------------------------------------------------
getMaxNmb: ;Подпрограмма, после выполнения которой в регистре eax хранится максимальный параметр функции факториала, при котором значение функции не превышает = 10^9.
        mov [nmb], 1
        xor eax, eax
loopGetMaxNmb: ;Цикл, проверяюющий что не достигнут параметр, при котором число Фибоначчи больше 10^9.
        cmp eax, [maxNumber]
        jg endLoopGetMaxNmb
        add [nmb], 1
        mov eax, [nmb]
        call fibonacci
        jmp loopGetMaxNmb
endLoopGetMaxNmb:
        dec [nmb]
        mov eax, [nmb]
        ret

;--------------------------------------------------------------------------
fibonacci: ;Принимает на вход в регистре eax номер числа Фибоначчи, которое подпрограмма вычисляет и сохраняет в регистр eax.
        mov ebx, 0
        mov ecx, 1
        mov [i], 2
loopFibonacciNumber:
        cmp [i], eax
        jg endFibonacci
        add [i], 1
        xor ebx, ecx
        xor ecx, ebx
        xor ebx, ecx
        add ecx, ebx
        jmp loopFibonacciNumber
endFibonacci:
        mov eax, ecx
        ret
;--------------------------------------------------------------------------

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