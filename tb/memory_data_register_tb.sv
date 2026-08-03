`timescale 1ns/1ps

module memory_data_register_tb;

    logic clk;
    logic rst_n;
    logic mdr_write;
    logic [15:0] mem_data;
    logic [15:0] mdr_out;

    memory_data_register uut (
        .clk(clk),
        .rst_n(rst_n),
        .mdr_write(mdr_write),
        .mem_data(mem_data),
        .mdr_out(mdr_out)
    );

    always #5 clk = ~clk;

    initial begin 
        $dumpfile("memory_data_register_tb.vcd");
        $dumpvars(0, memory_data_register_tb);

        $display("Memory Data Register Simulation");

        // initialazing signals
        clk = 0;
        rst_n = 0;
        mdr_write = 0;
        mem_data = 16'h0000;

        // Case 1: Async Reset

        #12;
        rst_n = 1;
        $display("[RESET] mdr_out: %h", mdr_out);

        // Case 2: Writing Enabled

        @(negedge clk);
        mem_data = 16'hABCD;
        mdr_write = 1;

        @(posedge clk);
        #1;
        $display("[WRITE EN] mem_data: %h | mdr_write: %b | mdr_out: %h |", mem_data, mdr_write, mdr_out);

        // Case 3 Writing test with enabling deactivated

        @(negedge clk);
        mem_data = 16'hFFFF;
        mdr_write = 0;

        @(posedge clk);
        #1;
        $display("[WRITE DIS] mem_data: %h | mdr_write: %b | mdr_out: %h |", mem_data, mdr_write, mdr_out);

        // Case 4: Writing enablign reactived

        @(negedge clk);
        mem_data = 16'h1234;
        mdr_write = 1;

        @(posedge clk);
        #1;
        $display("[WRITE EN2] mem_data: %h | mdr_write: %b | mdr_out: %h", mem_data, mdr_write, mdr_out);

        $display("MDR Simulation Finished");
        $finish;

    end

endmodule