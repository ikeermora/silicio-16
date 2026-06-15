# Silicio-16 Instruction Set Architecture (ISA)

## Overview

Silicio-16 is a 16-bit educational processor designed for FPGA implementation and computer architecture learning.

### Key Features

* 16-bit datapath
* 16-bit instruction word
* 8 general-purpose registers (R0-R7)
* Custom similarity instruction (SIM)

---

## Registers

The processor contains eight 16-bit general-purpose registers:

| Register |
| -------- |
| R0       |
| R1       |
| R2       |
| R3       |
| R4       |
| R5       |
| R6       |
| R7       |

---

## Arithmetic Instructions

### ADD

Syntax:

ADD rd, ra, rb

Description:

Adds the contents of ra and rb and stores the result in rd.

### SUB

Syntax:

SUB rd, ra, rb

Description:

Subtracts rb from ra and stores the result in rd.

---

## Logic Instructions

### AND

Syntax:

AND rd, ra, rb

### OR

Syntax:

OR rd, ra, rb

### XOR

Syntax:

XOR rd, ra, rb

---

## Data Movement Instructions

### MOV

Syntax:

MOV rd, ra

### LDI

Syntax:

LDI rd, immediate

### LOAD

Syntax:

LOAD rd, address

### STORE

Syntax:

STORE rd, address

---

## Control Flow Instructions

### CMP

Syntax:

CMP ra, rb

### BEQ

Syntax:

BEQ address

### BNE

Syntax:

BNE address

### JMP

Syntax:

JMP address

---

## System Instructions

### NOP

No operation.

### HALT

Stops processor execution.

---

## Custom Instructions

### SIM

Syntax:

SIM rd, ra, rb

Description:

Computes a similarity score between two operands and stores the result in rd.
