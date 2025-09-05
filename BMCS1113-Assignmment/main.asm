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
currentPrice         WORD 0      ; Stores the price of the selected trip
currentTripType      BYTE 0      ; Stores the type of trip (not used yet)
currentReturnDate    BYTE 0      ; Stores the return date (not used yet)
currentDepartureDate BYTE 0      ; Stores the departure date (not used yet)
currentAirline       BYTE 0      ; Stores the selected airline (not used yet)
currentDestination   BYTE 0      ; Stores the selected destination (not used yet)
currentDeparture     BYTE 0      ; Stores the selected departure location (not used yet)

; --- Menu Selections ---
selection0 BYTE "0",0           ; Option to log out
selection1 BYTE "1",0           ; Option 1
selection2 BYTE "2",0           ; Option 2
selection3 BYTE "3",0           ; Option 3
selection4 BYTE "4",0           ; Option 4
selection5 BYTE "5",0           ; Option 5

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
menuLine10  DB "Select [0] to log out.",0

; ------------------------------------------------------------
; YAN ZHE - Flight Selection and Price Calculation Module
; ------------------------------------------------------------
; prices used for calculations (must match the table above)
flightPrices DWORD 525,2700,7500,3300,5400

; prompts and messages
promptFlight  BYTE "Choose your option [0-5]: ",0
promptClass   BYTE "Choose class: [1] Economy [2] Business : ",0
promptIns     BYTE "Add insurance? [1] Yes [2] No : ",0
invalidMsg    BYTE "Invalid input! Please try again.",0

msgBase       BYTE "Base Price: RM",0
msgClass      BYTE " Class Adj: RM",0
msgIns        BYTE " Insurance: RM",0
msgSep        BYTE "---------------------",0
msgTotal      BYTE "     Total: RM",0

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
CUSTOMER_ID_SIZE = 10

; Module 5 Data
promptPax      BYTE "Number of passengers [1-5]: ", 0
promptName     BYTE "Passenger name: ", 0
promptPassport BYTE "Passport number: ", 0
promptCustomer BYTE "Customer ID (C12345 format): ", 0
errPaxMsg      BYTE "Invalid input. Please enter [1-5]: ", 0

; Passenger Data
pax DWORD ?
customerId BYTE CUSTOMER_ID_SIZE DUP(?)
passengerNames BYTE MAX_PASSENGERS DUP(NAME_SIZE DUP(?))
passports BYTE MAX_PASSENGERS DUP(PASSPORT_SIZE DUP(?))
; isMember DWORD 0  ; 0 = not member, 1 = member

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
discount REAL8 0.10
total DWORD ?
discountedTotal DWORD ?

; ------------------------------------------------------------
; ADAM - Payment Processing and Transaction Module
; ------------------------------------------------------------
; Payment and booking variables
paymentMethod BYTE ? ; 1=Credit Card, 2=E-wallet
bookAnother BYTE ?   ; 1=Yes, 0=No
promptPayment BYTE "Select payment method: [1] Credit Card  [2] E-wallet | Your Choice: ",0
promptSuccess BYTE "Payment successful. Flight booked!",0
promptAnother BYTE "Book another flight? 1=Yes 2=No : ",0
promptInvalid BYTE "Invalid input. Try again.",0
promptPay BYTE "Pay Amount: RM",0
promptChange BYTE "Your change is: RM",0
promptNotEnough BYTE "Not enough balance. Please check again",0
inputStr BYTE 32 DUP(0)
totalBill DWORD 3500 ; Example total bill amount
paymentAmount DWORD ?
change DWORD ?



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
    cmp eax, 1
    jl InvalidFlight
    cmp eax, 5
    jg InvalidFlight
    mov selectedID, eax
    jmp AfterFlight

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
    ;call passengerInputModule
    jmp AskInsurance

InsYes:
    mov insPrice, 100
    call PassengerInputModule
    jmp selectTicketEnd

InsNo:
    mov insPrice, 0
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
    mov eax, classPrice
    add eax, insPrice
    mov totalPrice, eax

; ----------- display breakdown -----------
    call Crlf
    mov edx, OFFSET msgBase
    call WriteString
    mov eax, basePrice
    call WriteIntegerAsMoney
    call Crlf

    mov edx, OFFSET msgClass
    call WriteString
    mov eax, classPrice
    sub eax, basePrice        ; show adjustment compared to base
    call WriteIntegerAsMoney
    call Crlf

    mov edx, OFFSET msgIns
    call WriteString
    mov eax, insPrice
    call WriteIntegerAsMoney
    call Crlf

    mov edx, OFFSET msgSep
    call WriteString
    call Crlf

    mov edx, OFFSET msgTotal
    call WriteString
    mov eax, totalPrice
    call WriteIntegerAsMoney
    call Crlf

    ;call Crlf
    ;mov edx, OFFSET nextSessionMessage
    ;call WriteString
    ;call waitEnter
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
    ;call clrscr
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

    mov edx, OFFSET nextSessionMessage
    call writeString
    call waitEnter
    ;call clrscr

    pop ecx   ; Restore loop counter
    inc esi

    loop PassengerLoop

    call SummaryModule
    
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
WriteIntegerAsMoney PROC
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
WriteIntegerAsMoney ENDP

;-----------------------------------------------------------
SummaryModule PROC
;
; Displays booking summary and calculates total price with membership discounts
;-----------------------------------------------------------
    ; Display header
    call clrscr
    mov edx, OFFSET summaryTitle
    call WriteString


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

    ; Apply discount if member
    cmp currentUser, 2

    ;fld total
    ;fld discount
    ;fmul
    ;fld total
    ;fsub
    ;fstp discountedTotal


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
    call Crlf  ; Add extra line break between passengers

    pop ecx
    inc esi
    loop DisplayLoop

    ; Display separator
    ;mov edx, OFFSET separatorLine
    ;call WriteString

    ; Display pricing information
    ;mov edx, OFFSET priceLabel
    ;call WriteString

    ; Display appropriate total
    cmp currentUser, 1
    jne ShowRegularPrice

    ; Show discounted price
    ;fld discountedTotal
    ;call WriteFloat2Decimal
    ;call Crlf
    jmp Done

ShowRegularPrice:
    mov eax, total
    call WriteIntegerAsMoney
    call Crlf

Done:
    ; Display final separator
    ;mov edx, OFFSET separatorLine
    ;call WriteString
    ;mov edx, OFFSET nextSessionMessage
    ;call WriteString
    ;call waitEnter
    call computeTotal
    call payment
    ret

SummaryModule ENDP

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
    call WriteIntegerAsMoney
    ret
WriteMoney ENDP

;-----------------------------------------------------------
payment PROC
;
; Handles payment processing, change calculation, and booking confirmation
;-----------------------------------------------------------
    ;call clrscr                        ; Clear the screen every time you show the payment screen
    ;mov edx, OFFSET msgTotal
    ;call WriteString                   ; Print "Total: "
    ;mov eax, totalPrice
    ;call WriteMoney                    ; Print as decimal (e.g., 3880.00)
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
    mov ebx, totalPrice         ; totalPrice = amount due
    cmp eax, ebx
    jl not_enough_balance
    sub eax, ebx                ; change = paymentAmount - totalPrice
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

END main