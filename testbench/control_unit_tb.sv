/*
  Eric Villasenor
  evillase@gmail.com

  register file test bench
*/

// mapped needs this
`include "control_unit_if.vh"
`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;

// mapped timing needs this. 1ns is too fast
`timescale 1 ns / 1 ns

module control_unit_tb;

  parameter PERIOD = 10;

  // test vars
  int v1 = 1;
  int v2 = 4721;
  int v3 = 25119;

  // clock

  // interface
  control_unit_if cif ();
  // test program
  test PROG (cif);
  // DUT
`ifndef MAPPED
  control_unit DUT(cif);
`else
  control_unit DUT(
    .\cif.rsel1(cif.rsel1),
    .\cif.rsel2(cif.rsel1),
    .\cif.wsel(cif.wsel),
    .\cif.instruction(cif.instruction),
    .\cif.imm_gen(cif.imm_gen),
    .\cif.alu_op(cif.alu_op),
    .\cif.alu_src(cif.alu_src),
    .\cif.regwrite(cif.regwrite),
    .\cif.memwrite(cif.memwrite),
    .\cif.memread(cif.memread),
    .\cif.memreg(cif.memreg),
    .\cif.jump(cif.jump),
    .\cif.jalr(cif.jalr),
    .\cif.lui(cif.lui),
    .\cif.cauipc(cif.cauipc)
  );
`endif


endmodule

program test(control_unit_if.cuif cif);
endprogram
