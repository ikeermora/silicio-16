`timescale 1ns/1ps

module pc_logic(

    input logic [1:0] pc_src,
    input logic pc_write_cond,
    input logic zero_flag,
    input logic pc_write,
    input logic [3:0] opcode,
    input logic [15:0] alu_result,
    input logic [15:0] branch_target,
    input logic[15:0] jump_target,
    output logic [15:0] next_pc,
    output logic pc_write_enable
);

    // Selección del próximo PC (Multiplexor)
    always_comb begin 
        case (pc_src) 
            2'b00: next_pc = alu_result;
            2'b01: next_pc = branch_target;
            2'b10: next_pc = jump_target;
            default: next_pc = 16'h0000;
        endcase
    end

    // Lógica combinacional para evaluar la bandera
    logic branch_taken;
    always_comb begin
        if (opcode == 4'b1100)       // BEQ: Salta si Zero es 1
            branch_taken = zero_flag;
        else if (opcode == 4'b1101)  // BNE: Salta si Zero es 0
            branch_taken = ~zero_flag;
        else
            branch_taken = 1'b0;
    end

    // Enable final: Escribe si es incondicional O si la condición de salto se cumple
    assign pc_write_enable = pc_write | (pc_write_cond & branch_taken);

endmodule
