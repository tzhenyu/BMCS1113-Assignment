login PROC
    mov edx, OFFSET loginMessage
    call WriteString
    call crlf

    ; Read string from user
    mov edx, OFFSET userInput
    mov ecx, SIZEOF userInput
    call ReadString

    ; Compare userInput to user1name
    INVOKE Str_compare, ADDR userInput, ADDR user1name
    je  user1_found

    ; Compare userInput to user2name
    INVOKE Str_compare, ADDR userInput, ADDR user2name
    je  user2_found

    ; If neither matched
    mov edx, OFFSET wrongPwordMessage
    call WriteString
    jmp login_end

user1_found:
    mov edx, OFFSET user1found
    call WriteString
    jmp login_end

user2_found:
    ; Code for user2 (membership privilege)
    jmp login_end

login_end:
    ret
login ENDP