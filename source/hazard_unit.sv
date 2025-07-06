// import types
import cpu_types_pkg::*;
`include "cpu_types_pkg.vh"

module hazard_unit (





    /* Modifications needed to the hazard unit include duplicating the logic for memory dependency checking
        Need a new logic signal that indicates which instruction had the load use hazard
    */
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
         //ex_flush = 1'b0;
        //if_flush = 0;
        //id_flush = 0;
        //ex_flush = 0;
        //stall = (id_ex_memread && ((id_ex_rd == if_id_rs1) || (id_ex_rd == if_id_rs2)));

        PCWrite = 1;
        if_id_write1 = 1;
        if_id_write2 = 1;
        // Before, if we were branching or JALR, we didn't want the load use hazard to to place
        /*
        Branch and JALR happen in the execute stage (so after id_ex) but load use hazard 
        */
        if(branch || jump || jalr) begin
          //  ex_flush = branch;
           // if_flush = 1'b1;
           // id_flush = 1'b1;
        end else begin
            /*
            Four Cases for load use hazarding to occur 
            1) Flush both latches if stall flag is high and there is a dependency with instr 1 (and or 2)
            2) Flush only the instr 1 latch if instr 1 has a dependency, instr 2 does not have a dependency, and stall flag is not high
            3) Flush 
            */
            // Check if the execute stage instr 1 or instr 2 has any dependencies with instr 1 of the decode stage
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


    
    // ld hazard
    // always_comb begin : LD_HAZARDING
    //     PCWrite = 1;
    //     if_id_write = 1; 
    //     flush_id_ex = 0; <- id flush

    //     if(id_ex_memread && (id_ex_rd == if_id_rs1 || id_ex_rd == if_id_rs2)) begin
    //         PCWrite = 0;
    //         if_id_write = 0;
    //         flush_id_ex = 1;
    //     end
    // end
    
endmodule