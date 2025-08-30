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
    MAX_PASSENGERS = 20
    NAME_SIZE = 50
    PASSPORT_SIZE = 20
    CUSTOMER_ID_SIZE = 10

    ; Module 5 Data
    promptPax      BYTE "Number of passengers (1-20): ", 0
    promptName     BYTE "Passenger name: ", 0
    promptPassport BYTE "Passport number: ", 0
    promptCustomer BYTE "Customer ID (C12345 format): ", 0
    errPaxMsg      BYTE "Invalid input. Please enter 1-20: ", 0
    
    ; Passenger Data
    pax DWORD ?
    customerId BYTE CUSTOMER_ID_SIZE DUP(?)
    passengerNames BYTE MAX_PASSENGERS DUP(NAME_SIZE DUP(?))
    passports BYTE MAX_PASSENGERS DUP(PASSPORT_SIZE DUP(?))
    isMember DWORD 0  ; 0 = not member, 1 = member

    ; Module 6 Data
    summaryTitle BYTE "----- Booking Summary -----",0Dh,0Ah,0
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

    ; Check if customer ID starts with 'C' (membership requirement)
    mov al, customerId
    cmp al, 'C'
    jne NotMember

    ; If starts with 'C', check if followed by numbers
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
SummaryModule PROC
;
; Module 6: Displays booking summary and calculates price
;-----------------------------------------------------------
    ; Display header
    mov edx, OFFSET summaryTitle
    call WriteString
    call Crlf

    ; Display customer ID
    mov edx, OFFSET promptCustomer
    call WriteString
    mov edx, OFFSET customerId
    call WriteString
    call Crlf

    ; Display status
    cmp isMember, 1
    jne RegularCustomer
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
    call WriteFloat
    call Crlf

    ; Show original price for comparison
    mov edx, OFFSET priceLabel
    call WriteString
    mov edx, OFFSET priceLabel
    call WriteString
    fld total
    call WriteFloat
    mov al, ' '
    call WriteChar
    mov al, '('
    call WriteChar
    mov al, 'o'
    call WriteChar
    mov al, 'r'
    call WriteChar
    mov al, 'i'
    call WriteChar
    mov al, 'g'
    call WriteChar
    mov al, 'i'
    call WriteChar
    mov al, 'n'
    call WriteChar
    mov al, 'a'
    call WriteChar
    mov al, 'l'
    call WriteChar
    mov al, ' '
    call WriteChar
    mov al, 'p'
    call WriteChar
    mov al, 'r'
    call WriteChar
    mov al, 'i'
    call WriteChar
    mov al, 'c'
    call WriteChar
    mov al, 'e'
    call WriteChar
    mov al, ')'
    call WriteChar
    call Crlf
    jmp Done

ShowRegularPrice:
    fld total
    call WriteFloat
    call Crlf

Done:
    ; Display final separator
    mov edx, OFFSET separatorLine
    call WriteString
    ret
SummaryModule ENDP

END main