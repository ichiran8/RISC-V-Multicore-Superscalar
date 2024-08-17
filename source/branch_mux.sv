`include "cpu_types_pkg.vh"
`include "branch_mux_if.vh"
import cpu_types_pkg::*;

module branch_mux(
    branch_mux_if.br bif
);

    always_comb begin
        case(bif.branch_type) 
            BEQ: bif.branch = (bif.zero && !bif.overflow);
            BNE: bif.branch = (bif.zero && !bif.overflow); // double check later
            BLT: bif.branch = (bif.result == 1); // double check ;later
            BGE: bif.branch = (bif.zero || (!bif.negative && !bif.overflow));
            BLTU: bif.branch = (bif.result == 1);
            BGEU: bif.branch = (bif.result == 0);
            default : bif.branch = 0;
        endcase
    end

endmodule;