/*
  Eric Villasenor
  evillase@gmail.com

  register file interface
*/
`ifndef CONTROL_UNIT_IF_VH
`define CONTROL_UNIT_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface control_unit_if;
  // import types
  import cpu_types_pkg::*;
  
  funct3_r_t funct3_r;
  funct3_b_t funct3_b;
  funct3_i_t funct3_i;
  funct7_r_t funct7_r;
  funct7_srla_r_t funct7_srla_r;
  opcode_t opcode;

  word_t instruction, imm_gen;
  regbits_t wsel, rsel1, rsel2;
  //funct3_b_t funct3_b;

  //logic branch_bit;
  aluop_t alu_op;
  logic alu_src, regwrite, memwrite, memread, memreg, jump, cauipc, halt, jalr, lui, zero;
  logic [1:0] branch_type;


  // register file ports
  modport cuif (
    input   instruction, funct3_r, funct3_b, funct3_i, funct7_r, funct7_srla_r, //zero,
    output  alu_op, alu_src, regwrite, memwrite, memread, memreg, jump, wsel, rsel1, rsel2, imm_gen, cauipc, halt, jalr, branch_type, lui
  );

   modport tb (
    input  alu_op, alu_src, regwrite, memwrite, memread, memreg, jump, wsel, rsel1, rsel2, imm_gen, cauipc, halt, jalr, branch_type, lui,
    output instruction //, zero
  );

  // // register file tb
  // modport tb (
  //   input   rdat1, rdat2,
  //   output  WEN, wsel, rsel1, rsel2, wdat
  // );
  // modport dec (
  //   output funct3_r, funct3_i, funct3_ld_i, funct3_s, funct3_b, funct7_r, funct7_srla_r, opcode, imm_i, imm_u_uj, imm_s_b
  // );


endinterface

`endif //REGISTER_FILE_IF_VH
