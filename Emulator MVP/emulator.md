# Silicio-16 Emulator (MVP)

Este es el **Modelo de Referencia en Software** para el procesador **Silicio-16**. Actúa como un emulador arquitectónico básico desarrollado en Python para validar el comportamiento lógico de la CPU antes de proceder con la implementación del RTL en Verilog/SystemVerilog.

---

##  Características del MVP

* **Registros de 16 bits:** Simulación estricta de 8 registros de propósito general (`R0` a `R7`) y un Program Counter (`PC`). Los resultados aritméticos y lógicos están enmascarados a 16 bits (`0xFFFF`).
* **Memoria Aislada:** Arquitectura limpia con separación lógica entre memoria y unidad de procesamiento.
* **Ejecución Paso a Paso:** Ciclo interactivo *Fetch-Execute* que permite inspeccionar los cambios en los registros tras cada ciclo de reloj.
* **Volcado de Estado (Register Dump):** Monitoreo dinámico en la terminal para facilitar la depuración.

---

##  Estructura del Proyecto

El emulador está organizado de la siguiente manera:

```text
emulator/
├── main.py       # Punto de entrada, programa de prueba y bucle interactivo.
├── cpu.py        # Unidad central de procesamiento (Registros, Fetch y Execute).
└── memory.py     # Componente de memoria para instrucciones y datos de prueba.
