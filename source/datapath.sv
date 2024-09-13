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
  request_unit_if ru();

  // START OF INSTRUCTION FETCH : INSTRUCTION DECODE (IF/ID) LATCH

  //
  typedef struct packed {
    word_t next_pc;
    word_t instruction;
  } if_id_t;

  if_id_t if_id;

  always_ff @(posedge CLK, negedge nRST) begin : IF_ID_LATCH
    if(!nRST) begin // add flush here
      if_id <= '0;
    end else (dpif.ihit) begin
      if_id.instruction <= dpif.imemload;
      if_id.next_pc <= pc + 4;
    end
  end
assign cif.instruction = if_id.instruction;
assign next_pc = if_id.next_pc;

// END OF INSTRUCTION FETCH : INSTRUCTION DECODE (IF/ID) LATCH

//

// START OF INSTRUCTION DECODE : EXECUTE (ID/EX) LATCH

//
  typedef struct packed {
    word_t rdat1, rdat2;
    logic alu_src, regwrite, memwrite, memread, memreg, jump, auipc, halt, jalr, lui; 
  } id_ex_t;

  if_ex_t id_ex;

  always_ff begin
    if(!nRST) begin
      id_ex <= '0;
    end else begin
      id_ex.rdat1 <= rfif.rdat1;
      id_ex.rdat2 <= rif.rdat2;
      id_ex.imm_gen <= cif.imm_gen; // NOT A CONTROL SIGNAL
      id_ex.alu_src <= cif.alu_src; // choosing whether or not we take a value to r2 or immediate
      id_ex.regwrite <= cif.regwrite; // determine whether or not we write into a register
      id_ex.memwrite <= cif.memwrit3e; // determine whether or not we write into memory
      id_ex.memread <= cif.memread; // determine whether or not we are reading from memory
      id_ex.memreg <= cif.memreg; // determine whether or not we take the value from memory or the alu result to be written back 
      id_ex.alu_op <= cif.alu_op; // alu operation ; NOT A CONTROL SIGNAL (BASICALLY)
      id_ex.jump <= cif.jump; // jump for JAL and JALR (write back block); I think AUIPC too?
      id_ex.auipc <= cif.cauipc; //auipc ctrl logic
      id_ex.halt <= cif.halt;
      id_ex.jalr <= cif.jalr;
      id_ex.branch_type <= cif.branch_type;
      id_ex.lui <= cif.lui;
    end
  end

  // END OF INSTRUCTION DECODE : EXECUTE (ID/EX) LATCH

  //
 

word_t portB;

assign portB = (cif.alu_src) ? cif.imm_gen : rfif.rdat2;

word_t next_pc, pc; //, pc_add;

always_ff @(posedge CLK, negedge nRST) begin
  if(!nRST) begin
    pc <= '0;
  end else begin // include the dHit and iHit signals
    pc <= next_pc;//(ru.pc_enable) ? next_pc : pc;
  end
end

assign dpif.dmemstore = ru.dmemstore; 
assign ru.rdat2 = rfif.rdat2;

always_comb begin
  next_pc = pc;
  if(ru.pc_enable) begin
    //next_pc = pc + 4;//pc_add;
    casez({cif.jump, cif.jalr, cif.branch_type})      
        4'b1000 : next_pc = pc + cif.imm_gen;
        4'b0100 : next_pc = aluif.result;
        4'b0010 : next_pc = !(aluif.zero) ? pc + cif.imm_gen : pc + 4;
        4'b0001 : next_pc = (aluif.zero) ? pc + cif.imm_gen : pc + 4;
        default : next_pc = pc + 4;
      endcase
    end
end
 // datapath ports


assign dpif.imemREN = ru.imemREN;
assign dpif.dmemREN = ru.dmemREN;
assign dpif.dmemWEN = ru.dmemWEN;
assign dpif.imemaddr = pc;
assign dpif.dmemaddr = aluif.result;


assign cif.instruction = dpif.imemload;

assign ru.ihit = dpif.ihit;
assign ru.dhit = dpif.dhit;
assign ru.memread = cif.memread;
assign ru.memwrite = cif.memwrite;

assign rfif.rsel1 = cif.rsel1;
assign rfif.rsel2 = cif.rsel2;
assign rfif.wsel = cif.wsel;


logic switch1;
assign switch1 = cif.jump | cif.jalr;
always_comb begin
  casez({cif.memreg, switch1, cif.cauipc, cif.lui})
    4'b0000 : rfif.wdat = aluif.result;
    4'b0100 : rfif.wdat = pc + 4;
    4'b0010 : rfif.wdat = pc + cif.imm_gen;
    4'b0001 : rfif.wdat = cif.imm_gen;
    default : rfif.wdat = dpif.dmemload;
  endcase
end
assign rfif.WEN = cif.regwrite & (dpif.dhit | dpif.ihit);

assign aluif.rda = rfif.rdat1;
assign aluif.rdb = portB;
assign aluif.alu_op = cif.alu_op;


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
  request_unit ru1(CLK, nRST, ru);

endmodule
