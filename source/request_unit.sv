`include "request_unit_if.vh"
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;
module request_unit(
    input logic CLK, nRST, request_unit_if.ru ruif
);

    always_ff @(posedge CLK, negedge nRST) begin
        if(!nRST) begin
            ruif.dmemREN <= 1'b0;
            ruif.dmemWEN <= 1'b0;
        end else begin
            ruif.dmemREN <= (ruif.dhit) ? 1'b0 : (ruif.ihit) ? ruif.memread : ruif.dmemREN;
            ruif.dmemWEN <= (ruif.dhit) ? 1'b0 : (ruif.ihit) ? ruif.memwrite : ruif.dmemWEN;
        end
    end
    assign ruif.pc_enable = ruif.ihit;
    assign ruif.imemREN = 1'b1;
    
endmodule
