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
//ssign dpif.dmemaddr = (cif.memread || cif.memwrite) ? aluif.result : '0;
assign dpif.dmemaddr = aluif.result;
//word_t previous_instruction;
// always_ff @(posedge CLK) begin
//   previous_instruction <= cif.instruction;
// end

//assign cif.instruction = (dpif.ihit) ? dpif.imemload : previous_instruction;
// assign wbif.memread_data = (dpif.dhit) ? dpif.dmemload : '0;

assign cif.instruction = dpif.imemload;
assign wbif.memread_data = dpif.dmemload;
assign prog.pc_enable = ru.pc_enable;

assign ru.ihit = dpif.ihit;
assign ru.dhit = dpif.dhit;
assign ru.memread = cif.memread;
assign ru.memwrite = cif.memwrite;

assign rfif.rsel1 = cif.rsel1;
assign rfif.rsel2 = cif.rsel2;
assign rfif.wsel = cif.wsel;
assign rfif.wdat = wbif.wdat;
assign rfif.WEN = cif.regwrite & (dpif.dhit | dpif.ihit);

assign aluif.rda = rfif.rdat1;
assign aluif.rdb = portB;
assign aluif.alu_op = cif.alu_op;

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
assign bif.branch_bit = cif.branch_bit;

// word_t next_pc, pc;

// always_ff @(posedge CLK, negedge nRST) begin
//   if(!nRST) begin
//     prog.pc <= '0;
//   end else begin // include the dHit and iHit signals
//       prog.pc <= next_pc;
//   end
// end

// always_comb begin
//   next_pc = pc;
//   if(pc_enable & !(dpif.dmemREN | dpif.dmemWEN)) begin
//     next_pc = pc + 4; 
//     if(cif.jump) begin
//       next_pc = pc + aluif.result;
//       end else if (cif.jalr) begin
//         next_pc = aluif.result;
//       end else if (cif.branch) begin
//         next_pc = pc + cif.imm_gen;
//       end
//     end
// end
    

always_ff @(posedge CLK, negedge nRST) begin
  if(!nRST) begin
    dpif.halt <= 1'b0;
  end else begin
    dpif.halt <= (dpif.halt | cif.halt);
  end
end

  register_file rf(CLK, nRST, rfif);
  alu alu(aluif);
  control_unit cu1(cif);
  pc pc(CLK, nRST, prog);
  request_unit ru1(CLK, nRST, ru);
  writeback wb(wbif);
  branch_mux bm(bif);

endmodule
