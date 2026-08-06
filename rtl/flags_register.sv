module flags_register (
    input logic clk,
    input logic rst_n,
    input logic flags_write, // Esta señal la controlas desde tu FSM
    input logic zero_in,
    output logic zero_out
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) zero_out <= 1'b0;
        else if (flags_write) zero_out <= zero_in;
    end
endmodule