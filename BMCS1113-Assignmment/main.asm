INCLUDE Irvine32.inc

; ============================================================
; Data Section
; ============================================================
.data

; ------------------------------------------------------------
; ZHEN YU - User Authentication and Main Menu Module
; ------------------------------------------------------------
; --- User State Variables ---
currentUser          BYTE 0      ; Tracks the currently logged-in user (0 = none, 1 = user1, 2 = user2)

; --- User Credentials ---
user1name   DB "12345",0        ; Username for user 1 (no membership)
user1pw     DB "8888",0         ; Password for user 1
user2name   DB "67890",0        ; Username for user 2 (membership)
user2pw     DB "9999",0         ; Password for user 2

; --- Messages ---
welcomeMessage      DB "Welcome to the Flight Booking System!",0
loginMessage         DB "Please enter your username: ",0
passwordMessage      DB "Please enter your password: ",0
invalidMessage       DB "Invalid choice! Press [ENTER] to try again.",0
wrongPwordMessage    DB "Wrong password. Press [ENTER] to try again.",0
wrongUsernameMessage DB "Invalid username. Press [ENTER] to try again.",0
nextSessionMessage   DB "Press [ENTER] to continue.", 0
byeMessage           DB "Thank you for using the system. Goodbye!",0
user1found           DB "Hi, User 1. No membership privilege.",0
user2found           DB "Hi, User 2. Have membership privilege.",0
greetUser1           DB "Hi, user 1!",0
greetUser2           DB "Hi, user 2!",0

; --- Input Buffer ---
userInput DB 50 DUP(0)          ; Buffer for user input (up to 49 chars + null terminator)

; --- Menu Display Lines ---
menuLine1   DB "+-----+----------------------+----------------+----------------+----------------+-----------+------------+-------------+",0
menuLine2   DB "| ID  | Airline              | Departure      | Destination    | Departure Date | Trip Type | Return Date| Price (MYR) |",0
menuLine3   DB "+-----+----------------------+----------------+----------------+----------------+-----------+------------+-------------+",0
menuLine4   DB "| [1] | SkyJet Airlines      | Kuala Lumpur   | Singapore      | 2025-08-15     |  One-way  |     N/A    |   525.00    |",0
menuLine5   DB "| [2] | Oceanic Air          | Penang         | Bangkok        | 2025-08-16     |  Two-way  | 2025-08-21 |  2700.00    |",0
menuLine6   DB "| [3] | CloudNine Airways    | Johor Bahru    | Hong Kong      | 2025-08-17     |  Two-way  | 2025-08-22 |  7500.00    |",0
menuLine7   DB "| [4] | Eastern Horizon Air  | Kota Kinabalu  | Manila         | 2025-08-18     |  One-way  |     N/A    |  3300.00    |",0
menuLine8   DB "| [5] | Jet2 Holiday         | Kuching        | Jakarta        | 2025-08-19     |  Two-way  | 2025-08-24 |  5400.00    |",0
menuLine9   DB "+-----+----------------------+----------------+----------------+----------------+-----------+------------+-------------+",0
menuLine10  DB "Select [0] to log out. [6] View booking history.",0

; ------------------------------------------------------------
; YAN ZHE - Flight Selection and Price Calculation Module
; ------------------------------------------------------------
; prices used for calculations (must match the table above)
flightPrices DWORD 525,2700,7500,3300,5400

; prompts and messages
promptFlight  BYTE "Choose your option [0-6]: ",0
promptClass   BYTE "Choose class: [1] Economy [2] Business : ",0
promptIns     BYTE "Add insurance? [1] Yes [2] No : ",0
invalidMsg    BYTE "Invalid input! Please try again.",0

msgBase       BYTE "Base Price:      RM",0
msgClass      BYTE "Class Adj:       RM",0
msgIns        BYTE "Insurance:       RM",0
msgSep        BYTE "-----------------------------",0
msgTotal      BYTE "Total:           RM",0
msgPerPax     BYTE "Pax:             ",0
msgDiscount   BYTE "Discount (15%):  -RM",0
msgSepLong    BYTE "-----------------------------",0
msgSepLong2   BYTE "-----------------------------",0
msgGrandTotal BYTE "Grand Total:     RM",0

; temp/user variables
selectedID    DWORD ?
basePrice     DWORD ?
classPrice    DWORD ?
insPrice      DWORD ?
totalPrice    DWORD ?

; ------------------------------------------------------------
; GUAN RONG - Passenger Information and Booking Summary Module
; ------------------------------------------------------------
; Constants
MAX_PASSENGERS = 5
NAME_SIZE = 50
PASSPORT_SIZE = 20

; Module 5 Data
promptPax      BYTE "Number of passengers [1-5]: ", 0
promptName     BYTE "Passenger name: ", 0
promptPassport BYTE "Passport number: ", 0
errPaxMsg      BYTE "Invalid input. Please enter [1-5]: ", 0
errNameMsg     BYTE "Invalid name! Name must contain only letters and spaces: ", 0
errPassportMsg BYTE "Invalid passport! Must be 6-15 characters (numbers and uppercase letters only): ", 0

; Passenger Data
pax DWORD ?
passengerNames BYTE MAX_PASSENGERS * NAME_SIZE DUP(0)
passports BYTE MAX_PASSENGERS * PASSPORT_SIZE DUP(0)

; For float formatting
tempInt DWORD ?
hundred REAL8 100.0
dotStr BYTE ".",0

; Module 6 Data
summaryTitle BYTE "----- Booking Ticket -----",0Dh,0Ah,0
paxTitle BYTE "----- Passenger Info -----",0Dh,0Ah,0
memberStatus BYTE "Status: Member (15% discount)",0Dh,0Ah,0
normalStatus BYTE "Status: Regular Customer",0Dh,0Ah,0
priceLabel   BYTE "Total Price: RM",0
newline      BYTE 0Dh,0Ah,0
passengerHeader BYTE "Passenger Details:",0Dh,0Ah,0
passengerLine BYTE "Name: ",0
passportLine BYTE "Passport: ",0
separatorLine BYTE "-----------------------------",0Dh,0Ah,0

; Pricing
discount REAL8 0.15
total DWORD ?
discountedTotal DWORD ?
discountAmount DWORD ?

; ------------------------------------------------------------
; Booking History Module
; ------------------------------------------------------------
; Constants for booking history
BOOKING_SIZE = 200

; Booking history data
bookingCount DWORD 0
bookingHistory BYTE 10 DUP(BOOKING_SIZE DUP(?))
bookingFlightIDs DWORD 10 DUP(?)
bookingTotalPrices DWORD 10 DUP(?)
bookingPassengerCounts DWORD 10 DUP(?)

; Airline names for history display
airline1 BYTE "SkyJet Airlines",0
airline2 BYTE "Oceanic Air",0
airline3 BYTE "CloudNine Airways",0
airline4 BYTE "Eastern Horizon Air",0
airline5 BYTE "Jet2 Holiday",0

; Booking history messages
historyTitle BYTE "----- Your Booking History -----",0Dh,0Ah,0
noBookingsMsg BYTE "No previous bookings found.",0Dh,0Ah,0
bookingEntryMsg BYTE "Booking #",0
flightMsg BYTE " | Flight: ",0
priceMsg BYTE " | Total: RM",0
paxMsg BYTE " | Passengers: ",0

; ------------------------------------------------------------
; ADAM - Payment Processing and Transaction Module
; ------------------------------------------------------------
; Payment and booking variables
paymentMethod BYTE ? ; 1=Credit Card, 2=E-wallet
bookAnother BYTE ?   ; 1=Yes, 0=No
promptPayment BYTE "Select payment method: [1] Credit Card  [2] E-wallet | Your Choice: ",0
promptSuccess BYTE "Payment successful. Flight booked!",0
promptAnother BYTE "Book another flight? [1] Yes [2] No : ",0
promptInvalid BYTE "Invalid input. Try again.",0
promptPay BYTE "Pay Amount: RM",0
promptChange BYTE "Your change is: RM",0
promptNotEnough BYTE "Not enough balance. Please check again",0
inputStr BYTE 32 DUP(0)
paymentAmount DWORD ?
paymentChange DWORD ?  ; Separate variable for payment change calculation

; ------------------------------------------------------------
; Ticket Printing Module
; ------------------------------------------------------------
; Ticket display messages
ticketHeader1 BYTE "===============================================",0
ticketHeader2 BYTE "           FLIGHT BOOKING TICKET              ",0
ticketHeader3 BYTE "===============================================",0
ticketBookingRef BYTE "Booking Reference: FB",0
ticketDate BYTE "Booking Date: 2025-09-04",0
ticketSeparator BYTE "-----------------------------------------------",0
ticketFlightInfo BYTE "FLIGHT INFORMATION",0
ticketAirlineLabel BYTE "Airline: ",0
ticketRouteLabel BYTE "Route: ",0
ticketDateLabel BYTE "Departure: ",0
ticketClassLabel BYTE "Class: ",0
ticketInsuranceLabel BYTE "Insurance: ",0
ticketPaxInfo BYTE "PASSENGER INFORMATION",0
ticketPaxCount BYTE "Number of Passengers: ",0
ticketTotalLabel BYTE "TOTAL AMOUNT: RM",0
ticketPaymentLabel BYTE "Payment Method: ",0
ticketThankYou BYTE "Thank you for choosing our airline!",0
ticketContact BYTE "For inquiries: +60-3-1234-5678",0
printPrompt BYTE "Print ticket? [1] Yes [2] No: ",0

; Class and insurance text
economyText BYTE "Economy",0
businessText BYTE "Business",0
yesText BYTE "Yes",0
noText BYTE "No",0
creditCardText BYTE "Credit Card",0
ewalletText BYTE "E-wallet",0

; Flight route information arrays
departureLocations BYTE "Kuala Lumpur",0,"Penang       ",0,"Johor Bahru  ",0,"Kota Kinabalu",0,"Kuching      ",0
destinationLocations BYTE "Singapore ",0,"Bangkok   ",0,"Hong Kong ",0,"Manila    ",0,"Jakarta   ",0
departureDates BYTE "2025-12-14",0,"2025-12-16",0,"2025-12-18",0,"2025-12-18",0,"2025-12-19",0

; Flight map
FlightSeat1 BYTE "   A B C D E F", 0
FlightSeat2 BYTE "01 O O O O O O", 0
FlightSeat3 BYTE "02 O O O O O O", 0
FlightSeat4 BYTE "03 O O O O O O", 0
FlightSeat5 BYTE "04 O O O O O O", 0
FlightSeat6 BYTE "05 O O O O O O", 0
FlightSeat7 BYTE "06 O O O O O O", 0
FlightSeat8 BYTE "07 O O O O O O", 0
FlightSeat9 BYTE "08 O O O O O O", 0
FlightSeat10 BYTE "09 O O O O O O", 0
FlightSeat11 BYTE "10 O O O O O O", 0
FlightSeat12 BYTE "11 O O O O O O", 0
FlightSeat13 BYTE "12 O O O O O O", 0
FlightSeat14 BYTE "13 O O O O O O", 0
FlightSeat15 BYTE "14 O O O O O O", 0
FlightSeat16 BYTE "15 O O O O O O", 0
FlightSeat17 BYTE "16 O O O O O O", 0
FlightSeat18 BYTE "17 O O O O O O", 0
FlightSeat19 BYTE "18 O O O O O O", 0
FlightSeat20 BYTE "19 O O O O O O", 0
FlightSeat21 BYTE "20 O O O O O O", 0

SeatRow BYTE "Enter row number (1-20): ", 0
SeatColumn BYTE "Enter column letter (A-F): ", 0

; ============================================================
; Code Section
; ============================================================
.code

; ------------------------------------------------------------
; ZHEN YU - User Authentication and Main Menu Procedures
; ------------------------------------------------------------

;-----------------------------------------------------------
main PROC
;
; Program entry point - starts the flight booking system
;-----------------------------------------------------------
    call login         ; Start with login procedure
    exit               ; Exit program after login returns (should not happen)
main ENDP

;-----------------------------------------------------------
login PROC
;
; Handles user authentication and loops until successful login
;-----------------------------------------------------------
    call clrscr
    mov currentUser, 0 ; Reset current user


login_loop:

    call clrscr
    mov edx, OFFSET separatorLine
    call WriteString

    mov edx, OFFSET welcomeMessage
    call WriteString
    call crlf
    mov edx, OFFSET separatorLine
    call WriteString
    

    mov edx, OFFSET loginMessage
    call WriteString   ; Prompt for username
    call crlf

    mov edx, OFFSET userInput
    mov ecx, SIZEOF userInput
    call ReadString    ; Read username input

    ; Check if input matches user1
    INVOKE Str_compare, ADDR userInput, ADDR user1name
    je user1_found

    ; Check if input matches user2
    INVOKE Str_compare, ADDR userInput, ADDR user2name
    je user2_found

    ; If username is invalid
    mov edx, OFFSET wrongUsernameMessage
    call WriteString
    call crlf
    call waitEnter     ; Wait for user to press Enter
    jmp login_loop     ; Retry login

user1_found:
    call crlf
    mov currentUser, 1
    mov edx, OFFSET user1found
    call WriteString   ; Greet user 1
    call crlf
    mov edx, OFFSET passwordMessage
    call WriteString   ; Prompt for password
    call crlf

    mov edx, OFFSET userInput
    mov ecx, SIZEOF userInput
    call ReadString    ; Read password input
    INVOKE Str_compare, ADDR userInput, ADDR user1pw
    je selectTicket       ; If password correct, go to main menu ## changed to selectticket

    ; If password is incorrect
    mov edx, OFFSET wrongPwordMessage
    call WriteString
    call crlf
    call waitEnter
    jmp login_loop     ; Retry login

user2_found:
    call crlf
    mov currentUser, 2
    mov edx, OFFSET user2found
    call WriteString   ; Greet user 2
    call crlf
    mov edx, OFFSET passwordMessage
    call WriteString   ; Prompt for password
    call crlf

    mov edx, OFFSET userInput
    mov ecx, SIZEOF userInput
    call ReadString    ; Read password input
    INVOKE Str_compare, ADDR userInput, ADDR user2pw
    je selectTicket       ; If password correct, go to main menu ## CHANGED TO SELECTTICKET

    ; If password is incorrect
    mov edx, OFFSET wrongPwordMessage
    call WriteString
    call crlf
    call waitEnter
    jmp login_loop     ; Retry login

login_end:
    ret
login ENDP


;-----------------------------------------------------------
waitEnter PROC
;
; Waits until the user presses the Enter key
;-----------------------------------------------------------
waitLoop:
    call ReadChar
    cmp al, 13                  ; 13 = ASCII code for Enter
    jne waitLoop
    ret
waitEnter ENDP

; ------------------------------------------------------------
; YAN ZHE - Flight Selection and Price Calculation Procedures
; ------------------------------------------------------------

;-----------------------------------------------------------
selectTicket PROC
;
; Displays flight menu, handles flight selection, class choice, and insurance options
;-----------------------------------------------------------

    call Clrscr

    ; Display personalized greeting based on user
    mov al, currentUser
    cmp al, 1
    je show_user1_greet
    cmp al, 2
    je show_user2_greet
    jmp show_menu

show_user1_greet:
    mov edx, OFFSET greetUser1
    call WriteString
    call crlf
    jmp show_menu

show_user2_greet:
    mov edx, OFFSET greetUser2
    call WriteString
    call crlf

show_menu:
       
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

    mov edx, OFFSET menuLine10
    call WriteString
    call Crlf

    call Crlf


; -------- get flight id (with validation) --------
GetFlight:
    mov edx, OFFSET promptFlight
    call WriteString
    call ReadInt           ; EAX = user's input
    cmp eax, 0
    je LogoutSelected      ; If user selects 0, go to logout
    cmp eax, 6
    je ViewHistory         ; If user selects 6, view booking history
    cmp eax, 1
    jl InvalidFlight
    cmp eax, 5
    jg InvalidFlight
    mov selectedID, eax
    jmp AfterFlight

ViewHistory:
    call DisplayBookingHistory
    jmp selectTicket       ; Return to main menu after viewing history

InvalidFlight:
    mov edx, OFFSET invalidMsg
    call WriteString
    call Crlf
    jmp GetFlight

LogoutSelected:
    call login             ; Call login function when user selects 0
    ret                    ; Return from selectTicket procedure

AfterFlight:
    ; clear screen and show only the selected row (with borders)
    call Clrscr

    mov edx, OFFSET menuLine1
    call WriteString
    call Crlf

    mov edx, OFFSET menuLine2
    call WriteString
    call Crlf

    mov edx, OFFSET menuLine3
    call WriteString
    call Crlf

    mov eax, selectedID
    cmp eax, 1
    je ShowRow1
    cmp eax, 2
    je ShowRow2
    cmp eax, 3
    je ShowRow3
    cmp eax, 4
    je ShowRow4
    jmp ShowRow5

ShowRow1:
    mov edx, OFFSET menuLine4
    call WriteString
    call Crlf
    jmp ShowRowEnd
ShowRow2:
    mov edx, OFFSET menuLine5
    call WriteString
    call Crlf
    jmp ShowRowEnd
ShowRow3:
    mov edx, OFFSET menuLine6
    call WriteString
    call Crlf
    jmp ShowRowEnd
ShowRow4:
    mov edx, OFFSET menuLine7
    call WriteString
    call Crlf
    jmp ShowRowEnd
ShowRow5:
    mov edx, OFFSET menuLine8
    call WriteString
    call Crlf

ShowRowEnd:
    mov edx, OFFSET menuLine9
    call WriteString
    call Crlf

    ; ------------ load base price from array ------------
    mov eax, selectedID
    dec eax                  ; make 0-based index
    lea esi, flightPrices
    mov eax, [esi + eax*4]   ; load price
    mov basePrice, eax

    ; ------------ ask for class ------------
GetClass:
    mov edx, OFFSET promptClass
    call WriteString
    call ReadInt            ; EAX = class choice
    cmp eax, 1
    je ClassEconomy
    cmp eax, 2
    je ClassBusiness
    mov edx, OFFSET invalidMsg
    call WriteString
    call Crlf
    jmp GetClass

ClassEconomy:
    mov eax, basePrice
    mov classPrice, eax
    jmp AskInsurance

ClassBusiness:
    ; classPrice = basePrice * 1.4  ->  = (base * 14) / 10
    mov eax, basePrice
    mov ebx, 14
    mul ebx                 ; EDX:EAX = base * 14
    mov ebx, 10
    div ebx                 ; EAX = (base*14)/10
    mov classPrice, eax
    jmp AskInsurance

AskInsurance:
    mov edx, OFFSET promptIns
    call WriteString
    call ReadInt            ; EAX = 1 -> yes, 2 -> no
    cmp eax, 1
    je InsYes
    cmp eax, 2
    je InsNo
    mov edx, OFFSET invalidMsg
    call WriteString
    call Crlf
    jmp AskInsurance

InsYes:
    mov insPrice, 100
    jmp AfterInsurance

InsNo:
    mov insPrice, 0

AfterInsurance:
    ; Compute total price for one passenger
    mov eax, classPrice
    add eax, insPrice
    mov totalPrice, eax
    call PassengerInputModule
    jmp selectTicketEnd

selectTicketEnd:
    ret

selectTicket ENDP
;-----------------------------------------------------------
ComputeTotal PROC
;
; Computes total price and displays price breakdown
;-----------------------------------------------------------

; ------------ compute total price ------------
    mov eax, totalPrice
    mov ebx, pax
    mul ebx
    mov total, eax

; ----------- display breakdown -----------
    call Crlf
    mov edx, OFFSET msgBase
    call WriteString
    mov eax, basePrice
    call WriteFloat2Decimal
    call Crlf

    ; Display base price
    mov edx, OFFSET msgClass
    call WriteString
    mov eax, classPrice
    sub eax, basePrice        ; show adjustment compared to base
    call WriteFloat2Decimal
    call Crlf

    ; Display Insurance
    mov edx, OFFSET msgIns
    call WriteString
    mov eax, insPrice
    call WriteFloat2Decimal
    call Crlf

    ; Display separator
    mov edx, OFFSET msgSepLong2
    call WriteString
    call Crlf

    ; Display total per passenger
    mov edx, OFFSET msgTotal
    call WriteString
    mov eax, totalPrice
    call WriteFloat2Decimal
    call Crlf

    ; Display passenger count (Pax) with proper alignment
    mov edx, OFFSET msgPerPax   ; "Pax:             "
    call WriteString
    mov eax, pax
    call WriteDec
    call Crlf

    ; Check if user is member (user2) and apply discount
    cmp currentUser, 2
    jne NoDiscount
    
    ; Calculate discount amount (15% of total)
    mov eax, total
    mov ebx, 15
    mul ebx
    mov ebx, 100
    div ebx
    mov discountAmount, eax
    
    ; Display discount with minus sign
    mov edx, OFFSET msgDiscount
    call WriteString
    mov eax, discountAmount
    call WriteFloat2Decimal
    call Crlf
    
    ; Subtract discount from total
    mov eax, total
    sub eax, discountAmount
    mov total, eax

NoDiscount:
    ; Display long separator
    mov edx, OFFSET msgSepLong
    call WriteString
    call Crlf
    
    ; Display grand total
    mov edx, OFFSET msgGrandTotal
    call WriteString
    mov eax, total
    call WriteFloat2Decimal
    call Crlf

    ret
ComputeTotal ENDP

; ------------------------------------------------------------
; GUAN RONG - Passenger Information and Booking Summary Procedures
; ------------------------------------------------------------

;-----------------------------------------------------------
PassengerInputModule PROC
;
; Collects passenger information including names and passport numbers
;-----------------------------------------------------------

    call clrscr

; Get number of passengers
GetPaxCount:
    call Crlf
    mov edx, OFFSET paxTitle
    call WriteString
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
    
    ; Get passenger name with validation
GetName:
    mov edx, OFFSET promptName
    call WriteString
    mov eax, esi
    mov ebx, NAME_SIZE
    mul ebx
    mov edx, OFFSET passengerNames
    add edx, eax
    mov ecx, NAME_SIZE
    call ReadString
    
    ; Validate name (check if not empty and contains only letters/spaces)
    call ValidateName
    cmp eax, 0
    je GetName

    ; Get passport number with validation
GetPassport:
    mov edx, OFFSET promptPassport
    call WriteString
    mov eax, esi
    mov ebx, PASSPORT_SIZE
    mul ebx
    mov edx, OFFSET passports
    add edx, eax
    mov ecx, PASSPORT_SIZE
    call ReadString
    
    ; Validate passport (check if not empty and alphanumeric)
    call ValidatePassport
    cmp eax, 0
    je GetPassport
    
    call Crlf

    pop ecx   ; Restore loop counter
    inc esi

    loop PassengerLoop

    call SummaryModule

    ret
    
PassengerInputModule ENDP

;-----------------------------------------------------------
WriteFloat2Decimal PROC
;
; Displays an integer as money format with .00
; Input: EAX = integer value to display
;-----------------------------------------------------------
    call WriteDec
    mov edx, OFFSET dotStr
    call WriteString
    mov al, '0'
    call WriteChar
    call WriteChar
    ret
WriteFloat2Decimal ENDP

;-----------------------------------------------------------
SummaryModule PROC
;
; Displays booking summary and calculates total price with membership discounts
;-----------------------------------------------------------

    ; Display header
    call clrscr
    mov edx, OFFSET summaryTitle
    call WriteString

    call Crlf

    ; Display membership status message if member
    cmp currentUser, 1
    je RegularCustomer

    mov edx, OFFSET memberStatus
    call WriteString
    jmp CalculatePrice

RegularCustomer:
    mov edx, OFFSET normalStatus
    call WriteString

CalculatePrice:
    ; Calculate base total (price * passengers)
    mov eax, totalPrice
    mov ebx, pax
    mul ebx
    mov total, eax

    ; Display passenger details
DisplayPassengers:
    mov edx, OFFSET passengerHeader
    call WriteString
    call crlf

    mov ecx, pax
    mov esi, 0

DisplayLoop:
    push ecx

    ; Display name
    mov edx, OFFSET passengerLine
    call WriteString

    ; Calculate offset and display name
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
    call Crlf  ; Add extra line break between passengers

    pop ecx
    inc esi
    loop DisplayLoop

    jmp Done

Done:
    call ComputeTotal
    call payment
    ret

SummaryModule ENDP

;-----------------------------------------------------------
ValidateName PROC
;
; Validates passenger name (letters, spaces, and apostrophes only)
; Input: EDX = pointer to name string
; Output: EAX = 1 if valid, 0 if invalid
;-----------------------------------------------------------
    push esi
    push ebx
    
    mov esi, edx
    mov ebx, 0          ; Character count
    
CheckNameLoop:
    mov al, [esi]
    cmp al, 0           ; End of string?
    je CheckNameLength
    
    ; Check if character is valid (letter, space, or apostrophe)
    cmp al, ' '
    je ValidNameChar
    cmp al, 27h         ; Apostrophe
    je ValidNameChar
    cmp al, 'A'
    jb InvalidNameChar
    cmp al, 'Z'
    jbe ValidNameChar
    cmp al, 'a'
    jb InvalidNameChar
    cmp al, 'z'
    ja InvalidNameChar
    
ValidNameChar:
    inc ebx
    inc esi
    jmp CheckNameLoop
    
CheckNameLength:
    cmp ebx, 1          ; Must have at least 1 character
    jl InvalidNameChar
    cmp ebx, 45         ; Maximum reasonable name length
    jg InvalidNameChar
    
    mov eax, 1          ; Valid name
    jmp NameValidationEnd
    
InvalidNameChar:
    mov edx, OFFSET errNameMsg
    call WriteString
    call Crlf
    mov eax, 0          ; Invalid name
    
NameValidationEnd:
    pop ebx
    pop esi
    ret
ValidateName ENDP

;-----------------------------------------------------------
ValidatePassport PROC
;
; Validates passport number (6-15 alphanumeric characters)
; Input: EDX = pointer to passport string
; Output: EAX = 1 if valid, 0 if invalid
;-----------------------------------------------------------
    push esi
    push ebx
    
    mov esi, edx
    mov ebx, 0          ; Character count
    
CheckPassportLoop:
    mov al, [esi]
    cmp al, 0           ; End of string?
    je CheckPassportLength
    
    ; Check if character is numeric or uppercase letter only
    cmp al, '0'
    jb InvalidPassportChar
    cmp al, '9'
    jbe ValidPassportChar
    cmp al, 'A'
    jb InvalidPassportChar
    cmp al, 'Z'
    jbe ValidPassportChar
    jmp InvalidPassportChar
    
ValidPassportChar:
    inc ebx
    inc esi
    jmp CheckPassportLoop
    
CheckPassportLength:
    cmp ebx, 6          ; Minimum 6 characters
    jl InvalidPassportChar
    cmp ebx, 15         ; Maximum 15 characters
    jg InvalidPassportChar
    
    mov eax, 1          ; Valid passport
    jmp PassportValidationEnd
    
InvalidPassportChar:
    mov edx, OFFSET errPassportMsg
    call WriteString
    call Crlf
    mov eax, 0          ; Invalid passport
    
PassportValidationEnd:
    pop ebx
    pop esi
    ret
ValidatePassport ENDP

; ------------------------------------------------------------
; ADAM - Payment Processing and Transaction Procedures
; ------------------------------------------------------------

;-----------------------------------------------------------
ReadMoney PROC
;
; Reads monetary input from user and converts to integer value
;-----------------------------------------------------------

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
    movzx ebx, bl
    push ebx
    mov ebx, 10
    mul ebx
    pop ebx
    add eax, ebx
    inc esi
    jmp parse_int
int_done:
    mov paymentAmount, eax
    ret
invalid_input:
    mov paymentAmount, 0
    ret
ReadMoney ENDP

;-----------------------------------------------------------
WriteMoney PROC
;
; Prints a monetary value with .00 format
; Input: EAX = integer value to display
;-----------------------------------------------------------
    call WriteFloat2Decimal
    ret
WriteMoney ENDP

;-----------------------------------------------------------
payment PROC
;
; Handles payment processing, change calculation, and booking confirmation
;-----------------------------------------------------------
    call Crlf                          ; New line

mainLoop:
    mov edx, OFFSET promptPayment
    call WriteString                   ; Print payment method prompt
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
    mov eax, paymentAmount      ; paymentAmount = user input
    mov ebx, total              ; total = amount due (totalPrice * passengers)
    cmp eax, ebx
    jl not_enough_balance
    sub eax, ebx                ; paymentChange = paymentAmount - total
    mov paymentChange, eax
    mov edx, OFFSET promptChange
    call WriteString
    mov eax, paymentChange
    call WriteMoney
    call Crlf
    mov edx, OFFSET promptSuccess
    call WriteString
    call Crlf
    
    ; Save this booking to history
    call SaveBooking
    
    ; Ask if user wants to print ticket
    call PrintTicket
    
    jmp askAnother

not_enough_balance:
    mov edx, OFFSET promptNotEnough
    call WriteString
    call Crlf
    jmp getPayment

askAnother:
    call crlf
    mov edx, OFFSET promptAnother
    call WriteString
    call ReadInt
    mov bookAnother, al
    cmp al, 1
    je go_menu
    cmp al, 2
    je exitApp
    mov edx, OFFSET promptInvalid
    call WriteString
    call Crlf
    jmp askAnother

go_menu:
    call selectTicket
    jmp payment

exitApp:
    call crlf
    mov edx, OFFSET byeMessage
    call WriteString
    call crlf
    exit                      

payment ENDP

; ------------------------------------------------------------
; Booking History Procedures
; ------------------------------------------------------------

;-----------------------------------------------------------
SaveBooking PROC
;
; Saves current booking to history
;-----------------------------------------------------------
    ; Save flight ID
    mov ebx, bookingCount
    mov eax, selectedID
    mov bookingFlightIDs[ebx*4], eax
    
    ; Save total price
    mov eax, total
    mov bookingTotalPrices[ebx*4], eax
    
    ; Save passenger count
    mov eax, pax
    mov bookingPassengerCounts[ebx*4], eax
    
    ; Increment booking count
    inc bookingCount
    
SaveBooking ENDP

;-----------------------------------------------------------
DisplayBookingHistory PROC
;
; Displays all previous bookings for the current user
;-----------------------------------------------------------
    call Crlf
    mov edx, OFFSET historyTitle
    call WriteString
    
    ; Check if any bookings exist
    mov eax, bookingCount
    cmp eax, 0
    je NoBookings
    
    ; Display each booking
    mov ecx, bookingCount
    mov esi, 0
    
DisplayBookingLoop:
    push ecx
    
    ; Display booking number
    mov edx, OFFSET bookingEntryMsg
    call WriteString
    mov eax, esi
    inc eax
    call WriteDec
    
    ; Display flight ID and airline name
    mov edx, OFFSET flightMsg
    call WriteString
    mov eax, bookingFlightIDs[esi*4]
    call WriteDec
    mov al, ' '
    call WriteChar
    call WriteChar
    
    ; Display airline name based on flight ID
    mov eax, bookingFlightIDs[esi*4]
    call DisplayAirlineName
    
ContinueDisplay:
    
    ; Display total price
    mov edx, OFFSET priceMsg
    call WriteString
    mov eax, bookingTotalPrices[esi*4]
    call WriteFloat2Decimal
    
    ; Display passenger count
    mov edx, OFFSET paxMsg
    call WriteString
    mov eax, bookingPassengerCounts[esi*4]
    call WriteDec
    call Crlf
    call Crlf
    
    inc esi
    pop ecx
    loop DisplayBookingLoop
    
    jmp HistoryEnd
    
NoBookings:
    mov edx, OFFSET noBookingsMsg
    call WriteString
    
HistoryEnd:
    mov edx, OFFSET nextSessionMessage
    call WriteString
    call waitEnter
    ret
DisplayBookingHistory ENDP

;-----------------------------------------------------------
DisplayAirlineName PROC
;
; Displays airline name based on flight ID in EAX
;-----------------------------------------------------------
    cmp eax, 1
    je ShowAirline1
    cmp eax, 2
    je ShowAirline2
    cmp eax, 3
    je ShowAirline3
    cmp eax, 4
    je ShowAirline4
    jmp ShowAirline5
    
ShowAirline1:
    mov edx, OFFSET airline1
    call WriteString
    ret
ShowAirline2:
    mov edx, OFFSET airline2
    call WriteString
    ret
ShowAirline3:
    mov edx, OFFSET airline3
    call WriteString
    ret
ShowAirline4:
    mov edx, OFFSET airline4
    call WriteString
    ret
ShowAirline5:
    mov edx, OFFSET airline5
    call WriteString
    ret
DisplayAirlineName ENDP

; ------------------------------------------------------------
; Ticket Printing Procedures
; ------------------------------------------------------------

;-----------------------------------------------------------
PrintTicket PROC
;
; Asks user if they want to print ticket and displays formatted ticket
;-----------------------------------------------------------
    call Crlf
    mov edx, OFFSET printPrompt
    call WriteString
    call ReadInt
    
    cmp eax, 1
    je DisplayTicket
    cmp eax, 2
    je TicketEnd
    
    ; Invalid input
    mov edx, OFFSET promptInvalid
    call WriteString
    call Crlf
    jmp PrintTicket
    
DisplayTicket:
    call Crlf
    call DisplayFormattedTicket
    jmp TicketEnd

TicketEnd:
    ret
PrintTicket ENDP

;-----------------------------------------------------------
DisplayFormattedTicket PROC
;
; Displays a formatted airline ticket with all booking details
;-----------------------------------------------------------
    ; Display ticket header
    call clrscr
    mov edx, OFFSET ticketHeader1
    call WriteString
    call Crlf
    mov edx, OFFSET ticketHeader2
    call WriteString
    call Crlf
    mov edx, OFFSET ticketHeader3
    call WriteString
    call Crlf
    call Crlf
    
    ; Display booking reference (using booking count as reference number)
    mov edx, OFFSET ticketBookingRef
    call WriteString
    mov eax, bookingCount
    call WriteDec
    call Crlf
    
    ; Display booking date
    mov edx, OFFSET ticketDate
    call WriteString
    call Crlf
    call Crlf
    
    ; Display separator
    mov edx, OFFSET ticketSeparator
    call WriteString
    call Crlf
    
    ; Flight information section
    mov edx, OFFSET ticketFlightInfo
    call WriteString
    call Crlf
    mov edx, OFFSET ticketSeparator
    call WriteString
    call Crlf
    
    ; Display airline name
    mov edx, OFFSET ticketAirlineLabel
    call WriteString
    mov eax, selectedID
    call DisplayAirlineName
    call Crlf
    
    ; Display route information
    mov edx, OFFSET ticketRouteLabel
    call WriteString
    call DisplayRouteInfo
    call Crlf
    
    ; Display departure date
    mov edx, OFFSET ticketDateLabel
    call WriteString
    call DisplayDepartureDate
    call Crlf
    
    ; Display class
    mov edx, OFFSET ticketClassLabel
    call WriteString
    call DisplayClassInfo
    call Crlf
    
    ; Display insurance
    mov edx, OFFSET ticketInsuranceLabel
    call WriteString
    call DisplayInsuranceInfo
    call Crlf
    call Crlf
    
    ; Passenger information section
    mov edx, OFFSET ticketSeparator
    call WriteString
    call Crlf
    mov edx, OFFSET ticketPaxInfo
    call WriteString
    call Crlf
    mov edx, OFFSET ticketSeparator
    call WriteString
    call Crlf
    
    ; Display passenger count
    mov edx, OFFSET ticketPaxCount
    call WriteString
    mov eax, pax
    call WriteDec
    call Crlf
    call Crlf
    
    ; Display all passenger names
    call DisplayTicketPassengers
    call Crlf
    
    ; Payment information
    mov edx, OFFSET ticketSeparator
    call WriteString
    call Crlf
    mov edx, OFFSET ticketTotalLabel
    call WriteString
    mov eax, total
    call WriteFloat2Decimal
    call Crlf
    
    mov edx, OFFSET ticketPaymentLabel
    call WriteString
    call DisplayPaymentMethod
    call Crlf
    call Crlf
    
    ; Footer
    mov edx, OFFSET ticketHeader1
    call WriteString
    call Crlf
    mov edx, OFFSET ticketThankYou
    call WriteString
    call Crlf
    mov edx, OFFSET ticketContact
    call WriteString
    call Crlf
    mov edx, OFFSET ticketHeader1
    call WriteString
    call Crlf
    call Crlf
    
    ret
DisplayFormattedTicket ENDP

;-----------------------------------------------------------
DisplayRouteInfo PROC
;
; Displays departure and destination based on selected flight
;-----------------------------------------------------------
    ; Display departure location
    mov eax, selectedID
    dec eax                     ; Convert to 0-based index
    mov ebx, 13                 ; Each location string is 13 chars
    mul ebx
    mov edx, OFFSET departureLocations
    add edx, eax
    call WriteString
    
    mov al, ' '
    call WriteChar
    mov al, '-'
    call WriteChar
    mov al, '>'
    call WriteChar
    mov al, ' '
    call WriteChar
    
    ; Display destination location
    mov eax, selectedID
    dec eax                     ; Convert to 0-based index
    mov ebx, 10                 ; Each destination string is 10 chars
    mul ebx
    mov edx, OFFSET destinationLocations
    add edx, eax
    call WriteString
    
    ret
DisplayRouteInfo ENDP

;-----------------------------------------------------------
DisplayDepartureDate PROC
;
; Displays departure date based on selected flight
;-----------------------------------------------------------
    mov eax, selectedID
    dec eax                     ; Convert to 0-based index
    mov ebx, 11                 ; Each date string is 11 chars (10 + null)
    mul ebx
    mov edx, OFFSET departureDates
    add edx, eax
    call WriteString
    ret
DisplayDepartureDate ENDP

;-----------------------------------------------------------
DisplayClassInfo PROC
;
; Displays class information (Economy or Business)
;-----------------------------------------------------------
    mov eax, classPrice
    mov ebx, basePrice
    cmp eax, ebx
    je ShowEconomy
    
    ; Business class
    mov edx, OFFSET businessText
    call WriteString
    ret
    
ShowEconomy:
    mov edx, OFFSET economyText
    call WriteString
    ret
DisplayClassInfo ENDP

;-----------------------------------------------------------
DisplayInsuranceInfo PROC
;
; Displays insurance information (Yes or No)
;-----------------------------------------------------------
    cmp insPrice, 0
    je ShowNoInsurance
    
    ; Has insurance
    mov edx, OFFSET yesText
    call WriteString
    ret
    
ShowNoInsurance:
    mov edx, OFFSET noText
    call WriteString
    ret
DisplayInsuranceInfo ENDP

;-----------------------------------------------------------
DisplayPaymentMethod PROC
;
; Displays payment method used
;-----------------------------------------------------------
    cmp paymentMethod, 1
    je ShowCreditCard
    
    ; E-wallet
    mov edx, OFFSET ewalletText
    call WriteString
    ret
    
ShowCreditCard:
    mov edx, OFFSET creditCardText
    call WriteString
    ret
DisplayPaymentMethod ENDP

;-----------------------------------------------------------
DisplayTicketPassengers PROC
;
; Displays all passenger names on the ticket
;-----------------------------------------------------------
    mov ecx, pax
    mov esi, 0
    
TicketPaxLoop:
    push ecx
    
    ; Display passenger number
    mov eax, esi
    inc eax
    call WriteDec
    mov al, '.'
    call WriteChar
    mov al, ' '
    call WriteChar
    
    ; Display passenger name
    mov eax, esi
    mov ebx, NAME_SIZE
    mul ebx
    mov edx, OFFSET passengerNames
    add edx, eax
    call WriteString
    call Crlf
    
    pop ecx
    inc esi
    loop TicketPaxLoop
    
    ret
DisplayTicketPassengers ENDP

END main