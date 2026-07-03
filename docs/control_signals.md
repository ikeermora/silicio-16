# Silicio-16 Control Signals
Silicio-16 uses a multicycle control unit. The control unit activates different signals depending on the current instruction and execution cycle

## Signal List

| Signal | Purpose |
|---|---|
| PCWrite | Allows the PC to update unconditionally |
| PCWriteCond | Allows the PC update only if a branch condition is true | 
| IRWrite | Allows the Instruction Register to store a new instruction |
| RegWrite | Allows writing data into the Register File |
| MemRead | Enables reading from Data Memory |
| MemWrite | Enables writing to Data Memory |
| ALUSelA | Selects the first ALU operand |
| ALUSelB | Selects the second ALU operand |
| ALUOp | Selects the ALU operation | 
| PCSrc | Selects the next PC source | 
| MemToReg | Selects what data is written back to a register | 
| RegDst | Selects destination register field |
| ImmSrc | Selects how the immediate is extended | 
| Halt | Stops CPU execution | 
| ALUOutWrite | Allows the ALUOut register to store the ALU result | 
| MDRWrite | Allows the Memory Data register to store memory read data | 
| FlagsWrite | Allows condition flags to update | 


## Control Signal Encodings

### ALUSelA
| Value | Source |
|---|---|
| 0 | PC |
| 1 | A Register |

### ALUSelB
| Value | Source |
|---|---|
| 00 | B Register |
| 01 | Constant 1 |
| 10 | Extended Immediate |

### MemToReg
| Value | Source |
|---|---|
| 00 | ALUOut |
| 01 | MDR |
| 10 | Extended Immediate |
| 11 | A Register |

### RegDst
| Value | Destination |
|---|---|
| 00 | rd |
| 01 | rt / secondary register field |

### PCSrc
| Value | Source |
|---|---|
| 00 | ALUResult |
| 01 | Branch target |
| 10 | Jump target |

---

### ALUOp
| Value | Operation |
|---|---|
| 0000 | ADD / pass address |
| 0001 | SUB / compare |
| opcode | Use instruction opcode for R-Type |

--- 


## Common Control Cycles 


### Cycle 1: Fetch

Actions: 

- Fetch Instruction from *Instruction Memory*
- Store instruction in Instruction Register
- Update PC to PC + 1

Control Signals:

`IRWrite = 1`
`PCWrite = 1`
`ALUSelA = 0`
`ALUSelB = 01`
`ALUOp = 0000`
`PCSrc = 00`

---

## R-Type Control Signals

**Instructions** : `ADD, SUB, AND, OR, XOR, SIM`

Total duration: 4 Cycles (Cycle 1 & 2 are common; fetch & decode)

### Cycle 3: Execute 
The control unit configures the datapath multiplexers to connect the read registers in the previous cycle to the entry of the ALU and commands the ALU what math or logical operation to do.

Control Signals: 

```
ALUSelA = 1
ALUSelB = 00
ALUOp = Opcode
ALUOutWrite = 1 
RegWrite = 0
MemRead = 0
MemWrite = 0
```

### Cycle 4: Write Back
The calculated result is stable and saved.

Control Signals:

`RegWrite = 1`
`RegDst = 00`
`MemToReg = 00`
`PCWrite = 0`
`MemWrite = 0`
`ALUOutWrite = 0`


--- 

## LDI Control Signals

Total Duration: 3 Cycles (Cycles 1 & 2 are Common)

### Cycle 3: Write Back
During this Cycle, the processor takes the immediate value the block `immediate extension` has already isolated and gotten ready during Cycle 2, then writes it directly into the destination register. 

Control Signals: 

`RegWrite = 1`
`RegDst = 00`
`MemToReg = 10`
`MemRead = 0`
`MemWrite = 0`
`ALUOutWrite = 0`
`PCWrite = 0`

--- 


## MOV Control Signals

Total Duration: 3 Cycles (Cycles 1 & 2 are common)

## Cycle 3: Write Back
During this cycle, the processor takes the read value from the source register on cycle two, and writes it directly on the register bank in the destination register

Control Signals:

`RegWrite = 1`
`RegDst = 00`
`MemToReg = 11`
`MemRead = 0`
`MemWrite = 0`
`ALUOutWrite = 0`
`PCWrite = 0`

---

## LOAD Control Signals

Total Duration: 5 Cycles (Cycles 1 & 2 are common)

### Cycle 3: Execute
The address stored on the source register is passed through the ALU to stabilize it

Control Signals: 

`ALUSelA = 1`
`ALUSelB = 00`
`ALUOp = 0000`
`ALUOutWrite = 1`
`MemRead = 0`
`RegWrite = 0`

### Cycle 4: Memory Read
The processor takes the stored address in ALUOut, points to Memory Data, and enables the reading to bring the data to the temporary memory register

Control Signals: 
`MemRead = 1`
`MDRWrite = 1`
`IRWrite = 0`

*At the end of this cycle, the read data is stored in the Memory Data Register (**MDR**)*

### Cycle 5: Write Back
The now stored data on MDR is moved (saved) into rd

Control Signals:

`RegWrite = 1`
`RegDst = 00`
`MemToReg = 01`
`MemRead = 0`
`ALUOutWrite = 0`

---

## STORE Control Signals

Total Duration: 4 Cycles (Cycle 1 & 2 are Common)

### Cycle 3: Execute
The address of the saved memory in rs is passed through the ALU.

Control Signals: 
`ALUSelA = 1`
`ALUSelB = 00`
`ALUOp = 0000`
`ALUOutWrite = 1`
`MemWrite = 0`
`RegWrite = 0`

### Cycle 4: Memory Write
We take the address we just saved in ALUOut, and select the data from the register we want to keep.

Control Signals:
`MemWrite = 1`
`RegWrite = 0`
`MemRead = 0`
`ALUOutWrite = 0`

---

## CMP Control Signals

Total Duration: 3 Cycles (Cycles 1 & 2 are Common)

### Cycle 3: Execute
During this cycle, we connect both registers to the ALU so it can do the comparison (subtraction).

Control Signals:
`ALUSelA = 1`
`ALUSelB = 00`
`ALUOp = 0001`
`FlagsWrite = 1`
`RegWrite = 0`
`MemWrite = 0`
`ALUOutWrite = 0`

--- 

## BEQ/BNE Control Signals
For `BEQ`, the PC updates if the Zero Flag is 1.  
For `BNE`, the PC updates if the Zero Flag is 0.

Total Duration: 3 Cycles (Cycles 1 & 2 are common)

### Cycle 3: Execute
During this cycle, we connect the two registers we want to compare to the ALU input ports and perform the subtraction.

Control Signals:

`PCWriteCond = 1`
`PCSrc = 01`
`ALUSelA = 1`
`ALUSelB = 00`
`ALUOp = 0001`
`RegWrite = 0`
`MemWrite = 0`
`ALUOutWrite = 0`


---

## JMP Control Signals

Total Duration: 3 Cycles (Cycle 1 & 2 are common)

### Cycle 3: Execute

Control Signals:
`PCSrc = 10`
`PCWrite = 1`
`RegWrite = 0`
`MemWrite = 0`
`ALUOutWrite = 0`
`Branch = 0`

--- 

## NOP Control Signals

Total Duration: 3 Cycles (Cycles 1 & 2 are Common)

### Cycle 3: Execute (Null Operation)
The only purpose of NOP is to let time pass for sync purposes or delays. 

Control Signals: 
`RegWrite = 0`
`MemWrite = 0`
`MemRead = 0`
`ALUOutWrite = 0`
`PCWrite = 0`
`Branch = 0`

*The PC should've moved to PC + 1 during the common fetch cycle, so the processor moves clean to the next cycle*

---

## HALT Control Signals

Total Duration: 3 Cycles + Infinite Wait (Cycles 1 & 2 are common)

### Cycle 3: Stop Execution
When detecting the HALT instruction, the control unit stops the processor from continuing execution.

Control Signals:

`PCWrite = 0`  
`Halt = 1`  
`RegWrite = 0`  
`MemWrite = 0`


---

**During Decode, the A Register and B Register capture the values read from the Register File.**