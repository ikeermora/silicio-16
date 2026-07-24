`timescale 1ns/1ps

module pc_logic(

    input logic [1:0] pc_src,
    input logic pc_write_cond,
    input logic zero_flag,
    input logic [15:0] alu_result,
    input logic [15:0] branch_target,
    input logic[15:0] jump_target,
    output logic [15:0] next_pc,
    output logic pc_write_enable
);

    always_comb begin 
        case (pc_src) 
            2'b00: next_pc = alu_result;
            2'b01: next_pc = branch_target;
            2'b10: next_pc = jump_target;
            default: next_pc = 16'h0000;
        endcase
    end

    //Conditional enabling: Allows to write in the PC if PCWrite Cond is activated
    assign pc_write_enable = pc_write_cond ? zero_flag : 1'b0;



endmodule