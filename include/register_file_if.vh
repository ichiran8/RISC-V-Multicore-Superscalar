/*
  Eric Villasenor
  evillase@gmail.com

  register file interface
*/
`ifndef REGISTER_FILE_IF_VH
`define REGISTER_FILE_IF_VH

// all types
`include "cpu_types_pkg.vh"

interface register_file_if;
  // import types
  import cpu_types_pkg::*;

  logic     WEN1, WEN2;
  regbits_t wsel1, wsel2, rsel1_1, rsel1_2, rsel2_1, rsel2_2;
  word_t    wdat1, wdat2, rdat1_1, rdat1_2, rdat2_1, rdat2_2;

  // register file ports
  modport rf (
    input   WEN1, WEN2, wsel1, wsel2, rsel1_1, rsel1_2, rsel2_1, rsel2_2, wdat1, wdat2,
    output  rdat1_1, rdat1_2, rdat2_1, rdat2_2
  );
  // // register file tb
  // modport tb (
  //   input   rdat1, rdat2,
  //   output  WEN, wsel, rsel1, rsel2, wdat
  // );
endinterface

`endif //REGISTER_FILE_IF_VH
