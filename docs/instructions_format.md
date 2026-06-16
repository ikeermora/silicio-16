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

## Field Sizes

- Opcode: 4 bits
- Register fields: 3 bits
- Immediate: 8 bits
- Jump address: 12 bits
- Branch offset: 6 bits

---

## Instruction Layouts

### R-Type

Used by: `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SIM`

```text
15      12 11    9 8     6 5     3 2     0
+---------+--------+-------+-------+--------+
| Opcode  |  rd    |  ra   |  rb   | unused |
+---------+--------+-------+-------+--------+
```

Field breakdown:

- `Opcode`: 4 bits
- `rd`: 3 bits
- `ra`: 3 bits
- `rb`: 3 bits
- `unused`: 3 bits

Total: `4 + 3 + 3 + 3 + 3 = 16 bits`

---

### I-Type

Used by: `LDI`

```text
15      12 11    9 8              1 0
+---------+--------+----------------+-+
| Opcode  |  rd    |      imm       | |
+---------+--------+----------------+-+
```

Field breakdown:

- `Opcode`: 4 bits
- `rd`: 3 bits
- `imm`: 8 bits
- `unused`: 1 bit

Total: `4 + 3 + 8 + 1 = 16 bits`

---

### J-Type

Used by: `JMP`

```text
15      12 11                       0
+---------+--------------------------+
| Opcode  |         address          |
+---------+--------------------------+
```

Field breakdown:

- `Opcode`: 4 bits
- `address`: 12 bits

Total: `4 + 12 = 16 bits`

---

### Branch Type

Used by: `BEQ`, `BNE`

```text
15      12 11    9 8     6 5       0
+---------+--------+-------+---------+
| Opcode  |  rs    |  rt   | offset  |
+---------+--------+-------+---------+
```

Field breakdown:

- `Opcode`: 4 bits
- `rs`: 3 bits
- `rt`: 3 bits
- `offset`: 6 bits

Total: `4 + 3 + 3 + 6 = 16 bits`

---

### Compare Type

Used by: `CMP`

```text
15      12 11    9 8     6 5       0
+---------+--------+-------+---------+
| Opcode  |  ra    |  rb   | unused  |
+---------+--------+-------+---------+
```

Field breakdown:

- `Opcode`: 4 bits
- `ra`: 3 bits
- `rb`: 3 bits
- `unused`: 6 bits

Total: `4 + 3 + 3 + 6 = 16 bits`

---

### Register Copy Type

Used by: `MOV`

```text
15      12 11    9 8     6 5       0
+---------+--------+-------+---------+
| Opcode  |  rd    |  ra   | unused  |
+---------+--------+-------+---------+
```

Field breakdown:

- `Opcode`: 4 bits
- `rd`: 3 bits
- `ra`: 3 bits
- `unused`: 6 bits

Total: `4 + 3 + 3 + 6 = 16 bits`

---

### M-Type

Used by: `LOAD`, `STORE`

```text
15      12 11    9 8     6 5       0
+---------+--------+-------+---------+
| Opcode  |  rd    |  rs   | unused  |
+---------+--------+-------+---------+
```

Field breakdown:

- `Opcode`: 4 bits
- `rd`: 3 bits
- `rs`: 3 bits
- `unused`: 6 bits

Total: `4 + 3 + 3 + 6 = 16 bits`

---

### Special Type

Used by: `NOP`, `HALT`

```text
15      12 11                       0
+---------+--------------------------+
| Opcode  |          unused          |
+---------+--------------------------+
```

Field breakdown:

- `Opcode`: 4 bits
- `unused`: 12 bits

Total: `4 + 12 = 16 bits`