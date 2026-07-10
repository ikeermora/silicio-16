module alu (
    input logic [15:0] a, 
    input logic [15:0] b,
    input logic [3:0] alu_op,
    output logic [15:0] alu_result,
    output logic zero
);

localparam [3:0] OP_ADD = 4'b0001;
localparam [3:0] OP_SUB = 4'b0010;
localparam [3:0] OP_AND = 4'b0011;
localparam [3:0] OP_OR = 4'b0100;
localparam [3:0] OP_XOR = 4'b0101;
localparam [3:0] OP_SIM = 4'b0110;
localparam [3:0] OP_MOV = 4'b0111;
localparam [3:0] OP_LDI = 4'b1000;
localparam [3:0] OP_LOAD = 4'b1001;
localparam [3:0] OP_STORE = 4'b1010;
localparam [3:0] OP_CMP = 4'b1011;
localparam [3:0] OP_BEQ = 4'b1100;
localparam [3:0] OP_BNE = 4'b1101;
localparam [3:0] OP_JMP = 4'b1110;
localparam [3:0] OP_HALT = 4'b1111;
localparam [3:0] OP_NOP = 4'b0000;

always_comb begin
    alu_result = 16'h0000;

    case (alu_op)
        OP_ADD: begin 
            alu_result = a + b;
    end
        OP_SUB: begin
            alu_result = a - b;
        end

        OP_OR: begin 
            alu_result = a | b;
        end

        OP_AND: begin 
            alu_result = a & b;
        end 

        OP_XOR: begin 
            alu_result = a ^ b;
        end
        
        OP_SIM: begin 
            OP_SIM: begin
                alu_result = 16'd0;
                for (int i = 0; i < 16; i++) begin
                if (a[i] == b[i]) begin
                    alu_result = alu_result + 1;
                 end
                end
            end
        end

        OP_MOV: begin 
            alu_result = a;
        end

        OP_LDI: begin 
            alu_result = b;
        end
        
        OP_LOAD: begin 
            alu_result = a;
        end

        OP_STORE: begin 
            alu_result = a;
        end

        OP_CMP: begin 
            alu_result = a - b;
        end

        OP_BEQ: begin 
            alu_result = a - b;
        end

        OP_BNE: begin 
            alu_result = a - b;
        end

        OP_JMP: begin 
            alu_result = a;
        end

        OP_NOP: begin 
            alu_result = 16'h0000;
        end

        OP_HALT: begin 
            alu_result = 16'h0000;
        end

    default: begin
        alu_result = 16'h0000;
    end
    endcase
end
assign zero = (alu_result == 16'h0000);
endmodule
