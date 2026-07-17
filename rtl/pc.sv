module pc (
    input logic clk,
    input logic reset,
    input logic pc_write,
    input logic [15:0] next_pc,
    output logic [15:0] current_pc
);

always_ff @(posedge clk or posedge reset) begin 

    if (reset) begin 
        current_pc <= 16'h0000;
    end
    else if (pc_write) begin 
        current_pc <= next_pc;
    end

end

endmodule