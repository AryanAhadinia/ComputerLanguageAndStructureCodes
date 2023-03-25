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
inStr   DB 10H DUP (?)
prompt  DB 'Please enter the value of N: $'
res     DW 2 DUP (?)
DtSeg   ENDS

CDSeg   Segment
        ASSUME CS:CDSeg,DS:DtSeg,SS:StSeg
Start:
        MOV     AX,DtSeg    ; set DS to point to the data segment
        MOV     DS,AX
        
        PUSH    0           ; push 0 as place holder for sum lsb
        PUSH    0           ; push 0 as place holder for sum msb
        PUSH    0           ; push 0 as place holder for readI, will be n
        LEA     DX,prompt   ; load prompt message for n in DX
        MOV     AH,9        ; set INT 21H code to print string
        INT     21H         ; call INT 21H
        CALL    readI       ; call readI
        CALL    sum         ; call sum
        POP     CX          ; clean up stack
        POP     DX          ; load result msb in DX
        POP     AX          ; load result lsb in AX
        LEA     BX,res      ; load address of result in BX
        MOV     [BX],DX     ; store msb in res[0]
        MOV     [BX+2],AX   ; store lsb in res[1]

        MOV     AH,4CH      ; DOS: terminate program
        MOV     AL,0        ; return code will be 0
        INT     21H         ; terminate the program


; sum: a procedure to calculate sum of 1 ... n
; Instruction for stack
; PUSH 0 as place holder for result lsb
; PUSH 0 as place holder for result msb
; PUSH n
sum     PROC    NEAR
        PUSHF               ; store registers
        PUSH    AX
        PUSH    DX
        PUSH    BP
        MOV     BP,SP
        
        MOV     AX,[BP+10]  ; load n in AX
        
        CMP     AX,0        ; boundry condition: compare n with 0
        JE      retSg       ; jump to return segemnt to return 00000000H
        
        SUB     AX,1        ; AX = n - 1
        
        PUSH    0           ; push 0 as place holder for sum lsb 
        PUSH    0           ; push 0 as place holder for sum msb
        PUSH    AX          ; psuh AX as arg
        CALL    sum         ; call recursion
        POP     AX          ; clean up stack
        POP     DX          ; load result msb in DX
        POP     AX          ; load result lsb in AX
        
        ADD     AX,[BP+10]  ; AX = AX + n
        JNC     nCarry      ; check if carry generated
        ADD     DX,1        ; add 1 to msb if carry
        
nCarry: MOV     [BP+14],AX  ; save lsb
        MOV     [BP+12],DX  ; save msb
        
retSg:  POP     BP          ; restore registers
        POP     DX
        POP     AX
        POPF
        RET                 ; return to call point
sum     ENDP

        
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

CDSeg   ENDS
END Start
        