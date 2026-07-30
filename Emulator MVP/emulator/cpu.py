class CPU:
    def __init__(self, memory):
        self.memory = memory
        self.pc = 0
        self.registers = [0] * 8
        self.memorylocation = [0] * 256
        self.cycle = 1
        self.running = True

        # REGISTROS MICROARQUITECTONICOS
        self.ir = None
        self.a_reg = 0
        self.b_reg = 0
        self.alu_out = 0
        self.mdr = 0
        self.opcode = None # Guardará la instrucción global (ej. "LOAD")
        
        # SENALES DE CONTROL
        self.PCWrite = 0
        self.IRWrite = 0
        self.RegWrite = 0
        self.MemRead = 0
        self.MemWrite = 0
        self.ALUSelA = 0
        self.ALUSelB = 0
        self.ALUOp = "0000" # Operación matemática (ej. "ADD")
        self.MemToReg = 0
        self.PCSrc = 0
        self.RegDst = 0
        self.ImmSrc = 0
        self.Halt = 0
        self.ALUOutWrite = 0
        self.MDRWrite = 0
        self.FlagsWrite = 0

        # FLAGS
        self.ZeroFlag = 0

    def step(self):
        # ==========================================
        # ETAPA 1: UNIDAD DE CONTROL (Genera señales)
        # ==========================================

        # Reiniciamos las señales transitorias
        self.PCWrite = 0
        self.IRWrite = 0
        self.RegWrite = 0
        self.MemRead = 0
        self.MemWrite = 0
        self.MDRWrite = 0
        self.FlagsWrite = 0
        self.ALUOutWrite = 0

        if self.cycle == 1: # FETCH
            self.IRWrite = 1
            self.PCWrite = 1
            # En tu arquitectura actual el PC avanza directo, 
            # pero si pasara por la ALU, ALUOp sería "ADD"
            self.ALUOp = "ADD" 
            
        elif self.cycle == 2: # DECODE
            # Guardamos el opcode para dictar el flujo de los siguientes ciclos
            self.opcode = self.ir[0] 

        elif self.cycle == 3: # EXECUTE / MEM ADDRESS COMPUTE / BRANCH
            if self.opcode == "LDI":
                self.RegWrite = 1
                self.MemToReg = 2

            elif self.opcode == "MOV":
                self.RegWrite = 1
                self.MemToReg = 3

            elif self.opcode in ["ADD", "SUB", "AND", "OR", "XOR", "SIM"]:
                self.ALUSelA = 1
                self.ALUSelB = 0
                self.ALUOp = self.opcode # Aquí el opcode y ALUOp sí coinciden
                self.ALUOutWrite = 1

            elif self.opcode in ["LOAD", "STORE"]:
                self.ALUSelA = 1
                self.ALUSelB = 0
                self.ALUOp = "ADD" # La ALU suma registro base para calcular dirección
                self.ALUOutWrite = 1

            elif self.opcode == "CMP":
                self.ALUSelA = 1
                self.ALUSelB = 0
                self.ALUOp = "SUB" # Restamos para comparar, sin guardar en registro
                self.ALUOutWrite = 1
                self.FlagsWrite = 1

            elif self.opcode == "BEQ":
                if self.ZeroFlag == 1:
                    self.PCWrite = 1
                    
            elif self.opcode == "BNE":
                if self.ZeroFlag == 0:
                    self.PCWrite = 1

            elif self.opcode == "JMP":
                self.PCWrite = 1

            elif self.opcode == "HALT":
                self.Halt = 1

        elif self.cycle == 4: # MEMORY ACCESS / ALU WRITEBACK
            if self.opcode in ["ADD", "SUB", "AND", "OR", "XOR", "SIM"]:
                self.RegWrite = 1
                self.MemToReg = 0

            elif self.opcode == "LOAD":
                self.MemRead = 1
                self.MDRWrite = 1 

            elif self.opcode == "STORE":
                self.MemWrite = 1 
                
        elif self.cycle == 5: # WRITEBACK LOAD
            if self.opcode == "LOAD":
                self.RegWrite = 1
                self.MemToReg = 1 

        # ==========================================
        # ETAPA 2: DATAPATH (Ejecuta basado en señales)
        # ==========================================
        
        if self.cycle == 1:
            if self.IRWrite == 1:
                self.ir = self.memory.read_instruction(self.pc)
            if self.PCWrite == 1:
                self.pc += 1
            self.cycle = 2
            return True

        elif self.cycle == 2:
            if len(self.ir) == 4:
                self.a_reg = self.registers[self.ir[2]]
                self.b_reg = self.registers[self.ir[3]]
            elif len(self.ir) == 3:
                self.a_reg = 0
                self.b_reg = self.ir[2]
            elif len(self.ir) == 2:
                self.a_reg = 0
                self.b_reg = self.ir[1]
            self.cycle = 3
            return True

        elif self.cycle == 3:
            # --- Tareas de ejecución de la ALU ---
            if self.ALUOutWrite == 1:
                # La ALU obedece estrictamente a ALUOp
                if self.ALUOp == "ADD":
                    self.alu_out = (self.a_reg + self.b_reg) & 0xFFFF 
                elif self.ALUOp == "SUB":
                    self.alu_out = (self.a_reg - self.b_reg) & 0xFFFF 
                elif self.ALUOp == "AND":
                    self.alu_out = (self.a_reg & self.b_reg) & 0xFFFF 
                elif self.ALUOp == "OR":
                    self.alu_out = (self.a_reg | self.b_reg) & 0xFFFF 
                elif self.ALUOp == "XOR":
                    self.alu_out = (self.a_reg ^ self.b_reg) & 0xFFFF 
                elif self.ALUOp == "SIM":
                    temp = bin((self.a_reg ^ self.b_reg) & 0xFFFF)
                    self.alu_out = temp.count('1')
                
                # Actualización de flags (Ej: después de un SUB proveniente de un CMP)
                if self.FlagsWrite == 1:
                    if self.alu_out == 0:
                        self.ZeroFlag = 1
                    else:
                        self.ZeroFlag = 0

            # --- Resolución temprana de instrucciones (Saltos, LDI, MOV, HALT) ---
            if self.opcode == "LDI" and self.RegWrite == 1:
                rd = self.ir[1]
                if self.MemToReg == 2:
                    self.registers[rd] = self.b_reg & 0xFFFF
                self.cycle = 1
                return True

            elif self.opcode == "MOV" and self.RegWrite == 1:
                rd = self.ir[1]
                self.registers[rd] = self.a_reg & 0xFFFF
                self.cycle = 1
                return True
                
            elif self.opcode in ["BEQ", "BNE", "JMP"] and self.PCWrite == 1:
                # Asumiendo que el argumento de salto está en b_reg (inmediato)
                self.pc = self.b_reg & 0xFFFF
                self.cycle = 1
                return True
                
            elif self.opcode in ["BEQ", "BNE", "JMP"] and self.PCWrite == 0:
                # Si la condición del branch no se cumple, solo termina la instrucción
                self.cycle = 1
                return True

            elif self.opcode == "CMP" and self.FlagsWrite == 1:
                self.cycle = 1
                return True

            elif self.opcode == "HALT" and self.Halt == 1:
                self.running = False
                self.cycle = 1
                return True

            # Si es otra instrucción, pasamos al ciclo 4
            self.cycle = 4 
            return True

        elif self.cycle == 4:
            if self.opcode in ["ADD", "SUB", "AND", "OR", "XOR", "SIM"] and self.RegWrite == 1:
                rd = self.ir[1]
                self.registers[rd] = self.alu_out
                self.cycle = 1
                return True

            elif self.opcode == "LOAD" and self.MDRWrite == 1:
                direction = self.alu_out
                self.mdr = self.memorylocation[direction] & 0xFFFF
                self.cycle = 5
                return True

            elif self.opcode == "STORE" and self.MemWrite == 1:
                rd = self.ir[1]
                direction = self.alu_out
                self.memorylocation[direction] = self.registers[rd] & 0xFFFF
                self.cycle = 1
                return True

        elif self.cycle == 5:
            if self.opcode == "LOAD" and self.RegWrite == 1:
                rd = self.ir[1]
                self.registers[rd] = self.mdr
                self.cycle = 1
                return True

    def dump_registers(self):
        print("\n=== Register Dump ===")
        for i in range(8):
            print(f"R{i} = {self.registers[i]}")
        print(f"PC = {self.pc}")
        print(f"ZeroFlag = {self.ZeroFlag}")
        print("========================\n")
