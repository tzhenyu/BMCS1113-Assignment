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
main PROC
    ; Main booking/payment loop
mainLoop:
    ; --- Payment Module ---
    mov edx, OFFSET promptPayment
    call WriteString
    call ReadInt
    mov paymentMethod, al
    cmp al, 1
    je payment_ok
    cmp al, 2
    je payment_ok
    ; Invalid input
    mov edx, OFFSET promptInvalid
    call WriteString
    mov edx, OFFSET newline
    call WriteString
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