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
  
  
 logic               halt;

// Icache signals
  // hit and enable
  logic               ihit, imemREN;
  // instruction addr
  word_t             imemload, imemaddr;

// Dcache signals
  // hit, atomic and enables
  logic               dhit, datomic, dmemREN, dmemWEN, flushed, memwrite, memread;
  // data and address
  word_t              dmemload, dmemstore, dmemaddr, result, pc;


 // datapath ports
  modport ru (
    input   ihit, imemload, dhit, dmemload, memread, memwrite,
    output  halt, imemREN, imemaddr, dmemREN, dmemWEN, datomic,
            dmemstore, dmemaddr
  );
//   // register file tb
//   modport tb (
//     input   rdat1, rdat2,
//     output  WEN, wsel, rsel1, rsel2, wdat
//   );
endinterface

`endif //REGISTER_FILE_IF_VH
