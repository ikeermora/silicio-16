`timescale 1ns/1ps

module control_unit(
    input logic clk,
    input logic rst_n,
    input logic [3:0] opcode,

    output logic pc_write,
    output logic pc_write_cond,
    output logic ir_write,
    output logic reg_write,
    output logic mem_read,
    output logic mem_write, 
    output logic alu_sel_a,
    output logic [1:0] alu_sel_b,
    output logic [3:0] alu_op,
    output logic [1:0] pc_src,
    output logic [1:0] mem_to_reg,
    output logic reg_dst,
    output logic imm_src,
    output logic halt_cpu,
    output logic alu_out_write,
    output logic mdr_write,
    output logic flags_write
);

    // Opcodes - Refer to Opcode table in Docs if necessary
    localparam OP_NOP   = 4'h0;
    localparam OP_ADD   = 4'h1;
    localparam OP_SUB   = 4'h2;
    localparam OP_AND   = 4'h3;
    localparam OP_OR    = 4'h4;
    localparam OP_XOR   = 4'h5;
    localparam OP_SIM   = 4'h6;
    localparam OP_MOV   = 4'h7;
    localparam OP_LDI   = 4'h8;
    localparam OP_LOAD  = 4'h9;
    localparam OP_STORE = 4'hA;
    localparam OP_CMP   = 4'hB;
    localparam OP_BEQ   = 4'hC;
    localparam OP_BNE   = 4'hD;
    localparam OP_JMP   = 4'hE;
    localparam OP_HALT  = 4'hF;

    // FSM states
    typedef enum logic [4:0] {  
        S_FETCH,
        S_DECODE,
        S_EXEC_R,
        S_WB_R,
        S_WB_LDI,
        S_WB_MOV,
        S_EXEC_MEM,
        S_MEM_READ,
        S_WB_LOAD,
        S_MEM_WRITE,
        S_EXEC_CMP,
        S_EXEC_BRANCH,
        S_EXEC_JMP,
        S_EXEC_NOP,
        S_HALT
    } state_t;

    state_t current_state, next_state;

    // 1. Secuential State of Register
    always_ff @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin 
            current_state <= S_FETCH;
        end else  begin 
            current_state <= next_state;
        end 
    end

    // 2. Logic of next state (Combinational)

    always_comb begin 
        next_state = current_state;

        case (current_state)
            S_FETCH: next_state = S_DECODE;
            S_DECODE: begin 
                case(opcode)
                    OP_ADD, OP_SUB, OP_AND, OP_OR, OP_XOR, OP_SIM: next_state = S_EXEC_R;
                    OP_LDI: next_state = S_WB_LDI;
                    OP_MOV: next_state = S_WB_MOV;
                    OP_LOAD, OP_STORE: next_state = S_EXEC_MEM;
                    OP_CMP: next_state = S_EXEC_CMP;
                    OP_BEQ, OP_BNE: next_state = S_EXEC_BRANCH;
                    OP_JMP: next_state = S_EXEC_JMP;
                    OP_NOP: next_state = S_EXEC_NOP;
                    OP_HALT: next_state = S_HALT;
                    default : next_state = S_FETCH;
                endcase
            end

            // 3rd Cycle, transitions from execute
            S_EXEC_R: next_state = S_WB_R;

            S_EXEC_MEM: begin
                if (opcode == OP_LOAD)
                    next_state = S_MEM_READ;
                else
                    next_state = S_MEM_WRITE;
            end

            S_EXEC_CMP:    next_state = S_FETCH;
            S_EXEC_BRANCH: next_state = S_FETCH;
            S_EXEC_JMP:    next_state = S_FETCH;
            S_EXEC_NOP:    next_state = S_FETCH;

            // Transitions from Memory, 4th cycle
            S_MEM_READ: next_state = S_WB_LOAD;
            S_MEM_WRITE: next_state = S_FETCH;

            // Transitions from Write Back (Last cycles)

            S_WB_R: next_state = S_FETCH;
            S_WB_LDI: next_state = S_FETCH;
            S_WB_MOV: next_state = S_FETCH;
            S_WB_LOAD: next_state = S_FETCH;

            // HALT State
            S_HALT: next_state = S_HALT;
            default: next_state = S_FETCH;
        endcase
    end

    // 3. Logic for the control signals output 
    always_comb begin 
        // Inicialización de todas las señales a 0 por seguridad
        pc_write      = 0;
        pc_write_cond = 0;
        ir_write      = 0;
        reg_write     = 0;
        mem_read      = 0;
        mem_write     = 0;
        alu_sel_a     = 0;
        alu_sel_b     = 2'b00;
        alu_op        = 4'h0;
        pc_src        = 2'b00;
        mem_to_reg    = 2'b00;
        reg_dst       = 0;
        imm_src       = 0;
        halt_cpu      = 0;
        alu_out_write = 0;
        mdr_write     = 0;
        flags_write   = 0;

        case (current_state) 
            S_FETCH: begin 
                ir_write = 1;
                pc_write = 1;
                alu_sel_a = 0;
                alu_sel_b = 2'b01;
                alu_op = OP_ADD;
                pc_src = 2'b00;
            end

        S_DECODE: begin 
            // Los registros A y B leen del Register File automáticamente.
            // En este ciclo la Unidad de Control analiza el Opcode.
        end

        S_EXEC_R: begin 
            alu_sel_a = 1;
            alu_sel_b = 2'b00;
            alu_op = opcode;
            alu_out_write = 1;
        end

        S_WB_R: begin
            reg_write = 1;
            reg_dst = 0;
            mem_to_reg = 2'b00;
        end
        S_WB_LDI: begin 
            reg_write = 1;
            reg_dst = 0;
            mem_to_reg = 2'b10;
        end
        S_WB_MOV: begin 
            reg_write = 1;
            reg_dst = 0;
            mem_to_reg = 2'b11;
        end
        S_EXEC_MEM: begin 
            alu_sel_a = 1;
            alu_sel_b = 2'b00;
            alu_op = opcode;
            alu_out_write = 1;
        end
        S_MEM_READ: begin 
            mem_read = 1;
            mdr_write = 1;
        end
        S_WB_LOAD: begin 
            reg_write = 1;
            reg_dst = 0;
            mem_to_reg = 2'b01;
        end

        S_MEM_WRITE: begin 
            mem_write = 1;
        end
        S_EXEC_CMP: begin 
            alu_sel_a = 1;
            alu_sel_b = 2'b00;
            alu_op = opcode;
            flags_write = 1;
        end

        S_EXEC_BRANCH: begin 
            pc_write_cond = 1;
            pc_src = 2'b01;
            alu_sel_a = 1;
            alu_sel_b = 2'b00;
            alu_op = opcode;
        end
        
        S_EXEC_JMP: begin 
            pc_write = 1;
            pc_src = 2'b10;
        end
        S_EXEC_NOP: begin 
            // Nothing happens, it's just a delay
        end
        S_HALT: begin
            halt_cpu = 1;
        end




        endcase


    end


endmodule