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
* Multiplexers*

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
Purpose: Keeps track of the instruction that is being executed by the processor. 

Inputs: 

Outputs: 

### Instruction Register
Purpose:

Inputs: 

Outputs: 

### Control Unit
Purpose:

Inputs: 

Outputs: 

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
