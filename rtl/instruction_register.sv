module instruction_register (
    input logic clk,
    input logic reset,
    input logic ir_write,
    input logic [15:0] instruction_in,
    output logic [15:0] instruction_out
);

    always_ff @(posedge clk or posedge reset) begin 
        if (reset) begin 
            instruction_out <= 16'h0000;
        end
        else if (ir_write) begin 
            instruction_out <= instruction_in;
        end
    end

endmodule