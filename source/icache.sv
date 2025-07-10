`include "cpu_types_pkg.vh"
`include "caches_if.vh"
`include "datapath_cache_if.vh"

import cpu_types_pkg::*;

module icache(
    input logic CLK, nRST,
    datapath_cache_if.icache dpif,
    caches_if.icache caif
);



    icache_frame [15:0] cache;
    icache_frame [15:0] next_cache;
    typedef enum logic [1:0] {IDLE, MEM1, MEM2} state_t;

    state_t state, next_state;
    icachef_t instr1, instr2;

    assign instr1 = dpif.imemaddr1;
    assign instr2 = dpif.imemaddr2;
    

    logic next_iREN;
    word_t next_iaddr;
    logic [3:0] addr_index;
    logic [24:0] addr_tag;
    logic [1:0] addr_bytoff;

    logic ihit1, ihit2;
    always_ff @(posedge CLK, negedge nRST) begin
        if(!nRST) begin
            state <= IDLE;
            cache <= '0;
            caif.iREN <= '0;
            caif.iaddr <= '0;
        end else begin
            state <= next_state;
            cache <= next_cache;
            caif.iREN <= next_iREN;
            caif.iaddr <= next_iaddr;
        end
    end

    assign addr_tag = caif.iaddr[31:7];
    assign addr_index = caif.iaddr[6:3];
    assign addr_bytoff = caif.iaddr[1:0];
    always_comb begin // state machine
        next_state = state;
        next_cache = cache;
        next_iaddr = caif.iaddr;
        next_iREN = caif.iREN;
        casez(state)
            IDLE : begin
                 if (!dpif.ihit && dpif.imemREN) begin
                    next_state = MEM1;
                    next_iREN = 1'b1;  
                    next_iaddr = (!ihit1) ? {dpif.imemaddr1[31:3], 1'b0, dpif.imemaddr1[1:0]} : {dpif.imemaddr2[31:3], 1'b0, dpif.imemaddr2[1:0]};
                 end
            end
            MEM1 : begin
                // Bring the first word from memory for the block
                if (!caif.iwait) begin
                    next_state = MEM2;
                    next_cache[addr_index].data[0] = caif.iload; //{1'b1, icheck.tag, caif.iload}; Do not set valid or tag bits yet
                    next_iaddr = {addr_tag, addr_index, 1'b1, addr_bytoff};
                    next_iREN = 1'b1;
                end
            end
            
            MEM2 : begin
                // Bring the second word from memory for the block 
                if(!caif.iwait) begin
                    next_state = IDLE;
                    next_cache[addr_index].data[1] = caif.iload;
                    next_cache[addr_index].valid = 1'b1;
                    next_cache[addr_index].tag = addr_tag;//caif.iaddr[31:7];
                    next_iaddr = '0;
                    next_iREN = 1'b0;
                end
            end
        endcase
    end


    assign ihit1 = (dpif.imemREN && cache[instr1.idx].valid && (cache[instr1.idx].tag == instr1.tag)); // if there is a valid bit
    assign ihit2 = (dpif.imemREN && cache[instr2.idx].valid && (cache[instr2.idx].tag == instr2.tag));
    assign dpif.ihit = ihit1 & ihit2;
    assign dpif.imemload1 = cache[instr1.idx].data[instr1.blkoff];
    assign dpif.imemload2 = cache[instr2.idx].data[instr2.blkoff];

endmodule