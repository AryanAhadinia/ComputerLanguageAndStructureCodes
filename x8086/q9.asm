; Computer Language and Structure, HW3, Q9
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
 
c1      DW 100H DUP (0)
c2      DW 100H DUP (0)

cePmt   DB 'Please enter degree of polynomial: $'
rePmt   DB 'Standard polynomial form of result is equal to $'
sep     DB ', $'
DtSeg   ENDS

CDSeg   Segment
        ASSUME CS:CDSeg,DS:DtSeg,SS:StSeg
Start:
        MOV     AX,DtSeg    ; set DS to point to the data segment
        MOV     DS,AX
        
        PUSH    0           ; push 0 as place holder of degree
        LEA     BX,c1       ; load address of c1
        PUSH    BX          ; push address of c1 as place for coefficients
        CALL    getC        ; call getC to get coefficients from users
        POP     BX          ; clean up stack
        
        PUSH    0           ; push 0 as place holder of degree                
        LEA     BX,c2       ; load address of c2
        PUSH    BX          ; push address of c2 as place for coefficients
        CALL    getC        ; call getC to get coefficients from users
        POP     BX          ; clean up stack
        
        LEA     DX,rePmt    ; load address of result prompt message in DX
        MOV     AH,9        ; set INT 21H code to print string
        INT     21H         ; call INT 21H
        
        MOV     CX,0        ; calculate degree of result
        POP     AX          ; pop degree of second polynomial in AX
        ADD     CX,AX       ; CX += AX
        POP     AX          ; pop degree of first polynomial in AX
        ADD     CX,AX       ; CX += AX
        
        LEA     DX,sep      ; load address of separator in DX
        MOV     AH,9        ; set INT 21H code to print string

        LEA     BX,c1       ; load address of c1
        PUSH    BX          ; push address of c1
        LEA     BX,c2       ; load address of c2       
        PUSH    BX          ; push address of c2        
oLoop:  PUSH    CX          ; push degree
        PUSH    0           ; push 0 as place holder for result
        CALL    calC        ; call calC to calculate CX'th co.
        CALL    printI      ; print result (result in in stack)
        INT     21H         ; print separator
        POP     BX          ; clean up stack
        POP     BX
        LOOP    oLoop       ; loop
        
        PUSH    CX          ; push 0 for 0-degree co.
        PUSH    0           ; push 0 as place holder for result
        CALL    calC        ; call calC to calculate CX'th co.
        CALL    printI      ; print result (result in in stack) 
        POP     BX          ; clean up stack
        POP     BX          ; clean up stack
                        
        MOV     AH,4CH      ; DOS: terminate program
        MOV     AL,0        ; return code will be 0
        INT     21H         ; terminate the program
        
 
; getC: a subrotine to get coeffiencts of a polynomial
; Instruction for stack
; push place holder for degree
; push address of where to place coeffients
getC    PROC    NEAR
        PUSHF               ; store registers in stack
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    BP
        MOV     BP,SP
        
        MOV     BX,[BP+14]  ; move result place address in BX
        
        LEA     DX,cePmt    ; print prompt message for degree
        MOV     AH,9        ; set INT 21H code to print string
        INT     21H         ; call INT 21H
        
        PUSH    0           ; push 0 as placve holder for readI
        CALL    readI       ; call readI
        POP     CX          ; pop result in CX
        
        MOV     [BP+16],CX  ; set return value for degree
        
        CALL    pEndl       ; go to next line
        
        MOV     DX,0        ; start from zero
getCL:  CMP     DX,CX       ; loop over DX: 0...CX
        JG      getCLE      ; jump on codition violation
                
        PUSH    DX          ; store DX
        MOV     AH,2        ; set INT 21H code to print char
        MOV     DL,43H      ; ASCII('C') = 43H
        INT     21H         ; call INT 21H to print 'C'
        CALL    printI      ; print DX
        MOV     DL,3AH      ; ASCII(':') = 3AH 
        INT     21H         ; call INT 21H to print ':'
        POP     DX          ; restore DX
        PUSH    0           ; push 0 as place holder og readI result
        CALL    readI       ; read co.
        CALL    pEndl       ; go to next line
        POP     AX          ; pop result in AX
        MOV     [BX],AX     ; set co. in co. array
        
        INC     DX          ; go to the next
        ADD     BX,2        ; go to the next cell of array        
        JMP     getCL       ; loop
getCLE:
        
        POP     BP          ; restore registers from stack
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        POPF
        RET                 ; return to call point
getC    ENDP


; calC: a subroutine to calculate c-degree coefficent
; Instruction for stack
; push first polynomial address
; push second polynomial address
; push c
; push 0 as place holder for result
calC    PROC    NEAR
        PUSHF               ; store registers in stack
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    DI
        PUSH    BP
        MOV     BP,SP        
        
        MOV     CX,[BP+18]  ; load c in CX
        MOV     BX,[BP+20]  ; load second array address in BX
        MOV     DI,[BP+22]  ; load first array address in BP
        
        MOV     AX,CX       ; AX = CX
        SHL     AX,1        ; CX *= 2
        ADD     BX,AX       ; set BX to c'th coefficient
        
        INC     CX
        
        MOV     BP,0        ; set BP = 0 for summation
        
sumL:   MOV     AX,[BX]     ; load i'th co. of second array in AX
        MOV     DX,[DI]     ; load (c-i)'th co. of first array in AX
        MUL     DX          ; DAX = AX * DX
        ADD     BP,AX       ; BP += AX
        ADD     DI,2        ; go to next co. in first array 
        ADD     BX,-2       ; go to prev. co. in second array
        LOOP    sumL        ; loop
        
        MOV     AX,BP       ; store co. in AX
        MOV     BP,SP       ; BP = SP
        MOV     [BP+16],AX  ; set return value
        
        POP     BP          ; restore registers from stack
        POP     DI
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        POPF
        RET                 ; return to call point    
calC    ENDP


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
        