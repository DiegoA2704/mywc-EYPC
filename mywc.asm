;Integrantes:
; - Alonso Olivar Diego
; - Calzada Rivera Gerardo Yahir
; - Mendieta Villa Adrian
; - Zarate Mendoza Luis Alejandro

;; @details: Programa completo que cuenta líneas, palabras y caracteres de un archivo

section .data
    msg_err_args db "Error: faltan argumentos", 10
    len_args     equ $ - msg_err_args
    msg_err_open db "No se pudo abrir el archivo", 10
    len_open     equ $ - msg_err_open

section .bss
    descriptor resd 1
    lines      resd 1
    words      resd 1
    chars      resd 1
    caracter   resd 1

section .text
global _start

_start:
    push ebp
    mov  ebp, esp

    ;Verifica que sean los argumentos sean iguales o mayores a dos
    mov  eax, [ebp+4]        
    cmp  eax, 2
    jl   .error_args

    ; Abrir en modo lectura
    mov  eax, 5
    mov  ebx, [ebp+12]       
    mov  ecx, 0
    int  0x80

    ;Comprueba si se pudo abrir el archivo
    cmp  eax, 0
    jl   .error_open
    mov  [descriptor], eax   

    ;Se inicializan las variables
    mov  dword [lines], 0
    mov  dword [words], 0
    mov  dword [chars], 0

.ciclo_mywc:
    mov  eax, 3
    mov  ebx, [descriptor]
    mov  ecx, caracter
    mov  edx, 1
    int  0x80

    ; while (!feof(file))
    cmp  eax, 0
    jle  .fin_lectura
    mov  al, [caracter]

    ; switch
    cmp  al, 10
    je   .caso_salto_linea
    cmp  al, 32
    je   .caso_espacio_tab
    cmp  al, 9
    je   .caso_espacio_tab
    jmp  .caso_default

.caso_salto_linea:
    inc  dword [lines]
    inc  dword [chars]
    inc  dword [words]
    jmp  .siguiente_iteracion

.caso_espacio_tab:
    inc  dword [chars]
    inc  dword [words]
    jmp  .siguiente_iteracion

.caso_default:
    inc  dword [chars]

.siguiente_iteracion:
    jmp  .ciclo_mywc        

.fin_lectura:
    mov  eax, 6
    mov  ebx, [descriptor]
    int  0x80
    jmp  .fin_exito

.error_args:
    mov  eax, 4
    mov  ebx, 2
    mov  ecx, msg_err_args
    mov  edx, len_args
    int  0x80
    jmp  .salir_error

.error_open:
    mov  eax, 4
    mov  ebx, 2
    mov  ecx, msg_err_open
    mov  edx, len_open
    int  0x80

.salir_error:
    mov  eax, 1
    mov  ebx, 1
    int  0x80

.fin_exito:
    mov  esp, ebp
    pop  ebp

    mov  eax, 1
    xor  ebx, ebx
    int  0x80