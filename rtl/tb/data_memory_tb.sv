`timescale 1ns/1ps

module data_memory_tb;

    logic clk;
    logic mem_write;
    logic mem_read;
    logic [15:0] address;
    logic [15:0] write_data;
    logic [15:0] read_data;

    data_memory uut (
        .clk(clk),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .address(address),
        .write_data(write_data),
        .read_data(read_data)
    );

    always #5 clk = ~clk;

    initial begin 
        $dumpfile("data_memory_tb.vcd");
        $dumpvars(0, data_memory_tb);

        $display("Simulating Data Memory");

        // initializing

        clk = 0;
        mem_write = 0;
        mem_read = 0;
        address = 16'h0000;
        write_data = 16'h0000;

        #10;

        // Case 1: Store -> Write 0xDreax in the direction 0x0004

        @(negedge clk);
        address = 16'h0004;
        write_data = 16'hDEAD;
        mem_write = 1;
        mem_read = 0;


        // Case 2: Store -> Write 0xBEEF in the direction 0x0008
        @(negedge clk);
        address = 16'h0008;
        write_data = 16'hBEEF;
        mem_write = 1;
        mem_read = 0;

        // Case 3:  Deactive Write and read (LOAD) in the direction 0x0004
        @(negedge clk);
        address = 16'h0004;
        mem_write = 0;
        mem_read = 1;

        #1;
        $display("[LOAD]  Address: %h | ReadData: %h", address, read_data);
        
        // Case 4: Read (LOAD) from address 0x0008
        @(negedge clk);
        address = 16'h0008;
        mem_read = 1;
        #1;
        $display("[LOAD]  Address: %h | ReadData: %h", address, read_data);

        // Case 5: Disable Reading
        @(negedge clk);
        mem_read = 0;

        #1;
        $display("[READ DIS] MemRead: %b | ReadData: %h ", mem_read, read_data);

        $display("Simulation Finished");
        $finish;
    end
endmodule