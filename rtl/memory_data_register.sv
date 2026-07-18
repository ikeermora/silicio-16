`timescale 1ns/1ps 

module memory_data_register(
    input logic clk,
    input logic rst_n, 
    input logic mdr_write,
    input logic [15:0] mem_data,
    output logic [15:0] mdr_out
);

always_ff @(posedge clk or negedge rst_n) begin 
    if (!rst_n) begin 
        mdr_out <= 16'h0000;
    end else if (mdr_write) begin 
        mdr_out <= mem_data;
    end
end

endmodule