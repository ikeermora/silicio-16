module register_file (
    input  logic        clk,
    input  logic        reset,
    input  logic        reg_write,
    input  logic [2:0]  read_reg1,
    input  logic [2:0]  read_reg2,
    input  logic [2:0]  write_reg,
    input  logic [15:0] write_data,
    output logic [15:0] read_data1,
    output logic [15:0] read_data2
);

    // Array of 8 registers, each 16 bits wide
    logic [15:0] registers [0:7];

    // ==========================================
    // ASYNCHRONOUS READ PORTS
    // ==========================================
    // These outputs update immediately whenever read_reg1 or read_reg2 changes.
    // They do not wait for a clock edge.
    assign read_data1 = registers[read_reg1];
    assign read_data2 = registers[read_reg2];

    // ==========================================
    // SYNCHRONOUS WRITE PORT & RESET
    // ==========================================
    // Writes and resets only happen on the rising edge of the clock.
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Clear all registers to 0
            for (int i = 0; i < 8; i++) begin
                registers[i] <= 16'b0;
            end
        end 
        else if (reg_write) begin
            // Write data to the specified register
            registers[write_reg] <= write_data;
        end
    end

endmodule
