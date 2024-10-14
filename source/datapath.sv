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

word_t next_pc, pc, portA, portB, write_back;
logic switch1, PCWrite, if_id_write; // we're going to have two flush signals for id_ex, so seperated names
logic if_flush, id_flush, ex_flush, branch;
logic [1:0] forwardA, forwardB;

  typedef struct packed {
    word_t instruction, pc_add, curr_pc;
  } if_id_t;

  if_id_t if_id;

  typedef struct packed {
    word_t rdat1, rdat2, pc_add, curr_pc, u_type, imm_gen, jump_target;
    aluop_t alu_op;
    logic alu_src, regwrite, memwrite, memread, memreg, jump, halt, jalr, switch1, switch2, zero; 
    regbits_t wsel, rsel1, rsel2;
    logic [1:0] branch_type;
  } id_ex_t;

  id_ex_t id_ex;

  typedef struct packed {
    word_t write_selected, dmemstore, dmemload, imm_gen, curr_pc, portA, portB;
    logic regwrite, memwrite, memread, memreg, halt, zero; 
    logic [1:0] branch_type;
    regbits_t wsel;
  } ex_mem_t;

   ex_mem_t ex_mem;


typedef struct packed {
  word_t  write_back;
  logic regwrite, halt, memreg; 
  regbits_t wsel;
} mem_wb_t;

mem_wb_t mem_wb;


// ********************* MISC *************************** //

register_file rf(CLK, nRST, rfif);
alu alu(aluif);
control_unit cu1(cif);
forwarding_unit forward(.id_ex_rsel1(id_ex.rsel1), .id_ex_rsel2(id_ex.rsel2), .ex_mem_wsel(ex_mem.wsel), .mem_wb_wsel(mem_wb.wsel), .ex_mem_regwrite(ex_mem.regwrite), .mem_wb_regwrite(mem_wb.regwrite), .forwardA(forwardA), .forwardB(forwardB));
//hazard_unit hazarding(.id_ex_memread(id_ex.memread), .id_ex_rd(id_ex.wsel), .if_id_rs1(rfif.rsel1), .if_id_rs2(rfif.rsel2), .PCWrite(PCWrite), .if_id_write(if_id_write), .flush_id_ex(hazard_flush_id_ex));
hazard_unit hazarding(.branch(branch), .jump(id_ex.jump | id_ex.jalr), .halt(id_ex.halt), .if_flush(if_flush), .id_flush(id_flush), .ex_flush(ex_flush)); //.id_ex_memread(id_ex.memread), .id_ex_rd(id_ex.wsel), .if_id_rs1(rfif.rsel1), .if_id_rs2(rfif.rsel2), .PCWrite(PCWrite), .if_id_write(if_id_write)); // check halt
    
assign dpif.imemREN = !(dpif.dmemREN | dpif.dmemWEN);
assign dpif.imemaddr = pc;
assign rfif.rsel1 = dpif.dhit ? id_ex.rsel1 : cif.rsel1;
assign rfif.rsel2 = dpif.dhit ? id_ex.rsel2 : cif.rsel2;

//********************** PROGRAM COUNTER ************************** //

always_ff @(posedge CLK, negedge nRST) begin
  if(!nRST) begin
    pc <= '0;
  end else if (dpif.ihit) begin // include the dHit and iHit signals
    pc <= next_pc;//(ru.pc_enable) ? next_pc : pc;
  end
end


  //********************* START OF INSTRUCTION FETCH : INSTRUCTION DECODE (IF/ID) LATCH *********************//

  always_ff @(posedge CLK, negedge nRST) begin : IF_ID_LATCH
    if(!nRST) begin // add flush here
      if_id <= '0;
    end else if (if_flush & dpif.ihit) begin
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
    else if (id_flush & dpif.ihit)
      id_ex <= '0;
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
        id_ex.halt <= cif.halt;
        id_ex.jalr <= cif.jalr;
        id_ex.branch_type <= cif.branch_type;
        id_ex.switch2 <= cif.lui | cif.cauipc;
        id_ex.wsel <= cif.wsel;
        id_ex.u_type <= (cif.cauipc) ? cif.imm_gen + if_id.curr_pc : cif.imm_gen;
        id_ex.zero <= cif.zero;
        id_ex.jump_target <= if_id.curr_pc + cif.imm_gen;
        id_ex.switch1 <= cif.jalr | cif.jump;
      end
  end
always_comb begin
  portA = id_ex.rdat1;
  portB = id_ex.rdat2;
  casez({forwardA})
    2'b10 : portA = write_back;
    2'b01 : portA = mem_wb.write_back;
  endcase
  casez({forwardB})
    2'b10 : portB = write_back;
    2'b01 : portB = mem_wb.write_back;
  endcase
end
assign aluif.rda = portA;
assign aluif.rdb = (id_ex.alu_src) ? id_ex.imm_gen : portB;
assign aluif.alu_op = id_ex.alu_op;


// can straight up do this here
word_t write_selected;

always_comb begin
  write_selected = aluif.result;
  casez({{id_ex.switch1}, id_ex.switch2})
    2'b10 : write_selected = id_ex.pc_add;
    2'b01 : write_selected = id_ex.u_type;
  endcase
end

always_comb begin
    next_pc = pc + 4; // Don't know if I need this here tbh (no you don't)
    if(branch) begin
      next_pc = ex_mem.curr_pc + ex_mem.imm_gen; // this is calculated in the mem  stage
    end else begin
      casez({id_ex.jump, id_ex.jalr})      
          2'b10 : next_pc = id_ex.jump_target; // this is calculated in the execute stage
          2'b01 : next_pc = aluif.result;
      endcase
    end
end


// TOTAL NUMBER OF LATCHED BITS : 191 (?)


// ********************* START OF EXECUTE : MEMORY (EX/MEM) LATCH ********************* //



  always_ff @(posedge CLK, negedge nRST) begin : EX_MEM_LATCH  
    if(!nRST) begin
      ex_mem <= '0;
    end else if (ex_flush && dpif.ihit)begin
      ex_mem <= '0;
    end
    else if (dpif.dhit) begin
      ex_mem.memwrite <= 1'b0;
      ex_mem.memread <= 1'b0;
      ex_mem.dmemload <= dpif.dmemload;
    end 
    else if (dpif.ihit) begin
      ex_mem.write_selected <= write_selected; // this is put above
      ex_mem.regwrite <= id_ex.regwrite; // determine whether or not we write into a register
      ex_mem.memwrite <= id_ex.memwrite; // determine whether or not we write into memory
      ex_mem.memread <= id_ex.memread; // determine whether or not we are reading from memory
      ex_mem.memreg <= id_ex.memreg; // determine whether or not we take the value from memory or the alu result to be written back 
      ex_mem.halt <= id_ex.halt;
      ex_mem.wsel <= id_ex.wsel;
      ex_mem.curr_pc <= id_ex.curr_pc;
      ex_mem.imm_gen <= id_ex.imm_gen;
      ex_mem.dmemstore <= portB;
      ex_mem.branch_type <= id_ex.branch_type;
      ex_mem.zero <= id_ex.zero;
      ex_mem.portA <= aluif.rda;
      ex_mem.portB <= aluif.rdb;
    end
  end

always_comb begin
  branch = 1'b0;
  casez(ex_mem.branch_type)
    2'd1 : branch = !((ex_mem.portA == ex_mem.portB) ^ ex_mem.zero); //((ex_mem.portA ^ ex_mem.portB) == 0) : ((ex_mem.portA ^ ex_mem.portB) != 32'b0);
    2'd2 : branch = !(($signed(ex_mem.portA) >= $signed(ex_mem.portB)) ^ ex_mem.zero);//(ex_mem.zero) ? !($signed(ex_mem.portA) < $signed(ex_mem.portB)) : (($signed(ex_mem.portA) < $signed(ex_mem.portB)));
    2'd3 : branch = !(($unsigned(ex_mem.portA) >= $unsigned(ex_mem.portB)) ^ ex_mem.zero);//(ex_mem.zero) ? !(($unsigned(ex_mem.portA) < $unsigned(ex_mem.portB))) : (($unsigned(ex_mem.portA) < $unsigned(ex_mem.portB)));
  endcase
end

assign dpif.dmemstore = ex_mem.dmemstore; 
assign dpif.dmemaddr  = ex_mem.write_selected;
assign dpif.dmemREN   = ex_mem.memread;
assign dpif.dmemWEN   = ex_mem.memwrite;
assign write_back     = (ex_mem.memreg) ? ex_mem.dmemload : ex_mem.write_selected;





// TOTAL NUMBER OF LATCHED BITS : 143 (i think sounds correct, bc auipc/lui)

// ********************* START OF MEMORY : WRITEBACK (MEM/WB) LATCH ********************* //

always_ff @(posedge CLK, negedge nRST) begin : MEM_WB_LATCH
  if(!nRST) begin
    mem_wb <= '0;
  end else if (dpif.ihit) begin
    mem_wb.wsel <= ex_mem.wsel;
    mem_wb.regwrite <= ex_mem.regwrite;
    mem_wb.halt <= ex_mem.halt;
    mem_wb.memreg <= ex_mem.memreg;
    mem_wb.write_back <= write_back; 
  end
end
 
assign rfif.wsel = mem_wb.wsel;

assign rfif.wdat = mem_wb.write_back; 
assign rfif.WEN  = mem_wb.regwrite;


always_ff @(posedge CLK, negedge nRST) begin
  if(!nRST) begin
    dpif.halt <= 1'b0;
  end else begin
    dpif.halt <= (dpif.halt | ex_mem.halt);
  end
end

// TOTAL NUMBER OF LATCHED BITS : 72

endmodule
