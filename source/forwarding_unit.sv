`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;

module forwarding_unit (
    input regbits_t id_ex_rsel1, id_ex_rsel2, ex_mem_wsel1, ex_mem_wsel2, mem_wb_wsel1, mem_wb_wsel2,
    input logic ex_mem_regwrite1, ex_mem_regwrite2, mem_wb_regwrite1, mem_wb_regwrite2,
    output logic [2:0] forwardA, forwardB
);


/*
Originally
ForwardA/B = 2'd2 (priority) which meant forwarding from the memory stage rather than the write back stage (it has the latest value)
Now, We will need more bits 

2'd1 refers to forwarding from write back stage (instruction 1)
2'd2 refers to forwarding from memory stage (instruction 1)
2'd3 refers to forwarding from memory stage stage (instruction 2)
2'd4 refers to forwarding from writebaclk stage (instruction 2)
*/

// TODO Can 2 instructions try to forward to the same place? Yeah its possible but that would be kinda dumb
always_comb begin
    forwardA = 0;
    forwardB = 0;

    if((ex_mem_regwrite2 && (ex_mem_wsel2 != 0)) && (ex_mem_wsel2 == id_ex_rsel1)) begin
        forwardA = 3'd3;
    end else if ((ex_mem_regwrite1 && (ex_mem_wsel1 != 0)) && (ex_mem_wsel1 == id_ex_rsel1)) begin
        forwardA = 3'd2;
    end else if ((mem_wb_regwrite2 && (mem_wb_wsel2 != 0)) && (mem_wb_wsel2 == id_ex_rsel1)) begin
        forwardA = 3'd4;
    end else if ((mem_wb_regwrite1 && (mem_wb_wsel1 != 0)) && (mem_wb_wsel1 == id_ex_rsel1)) begin
        forwardA = 3'd1;
    end

    if((ex_mem_regwrite2 && (ex_mem_wsel2 != 0)) & (ex_mem_wsel2 == id_ex_rsel2)) begin
        forwardB = 3'd3;
    end else if ((ex_mem_regwrite1 && (ex_mem_wsel1 != 0)) && (ex_mem_wsel1 == id_ex_rsel2)) begin
        forwardB = 3'd2;
    end else if ((mem_wb_regwrite2 && (mem_wb_wsel2 != 0)) && (mem_wb_wsel2 == id_ex_rsel2)) begin
        forwardB = 3'd4;
    end else if ((mem_wb_regwrite1 && (mem_wb_wsel1 != 0)) && (mem_wb_wsel1 == id_ex_rsel2)) begin
        forwardB = 3'd1;
    end
end

endmodule