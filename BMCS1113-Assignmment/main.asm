INCLUDE Irvine32.inc

.data
user1name DB "12345",0 ; no membership privilege
user1pw   DB "8888", 0

user2name DB "67890", 0 ; membership privilege
user2pw   DB "9999", 0

loginMessage DB "Please enter your username: ", 0
passwordMessage DB "Please enter your password: ", 0

wrongPwordMessage DB "Wrong password. Please try again.", 0
wrongUsernameMessage DB "Invalid username. Please try again.", 0

user1found DB "Hi, User 1. No membership privilege.", 0
user2found DB "Hi, User 2. Have membership privilege.", 0

main_menuMessage DB "Welcome to the main menu!", 0

userInput DB 50 DUP(0)     ; buffer for up to 49 chars + null terminator
inputLen  DWORD ?          ; will store number of characters entered

.code
main PROC
    call login
    exit
main ENDP

login PROC
login_loop:
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
    jmp login_loop

user1_found:
    ; Code for user1 (no membership privilege)
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
    jmp login_loop

    jmp login_end

user2_found:
    ; Code for user1 (no membership privilege)
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

    ; If neither matched
    mov edx, OFFSET wrongPwordMessage
    call WriteString
    call crlf
    jmp login_loop

    jmp login_end

login_end:
    ret                          ; return from login procedure

login ENDP

main_menu PROC
    ; Code for main menu after successful login
    mov edx, OFFSET main_menuMessage
    call WriteString
    ret
main_menu ENDP

END main
