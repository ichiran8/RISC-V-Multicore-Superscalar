`include "cpu_types_pkg.vh"
`include "branch_mux_if.vh"
import cpu_types_pkg::*;

module branch_mux(
    branch_mux_if.br bif
);

    always_comb begin
        bif.branch = 1'b0;
        casez ({bif.zero, bif.branch_type})
            3'd5 : bif.branch = 1'b1;
            3'd2 : bif.branch = 1'b1;
        endcase
    end

    // always_comb begin
    //     bif.branch = 1'b0;
    //     if(bif.branch_bit) begin
    //         casez(bif.branch_type) 
    //             BEQ : bif.branch = (bif.zero);
    //             BNE : bif.branch = (!bif.zero); // double check later
    //             BLT: bif.branch = (!bif.zero); // double check ;later
    //             BGE: bif.branch = (bif.zero);
    //             BLTU: bif.branch = (!bif.zero);
    //             BGEU: bif.branch = (bif.zero);
    //         endcase
    //     end
    // end

            // BEQ: bif.branch = (bif.zero && !bif.overflow);
            // BNE: bif.branch = (!bif.zero && !bif.overflow); // double check later
            // BLT: bif.branch = (bif.result == 1); // double check ;later
            // BGE: bif.branch = (bif.zero || (!bif.negative && !bif.overflow));
            // BLTU: bif.branch = (bif.result == 1);
            // BGEU: bif.branch = (bif.result == 0);
endmodule