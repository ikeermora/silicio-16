`timescale 1ns/1ps

module control_unit_tb;

     logic clk;
     logic rst_n;
     logic [3:0] opcode;

     //outputs
    logic       pc_write;
    logic       pc_write_cond;
    logic       ir_write;
    logic       reg_write;
    logic       mem_read;
    logic       mem_write;
    logic       alu_sel_a;
    logic [1:0] alu_sel_b;
    logic [3:0] alu_op;
    logic [1:0] pc_src;
    logic [1:0] mem_to_reg;
    logic       reg_dst;
    logic       imm_src;
    logic       halt_cpu;
    logic       alu_out_write;
    logic       mdr_write;
    logic       flags_write;

    control_unit uut (.*);

    always #5 clk = ~clk;

    initial begin 
        $dumpfile("control_unit_tb.vcd");
        $dumpvars(0,control_unit_tb);

        $display("Control Unit Simulation");

        clk = 0;
        rst_n = 0;
        opcode = 4'h0;

        #12;
        rst_n = 1;

        // Test 1: Add cycle

        opcode = 4'h1;

        // Fetch Cycle 1
        @(posedge clk);
        #1;
        $display("[ADD - FETCH] IRWrite: %b | PCWrite: %b | ALUOp: %h", ir_write, pc_write, alu_op);

        // Decode Cycle 2
        @(posedge clk);
        #1;
        $display("[ADD - DECODE] Esperando análisis del Opcode...");

        // Execute Cycle 3
        @(posedge clk);
        #1;
        $display("[ADD - EXEC] ALUOp: %h | ALUOutWrite: %b", alu_op, alu_out_write);

        // Write Back Cycle 4
        @(posedge clk);
        #1;
        $display("[ADD - WB] RegWrite: %b | MemToReg: %b", reg_write, mem_to_reg);

        // test 2: halt instruction
        opcode = 4'hF;

        // fetch
        @(posedge clk);

        // decode
        @(posedge clk);

        // execute / halt
        @(posedge clk);
        #1;
        $display("[HALT - EXEC] Halt_CPU: %b", halt_cpu);

        // halt trap
        @(posedge clk);
        #1;
        $display("[HALT - TRAPPED] Halt_CPU: %b", halt_cpu);

        $display("Control unit simulation finished");

        $finish;
    end
endmodule