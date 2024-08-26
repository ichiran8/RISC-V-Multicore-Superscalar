/*
  Eric Villasenor
  evillase@gmail.com

  register file interface
*/
`ifndef ALUSRC_IF_VH
`define ALUSRC_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface alusrc_if;
  // import types
  import cpu_types_pkg::*;

  word_t imm_gen, rdat2, portB;
  logic alu_src;
  // register file ports
  modport src (
    input   imm_gen, rdat2, alu_src,
    output  portB
  );
//   // register file tb
//   modport tb (
//     input   rdat1, rdat2,
//     output  WEN, wsel, rsel1, rsel2, wdat
//   );
endinterface

`endif //REGISTER_FILE_IF_VH
