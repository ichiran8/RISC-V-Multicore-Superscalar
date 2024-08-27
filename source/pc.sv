`include "program_counter_if.vh"
`include "cpu_types_pkg.vh"

import cpu_types_pkg::*;
module pc(
    input logic CLK, nRST, program_counter_if.pcp prog
);

// optimize later when pipelining (remove the next_pc)
    word_t next_pc;
    always_ff @(posedge CLK, negedge nRST) begin
        if(!nRST) begin
            prog.pc <= '0;
        end else if (prog.pc_enable)begin // include the dHit and iHit signals
            prog.pc <= next_pc;
        end
    end

    always_comb begin
        if(prog.jump) begin
            next_pc = prog.pc + prog.result;
        end else if (prog.jalr) begin
            next_pc = prog.result;
        end else if (prog.branch) begin
            next_pc = prog.pc + prog.imm_gen;
        end else begin
            next_pc = prog.pc + 4; 
        end
    end
    assign prog.pc_add = prog.pc + 4;
endmodule
