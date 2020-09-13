; -------------------------------------------------------------------------------------

        ; FASM version of Win32 Hello World:

        ; http://msdn.microsoft.com/en-us/library/vstudio/bb384843.aspx

; -------------------------------------------------------------------------------------

 format PE GUI 4.0

 entry win_main

 include 'win32a.inc'

; -------------------------------------------------------------------------------------

 section '.code' code readable executable

  win_main:

        ; initialise the members of the wcex structure

        ; --------------------------------------------

        ; WNDCLASSEX

        ; UINT cbSize
        ; UINT style
        ; WNDPROC lpfnWndProc
        ; int cbClsExtra
        ; int cbWndExtra
        ; HINSTANCE hInstance
        ; HICON hIcon
        ; HCURSOR hCursor
        ; HBRUSH hbrBackground
        ; LPCTSTR lpszMenuName
        ; LPCTSTR lpszClassName
        ; HICON hIconSm

        ; --------------------------------------------

        ; the instance handle

        invoke GetModuleHandle,0

        mov [wcex.hInstance],eax

        ; cbSize

        mov eax,sizeof.WNDCLASSEX

        mov [wcex.cbSize],eax

        ; the windows proc

        mov [wcex.lpfnWndProc],WndProc

        ; the windows style

        mov [wcex.style],CS_HREDRAW+CS_VREDRAW

        ; load the icons

        invoke LoadIcon,[wcex.hInstance],IDI_APPLICATION

        mov [wcex.hIcon],eax

        mov [wcex.hIconSm],eax

        ; load the cursor

        invoke LoadCursor,NULL,IDC_ARROW

        mov [wcex.hCursor],eax

        ; the brush for the background

        mov [wcex.hbrBackground],COLOR_WINDOW+1

        ; the windows class name

        mov dword [wcex.lpszClassName],szClass

        ; set to NULL

        mov [wcex.cbClsExtra],0

        mov [wcex.cbWndExtra],0

        mov dword [wcex.lpszMenuName],NULL

        ; register wcex

        ; RegisterClassEx(&wcex)

        invoke RegisterClassEx,wcex

        test eax,eax

        jz reg_error

        ; create the window

        invoke CreateWindowEx,0,szClass,szTitle,WS_OVERLAPPEDWINDOW,\
                              CW_USEDEFAULT,CW_USEDEFAULT,\
                              500,100,NULL,NULL,[wcex.hInstance],NULL

        test eax,eax

        jz cr_error

        mov [h_wnd],eax

        ; show and update the window

        ; ShowWindow(hWnd,SW_SHOWNORMAL)

        invoke ShowWindow,[h_wnd],SW_SHOWNORMAL

        ; UpdateWindow(hWnd)

        invoke UpdateWindow,[h_wnd]

  msg_loop:

        ; the main message loop

        ; GetMessage(&msg,NULL,0,0)

        invoke GetMessage,msg,NULL,0,0

        cmp eax,1

        jb exit

        jne msg_loop

        ; TranslateMessage(&msg)

        invoke TranslateMessage,msg

        ; DispatchMessage(&msg)

        invoke DispatchMessage,msg

        jmp msg_loop

  reg_error:

        invoke MessageBox,NULL,szRegError,szTitle,MB_ICONERROR+MB_OK

        jmp exit

  cr_error:

        invoke MessageBox,NULL,szCreateError,szTitle,MB_ICONERROR+MB_OK

  exit:

        ; return msg.wParam

        invoke  ExitProcess,[msg.wParam]

; -------------------------------------------------------------------------------------

proc WndProc uses ebx esi edi,hwnd,wmsg,wparam,lparam

  ; WndProc(hwnd,wmsg,wparam,lparam)

  ; callback function to process messages for the main window

        cmp [wmsg],WM_PAINT

        je .PAINT

        cmp [wmsg],WM_DESTROY

        je .DESTROY

  .DEFAULT:

        ; DefWindowProc(hWnd,message,wParam,lParam)

        invoke DefWindowProc,[hwnd],[wmsg],[wparam],[lparam]

        jmp .DONE

  .PAINT:

        ; hdc = BeginPaint(hWnd,&ps)

        invoke BeginPaint,[hwnd],ps

        mov [hdc],eax

        ; TextOut(hdc,5,5,greeting,len(greeting))

        invoke TextOut,[hdc],5,5,szGreeting,12

        ; EndPaint(hWnd,&ps)

        invoke EndPaint,[hwnd],ps

        jmp .DONE

  .DESTROY:

        ; PostQuitMessage(0)

        invoke PostQuitMessage,0

        xor eax,eax

  .DONE:

        ret

endp

; -------------------------------------------------------------------------------------

section '.idata' import data readable writeable

  library kernel,'KERNEL32.DLL',\
          user,'USER32.DLL',\
          gdi,'GDI32.DLL'

  import kernel,\
         GetModuleHandle,'GetModuleHandleA',\
         ExitProcess,'ExitProcess'

  import user,\
         RegisterClassEx,'RegisterClassExA',\
         CreateWindowEx,'CreateWindowExA',\
         ShowWindow,'ShowWindow',\
         UpdateWindow,'UpdateWindow',\
         GetMessage,'GetMessageA',\
         TranslateMessage,'TranslateMessage',\
         DispatchMessage,'DispatchMessageA',\
         MessageBox,'MessageBoxA',\
         DefWindowProc,'DefWindowProcA',\
         BeginPaint,'BeginPaint',\
         EndPaint,'EndPaint',\
         PostQuitMessage,'PostQuitMessage',\
         LoadIcon,'LoadIconA',\
         LoadCursor,'LoadCursorA'

  import gdi,\
         TextOut,'TextOutA'

; -------------------------------------------------------------------------------------

section '.data' readable writeable

  szClass TCHAR "Win32app",0

  szTitle TCHAR "Win32 Application",0 

  szGreeting TCHAR "Hello World!",0

  szRegError TCHAR "Call to RegisterClassEx failed!",0

  szCreateError TCHAR "Call to CreateWindowEx failed!",0

  wcex WNDCLASSEX

  ps PAINTSTRUCT

  msg MSG

  h_wnd dd 0

  hdc dd 0

; -