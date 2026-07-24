`timescale  1ns/1ps

module data_memory(
    input logic clk,
    input logic mem_write,
    input logic mem_read,
    input logic [15:0] address,
    input logic [15:0] write_data,
    output logic [15:0] read_data
);

    // This is the array of RAM memory of 256 words of 16 bits
    logic [15:0] ram [0:255];

    assign read_data = (mem_read) ? ram[address[7:0]] : 16'h0000;

    always_ff @(posedge clk) begin 
        if (mem_write) begin 
            ram[address[7:0]] <= write_data;
        end
    end
    // Rii chisa 971 116 9111
endmodule