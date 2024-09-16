// import types
import cpu_types_pkg::*;
`include "cpu_types_pkg.vh"

module hazard_unit (
    input logic id_ex_memread,
    input regbits_t id_ex_rd,
    input regbits_t if_id_rs1,
    input regbits_t if_id_rs2,
    output logic PCWrite,
    output logic if_id_write,
    output logic flush_id_ex
);

    always_comb begin
        PCWrite = 1;
        if_id_write = 1;
        flush_id_ex = 0;

        if(id_ex_memread && (id_ex_rd == if_id_rs1 || id_ex_rd == if_id_rs2)) begin
            PCWrite = 0;
            if_id_write = 0;
            flush_id_ex = 1;
        end
    end
    
endmodule