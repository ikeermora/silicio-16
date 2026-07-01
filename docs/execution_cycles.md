# Silicio-16 Execution Cycles

Silicio-16 uses a multicycle execution model. Each instruction is divided into smaller steps executed across multiple clock cycles.

## Common Cycles

### Cycle 1: **Fetch**
The CPU fetches the instruction from Instruction Memory using the current PC.

Actions:
- PC sends address to Instruction Memory
- Instruction Memory outputs the instruction
- Instruction Register stores instruction
- PC updates to PC + 1

### Cycle 2: Decode / Register Read
The CPU decodes the instruction and reads the required registers

Actions:
- The Control Unit reads the opcode
- The Register File reads source registers
- Immediate Extension prepares immediate value if needed

---

## R-Type Execution

Used by: ADD, SUB, AND, OR, XOR, SIM

Example:

ADD R1, R2, R3

Cycle 1: Fetch
Cycle 2: Decode / Register Read
Cycle 3: Execute ALU operation
Cycle 4: Write back result to rd

---

## LDI Execution
The CPU loads an immediate value from the instruction into a destination register

Example: `LDI R1, 0x25`

Cycle 1: Fetch
Cycle 2: Decode/Extension
Cycle 3: Write back

## MOV Execution

Example: `MOV R1, R2`

Cycle 1: Fetch
Cycle 2: Decode / Register Read
Cycle 3: Write Back

## LOAD Execution
The ALU calculates the address of the memory and then it goes to the RAM to bring the data.

Example: `LOAD R1, R2` 

Cycle 1: Fetch
Cycle 2: Decode / Register Read
Cycle 3: Execute (Address Calculation)
Cycle 4: Memory Read
Cycle 5: Write Back

## STORE Execution

Example: `STORE R1, R2`

Cycle 1: Fetch
Cycle 2: Decode / Register Read
Cycle 3: Execute (Address Calculation)
Cycle 4: Memory Write

## CMP Execution

The CPU compares two registers and updates the condition flags.

Example: `CMP R1, R2`

Meaning:  
Compare `R1` and `R2`. If they are equal, the Zero Flag is set.

Cycle 1: Fetch  
Cycle 2: Decode / Register Read  
Cycle 3: Execute / Flags Update

## BEQ / BNE Execution

Example: `BEQ R1, R2, offset`

Meaning:  
If `R1 == R2`, then `PC = PC + offset`.

For `BNE`, the branch is taken if the two registers are not equal.

Cycle 1: Fetch
Cycle 2: Decode Extension
Cycle 3: Execute (Branch Decision & PC Update)


## JMP Execution

Example: `JMP 0x00A5`

Cycle 1: Fetch
Cycle 2: Decode/Extension
Cycle 3: Execute (PC Update)

## NOP Execution
The processor allows a clock cycle without altering the state of the system.

Example: `NOP`


Cycle 1: Fetch
Cycle 2: Decode
Cycle 3: Execute

## HALT Execution

The execution of the program is stopped indefinitely.

Example: `HALT`

Cycle 1: Fetch  
Cycle 2: Decode / Stop


