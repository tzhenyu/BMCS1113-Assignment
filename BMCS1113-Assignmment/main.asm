.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

include \Irvine32\Irvine32.inc
includelib \Irvine32\Irvine32.lib
includelib \Irvine32\Kernel32.lib
includelib \Irvine32\User32.lib

.data
    ; Constants
    MAX_PASSENGERS = 5
    NAME_SIZE = 50
    PASSPORT_SIZE = 20
    CUSTOMER_ID_SIZE = 10

    ; Module 5 Data
    promptPax      BYTE "Number of passengers (1-5): ", 0
    promptName     BYTE "Passenger name: ", 0
    promptPassport BYTE "Passport number: ", 0
    promptCustomer BYTE "Customer ID (C12345 format): ", 0
    errPaxMsg      BYTE "Invalid input. Please enter 1-5: ", 0
    
    ; Passenger Data
    pax DWORD ?
    customerId BYTE CUSTOMER_ID_SIZE DUP(?)
    passengerNames BYTE MAX_PASSENGERS DUP(NAME_SIZE DUP(?))
    passports BYTE MAX_PASSENGERS DUP(PASSPORT_SIZE DUP(?))
    isMember DWORD 0  ; 0 = not member, 1 = member

    ; For float formatting
    tempInt DWORD ?
    hundred REAL8 100.0

    ; Module 6 Data
    summaryTitle BYTE "----- Booking Ticket -----",0Dh,0Ah,0
    memberDetected BYTE "Membership detected! 15% discount applied!",0Dh,0Ah,0
    memberStatus BYTE "Status: Member (15% discount)",0Dh,0Ah,0
    normalStatus BYTE "Status: Regular Customer",0Dh,0Ah,0
    priceLabel   BYTE "Total Price: RM",0
    newline      BYTE 0Dh,0Ah,0
    passengerHeader BYTE "Passenger Details:",0Dh,0Ah,0
    passengerLine BYTE "Name: ",0
    passportLine BYTE "Passport: ",0
    separatorLine BYTE "-----------------------------",0Dh,0Ah,0

    ; Pricing
    basePrice REAL8 199.99
    discount REAL8 0.15
    total REAL8 ?
    discountedTotal REAL8 ?

.code
main PROC
    call CustomerIdModule
    call PassengerInputModule
    call SummaryModule
    INVOKE ExitProcess, 0
main ENDP

;-----------------------------------------------------------
CustomerIdModule PROC
;
; Gets customer ID and checks membership
;-----------------------------------------------------------
    mov edx, OFFSET promptCustomer
    call WriteString
    mov edx, OFFSET customerId
    mov ecx, CUSTOMER_ID_SIZE
    call ReadString
    call Crlf

    ; Check if customer ID starts with 'C' or 'c' (case-insensitive)
    mov al, customerId
    cmp al, 'C'
    je CheckRestOfId
    cmp al, 'c'
    je CheckRestOfId
    jmp NotMember

CheckRestOfId:
    ; If starts with 'C' or 'c', check if followed by numbers
    mov ecx, 1
CheckDigits:
    mov al, customerId[ecx]
    cmp al, 0
    je ValidMemberId
    cmp al, '0'
    jl NotMember
    cmp al, '9'
    jg NotMember
    inc ecx
    jmp CheckDigits

ValidMemberId:
    mov isMember, 1
    mov edx, OFFSET memberDetected
    call WriteString
    call Crlf
    ret

NotMember:
    mov isMember, 0
    ret
CustomerIdModule ENDP

;-----------------------------------------------------------
PassengerInputModule PROC
;
; Module 5: Collects passenger information
;-----------------------------------------------------------
    ; Get number of passengers
GetPaxCount:
    mov edx, OFFSET promptPax
    call WriteString
    call ReadInt
    
    cmp eax, 1
    jl InvalidInput
    cmp eax, MAX_PASSENGERS
    jg InvalidInput
    mov pax, eax
    jmp GetPassengerData

InvalidInput:
    mov edx, OFFSET errPaxMsg
    call WriteString
    jmp GetPaxCount

GetPassengerData:
    mov ecx, pax
    mov esi, 0

PassengerLoop:
    push ecx  ; Save loop counter
    
    ; Get passenger name (offset = esi * NAME_SIZE)
    mov edx, OFFSET promptName
    call WriteString
    mov eax, esi
    mov ebx, NAME_SIZE
    mul ebx
    mov edx, OFFSET passengerNames
    add edx, eax
    mov ecx, NAME_SIZE
    call ReadString
    call Crlf

    ; Get passport number (offset = esi * PASSPORT_SIZE)
    mov edx, OFFSET promptPassport
    call WriteString
    mov eax, esi
    mov ebx, PASSPORT_SIZE
    mul ebx
    mov edx, OFFSET passports
    add edx, eax
    mov ecx, PASSPORT_SIZE
    call ReadString
    call Crlf

    pop ecx   ; Restore loop counter
    inc esi
    loop PassengerLoop

    ret
PassengerInputModule ENDP

;-----------------------------------------------------------
WriteFloat2Decimal PROC
;
; Writes a floating-point number with 2 decimal places
;-----------------------------------------------------------
    LOCAL negativeFlag:BYTE
    
    mov negativeFlag, 0
    
    ; Check if negative
    fld ST(0)
    ftst
    fstsw ax
    sahf
    jnb PositiveNumber
    mov negativeFlag, 1
    fchs  ; Make positive
    
PositiveNumber:
    ; Multiply by 100, round to integer
    fmul hundred
    frndint
    fistp tempInt
    
    ; Display negative sign if needed
    cmp negativeFlag, 0
    je DisplayNumber
    mov al, '-'
    call WriteChar
    
DisplayNumber:
    ; Display integer part (dollars)
    mov eax, tempInt
    mov edx, 0
    mov ebx, 100
    div ebx
    call WriteDec
    
    ; Display decimal point
    mov al, '.'
    call WriteChar
    
    ; Display cents (2 decimal places)
    mov eax, edx  ; remainder contains cents
    cmp eax, 10
    jge DisplayCents
    mov al, '0'   ; add leading zero if needed
    call WriteChar
    
DisplayCents:
    call WriteDec
    ret
WriteFloat2Decimal ENDP

;-----------------------------------------------------------
SummaryModule PROC
;
; Module 6: Displays booking summary and calculates price
;-----------------------------------------------------------
    ; Display header
    mov edx, OFFSET summaryTitle
    call WriteString
    call Crlf

    ; Display membership status message if member
    cmp isMember, 1
    jne RegularCustomer
    
    ; Show membership detected message
    mov edx, OFFSET memberDetected
    call WriteString
    
    mov edx, OFFSET memberStatus
    call WriteString
    jmp CalculatePrice

RegularCustomer:
    mov edx, OFFSET normalStatus
    call WriteString

CalculatePrice:
    ; Calculate base total (price * passengers)
    fild pax
    fld basePrice
    fmul
    fstp total

    ; Apply discount if member
    cmp isMember, 1
    jne DisplayPassengers

    fld total
    fld discount
    fmul
    fld total
    fsub
    fstp discountedTotal

    ; Display passenger details
DisplayPassengers:
    mov edx, OFFSET passengerHeader
    call WriteString
    mov ecx, pax
    mov esi, 0

DisplayLoop:
    push ecx

    ; Display name
    mov edx, OFFSET passengerLine
    call WriteString
    mov eax, esi
    mov ebx, NAME_SIZE
    mul ebx
    mov edx, OFFSET passengerNames
    add edx, eax
    call WriteString
    call Crlf

    ; Display passport
    mov edx, OFFSET passportLine
    call WriteString
    mov eax, esi
    mov ebx, PASSPORT_SIZE
    mul ebx
    mov edx, OFFSET passports
    add edx, eax
    call WriteString
    call Crlf
    call Crlf

    pop ecx
    inc esi
    loop DisplayLoop

    ; Display separator
    mov edx, OFFSET separatorLine
    call WriteString

    ; Display pricing information
    mov edx, OFFSET priceLabel
    call WriteString

    ; Display appropriate total
    cmp isMember, 1
    jne ShowRegularPrice

    ; Show discounted price
    fld discountedTotal
    call WriteFloat2Decimal
    call Crlf
    jmp Done

ShowRegularPrice:
    fld total
    call WriteFloat2Decimal
    call Crlf

Done:
    ; Display final separator
    mov edx, OFFSET separatorLine
    call WriteString
    ret
SummaryModule ENDP

END main