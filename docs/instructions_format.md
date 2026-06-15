# Silicio-16 Instructions Format

This document demonstrates the format each instruction of the Silicio-16 operates.

---

## R-Type Instructions (Register Instructions)

ADD
SUB
AND
OR
XOR
SIM


### Required Information
* Opcode
* Destination Register (rd)
* Source Register A (ra)
* Source Register B (rb)

### Example
ADD R1, R2, R3
rd = r1
ra = r2
rb = r3

---

## I-Type (Immediate Instructions)
LDI

### Required Information
* Opcode
* Destination Register (rd)
* Immediate (imm)

### Example

LDI R1, imm
rd = R1
imm = imm

---

## J-Type (Jump Instructions)

JMP

### Required Information
* Opcode
* address

### Example

JMP 120
address = 120


---

## Branch Type
BEQ
BNE

### Required Information
* Opcode
* rs
* rt
* address

### Example

beq R0, R1, address
rs = r0
rt = r1
address = address

---
## Compare Type

CMP

### Required Information 

* Opcode 
* ra 
* rb

### Example

CMP R1, R2
ra = R1
rb = R2

---
## Register Copy Type

MOV

### Required Information

* Opcode
* ra
* rd

### Example

MOV R1, R2
rd = R1
ra = R2


---

## M-Type (Memory instructions)
LOAD
STORE

### Required Information
* Opcode 
* Rs
* Rd

### Example
LOAD R1, R2
rs = R2
rd = R1

---

## Special Instructions
NOP
HALT