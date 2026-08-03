`timescale 1ns/1ps

module cpu(
    input logic clk,
    input logic rst_n
);


    // Bus declaration and wires
    logic       pc_write;
    logic       pc_write_cond;
    logic       ir_write;
    logic       reg_write;
    logic       mem_read;
    logic       mem_write;
    logic       alu_sel_a;
    logic [1:0] alu_sel_b;
    logic [3:0] alu_op;
    logic [1:0] pc_src;
    logic [1:0] mem_to_reg;
    logic       reg_dst;
    logic       imm_src;
    logic       halt_cpu;
    logic       alu_out_write;
    logic       mdr_write;
    logic       flags_write;

    // Program counter signals and Instructions memory
    logic [15:0] next_pc;
    logic [15:0] pc_current;
    logic [15:0] instruction_raw;
    logic [15:0] instruction;
    logic        pc_write_enable;


    // Extraction of instruction fields

    logic [3:0] opcode;
    logic [2:0] rd_field;
    logic [2:0] ra_field;
    logic [2:0] rb_field;
    logic [2:0] rs_field;
    logic [11:0] jump_address;

    assign opcode       = instruction[15:12];
    assign rd_field     = instruction[11:9];
    assign ra_field     = instruction[8:6];
    assign rs_field     = instruction[8:6];
    assign rb_field     = instruction[5:3];
    assign jump_address = instruction[11:0];

    // Signals from Register File and Registers A/B
    logic [2:0] write_reg_addr;
    logic [15:0] write_data_reg;
    logic [15:0] reg_read_data_1;
    logic [15:0] reg_read_data_2;
    logic [15:0] a_reg_out;
    logic [15:0] b_reg_out;

    // Signals from the ALU and immediate extension
    logic [15:0] extended_imm;
    logic [15:0] alu_operand_a;
    logic [15:0] alu_operand_b;
    logic [15:0] alu_result;
    logic alu_zero_flag;
    logic [15:0] alu_out;

    // Memory Data Signals

    logic [15:0] mem_read_data;
    logic [15:0] mdr_out;

    // Combinational logic and multiplexers

    assign write_reg_addr = (reg_dst == 1'b0) ? rd_field : rs_field;

    always_comb begin 
        case (mem_to_reg) 
            2'b00: write_data_reg = alu_out;
            2'b01: write_data_reg = mdr_out;
            2'b10: write_data_reg = extended_imm;
            2'b11: write_data_reg = a_reg_out;
        endcase
    end

    assign alu_operand_a = (alu_sel_a == 1'b0) ? pc_current : a_reg_out;

    always_comb begin 
        case (alu_sel_b) 
            2'b00: alu_operand_b = b_reg_out;
            2'b01: alu_operand_b = 16'h0001;
            2'b10: alu_operand_b = extended_imm;
            default: alu_operand_b = 16'h0000;
        endcase
    end

    // 3 Hardware Blocks instancing.

    control_unit control_unit_inst(
        .clk(clk),
        .rst_n(rst_n),
        .opcode(opcode),
        .pc_write(pc_write),
        .pc_write_cond(pc_write_cond),
        .ir_write(ir_write),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .alu_sel_a(alu_sel_a),
        .alu_sel_b(alu_sel_b),
        .alu_op(alu_op),
        .pc_src(pc_src),
        .mem_to_reg(mem_to_reg),
        .reg_dst(reg_dst),
        .imm_src(imm_src),
        .halt_cpu(halt_cpu),
        .alu_out_write(alu_out_write),
        .mdr_write(mdr_write),
        .flags_write(flags_write)
    );

    pc_logic pc_logic_inst (
        .pc_src(pc_src),
        .pc_write_cond(pc_write_cond),
        .zero_flag(alu_zero_flag),
        .alu_result(alu_result),
        .branch_target(alu_out),
        .jump_target({4'b0000, jump_address}),
        .next_pc(next_pc),
        .pc_write_enable(pc_write_enable)
    );

    pc pc_inst (
.clk(clk),
        .reset(~rst_n),                  
        .pc_write(pc_write | pc_write_enable),
        .next_pc(next_pc),
        .current_pc(pc_current)               
    );

    instruction_memory inst_mem_inst (
        .pc(pc_current),
        .instruction(instruction_raw)
    );

    instruction_register ir_inst (
        .clk(clk),
        .reset(~rst_n), 
        .ir_write(ir_write),
        .instruction_in(instruction_raw),
        .instruction_out(instruction)
    );

    register_file rf_inst (
        .clk(clk),
        .reset(~rst_n),               
        .reg_write(reg_write),
        .read_reg1(ra_field),      
        .read_reg2(rb_field),
        .write_reg(write_reg_addr),
        .write_data(write_data_reg),
        .read_data1(reg_read_data_1), 
        .read_data2(reg_read_data_2)
    );

    always_ff @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin 
            a_reg_out <= 16'h0000;
            b_reg_out <= 16'h0000;
        end else begin 
            a_reg_out <= reg_read_data_1;
            b_reg_out <= reg_read_data_2;
        end
    end


    immediate_ext imm_ext_inst (
        .instruction(instruction),
        .imm_src(imm_src),
        .ext_imm(extended_imm)
    );

    alu alu_inst (
        .a(alu_operand_a),      
        .b(alu_operand_b),      
        .alu_op(alu_op),
        .alu_result(alu_result),
        .zero(alu_zero_flag)   
    );

    alu_out_register alu_out_reg_inst (
        .clk(clk),
        .rst_n(rst_n),
        .alu_out_write(alu_out_write),
        .alu_result(alu_result),
        .alu_out(alu_out)
    );

    data_memory data_mem_inst (
        .clk(clk),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .address(alu_out),
        .write_data(b_reg_out),
        .read_data(mem_read_data)
    );

    memory_data_register mdr_inst (
        .clk(clk),
        .rst_n(rst_n),
        .mdr_write(mdr_write),
        .mem_data(mem_read_data),
        .mdr_out(mdr_out)
    );
endmodule