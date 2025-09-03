login PROC
    mov edx, OFFSET loginMessage
    call WriteString
    call crlf
INCLUDE Irvine32.inc

    call ReadString



    call WriteString

    call WriteString


    ret
