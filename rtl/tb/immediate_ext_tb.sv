`timescale 1ns/1ps

module immediate_ext_tb;

    logic [15:0] instruction;
    logic[1:0] imm_src;
    logic [15:0] ext_imm;

    immediate_ext uut (

        .instruction(instruction),
        .imm_src(imm_src),
        .ext_imm(ext_imm)
    );

    initial begin 
        $dumpfile("immediate_ext_tb.vcd");
        $dumpvars(0, immediate_ext_tb);

        $display("Immediate Extension Simulation");

        // Case 1: LDI
        imm_src = 2'b00;
        instruction = {4'b1000, 3'b011, 8'b11010101, 1'b0};
        #10;
        $display("[LDI] Inst: %b | ImmSrc: %b | Result %h | ", instruction, imm_src, ext_imm);

        // Case 2: BEQ/BNE Positive Jump
        imm_src = 2'b01;
        instruction = {4'b1100, 3'b001, 3'b010, 6'b001010};
        #10;
        $display("[BRANCH+ ] Inst: %b | ImmSrc: %b | Result: %h |", instruction, imm_src, ext_imm);

        // Case 3: BEQ/BNE Neg Jump
        imm_src = 2'b01;
        instruction = {4'b1101, 3'b001, 3'b010, 6'b111011};
        #10;
        $display("[BRANCH- ] Inst: %b | ImmSrc: %b | Result: %h | ", instruction, imm_src, ext_imm);

        // Case 4: JMP
        imm_src = 2'b10;
        instruction = {4'b1110, 12'b1010_0101_1111};
        #10;
        $display("[JMP] Inst: %b | ImmSrc %b | Result %h | ", instruction, imm_src, ext_imm);

        $display("Simulation Finished");
        $finish;
    end
endmodule