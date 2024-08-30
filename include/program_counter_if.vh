/*
  Eric Villasenor
  evillase@gmail.com

  register file interface
*/
`ifndef PROGRAM_COUNTER_IF_VH
`define PROGRAM_COUNTER_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface program_counter_if;
  // import types
  import cpu_types_pkg::*;

  word_t result, pc, pc_add;
  logic pc_enable, branch, jump, jalr;
  word_t imm_gen;
  opcode_t opcode;
  // register file ports
  modport pcp (
    input pc_enable, result, branch, jump,  imm_gen, jalr, 
    output pc, pc_add
  );
  // register file tb
  // modport tb (
  //   input pc;
  //   output opcode, pc_enable, result, branch, jump, pc_add
  // );
endinterface

`endif //REGISTER_FILE_IF_VH
