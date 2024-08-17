/*
  Eric Villasenor
  evillase@gmail.com

  register file interface
*/
`ifndef CONTROL_UNIT_IF_VH
`define REGISTER_FILE_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface control_unit_if;
  // import types
  import cpu_types_pkg::*;

  word_t instruction;
  regbits_t wsel, rsel1, rsel2;
  logic [11:0] imm_i;
  logic [11:0] imm_s_b;
  logic [19:0] imm_u_j;
  funct3_r_t funct3_r;
  funct3_i_t funct3_i;
  funct3_ld_i_t funct3_ld_i;
  funct3_s_t funct3_s;
  funct3_b_t funct3_b;
  funct7_r_t funct7_r;
  funct7_srla_r_t funct7_srla_r;
  opcode_t opcode;
  aluop_t alu_op;
  logic alu_src, regwrite, memwrite, memread, memreg, jump;

  // register file ports
  modport cuif (
    input   instruction, funct3_r, funct3_i, funct3_ld_i, funct3_s, funct3_b, funct7_r, funct7_srla_r, opcode, imm_i, imm_s_b, imm_u_j,
    output  alu_op, alu_src, regwrite, memwrite, memread, memreg, jump, wsel, rsel1, rsel2
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
