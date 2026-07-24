`timescale 1ns/1ps

module instruction_memory(

    input logic[15:0] pc,
    output logic [15:0] instruction
);
    logic [15:0] rom [0:255];
    initial begin 
        for (int i = 0; i < 256; i++) begin 
            rom[i] = 16'h0000;
        end
   

     $readmemh("program.hex", rom);
    end

    assign instruction = rom[pc[7:0]];


endmodule


