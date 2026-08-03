`timescale 1ns/1ps

module instruction_memory_tb;

    logic[15:0] pc;
    logic[15:0] instruction;

    instruction_memory uut (
        .pc(pc),
        .instruction(instruction)
    );

    initial begin 
        $dumpfile("instruction_memory_tb.vcd");
        $dumpvars(0, instruction_memory_tb);

        $display("Instruction Memory (ROM) simulation: ");

        // Manually load test instructions in the ROM
        // NOP position: 0x0000
        uut.rom[0] = 16'h0000;

        // Position 1: LDI R1, 0x25
        uut.rom[1] = 16'b1000_001_00100101_0;

        // Position 2: ADD R3, R1, R2
        uut.rom[2] = 16'b0001_011_001_010_000;

        //Position 3: JMP 0x00A5
        uut.rom[3] = 16'b1110_000010100101;

        // Combinational reading test
        pc = 16'h0000;
        #10;
        $display("[FETCH PC=0] Inst: %h", instruction);

        pc = 16'h0001;
        #10;
        $display("[FETCH PC=1] Inst: %h", instruction);

        pc = 16'h0002;
        #10;
        $display("[FETCH PC=2] Inst: %h", instruction);

        pc = 16'h0003;
        #10;
        $display("[FETCH PC=3] Inst: %h", instruction);
        
        $display("ROM simulation finished");
        $finish;
    end


endmodule