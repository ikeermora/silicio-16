; Silicio-16 Fibonacci demo
; Stores F(0)..F(9) in RAM[0x20]..RAM[0x29].
;
; Register allocation:
; R0 = constant 0
; R1 = previous Fibonacci number
; R2 = current Fibonacci number
; R3 = next Fibonacci number (temporary)
; R4 = RAM write pointer
; R5 = constant 1
; R6 = remaining iteration count

        LDI   R0, 0
        LDI   R1, 0
        LDI   R2, 1
        LDI   R4, 0x20
        LDI   R5, 1
        LDI   R6, 10

loop:
        STORE [R4], R1
        ADD   R3, R1, R2
        MOV   R1, R2
        MOV   R2, R3
        ADD   R4, R4, R5
        SUB   R6, R6, R5
        CMP   R6, R0
        BNE   loop            ; PC-relative offset = -8

        HALT
