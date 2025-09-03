INCLUDE Irvine32.inc

.data
; Payment and booking variables
paymentMethod BYTE ? ; 1=Credit Card, 2=E-wallet
bookAnother BYTE ?   ; 1=Yes, 0=No
promptPayment BYTE "Select payment method: 1. Credit Card  2. E-wallet | Your Choice: ",0
promptSuccess BYTE "Payment successful. Flight booked!",0
promptAnother BYTE "Book another flight? 1=Yes 2=No : ",0
promptInvalid BYTE "Invalid input. Try again.",0
promptPay BYTE "Pay Amount (e.g. 3500.75): ",0
promptChange BYTE "Your change is: ",0
promptNotEnough BYTE "Not enough balance. Please check again",0
inputStr BYTE 32 DUP(0)
totalBill DWORD 350000 ; Example total bill amount (RM 3500.00, in cents)
paymentAmount DWORD ?
change DWORD ?
dotStr BYTE ".",0

.code

; Reads a string and parses it as a decimal value (e.g., 3500.75 -> 350075)
; Result in paymentAmount (in cents)
ReadMoney PROC
    mov edx, OFFSET inputStr
    mov ecx, LENGTHOF inputStr
    call ReadString

    ; Parse integer part
    mov esi, OFFSET inputStr
    mov eax, 0
parse_int:
    mov bl, [esi]
    cmp bl, 0
    je int_done
    cmp bl, '.'
    je int_done
    cmp bl, '0'
    jb invalid_input
    cmp bl, '9'
    ja invalid_input
    sub bl, '0'
    movzx edx, bl
    imul eax, eax, 10
    add eax, edx
    inc esi
    jmp parse_int
int_done:
    imul eax, eax, 100 ; integer part * 100
    mov ebx, eax       ; ebx = total so far

    ; Parse decimal part (if any)
    mov bl, [esi]
    cmp bl, '.'

 jne no_decimal
    inc esi

    xor ecx, ecx       ; Always clear ecx for decimal part

    ; First decimal digit
    mov bl, [esi]
    cmp bl, 0
    je add_decimal
    cmp bl, '0'
    jb invalid_input
    cmp bl, '9'
    ja invalid_input
    sub bl, '0'
    movzx ecx, bl
    imul ecx, ecx, 10 ; first digit * 10
    inc esi

    ; Second decimal digit
    mov bl, [esi]
    cmp bl, 0
    je add_decimal
    cmp bl, '0'
    jb invalid_input
    cmp bl, '9'
    ja invalid_input
    sub bl, '0'
    movzx edx, bl      ; Use edx for second digit
    add ecx, edx       ; Add second digit to decimal part
    inc esi
    mov bl, [esi]
    cmp bl, 0
    jne invalid_input

add_decimal:
    ; ecx now contains the decimal part in cents (0-99)
    add ebx, ecx
    mov paymentAmount, ebx
    ret

no_decimal:
    mov paymentAmount, ebx
    ret

invalid_input:
    mov paymentAmount, 0
    ret
ReadMoney ENDP

; Prints a value in cents as a decimal (e.g., 1250 -> 12.50)
WriteMoney PROC
    push edx
    push eax
    mov edx, 0
    mov ebx, 100
    div ebx
    push edx
    call WriteInt
    mov edx, OFFSET dotStr
    call WriteString
    pop eax
    cmp eax, 10
    jge write_cents
    mov al, '0'
    call WriteChar
write_cents:
    call WriteInt
    pop eax
    pop edx
    ret
WriteMoney ENDP

payment PROC
mainLoop:
    mov edx, OFFSET promptPayment
    call WriteString
    call ReadInt
    mov paymentMethod, al
    cmp al, 1
    je payment_ok
    cmp al, 2
    je payment_ok
    mov edx, OFFSET promptInvalid
    call WriteString
    call Crlf
    jmp mainLoop

payment_ok:
getPayment:
    mov edx, OFFSET promptPay
    call WriteString
    call ReadMoney
    mov eax, paymentAmount
    cmp eax, totalBill
    jl not_enough_balance
    sub eax, totalBill
    mov change, eax
    mov edx, OFFSET promptChange
    call WriteString
    mov eax, change
    call WriteMoney
    call Crlf
    mov edx, OFFSET promptSuccess
    call WriteString
    call Crlf
    jmp askAnother

not_enough_balance:
    mov edx, OFFSET promptNotEnough
    call WriteString
    call Crlf
    jmp getPayment

askAnother:
    mov edx, OFFSET promptAnother
    call WriteString
    call ReadInt
    mov bookAnother, al
    cmp al, 1
    je mainLoop
    cmp al, 2
    je exitApp
    mov edx, OFFSET promptInvalid
    call WriteString
    call Crlf
    jmp askAnother

exitApp:
    ret

payment ENDP

main PROC
    call payment
    INVOKE ExitProcess, 0
main ENDP
END main