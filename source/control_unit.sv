`include "cpu_types_pkg.vh"
`include "control_unit_if.vh"
`include "register_file_if.vh"
import cpu_types_pkg::*;

module control_unit(
    control_unit_if.cuif cif
);
funct3_r_t funct3_r;
//funct3_b_t funct3_b;
funct3_i_t funct3_i;
funct3_s_t funct3_s;
funct7_r_t funct7_r;
funct7_srla_r_t funct7_srla_r;
funct3_ld_i_t funct3_ld_i;
assign cif.opcode = opcode_t'(cif.instruction[6:0]);
always_comb begin
    cif.rsel1 = cif.instruction[19:15];
    cif.rsel2 = cif.instruction[24:20];
    cif.wsel = cif.instruction[11:7];
    funct3_r = funct3_r_t'('0); // need to fix
    funct7_r = funct7_r_t'('0); // ^
    funct3_i = funct3_i_t'('0);
    funct3_s = funct3_s_t'('0);
    funct7_srla_r = funct7_srla_r_t'('0);
    cif.funct3_b = funct3_b_t'(3'h2); // ^
    funct3_ld_i = funct3_ld_i_t'('0);
    cif.imm_gen = '0;
    casex(cif.opcode)
        RTYPE : begin
            funct3_r = funct3_r_t'(cif.instruction[14:12]);
            funct7_r = funct7_r_t'(cif.instruction[31:25]);
            funct7_srla_r = funct7_srla_r_t'(cif.instruction[31:25]);
        end
        ITYPE, ITYPE_LW, JALR : begin
            cif.rsel2 = '0;
            funct3_i = funct3_i_t'(cif.instruction[14:12]);
            funct3_ld_i = funct3_ld_i_t'(cif.instruction[14:12]);
            cif.imm_gen = {{20{cif.instruction[31]}}, cif.instruction[31:20]};
        end
        STYPE : begin
            cif.wsel = '0;
            cif.imm_gen = {{20{cif.instruction[31]}}, cif.instruction[31:25], cif.instruction[11:7]};
            funct3_s = funct3_s_t'(cif.instruction[14:12]);
        end
        BTYPE : begin
            cif.wsel = '0;
            cif.imm_gen = {{20{cif.instruction[31]}}, cif.instruction[7], cif.instruction[30:25], cif.instruction[11:8], 1'b0};
            cif.funct3_b = funct3_b_t'(cif.instruction[14:12]);
        end
        JAL : begin
            cif.rsel1 = '0;
            cif.rsel2 = '0;
            cif.imm_gen = {{12{cif.instruction[31]}}, cif.instruction[19:12], cif.instruction[20], cif.instruction[30:21],1'b0};
        end
        LUI, AUIPC : begin
            cif.rsel1 = '0;
            cif.rsel2 = '0;
            cif.imm_gen = {cif.instruction[31:12], 12'd0};
        end
        HALT : begin
            cif.rsel1 = '0;
            cif.rsel2 = '0;
            cif.wsel = '0;
            cif.imm_gen = '0;
        end
        default : begin
            cif.rsel1 = cif.instruction[19:15];
            cif.rsel2 = cif.instruction[24:20];
            cif.wsel = cif.instruction[11:7];
            funct3_r = funct3_r_t'('0); // need to fix
            funct7_r = funct7_r_t'('0); // ^
            funct3_i = funct3_i_t'('0);
            funct3_s = funct3_s_t'('0);
            funct7_srla_r = funct7_srla_r_t'('0);
            cif.funct3_b = funct3_b_t'(3'h2); // ^
            funct3_ld_i = funct3_ld_i_t'('0);
            cif.imm_gen = '0;
        end
    endcase
end


// one more optimization concern is to add another signal for 
always_comb begin
    cif.alu_src = 0; // choosing whether or not we take a value to r2 or immediate
    cif.regwrite = 0; // determine whether or not we write into a register
    cif.memwrite = 0; // determine whether or not we write into memory
    cif.memread = 0; // determine whether or not we are reading from memory
    cif.memreg = 0; // determine whether or not we take the value from memory or the alu result to be written back 
    cif.alu_op = ALU_ADD; // alu operation
    cif.jump = 1'b0; // jump for JAL and JALR (write back block); I think AUIPC too?
    cif.cauipc = 1'b0; //auipc ctrl logic
    cif.halt = 1'b0;
    cif.jalr = 1'b0;
    casex(cif.opcode)
        RTYPE : begin
            cif.alu_src = 1'b0;
            cif.regwrite = 1'b1;
            cif.memwrite = 1'b0;
            cif.memread = 1'b0;
            cif.memreg = 1'b0;
            cif.alu_op = ALU_ADD;
            cif.jump = 1'b0;
            cif.cauipc = 1'b0;
            cif.halt = 1'b0;
            cif.jalr = 1'b0;
            casex(funct3_r) 
                ADD_SUB : cif.alu_op = (funct7_r == ADD) ? ALU_ADD : ALU_SUB;
                SLL     : cif.alu_op = ALU_SLL;
                SLT     : cif.alu_op = ALU_SLT;
                SLTU    : cif.alu_op = ALU_SLTU;
                XOR     : cif.alu_op = ALU_XOR;
                SRL_SRA : cif.alu_op = (funct7_srla_r == SRA) ? ALU_SRA : ALU_SRL;
                OR      : cif.alu_op = ALU_OR;
                AND     : cif.alu_op = ALU_AND;
            endcase
        end
        ITYPE : begin
            cif.alu_src = 1'b1; // we are taking the immediate value
            cif.regwrite = 1'b1; // we are writing back into the register
            cif.memwrite = 1'b0; // we are not writing to memory 
            cif.memread = 1'b0; // we are not reading from memory
            cif.memreg = 1'b0; // we are not taking the value from memory to be written back
            cif.alu_op = ALU_ADD; // just default 
            cif.jump = 1'b0; // not jumping 
            cif.cauipc = 1'b0; // no auipc
            cif.halt = 1'b0; // no halt
            cif.jalr = 1'b0;
            case(funct3_i) 
                ADDI  : cif.alu_op = ALU_ADD;
                SLLI  : cif.alu_op = ALU_SLL;
                SLTI  : cif.alu_op = ALU_SLT;
                SLTIU : cif.alu_op = ALU_SLTU;
                XORI  : cif.alu_op = ALU_XOR;
                SRLI_SRAI : cif.alu_op = (cif.instruction[30]) ? ALU_SRA : ALU_SRL; 
                ORI   : cif.alu_op = ALU_OR;
                ANDI  : cif.alu_op = ALU_AND;
            endcase
        end
        ITYPE_LW : begin
            cif.alu_src = 1'b1; // we are taking the immediate value 
            cif.regwrite = 1'b1; // we are writing to the register 
            cif.memwrite = 1'b0; // we are not writing to memory 
            cif.memread = 1'b1; // we are reading from memory
            cif.memreg = 1'b1; // we are trying to take the value that we read from memory and place it into a reg
            cif.alu_op = ALU_ADD; // we have to add the address 
            cif.jump = 1'b0; // we are not going to jump 
            cif.cauipc = 1'b0; // no cauipc
            cif.jalr = 1'b0;
        end
        JALR : begin // you are jumping to a label and also linking the return address to the jump of the label (?)
                     // JALR also can add using mux because rs1 will be 0 here (default case); make sure to add to write back block
            cif.alu_src = 1'b1; // we are taking the immediate value 
            cif.regwrite = 1'b1; // we are writing back into a register
            cif.memwrite = 1'b0; // we are not writing to memory 
            cif.memread = 1'b0; // we are not reading from memory 
            cif.memreg = 1'b0; // we are taking the alu result value, and not the memory result 
            cif.alu_op = ALU_ADD; // we are adding to produce the offset in memory 
            cif.jump = 1'b0; // we are jumping 
            cif.cauipc = 1'b0; // no cauipc
            cif.halt = 1'b0; // no halt
            cif.jalr = 1'b1;
        end
        STYPE : begin // SW
            cif.alu_src = 1'b1; // we are taking the immediate value.
            cif.regwrite = 1'b0; // we are not writing into a register 
            cif.memwrite = 1'b1; // we are writing to memory 
            cif.memread = 1'b0; // we are not reading from memory 
            cif.memreg = 1'b0; // dont care since we are not writing into a register
            cif.alu_op = ALU_ADD;
            cif.jump = 1'b0;
            cif.cauipc = 1'b0;
            cif.halt = 1'b0;
            cif.jalr = 1'b0;
        end 
        BTYPE : begin
            cif.alu_src = 1'b0;
            cif.regwrite = 1'b0;
            cif.memwrite = 1'b0;
            cif.memread = 1'b0;
            cif.memreg = 1'b0;
            cif.alu_op = ALU_ADD;
            cif.jump = 1'b0;
            cif.cauipc = 1'b0;
            cif.halt = 1'b0;
            cif.jalr = 1'b0;
            case(cif.funct3_b) 
                BEQ : cif.alu_op = ALU_SUB;
                BNE : cif.alu_op = ALU_SUB;
                BLT : cif.alu_op = ALU_SLT;
                BGE : cif.alu_op = ALU_SLT;
                BLTU : cif.alu_op = ALU_SLTU;
                BGEU : cif.alu_op = ALU_SLTU;
            endcase
        end
        JAL: begin // TO DO, add jump stuff for jalr and JAL; make sure to add to write back block
            cif.alu_src = 1'b1;
            cif.regwrite = 1'b1;
            cif.memwrite = 1'b0;
            cif.memread = 1'b0;
            cif.memreg = 1'b0;
            cif.alu_op = ALU_ADD;
            cif.jump = 1'b1;
            cif.cauipc = 1'b0;
            cif.halt = 1'b0;
            cif.jalr = 1'b0;
        end
        LUI : begin
            cif.alu_src = 1'b1;
            cif.regwrite = 1'b1;
            cif.memwrite = 1'b0;
            cif.memread = 1'b0;
            cif.memreg = 1'b0;
            cif.alu_op = ALU_ADD;
            cif.jump = 1'b0;
            cif.cauipc = 1'b0;
            cif.halt = 1'b0;
            cif.jalr = 1'b0;
        end
        AUIPC : begin // make sure to add to write back block
            cif.alu_src = 1'b1;
            cif.regwrite = 1'b1;
            cif.memwrite = 1'b0;
            cif.memread = 1'b0;
            cif.memreg = 1'b0;
            cif.alu_op = ALU_ADD;
            cif.jump = 1'b0;
            cif.cauipc = 1'b1;
            cif.halt = 1'b0;
            cif.jalr = 1'b0;
        end
        HALT : begin // might remove later since it isnt needed here x.x
            cif.alu_src = 1'b0;
            cif.regwrite = 1'b0;
            cif.memwrite = 1'b0;
            cif.memread = 1'b0;
            cif.memreg = 1'b0;
            cif.alu_op = ALU_ADD;
            cif.jump = 1'b0;
            cif.cauipc = 1'b0;
            cif.halt = 1'b1;
            cif.jalr = 1'b0;
        end
        default : begin
            cif.alu_src = 1'b0; // not done ; debating on using it in the ctrl unit or simply the datapath
            cif.regwrite = 1'b0; // done (this is WEN) ; register file
            cif.memwrite = 1'b0; // done ; ru 
            cif.memread = 1'b0; // done ; ru
            cif.memreg = 1'b0; // done ; write bacl
            cif.alu_op = ALU_ADD; // alu
            cif.jump = 1'b0; // program counter
            cif.cauipc = 1'b0; // done ; wruite back
            cif.halt = 1'b0;
            cif.jalr = 1'b0;
        end
    endcase
end


endmodule