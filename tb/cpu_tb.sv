`timescale 1ns/1ps


module cpu_tb;

    logic clk;
    logic rst_n;

    // Top level instancing
    cpu uut (
        .clk(clk),
        .rst_n(rst_n)
    );

    always #5 clk = ~clk;

    initial begin 
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0, cpu_tb);

        $display("Integration Test");

        clk = 0;
        rst_n = 0;
        $display("[TIME: %0t] Sistema en Reset...", $time);

        #20;
        rst_n = 1;
        $display("[TIME: %0t] Reset liberado. Arrancando procesador...", $time);

        #1000;

        $display("Simulation finished");

        $finish;
    end
    always @(posedge clk) begin
        if (rst_n) begin
            $display("Time: %0t | PC: %h | Inst: %h | State: %b", 
                     $time, 
                     uut.pc_current, 
                     uut.instruction, 
                     uut.control_unit_inst.current_state);
        end
    end

endmodule