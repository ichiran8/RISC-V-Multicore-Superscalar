/*
  Eric Villasenor
  evillase@gmail.com

  register file interface
*/
`ifndef BRANCH_MUX_IF_VH
`define BRANCH_MUX_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface branch_mux_if;
  // import types
  import cpu_types_pkg::*;

  logic branch;
  funct3_b_t branch_type;
  word_t result;
  logic zero, negative, overflow;
  // register file ports
  modport br (
    input branch_type, zero, negative, overflow, result,
    output branch
  );
  // register file tb
  modport tb (
    input branch,
    output branch_type, zero, negative, overflow, result
  );
endinterface

`endif //REGISTER_FILE_IF_VH
