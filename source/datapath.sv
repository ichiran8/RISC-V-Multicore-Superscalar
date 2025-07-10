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
  control_unit_if cif1 ();
  control_unit_if cif2 ();
  arithmetic_logic_if aluif1 ();
  arithmetic_logic_if aluif2 ();

word_t next_pc, pc, portA1, portB1, portA2, portB2, write_selected1, write_selected2, load1, load2; 
logic control_pipe, stall_flag, misalignment, start, stall_check, switch1, PCWrite, if_id_write1, if_id_write2, if_flush, id_flush1, id_flush2, ex_flush, branch1, branch2, mem_dep, stall; 
logic [2:0] forwardA1, forwardB1, forwardA2, forwardB2;

  // ************************ INSTRUCTION FETCH / DECODE PIPELINE STRUCT ************************
  typedef struct packed {
    word_t instruction, pc_add, curr_pc;
  } if_id_t;

  if_id_t if_id1, if_id2;

  // ************************    DECODE / EXECUTE PIPELINE STRUCT   ************************
  // We need a FIFO to keep track of instructions that are dependent (also need to flush if it overflows but it should never overflow)

  typedef struct packed {
    word_t instruction, rdat1, rdat2, pc_add, curr_pc, u_type, imm_gen;
    logic [19:0] u_addr;
    aluop_t alu_op;
    logic alu_src, regwrite, memwrite, memread, memreg, jump, halt, jalr, switch1, switch2, zero, datomic, lrsc; 
    regbits_t wsel, rsel1, rsel2;
    logic [1:0] branch_type;
  } id_ex_t;

  id_ex_t id_ex1, id_ex2;

  // ************************    EXECUTE / MEMORY  PIPELINE STRUCT   ************************

  typedef struct packed {
    word_t instruction, write_selected, dmemstore, dmemload, imm_gen, curr_pc, portA, portB;
    logic regwrite, memwrite, memread, memreg, halt, zero, datomic; 
    logic [1:0] branch_type;
    regbits_t wsel;
  } ex_mem_t;

   ex_mem_t ex_mem1, ex_mem2;
  // ************************    MEMORY / WRITEBACK PIPELINE STRUCT   ************************

typedef struct packed {
  word_t  instruction, write_back, write_selected, memload;
  logic regwrite, halt, memreg; 
  regbits_t wsel;//, rsel1, rsel2;
} mem_wb_t;

mem_wb_t mem_wb1, mem_wb2;
// ********************* MISC *************************** //

register_file rf(CLK, nRST, rfif);
alu alu1(aluif1);
alu alu2(aluif2);
control_unit cu1(cif1);
control_unit cu2(cif2);
forwarding_unit forward1(.id_ex_rsel1(id_ex1.rsel1), .id_ex_rsel2(id_ex1.rsel2), .ex_mem_wsel1(ex_mem1.wsel), .ex_mem_wsel2(ex_mem2.wsel), .mem_wb_wsel1(mem_wb1.wsel), .mem_wb_wsel2(mem_wb2.wsel), .ex_mem_regwrite1(ex_mem1.regwrite), .ex_mem_regwrite2(ex_mem2.regwrite), .mem_wb_regwrite1(mem_wb1.regwrite), .mem_wb_regwrite2(mem_wb2.regwrite), .forwardA(forwardA1), .forwardB(forwardB1));
forwarding_unit forward2(.id_ex_rsel1(id_ex2.rsel1), .id_ex_rsel2(id_ex2.rsel2), .ex_mem_wsel1(ex_mem1.wsel), .ex_mem_wsel2(ex_mem2.wsel), .mem_wb_wsel1(mem_wb1.wsel), .mem_wb_wsel2(mem_wb2.wsel), .ex_mem_regwrite1(ex_mem1.regwrite), .ex_mem_regwrite2(ex_mem2.regwrite), .mem_wb_regwrite1(mem_wb1.regwrite), .mem_wb_regwrite2(mem_wb2.regwrite), .forwardA(forwardA2), .forwardB(forwardB2));
hazard_unit hazarding(.branch(branch1 || branch2), .jump(cif1.jump || (cif2.jump && !stall_flag)), .halt(id_ex1.halt || (id_ex2.halt & !(branch1 || id_ex1.jalr))), .if_flush(if_flush), .id_flush1(id_flush1), .id_flush2(id_flush2), .id_ex_memread1(id_ex1.memread || id_ex1.lrsc), .id_ex_rd1(id_ex1.wsel), .id_ex_rd2(id_ex2.wsel), .if_id_rs1_1(rfif.rsel1_1), .if_id_rs2_1(rfif.rsel2_1), .id_ex_memread2(id_ex2.memread || id_ex2.lrsc), .if_id_rs1_2(rfif.rsel1_2), .if_id_rs2_2(rfif.rsel2_2), .PCWrite(PCWrite), .if_id_write1(if_id_write1), .if_id_write2(if_id_write2), .jalr(id_ex1.jalr || id_ex2.jalr));

assign dpif.imemREN = 1'b1;
assign control_pipe = (ex_mem1.memread | ex_mem1.memwrite | ex_mem2.memread | ex_mem2.memwrite) ? (dpif.dhit & dpif.ihit) : dpif.ihit;
assign dpif.imemaddr1 = pc;
assign dpif.imemaddr2 = pc + 4;
assign rfif.rsel1_1 = cif1.rsel1; 
assign rfif.rsel2_1 = cif1.rsel2; 
assign rfif.rsel1_2 = cif2.rsel1;
assign rfif.rsel2_2 = cif2.rsel2;

// ********************** PROGRAM COUNTER ************************** //

assign stall = (branch1 || branch2 || cif1.jump || id_ex1.jalr || id_ex2.jalr) ? 1'b0 : stall_flag;
always_ff @(posedge CLK, negedge nRST) begin
  if(!nRST) begin
    pc <= PC_INIT;
  end else if (control_pipe & PCWrite & !stall) begin 
    pc <= next_pc;
  end
end

  //********************* START OF INSTRUCTION FETCH : INSTRUCTION DECODE (IF/ID) LATCH *********************//

  always_ff @(posedge CLK, negedge nRST) begin : IF_ID_LATCH1
    if(!nRST) begin
      if_id1 <= '0;
    end else if (if_flush & control_pipe) begin
      if_id1 <= '0;
    end else if (stall_check & !if_id_write2 & control_pipe) begin
      if_id1 <= '0;
    end else if (!if_id_write1 & control_pipe) begin
      if_id1 <= if_id1;
    end else if(stall_flag & control_pipe) begin 
      if_id1 <= '0;
    end else if (control_pipe & if_id_write1) begin
      if_id1.instruction <= dpif.imemload1; 
      if_id1.pc_add <= pc + 4;
      if_id1.curr_pc <= pc;
    end
  end

  always_ff @(posedge CLK, negedge nRST) begin : IF_ID_LATCH2
    if(!nRST) begin
      if_id2 <= '0;
    end else if ((if_flush) & control_pipe) begin
      if_id2 <= '0;
    end else if ((stall_flag || !if_id_write2 || !if_id_write1) & control_pipe) begin
      if_id2 <= if_id2;
    end else if (control_pipe & if_id_write2) begin
      if_id2.instruction <= dpif.imemload2; 
      if_id2.pc_add <= pc + 8;
      if_id2.curr_pc <= pc + 4;
    end
  end
  
assign cif1.instruction = if_id1.instruction;
assign cif2.instruction = if_id2.instruction;
assign mem_dep = (cif1.memread || cif1.memwrite) && (cif2.memread || cif2.memwrite);

always_comb begin
  stall_flag = 1'b0;
  if ( ((( cif1.wsel == cif2.rsel1) || ((cif1.wsel == cif2.rsel2) && (!cif2.alu_src || cif2.memwrite))) && cif1.regwrite) || cif1.jalr || mem_dep || cif1.halt) begin
      stall_flag = 1'b1;
  end
end


always_ff @(posedge CLK, negedge nRST) begin
  if(!nRST) begin
    stall_check <= 0;
  end else if (control_pipe & if_flush) begin
    stall_check <= 0;
  end else if(control_pipe) begin 
    stall_check <= stall_flag;
  end
end


// TOTAL NUMBER OF LATCHED BITS : 96

//********************* START OF INSTRUCTION DECODE : EXECUTE (ID/EX) LATCH ********************* //

  always_ff @(posedge CLK, negedge nRST) begin 
    if(!nRST) begin
      id_ex1 <= '0;
    end else if (id_flush1 & control_pipe) begin
      id_ex1 <= '0;
    end else if (control_pipe) begin
        id_ex1.instruction <= if_id1.instruction;
        id_ex1.rdat1 <= rfif.rdat1_1;
        id_ex1.rdat2 <= rfif.rdat2_1;
        id_ex1.rsel1 <= rfif.rsel1_1;
        id_ex1.rsel2 <= rfif.rsel2_1;
        id_ex1.pc_add <= if_id1.pc_add;
        id_ex1.curr_pc <= if_id1.curr_pc;
        id_ex1.imm_gen <= cif1.imm_gen; 
        id_ex1.alu_src <= cif1.alu_src; 
        id_ex1.regwrite <= cif1.regwrite; 
        id_ex1.memwrite <= cif1.memwrite; 
        id_ex1.memread <= cif1.memread; 
        id_ex1.memreg <= cif1.memreg; 
        id_ex1.alu_op <= cif1.alu_op; 
        id_ex1.jump <= cif1.jump; 
        id_ex1.halt <= cif1.halt;
        id_ex1.jalr <= cif1.jalr;
        id_ex1.branch_type <= cif1.branch_type;
        id_ex1.switch2 <= cif1.lui | cif1.cauipc;
        id_ex1.wsel <= cif1.wsel;
        id_ex1.u_type <= (cif1.cauipc) ? cif1.imm_gen + if_id1.curr_pc : cif1.imm_gen;
        id_ex1.zero <= cif1.zero;
        id_ex1.switch1 <= cif1.jalr | cif1.jump;
        id_ex1.datomic <= cif1.datomic;
        id_ex1.lrsc <= cif1.lrsc;
      end
  end

  always_ff @(posedge CLK, negedge nRST) begin 
    if(!nRST) begin
      id_ex2 <= '0;
    end else if ((id_flush2 || stall_flag || cif1.jump || id_flush1) & control_pipe) begin 
      id_ex2 <= '0;
    end else if (control_pipe) begin
      id_ex2.instruction <= if_id2.instruction;
      id_ex2.rdat1 <= rfif.rdat1_2;
      id_ex2.rdat2 <= rfif.rdat2_2;
      id_ex2.rsel1 <= rfif.rsel1_2;
      id_ex2.rsel2 <= rfif.rsel2_2;
      id_ex2.pc_add <= if_id2.pc_add;
      id_ex2.curr_pc <= if_id2.curr_pc;
      id_ex2.imm_gen <= cif2.imm_gen; 
      id_ex2.alu_src <= cif2.alu_src; 
      id_ex2.regwrite <= cif2.regwrite; 
      id_ex2.memwrite <= cif2.memwrite; 
      id_ex2.memread <= cif2.memread; 
      id_ex2.memreg <= cif2.memreg; 
      id_ex2.alu_op <= cif2.alu_op; 
      id_ex2.jump <= cif2.jump; 
      id_ex2.halt <= cif2.halt;
      id_ex2.jalr <= cif2.jalr;
      id_ex2.branch_type <= cif2.branch_type;
      id_ex2.switch2 <= cif2.lui | cif2.cauipc;
      id_ex2.wsel <= cif2.wsel;
      id_ex2.u_type <= (cif2.cauipc) ? cif2.imm_gen + if_id2.curr_pc : cif2.imm_gen;
      id_ex2.zero <= cif2.zero;
      id_ex2.switch1 <= cif2.jalr | cif2.jump;
      id_ex2.datomic <= cif2.datomic;
      id_ex2.lrsc <= cif2.lrsc;
      end
  end

// TODO We need two forwarding units. The two forwarding units will need modifications to support forwarding 
/*
2'd1 refers to forwarding from write back stage (instruction 1)
2'd2 refers to forwarding from memory stage (instruction 1)
2'd3 refers to forwarding from memory stage stage (instruction 2)
2'd4 refers to forwarding from writebaclk stage (instruction 2)
*/
always_comb begin
  casez({forwardA1})
    3'b100 : portA1 = rfif.wdat2;
    3'b011 : portA1 = ex_mem2.write_selected;
    3'b010 : portA1 = ex_mem1.write_selected;
    3'b001 : portA1 = rfif.wdat1;
    default : portA1 = id_ex1.rdat1;
  endcase
end
always_comb begin
  casez({forwardB1})
    3'b100 : portB1 = rfif.wdat2;
    3'b011 : portB1 = ex_mem2.write_selected;
    3'b010 : portB1 = ex_mem1.write_selected;
    3'b001 : portB1 = rfif.wdat1;
    default : portB1 = id_ex1.rdat2;
  endcase
end
assign aluif1.rda = portA1;
assign aluif1.rdb = (id_ex1.alu_src) ? id_ex1.imm_gen : portB1;
assign aluif1.alu_op = id_ex1.alu_op;


always_comb begin
  casez({forwardA2})
    3'b100 : portA2 = rfif.wdat2;
    3'b011 : portA2 = ex_mem2.write_selected;
    3'b010 : portA2 = ex_mem1.write_selected;
    3'b001 : portA2 = rfif.wdat1;
    default : portA2 = id_ex2.rdat1;
  endcase
end
always_comb begin
  casez({forwardB2})
    3'b100 : portB2 = rfif.wdat2;
    3'b011 : portB2 = ex_mem2.write_selected;
    3'b010 : portB2 = ex_mem1.write_selected;
    3'b001 : portB2 = rfif.wdat1;
    default : portB2 = id_ex2.rdat2;
  endcase
end
assign aluif2.rda = portA2;
assign aluif2.rdb = (id_ex2.alu_src) ? id_ex2.imm_gen : portB2;
assign aluif2.alu_op = id_ex2.alu_op;


always_comb begin
  write_selected1 = aluif1.result;
  casez({{id_ex1.switch1}, id_ex1.switch2})
    2'b10 : write_selected1 = id_ex1.pc_add;
    2'b01 : write_selected1 = id_ex1.u_type;
  endcase
end

always_comb begin
  write_selected2 = aluif2.result;
  casez({{id_ex2.switch1}, id_ex2.switch2})
    2'b10 : write_selected2 = id_ex2.pc_add;
    2'b01 : write_selected2 = id_ex2.u_type;
  endcase
end
always_comb begin
  branch1 = 1'b0;
  casez(id_ex1.branch_type)
    2'd1 : branch1 = !((aluif1.rda == aluif1.rdb) ^ id_ex1.zero); 
    2'd2 : branch1 = !(($signed(aluif1.rda) >= $signed(aluif1.rdb)) ^ id_ex1.zero);
    2'd3 : branch1 = !(($unsigned(aluif1.rda) >= $unsigned(aluif1.rdb)) ^ id_ex1.zero);
  endcase
end
always_comb begin
  branch2 = 1'b0;
  casez(id_ex2.branch_type)
    2'd1 : branch2 = !((aluif2.rda == aluif2.rdb) ^ id_ex2.zero); 
    2'd2 : branch2 = !(($signed(aluif2.rda) >= $signed(aluif2.rdb)) ^ id_ex2.zero);
    2'd3 : branch2 = !(($unsigned(aluif2.rda) >= $unsigned(aluif2.rdb)) ^ id_ex2.zero);
  endcase
end

always_comb begin
    next_pc = pc + 8;
    if((branch1 || branch2) || (id_ex1.jalr || id_ex2.jalr)) begin 
      casez({(branch1 || branch2), id_ex1.jalr || id_ex2.jalr})
        2'd3 : begin
          if(branch1 & id_ex2.jalr) begin
            next_pc = id_ex1.curr_pc + id_ex1.imm_gen;
          end else if (branch2 & id_ex1.jalr) begin
            next_pc = aluif1.result;
          end
        end
        2'd2 : next_pc = (branch1) ? id_ex1.curr_pc + id_ex1.imm_gen : id_ex2.curr_pc + id_ex2.imm_gen;
        2'd1 : next_pc = (id_ex1.jalr) ? aluif1.result : aluif2.result;
      endcase
    end else if (cif1.jump || (cif2.jump && !stall_flag)) begin 
      next_pc = (cif1.jump) ? if_id1.curr_pc + cif1.imm_gen : if_id2.curr_pc + cif2.imm_gen;
    end
end


// TOTAL NUMBER OF LATCHED BITS : 191 (?)


// ********************* START OF EXECUTE : MEMORY (EX/MEM) LATCH ********************* //

  always_ff @(posedge CLK, negedge nRST) begin : EX_MEM_LATCH1  
    if(!nRST) begin
      ex_mem1 <= '0;
    end else if (dpif.dhit & !dpif.ihit) begin
      ex_mem1.memwrite <= 1'b0;
      ex_mem1.memread <= 1'b0;
      ex_mem1.dmemload <= dpif.dmemload;
    end else if (control_pipe) begin
      ex_mem1.instruction <= id_ex1.instruction;
      ex_mem1.write_selected <= write_selected1; // this is put above
      ex_mem1.regwrite <= id_ex1.regwrite; // determine whether or not we write into a register
      ex_mem1.memwrite <= id_ex1.memwrite; // determine whether or not we write into memory
      ex_mem1.memread <= id_ex1.memread; // determine whether or not we are reading from memory
      ex_mem1.memreg <= id_ex1.memreg; // determine whether or not we take the value from memory or the alu result to be written back 
      ex_mem1.halt <= id_ex1.halt;
      ex_mem1.wsel <= id_ex1.wsel;
      ex_mem1.curr_pc <= id_ex1.curr_pc;
      ex_mem1.imm_gen <= id_ex1.imm_gen;
      ex_mem1.dmemstore <= portB1;
      ex_mem1.branch_type <= id_ex1.branch_type;
      ex_mem1.zero <= id_ex1.zero;
      ex_mem1.portA <= aluif1.rda;
      ex_mem1.portB <= aluif1.rdb;
      ex_mem1.datomic <= id_ex1.datomic;
    end
  end

  always_ff @(posedge CLK, negedge nRST) begin : EX_MEM_LATCH2  
    if(!nRST) begin
      ex_mem2 <= '0;
    end else if (dpif.dhit & !dpif.ihit) begin
      ex_mem2.memwrite <= 1'b0;
      ex_mem2.memread <= 1'b0;
      ex_mem2.dmemload <= dpif.dmemload;
    end else if (branch1 & control_pipe) begin
      ex_mem2 <= '0;
    end else if (control_pipe) begin
      ex_mem2.instruction <= id_ex2.instruction;
      ex_mem2.write_selected <= write_selected2; 
      ex_mem2.regwrite <= id_ex2.regwrite; 
      ex_mem2.memwrite <= id_ex2.memwrite; 
      ex_mem2.memread <= id_ex2.memread; 
      ex_mem2.memreg <= id_ex2.memreg; 
      ex_mem2.halt <= id_ex2.halt;
      ex_mem2.wsel <= id_ex2.wsel;
      ex_mem2.curr_pc <= id_ex2.curr_pc;
      ex_mem2.imm_gen <= id_ex2.imm_gen;
      ex_mem2.dmemstore <= portB2;
      ex_mem2.branch_type <= id_ex2.branch_type;
      ex_mem2.zero <= id_ex2.zero;
      ex_mem2.portA <= aluif2.rda;
      ex_mem2.portB <= aluif2.rdb;
      ex_mem2.datomic <= id_ex2.datomic;
    end
  end

assign load1 = (dpif.dhit & dpif.ihit) ? dpif.dmemload : ex_mem1.dmemload;
assign load2 = (dpif.dhit & dpif.ihit) ? dpif.dmemload : ex_mem2.dmemload;
assign dpif.dmemstore = (ex_mem1.memwrite) ? ex_mem1.dmemstore : ex_mem2.dmemstore; 
assign dpif.dmemaddr  = (ex_mem1.memread || ex_mem1.memwrite) ? ex_mem1.write_selected : ex_mem2.write_selected;
assign dpif.dmemREN   = ex_mem1.memread || ex_mem2.memread;
assign dpif.dmemWEN   = ex_mem1.memwrite || ex_mem2.memwrite;
assign dpif.datomic   = ex_mem1.datomic || ex_mem2.datomic;

// TOTAL NUMBER OF LATCHED BITS : 143 (i think sounds correct, bc auipc/lui)

// ********************* START OF MEMORY : WRITEBACK (MEM/WB) LATCH ********************* //

always_ff @(posedge CLK, negedge nRST) begin : MEM_WB_LATCH1
  if(!nRST) begin
    mem_wb1 <= '0;
  end else if (control_pipe) begin
    mem_wb1.instruction <= ex_mem1.instruction;
    mem_wb1.wsel <= ex_mem1.wsel;
    mem_wb1.regwrite <= ex_mem1.regwrite;
    mem_wb1.halt <= ex_mem1.halt;
    mem_wb1.memreg <= ex_mem1.memreg;
    mem_wb1.write_selected <= ex_mem1.write_selected;
    mem_wb1.memload <= load1;
  end
end

always_ff @(posedge CLK, negedge nRST) begin : MEM_WB_LATCH2
  if(!nRST) begin
    mem_wb2 <= '0;
  end else if (control_pipe) begin
    mem_wb2.instruction <= ex_mem2.instruction;
    mem_wb2.wsel <= ex_mem2.wsel;
    mem_wb2.regwrite <= ex_mem2.regwrite;
    mem_wb2.halt <= ex_mem2.halt;
    mem_wb2.memreg <= ex_mem2.memreg;
    mem_wb2.write_selected <= ex_mem2.write_selected;
    mem_wb2.memload <= load2;
  end
end
 
assign rfif.wsel1 = mem_wb1.wsel;
assign rfif.wsel2 = mem_wb2.wsel;


assign rfif.wdat1 = mem_wb1.memreg ? mem_wb1.memload : mem_wb1.write_selected; 
assign rfif.wdat2 = mem_wb2.memreg ? mem_wb2.memload : mem_wb2.write_selected; 

assign rfif.WEN1  = mem_wb1.regwrite;
assign rfif.WEN2  = mem_wb2.regwrite;

always_ff @(posedge CLK, negedge nRST) begin
  if(!nRST) begin
    dpif.halt <= 1'b0;
  end else if (control_pipe) begin
    dpif.halt <= (dpif.halt | ex_mem1.halt | ex_mem2.halt); 
  end
end

// TOTAL NUMBER OF LATCHED BITS : 72

endmodule
