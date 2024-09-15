`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

module forwarding_unit (
    input regbits_t id_ex_rsel1, id_ex_rsel2, ex_mem_wsel, mem_wb_wsel,
    input logic ex_mem_regwrite, mem_wb_regwrite,
    output logic [1:0] forwardA, forwardB
);

always_comb begin
    forwardA = 0;
    forwardB = 0;
    if((ex_mem_regwrite && ex_mem_wsel) || (mem_wb_regwrite && mem_wb_wsel)) begin
        if(ex_mem_wsel == id_ex_rsel1) begin
            forwardA = 2'd2;
        end else if (mem_wb_wsel == id_ex_rsel1) begin
            forwardA = 2'd1;
        end

        if (ex_mem_wsel == id_ex_rsel2) begin 
            forwardB = 2'd2;
        end else if (mem_wb_wsel == id_ex_rsel1) begin
            forwardB = 2'd1;
        end

    end
end

endmodule