TITLE Flight Booking System (BookFlight.asm)
; Assemble with Visual Studio + Irvine32 library
; MASM 32-bit code

INCLUDE Irvine32.inc

.data
; Flight info table
flightTable BYTE "--------------------------------------------------",0Dh,0Ah,
             "| Airline    | Origin | Destination | Date       |",0Dh,0Ah,
             "--------------------------------------------------",0Dh,0Ah,
             "| 1. MAS     | KUL    | BKK         | 20/08/2025 |",0Dh,0Ah,
             "| 2. AIRASIA | PEN    | SIN         | 21/08/2025 |",0Dh,0Ah,
             "--------------------------------------------------",0

; Menus
menuFlight  BYTE "Select a flight:",0Dh,0Ah,
             "1. MAS (KUL -> BKK, 20/08/2025)",0Dh,0Ah,
             "2. AirAsia (PEN -> SIN, 21/08/2025)",0Dh,0Ah,
             "Choice: ",0

menuTrip    BYTE 0Dh,0Ah,"Select Trip Type:",0Dh,0Ah,
             "1. One-way",0Dh,0Ah,
             "2. Two-way",0Dh,0Ah,
             "Choice: ",0

menuClass   BYTE 0Dh,0Ah,"Select Ticket Class:",0Dh,0Ah,
             "1. Economy (RM500)",0Dh,0Ah,
             "2. Business (RM1200)",0Dh,0Ah,
             "Choice: ",0

menuInsure  BYTE 0Dh,0Ah,"Add Insurance (RM100)?",0Dh,0Ah,
             "1. Yes",0Dh,0Ah,
             "2. No",0Dh,0Ah,
             "Choice: ",0

; Messages
confirmMsg  BYTE 0Dh,0Ah,"Booking Confirmed:",0Dh,0Ah,0
totalMsg    BYTE 0Dh,0Ah,"Total Ticket Cost: RM",0

; Flight details
MASdepart   BYTE "Departure: MAS     | KUL -> BKK | 20/08/2025",0Dh,0Ah,0
MASreturn   BYTE "Return    : MAS     | BKK -> KUL | 25/08/2025",0Dh,0Ah,0

AAdDepart   BYTE "Departure: AIRASIA | PEN -> SIN | 21/08/2025",0Dh,0Ah,0
AAdReturn   BYTE "Return    : AIRASIA | SIN -> PEN | 26/08/2025",0Dh,0Ah,0

invalidMsg  BYTE "Invalid choice. Try again.",0Dh,0Ah,0

; Variables
selectedFlight DWORD 0   ; 1 = MAS, 2 = AirAsia
selectedTrip   DWORD 0   ; 1 = One-way, 2 = Two-way
ticketCost     DWORD 0   ; final cost

.code
main PROC
    ; Show flight table
    mov edx, OFFSET flightTable
    call WriteString
    call Crlf

; --- Step 1: Select Flight ---
FlightMenu:
    mov edx, OFFSET menuFlight
    call WriteString
    call ReadInt

    cmp eax, 1
    je ChooseMAS
    cmp eax, 2
    je ChooseAA

    mov edx, OFFSET invalidMsg
    call WriteString
    jmp FlightMenu

ChooseMAS:
    mov selectedFlight, 1
    jmp TripMenu

ChooseAA:
    mov selectedFlight, 2
    jmp TripMenu

; --- Step 2: Select Trip Type ---
TripMenu:
    mov edx, OFFSET menuTrip
    call WriteString
    call ReadInt

    cmp eax, 1
    je OneWay
    cmp eax, 2
    je TwoWay

    mov edx, OFFSET invalidMsg
    call WriteString
    jmp TripMenu

OneWay:
    mov selectedTrip, 1
    jmp ShowBooking

TwoWay:
    mov selectedTrip, 2
    jmp ShowBooking

; --- Show Booking Confirmation ---
ShowBooking:
    mov edx, OFFSET confirmMsg
    call WriteString

    mov eax, selectedFlight
    cmp eax, 1
    je ShowMAS
    cmp eax, 2
    je ShowAA

ShowMAS:
    mov edx, OFFSET MASdepart
    call WriteString
    mov eax, selectedTrip
    cmp eax, 2
    jne ContinueToTicket
    mov edx, OFFSET MASreturn
    call WriteString
    jmp ContinueToTicket

ShowAA:
    mov edx, OFFSET AAdDepart
    call WriteString
    mov eax, selectedTrip
    cmp eax, 2
    jne ContinueToTicket
    mov edx, OFFSET AAdReturn
    call WriteString
    jmp ContinueToTicket

; --- Step 3: Select Ticket Class ---
ContinueToTicket:
    mov edx, OFFSET menuClass
    call WriteString
    call ReadInt

    cmp eax, 1
    je ClassEconomy
    cmp eax, 2
    je ClassBusiness

    mov edx, OFFSET invalidMsg
    call WriteString
    jmp ContinueToTicket

ClassEconomy:
    mov ticketCost, 500
    jmp InsuranceMenu

ClassBusiness:
    mov ticketCost, 1200
    jmp InsuranceMenu

; --- Step 4: Insurance ---
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
    jmp InsuranceMenu

AddInsurance:
    add ticketCost, 100
    jmp ShowTotal

SkipInsurance:
    jmp ShowTotal

; --- Show Total ---
ShowTotal:
    mov edx, OFFSET totalMsg
    call WriteString
    mov eax, ticketCost
    call WriteDec
    call Crlf

    exit
main ENDP

END main
