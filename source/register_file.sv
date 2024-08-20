`include "cpu_types_pkg.vh"
`include "register_file_if.vh"
import cpu_types_pkg::*;

module register_file(input logic CLK, nRST, register_file_if.rf rfif);

logic [31:0] [31:0] registers;

always_ff @(posedge CLK, negedge nRST) begin
    if(!nRST) begin
        registers <= '0;
    end else if (rfif.WEN && !(rfif.wsel == 5'b0)) begin
        registers[rfif.wsel] <= rfif.wdat;
    end
end

always_comb begin
    rfif.rdat1 = registers[rfif.rsel1];
    rfif.rdat2 = registers[rfif.rsel2];
end

endmodule