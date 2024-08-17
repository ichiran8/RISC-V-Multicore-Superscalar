`include "cpu_types_pkg.vh"
`include "control_unit_if.vh"

import cpu_types_pkg.vh::*;
module immediate_generator(
    input logic [31:0] imm_gen,
    control_unit_if.cuif cif
);

always_comb begin
    case(opcode)
        ITYPE, ITYPE_LW, JALR : imm_gen = {{20{inst[31]}}, inst[31:20]};
        STYPE : imm_gen = {{20{inst[31]}}, inst[31:25], inst[11:7]};
        BTYPE : imm_gen = {{20{inst[31]}}, inst[7], inst[30:25], inst [11:8], 1'b0};
        AUIPC, LUIUI : imm_gen = {inst[31:12], 12'd0};
        JAL : imm_gen = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21],1'b0};
        default : imm_gen = '0;
    endcase
end

endmodule