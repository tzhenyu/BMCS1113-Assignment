INCLUDE Irvine32.inc

.data

currentUser BYTE 0 ; to track current user
currentPrice WORD 0; to track current price
currentTripType BYTE 0 ; to track current trip type
currentReturnDate BYTE 0 ; to track current return date
currentDepartureDate BYTE 0 ; to track current departure date
currentAirline BYTE 0 ; to track current airline
currentDestination BYTE 0 ; to track current destination
currentDeparture BYTE 0 ; to track current departure

selection1 BYTE "1",0
selection2 BYTE "2",0
selection3 BYTE "3",0
selection4 BYTE "4",0
selection5 BYTE "5",0
selection0 BYTE "0",0


user1name DB "12345",0 ; no membership privilege
user1pw   DB "8888", 0

user2name DB "67890", 0 ; membership privilege
user2pw   DB "9999", 0

loginMessage DB "Please enter your username: ", 0
passwordMessage DB "Please enter your password: ", 0

invalidMessage DB "Invalid choice! Press [ENTER] to try again.",0
wrongPwordMessage DB "Wrong password. Press [ENTER] to try again.", 0
wrongUsernameMessage DB "Invalid username. Press [ENTER] to try again.", 0

user1found DB "Hi, User 1. No membership privilege.", 0
user2found DB "Hi, User 2. Have membership privilege.", 0

greetUser1 DB "Hi, user 1!", 0
greetUser2 DB "Hi, user 2!", 0

userInput DB 50 DUP(0)     ; buffer for up to 49 chars + null terminator

menuLine1 DB "+-----+----------------------+----------------+----------------+----------------+-----------+------------+-------------+", 0
menuLine2 DB "| ID  | Airline              | Departure      | Destination    | Departure Date | Trip Type | Return Date| Price (MYR) |", 0
menuLine3 DB "+-----+----------------------+----------------+----------------+----------------+-----------+------------+-------------+", 0
menuLine4 DB "| [1] | SkyJet Airlines      | Kuala Lumpur   | Singapore      | 2025-08-15     |  One-way  |     N/A    |     525     |", 0
menuLine5 DB "| [2] | Oceanic Air          | Penang         | Bangkok        | 2025-08-16     |  Two-way  | 2025-08-21 |     2700    |", 0
menuLine6 DB "| [3] | CloudNine Airways    | Johor Bahru    | Hong Kong      | 2025-08-17     |  Two-way  | 2025-08-22 |     7500    |", 0
menuLine7 DB "| [4] | Eastern Horizon Air  | Kota Kinabalu  | Manila         | 2025-08-18     |  One-way  |     N/A    |     3300    |", 0
menuLine8 DB "| [5] | Jet2 Holiday         | Kuching        | Jakarta        | 2025-08-19     |  Two-way  | 2025-08-24 |     5400    |", 0
menuLine9 DB "+-----+----------------------+----------------+----------------+----------------+-----------+------------+-------------+", 0
menuLine10 DB "Select [0] to log out.", 0
menuLine11 DB "Please select an option from the menu above.", 0

.code
main PROC
    call login
    exit
main ENDP

login PROC
    call clrscr                 ; Clear the screen
    mov currentUser, 0          ; Reset current user to 0 (not logged in)
   
    ; Display login message
    login_loop:
    call clrscr                 ; Clear the screen
    mov edx, OFFSET loginMessage  ; EDX points to the string
    call WriteString              ; Display the string
    call crlf                     ; next line

    ; Read string from user
    mov edx, OFFSET userInput     ; buffer address
    mov ecx, SIZEOF userInput     ; max chars allowed
    call ReadString               ; reads into userInput, stores length in EAX

    ; Compare userInput to user1name
    INVOKE Str_compare, ADDR userInput, ADDR user1name
    je  user1_found

    ; Compare userInput to user2name
    INVOKE Str_compare, ADDR userInput, ADDR user2name
    je  user2_found

    ; If neither matched
    mov edx, OFFSET wrongUsernameMessage
    call WriteString
    call crlf
    call waitEnter
    jmp login_loop

user1_found:
    call clrscr                 ; Clear the screen
    ; Code for user1 (no membership privilege)
    mov currentUser, 1           ; Set current user to user1
    mov edx, OFFSET user1found
    call WriteString
    call crlf
    mov edx, OFFSET passwordMessage
    call WriteString             
    call crlf

    ; Read password
    mov edx, OFFSET userInput     ; buffer address
    mov ecx, SIZEOF userInput     ; max chars allowed
    call ReadString               ; reads into userInput, stores length in EAX
    INVOKE Str_compare, ADDR userInput, ADDR user1pw
    je main_menu

    ; If neither matched
    mov edx, OFFSET wrongPwordMessage
    call WriteString
    call crlf
    call waitEnter
    jmp login_loop


user2_found:
    call clrscr                 ; Clear the screen
    ; Code for user1 (no membership privilege)
    mov currentUser, 2
    mov edx, OFFSET user2found
    call WriteString
    call crlf
    mov edx, OFFSET passwordMessage
    call WriteString             
    call crlf

    ; Read password
    mov edx, OFFSET userInput     ; buffer address
    mov ecx, SIZEOF userInput     ; max chars allowed
    call ReadString               ; reads into userInput, stores length in EAX
    INVOKE Str_compare, ADDR userInput, ADDR user2pw
    je main_menu

    ; If password wrong
    mov edx, OFFSET wrongPwordMessage
    call WriteString
    call crlf
    call waitEnter
    jmp login_loop

login_end:
    ret                          ; return from login procedure

login ENDP

main_menu PROC
    ; Display the main menu
    call clrscr

    ; Display personalized greeting
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

    ; Read option from user
    mov edx, OFFSET userInput     ; buffer address
    mov ecx, SIZEOF userInput     ; max chars allowed
    call ReadString               ; reads into userInput, stores length in EAX



    ;option 0 selected
    INVOKE Str_compare, ADDR userInput, ADDR selection0
    je login

    ;option 1 selected
    INVOKE Str_compare, ADDR userInput, ADDR selection1
    je option1_selected

    ;option 2 selected
    INVOKE Str_compare, ADDR userInput, ADDR selection2
    je option2_selected

    ;option 3 selected
    INVOKE Str_compare, ADDR userInput, ADDR selection3
    je option3_selected

    ;option 4 selected
    INVOKE Str_compare, ADDR userInput, ADDR selection4
    je option4_selected

    ;option 5 selected
    INVOKE Str_compare, ADDR userInput, ADDR selection5
    je option5_selected

    ; If invalid option selected
    mov edx, OFFSET invalidMessage
    call WriteString
    call waitEnter
    jmp main_menu

    option1_selected:
    MOV ax, 525;
    MOV currentPrice, ax;
    ; ADD FUNCTION TO HANDLE THE SELECTED OPTION HERE

    option2_selected:
    MOV ax, 2700;
    MOV currentPrice, ax;
    ; ADD FUNCTION TO HANDLE THE SELECTED OPTION HERE

    option3_selected:
    MOV ax, 7500;
    MOV currentPrice, ax;
    ; ADD FUNCTION TO HANDLE THE SELECTED OPTION HERE

    option4_selected:
    MOV ax, 3300;
    MOV currentPrice, ax;
    ; ADD FUNCTION TO HANDLE THE SELECTED OPTION HERE

    option5_selected:
    MOV ax, 5400;
    MOV currentPrice, ax;
    ; ADD FUNCTION TO HANDLE THE SELECTED OPTION HERE

    ; PRICES ARE STORED IN currentPrice VARIABLE FOR FURTHER CALCULATIONS





main_menu ENDP

waitEnter PROC
waitLoop:
    call ReadChar        ; Read a single character from keyboard
    cmp al, 13           ; 13 = ASCII for Enter
    jne waitLoop        ; If not Enter, loop again
    ret
waitEnter ENDP

END main
