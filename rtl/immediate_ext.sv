`timescale 1ns/1ps


module immediate_ext(
    input logic [15:0] instruction,
    input logic [1:0] imm_src,
    output logic [15:0] ext_imm
);

    always_comb begin 

        case (imm_src)
        2'b00: begin 
            ext_imm = {8'h00, instruction[8:1]};
        end

        2'b01: begin 
            ext_imm = {{10{instruction[5]}}, instruction[5:0]};
        end

        2'b10: begin 
            ext_imm = {4'h0, instruction[11:0]};
        end

        default: begin 
            ext_imm = 16'h0000;
        end
        endcase
    end
    

endmodule