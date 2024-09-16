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

word_t next_pc, pc, portA, portB;
logic switch1;
logic [1:0] forwardA, forwardB;

  typedef struct packed {
    word_t instruction, pc_add, curr_pc;
  } if_id_t;

  if_id_t if_id;

  typedef struct packed {
    word_t rdat1, rdat2, pc_add, imm_gen, curr_pc;
    aluop_t alu_op;
    logic alu_src, regwrite, memwrite, memread, memreg, jump, auipc, halt, jalr, lui; 
    regbits_t wsel, rsel1, rsel2;
    logic [1:0] branch_type;
  } id_ex_t;

  id_ex_t id_ex;

  typedef struct packed {
    word_t write_selected, dmemstore, pc_add, curr_pc, imm_gen;
    logic regwrite, memwrite, memread, memreg, halt, jump, jalr, branch; 
    regbits_t wsel;
  } ex_mem_t;

   ex_mem_t ex_mem;


typedef struct packed {
  word_t memload, write_selected;
  logic regwrite, memreg, halt; 
  regbits_t wsel;
} mem_wb_t;

mem_wb_t mem_wb;


// ********************* MISC *************************** //

register_file rf(CLK, nRST, rfif);
alu alu(aluif);
control_unit cu1(cif);
forwarding_unit forward(.id_ex_rsel1(id_ex.rsel1), .id_ex_rsel2(id_ex.rsel2), .ex_mem_wsel(ex_mem.wsel), .mem_wb_wsel(mem_wb.wsel), .ex_mem_regwrite(ex_mem.regwrite), .mem_wb_regwrite(mem_wb.regwrite), .forwardA(forwardA), .forwardB(forwardB));
assign dpif.imemREN = 1'b1;
assign dpif.imemaddr = pc;
assign rfif.rsel1 = cif.rsel1;
assign rfif.rsel2 = cif.rsel2;

//********************** PROGRAM COUNTER ************************** //

always_ff @(posedge CLK, negedge nRST) begin
  if(!nRST) begin
    pc <= '0;
  end else begin // include the dHit and iHit signals
    pc <= next_pc;//(ru.pc_enable) ? next_pc : pc;
  end
end


  //********************* START OF INSTRUCTION FETCH : INSTRUCTION DECODE (IF/ID) LATCH *********************//

  always_ff @(posedge CLK, negedge nRST) begin : IF_ID_LATCH
    if(!nRST) begin // add flush here
      if_id <= '0;
    end else if (dpif.ihit) begin
      if_id.instruction <= dpif.imemload;
      if_id.pc_add <= pc + 4;
      if_id.curr_pc <= pc;
    end
  end
assign cif.instruction = if_id.instruction;

// TOTAL NUMBER OF LATCHED BITS : 96

//********************* START OF INSTRUCTION DECODE : EXECUTE (ID/EX) LATCH ********************* //

  always_ff @(posedge CLK, negedge nRST) begin : ID_EX_LATCH
    if(!nRST) begin
      id_ex <= '0;
    end 
    else if (dpif.ihit) begin
      id_ex.rdat1 <= rfif.rdat1;
      id_ex.rdat2 <= rfif.rdat2;
      id_ex.rsel1 <= rfif.rsel1;
      id_ex.rsel2 <= rfif.rsel2;
      id_ex.pc_add <= if_id.pc_add;
      id_ex.curr_pc <= if_id.curr_pc;
      id_ex.imm_gen <= cif.imm_gen; 
      id_ex.alu_src <= cif.alu_src; 
      id_ex.regwrite <= cif.regwrite; 
      id_ex.memwrite <= cif.memwrite; 
      id_ex.memread <= cif.memread; 
      id_ex.memreg <= cif.memreg; 
      id_ex.alu_op <= cif.alu_op; 
      id_ex.jump <= cif.jump; 
      id_ex.auipc <= cif.cauipc; 
      id_ex.halt <= cif.halt;
      id_ex.jalr <= cif.jalr;
      id_ex.branch_type <= cif.branch_type;
      id_ex.lui <= cif.lui;
      id_ex.wsel <= cif.wsel;
    end
  end

assign portA = forwardA[1] ? ex_mem.write_selected : forwardA[0] ? mem_wb.write_selected : id_ex.rdat1;
assign portB = forwardB[1] ? ex_mem.write_selected : forwardB[0] ? mem_wb.write_selected : (id_ex.alu_src) ? id_ex.imm_gen : id_ex.rdat2;
assign aluif.rda = portA;
assign aluif.rdb = portB;
assign aluif.alu_op = id_ex.alu_op;


// can straight up do this here
word_t write_selected;
assign switch1 = id_ex.jump | id_ex.jalr;
always_comb begin
  write_selected = aluif.result;
  casez({switch1, id_ex.lui, id_ex.auipc})
    3'b1?? : write_selected = id_ex.pc_add;
    3'b?1? : write_selected = id_ex.imm_gen;
    3'b??1 : write_selected = id_ex.curr_pc + id_ex.imm_gen;
  endcase
end

// TOTAL NUMBER OF LATCHED BITS : 191 (?)


// ********************* START OF EXECUTE : MEMORY (EX/MEM) LATCH ********************* //



  always_ff @(posedge CLK, negedge nRST) begin : EX_MEM_LATCH
    if(!nRST) begin
      ex_mem <= '0;
    end else if (dpif.ihit | dpif.dhit) begin
      ex_mem.write_selected <= write_selected; // this is put above
      ex_mem.pc_add <= id_ex.pc_add;
      ex_mem.curr_pc <= id_ex.curr_pc;
      ex_mem.imm_gen <= id_ex.imm_gen; // NOT A CONTROL SIGNAL
      ex_mem.regwrite <= id_ex.regwrite; // determine whether or not we write into a register
      ex_mem.memwrite <= dpif.dhit ? 1'b0 : id_ex.memwrite; // determine whether or not we write into memory
      ex_mem.memread <= dpif.dhit ? 1'b0 : id_ex.memread; // determine whether or not we are reading from memory
      ex_mem.memreg <= dpif.dhit ? 1'b0 : id_ex.memreg; // determine whether or not we take the value from memory or the alu result to be written back 
      ex_mem.jump <= id_ex.jump; // jump for JAL and JALR (write back block); I think AUIPC too?
      ex_mem.halt <= id_ex.halt;
      ex_mem.jalr <= id_ex.jalr;
      ex_mem.branch <= (id_ex.branch_type[0] & (aluif.zero)) | (id_ex.branch_type[1] & !(aluif.zero)) ? 1'b1 : 1'b0;
      ex_mem.wsel <= id_ex.wsel;
      ex_mem.dmemstore <= id_ex.rdat2;
    end
  end
 
assign dpif.dmemstore = ex_mem.dmemstore; 
assign dpif.dmemaddr = ex_mem.write_selected;
assign dpif.dmemREN = ex_mem.memread;
assign dpif.dmemWEN = ex_mem.memwrite;

always_comb begin
    next_pc = ex_mem.pc_add; // Don't know if I need this here tbh (no you don't)
    casez({ex_mem.jump, ex_mem.jalr, ex_mem.branch})      
        3'b1?? : next_pc = ex_mem.curr_pc + ex_mem.imm_gen; // this will be wrong
        3'b?1? : next_pc = ex_mem.write_selected;
        3'b??1 : next_pc = ex_mem.curr_pc + ex_mem.imm_gen; //: ex_mem.pc_add; // same with this
      endcase
  // end
end


// TOTAL NUMBER OF LATCHED BITS : 143 (i think sounds correct, bc auipc/lui)

// ********************* START OF MEMORY : WRITEBACK (MEM/WB) LATCH ********************* //

always_ff @(posedge CLK, negedge nRST) begin : MEM_WB_LATCH
  if(!nRST) begin
    mem_wb <= '0;
  end else if (dpif.ihit | dpif.dhit) begin
    mem_wb.memload <= dpif.dmemload;
    mem_wb.wsel <= ex_mem.wsel;
    mem_wb.regwrite <= ex_mem.regwrite;
    mem_wb.memreg <= ex_mem.memreg;
    mem_wb.halt <= ex_mem.halt;
    mem_wb.write_selected <= ex_mem.write_selected;
  end
end
 
assign rfif.wsel = mem_wb.wsel;

assign rfif.wdat = (mem_wb.memreg) ? mem_wb.memload : mem_wb.write_selected;
assign rfif.WEN = (dpif.ihit) ? 1'b0 : mem_wb.regwrite;


always_ff @(posedge CLK, negedge nRST) begin
  if(!nRST) begin
    dpif.halt <= 1'b0;
  end else begin
    dpif.halt <= (dpif.halt | mem_wb.halt);
  end
end

// TOTAL NUMBER OF LATCHED BITS : 72

endmodule
