`timescale 1ns/1ps

module alu_out_register (

    input logic clk,
    input logic rst_n, 
    input logic alu_out_write,
    input logic [15:0] alu_result,
    output logic [15:0] alu_out
);


    always_ff @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin 
            alu_out <= 16'h0000;
        
        end else if (alu_out_write) begin 
            alu_out <= alu_result;
        end
    end

endmodule