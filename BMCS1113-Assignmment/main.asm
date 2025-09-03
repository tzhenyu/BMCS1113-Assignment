INCLUDE Irvine32.inc

.data
; Payment and booking variables
paymentMethod BYTE ? ; 1=Credit Card, 2=Cash
bookAnother BYTE ?   ; 1=Yes, 0=No
promptPayment BYTE "Select payment method: 1. Credit Card  2. Cash | Your Choice: ",0
promptSuccess BYTE "Payment successful. Flight booked!",0
promptAnother BYTE "Book another flight? 1=Yes 2=No : ",0
promptInvalid BYTE "Invalid input. Try again.",0
promptPay BYTE "Pay Amount : ",0
promptChange BYTE "Your change is: ",0
promptNotEnough BYTE "Not enough balance. Please enter a sufficient amount.",0
newline BYTE 13,10,0

totalBill DWORD 100 ; Example total bill amount
paymentAmount DWORD ?
change DWORD ?

.code
main PROC
    ; Main booking/payment loop
mainLoop:
    mov edx, OFFSET promptPayment
    call WriteString
    call ReadInt
    mov paymentMethod, al
    cmp al, 1
    je payment_ok
    cmp al, 2
    mov edx, OFFSET promptInvalid
    call WriteString
    mov edx, OFFSET newline
    call WriteString
    jmp mainLoop

payment_ok:
getPayment:
    mov edx, OFFSET promptPay
    call WriteString
    call ReadInt
    mov paymentAmount, eax
    mov eax, paymentAmount
    cmp eax, totalBill
    jl not_enough_balance
    sub eax, totalBill
    mov change, eax
    mov edx, OFFSET promptChange
    call WriteString
    mov eax, change
    call WriteInt
    mov edx, OFFSET newline
    call WriteString

    mov edx, OFFSET promptSuccess
    call WriteString
    mov edx, OFFSET newline
    call WriteString

    jmp askAnother

not_enough_balance:
    mov edx, OFFSET promptNotEnough
    call WriteString
    mov edx, OFFSET newline
    call WriteString
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
    mov edx, OFFSET newline
    call WriteString
    jmp askAnother

exitApp:
    INVOKE ExitProcess, 0
main ENDP
END main