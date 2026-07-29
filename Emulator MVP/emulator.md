# Silicio-16 Multi-Cycle Emulator

This is the **Software Reference Model** for the **Silicio-16** processor. It acts as a low-level architectural emulator developed in Python to validate the CPU's logical behavior before proceeding with the RTL implementation in Verilog/SystemVerilog. Unlike single-cycle simulations, this emulator accurately models a **multi-cycle structural architecture**, faithfully reflecting the hardware's block diagram.

---

## 🚀 Emulator Features

* **Finite State Machine (FSM):** Execution based on real clock cycles through dedicated control stages (up to 5 cycles per instruction).
* **Hardware Temporary Registers:** Simulation of silicon intermediate buffers:
    * `IR` (Instruction Register)
    * `A Register` and `B Register` (Register File outputs)
    * `ALUOut` (ALU output register)
    * `MDR` (Memory Data Register)
* **Strict Control Logic Separation:** Accurate architectural division between the global `Opcode` (Control Unit routing) and the mathematical `ALUOp` (Datapath execution).
* **Branching & Flags:** Emulation of condition tracking (`ZeroFlag`) to support conditional (`BEQ`, `BNE`) and unconditional (`JMP`) control flow instructions.
* **16-bit Behavior:** Strict masking (`& 0xFFFF`) on all arithmetic and logical operations to emulate real hardware overflow.

---

## ⚙️ FSM Architecture (Clock Cycle)

Instructions are processed sequentially and dynamically routed through up to 5 physical stages depending on their type:

1. **`FETCH` (Cycle 1):** The memory reads the instruction at the current `PC` and stores it in the `IR`. The `PC` is immediately incremented to prepare for the next sequential instruction.
2. **`DECODE` (Cycle 2):** The Control Unit decodes the `Opcode`. The Register File automatically reads the source registers and loads the values into the temporary `A` and `B` registers.
3. **`EXECUTE / MEM ADDR / BRANCH` (Cycle 3):** * **Arithmetic/Logic:** The ALU processes the data from `A` and `B` according to the strict `ALUOp` signal and stores the result in `ALUOut`.
    * **Memory:** The ALU calculates the target memory address by adding the base register and offset.
    * **Branching:** The ALU performs a comparison (`CMP`), sets the `ZeroFlag`, and if conditions are met, the `PC` is overwritten with the jump address.
4. **`MEMORY / ALU WRITEBACK` (Cycle 4):** * **Arithmetic/Logic:** The calculated result in `ALUOut` is written back to the destination register.
    * **Memory:** Data is explicitly written to memory (`STORE`) or read from memory into the `MDR` (`LOAD`).
5. **`LOAD WRITEBACK` (Cycle 5):** The data buffered in the `MDR` from the previous cycle is written into the destination register.

---

## 📁 Project Structure

```text
emulator/
├── main.py       # Orchestrator; loads the program and iterates the clock cycles.
├── cpu.py        # Structural CPU (FSM, microarchitectural registers, and ALU).
└── memory.py     # Unified memory component for instructions and data.
