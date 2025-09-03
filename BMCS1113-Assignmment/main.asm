; BookFlight_fixed_corrected.asm
; MASM 32-bit with Irvine32
TITLE BookFlight_fixed_corrected

.386
.model flat,stdcall
.stack 4096
option casemap:none

INCLUDE Irvine32.inc
includelib Irvine32.lib
includelib kernel32.lib

; ============================================================
; Data Section
; ============================================================
.data
; --- Menu Display Lines (unchanged) ---
menuLine1   DB "+-----+----------------------+----------------+----------------+----------------+-----------+------------+-------------+",0
menuLine2   DB "| ID  | Airline              | Departure      | Destination    | Departure Date | Trip Type | Return Date| Price (MYR) |",0
menuLine3   DB "+-----+----------------------+----------------+----------------+----------------+-----------+------------+-------------+",0
menuLine4   DB "| [1] | SkyJet Airlines      | Kuala Lumpur   | Singapore      | 2025-08-15     | One-way   | N/A        | 525         |",0
menuLine5   DB "| [2] | Oceanic Air          | Penang         | Bangkok        | 2025-08-16     | Two-way   | 2025-08-21 | 2700        |",0
menuLine6   DB "| [3] | CloudNine Airways    | Johor Bahru    | Hong Kong      | 2025-08-17     | Two-way   | 2025-08-22 | 7500        |",0
menuLine7   DB "| [4] | Eastern Horizon Air  | Kota Kinabalu  | Manila         | 2025-08-18     | One-way   | N/A        | 3300        |",0
menuLine8   DB "| [5] | Jet2 Holiday         | Kuching        | Jakarta        | 2025-08-19     | Two-way   | 2025-08-24 | 5400        |",0
menuLine9   DB "+-----+----------------------+----------------+----------------+----------------+-----------+------------+-------------+",0

; prices used for calculations (must match the table above)
flightPrices DWORD 525,2700,7500,3300,5400

; prompts and messages
promptFlight  BYTE "Enter Flight ID (1-5): ",0
promptClass   BYTE "Choose class: 1=Economy 2=Business : ",0
promptIns     BYTE "Add insurance? 1=Yes 2=No : ",0
invalidMsg    BYTE "Invalid input! Please try again.",0

msgBase       BYTE "Base Price: ",0
msgClass      BYTE "Class Adj: ",0
msgIns        BYTE "Insurance: ",0
msgSep        BYTE "-----------------------------",0
msgTotal      BYTE "Total: ",0

; temp/user variables
selectedID    DWORD ?
basePrice     DWORD ?
classPrice    DWORD ?
insPrice      DWORD ?
totalPrice    DWORD ?

.code

main PROC
    ; show menu
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

    ; -------- get flight id (with validation) --------
GetFlight:
    mov edx, OFFSET promptFlight
    call WriteString
    call ReadInt           ; EAX = user's input
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
    jmp ComputeTotal
InsNo:
    mov insPrice, 0

ComputeTotal:
    mov eax, classPrice
    add eax, insPrice
    mov totalPrice, eax

    ; ----------- display breakdown -----------
    call Crlf
    mov edx, OFFSET msgBase
    call WriteString
    mov eax, basePrice
    call WriteDec
    call Crlf

    mov edx, OFFSET msgClass
    call WriteString
    mov eax, classPrice
    sub eax, basePrice        ; show adjustment compared to base
    call WriteDec
    call Crlf

    mov edx, OFFSET msgIns
    call WriteString
    mov eax, insPrice
    call WriteDec
    call Crlf

    mov edx, OFFSET msgSep
    call WriteString
    call Crlf

    mov edx, OFFSET msgTotal
    call WriteString
    mov eax, totalPrice
    call WriteDec
    call Crlf

    ; exit
    invoke ExitProcess, 0
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

