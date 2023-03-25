; Computer Language and Structure, HW3, Q8
; Aryan Ahadinia, 98103878
; Marked as final, Version 0

StSeg   Segment STACK 'STACK'
ns      DB 1000H DUP (?)
StSeg   ENDS

DtSeg   Segment
a1      DW 1, 3, 5, 7
a1Size  DW 4
a2      DW 10, 11, 12, 13, 14, 15, 16, 17, 18
a2Size  DW 9
merged  DW 100H DUP (?)

temp1   DW ?
temp2   DW ?
DtSeg   ENDS

ExSeg   Segment
   
ExSeg   ENDS

CDSeg   Segment
        ASSUME CS:CDSeg,DS:DtSeg,SS:StSeg,ES:ExSeg
Start:
        MOV     AX,DtSeg    ; set DS to point to the data segment
        MOV     DS,AX
        
        LEA     AX,a1       ; load address of first array in in AX
        PUSH    AX          ; push address of first array in stack 
        
        MOV     AX,a1Size   ; load size of first array in AX
        PUSH    AX          ; push size of first array in stack
        
        LEA     AX,a2       ; load address of second array in in AX
        PUSH    AX          ; push address of second array in stack
        
        MOV     AX,a2Size   ; load size of second array in AX
        PUSH    AX          ; push size of second array in stack
        
        CALL    merge

        MOV     AH,4CH      ; DOS: terminate program
        MOV     AL,0        ; return code will be 0
        INT     21H         ; terminate the program
        

; merge: a procedure to merge to ascending sorted array
; Instruction for stack
; push place holder for result array address
; push first array address
; push first array size
; push second array address
; push second array size
merge   PROC    NEAR
        PUSHF               ; store registers in stack
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    DI
        PUSH    BP
        MOV     BP,SP
            
        MOV     DX,[BP+16]  ; pop size of second array in DX
        MOV     BX,[BP+18]  ; pop address of second array in BX
        MOV     temp1,DX
        
        MOV     CX,[BP+20]  ; pop size of first array in CX
        MOV     DI,[BP+22]  ; pop address of first array in BX
        MOV     temp2,CX
        
mrgL:   CMP     CX,0        ; end merge loop if CX == 0
        JZ      mrgLE
        CMP     DX,0        ; end merge loop if DX == 0
        JZ      mrgLE
        MOV     AX,[BX]     ; move smallest element of a2 in AX
        CMP     AX,[DI]     ; compare smallest element of a2 with smallest element of a1
        JLE     normM       ; jump if [BX] <= [DI]
XCGreq: MOV     AX,[DI]     ; change place of two array else
        XCHG    CX,DX
        XCHG    DI,BX             
normM:  DEC     DX          ; DX -= 1
        ADD     BX,2        ; BX += 2
        PUSH    AX          ; push smallest element in stack
        JMP     mrgL        ; back to loop condition checking
mrgLE:

        CMP     DX,0        ; check if second array is empty or not
        JZ      normC       ; jump if empty
        XCHG    CX,DX       ; change place of first and second if not
        XCHG    DI,BX
normC:  MOV     AX,[DI]     ; concat the rest
        PUSH    AX          ; push AX
        ADD     DI,2        ; go to next element
        LOOP    normC

        MOV     CX,temp1
        ADD     CX,temp2    ; CX = size(a1) + size(a2)
        
        MOV     DX,CX
        SHL     DX,1
        LEA     BX,merged
        ADD     BX,DX
                
cLoop:  CALL    printI      ; print last element in stack
        CALL    pEndl       ; go to next line
        POP     AX          ; clean up stack
        ADD     BX,-2       ; BX to prev cell
        MOV     [BX],AX
        LOOP    cLoop       ; loop
        
        MOV     DX,merged   ; set return value
        MOV     [BP+24],DX
        
        POP     BP          ; restore registers from stack
        POP     DI
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        POPF
        RET    
merge   ENDP


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
        