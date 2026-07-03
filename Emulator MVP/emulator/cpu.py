class CPU:
    def __init__(self, memory):
        self.pc = 0
        self.registers = [0] * 8  # R0 a R7 inicializados en 0

        # NUEVOS REGISTROS TEMPORALES 
        self.ir = None          # Instruction Register
        self.a_reg = 0          # A Register (General Purpose)
        self.b_reg = 0          # B Register (General Purpose)
        self.alu_out = 0        # ALU Output
        self.mdr = 0            # Memory Data Register
        
        
        self.memory = memory
        self.current_state = "FETCH"
        self.running = True
        self.ALUSelA = False #False para inmediato, True para registros
        self.ALUSelB = False #False para inmediato, True para registros
        self.ALUOp = "ADD" #Operacion de la ALU

    def step(self):

        if self.current_state == "FETCH":
            # 1. Leer de Instruction Memory usando el PC
            # 2. Guardar el resultado en el Instruction Register (self.ir)
            # 3. Cambiar al siguiente estado
            self.ir = self.memory.read_instruction(self.pc)
            if self.ir is None:
                self.running = False
                return False
            self.current_state = "DECODE"

        elif self.current_state == "DECODE":
            # 1. Leer los registers del Registers File segun indique self.ir
            # 2. Guardar los valores en self.a_reg y self.b_reg
            # 3. La Control Unit analiza que instruccion es (LDI, ADD, etc.)
            self.ALUOp = self.ir[0]                         #Sacamos el primer elemento de la tupla (que es el opcode)
            if len(self.ir) == 4:
                self.a_reg = self.registers[self.ir[2]]
                self.b_reg = self.registers[self.ir[3]]

            elif len(self.ir) == 3:
                self.a_reg = 0
                if self.ALUOp == "MOV":
                    self.b_reg = self.registers[self.ir[2]]
                else:
                    self.b_reg = self.ir[2]
            
            else:
                self.a_reg = None
                self.b_reg = None

            if self.a_reg == 0 and len(self.ir) == 3: #Si a_reg es 0, es una instruccion LDI o MOV
                self.ALUSelA = False
                self.ALUSelB = False
                    
            else:
                self.ALUSelA = True
                self.ALUSelB = True
            self.current_state = "EXECUTE"

        elif self.current_state == "EXECUTE":
            # 1. Aqui opera la ALU.
            # 2. Dependiendo de los MUX (ALUSelA y ALUSelB), eliges las entradas.
            #    Por ejemplo, si es ADD: opera self.a_reg y self.b_reg.
            #    Si es LDI: usa el Immediate Ext.
            # 3. El resultado se guarda en self.alu_out

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
            elif self.ALUOp == "LDI":
                self.alu_out = self.b_reg & 0xFFFF
            elif self.ALUOp == "MOV":
                self.alu_out = self.b_reg & 0xFFFF
            
            else:
                self.running = False
                print("Error en la instruccion")
                return False

            self.current_state = "WRITEBACK"

        elif self.current_state == "WRITEBACK":
            # 1. Guardar el resultado de self.alu_out de vuelta en el Register File
            # 2. Actualizar el PC (usando la logica de Brach/PC Logic si corresponde)
            #    Por ahora, solo incrementamos el PC
            self.registers[self.ir[1]] = self.alu_out
            self.pc += 1
            self.current_state = "FETCH" #Volver a empezar con la siguiente instruccion
            return True

    def dump_registers(self):
        """Muestra el estado actual de los registros"""
        print("\n=== Register Dump ===")
        for i in range(8):
            print(f"R{i} = {self.registers[i]}")
        print(f"PC = {self.pc}")
        print("========================\n")
