module tb_register_file;

    // Testbench signals
    logic        clk;
    logic        reset;
    logic        reg_write;
    logic [2:0]  read_reg1, read_reg2, write_reg;
    logic [15:0] write_data;
    logic [15:0] read_data1, read_data2;

    // Instantiate the Device Under Test (DUT)
    register_file dut (
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // Clock generation (10 time units period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Stimulus process
    initial begin
        $display("=== Starting Register File Testbench ===");

        // 1. Initial State & Reset Test
        reset = 1; reg_write = 0;
        read_reg1 = 3'd0; read_reg2 = 3'd7;
        write_reg = 3'd0; write_data = 16'h0000;
        
        #10; // Wait for a clock cycle
        reset = 0;
        $display("After Reset -> R0: %h, R7: %h (Expected: 0000, 0000)", read_data1, read_data2);

        // 2. Synchronous Write Test
        @(posedge clk);
        reg_write = 1;
        write_reg = 3'd3;      // Write to R3
        write_data = 16'hAAAA; // Data: AAAA
        
        @(posedge clk);
        reg_write = 1;
        write_reg = 3'd5;      // Write to R5
        write_data = 16'h5555; // Data: 5555
        
        // 3. Asynchronous Dual Read Test
        @(negedge clk); // Check between clock edges
        reg_write = 0;
        read_reg1 = 3'd3; // Read R3
        read_reg2 = 3'd5; // Read R5
        #1;
        $display("Dual Read   -> R3: %h, R5: %h (Expected: aaaa, 5555)", read_data1, read_data2);

        // 4. Write Disable Test (reg_write = 0)
        @(posedge clk);
        reg_write = 0;
        write_reg = 3'd3;      // Attempt to overwrite R3
        write_data = 16'hFFFF; 
        
        @(negedge clk);
        read_reg1 = 3'd3;
        #1;
        $display("No Write    -> R3: %h (Expected: aaaa - because reg_write was 0)", read_data1);

        // 5. Final Reset Check
        @(posedge clk);
        reset = 1;
        
        @(negedge clk);
        #1;
        $display("Final Reset -> R3: %h, R5: %h (Expected: 0000, 0000)", read_data1, read_data2);

        $display("=== Testbench Complete ===");
        $finish;
    end

endmodule
