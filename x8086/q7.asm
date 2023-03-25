; Computer Language and Structure, HW3, Q7
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
nPrompt DB 'Please enter value of n: $'
rPrompt DB 'Please enter value of r: $'
result  DB 'The result is equal to $'
DtSeg   ENDS

CDSeg   Segment
        ASSUME CS:CDSeg,DS:DtSeg,SS:StSeg
Start:
        MOV     AX,DtSeg    ; set DS to point to the data segment
        MOV     DS,AX
        
        LEA     DX,nPrompt  ; load promt message address for n in DX
        MOV     AH,9        ; set INT 21H code to print string
        INT     21H         ; call INT 21H
        
        PUSH    0           ; push 0 as place holder of readI result
        CALL    readI       ; call readI
        CALL    pEndl       ; go to next line
        POP     CX          ; store n in CX
        
        PUSH    1           ; push 0 as place holder of F result
        PUSH    CX          ; push CX as are (= n)
        CALL    F           ; call F to calculate n!
        POP     DX          ; clean up 
        
        LEA     DX,rPrompt  ; load promt message address for r in DX
        MOV     AH,9        ; set INT 21H code to print string
        INT     21H         ; call INT 21H
        
        PUSH    0           ; push 0 as place holder of readI result
        CALL    readI       ; call readI
        CALL    pEndl       ; go to next line
        POP     BX          ; store r in BX
        
        SUB     CX,BX       ; calculate value of n-r
        
        PUSH    1           ; push 0 as place holder of F result
        PUSH    CX          ; push AX as arg (= n - r)                                                     
        CALL    F           ; call F to calculate n!
        POP     DX          ; clean up 
        
        POP     BX          ; pop value of (n-r)! in BX
        POP     AX          ; pop value of n! in AX
        MOV     DX,0        ; set DX = 0 for 32/16 division
        DIV     BX          ; AX = DAX / BX
        
        PUSH    AX          ; push AX in stack as arg of printUI
        LEA     DX,result   ; load result message address in DX
        MOV     AH,9        ; set INT 21H code to print string
        INT     21H         ; call INT 21H
        CALL    printUI     ; call printUI
        POP     AX          ; clean up stack
        
        MOV     AH,4CH      ; DOS: terminate program
        MOV     AL,0        ; return code will be 0
        INT     21H         ; terminate the program
 
       
; F: a subroutine to calculate n!
; Instruction of stack:
; PUSH 1 as place holder for return value
; PUSH n
F       PROC    NEAR
        PUSHF               ; store registers
        PUSH    AX
        PUSH    CX
        PUSH    BP
        MOV     BP,SP
               
        MOV     AX,1        ; set initial value of AX to 1
        
        MOV     CX,[BP+10]  ; set CX = n
        
        CMP     CX,0        ; compare CX with 0
        JE      retSg       ; jump to return segment if n == 0
        
fLoop:  MUL     CX          ; AX *= CL (16 * 8 multiplication)
        LOOP    fLoop       ; loop over value of CL
        
        MOV     [BP+12],AX  ; store result in plac holder
       
retSg:  POP     BP          ; restore registers
        POP     CX
        POP     AX
        POPF
        RET
F       ENDP


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
        