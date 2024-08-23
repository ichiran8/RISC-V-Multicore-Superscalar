`ifndef ARITHMETIC_LOGIC_IF_VH
`define ARITHMETIC_LOGIC_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface arithmetic_logic_if;
  // import types
  import cpu_types_pkg::*;

  logic  [31:0] rda, rdb, result;
  logic zero, negative, overflow;


  aluop_t alu_op;

  // register file ports
  modport aluds (
    input  rda, rdb, alu_op,
    output  result, zero, overflow, negative
  );
  // register file tb
  modport tb (
    input   result, zero, overflow, negative,
    output  rda, rdb, alu_op
  );

endinterface
`endif
