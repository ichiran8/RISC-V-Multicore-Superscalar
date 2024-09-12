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
endmodule