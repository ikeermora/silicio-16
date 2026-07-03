# Silicio-16 Opcode Table

Silicio-16 uses a 4-bit opcode field. This allows up to 16 instructions.

## Opcode Assignments

| Opcode | Hex | Instruction | Type | Description |
|---|---|---|---|---|
| 0000 | 0x0 | NOP | Special | No operation |
| 0001 | 0x1 | ADD | R-Type | Add two registers |
| 0010 | 0x2 | SUB | R-Type | Subtract two registers |
| 0011 | 0x3 | AND | R-Type | Bitwise AND |
| 0100 | 0x4 | OR | R-Type | Bitwise OR |
| 0101 | 0x5 | XOR | R-Type | Bitwise XOR |
| 0110 | 0x6 | SIM | R-Type | Similarity operation |
| 0111 | 0x7 | MOV | Register Copy | Copy register value |
| 1000 | 0x8 | LDI | I-Type | Load immediate |
| 1001 | 0x9 | LOAD | M-Type | Load from data memory |
| 1010 | 0xA | STORE | M-Type | Store to data memory |
| 1011 | 0xB | CMP | Compare | Compare two registers |
| 1100 | 0xC | BEQ | Branch | Branch if equal |
| 1101 | 0xD | BNE | Branch | Branch if not equal |
| 1110 | 0xE | JMP | J-Type | Jump to address |
| 1111 | 0xF | HALT | Special | Stop execution |


---

## Notes

These opcode values are fixed for Silicio-16 v1.0 and should be used consistently across:

- Emulator
- Assembler
- Control Unit
- RTL implementation