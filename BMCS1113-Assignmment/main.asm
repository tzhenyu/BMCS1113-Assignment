.386
.model flat, stdcall
.stack 4096

ExitProcess PROTO, dwExitCode:DWORD
INCLUDE Irvine32.inc

.data
; Payment and booking variables
paymentMethod BYTE ? ; 1=Credit Card, 2=Cash
bookAnother BYTE ?   ; 1=Yes, 0=No
promptPayment BYTE "Select payment method: 1. Credit Card  2. Cash | Your Choice: ",0
promptSuccess BYTE "Payment successful. Flight booked!",0
promptAnother BYTE "Book another flight? 1=Yes 2=No : ",0
promptInvalid BYTE "Invalid input. Try again.",0
newline BYTE 13,10,0

.code
main PROC
    ; Main booking/payment loop
mainLoop:
    ; --- Payment Module ---
    mov edx, OFFSET promptPayment
    call WriteString
    call ReadInt
    mov paymentMethod, al
    cmp al, 1
    je payment_ok
    cmp al, 2
    je payment_ok
    ; Invalid input
    mov edx, OFFSET promptInvalid
    call WriteString
    mov edx, OFFSET newline
    call WriteString
    jmp mainLoop

payment_ok:
    mov edx, OFFSET promptSuccess
    call WriteString
    mov edx, OFFSET newline
    call WriteString

    ; --- Book Another Flight Module ---
askAnother:
    mov edx, OFFSET promptAnother
    call WriteString
    call ReadInt
    mov bookAnother, al
    cmp al, 1
    je mainLoop
    cmp al, 2
    je exitApp
    ; Invalid input
    mov edx, OFFSET promptInvalid
    call WriteString
    mov edx, OFFSET newline
    call WriteString
    jmp askAnother

exitApp:
    INVOKE ExitProcess, 0
main ENDP

END main