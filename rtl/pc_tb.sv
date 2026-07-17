`timescale 1ns/1ps

module pc_tb;

    logic clk;
    logic reset;
    logic pc_write;
    logic [15:0] next_pc;

    logic [15:0] current_pc;

    pc uut (
        .clk(clk),
        .reset(reset),
        .pc_write(pc_write),
        .next_pc(next_pc),
        .current_pc(current_pc)
    );

    always begin 
        clk = 0;
        #5;
        clk = 1;
        #5;
    end

    initial begin 
        $dumpfile("pc_sim.vcd");
        $dumpvars(0, pc_tb);
    end

    initial begin 
        $monitor("Time: %0t ns | Reset: %b | PCWrite: %b | Next_PC %h | Current_PC: %h", $time, reset, pc_write, next_pc, current_pc);

        $display("PC Simulation:");

        // Case 1: Initialization with Reset Activated
        reset = 1;
        pc_write = 0;
        next_pc = 16'h1000;
        #12;

        // Case 2: Free Reset
        reset = 0;
        #10;

        // Case 3: Enable PCWrite
        pc_write = 1;
        next_pc = 16'h0001;
        #10;

        // Case 4: Next execution cycle

        next_pc = 16'h0002;
        #10;
        next_pc = 16'h0003;
        #10;

        // Case 5: Unenable PCWrite
        pc_write = 0;
        next_pc = 16'h0AFA;
        #20;

        // Case 6: Reset in the middle of the execution
        reset = 1;
        #10;

        // Case 7: Final free reset
        reset = 0;
        #10;

        $display("Simulation ended");
        $finish;

    end




endmodule