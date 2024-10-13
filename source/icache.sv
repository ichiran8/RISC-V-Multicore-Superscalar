`include "cpu_types_pkg.vh"
`include "caches_if.vh"
`include "datapath_cache_if.vh"

import cpu_types_pkg::*;

module icache(
    input logic CLK, nRST,
    datapath_cache_if.icache caif,
    caches_if.icache c_icache
);



    icache_frame [15:0] cache, next_cache;
    typedef enum logic {IDLE, MEM} state_t;

    state_t state, next_state;
    logic imiss;
    logic [ITAG_W-1:0]  tag;
    logic [IIDX_W-1:0]  idx;
    logic [IBYT_W-1:0]  bytoff;
    icache_f icheck;
    
    assign icheck.tag = caif.imemaddr[31:5];
    assign icheck.idx = caif.imemaddr[5:2];
    assign icheck.byteoff = caif.imemaddr[1:0];
    // we fetch from the main memory when we get a memory miss

    always_ff @(posedge CLK, negedge nRST) begin
        if(!nRST) begin
            state <= IDLE;
            cache <= '0;
        end else begin
            state <= next_state;
            cache <= next_cache;
        end
        else if (halt)
            cache.valid = '0;
    end


    always_comb begin // state machine
        next_state = state;
        next_cache = cache;
        c_icache.iREN = 1'b0;
        c_icache.iaddr = 0;
        case(state)
            IDLE : begin
                 if (dpif.imemREN && !caif.ihit) begin
                    next_state = MEM;
                    //c_icache.IREN = 1'b1;
                    //c_icache.iaddr = caif.imemaddr;
                 end
            
            end
            MEM : begin
                c_icache.iREN = 1'b1;
                c_icache.iaddr = caif.imemaddr;
                if (!caif.iwait) begin
                    next_state = IDLE;
                    next_cache[icheck.idx] = {1'b1, icheck.tag, c_icache.iload};
                end
            end
        endcase
    end

    // tag width is 26 bits 
    // index is pc [5:2]
    assign caif.ihit = (dpif.imemREN && cache[icheck.idx].valid && cache[icheck.idx].tag == icheck.tag); // if there is a valid bit
    assign caif.imemload = cache[idx].data;
endmodule