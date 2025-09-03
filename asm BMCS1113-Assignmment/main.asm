<<<<<<< HEAD
=======

>>>>>>> f847de666df6eff416a46d5ea47e7b35f9790e41
INCLUDE Irvine32.inc

; ============================================================
; Data Section
; ============================================================
.data
; ADAM PART
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

  ; GUAN RONG PART
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
loginMessage         DB "Please enter your username: ",0
passwordMessage      DB "Please enter your password: ",0
invalidMessage       DB "Invalid choice! Press [ENTER] to try again.",0
wrongPwordMessage    DB "Wrong password. Press [ENTER] to try again.",0
wrongUsernameMessage DB "Invalid username. Press [ENTER] to try again.",0
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
menuLine4   DB "| [1] | SkyJet Airlines      | Kuala Lumpur   | Singapore      | 2025-08-15     |  One-way  |     N/A    |     525     |",0
menuLine5   DB "| [2] | Oceanic Air          | Penang         | Bangkok        | 2025-08-16     |  Two-way  | 2025-08-21 |     2700    |",0
menuLine6   DB "| [3] | CloudNine Airways    | Johor Bahru    | Hong Kong      | 2025-08-17     |  Two-way  | 2025-08-22 |     7500    |",0
menuLine7   DB "| [4] | Eastern Horizon Air  | Kota Kinabalu  | Manila         | 2025-08-18     |  One-way  |     N/A    |     3300    |",0
menuLine8   DB "| [5] | Jet2 Holiday         | Kuching        | Jakarta        | 2025-08-19     |  Two-way  | 2025-08-24 |     5400    |",0
menuLine9   DB "+-----+----------------------+----------------+----------------+----------------+-----------+------------+-------------+",0
menuLine10  DB "Select [0] to log out.",0
menuLine11  DB "Please select an option from the menu above.",0

; ============================================================
; Code Section
; ============================================================
.code
<<<<<<< HEAD

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
=======
; ADAM PART
;main PROC
;    ; Main booking/payment loop
;mainLoop:
;    ; --- Payment Module ---
;    mov edx, OFFSET promptPayment
;    call WriteString
;    call ReadInt
;    mov paymentMethod, al
;    cmp al, 1
;    je payment_ok
;    cmp al, 2
;    je payment_ok
;    ; Invalid input
;    mov edx, OFFSET promptInvalid
;    call WriteString
;    mov edx, OFFSET newline
;    call WriteString
;    jmp mainLoop
>>>>>>> f847de666df6eff416a46d5ea47e7b35f9790e41

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
=======

;main PROC
;    call CustomerIdModule
;    call PassengerInputModule
;    call SummaryModule
;    INVOKE ExitProcess, 0
;main ENDP

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
=======
; YANZHE PART
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



; ------------------------------------------------------------
; Program Entry Point
; ------------------------------------------------------------
main PROC
    call login         ; Start with login procedure
    exit               ; Exit program after login returns (should not happen)
main ENDP
<<<<<<< HEAD
END main
=======

; ------------------------------------------------------------
; Login Procedure
; Handles user authentication and loops until successful login
; ------------------------------------------------------------
login PROC
    call clrscr
    mov currentUser, 0 ; Reset current user

login_loop:
    call clrscr
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
    call clrscr
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
    je main_menu       ; If password correct, go to main menu

    ; If password is incorrect
    mov edx, OFFSET wrongPwordMessage
    call WriteString
    call crlf
    call waitEnter
    jmp login_loop     ; Retry login

user2_found:
    call clrscr
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
    je main_menu       ; If password correct, go to main menu

    ; If password is incorrect
    mov edx, OFFSET wrongPwordMessage
    call WriteString
    call crlf
    call waitEnter
    jmp login_loop     ; Retry login

login_end:
    ret
login ENDP

; ------------------------------------------------------------
; Main Menu Procedure
; Displays the menu and handles user selection
; ------------------------------------------------------------
main_menu PROC
    call clrscr

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
    ; Display all menu lines
    mov edx, OFFSET menuLine1
    call WriteString
    call crlf
    mov edx, OFFSET menuLine2
    call WriteString
    call crlf
    mov edx, OFFSET menuLine3
    call WriteString
    call crlf
    mov edx, OFFSET menuLine4
    call WriteString
    call crlf
    mov edx, OFFSET menuLine5
    call WriteString
    call crlf
    mov edx, OFFSET menuLine6
    call WriteString
    call crlf
    mov edx, OFFSET menuLine7
    call WriteString
    call crlf
    mov edx, OFFSET menuLine8
    call WriteString
    call crlf
    mov edx, OFFSET menuLine9
    call WriteString
    call crlf
    mov edx, OFFSET menuLine10
    call WriteString
    call crlf
    mov edx, OFFSET menuLine11
    call WriteString
    call crlf

    ; Read user option selection
    mov edx, OFFSET userInput
    mov ecx, SIZEOF userInput
    call ReadString

    ; Handle menu options
    INVOKE Str_compare, ADDR userInput, ADDR selection0
    je login            ; Log out and return to login

    INVOKE Str_compare, ADDR userInput, ADDR selection1
    je option1_selected

    INVOKE Str_compare, ADDR userInput, ADDR selection2
    je option2_selected

    INVOKE Str_compare, ADDR userInput, ADDR selection3
    je option3_selected

    INVOKE Str_compare, ADDR userInput, ADDR selection4
    je option4_selected

    INVOKE Str_compare, ADDR userInput, ADDR selection5
    je option5_selected

    ; If invalid option selected
    mov edx, OFFSET invalidMessage
    call WriteString
    call waitEnter
    jmp main_menu

option1_selected:
    mov ax, 525
    mov currentPrice, ax         ; Store price for option 1
    ; ADD FUNCTION TO HANDLE THE SELECTED OPTION HERE

option2_selected:
    mov ax, 2700
    mov currentPrice, ax         ; Store price for option 2
    ; ADD FUNCTION TO HANDLE THE SELECTED OPTION HERE

option3_selected:
    mov ax, 7500
    mov currentPrice, ax         ; Store price for option 3
    ; ADD FUNCTION TO HANDLE THE SELECTED OPTION HERE

option4_selected:
    mov ax, 3300
    mov currentPrice, ax         ; Store price for option 4
    ; ADD FUNCTION TO HANDLE THE SELECTED OPTION HERE

option5_selected:
    mov ax, 5400
    mov currentPrice, ax         ; Store price for option 5
    ; ADD FUNCTION TO HANDLE THE SELECTED OPTION HERE

    ; PRICES ARE STORED IN currentPrice VARIABLE FOR FURTHER CALCULATIONS

main_menu ENDP

; ------------------------------------------------------------
; Wait for Enter Key Procedure
; Waits until the user presses the Enter key
; ------------------------------------------------------------
waitEnter PROC
waitLoop:
    call ReadChar
    cmp al, 13                  ; 13 = ASCII code for Enter
    jne waitLoop
    ret
waitEnter ENDP

END main


>>>>>>> f847de666df6eff416a46d5ea47e7b35f9790e41
