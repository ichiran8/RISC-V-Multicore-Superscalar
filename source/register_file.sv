`include "cpu_types_pkg.vh"
`include "register_file_if.vh"
import cpu_types_pkg::*;

module register_file(input logic CLK, nRST, register_file_if.rf rfif);

word_t [31:0] registers, next_registers;




always_ff @(negedge CLK, negedge nRST) begin
    if(!nRST) begin
        registers <= '0;
    end else begin
        // instruction 1
        if (rfif.WEN1 && (rfif.wsel1 != 5'b0 && rfif.wsel1 != rfif.wsel2)) begin
            registers[rfif.wsel1] <= rfif.wdat1;
        end

        // instruction 2
        if (rfif.WEN2 && (rfif.wsel2 != 5'b0)) begin
            registers[rfif.wsel2] <= rfif.wdat2;
        end
    end
end

    // instruction 1
    assign rfif.rdat1_1 = registers[rfif.rsel1_1];
    assign rfif.rdat2_1 = registers[rfif.rsel2_1];

    // instruction 2
    assign rfif.rdat1_2 = registers[rfif.rsel1_2];
    assign rfif.rdat2_2 = registers[rfif.rsel2_2];

endmodule