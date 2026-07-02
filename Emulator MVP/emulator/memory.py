class Memory:
	def __init__(self):
		# Memoria de instrucciones (lista de tuplas)
		self.instructions = []
		# Memoria de datos basica por si se necesita en el futuro (ej. 256 posiciones)

	def load_program(self, program_list):
		self.instructions = program_list

	def read_instruction(self, pc):
		if 0 <= pc < len(self.instructions):
			return self.instructions[pc]
		return None  # Fin del programa o dirección invalida 