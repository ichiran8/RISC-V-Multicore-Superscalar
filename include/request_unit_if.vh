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
  
  
// Icache signals
  // hit and enable
  logic               ihit, imemREN, dhit, dmemREN, dmemWEN, memread, memwrite, pc_enable;




 // datapath ports
  modport ru (
    input   ihit, dhit, memread, memwrite,
    output  imemREN, dmemREN, dmemWEN, pc_enable
  );

    modport tb (
    input  imemREN, dmemREN, dmemWEN, pc_enable,

    output   ihit, dhit, memread, memwrite
  );
//   // register file tb
//   modport tb (
//     input   rdat1, rdat2,
//     output  WEN, wsel, rsel1, rsel2, wdat
//   );
endinterface

`endif //REGISTER_FILE_IF_VH
