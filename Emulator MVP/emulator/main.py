from memory import Memory 
from cpu import CPU

def main():
    # 1. Definir el programa de prueba (el del ejemplo del issue + extras)
    program = [
        ("LDI", 1, 5),
        ("LDI", 2, 7),
        ("ADD", 3, 1, 2),
        ("SUB", 4, 2, 1),
        ("XOR", 5, 1, 2),
    ]
    
    # 2. Inicializar componentes
    memory = Memory()
    memory.load_program(program)
    
    cpu = CPU(memory)
    
    print("Iniciando emulador Silicio-16...")
    
    # 3. Bucle de ejecucion paso a paso
    while cpu.running:
        input("Presiona Enter para ejecutar el siguiente paso...")
        success = cpu.step()
        if success:
            cpu.dump_registers()
            
    print("Program finalizado con exito.")
    cpu.dump_registers()
    
if __name__ == "__main__":
    main()
