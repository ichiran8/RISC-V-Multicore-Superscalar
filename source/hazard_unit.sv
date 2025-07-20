// import types
import cpu_types_pkg::*;
`include "cpu_types_pkg.vh"

module hazard_unit (
    input logic id_ex_memread1,

    input regbits_t id_ex_rd1, 

    input regbits_t if_id_rs1_1,
    input regbits_t if_id_rs2_1,

    input logic id_ex_memread2,
    input regbits_t id_ex_rd2,
    input regbits_t if_id_rs1_2,
    input regbits_t if_id_rs2_2,
    input logic jalr,
    output logic PCWrite,
    output logic if_id_write1, if_id_write2,
    // we don't use top right now

    input logic branch,
    input logic jump,
    input logic halt,
    output logic if_flush,
    output logic id_flush1, // indicates that the first instruction has a dependency
    output logic id_flush2 // indicates that the second instruction has a dependency
    //output logic ex_flush //output logic stall
);
    always_comb begin : BRANCH_JUMP_HAZARDING
         if_flush = jump || halt || branch || jalr;
         id_flush1 = jalr || halt || branch;
         id_flush2 = jalr || halt || branch;
        PCWrite = 1;
        if_id_write1 = 1;
        if_id_write2 = 1;
        if(branch || jump || jalr) begin
        end else begin
            if((id_ex_memread1 && ((id_ex_rd1 == if_id_rs1_1) || (id_ex_rd1 == if_id_rs2_1))) || (id_ex_memread2 && ((id_ex_rd2 == if_id_rs1_1) || (id_ex_rd2 == if_id_rs2_1)))) begin
                // Stall
                PCWrite = 0;
                if_id_write1 = 0;
                id_flush1 = 1;

            end
            // Check if the execute stage instr 1 or instr 2 has any dependencies with instr 2 of the decode stage
            if((id_ex_memread1 && ((id_ex_rd1 == if_id_rs1_2) || (id_ex_rd1 == if_id_rs2_2))) || (id_ex_memread2 && ((id_ex_rd2 == if_id_rs1_2) || (id_ex_rd2 == if_id_rs2_2)))) begin
                PCWrite = 0;
                if_id_write2 = 0;
                id_flush2 = 1;
            end
        end
    end    
endmodule