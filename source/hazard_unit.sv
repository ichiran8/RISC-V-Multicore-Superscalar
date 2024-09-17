// import types
import cpu_types_pkg::*;
`include "cpu_types_pkg.vh"

module hazard_unit (
    // input logic id_ex_memread,
    // input regbits_t id_ex_rd,
    // input regbits_t if_id_rs1,
    // input regbits_t if_id_rs2,
    // output logic PCWrite,
    // output logic if_id_write,
    // output logic flush_id_ex,
    // we don't use top right now

    input logic branch,
    input logic jump,
    input logic halt,
    output logic if_flush,
    output logic id_flush,
    output logic ex_flush
);
    always_comb begin : BRANCH_JUMP_HAZARDING
        if_flush = 0;
        id_flush = 0;
        ex_flush = 0;

        if(branch | jump | halt) begin
            if_flush = 1;
            id_flush = 1;
            ex_flush = 1;
        end
    end

    // ld hazard
    // always_comb begin : LD_HAZARDING
    //     PCWrite = 1;
    //     if_id_write = 1;
    //     flush_id_ex = 0;

    //     if(id_ex_memread && (id_ex_rd == if_id_rs1 || id_ex_rd == if_id_rs2)) begin
    //         PCWrite = 0;
    //         if_id_write = 0;
    //         flush_id_ex = 1;
    //     end
    // end
    
endmodule