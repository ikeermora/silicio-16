`timescale 1ns/1ps

module cpu_regression_tb;

    localparam logic [3:0] OP_NOP   = 4'h0;
    localparam logic [3:0] OP_ADD   = 4'h1;
    localparam logic [3:0] OP_SUB   = 4'h2;
    localparam logic [3:0] OP_AND   = 4'h3;
    localparam logic [3:0] OP_OR    = 4'h4;
    localparam logic [3:0] OP_XOR   = 4'h5;
    localparam logic [3:0] OP_SIM   = 4'h6;
    localparam logic [3:0] OP_MOV   = 4'h7;
    localparam logic [3:0] OP_LDI   = 4'h8;
    localparam logic [3:0] OP_LOAD  = 4'h9;
    localparam logic [3:0] OP_STORE = 4'hA;
    localparam logic [3:0] OP_CMP   = 4'hB;
    localparam logic [3:0] OP_BEQ   = 4'hC;
    localparam logic [3:0] OP_BNE   = 4'hD;
    localparam logic [3:0] OP_JMP   = 4'hE;
    localparam logic [3:0] OP_HALT  = 4'hF;

    logic clk;
    logic rst_n;
    integer checks;
    integer failures;

    cpu uut (
        .clk   (clk),
        .rst_n (rst_n)
    );

    always #5 clk = ~clk;

    function automatic logic [15:0] enc_r(
        input logic [3:0] op,
        input logic [2:0] rd,
        input logic [2:0] ra,
        input logic [2:0] rb
    );
        enc_r = {op, rd, ra, rb, 3'b000};
    endfunction

    function automatic logic [15:0] enc_ldi(
        input logic [2:0] rd,
        input logic [7:0] imm
    );
        enc_ldi = {OP_LDI, rd, imm, 1'b0};
    endfunction

    // CMP follows the intended two-source format:
    // [15:12] opcode, [11:9] rs, [8:6] rt, [5:0] unused.
    function automatic logic [15:0] enc_cmp(
        input logic [2:0] rs,
        input logic [2:0] rt
    );
        enc_cmp = {OP_CMP, rs, rt, 6'b000000};
    endfunction

    function automatic logic [15:0] enc_branch(
        input logic [3:0] op,
        input logic [2:0] rs,
        input logic [2:0] rt,
        input logic signed [5:0] offset
    );
        enc_branch = {op, rs, rt, offset};
    endfunction

    function automatic logic [15:0] enc_jmp(
        input logic [11:0] address
    );
        enc_jmp = {OP_JMP, address};
    endfunction

    task automatic begin_test(input string test_name);
        integer i;
        begin
            $display("\n[TEST] %s", test_name);
            rst_n = 1'b0;
            repeat (2) @(negedge clk);

            // instruction_memory and data_memory intentionally have no
            // runtime loading interface, so the integration test initializes
            // the instruction ROM hierarchically before releasing reset.
            // RAM is not cleared here: the memory test writes its address
            // before reading it, avoiding a second writer on its always_ff RAM.
            for (i = 0; i < 256; i = i + 1) begin
                uut.inst_mem_inst.rom[i] = 16'h0000;
            end
        end
    endtask

    task automatic run_until_halt(
        input string test_name,
        input integer max_cycles
    );
        integer cycles;
        begin
            rst_n = 1'b1;
            cycles = 0;

            while ((uut.halt_cpu !== 1'b1) && (cycles < max_cycles)) begin
                @(negedge clk);
                cycles = cycles + 1;
            end

            if (uut.halt_cpu !== 1'b1) begin
                failures = failures + 1;
                $error("[FAIL] %s: timeout after %0d cycles (PC=%h, IR=%h)",
                       test_name, max_cycles, uut.pc_current, uut.instruction);
            end else begin
                $display("[INFO] HALT reached in %0d cycles (PC=%h)",
                         cycles, uut.pc_current);
            end
        end
    endtask

    task automatic expect_reg(
        input integer index,
        input logic [15:0] expected,
        input string label
    );
        begin
            checks = checks + 1;
            if (uut.rf_inst.registers[index] !== expected) begin
                failures = failures + 1;
                $error("[FAIL] %s: R%0d expected %h, got %h",
                       label, index, expected, uut.rf_inst.registers[index]);
            end else begin
                $display("[PASS] %s: R%0d = %h", label, index, expected);
            end
        end
    endtask

    task automatic expect_mem(
        input integer address,
        input logic [15:0] expected,
        input string label
    );
        begin
            checks = checks + 1;
            if (uut.data_mem_inst.ram[address] !== expected) begin
                failures = failures + 1;
                $error("[FAIL] %s: RAM[%0d] expected %h, got %h",
                       label, address, expected,
                       uut.data_mem_inst.ram[address]);
            end else begin
                $display("[PASS] %s: RAM[%0d] = %h",
                         label, address, expected);
            end
        end
    endtask

    task automatic expect_flag(
        input logic expected,
        input string label
    );
        begin
            checks = checks + 1;
            if (uut.zero_flag_reg !== expected) begin
                failures = failures + 1;
                $error("[FAIL] %s: zero flag expected %b, got %b",
                       label, expected, uut.zero_flag_reg);
            end else begin
                $display("[PASS] %s: zero flag = %b", label, expected);
            end
        end
    endtask

    task automatic test_arithmetic_logic;
        begin
            begin_test("Arithmetic and bitwise operations");
            uut.inst_mem_inst.rom[0] = enc_ldi(3'd1, 8'd5);
            uut.inst_mem_inst.rom[1] = enc_ldi(3'd2, 8'd10);
            uut.inst_mem_inst.rom[2] = enc_r(OP_ADD, 3'd3, 3'd1, 3'd2);
            uut.inst_mem_inst.rom[3] = enc_r(OP_SUB, 3'd4, 3'd2, 3'd1);
            uut.inst_mem_inst.rom[4] = enc_r(OP_AND, 3'd5, 3'd1, 3'd2);
            uut.inst_mem_inst.rom[5] = enc_r(OP_OR,  3'd6, 3'd1, 3'd2);
            uut.inst_mem_inst.rom[6] = enc_r(OP_XOR, 3'd7, 3'd1, 3'd2);
            uut.inst_mem_inst.rom[7] = {OP_HALT, 12'h000};

            run_until_halt("Arithmetic and bitwise operations", 80);
            expect_reg(1, 16'h0005, "LDI");
            expect_reg(2, 16'h000A, "LDI");
            expect_reg(3, 16'h000F, "ADD");
            expect_reg(4, 16'h0005, "SUB");
            expect_reg(5, 16'h0000, "AND");
            expect_reg(6, 16'h000F, "OR");
            expect_reg(7, 16'h000F, "XOR");
        end
    endtask

    task automatic test_sim_mov;
        begin
            begin_test("SIM and MOV");
            uut.inst_mem_inst.rom[0] = enc_ldi(3'd1, 8'h05);
            uut.inst_mem_inst.rom[1] = enc_ldi(3'd2, 8'h0A);
            uut.inst_mem_inst.rom[2] = enc_r(OP_SIM, 3'd3, 3'd1, 3'd2);
            uut.inst_mem_inst.rom[3] = enc_r(OP_MOV, 3'd4, 3'd3, 3'd0);
            uut.inst_mem_inst.rom[4] = {OP_HALT, 12'h000};

            run_until_halt("SIM and MOV", 60);
            expect_reg(3, 16'd12, "SIM similarity count");
            expect_reg(4, 16'd12, "MOV");
        end
    endtask

    task automatic test_memory;
        begin
            begin_test("STORE and LOAD");
            uut.inst_mem_inst.rom[0] = enc_ldi(3'd1, 8'h20);
            uut.inst_mem_inst.rom[1] = enc_ldi(3'd2, 8'h5A);
            uut.inst_mem_inst.rom[2] = enc_r(OP_STORE, 3'd0, 3'd1, 3'd2);
            uut.inst_mem_inst.rom[3] = enc_r(OP_LOAD,  3'd3, 3'd1, 3'd0);
            uut.inst_mem_inst.rom[4] = {OP_HALT, 12'h000};

            run_until_halt("STORE and LOAD", 70);
            expect_mem(8'h20, 16'h005A, "STORE");
            expect_reg(3, 16'h005A, "LOAD");
        end
    endtask

    task automatic test_beq_taken;
        begin
            begin_test("CMP sources and BEQ taken");
            uut.inst_mem_inst.rom[0] = enc_ldi(3'd1, 8'h07);
            uut.inst_mem_inst.rom[1] = enc_ldi(3'd2, 8'h07);
            uut.inst_mem_inst.rom[2] = enc_cmp(3'd1, 3'd2);
            uut.inst_mem_inst.rom[3] = enc_branch(OP_BEQ, 3'd1, 3'd2, 6'sd1);
            uut.inst_mem_inst.rom[4] = enc_ldi(3'd7, 8'hEE); // must be skipped
            uut.inst_mem_inst.rom[5] = enc_ldi(3'd3, 8'hA1);
            uut.inst_mem_inst.rom[6] = {OP_HALT, 12'h000};

            run_until_halt("CMP sources and BEQ taken", 80);
            expect_flag(1'b1, "CMP equal");
            expect_reg(7, 16'h0000, "BEQ skipped trap");
            expect_reg(3, 16'h00A1, "BEQ target executed");
        end
    endtask

    task automatic test_beq_not_taken;
        begin
            begin_test("BEQ not taken");
            uut.inst_mem_inst.rom[0] = enc_ldi(3'd1, 8'h07);
            uut.inst_mem_inst.rom[1] = enc_ldi(3'd2, 8'h08);
            uut.inst_mem_inst.rom[2] = enc_cmp(3'd1, 3'd2);
            uut.inst_mem_inst.rom[3] = enc_branch(OP_BEQ, 3'd1, 3'd2, 6'sd1);
            uut.inst_mem_inst.rom[4] = enc_ldi(3'd4, 8'hB2); // must execute
            uut.inst_mem_inst.rom[5] = {OP_HALT, 12'h000};

            run_until_halt("BEQ not taken", 70);
            expect_flag(1'b0, "CMP different");
            expect_reg(4, 16'h00B2, "BEQ fall-through executed");
        end
    endtask

    task automatic test_bne_taken;
        begin
            begin_test("BNE taken");
            uut.inst_mem_inst.rom[0] = enc_ldi(3'd1, 8'h07);
            uut.inst_mem_inst.rom[1] = enc_ldi(3'd2, 8'h08);
            uut.inst_mem_inst.rom[2] = enc_cmp(3'd1, 3'd2);
            uut.inst_mem_inst.rom[3] = enc_branch(OP_BNE, 3'd1, 3'd2, 6'sd1);
            uut.inst_mem_inst.rom[4] = enc_ldi(3'd7, 8'hDD); // must be skipped
            uut.inst_mem_inst.rom[5] = enc_ldi(3'd5, 8'hC3);
            uut.inst_mem_inst.rom[6] = {OP_HALT, 12'h000};

            run_until_halt("BNE taken", 80);
            expect_flag(1'b0, "CMP different");
            expect_reg(7, 16'h0000, "BNE skipped trap");
            expect_reg(5, 16'h00C3, "BNE target executed");
        end
    endtask

    task automatic test_bne_not_taken;
        begin
            begin_test("BNE not taken");
            uut.inst_mem_inst.rom[0] = enc_ldi(3'd1, 8'h07);
            uut.inst_mem_inst.rom[1] = enc_ldi(3'd2, 8'h07);
            uut.inst_mem_inst.rom[2] = enc_cmp(3'd1, 3'd2);
            uut.inst_mem_inst.rom[3] = enc_branch(OP_BNE, 3'd1, 3'd2, 6'sd1);
            uut.inst_mem_inst.rom[4] = enc_ldi(3'd6, 8'hD4); // must execute
            uut.inst_mem_inst.rom[5] = {OP_HALT, 12'h000};

            run_until_halt("BNE not taken", 70);
            expect_flag(1'b1, "CMP equal");
            expect_reg(6, 16'h00D4, "BNE fall-through executed");
        end
    endtask

    task automatic test_negative_branch;
        begin
            begin_test("Negative branch offset");
            uut.inst_mem_inst.rom[0] = enc_ldi(3'd1, 8'h01);
            uut.inst_mem_inst.rom[1] = enc_ldi(3'd2, 8'h02);
            uut.inst_mem_inst.rom[2] = enc_cmp(3'd1, 3'd2); // not equal
            uut.inst_mem_inst.rom[3] = enc_jmp(12'd6);
            uut.inst_mem_inst.rom[4] = enc_ldi(3'd2, 8'h01);
            uut.inst_mem_inst.rom[5] = enc_cmp(3'd1, 3'd2); // now equal
            // At execution, PC=7. Offset -3 sends it back to address 4.
            uut.inst_mem_inst.rom[6] = enc_branch(OP_BNE, 3'd1, 3'd2, -6'sd3);
            uut.inst_mem_inst.rom[7] = enc_ldi(3'd3, 8'hAA);
            uut.inst_mem_inst.rom[8] = {OP_HALT, 12'h000};

            run_until_halt("Negative branch offset", 130);
            expect_reg(2, 16'h0001, "Backward branch target executed");
            expect_reg(3, 16'h00AA, "Loop exited after flag update");
            expect_flag(1'b1, "Second CMP equal");
        end
    endtask

    task automatic test_nop_jmp_halt;
        logic [15:0] frozen_pc;
        logic [15:0] frozen_r1;
        integer i;
        begin
            begin_test("NOP, JMP and HALT stability");
            uut.inst_mem_inst.rom[0] = {OP_NOP, 12'h000};
            uut.inst_mem_inst.rom[1] = enc_ldi(3'd1, 8'h11);
            uut.inst_mem_inst.rom[2] = enc_jmp(12'd5);
            uut.inst_mem_inst.rom[3] = enc_ldi(3'd7, 8'hEE); // must be skipped
            uut.inst_mem_inst.rom[4] = enc_ldi(3'd7, 8'hDD); // must be skipped
            uut.inst_mem_inst.rom[5] = {OP_HALT, 12'h000};

            run_until_halt("NOP, JMP and HALT stability", 70);
            expect_reg(1, 16'h0011, "NOP preserved flow");
            expect_reg(7, 16'h0000, "JMP skipped traps");

            frozen_pc = uut.pc_current;
            frozen_r1 = uut.rf_inst.registers[1];
            repeat (5) @(negedge clk);

            checks = checks + 4;
            if (uut.pc_current !== frozen_pc) begin
                failures = failures + 1;
                $error("[FAIL] HALT changed PC: expected %h, got %h",
                       frozen_pc, uut.pc_current);
            end
            if (uut.rf_inst.registers[1] !== frozen_r1) begin
                failures = failures + 1;
                $error("[FAIL] HALT changed R1: expected %h, got %h",
                       frozen_r1, uut.rf_inst.registers[1]);
            end
            if (uut.pc_write_enable !== 1'b0) begin
                failures = failures + 1;
                $error("[FAIL] HALT left pc_write_enable asserted");
            end
            if ((uut.reg_write !== 1'b0) || (uut.mem_write !== 1'b0)) begin
                failures = failures + 1;
                $error("[FAIL] HALT left a state-changing write asserted");
            end

            if ((uut.pc_current === frozen_pc) &&
                (uut.rf_inst.registers[1] === frozen_r1) &&
                (uut.pc_write_enable === 1'b0) &&
                (uut.reg_write === 1'b0) &&
                (uut.mem_write === 1'b0)) begin
                $display("[PASS] HALT held architectural state for 5 cycles");
            end
        end
    endtask

    initial begin
        $dumpfile("cpu_regression_tb.vcd");
        $dumpvars(0, cpu_regression_tb);

        clk = 1'b0;
        rst_n = 1'b0;
        checks = 0;
        failures = 0;

        // Let instruction_memory's own initial block finish first. Each test
        // then replaces its ROM contents before reset is released.
        #1;

        test_arithmetic_logic();
        test_sim_mov();
        test_memory();
        test_beq_taken();
        test_beq_not_taken();
        test_bne_taken();
        test_bne_not_taken();
        test_negative_branch();
        test_nop_jmp_halt();

        $display("\n========================================");
        $display("Silicio-16 regression: %0d checks, %0d failures",
                 checks, failures);
        $display("========================================");

        if (failures == 0) begin
            $display("[PASS] ALL SILICIO-16 RTL TESTS PASSED");
            $finish;
        end else begin
            $fatal(1, "[FAIL] SILICIO-16 REGRESSION FAILED");
        end
    end

endmodule
