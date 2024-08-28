/*
  Eric Villasenor
  evillase@gmail.com

  register file interface
*/
`ifndef WRITEBACK_IF_VH
`define WRITEBACK_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface writeback_if;
  // import types
  import cpu_types_pkg::*;

    word_t pc_add, result, wdat, pc, memread_data;
    logic jump, memreg, cauipc, jalr;

  // register file ports
  modport wb (
    input   pc_add, result, pc, jump, memreg, cauipc, jalr, memread_data,
    output  wdat
  );
  // register file tb
//   modport tb (
//     input   rdat1, rdat2,
//     output  WEN, wsel, rsel1, rsel2, wdat
//   );
endinterface

`endif //REGISTER_FILE_IF_VH
