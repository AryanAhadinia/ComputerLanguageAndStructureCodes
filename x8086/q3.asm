; Computer Language and Structure, HW3, Q3
; Aryan Ahadinia, 98103878
; Marked as final, Version 0

StSeg   Segment STACK 'STACK'
ns      DB 100H DUP (?)
StSeg   ENDS

DtSeg   Segment
inBuf   Label BYTE
bSize   DB 16
rSize   DB ?
inStr   DB 10H DUP (?)
prompt  DB 'Please enter your matrix. $' 
result  DB 'The determinant is equal to $'
DtSeg   ENDS

CDSeg   Segment
        ASSUME CS:CDSeg,DS:DtSeg,SS:StSeg
Start:  MOV     AX,DtSeg    ; set DS to point to the data segment
        MOV     DS,AX
 
        LEA     DX,prompt   ; load prompt message
        MOV     AH,9        ; set INT 21H code to print string
        INT     21H         ; call INT 21H
        CALL    pEndl       ; go to next line
                
        MOV     CX,2        ; set CX = 2 for two rows
loop1:  MOV     AX,CX       ; store CX in DX
       
        MOV     CX,2        ; set CX = 2 for two cells in each row
loop2:  PUSH    0           ; push 0 as place holder for return value of readI

        CALL    readI       ; call readI
        CALL    pSpace      ; call pSpace to go to next column
        LOOP    loop2       ; loop over cells
                     
        MOV     CX,AX       ; restore CX
        CALL    pEndl       ; call pEndl to go to next line
        LOOP    loop1       ; loop over rows
        
        ; all four cells of matrix is in stack reversly
        
        PUSH    BP          ; store BP
        MOV     BP,SP

        MOV     DX,[BP+2]   ; DX = matrix [1][1]
        MOV     AX,[BP+8]   ; AX = matrix [0][0]
        MUL     DX          ; DAX = AX * DX (result will be only in AX because of limits)
        MOV     BX,AX       ; store AX in BX
        
        MOV     DX,[BP+4]   ; DX = matrix [1][0]
        MOV     AX,[BP+6]   ; DX = matrix [0][1]
        MUL     DX          ; DAX = AX * DX (result will be only in AX because of limits)
        
        SUB     BX,AX       ; BX = BX - AX (the deteminane)
        
        POP     BP          ; restore BP
        POP     AX          ; clean up stack
        POP     AX
        POP     AX
        POP     AX      
        
        LEA     DX,result   ; load result message
        MOV     AH,9        ; set INT 21H code to print string
        INT     21H         ; call INT 21H
        
        PUSH    BX          ; push BX as arg of printI
        CALL    printI      ; call printI to print BX
        POP     BX          ; clean up stack

        MOV     AH,4CH      ; DOS: terminate program
        MOV     AL,0        ; return code will be 0
        INT     21H         ; terminate the program


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


; pSpace: a procedure to go to next column
; No stack instruction
pSpace  PROC    NEAR
        PUSHF               ; store registers
        PUSH    AX
        PUSH    DX
        MOV     AH,02H      ; set INT 21H code to print char 
        MOV     DL,09H      ; set '\n' to print
        INT     21H         ; call OS for interupption 
        POP     DX          ; restore registers
        POP     AX
        POPF         
        RET                 ; return to call point
pSpace  ENDP


; readI: to read an 16-bit signed integer from input
; It's nessary to reserve inBuf in DtSeg like below
;       inBuf   Label BYTE
;       bSize   DB 16
;       rSize   DB ?
;       inStr   DB 10H DUP (?) 
; Instruction for stack:
; PUSH  place holder for return value                
readI   PROC    NEAR 
        PUSHF               ; store registers in stack
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    BP
        MOV     BP,SP
          
        LEA     DX,inBuf    ; load effective address of buffer in DX
        MOV     AH,0AH      ; set INT 21H code for Buffered Keyboard Input (0AH)
        INT     21H         ; call OS for interupttion
        
        MOV     CX,0        ; set CX = 0
        MOV     CL,rSize    ; load input string real size in CL for loop counter
        LEA     BX,inStr    ; load address of string in BX
        
        MOV     AX,0        ; set AX = 0
        MOV     [BP+14],AX  ; set initial value of return arg to 0
        
        CMP     CX,0        ; compare CX with zero
        JNE     pSign       ; jump if string length != 0
        RET                 ; return if string length == 0 
           
pSign:  MOV     AL,2BH      ; set AL = ASCII "+"
        SUB     AL,[BX]     ; compare first char with "+"
        JNZ     nSign       ; continue if first char is equal to "+"
        INC     BX          ; BX to next char
        DEC     CX          ; c--
        PUSH    0           ; push 0 in stack as positive sign
        JMP     condEnd     ; jump to end of the condition block
nSign:  MOV     AL,2DH      ; set AL = ASCII "-"
        SUB     AL,[BX]     ; compare first char with "-"
        JNZ     noSign      ; continue if first char is equal to "-"
        INC     BX          ; BX to next char
        DEC     CX          ; c--
        PUSH    1           ; push 1 in stack as negative sign
        JMP     condEnd     ; jump to end of the condition block
noSign: PUSH    0           ; push 0 in stack as positive sign
condEnd:NOP                 ; no operation, just for readability
              
dLoop:  MOV     AX,0        ; set AX = 0
        MOV     AL,[BX]     ; load char in loop
        INC     BX          ; BX to next
        AND     AL,0FH      ; Drop 4 higher bits of AL to convert ASCII to numeric value
        PUSH    AX          ; Push numeric value in stack
        MOV     DX,0AH      ; DX = 10
        MOV     AX,[BP+14]  ; set DX = return arg temp value
        MUL     DX          ; AX = AX * 10
        POP     DX          ; POP the char numeric value in DX
        ADD     AX,DX       ; AX = AX + DX (number * 10 + numericVal)
        MOV     [BP+14],AX  ; set return arg temp value = DX
        LOOP    dLoop       ; loop over string
        
        POP     AX          ; pop sign
        CMP     AX,0        ; compare sign with zero
        JE      notNegReadI ; jump if sign is 0
        MOV     AX,[BP+14]  ; set AX = return arg temp value
        MOV     BX,-1       ; set BX = -1
        MUL     BX          ; AX *= -1
        MOV     [BP+14],AX  ; set return arg temp value = AX        
notNegReadI:    NOP         ; no operation, just for readability
        
        POP     BP          ; restore registers from stack
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        POPF
        RET                 ; return to call point
readI   ENDP


; printI: a subroutine to print an 16-bit signed integer
; Instruction for stack:
; PUSH number you want to print in console            
printI  PROC    NEAR
        PUSHF               ; store registers in stack
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    BP   
        MOV     BP,SP
         
        MOV     AX,[BP+14]  ; load arg in AX
        
        CMP     AX,0        ; compare arg with AX to print "-" if required
        JGE     signBE      ; jump to avoid print "-" if AX >= 0
        MOV     BX,-1       ; load -1 in BX
        MUL     BX          ; AX *= -1 if it's negative
        PUSH    AX          ; store AX
        MOV     DL,2DH      ; load ASCII of "-" in DL
        MOV     AH,02H      ; set INT 21H code to print char
        INT     21H         ; call OS for interupption 
        POP     AX          ; restore AX
        
signBE: MOV     CX,0        ; set CX = 0 as digit counter
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
printI  ENDP

CDSeg   ENDS
END Start
        