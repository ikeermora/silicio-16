`timescale 1ns/1ps

module fibonacci_tb;

    logic clk;
    logic rst_n;
    logic [15:0] expected [0:9];
    integer cycles;
    integer failures;
    integer i;

    cpu uut (
        .clk   (clk),
        .rst_n (rst_n)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("fibonacci_tb.vcd");
        $dumpvars(0, fibonacci_tb);

        expected[0] = 16'd0;
        expected[1] = 16'd1;
        expected[2] = 16'd1;
        expected[3] = 16'd2;
        expected[4] = 16'd3;
        expected[5] = 16'd5;
        expected[6] = 16'd8;
        expected[7] = 16'd13;
        expected[8] = 16'd21;
        expected[9] = 16'd34;

        clk = 1'b0;
        rst_n = 1'b0;
        failures = 0;

        // instruction_memory loads program.hex at time zero. Override only
        // the used ROM range with the Fibonacci demo before releasing reset.
        #1;
        $readmemh("fibonacci.hex", uut.inst_mem_inst.rom, 0, 14);

        repeat (2) @(negedge clk);
        rst_n = 1'b1;

        cycles = 0;
        while ((uut.halt_cpu !== 1'b1) && (cycles < 400)) begin
            @(negedge clk);
            cycles = cycles + 1;
        end

        if (uut.halt_cpu !== 1'b1) begin
            $fatal(1,
                   "[FAIL] Fibonacci timeout (PC=%h, IR=%h)",
                   uut.pc_current, uut.instruction);
        end

        $display("\nSilicio-16 Fibonacci demo");
        $display("HALT reached in %0d cycles", cycles);
        $display("RAM results:");

        for (i = 0; i < 10; i = i + 1) begin
            if (uut.data_mem_inst.ram[8'h20 + i] !== expected[i]) begin
                failures = failures + 1;
                $error("[FAIL] RAM[%02h] expected %0d, got %0d (%h)",
                       8'h20 + i,
                       expected[i],
                       uut.data_mem_inst.ram[8'h20 + i],
                       uut.data_mem_inst.ram[8'h20 + i]);
            end else begin
                $display("[PASS] RAM[%02h] = %0d",
                         8'h20 + i, expected[i]);
            end
        end

        if (uut.rf_inst.registers[1] !== 16'd55) begin
            failures = failures + 1;
            $error("[FAIL] Final R1 expected 55, got %0d",
                   uut.rf_inst.registers[1]);
        end

        if (uut.rf_inst.registers[2] !== 16'd89) begin
            failures = failures + 1;
            $error("[FAIL] Final R2 expected 89, got %0d",
                   uut.rf_inst.registers[2]);
        end

        if (uut.rf_inst.registers[4] !== 16'h002A) begin
            failures = failures + 1;
            $error("[FAIL] Final RAM pointer expected 002a, got %h",
                   uut.rf_inst.registers[4]);
        end

        if (uut.rf_inst.registers[6] !== 16'h0000) begin
            failures = failures + 1;
            $error("[FAIL] Final counter expected 0000, got %h",
                   uut.rf_inst.registers[6]);
        end

        if (failures == 0) begin
            $display("Final state: R1=55, R2=89, pointer=002a, counter=0");
            $display("[PASS] SILICIO-16 FIBONACCI DEMO PASSED");
            $finish;
        end else begin
            $fatal(1, "[FAIL] FIBONACCI DEMO FAILED WITH %0d ERRORS",
                   failures);
        end
    end

endmodule
