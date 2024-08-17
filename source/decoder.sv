`include "control_unit_if.vh"
`include "cpu_types_pkg.vh"
`include "register_file_if.vh"
import cpu_types_pkg::*;

module decoder(
    input word_t instruction,
    control_unit_if.dec cif,
    register_file_if.rf rfif
);

assign cif.opcode = instruction[6:0];
always_comb begin
    rfif.rsel1 = '0;
    rfif.rsel2 = '0;
    rfif.wsel = '0;
    cif.funct3_r = $funct3_r_t('0);
    cif.funct7_r = $funct7_r_t('0);
    cif.funct3_i = $funct3_i_t('0);
    cif.funct3_s = $funct3_s_t('0);
    cif.funct3_b = $funct3_b_t('0);
    cif.imm_i = '0;
    cif.imm_s_b = '0;
    cif_imm_u_j = '0;
    case(cif.opcode)
        RTYPE : begin
            rfif.rsel1 = instruction[19:15];
            rfif.rsel2 = instruction[24:20];
            rfif.wsel = instruction[11:7];
            cif.funct3_r = $funct3_r_t(instruction[14:12]);
            cif.funct7_r = $funct7_r_t(instruction[31:25]);
        end
        ITYPE, ITYPE_LW, JALR : begin
            rfif.rsel1 = instruction[19:15];
            rfif.rsel2 = '0;
            rfif.wsel = instruction[11:7];
            cif.funct3_i = $funct3_i_t(instruction[14:12]);
            cif.funct3_ld_i = $funct3_ld_i_t(instruction[14:12]);
            cif.imm_i = instruction[31:20];
        end
        STYPE : begin
            rfif.rsel1 = instruction[19:15];
            rfif.rsel2 = instruction[24:20];
            rfif.wsel = '0;
            cif.imm_s_b = {instruction[31:25], instruction[11:7]};
            cif.funct3_s = instruction[14:12];
        end
        BTYPE : begin
            rfif.rsel1 = instruction[19:15];
            rfif.rsel2 = instruction[24:20];
            rfif.wsel = '0;
            cif.imm_s_b = {instruction[31:25], instruction[11:7]};
            cif.funct3_b = instruction[14:12];
        end
        JAL : begin
            rfif.rsel1 = '0;
            rfif.rsel2 = '0;
            rfif.wsel = instruction[11:7];
            cif.imm_u_uj = instruction[31:12];
        end
        LUI, AUIPC : begin
            rfif.rsel1 = '0;
            rfif.rsel2 = '0;
            rfif.wsel = instruction[11:7];
            cif.imm_u_uj = instruction[31:12];
        end
        HALT : begin
            rfif.rsel1 = '0;
            rfif.rsel2 = '0;
            rfif.wsel = '0;
        end
        default : begin
            rfif.rsel1 = '0;
            rfif.rsel2 = '0;
            rfif.wsel = '0;
            cif.funct3_r = $funct3_r_t('0);
            cif.funct7_r = $funct7_r_t('0);
            cif.funct3_i = $funct3_i_t('0);
            cif.funct3_s = $funct3_s_t('0);
            cif.funct3_b = $funct3_b_t('0);
            cif.imm_i = '0;
            cif.imm_s_b = '0;
            cif_imm_u_j = '0;
        end
    endcase
end

endmodule