# Silicio-16 Multi-Cycle Emulator

Este es el **Modelo de Referencia en Software** para el procesador **Silicio-16**. Actúa como un emulador arquitectónico de bajo nivel desarrollado en Python para validar el comportamiento lógico de la CPU antes de proceder con la implementación del RTL en Verilog/SystemVerilog.

A diferencia de las simulaciones de un solo ciclo, este emulador modela de forma precisa una **arquitectura estructural multiciclo**, reflejando fielmente el diagrama de bloques del hardware.

---

## 🚀 Características del Emulador

* **Máquina de Estados Finitos (FSM):** Ejecución basada en ciclos de reloj reales a través de etapas de control dedicadas.
* **Registros Temporales de Hardware:** Simulación de buffers intermedios del silicio:
  * `IR` (Instruction Register)
  * `A Register` y `B Register` (Salidas del Register File)
  * `ALUOut` (Registro de salida de la ALU)
  * `MDR` (Memory Data Register)
* **Simulación de Señales de Control:** Modelado de multiplexores (`ALUSelA`, `ALUSelB`) y operaciones de la ALU (`ALUOp`) manejadas por la Unidad de Control.
* **Comportamiento de 16 bits:** Enmascaramiento estricto (`& 0xFFFF`) en todas las operaciones aritméticas y lógicas para emular el desbordamiento real del hardware.

---

## ⚙️ Arquitectura de la FSM (Ciclo de Reloj)

Cada instrucción se procesa de forma secuencial dividida en las siguientes etapas físicas:

1. **`FETCH`:** El `PC` apunta a la memoria de instrucciones, se extrae la tupla y se almacena en el *Instruction Register* (`IR`).
2. **`DECODE`:** La Unidad de Control analiza el tamaño y Opcode en el `IR`, activa los selectores de los MUX correspondientes y carga los valores reales desde el *Register File* hacia los registros temporales `A` y `B`.
3. **`EXECUTE`:** La ALU procesa los datos de los registros intermedios según la señal `ALUOp` y deposita el resultado en `ALUOut`.
4. **`WRITEBACK`:** El resultado de `ALUOut` se escribe de vuelta en el registro destino del *Register File* y se incrementa el `PC` para el siguiente ciclo.

---

## 📁 Estructura del Proyecto

```text
emulator/
├── main.py       # Director de orquesta, carga el programa e itera los ciclos de reloj.
├── cpu.py        # CPU estructural (FSM, Registros microarquitectónicos y ALU).
└── memory.py     # Componente de memoria unificada para instrucciones y datos.
