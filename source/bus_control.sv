`include "cpu_types_pkg_if.vh"
`include "cache_control_if.vh"
import cpu_types_pkg::*;

module bus_controller(
    input logic CLK, nRST,
    cache_control_if.cc cc
);

// controller ports to ram and caches
//   modport cc (
//             // cache inputs
//     input   iREN, dREN, dWEN, dstore, iaddr, daddr,
//             // ram inputs
//             ramload, ramstate,
//             // coherence inputs from cache
//             ccwrite, cctrans,
//             // cache outputs
//     output  iwait, dwait, iload, dload,
//             // ram outputs
//             ramstore, ramaddr, ramWEN, ramREN,
//             // coherence outputs to cache
//             ccwait, ccinv, ccsnoopaddr
//   );

// using cc trans as a confirmation (?)
logic [1:0] next_ccwait;
typedef enum logic [3:0] {
    IDLE, IFETCH, D_UPDATE_1, D_UPDATE_2, SNOOP_REQ, SNOOP_RESP, CACHE_UPDATE_1, CACHE_UPDATE_2, CACHE_MEM_UPDATE_1, CACHE_MEM_UPDATE_2, MEM_UPDATE_1, MEM_UPDATE_2
} state_t;
state_t state, next_state;
logic core, lru, next_core, next_lru, data_read, data_write, inst_read, core0_req, core1_req;

assign data_read = dREN[0] | dREN[1];
assign data_write = dWEN[0] | dWEN[1];
assign inst_read = iREN[0] | iREN[1];
assign core0_req = dREN[0] | dWEN[0] | iREN[0];
assign core1_req = dREN[1] | dWEN[1] | iREN[1]; // might not be needed but I might rewrite it such that it will check to service which core (before arbitrating which action to take)
always_ff @(posedge CLK, negedge nRST) begin
    if(!nRST) begin
        state <= IDLE;
        core <= 0;
        lru <= 0; // DOUBLE CHECK if we allow core 0 to be served first,
        cc.ccwait <= 0;
    end else begin
        state <= next_state; 
        core <= next_core;
        lru <= next_lru;
        cc.ccwait <= next_ccwait;;
    end
end
//assign cc.ccinv[1] = cc.ccwrite[0];
//assign cc.ccinv[0] = cc.ccwrite[1];
// Priority read / readX >> WEN >> IREN
// Then arbritrate priority based on cores? Not sure if it is supposed to arbritrate core requests first and THEN read? But that wouldn't make much sense
always_comb begin
    next_state = state;
    next_core = core;
    next_lru = lru;
    next_ccwait = 0;
    //ccwait[0] = (core == 0); // might be wrong 
    //ccwait[1] = (core == 1); // might be wrong; i might need to add wait states in between as a handshake signal to acknowledge a transation is complete
    // i.e (JUST LIKE FIR FILTER), ccwait <= next_ccwait; Set next_ccwait upon the transition
    casez(state)
        IDLE : begin
            if(data_read) // busRD or busRDX
                next_state = SNOOP_REQ;
                if(cc.dREN[0] && dREN[1]) begin // basic case : basically if both of them have a request at the same time
                    if(!lru) begin // take dREN[1] since it is least recently used
                        next_core = 0;
                        next_lru = !lru; // I only update LRU if they are both fighting over it? Might CHANGE *******
                        next_ccwait[0] = 1'b1;
                    end else begin // take dREN [0] since it is least recently used
                        next_core = 1;
                        next_lru = !lru;
                        next_ccwait[1] = 1'b1;
                    end
                end else if(cc.dREN[0]) begin // only 1 request so no need to check LRU; idk if I need to update LRU (probably should)
                    next_state = SNOOP_REQ;
                    next_core = 0;
                    next_ccwait[0] = 1'b1;
                    next_lru = (!lru) ? 1'b1 : 1'b0;
                end else if (cc.dREN[1]) begin
                    next_state = SNOOP_REQ;
                    next_core = 1;
                    next_ccwait[1] = 1'b1;
                    next_lru = lru ? 1'b0 : 1'b1;
                end
            end else if (data_write) begin // just a generic write back to memory if block is evicted from cache
                next_state = D_UPDATE_1;
                if(cc.dWEN[0] && cc.dWEN[1]) begin // basic case
                    if(!lru) begin // take dREN[1]
                        next_core = 0;
                        next_lru = !lru;
                        next_ccwait[0] = 1'b1;
                    end else begin // take dREN [0]
                        next_core = 1;
                        next_lru = !lru;
                        next_ccwait[1] = 1'b1;
                    end
                end else if(cc.dWEN[0]) begin
                    next_state = SNOOP_REQ;
                    next_core = 0;
                    next_ccwait[0] = 1'b1;
                    next_lru = (!lru) ? 1'b1 : 1'b0;
                end else if (cc.dWEN[1]) begin
                    next_state = SNOOP_REQ;
                    next_core = 1;
                    nexT_ccwait[1] = 1'b1;
                    next_lru = lru ? 1'b0 : 1'b1;
                end
            end else if (inst_read) begin // instruction read
                next_state = IFETCH;
                if(cc.iREN[0] && iREN[1]) begin // basic case
                    if(!lru) begin // take dREN[1]
                        next_core = 0;
                        next_lru = !lru;
                        next_ccwait[0] = 1'b1;
                    end else begin // take dREN [0]
                        next_core = 1;
                        next_lru = !lru;
                        next_ccwait[1] = 1'b1;
                    end
                end else if(cc.iREN[0]) begin
                    next_state = SNOOP_REQ;
                    next_core = 0;
                    next_lru = !lru;
                    next_ccwait[0] = 1'b1;
                    next_lru = (!lru) ? 1'b1 : 1'b0;
                end else if (cc.iREN[1]) begin
                    next_state = SNOOP_REQ;
                    next_core = 1;
                    next_lru = !lru;
                    next_ccwait[1] = 1'b1;
                    next_lru = lru ? 1'b0 : 1'b1;
                end
            end
        IFETCH : begin
            ramREN = 1'b1;
            cc.ramaddr = cc.iaddr[core];
            if(!cc.iwait[core]) begin
                cc.iload = cc.ramload;
                next_ccwait[core] = 1'b0;
            end
        end
        D_UPDATE_1 : begin
            ramWEN = 1'b1;
            cc.ramaddr = {cc.daddr[core][31:2], 2'b0};
            if(!cc.dwait[core]) begin
                next_state = D_UPDATE_1; // might update to a wait state 
                //next_ccwait[core] = 1'b0;
            end
        end
        D_UPDATE_2 : begin
            ramWEN = 1'b1;
            cc.ramaddr = {cc.daddr[core][31:2], 2'b0};
            if(!cc.dwait[core]) begin
                next_state = IDLE;
                next_ccwait[core = 1'b0]
            end
        end
        SNOOP_REQ : begin
            cc.ccsnoopaddr[!core] = {cc.daddr[core][31:2], 2'b01}; // lower 2 bits of daddr being reallocated to be used for snooping MSI 
            next_state = SNOOP_RESP;
        end
        SNOOP_RESP : begin
            cc.ccinv[!core] = cc.ccwrite[core]; // invalidate other core if current core is writing
            // We can do this here after we get the response (MSI)
            // I need to discuss about dcache because daddr[core][1:0] represents the MSI 
            // I would also need to hold ccwrite[core] high for a certain amount of time so discussion about dcache needs to take place
            casez({cc.daddr[!core][1:0]})
                2'b0? : next_state = MEM_UPDATE_2;
                2'b10 : next_state = CACHE_UPDATE_1;
                2'b11 : next_state = CACHE_MEM_UPDATE_1;
            endcase
        end
        
        MEM_UPDATE_1 : begin // 
            cc.ramREN = 1'b1;
            cc.ramaddr = cc.daddr[core];
            if(!cc.dwait[core]) begin
                cc.dload[core] = cc.ramload;
                next_state = MEM_UPDATE_2;
            end
        end
        MEM_UPDATE_2 : begin // update from mem because other cache is in Invalid state
        // some things to keep in mind is that data address needs to be updated for the other block, so it needs to communicate with the d cache to update
            cc.ramREN = 1'b1;
            cc.ramaddr = cc.daddr[core];
            if(!cc.dwait[core]) begin
                cc.dload[core] = cc.ramload;
                next_state = IDLE;
            end
        end
        CACHE_MEM_UPDATE_1 : begin  // update cache and mem because other cache is in MODIFIED state
            cc.ramWEN = 1'b1;
            cc.dload[core] = cc.dstore[!core];
            cc.ramaddr = cc.daddr[!core];
            if(!cc.dwait[core]) begin
                next_state = CACHE_MEM_UPDATE_2;
            end
        end
        CACHE_MEM_UPDATE_2 : begin
            cc.ramWEN = 1'b1;
            cc.dload[core] = cc.dstore[!core];
            cc.ramaddr = cc.daddr[!core];
            if(!cc.dwait[core]) begin
                next_state = IDLE;
            end
        end
        CACHE_UPDATE_1 : begin  // update cache because other cache is in shared state
            // might need an acknowledgement signal to transition
            cc.dload[core] = cc.dstore[!core];
            next_state = CACHE_UPDATE_2;
        end
        CACHE_UPDATE_2 : begin
            cc.dload[core] = cc.dstore[!core];
            next_state = IDLE;
        end

    endcase

end

assign cc.iwait[0] = (cc.ramstate == BUSY || (dREN[0] | dWEN[0])) && (!core); 
assign cc.iwait[1] = ((cc.ramstate == BUSY) || (dREN[1] | dWEN[1]) && core); // core determines if this is the current core being servied
assign cc.dwait = !(cc.ramstate == ACCESS && (data_read | data_write));
endmodule