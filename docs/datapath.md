# List of Blocks that will form the Datapath

* Program Counter
* Instruction Memory
* Instruction Register
* Control Unit
* Register File
* ALU
* Data Memory
* Immediate Extension Unit
* Branch / PC Logic
* Multiplexers

## Hardware Blocks

### Program Counter
Purpose: Stores the address of the next instruction the CPU should execute. It should update to `PC + 1`. For jumps or branches, it should update to the new target address.

Inputs: 
- Clock: Updates the PC on each cycle
- Reset: Sets the PC back to the starting address
- Next PC value: The address that should be loaded into the PC
- PC write enable: Allows the PC to update.

Outputs: 
- Current PC Value: Sent to instruction memory as the instruction address.

### Instruction Memory
Purpose: Stores the program instructions. It receives the current PC value as an address and outputs the 16-bit instruction stored at that address

Inputs:
- Program Counter **(PC)**

Outputs: 
- 16-bit Instruction address

### Instruction Register
Purpose: It keeps one instruction at a time frozen, so it does not change bits by accident. 

Inputs: 
- Instruction address bits from *Instruction Memory*
- Clock
- Write Enable

Outputs: Instruction bits

### Control Unit
Purpose: It sends the control signals each clock cycle through the steps of execution of an instruction to the blocks across the datapath.

Inputs: 
- Clock
- Reset
- Opcode
- Funct
- Zero / ALU Flags

Outputs: 
- PCWrite
- IRWrite / WriteEnable
- RegWrite
- MemWrite
- MemRead
- ALUSelA / ALUSelB
- ALUOp
- PCSrc
- MemToReg


### Register File
Purpose:

Inputs: 

Outputs: 

### ALU
Purpose:

Inputs: 

Outputs: 

### Data Memory
Purpose:

Inputs: 

Outputs: 

### Immediate Extension Unit
Purpose:

Inputs: 

Outputs: 

### Branch / PC Logic
Purpose:

Inputs: 

Outputs: 

### Multiplexers
Purpose:

Inputs: 

Outputs: 
