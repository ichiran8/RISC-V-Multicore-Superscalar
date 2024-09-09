/*
  Eric Villasenor
  evillase@gmail.com

  register file test bench
*/

// mapped needs this
`include "control_unit_if.vh"
`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module control_unit_tb;

  parameter PERIOD = 10;

  // test vars
  int v1 = 1;
  int v2 = 4721;
  int v3 = 25119;

  // clock

  // interface
  control_unit_if cif ();
  // test program
  test PROG (cif);
  // DUT
`ifndef MAPPED
  control_unit DUT(cif);
`else
  control_unit DUT(
    .\cif.rsel1(cif.rsel1),
    .\cif.rsel2(cif.rsel1),
    .\cif.wsel(cif.wsel),
    .\cif.instruction(cif.instruction),
    .\cif.imm_gen(cif.imm_gen),
    .\cif.alu_op(cif.alu_op),
    .\cif.alu_src(cif.alu_src),
    .\cif.regwrite(cif.regwrite),
    .\cif.memwrite(cif.memwrite),
    .\cif.memread(cif.memread),
    .\cif.memreg(cif.memreg),
    .\cif.jump(cif.jump),
    .\cif.jalr(cif.jalr),
    .\cif.lui(cif.lui),
    .\cif.cauipc(cif.cauipc)
    .\cif.branch_type(cif.branch_type)
  );
`endif


endmodule

program test(control_unit_if.tb cif);

task check_outputs;
  input aluop_t expected_alu;
  input word_t expected_imm;
  input logic [10:0] expected_control;
begin
  if(expected_alu == cif.alu_op)
    $display("Correct alu operation");
  else  
    $display("Incorrect alu operation");

  if(expected_imm == cif.imm_gen) 
    $display("Correct immediate generated");
  else
    $display("Incorrect immediate generated, %d", cif.imm_gen);
  
  if(expected_control == {cif.alu_src, cif.regwrite, cif.memwrite, cif.memread, cif.memreg, cif.jump, cif.jalr, cif.lui, cif.cauipc, cif.branch_type})
    $display("Correct control logic signal decoding");
  else
    $display("Incorrect control logic signal decoding %d %d %d %d %d %d %d %d %d %d", cif.alu_src, cif.regwrite, cif.memwrite, cif.memread, cif.memreg, cif.jump, cif.jalr, cif.lui, cif.cauipc, cif.branch_type);
end
endtask

initial begin
// R-Type //

  cif.instruction = 32'h000000b3;
  #(10ns);
  check_outputs(ALU_ADD, 32'b0, {1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b0});

   cif.instruction = 32'h40c58533;
  #(10ns);
  check_outputs(ALU_SUB, 32'b0, {1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b0});

   cif.instruction = 32'h00c5c533;
  #(10ns);
  check_outputs(ALU_XOR, 32'b0, {1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b0});

   cif.instruction = 32'h00c5e533;
  #(10ns);
  check_outputs(ALU_OR, 32'b0, {1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b0});

   cif.instruction = 32'h00c5f533;
  #(10ns);
  check_outputs(ALU_AND, 32'b0, {1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b0});

   cif.instruction = 32'h00c59533;
  #(10ns);
  check_outputs(ALU_SLL, 32'b0, {1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b0});

   cif.instruction = 32'h00c5d533;
  #(10ns);
  check_outputs(ALU_SRL, 32'b0, {1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b0});

   cif.instruction = 32'h40c5d533;
  #(10ns);
  check_outputs(ALU_SRA, 32'b0, {1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b0});

   cif.instruction = 32'h00c5a533;
  #(10ns);
  check_outputs(ALU_SLT, 32'b0, {1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b0});

   cif.instruction = 32'h00c5b533;
  #(10ns);
  check_outputs(ALU_SLTU, 32'b0, {1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b0});

// i type

  cif.instruction = 32'h00158513;
  #(10ns);
  check_outputs(ALU_ADD, 32'b1, {1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b0});

    cif.instruction = 32'h0015c513;
  #(10ns);
  check_outputs(ALU_XOR, 32'b1, {1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b0});

    cif.instruction = 32'h0015e513;
  #(10ns);
  check_outputs(ALU_OR, 32'b1, {1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b0});

    cif.instruction = 32'h0015f513;
  #(10ns);
  check_outputs(ALU_AND, 32'b1, {1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b0});

    cif.instruction = 32'h00159513;
  #(10ns);
  check_outputs(ALU_SLL, 32'b1, {1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b0});

    cif.instruction = 32'h0015d513;
  #(10ns);
  check_outputs(ALU_SRL, 32'b1, {1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b0});

    cif.instruction = 32'h4015d513;
  #(10ns);
  check_outputs(ALU_SRA, 32'd1025, {1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b0});

    cif.instruction = 32'h0015a513;
  #(10ns);
  check_outputs(ALU_SLT, 32'b1, {1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b0});

    cif.instruction = 32'h0015b513;
  #(10ns);
  check_outputs(ALU_SLTU, 32'b1, {1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b0});

  // lw

  cif.instruction = 32'h0015a503;
  #(10ns);
  check_outputs(ALU_ADD, 32'b1, {1'b1, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'b0});

  // jalr
  cif.instruction = 32'h001580e7;
  #(10ns);
  check_outputs(ALU_ADD, 32'b1, {1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 2'b0});


  // sw
  cif.instruction = 32'h00a5a0a3;
  #(10ns);
  check_outputs(ALU_ADD, 32'b1, {1'b1, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b0});

  // branching beq
  cif.instruction = 32'h00b50263;
  #(10ns);
  check_outputs(ALU_SUB, 32'd4, {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b1});

   // branching bne
  cif.instruction = 32'h00b51263;
  #(10ns);
  check_outputs(ALU_SUB, 32'd4, {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd2});

   // branching blt
  cif.instruction = 32'h00b54263;
  #(10ns);
  check_outputs(ALU_SLT, 32'd4, {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd2});

   // branching bltu
  cif.instruction = 32'h00b56263;
  #(10ns);
  check_outputs(ALU_SLTU, 32'd4, {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'd2});

   // branching bge
  cif.instruction = 32'h00b55263;
  #(10ns);
  check_outputs(ALU_SLT, 32'd4, {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b1});

   // branching bgeu
  cif.instruction = 32'h00b57263;
  #(10ns);
  check_outputs(ALU_SLTU, 32'd4, {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b1});

  // lui
  cif.instruction = 32'h00002537;
  
  
  #(10ns);
  check_outputs(ALU_ADD, 32'd8192, {1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 2'b0});

  cif.instruction = 32'h02525517;
  #(10ns);
  check_outputs(ALU_ADD, 32'd38948864, {1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b0});  

  //auipc

end
endprogram
