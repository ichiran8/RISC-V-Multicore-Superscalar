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
    typedef enum logic {IDLE, MEM} state_t;

    state_t state, next_state;
    icachef_t icheck;

    assign icheck = dpif.imemaddr;
    


    //assign icheck.tag = dpif.imemaddr[31:6];
    //assign icheck.idx = dpif.imemaddr[5:2];
    //assign icheck.bytoff = dpif.imemaddr[1:0];
    // we fetch from the main memory when we get a memory miss
    logic next_iREN;
    word_t next_iaddr;

    logic test_iREN;
    word_t test_iaddr;

    always_ff @(posedge CLK, negedge nRST) begin
        if(!nRST) begin
            state <= IDLE;
            cache <= '0;
            caif.iREN <= '0;
            caif.iaddr <= '0;
            // test_iREN <= '0;
            // test_iaddr  next_iaddr;
        end else begin
            state <= next_state;
            cache <= next_cache;
            caif.iREN <= next_iREN;
            caif.iaddr <= next_iaddr;
            // test_iREN <= next_iREN;
            // test_iaddr <= next_iaddr;
        end
    end


    always_comb begin // state machine
        next_state = state;
        next_cache = cache;
        next_iaddr = caif.iaddr;
        next_iREN = caif.iREN;
        // caif.iREN = 1'b0;
        // caif.iaddr = '0;
        casez(state)
            IDLE : begin
                 if (!dpif.ihit && dpif.imemREN) begin
                    next_state = MEM;
                    next_iREN = 1'b1;  // if we were to register iREN and imemaddr, we would need to do this
                    next_iaddr = dpif.imemaddr;
                 end
            
            end
            MEM : begin
                // caif.iREN = 1'b1;
                // caif.iaddr = dpif.imemaddr;
                if (!caif.iwait) begin
                    next_state = IDLE;
                    next_cache[icheck.idx] = {1'b1, icheck.tag, caif.iload};
                    next_iREN = 1'b0;
                end
            end
        endcase
    end

    // tag width is 26 bits 
    // index is pc [5:2]
    assign dpif.ihit = (dpif.imemREN && cache[icheck.idx].valid && (cache[icheck.idx].tag == icheck.tag)); // if there is a valid bit
    assign dpif.imemload = cache[icheck.idx].data;
endmodule