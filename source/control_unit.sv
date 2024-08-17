`include "cpu_types_pkg.vh"
`include "control_unit_if.vh"
`include "register_file_if.vh"
import cpu_types_pkg::*;

module control_unit(
    control_unit_if.cuif cif
);

assign cif.opcode = opcode_t'(cif.instruction[6:0]);
always_comb begin
    cif.rsel1 = cif.instruction[19:15];
    cif.rsel2 = cif.instruction[24:20];
    cif.wsel = cif.instruction[11:7];
    cif.funct3_r = funct3_r_t'('0);
    cif.funct7_r = funct7_r_t'('0);
    cif.funct3_i = funct3_i_t'('0);
    cif.funct3_s = funct3_s_t'('0);
    cif.funct3_b = funct3_b_t'('0);
    cif.imm_i = '0;
    cif.imm_s_b = '0;
    cif.imm_u_j = '0;
    case(cif.opcode)
        RTYPE : begin
            cif.funct3_r = funct3_r_t'(cif.instruction[14:12]);
            cif.funct7_r = funct7_r_t'(cif.instruction[31:25]);
        end
        ITYPE, ITYPE_LW, JALR : begin
            cif.rsel2 = '0;
            cif.funct3_i = funct3_i_t'(cif.instruction[14:12]);
            cif.funct3_ld_i = funct3_ld_i_t'(cif.instruction[14:12]);
            cif.imm_i = cif.instruction[31:20];
        end
        STYPE : begin
            cif.wsel = '0;
            cif.imm_s_b = {cif.instruction[31:25], cif.instruction[11:7]};
            cif.funct3_s = funct3_s_t'(cif.instruction[14:12]);
        end
        BTYPE : begin
            cif.wsel = '0;
            cif.imm_s_b = {cif.instruction[31:25], cif.instruction[11:7]};
            cif.funct3_b = funct3_b_t'(cif.instruction[14:12]);
        end
        JAL : begin
            cif.rsel1 = '0;
            cif.rsel2 = '0;
            cif.imm_u_j = cif.instruction[31:12];
        end
        LUI, AUIPC : begin
            cif.rsel1 = '0;
            cif.rsel2 = '0;
            cif.imm_u_j = cif.instruction[31:12];
        end
        HALT : begin
            cif.rsel1 = '0;
            cif.rsel2 = '0;
            cif.wsel = '0;
        end
        default : begin
            cif.rsel1 = cif.instruction[19:15];
            cif.rsel2 = cif.instruction[24:20];
            cif.wsel = cif.instruction[11:7];
            cif.funct3_r = funct3_r_t'('0);
            cif.funct7_r = funct7_r_t'('0);
            cif.funct3_i = funct3_i_t'('0);
            cif.funct3_s = funct3_s_t'('0);
            cif.funct3_b = funct3_b_t'('0);
            cif.imm_i = '0;
            cif.imm_s_b = '0;
            cif.imm_u_j = '0;
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
    case(cif.opcode)
        RTYPE : begin
            cif.alu_src = 1'b0;
            cif.regwrite = 1'b1;
            cif.memwrite = 1'b0;
            cif.memreg = 1'b0;
            case(cif.funct3_r) 
                ADD_SUB : cif.alu_op = (cif.funct7_r == ADD) ? ALU_ADD : ALU_SUB;
                SLL     : cif.alu_op = ALU_SLL;
                SLT     : cif.alu_op = ALU_SLT;
                SLTU    : cif.alu_op = ALU_SLTU;
                XOR     : cif.alu_op = ALU_XOR;
                SRL_SRA : cif.alu_op = (cif.funct7_srla_r == SRA) ? ALU_SRA : ALU_SRL;
                OR      : cif.alu_op = ALU_OR;
                AND     : cif.alu_op = ALU_AND;
                default : begin
                    cif.alu_src = 1'b0;
                    cif.regwrite = 1'b1;
                    cif.memwrite = 1'b0;
                    cif.memread = 1'b0;
                    cif.memreg = 1'b0;
                    cif.alu_op = ALU_ADD;
                    cif.jump = 1'b0;
                end
            endcase
        end
        ITYPE : begin
            case(cif.funct3_i) 
                ADDI  : cif.alu_op = ALU_ADD;
                SLLI  : cif.alu_op = ALU_SLL;
                SLTI  : cif.alu_op = ALU_SLT;
                SLTIU : cif.alu_op = ALU_SLTU;
                XORI  : cif.alu_op = ALU_XOR;
                SRLI_SRAI : cif.alu_op = (cif.imm_i[10]) ? ALU_SRL : ALU_SRA; 
                ORI   : cif.alu_op = ALU_OR;
                ANDI  : cif.alu_op = ALU_AND;
                default : begin
                    cif.alu_src = 1'b1;
                    cif.regwrite = 1'b1;
                    cif.memwrite = 1'b0;
                    cif.memread = 1'b0;
                    cif.memreg = 1'b0;
                    cif.alu_op = ALU_ADD;
                    cif.jump = 1'b0;
                end
            endcase
        end
        ITYPE_LW : begin
            cif.alu_src = 1'b1;
            cif.regwrite = 1'b1;
            cif.memwrite = 1'b0;
            cif.memread = 1'b1;
            cif.memreg = 1'b1; // we are trying to take the value that we read from memory and place it into a reg
            cif.alu_op = ALU_ADD;
            cif.jump = 1'b0;
        end
        JALR : begin // you are jumping to a label and also linking the return address to the jump of the label (?)
                     // JALR also can add using mux because rs1 will be 0 here (default case); make sure to add to write back block
            cif.alu_src = 1'b1;
            cif.regwrite = 1'b1;
            cif.memwrite = 1'b0;
            cif.memread = 1'b0;
            cif.memreg = 1'b0;
            cif.alu_op = ALU_ADD;
            cif.jump = 1'b1;
        end
        STYPE : begin // SW
            cif.alu_src = 1'b1;
            cif.regwrite = 1'b0;
            cif.memwrite = 1'b1;
            cif.memread = 1'b0;
            cif.memreg = 1'bx;
            cif.alu_op = ALU_ADD;
            cif.jump = 1'b0;
        end 
        BTYPE : begin
            case(cif.funct3_b) 
                BEQ : cif.alu_op = ALU_SUB;
                BNE : cif.alu_op = ALU_SUB;
                BLT : cif.alu_op = ALU_SLT;
                BGE : cif.alu_op = ALU_SLT;
                BLTU : cif.alu_op = ALU_SLTU;
                BGEU : cif.alu_op = ALU_SLTU;
                default : begin
                    cif.alu_src = 1'b1;
                    cif.regwrite = 1'b0;
                    cif.memwrite = 1'b0;
                    cif.memread = 1'b0;
                    cif.memreg = 1'b0;
                    cif.alu_op = ALU_ADD;
                    cif.jump = 1'b0;
                end
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
        end
        LUI : begin
            cif.alu_src = 1'b1;
            cif.regwrite = 1'b1;
            cif.memwrite = 1'b0;
            cif.memread = 1'b0;
            cif.memreg = 1'b0;
            cif.alu_op = ALU_ADD;
            cif.jump = 1'b0;
        end
        AUIPC : begin // make sure to add to write back block
            cif.alu_src = 1'b1;
            cif.regwrite = 1'b1;
            cif.memwrite = 1'b0;
            cif.memread = 1'b0;
            cif.memreg = 1'b0;
            cif.alu_op = ALU_ADD;
            cif.jump = 1'b1;
        end
        HALT : begin // might remove later since it isnt needed here x.x
            cif.alu_src = 1'bx;
            cif.regwrite = 1'bx;
            cif.memwrite = 1'bx;
            cif.memread = 1'bx;
            cif.memreg = 1'bx;
            cif.alu_op = ALU_ADD;
            cif.jump = 1'bx;
        end
        default : begin
            cif.alu_src = 1'b0;
            cif.regwrite = 1'b0;
            cif.memwrite = 1'b0;
            cif.memread = 1'b0;
            cif.memreg = 1'b0;
            cif.alu_op = ALU_ADD;
            cif.jump = 1'b0;
        end
    endcase
end

endmodule