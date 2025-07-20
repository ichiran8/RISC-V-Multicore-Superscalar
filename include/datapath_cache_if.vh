/*
  Eric Villasenor
  evillase@gmail.com

  holds datapath and cache interface signals
*/
`ifndef DATAPATH_CACHE_IF_VH
`define DATAPATH_CACHE_IF_VH

// types
`include "cpu_types_pkg.vh"

interface datapath_cache_if;
  // import types
  import cpu_types_pkg::*;

// datapath signals
  // stop processing
  logic               halt;

// Icache signals
  // hit and enable
  logic               ihit, ihit2, imemREN;
  // instruction addr
  word_t             imemload1, imemload2, imemaddr1, imemaddr2;

// Dcache signals
  // hit, atomic and enables
  logic               dhit, datomic, dmemREN, dmemWEN, flushed;
  // data and address
  word_t              dmemload, dmemstore, dmemaddr;

  // datapath ports
  modport dp (
    input   ihit, imemload1, imemload2, dhit, dmemload,
    output  halt, imemREN, imemaddr1, imemaddr2, dmemREN, dmemWEN, datomic,
            dmemstore, dmemaddr
  );

  // cache block ports
  modport cache (
    input   halt, imemREN, dmemREN, dmemWEN, datomic,
            dmemstore, dmemaddr, imemaddr1, imemaddr2,
    output  ihit, dhit, imemload1, imemload2, dmemload, flushed
  );

  // icache ports
  modport icache (
    input   imemREN, imemaddr1, imemaddr2,
    output  ihit, imemload1, imemload2
  );

  // dcache ports
  modport dcache (
    input   halt, dmemREN, dmemWEN,
            datomic, dmemstore, dmemaddr,
    output  dhit, dmemload, flushed
  );
endinterface

`endif //DATAPATH_CACHE_IF_VH
