; Computer Language and Structure, HW3, Q10
; Aryan Ahadinia, 98103878
; Marked as final, Version 0

StSeg   Segment STACK 'STACK'
ns      DB 100H DUP (?)
StSeg   ENDS

DtSeg   Segment
inBuf   Label BYTE
bSize   DB 16
rSize   DB ?
inStr   DB 100H DUP (?)
prompt  DB 'Please enter your string: $'
result  DB 'the result is $'
DtSeg   ENDS

CDSeg   Segment
        ASSUME CS:CDSeg,DS:DtSeg,SS:StSeg
Start:
        MOV     AX,DtSeg    ; set DS to point to the data segment
        MOV     DS,AX
        
        LEA     DX,prompt   ; load address of promp message in DX
        MOV     AH,9        ; set INT 21H code to print string
        INT     21H         ; call INT 21H
        
        MOV     AH,0AH      ; set INT 21H code to read string
        LEA     DX,inBuf    ; set DX = address if inBuf
        INT     21H         ; call INT 21H
        
        CALL    pEndl       ; go to next line
        
        LEA     DX,result   ; load address of result message in DX
        MOV     AH,9        ; set INT 21H code to print string
        INT     21H         ; call INT 21H
        
        LEA     AX,inStr    ; load address of inStr in AX
        
        PUSH    0           ; push 0 as place holder for result of second call of devide
        PUSH    0           ; push 0 as place holder for result of second call of devide
        PUSH    0           ; push 0 as place holder for result of first call of devide
        PUSH    0           ; push 0 as place holder for result of first call of devide
        PUSH    AX          ; push AX as arg for devide
        CALL    devide      ; call devide
        POP     AX          ; clean up stack
        POP     DX          ; store first number in DX
        CALL    devide      ; call devide (arg will be in stack)
        POP     AX          ; clean up stack
        POP     AX          ; store second number in AX
        
        MUL     DX          ; (D)AX = AX * DX
        
        PUSH    AX          ; push AX as arg for printUI in stack
        CALL    printUI     ; call printUI
          
        POP     AX          ; clean up stack
        POP     AX
                          
        MOV     AH,4CH      ; DOS: terminate program
        MOV     AL,0        ; return code will be 0
        INT     21H         ; terminate the program

        
; devide: s subroutine to determine a number from a string
; Instruction for stack
; PUSH 0 as place holder for address of start point of the rest of the string
; PUSH 0 as place holder for the number that is in the string
; PUSH [string]
devide  PROC    NEAR
        PUSHF               ; store registers in stack
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    BP
        MOV     BP,SP
        
        MOV     BX,[BP+14]  ; load address of string in CX
        DEC     BX          ; BX -= 1, will +1 in iteration start
        
        MOV     DX,0        ; DX = 0
        MOV     AX,0        ; AX = 0
        
        MOV     CX,0        ; CX = 0
        
trimL:  INC     BX          ; BX += 1
        MOV     CL,[BX]     ; Load BX'th char of string
        CMP     CL,24H      ; compare loaded char with '$' ASCII code
        JE      retSg       ; jump to return segment if loaded char is equal to '$'
        CMP     CL,30H      ; compare loaded char with '0' ASCII code
        JL      trimL       ; continue iteration if loaded char ASCII code if less than '0' ASCII code (the char in non-numberic)
        CMP     CL,39H      ; compare loaded char with '9' ASCII code
        JG      trimL       ; continue iteration if loaded char ASCII code if greater than '9' ASCII code (the char in non-numberic)
        
detL:   MOV     CL,[BX]     ; Load BX'th char of string
        CMP     CL,24H      ; compare loaded char with '$' ASCII code
        JE      retSg       ; jump to return segment if loaded char is equal to '$'
        CMP     CL,30H      ; compare loaded char with '0' ASCII code
        JL      detLE       ; end iteration if loaded char is non-numeric
        CMP     CL,39H      ; compare loaded char with '9' ASCII code
        JG      detLE       ; end iteration if loaded char is non-numeric
        AND     CL,0FH      ; convert ASCII code of digit to number
        MOV     DX,10       ; load 10 in DX
        MUL     DX          ; DAX = AX * 10
        ADD     AX,CX       ; AX += CX (CH is equal to 0)
        INC     BX          ; BX += 1
        JMP     detL        ; go back to loop condition checking
detLE:
        
retSg:  MOV     [BP+18],BX  ; store BX in place holder
        MOV     [BP+16],AX  ; store AX in place holder
        POP     BP          ; restore registers from stack
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        POPF
        RET                 ; back to call point
devide  ENDP


; pEndl: a procedure to go ot next line
; No stack instruction
pEndl   PROC    NEAR
        PUSHF               ; store registers
        PUSH    AX
        PUSH    DX
        MOV     AH,02H      ; set INT 21H code to print char 
        MOV     DL,0AH      ; set '\n' to print
        INT     21H         ; call OS for interupption 
        MOV     DL,0DH      ; set 'carriage return' to print
        INT     21H         ; call OS for interupption
        POP     DX          ; restore registers
        POP     AX
        POPF         
        RET                 ; return to call point
pEndl   ENDP


; printUI: a subroutine to print an 16-bit unsigned integer
; Instruction for stack:
; PUSH number you want to print in console            
printUI PROC    NEAR
        PUSHF               ; store registers in stack
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    BP   
        MOV     BP,SP
         
        MOV     AX,[BP+14]  ; load arg in AX
        
        MOV     CX,0        ; set CX = 0 as digit counter
        MOV     BX,10       ; set BX = 10 for loop-wide use

                            ; loop over number and convert each digit to ASCII code and push in stack to print reverse
dCalL:  MOV     DX,0        ; set DX = 0 for 32/16 division        
        DIV     BX          ; devide DAX by 10
        OR      DX,30H      ; convert reminder to ASCII code
        PUSH    DX          ; push lsd in stack
        INC     CX          ; increament number of digits
        CMP     AX,0        ; compare result with zero
        JNE     dCalL       ; end loop if result is zero

        MOV     AH,02H      ; set INT 21H code to print car for loop wide use

dPrL:   POP     DX          ; pop msd from stack, DH is 00H 
        INT     21H         ; call OS for interupption
        LOOP    dPrL        ; loop over CX (digit counts)

        POP     BP          ; restore registers
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        POPF
        RET                 ; return to call point
printUI ENDP

CDSeg   ENDS
END Start
        