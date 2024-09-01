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

logic branch;
 //things to note, unique statements and the use of branch = zero
// always_comb begin
//     branch = 1'b0;
//     casez ({aluif.zero, cif.branch_type})
//         3'd5 : branch = 1'b1;
//         3'd2 : branch = 1'b1;
//     endcase
// end

// always_comb begin
//   branch = 1'b0;
//   unique if (cif.branch_type == 2'd1) begin
//     branch = aluif.zero;
//   end else if (cif.branch_type == 2'd2) begin
//     branch = !aluif.zero;
//   end
// end

word_t next_pc, pc;//pc_add;

always_ff @(posedge CLK, negedge nRST) begin
  if(!nRST) begin
    pc <= '0;
  end else begin // include the dHit and iHit signals
    pc <= next_pc;//(ru.pc_enable) ? next_pc : pc;
  end
end
// can write cif.branchnz and cif.branchz
always_comb begin
  next_pc = pc;
 if(ru.pc_enable) begin
    next_pc = pc + 4;
    casez({cif.jump, cif.jalr, cif.branch_type})
      4'b1??? : next_pc = pc + cif.imm_gen;
      4'b?1?? : next_pc = aluif.result;
      4'b??1? : next_pc = (!aluif.zero) ? pc + cif.imm_gen : pc + 4;
      4'b???1 : next_pc = (aluif.zero) ? pc + cif.imm_gen : pc + 4;
    endcase
  end
end
// always_comb begin
//     next_pc = pc;
//     if(ru.pc_enable) begin
//       next_pc = pc + 4;
//       casez({cif.jump, cif.jalr, branch})
//         3'b1?? : next_pc = pc + aluif.result;
//         3'b?1? : next_pc = aluif.result;
//         3'b??1 : next_pc = pc + cif.imm_gen;
//       endcase
//   end
// end
// always_comb begin
//   next_pc = pc;
//   if(ru.pc_enable) begin
//     next_pc = pc + 4; 
//     if(cif.jump) begin
//       next_pc = pc + aluif.result;
//       end else if (cif.jalr) begin
//         next_pc = aluif.result;
//       end else if (branch) begin
//         next_pc = pc + cif.imm_gen;
//       end
//     end
// end

 // datapath ports


assign dpif.imemREN = ru.imemREN;
assign dpif.dmemREN = ru.dmemREN;
assign dpif.dmemWEN = ru.dmemWEN;

//assign dpif.imemaddr = prog.pc;
assign dpif.imemaddr = pc;
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
//assign wbif.memread_data = dpif.dmemload;
//assign prog.pc_enable = ru.pc_enable;

assign ru.ihit = dpif.ihit;
assign ru.dhit = dpif.dhit;
assign ru.memread = cif.memread;
assign ru.memwrite = cif.memwrite;

assign rfif.rsel1 = cif.rsel1;
assign rfif.rsel2 = cif.rsel2;
assign rfif.wsel = cif.wsel;
//assign rfif.wdat = wbif.wdat;
// always_comb begin
//   rfif.wdat = aluif.result;
//   casez({cif.jump, cif.jalr, cif.cauipc, cif.memreg})
//     4'b??00 : rfif.wdat = pc_add;
//     //4'b?1?? : rfif.wdat = pc_add;
//     4'b??1? : rfif.wdat = pc + aluif.result;
//     4'b???1 : rfif.wdat = dpif.dmemload;
//   endcase
// end
assign rfif.wdat = (cif.jump | cif.jalr) ? pc + 4 : (cif.cauipc) ? pc + cif.imm_gen : (cif.lui) ? cif.imm_gen : (cif.memreg) ? dpif.dmemload : aluif.result;
assign rfif.WEN = cif.regwrite & (dpif.dhit | dpif.ihit);

assign aluif.rda = rfif.rdat1;
assign aluif.rdb = portB;
assign aluif.alu_op = cif.alu_op;

// assign prog.result = aluif.result;
// assign prog.jump = cif.jump;
// assign prog.branch = bif.branch;
// assign prog.imm_gen = cif.imm_gen; 
// assign prog.jalr = cif.jalr;

// assign wbif.pc_add = prog.pc_add;
// assign wbif.result = aluif.result;
// assign wbif.pc = prog.pc;
// assign wbif.jalr = cif.jalr;
// assign wbif.jump = cif.jump;
// assign wbif.memreg = cif.memreg;
// assign wbif.cauipc = cif.cauipc;

// assign bif.branch_type = cif.branch_type;
// assign bif.zero = aluif.zero;
// assign bif.negative = aluif.negative;
// assign bif.overflow = aluif.overflow;
// assign bif.result = aluif.result;




//assign bif.branch_bit = cif.branch_bit;


    // one final optimization I can do is to get rid of alu src and to immediately pass imm_gen forward. The alu_result becomes irrelevant
    // this also gets rid of the need to define rsel1 for those signals 

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
  //pc pc(CLK, nRST, prog);
  request_unit ru1(CLK, nRST, ru);
  //writeback wb(wbif);
  //branch_mux bm(bif);

endmodule
