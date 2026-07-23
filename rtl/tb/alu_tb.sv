//ALU Testbench

`timescale 1ns/1ps

module alu_tb;

logic [15:0] a;
logic [15:0] b;
logic [3:0] alu_op;

logic [15:0] alu_result;
logic zero;


alu uut (
    .a(a),
    .b(b),
    .alu_op(alu_op),
    .alu_result(alu_result),
    .zero(zero)
);

// Bloque para generar el archivo de ondas
    initial begin
        $dumpfile("alu_sim.vcd"); // Define el nombre del archivo de salida
        $dumpvars(0, alu_tb);     // Guarda todas las variables desde el nivel alu_tb hacia abajo
    end

    initial begin 
        $monitor("Time: %0t ns | OP: %b | A: %h | B: %h | Result: %h | Zero: %b", $time, alu_op, a, b, alu_result, zero);



    // Initialization test #1
    a = 16'h0000;
    b = 16'h0000;
    alu_op = 4'b0000;
    #10; // <- 10 units of time.


    // NOP Case
    a = 16'h1234;
    b = 16'h5678;
    alu_op = 4'b0000;
    #10;



    // Test: ADD
    a = 16'd15;
    b = 16'd10;
    alu_op = 4'b0001;
    #10;

    // SUB Case
    a = 16'd500;
    b = 16'd120;
    alu_op = 4'b0010;
    #10;

    // AND Case
    a = 16'h0F0F;
    b = 16'hFFFF;
    alu_op = 4'b0011;
    #10;

    // OR Case
    a = 16'hF0F0;
    b = 16'h0F0F;
    alu_op = 4'b0100;
    #10;

    // MOV Case
    a = 16'h55AA;
    b = 16'hFFF;
    alu_op = 4'b0111;
    #10;

    // LOAD case

    a = 16'h00A0;
    b = 16'h0004;
    alu_op = 4'b1001;
    #10;

    // STORE Case

    a = 16'h00B0;
    b = 16'h0008;
    alu_op = 4'b1010;
    #10;

    // BEQ Case
    a = 16'd25;
    b = 16'd25;
    alu_op = 4'b1100;
    #10;

    // BNE Case

    a = 16'd25;
    b = 16'd10;
    alu_op = 4'b1101;
    #10;

    // JMP Case
    a = 16'h03FF;
    b = 16'h0000;
    alu_op = 4'b1110;
    #10;

    // HALT Case
    a = 16'h1234;
    b = 16'h5678;
    alu_op = 4'b1111;
    #10;

    // CMP Case
    a = 16'hA5A5;
    b = 16'hA5A5;
    alu_op = 4'b1011;
    #10;

    // XOR Case
    a = 16'b1111_0000_1100_1010;
    b = 16'b1010_1010_1010_1010;
    alu_op = 4'b0101;
    #10;

    // OPSIM Case
      
        a = 16'b1111_1111_0000_1111; 
        b = 16'b1111_0000_0000_1111; 
        alu_op = 4'b0110; 
        #10;

    // LDI Case

    a = 16'hFFFF;
    b = 16'hABCD;
    alu_op = 4'b1000;
    #10;

    $display("Finished");
    $finish;
end


endmodule