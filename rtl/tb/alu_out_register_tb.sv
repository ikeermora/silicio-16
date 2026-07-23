`timescale 1ns/1ps

module alu_out_register_tb;

    logic clk;
    logic rst_n;
    logic alu_out_write;
    logic [15:0] alu_result;
    logic [15:0] alu_out;

    alu_out_register uut(

        .clk(clk),
        .rst_n(rst_n),
        .alu_out_write(alu_out_write),
        .alu_result(alu_result),
        .alu_out(alu_out)
    );

    always #5 clk = ~clk;

    initial begin 
        $dumpfile ("alu_out_register_tb.vcd");
        $dumpvars(0, alu_out_register_tb);
        $display("ALU Out Register Simulation"); 

        clk = 0;
        rst_n = 0;
        alu_out_write = 0; 
        alu_result = 16'h0000;

        #12;
        rst_n = 1;
        $display("[RESET] alut_out: %h", alu_out);

        // Case 2:
        @(negedge clk);
        alu_result = 16'h55AA;
        alu_out_write = 1;


        @(posedge clk);
        #1;
        $display("[WRITE EN] alu_result: %h | alu_out_write: %b | alu_out: %h |", alu_result, alu_out_write, alu_out);

        // Case 3: 

        @(negedge clk);
        alu_result = 16'hFFFF;
        alu_out_write = 0;

        @(posedge clk);
        #1;
        $display("[WRITE DIS] alu_result: %h | alu_out_write: %b | alu_out: %h ", alu_result, alu_out_write, alu_out);

        // Case 4:
        @(negedge clk);
        alu_result = 16'h0A2C;
        alu_out_write = 1;

        @(posedge clk);
        #1;
        $display("[WRITE EN2] alu_result: %h | alu_out_write: %b | alu_out: %h |", alu_result, alu_out_write, alu_out);

        $display("ALU Out Register Simulation Finished");
        $finish;
    end
endmodule