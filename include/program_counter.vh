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

  word_t result, pc;
  logic pc_enable, branch;
  opcode_t opcode;
  // register file ports
  modport pc (
    input opcode, pc_enable, result, branch, jump
    output pc;
  );
  // register file tb
  modport tb (
    input pc;
    output opcode, pc_enable, result, branch, jump
  );
endinterface

`endif //REGISTER_FILE_IF_VH
