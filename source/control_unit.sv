`include "cpu_types_pkg.vh"
`include "control_unit_if.vh"
`include "register_file_if.vh"
import cpu_types_pkg::*;

module control_unit(
    control_unit_if.cuif cif
);
funct3_r_t funct3_r;
funct3_b_t funct3_b;
funct3_i_t funct3_i;
funct7_r_t funct7_r;
funct7_srla_r_t funct7_srla_r;

assign funct3_r = funct3_r_t'(cif.instruction[14:12]);
assign funct7_r = funct7_r_t'(cif.instruction[31:25]);
assign funct7_srla_r = funct7_srla_r_t'(cif.instruction[31:25]);
assign funct3_i = funct3_i_t'(cif.instruction[14:12]);

assign funct3_b = funct3_b_t'(cif.instruction[14:12]);

//assign cif.funct3_b = funct3_b_t'(cif.instruction[14:12]);
opcode_t opcode;
assign opcode = opcode_t'(cif.instruction[6:0]);

// one more optimization concern is to add another signal for 
assign cif.rsel1 = cif.instruction[19:15];
assign cif.rsel2 = cif.instruction[24:20];
assign cif.wsel = cif.instruction[11:7];
always_comb begin
    cif.imm_gen = 0; // NOT A CONTROL SIGNAL
    cif.alu_src = 1'b0; // choosing whether or not we take a value to r2 or immediate
    // ^ another point of optimization; alu_src is either a don't care, or a 1 except for RTYPE which is 0 and BTYPE which is a 0
    cif.regwrite = 1; // determine whether or not we write into a register
    cif.memwrite = 0; // determine whether or not we write into memory
    cif.memread = 0; // determine whether or not we are reading from memory
    cif.memreg = 0; // determine whether or not we take the value from memory or the alu result to be written back 
    cif.alu_op = ALU_ADD; // alu operation ; NOT A CONTROL SIGNAL (BASICALLY)
    cif.jump = 1'b0; // jump for JAL and JALR (write back block); I think AUIPC too?
    cif.cauipc = 1'b0; //auipc ctrl logic
    cif.halt = 1'b0;
    cif.jalr = 1'b0;
    cif.branch_type = 0;
    cif.lui = 1'b0;
    casez(opcode)
        RTYPE : begin
            //cif.regwrite = 1'b1; 
            casez(funct3_r) 
               // ADD_SUB : cif.alu_op = (funct7_r == ADD) ? ALU_ADD : ALU_SUB;
               ADD_SUB : //cif.alu_op = (cif.instruction[30]) ? ALU_SUB;
                    begin
                        if(cif.instruction[30])  begin
                            cif.alu_op = ALU_SUB;
                        end
                    end
                SLL     : cif.alu_op = ALU_SLL;
                SLT     : cif.alu_op = ALU_SLT;
                SLTU    : cif.alu_op = ALU_SLTU;
                XOR     : cif.alu_op = ALU_XOR;
                SRL_SRA : cif.alu_op = (cif.instruction[30]) ? ALU_SRA : ALU_SRL;
                OR      : cif.alu_op = ALU_OR;
                AND     : cif.alu_op = ALU_AND;
            endcase
        end
        ITYPE : begin
            cif.alu_src = 1'b1; // we are taking the immediate value
            //cif.regwrite = 1'b1; // we are writing back into the register
            cif.imm_gen = {{20{cif.instruction[31]}}, cif.instruction[31:20]};
            casez(funct3_i) 
                //ADDI  : cif.alu_op = ALU_ADD;
                SLLI  : cif.alu_op = ALU_SLL;
                SLTI  : cif.alu_op = ALU_SLT;
                SLTIU : cif.alu_op = ALU_SLTU;
                XORI  : cif.alu_op = ALU_XOR;
                SRLI_SRAI : cif.alu_op = (cif.instruction[30]) ? ALU_SRA : ALU_SRL; // check later
                ORI   : cif.alu_op = ALU_OR;
                ANDI  : cif.alu_op = ALU_AND;
            endcase
        end
        ITYPE_LW : begin
            cif.alu_src = 1'b1; // we are taking the immediate value 
            //cif.regwrite = 1'b1; // we are writing to the register 
            cif.memread = 1'b1; // we are reading from memory
            cif.memreg = 1'b1; // we are trying to take the value that we read from memory and place it into a reg
            cif.imm_gen = {{20{cif.instruction[31]}}, cif.instruction[31:20]};

        end
        JALR : begin // you are jumping to a label and also linking the return address to the jump of the label (?)
                     // JALR also can add using mux because rs1 will be 0 here (default case); make sure to add to write back block
            cif.alu_src = 1'b1; // we are taking the immediate value 
            //cif.regwrite = 1'b1; // we are writing back into a register
            cif.jalr = 1'b1;
            cif.imm_gen = {{20{cif.instruction[31]}}, cif.instruction[31:20]};
        end
        STYPE : begin // SW
            cif.alu_src = 1'b1; // we are taking the immediate value.
            cif.memwrite = 1'b1; // we are writing to memory 
            cif.regwrite = 1'b0;
            cif.imm_gen = {{20{cif.instruction[31]}}, cif.instruction[31:25], cif.instruction[11:7]};

        end 
        BTYPE : begin
            cif.regwrite = 1'b0;
            cif.branch_type = 2'd1;
            //cif.alu_op = ALU_SUB;
            cif.imm_gen = {{20{cif.instruction[31]}}, cif.instruction[7], cif.instruction[30:25], cif.instruction[11:8], 1'b0};
            casez(funct3_b) 
                BEQ : begin
                    cif.alu_op = ALU_SUB;
                    //cif.branch_type = 2'd1;
                end
                BNE : begin
                    cif.alu_op = ALU_SUB;
                    //cif.branch_type = !cif.zero;
                    cif.branch_type = 2'd2;
                end
                BLT : begin 
                    cif.alu_op = ALU_SLT;
                    //cif.branch_type = !cif.zero;
                    cif.branch_type = 2'd2;
                end
                BGE : begin
                     cif.alu_op = ALU_SLT;
                     //cif.branch_type = 2'd1;
                end
                BLTU : begin
                     cif.alu_op = ALU_SLTU;
                     //cif.branch_type = !cif.zero;
                     cif.branch_type = 2'd2;
                end
                BGEU : begin
                    cif.alu_op = ALU_SLTU;
                    //cif.branch_type = 2'd1;
                end
            endcase
        end
        JAL: begin // TO DO, add jump stuff for jalr and JAL; make sure to add to write back block
            cif.jump = 1'b1;
            cif.imm_gen = {{12{cif.instruction[31]}}, cif.instruction[19:12], cif.instruction[20], cif.instruction[30:21], 1'b0};

        end
        LUI : begin
            cif.alu_src = 1'b1;
            cif.lui = 1'b1;
            cif.imm_gen = {cif.instruction[31:12], 12'd0};

        end
        AUIPC : begin // make sure to add to write back block
            cif.alu_src = 1'b1;
            cif.cauipc = 1'b1;
            cif.imm_gen = {cif.instruction[31:12], 12'd0};

        end
        HALT : begin // might remove later since it isnt needed here x.x
            cif.halt = 1'b1;
        end
    endcase
end


endmodule