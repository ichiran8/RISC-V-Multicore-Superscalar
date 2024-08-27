/*
  Eric Villasenor
  evillase@gmail.com

  register file interface
*/
`ifndef REQUEST_UNIT_IF_VH
`define REQUEST_UNIT_IF_VH

// all types
`include "cpu_types_pkg.vh"





interface request_unit_if;
  // import types
  import cpu_types_pkg::*;
  
  
 logic               halt;

// Icache signals
  // hit and enable
  logic               ihit, imemREN;
  // instruction addr
  word_t             imemload, imemaddr;

// Dcache signals
  // hit, atomic and enables
  logic               dhit, dmemREN, dmemWEN, flushed, memwrite, memread, pc_enable;
  // data and address
  word_t              dmemload, dmemstore, dmemaddr, result, pc, instruction, memread_data, memwrite_data;



 // datapath ports
  modport ru (
    input   ihit, dhit, memread, memwrite,
    output  imemREN, dmemREN, dmemWEN, pc_enable
  );
//   // register file tb
//   modport tb (
//     input   rdat1, rdat2,
//     output  WEN, wsel, rsel1, rsel2, wdat
//   );
endinterface

`endif //REGISTER_FILE_IF_VH
