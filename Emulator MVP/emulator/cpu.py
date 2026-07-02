class CPU:
    def __init__(self, memory):
        self.pc = 0
        self.registers = [0] * 8  # R0 a R7 inicializados en 0
        self.memory = memory
        self.running = True

    def step(self):
        """Ejecuta una sola instruccion (un paso del reloj)"""
        if not self.running:
            return False

        # 1. FETCH
        instr = self.memory.read_instruction(self.pc)
        if instr is None:
            self.running = False
            return False

        # 2. DECODE & EXECUTE (Separamos la tupla)
        op = instr[0]

        if op == "LDI":
            # Formato: ("LDI", reg_dest, inmediato)
            _, rd, imm = instr
            self.registers[rd] = imm & 0xFFFF

        elif op == "MOV":
            # Formato: ("MOV", reg_dest, reg_origen)
            _, rd, rs = instr
            self.registers[rd] = self.registers[rs] & 0xFFFF

        elif op == "ADD":
            # Formato: ("ADD", reg_dest, reg_src1, reg_src2)
            _, rd, rs1, rs2 = instr
            self.registers[rd] = (self.registers[rs1] + self.registers[rs2]) & 0xFFFF

        elif op == "SUB":
            _, rd, rs1, rs2 = instr
            self.registers[rd] = (self.registers[rs1] - self.registers[rs2]) & 0xFFFF

        elif op == "AND":
            _, rd, rs1, rs2 = instr
            self.registers[rd] = (self.registers[rs1] & self.registers[rs2]) & 0xFFFF

        elif op == "OR":
            _, rd, rs1, rs2 = instr
            self.registers[rd] = (self.registers[rs1] | self.registers[rs2]) & 0xFFFF

        elif op == "XOR":
            _, rd, rs1, rs2 = instr
            self.registers[rd] = (self.registers[rs1] ^ self.registers[rs2]) & 0xFFFF

        else:
            print(f"Instruccion desconocida: {op}")
            self.running = False
            return False

        # 3. ACTUALIZAR PC
        self.pc += 1
        return True

    def dump_registers(self):
        """Muestra el estado actual de los registros"""
        print("\n=== Register Dump ===")
        for i in range(8):
            print(f"R{i} = {self.registers[i]}")
        print(f"PC = {self.pc}")
        print("========================\n")