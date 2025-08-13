
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

    ; Module 5 Data
    promptPax      BYTE "Number of passengers (1-20): ", 0
    promptName     BYTE "Passenger name: ", 0
    promptPassport BYTE "Passport number: ", 0
    errPaxMsg      BYTE "Invalid input. Please enter 1-20: ", 0
    
    ; Passenger Data
    pax DWORD ?
    passengerNames BYTE MAX_PASSENGERS DUP(NAME_SIZE DUP(?))
    passports BYTE MAX_PASSENGERS DUP(PASSPORT_SIZE DUP(?))

    ; Module 6 Data
    summaryTitle BYTE "Booking Summary",0Dh,0Ah,0
    memberStatus BYTE "Status: Member (15% discount)",0
    normalStatus BYTE "Status: Regular Customer",0
    priceLabel   BYTE "Total Price: RM",0
    newline      BYTE 0Dh,0Ah,0

    ; Pricing
    basePrice REAL8 199.99
    discount REAL8 0.15
    total REAL8 ?

.code
main PROC
    call PassengerInputModule
    call SummaryModule
    INVOKE ExitProcess, 0
main ENDP

;-----------------------------------------------------------
PassengerInputModule PROC
;
; Module 5: Collects passenger information
;-----------------------------------------------------------
    ; Get number of passengers
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
    jmp PassengerInputModule

GetPassengerData:
    mov ecx, pax
    mov esi, 0

PassengerLoop:
    ; Get passenger name
    mov edx, OFFSET promptName
    call WriteString
    mov edx, OFFSET passengerNames
    add edx, esi
    imul esi, NAME_SIZE    ; multiply index by NAME_SIZE
    add edx, esi
    call ReadString
    call Crlf

    ; Get passport number
    mov edx, OFFSET promptPassport
    call WriteString
    mov  edx, OFFSET passports  ; base address
    mov  eax, esi               ; copy index (so we don't destroy ESI)
    imul eax, PASSPORT_SIZE     ; scale index
    add  edx, eax               ; add scaled index
    call ReadString
    call Crlf

    inc esi
    loop PassengerLoop

    ret
PassengerInputModule ENDP

;-----------------------------------------------------------
SummaryModule PROC
;
; Module 6: Displays booking summary
;-----------------------------------------------------------
    ; Display header
    mov edx, OFFSET summaryTitle
    call WriteString

    ; Calculate base total
    fld basePrice
    fild pax
    fmul
    fstp total

    ; Apply discount (sample logic - replace with your membership check)
    mov eax, 1    ; 1 = member, 0 = non-member
    test eax, eax
    jz DisplayTotal

    ; Member discount calculation
    fld total
    fld discount
    fmul
    fld total
    fsub
    fstp total

    mov edx, OFFSET memberStatus
    call WriteString
    call Crlf
    jmp DisplayPrice

DisplayTotal:
    mov edx, OFFSET normalStatus
    call WriteString
    call Crlf

DisplayPrice:
    mov edx, OFFSET priceLabel
    call WriteString

    ; Display total price
    mov edx, OFFSET total
    call WriteFloat
    call Crlf

    ret
SummaryModule ENDP

END main