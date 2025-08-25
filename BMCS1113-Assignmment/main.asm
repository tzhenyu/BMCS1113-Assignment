INCLUDE Irvine32.inc

; ============================================================
; Data Section
; ============================================================
.data

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

