`timescale 1ns/1ps

module pc_logic_tb;

    logic [1:0] pc_src;
    logic pc_write_cond;
    logic zero_flag;
    logic [15:0] alu_result;
    logic [15:0] branch_target;
    logic [15:0] jump_target;
    logic [15:0] next_pc;
    logic pc_write_enable;

    pc_logic uut(
        .pc_src(pc_src),
        .pc_write_cond(pc_write_cond),
        .zero_flag(zero_flag),
        .alu_result(alu_result),
        .branch_target(branch_target),
        .jump_target(jump_target),
        .next_pc(next_pc),
        .pc_write_enable(pc_write_enable)
    );

    initial begin 
        $dumpfile("pc_logic_tb.vcd");
        $dumpvars(0, pc_logic_tb);

        $display("Simulation PC Logic");

        // Initialization
        alu_result    = 16'h0005; // Dirección secuencial (PC + 1)
        branch_target = 16'h0020; // Dirección por Branch
        jump_target   = 16'h00A5; // Dirección por Jump
        pc_write_cond = 0;
        zero_flag     = 0;

        // --- CASO 1: Selección Normal (PCSrc = 00 -> ALUResult) ---
        pc_src = 2'b00;
        #10;
        $display("[NORMAL] PCSrc: %b | NextPC: %h (Esperado: 0005)", pc_src, next_pc);

        // --- CASO 2: Selección Branch (PCSrc = 01 -> Branch Target) ---
        pc_src = 2'b01;
        #10;
        $display("[BRANCH] PCSrc: %b | NextPC: %h (Esperado: 0020)", pc_src, next_pc);

        // --- CASO 3: Selección Jump (PCSrc = 10 -> Jump Target) ---
        pc_src = 2'b10;
        #10;
        $display("[JUMP]   PCSrc: %b | NextPC: %h (Esperado: 00A5)", pc_src, next_pc);

        // --- CASO 4: Prueba de Condición Branch Tomada (Zero = 1) ---
        pc_write_cond = 1;
        zero_flag     = 1;
        #10;
        $display("[COND TAKEN] PCWriteCond: %b | Zero: %b | WriteEnable: %b (Esperado: 1)", 
                 pc_write_cond, zero_flag, pc_write_enable);

        // --- CASO 5: Prueba de Condición Branch No Tomada (Zero = 0) ---
        pc_write_cond = 1;
        zero_flag     = 0;
        #10;
        $display("[COND NOT TAKEN] PCWriteCond: %b | Zero: %b | WriteEnable: %b (Esperado: 0)", 
                 pc_write_cond, zero_flag, pc_write_enable);

        $display("=========================================================");
        $display("        Simulación de PC Logic Finalizada               ");
        $display("=========================================================");
        $finish;
    end
endmodule