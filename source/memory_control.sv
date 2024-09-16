/*
  Eric Villasenor
  evillase@gmail.com

  this block is the coherence protocol
  and artibtration for ram
*/

// interface include
`include "cache_control_if.vh"
`include "caches_if.vh"
// memory types
`include "cpu_types_pkg.vh"

module memory_control (
  input CLK, nRST,
  cache_control_if ccif
);
  // type import
  import cpu_types_pkg::*;

  // number of cpus for cc
  parameter CPUS = 2;


assign ccif.iwait = (ccif.ramstate == BUSY || (ccif.dREN || ccif.dWEN));
assign ccif.dwait = !(ccif.ramstate == ACCESS && (ccif.dREN | ccif.dWEN));
assign ccif.iload = ccif.ramload; // this is the data we read from memory (to be loaded as an instruction)  
assign ccif.dload = ccif.ramload; // this is the data we read from memory (to be loaded as the write back or whatever (lw))
assign ccif.ramstore = ccif.dstore;//(ccif.dWEN) ? ccif.dstore : 0;
assign ccif.ramaddr = (ccif.dREN | ccif.dWEN) ? ccif.daddr : ccif.iaddr; //(ccif.iREN) ? ccif.iaddr : 0; // if we want data 
assign ccif.ramWEN = ccif.dWEN;
assign ccif.ramREN = (ccif.dREN | (ccif.iREN & !ccif.dWEN));




endmodule
