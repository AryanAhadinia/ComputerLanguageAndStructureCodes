; Computer Language and Structure, HW3, Q4
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
result  DB 'The result is:            $'
DtSeg   ENDS

CDSeg   Segment
        ASSUME CS:CDSeg,DS:DtSeg,SS:StSeg
Start:
        MOV     AX,DtSeg    ; set DS to point to the data segment
        MOV     DS,AX
        
        LEA     DX,prompt   ; load address of prompt message in DX
        MOV     AH,9        ; set INT 21H code to print string
        INT     21H         ; call INT 21H
        
        MOV     AH,0AH      ; set INT 21H code to read bufferd keyboard input
        LEA     DX,inBuf    ; set address of buffer in DX
        INT     21H         ; call OS for interupption
         
        CALL    pEndl       ; next line
        
        LEA     DX,result   ; load address of prompt message in DX
        MOV     AH,9        ; set INT 21H code to print string
        INT     21H         ; call INT 21H
        
        MOV     CX,0        ; clear CX
        MOV     CL,rSize    ; load readed string size in CL
        LEA     BX,inStr    ; load effective address of inStr in BX
        
        MOV     AH,02H      ; set INT 21H code for print char, will use in loop
        
strL:   MOV     DL,[BX]     ; load read char in loop
        INC     BX          ; BX to next
        
        MOV     DH,32       ; set DH = 20H 
        OR      DH,DL       ; DH = lowercase(DL)
        CMP     DH,97       ; compare DH with 'a'
        JL      notAlpha    ; jump if DH < 'a'
        CMP     DH,122      ; compare DL with 'z'
        JG      notAlpha    ; jump if DH > 'a'
        XOR     DL,20H      ; complement 6'th bit if alphabetical
notAlpha:
        INT     21H         ; print char
        LOOP    strL        ; loop over string

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

CDSeg   ENDS
END Start
        