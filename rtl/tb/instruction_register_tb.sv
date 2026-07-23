`timescale 1ns/1ps

module instruction_register_tb;

    logic clk;
    logic reset;
    logic ir_write;
    logic [15:0] instruction_in;
    logic [15:0] instruction_out;


    instruction_register uut (
        .clk(clk),
        .reset(reset),
        .ir_write(ir_write),
        .instruction_in(instruction_in),
        .instruction_out(instruction_out)
    );

    always begin 
        clk = 0;
        #5;
        clk = 1;
        #5;
    end

    initial begin 
        $monitor("Time: %0t ns | Reset: %b | IRWrite: %b | In: %h | Out: %h", $time, reset, ir_write, instruction_in, instruction_out);
    

    $display("Instruction Register Simulation:");
    

    // Case 1: Initial Reset
    reset = 1;
    ir_write = 0;
    instruction_in = 16'h0000;
    #12;

    // Case 2: Free Reset

    reset = 0;
    #10;

    // Case 3: Load first instruction

    ir_write = 1;
    instruction_in = 16'h1A2B;
    #10;

    // Case 4: Unenable write and change entry
    ir_write = 0;
    instruction_in = 16'hFFFF;
    #20;

    // Case 5: Load second instruction

    ir_write = 1;
    instruction_in = 16'h6C7D;
    #10;

    // Case 6: Reset halfway thru
    reset = 1;
    #10;

    reset = 0;
    #10;

    $display("Simulation ended");
    $finish;

    end

endmodule