/*
  Eric Villasenor
  evillase@gmail.com

  datapath contains register file, control, hazard,
  muxes, and glue logic for processor
*/

// data path interface
`include "datapath_cache_if.vh"

// alu op, mips op, and instruction type
`include "cpu_types_pkg.vh"
`include "register_file_if.vh"
`include "arithmetic_logic_if.vh"
`include "control_unit_if.vh"
`include "program_counter_if.vh"
`include "request_unit_if.vh"
`include "writeback_if.vh"
`include "branch_mux_if.vh"


module datapath (
  input logic CLK, nRST,
  datapath_cache_if.dp dpif
);
  // import types
  import cpu_types_pkg::*;

  // pc init
 parameter PC_INIT = 0;

  register_file_if rfif ();
  control_unit_if cif ();
  arithmetic_logic_if aluif ();
  program_counter_if prog ();
  request_unit_if ru();
//  alusrc_if src ();
  writeback_if wbif();
  branch_mux_if bif();
//assign dpif.flushed = 1'b1;
// assigning ports

word_t portB;

assign portB = (cif.alu_src) ? cif.imm_gen : rfif.rdat2;

 // datapath ports


assign dpif.imemREN = ru.imemREN;
assign dpif.dmemREN = ru.dmemREN;
assign dpif.dmemWEN = ru.dmemWEN;

assign dpif.imemaddr = prog.pc;
assign dpif.dmemstore = rfif.rdat2;
assign dpif.dmemaddr = (cif.memread || cif.memwrite) ? aluif.result : '0;

word_t previous_instruction;
always_ff @(posedge CLK) begin
  previous_instruction <= cif.instruction;
end

assign cif.instruction = (dpif.ihit) ? dpif.imemload : previous_instruction;
assign wbif.memread_data = (dpif.dhit) ? dpif.dmemload : '0;
assign prog.pc_enable = ru.pc_enable;

assign ru.ihit = dpif.ihit;
assign ru.dhit = dpif.dhit;
assign ru.memread = cif.memread;
assign ru.memwrite = cif.memwrite;

assign rfif.rsel1 = cif.rsel1;
assign rfif.rsel2 = cif.rsel2;
assign rfif.wsel = cif.wsel;
assign rfif.wdat = wbif.wdat;
assign rfif.WEN = cif.regwrite;

assign aluif.rda = rfif.rdat1;
assign aluif.rdb = portB;
assign aluif.alu_op = cif.alu_op;
assign prog.opcode = cif.opcode;

assign prog.result = aluif.result;
assign prog.jump = cif.jump;
assign prog.branch = bif.branch;
assign prog.imm_gen = cif.imm_gen; 
assign prog.jalr = cif.jalr;

assign wbif.pc_add = prog.pc_add;
assign wbif.result = aluif.result;
assign wbif.pc = prog.pc;
assign wbif.jalr = cif.jalr;
assign wbif.jump = cif.jump;
assign wbif.memreg = cif.memreg;
assign wbif.cauipc = cif.cauipc;

assign bif.branch_type = cif.funct3_b;
assign bif.zero = aluif.zero;
assign bif.negative = aluif.negative;
assign bif.overflow = aluif.overflow;
assign bif.result = aluif.result;

always_ff @(posedge CLK, negedge nRST) begin
  if(!nRST) begin
    dpif.halt <= 1'b0;
  end else begin
    dpif.halt <= (dpif.halt | cif.halt);
  end
end

// assigning ports
`ifndef MAPPED
  register_file rf(CLK, nRST, rfif);
`else
  register_file rf(
    .\rfif.rdat2 (rfif.rdat2),
    .\rfif.rdat1 (rfif.rdat1),
    .\rfif.wdat (rfif.wdat),
    .\rfif.rsel2 (rfif.rsel2),
    .\rfif.rsel1 (rfif.rsel1),
    .\rfif.wsel (rfif.wsel),
    .\rfif.WEN (rfif.WEN),
    .\nRST (nRST),
    .\CLK (CLK)
  );
`endif 
`ifndef MAPPED
  alu alu(aluif);
`else 
  alu alu(
    .\aluif.rda (aluif.rda),
    .\aluif.rdb (aluif.rdb),
    .\aluif.result (aluif.result),
    .\aluif.zero (aluif.zero),
    .\aluif.alu_op (aluif.alu_op),
    .\aluif.overflow (aluif.overflow)
  );
`endif 

    // a lot of control unit signals are internal



  `ifndef MAPPED
    control_unit cu1(cif);
  `else
    control_unit cu1(
    .\cif.rsel1 (cif.rsel1),
    .\cif.rsel2 (cif.rsel2),
    .\cif.wsel (cif.wsel),
    .\cif.instruction (cif.instruction),
    .\cif.funct3_b (cif.funct3_b),
    .\cif.opcode (cif.opcode),
    .\cif.alu_op (cif.alu_op),
    .\cif.alu_src (cif.alu_src),
    .\cif.regwrite (cif.regwrite),
    .\cif.memwrite (cif.memwrite),
    .\cif.memread (cif.memread),
    .\cif.memreg (cif.memreg),
    .\cif.jump (cif.jump),
    .\cif.cauipc (cif.cauipc),
    .\cif.halt (cif.halt),
    .\cif.jalr (cif.jalr)
  );
`endif

`ifndef MAPPED
  pc pc(CLK, nRST, prog);
`else
  pc pc(
    .\prog.opcode (prog.opcode),
    .\prog.pc_enable (prog.pc_enable),
    .\prog.result (prog.result),
    .\prog.branch (prog.branch),
    .\prog.jump (prog.jump),
    .\prog.pc_add (prog.pc_add),
    .\prog.pc (prog.pc),
    .\prog.imm_gen (prog.imm_gen),
    .\prog.jalr (prog.jalr)
  );
`endif

`ifndef MAPPED
  request_unit ru1(CLK, nRST, ru);
`else
  request_unit ru1(
    .\ru.ihit (ru.ihit),
    .\ru.dhit (ru.dhit),
    .\ru.dmemload (ru.dmemload),
    .\ru.memread (ru.memread),
    .\ru.memwrite (ru.memwrite),
    .\ru.imemREN (ru.imemREN),
    .\ru.dmemWEN (ru.imemWEN),
    .\ru.dmemREN (ru.dmemREN)
  );
`endif



`ifndef MAPPED
  writeback wb(wbif);
`else
  writeback wb(
    .\wbif.pc_add (wbif.pc_add),
    .\wbif.result (wbif.result),
    .\wbif.pc (wbif.pc),
    .\wbif.jump (wbif.jump),
    .\wbif.memreg (wbif.memreg),
    .\wbif.cauipc (wbif.cauipc),
    .\wbif.memread_data (wbif.memread_data),
    .\wbif.wdat (wbif.wdat),
    .\wbif.jalr (wbif.jalr)
  );
  `endif

`ifndef MAPPED
  branch_mux bm(bif);
`else
  branch_mux bm(
    .\bif.branch_type (bif.branch_type),
    .\bif.zero (bif.zero),
    .\bif.negative (bif.negative),
    .\bif.overflow (bif.overflow),
    .\bif.result (bif.result),
    .\bif.branch (bif.branch)
  );
`endif

endmodule
