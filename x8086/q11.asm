; Computer Language and Structure, HW3, Q11
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
nPmt    DB 'Please enter n: $'
rPmt    DB 'Please enter r: $'
result  DB 'The result is equal to $'
DtSeg   ENDS

CDSeg   Segment
        ASSUME CS:CDSeg,DS:DtSeg,SS:StSeg
Start:
        MOV     AX,DtSeg    ; set DS to point to the data segment
        MOV     DS,AX
        
        PUSH    0           ; push place holder for return value of C
        PUSH    0           ; push place holder for readI (n)
        LEA     DX,nPmt     ; load prompt message for n in DX
        MOV     AH,9        ; set INT 21H code to print string
        INT     21H         ; call INT 21H
        CALL    readI       ; call readI
        CALL    pEndl       ; call pEndl to go to next line
        PUSH    0           ; push place holder for readI (r) 
        LEA     DX,rPmt     ; load prompt message for r in DX
        MOV     AH,9        ; set INT 21H code to print string
        INT     21H         ; call INT 21H
        CALL    readI       ; call readI
        CALL    pEndl       ; call pEndl to go to next line
        CALL    C           ; call C
        POP     AX          ; clean up stack
        POP     AX
        LEA     DX,result   ; load result message for n in DX
        MOV     AH,9        ; set INT 21H code to print string
        INT     21H         ; call INT 21H        
        CALL    printUI     ; print result of C unsigned
        POP     AX          ; clean up stack
        
        MOV     AH,4CH      ; DOS: terminate program
        MOV     AL,0        ; return code will be 0
        INT     21H         ; terminate the program
 
       
; C: a subroutine to recursively calculate nCr
; Instruction of stack:
; PUSH place holder for return value
; PUSH n
; PUSH r
C       PROC    NEAR
        PUSHF               ; store registers
        PUSH    AX
        PUSH    DX
        PUSH    BP
        MOV     BP,SP
        
        MOV     AX,1        ; set AX = 1
        MOV     [BP+14],AX  ; set place holder of result equal to 1
        
        MOV     AX,[BP+12]  ; load n in AX
        MOV     DX,[BP+10]  ; load r in DX
        
        CMP     AX,DX       ; compare n and r
        JE      retSg       ; jump to return segment if n == r
        CMP     DX,0        ; compare r and 0
        JE      retSg       ; jump to return segment if r == 0
        
        SUB     AX,1        ; AX = n - 1
        
        PUSH    0           ; push 0 as place holder of recursion result
        PUSH    AX          ; push AX as n
        PUSH    DX          ; push DX as r
        CALL    C           ; call C (n-1, r)
        POP     DX          ; clean up stack
        POP     AX
        
        SUB     DX,1
        
        PUSH    0           ; push 0 as place holder of recursion result
        PUSH    AX          ; push AX as n
        PUSH    DX          ; push DX as r
        CALL    C           ; call C (n-1, r-1)
        POP     DX          ; clean up stack
        POP     AX
        
        POP     AX          ; AX = C (n-1, r-1)
        POP     DX          ; DX = C (n-1, r)
        ADD     AX,DX       ; AX = C (n-1, r) + C (n-1, r-1)
        
        MOV     [BP+14],AX  ; result = AX
        
retSg:  POP     BP          ; restore registers
        POP     DX
        POP     AX
        POPF
        RET
C       ENDP


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
        