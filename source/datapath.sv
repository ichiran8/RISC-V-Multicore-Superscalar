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
  //program_counter_if prog ();
  request_unit_if ru();
//  alusrc_if src ();
  //writeback_if wbif();
  //branch_mux_if bif();
//assign dpif.flushed = 1'b1;
// assigning ports

word_t portB;

assign portB = (cif.alu_src) ? cif.imm_gen : rfif.rdat2;

word_t next_pc, pc;//pc_add;

always_ff @(posedge CLK, negedge nRST) begin
  if(!nRST) begin
    pc <= '0;
  end else begin // include the dHit and iHit signals
    pc <= next_pc;//(ru.pc_enable) ? next_pc : pc;
  end
end


always_comb begin
  next_pc = pc;
 if(ru.pc_enable) begin
   next_pc = pc + 4;//pc_add;
   casez({cif.jump, cif.jalr, cif.branch_type})      
      4'b1000 : next_pc = pc + cif.imm_gen;
      4'b0100 : next_pc = aluif.result;
      4'b0010 : next_pc = !(aluif.zero) ? pc + cif.imm_gen : pc + 4;
      4'b0001 : next_pc = (aluif.zero) ? pc + cif.imm_gen : pc + 4;
      //default : next_pc = pc + 4;
    endcase
  end
end
 // datapath ports


assign dpif.imemREN = ru.imemREN;
assign dpif.dmemREN = ru.dmemREN;
assign dpif.dmemWEN = ru.dmemWEN;
assign dpif.imemaddr = pc;
assign dpif.dmemstore = rfif.rdat2;
assign dpif.dmemaddr = aluif.result;



assign cif.instruction = dpif.imemload;

assign ru.ihit = dpif.ihit;
assign ru.dhit = dpif.dhit;
assign ru.memread = cif.memread;
assign ru.memwrite = cif.memwrite;

assign rfif.rsel1 = cif.rsel1;
assign rfif.rsel2 = cif.rsel2;
assign rfif.wsel = cif.wsel;


assign rfif.wdat = (cif.memreg) ? dpif.dmemload : (cif.jump | cif.jalr) ? pc + 4 : (cif.cauipc) ? pc + cif.imm_gen : (cif.lui) ? cif.imm_gen : aluif.result;
assign rfif.WEN = cif.regwrite & (dpif.dhit | dpif.ihit);

assign aluif.rda = rfif.rdat1;
assign aluif.rdb = portB;
assign aluif.alu_op = cif.alu_op;



//assign bif.branch_bit = cif.branch_bit;



always_ff @(posedge CLK, negedge nRST) begin
  if(!nRST) begin
    dpif.halt <= 1'b0;
  end else begin
    dpif.halt <= (dpif.halt | (cif.halt));
  end
end


  register_file rf(CLK, nRST, rfif);
  alu alu(aluif);
  control_unit cu1(cif);
  //pc pc(CLK, nRST, prog);
  request_unit ru1(CLK, nRST, ru);
  //writeback wb(wbif);
  //branch_mux bm(bif);

endmodule
