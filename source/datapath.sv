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

word_t next_pc, pc, portB;
logic switch1;


// ********************* MISC *************************** //

register_file rf(CLK, nRST, rfif);
alu alu(aluif);
control_unit cu1(cif);
request_unit ru1(CLK, nRST, ru);
assign dpif.imemREN = ru.imemREN;
assign dpif.dmemREN = ru.dmemREN;
assign dpif.dmemWEN = ru.dmemWEN;
assign dpif.imemaddr = pc;
assign ru.ihit = dpif.ihit;
assign ru.dhit = dpif.dhit;
assign rfif.rsel1 = cif.rsel1;
assign rfif.rsel2 = cif.rsel2;
assign dpif.dmemstore = ru.dmemstore; 

//********************** PROGRAM COUNTER ************************** //

always_ff @(posedge CLK, negedge nRST) begin
  if(!nRST) begin
    pc <= '0;
  end else begin // include the dHit and iHit signals
    pc <= next_pc;//(ru.pc_enable) ? next_pc : pc;
  end
end


  //********************* START OF INSTRUCTION FETCH : INSTRUCTION DECODE (IF/ID) LATCH *********************//

  
  typedef struct packed {
    word_t instruction, pc_add;
  } if_id_t;

  if_id_t if_id;

  always_ff @(posedge CLK, negedge nRST) begin : IF_ID_LATCH
    if(!nRST) begin // add flush here
      if_id <= '0;
    end else (dpif.ihit) begin
      if_id.instruction <= dpif.imemload;
      if_id.pc_add <= pc + 4;
    end
  end
assign cif.instruction = if_id.instruction;

// TOTAL NUMBER OF LATCHED BITS : 64

//********************* START OF INSTRUCTION DECODE : EXECUTE (ID/EX) LATCH ********************* //

  typedef struct packed {
    word_t rdat1, rdat2, pc_add, imm_gen;
    aluop_t alu_op;
    logic alu_src, regwrite, memwrite, memread, memreg, jump, auipc, halt, jalr, lui; 
    regbits_t wsel;
    logic [1:0] branch_type;
  } id_ex_t;

  if_ex_t id_ex;

  always_ff @(posedge CLK, negedge nRST) begin : ID_EX_LATCH
    if(!nRST) begin
      id_ex <= '0;
    end else if (dpif.ihit) begin
      id_ex.rdat1 <= rfif.rdat1;
      id_ex.rdat2 <= rif.rdat2;
      id_ex.pc_add <= if_id.pc_add;
      id_ex.imm_gen <= cif.imm_gen; 
      id_ex.alu_src <= cif.alu_src; 
      id_ex.regwrite <= cif.regwrite; 
      id_ex.memwrite <= cif.memwrit3e; 
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

assign portB = (id_ex.alu_src) ? id_ex.imm_gen : id_ex.rdat2;
assign aluif.rda = id_ex.rdat1;
assign aluif.rdb = portB;
assign aluif.alu_op = id_ex.alu_op;

// TOTAL NUMBER OF LATCHED BITS : 149 (?)


// ********************* START OF EXECUTE : MEMORY (EX/MEM) LATCH ********************* //

  typedef struct packed {
    word_t alu_result, pc_add, imm_gen, rdat2;
    logic regwrite, memwrite, memread, memreg, jump, auipc, halt, jalr, lui, zero; 
    regbits_t wsel;
    logic [1:0] branch_type;
  } mem_ex_t;

   mem_ex_t mem_ex;

  always_ff @(posedge CLK, negedge nRST) begin : MEM_EX_LATCH
    if(!nRST) begin
      mem_ex <= '0;
    end else if (dpif.ihit) begin
      mem_ex.rdat2 <= id_ex.rdat2; 
      mem_ex.alu_result <= aluif.result;
      mem_ex.pc_add <= id_ex.pc_add;
      mem_ex.imm_gen <= id_ex.imm_gen; // NOT A CONTROL SIGNAL
      mem_ex.regwrite <= id_ex.regwrite; // determine whether or not we write into a register
      mem_ex.memwrite <= id_ex.memwrit3e; // determine whether or not we write into memory
      mem_ex.memread <= id_ex.memread; // determine whether or not we are reading from memory
      mem_ex.memreg <= id_ex.memreg; // determine whether or not we take the value from memory or the alu result to be written back 
      mem_ex.jump <= id_ex.jump; // jump for JAL and JALR (write back block); I think AUIPC too?
      mem_ex.auipc <= id_ex.cauipc; //auipc ctrl logic
      mem_ex.halt <= id_ex.halt;
      mem_ex.jalr <= id_ex.jalr;
      mem_ex.branch_type <= id_ex.branch_type;
      mem_ex.lui <= id_ex.lui;
      mem_ex.zero <= aluif.zero;
      mem_ex.wsel <= id_ex.wsel;
    end
  end
 
assign ru.rdat2 = mem_ex.rdat2; //
assign dpif.dmemaddr = mem_ex.result;
assign ru.memread = mem_ex.memread;
assign ru.memwrite = mem_ex.memwrite;


always_comb begin
  next_pc = pc;
  if(ru.pc_enable) begin
    next_pc = mem_ex.pc_add; // Don't know if I need this here tbh
    casez({mem_ex.jump, mem_ex.jalr, mem_ex.branch_type})      
        4'b1000 : next_pc = pc + mem_ex.imm_gen;
        4'b0100 : next_pc = mem_ex.result;
        4'b0010 : next_pc = !(mem_ex.zero) ? pc + cif.imm_gen : mem_ex.pc_add;
        4'b0001 : next_pc = (mem_ex.zero) ? pc + cif.imm_gen : mem_ex.pc_add;
        default : next_pc = mem_ex.pc_add;
      endcase
    end
end

// TOTAL NUMBER OF LATCHED BITS : 145

// ********************* START OF MEMORY : WRITEBACK (MEM/WB) LATCH ********************* //

/*
  Some notes for Mr. Ahmet Oguz, make sure that you modify the halt signal, we need to use the "mem_wb.halt" signal rather
  than the cif.halt signal down below. 
  pc_add and rdat2 drop out, same with branch_type, I think the rest stay?

  JAL, JALR, memreg, memwrite, cauipc, and lui are ALL signals that are involved with the write back stage

  I can condense every control signal we have into like a [2:0] or even [3:0] signal if needed for it to be concise, but you would lose out
  on dropping signals along the way
  such as Branch.

  I need someone to double check whether or not the number of latched bits in the fourth stage is correct; I cannot seem to drop any bits more than 2?
*/

assign rfif.wsel = cif.wsel;




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


always_ff @(posedge CLK, negedge nRST) begin
  if(!nRST) begin
    dpif.halt <= 1'b0;
  end else begin
    dpif.halt <= (dpif.halt | cif.halt);
  end
end



endmodule
