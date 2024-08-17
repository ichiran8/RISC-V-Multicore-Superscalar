`include "program_counter.vh"
module pc(
    input logic CLK, nRST, program_counter_if.pc prog
);

// optimize later when pipelining (remove the next_pc)
    word_t next_pc;
    always_ff @(posedge CLK, negedge nRST) begin
        if(!nRST) begin
            prog.pc <= '0;
        end else if (prog.opcode != 7'b1111111)begin
            prog.pc <= next_pc;
        end
    end

    always_comb begin
        if(prog.branch || prog.jump) begin
            next_pc = prog.pc + prog.result;
        end else begin
            next_pc = prog.pc + 4; 
        end
    end

endmodule
