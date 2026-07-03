# Silicio-16 Multi-Cycle Emulator

This is the **Software Reference Model** for the **Silicio-16** processor. It acts as a low-level architectural emulator developed in Python to validate the CPU's logical behavior before proceeding with the RTL implementation in Verilog/SystemVerilog. Unlike single-cycle simulations, this emulator accurately models a **multi-cycle structural architecture**, faithfully reflecting the hardware's block diagram.

---

## 🚀 Emulator Features

* **Finite State Machine (FSM):** Execution based on real clock cycles through dedicated control stages.
* **Hardware Temporary Registers:** Simulation of silicon intermediate buffers:
    * `IR` (Instruction Register)
    * `A Register` and `B Register` (Register File outputs)
    * `ALUOut` (ALU output register)
    * `MDR` (Memory Data Register)
* **Control Signal Simulation:** Modeling of multiplexers (`ALUSelA`, `ALUSelB`) and ALU operations (`ALUOp`) managed by the Control Unit.
* **16-bit Behavior:** Strict masking (`& 0xFFFF`) on all arithmetic and logical operations to emulate real hardware overflow.

---

## ⚙️ FSM Architecture (Clock Cycle)

Each instruction is processed sequentially, divided into the following physical stages:

1. **`FETCH`:** The `PC` points to the instruction memory, the tuple is extracted, and it is stored in the *Instruction Register* (`IR`).
2. **`DECODE`:** The Control Unit analyzes the size and Opcode in the `IR`, activates the corresponding MUX selectors, and loads the actual values from the *Register File* into the temporary registers `A` and `B`.
3. **`EXECUTE`:** The ALU processes the data from the intermediate registers according to the `ALUOp` signal and deposits the result in `ALUOut`.
4. **`WRITEBACK`:** The result from `ALUOut` is written back to the destination register in the *Register File*, and the `PC` is incremented for the next cycle.

---

## 📁 Project Structure

```text
emulator/
├── main.py       # Orchestrator; loads the program and iterates the clock cycles.
├── cpu.py        # Structural CPU (FSM, microarchitectural registers, and ALU).
└── memory.py     # Unified memory component for instructions and data.
