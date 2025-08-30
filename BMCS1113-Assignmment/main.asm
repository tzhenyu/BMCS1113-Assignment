TITLE Flight Booking System (BookFlight.asm)
; Assemble with Visual Studio + Irvine32 library
; MASM 32-bit code

INCLUDE Irvine32.inc

.data
; --- Menu Display Lines ---
menuLine1   BYTE "+-----+----------------------+----------------+----------------+----------------+-----------+------------+-------------+",0
menuLine2   BYTE "| ID  | Airline              | Departure      | Destination    | Departure Date | Trip Type | Return Date| Price (MYR) |",0
menuLine3   BYTE "+-----+----------------------+----------------+----------------+----------------+-----------+------------+-------------+",0
menuLine4   BYTE "| [1] | SkyJet Airlines      | Kuala Lumpur   | Singapore      | 2025-08-15     |  One-way  |     N/A    |      525    |",0
menuLine5   BYTE "| [2] | Oceanic Air          | Penang         | Bangkok        | 2025-08-16     |  Two-way  | 2025-08-21 |     2700    |",0
menuLine6   BYTE "| [3] | CloudNine Airways    | Johor Bahru    | Hong Kong      | 2025-08-17     |  Two-way  | 2025-08-22 |     7500    |",0
menuLine7   BYTE "| [4] | Eastern Horizon Air  | Kota Kinabalu  | Manila         | 2025-08-18     |  One-way  |     N/A    |     3300    |",0
menuLine8   BYTE "| [5] | Jet2 Holiday         | Kuching        | Jakarta        | 2025-08-19     |  Two-way  | 2025-08-24 |     5400    |",0
menuLine9   BYTE "+-----+----------------------+----------------+----------------+----------------+-----------+------------+-------------+",0

; --- Module 3 / 4 variables ---
selectedFlight BYTE ?
selectedTrip   BYTE ?       ; 1 = One-way, 2 = Two-way
ticketCost     DWORD ?
insuranceCost  DWORD ?

menuFlight     BYTE "Select flight [1-5]: ",0
menuTrip       BYTE "Select trip type: 1=One-way 2=Two-way : ",0
menuClass      BYTE "Select class: 1=Economy 2=Business : ",0
menuInsure     BYTE "Add insurance? 1=Yes 2=No : ",0
confirmMsg     BYTE "Booking Confirmation:",0
totalMsg       BYTE "Total ticket cost: RM",0
invalidMsg     BYTE "Invalid input! Please try again.",0

MASdepart      BYTE "MAS Departure: Kuala Lumpur",0
MASreturn      BYTE "MAS Return: Singapore",0
AAdDepart      BYTE "AA Departure: Penang",0
AAdReturn      BYTE "AA Return: Bangkok",0

.code

; ------------------------------------------------------------
; MAIN ENTRY POINT
; ------------------------------------------------------------
main PROC
    ; Display menu
    mov edx, OFFSET menuLine1
    call WriteString
    call Crlf
    mov edx, OFFSET menuLine2
    call WriteString
    call Crlf
    mov edx, OFFSET menuLine3
    call WriteString
    call Crlf
    mov edx, OFFSET menuLine4
    call WriteString
    call Crlf
    mov edx, OFFSET menuLine5
    call WriteString
    call Crlf
    mov edx, OFFSET menuLine6
    call WriteString
    call Crlf
    mov edx, OFFSET menuLine7
    call WriteString
    call Crlf
    mov edx, OFFSET menuLine8
    call WriteString
    call Crlf
    mov edx, OFFSET menuLine9
    call WriteString
    call Crlf
    call Crlf

    ; Call booking modules
    call Module3_FlightTrip
    call Module4_ClassInsurance

    INVOKE ExitProcess,0
main ENDP

; ------------------------------------------------------------
; Module 3: Flight selection & trip type
; ------------------------------------------------------------
Module3_FlightTrip PROC
FlightMenu:
    mov edx, OFFSET menuFlight
    call WriteString
    call ReadInt
    mov selectedFlight, al        ; store flight choice

    cmp al, 1
    jb InvalidFlight
    cmp al, 5
    ja InvalidFlight
    jmp TripMenuLabel

InvalidFlight:
    mov edx, OFFSET invalidMsg
    call WriteString
    call Crlf
    jmp FlightMenu

TripMenuLabel:
    mov edx, OFFSET menuTrip
    call WriteString
    call ReadInt
    mov selectedTrip, al          ; store trip type

    cmp al, 1
    je OneWay
    cmp al, 2
    je TwoWay

    mov edx, OFFSET invalidMsg
    call WriteString
    call Crlf
    jmp TripMenuLabel

OneWay:
    jmp ShowBooking

TwoWay:
    jmp ShowBooking

ShowBooking:
    mov edx, OFFSET confirmMsg
    call WriteString
    call Crlf

    mov al, selectedFlight
    cmp al, 1
    je Flight1
    cmp al, 2
    je Flight2
    jmp EndModule3

Flight1:
    mov edx, OFFSET MASdepart
    call WriteString
    call Crlf
    cmp selectedTrip, 2
    jne EndModule3
    mov edx, OFFSET MASreturn
    call WriteString
    call Crlf
    jmp EndModule3

Flight2:
    mov edx, OFFSET AAdDepart
    call WriteString
    call Crlf
    cmp selectedTrip, 2
    jne EndModule3
    mov edx, OFFSET AAdReturn
    call WriteString
    call Crlf

EndModule3:
    ret
Module3_FlightTrip ENDP

; ------------------------------------------------------------
; Module 4: Ticket Class & Insurance
; ------------------------------------------------------------
Module4_ClassInsurance PROC
ClassMenu:
    mov edx, OFFSET menuClass
    call WriteString
    call ReadInt
    cmp eax, 1
    je ClassEconomy
    cmp eax, 2
    je ClassBusiness
    mov edx, OFFSET invalidMsg
    call WriteString
    call Crlf
    jmp ClassMenu

ClassEconomy:
    mov ticketCost, 500
    jmp InsuranceMenu

ClassBusiness:
    mov ticketCost, 1200
    jmp InsuranceMenu

InsuranceMenu:
    mov edx, OFFSET menuInsure
    call WriteString
    call ReadInt
    cmp eax, 1
    je AddInsurance
    cmp eax, 2
    je SkipInsurance
    mov edx, OFFSET invalidMsg
    call WriteString
    call Crlf
    jmp InsuranceMenu

AddInsurance:
    add ticketCost, 100
    mov insuranceCost, 100
    jmp ShowTotal

SkipInsurance:
    mov insuranceCost, 0

ShowTotal:
    mov edx, OFFSET totalMsg
    call WriteString
    mov eax, ticketCost
    call WriteDec
    call Crlf
    ret
Module4_ClassInsurance ENDP

END main