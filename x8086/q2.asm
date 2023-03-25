; Computer Language and Structure, HW3, Q2
; Aryan Ahadinia, 98103878
; Marked as final, Version 0

StSeg   Segment STACK 'STACK'
ns      DB 100H DUP (?)
StSeg   ENDS
                           
DtSeg   Segment
number  DW  -16000
prompt  DB  'Your number is $'
DtSeg   ENDS

CDSeg   Segment
        ASSUME  CS:CDSeg,DS:DtSeg,SS:StSeg
Start:  MOV     AX,DtSeg    ; set DS to point to the data segment
        MOV     DS,AX
        
        LEA     DX,prompt   ; load prompt message
        MOV     AH,9        ; set INT 21H code to print string
        INT     21H         ; call INT 21H
        
        MOV     AX,number   ; load number in AX
        PUSH    AX          ; push AX in stack as subroutine arg
        CALL    printI      ; call printI
        POP     AX          ; pop AX just for cleaning up stack

        MOV     AH,4CH      ; DOS: terminate program
        MOV     AL,0        ; return code will be 0
        INT     21H         ; terminate the program 


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
