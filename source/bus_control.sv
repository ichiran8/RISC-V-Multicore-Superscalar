`include "cpu_types_pkg.vh"
`include "cache_control_if.vh"
import cpu_types_pkg::*;

module bus_control(
    input logic CLK, nRST,
    cache_control_if.cc cc
);



// using cc trans as a confirmation (?)
logic [1:0] next_ccwait;
typedef enum logic [3:0] {
    IDLE, IFETCH, D_UPDATE_1, D_UPDATE_2, SNOOP_REQ, SNOOP_RESP, CACHE_UPDATE_1, CACHE_UPDATE_2, MEM_FETCH_1, MEM_FETCH_2, CACHE_MEM_UPDATE_1, CACHE_MEM_UPDATE_2, CACHE_INVALIDATE, WAIT_FETCH, WAIT_MEM
} state_t;
state_t state, next_state;
//word_t next_snoop_addr0, next_snoop_addr1;
logic core, lru, next_core, next_lru, data_read, data_write, inst_read, core0_req, core1_req, next_ramREN, next_ramWEN, invalidate_check;
word_t next_ramaddr, next_ramstore;
word_t [1:0] next_snoop_addr;

assign data_read = cc.dREN[0] | cc.dREN[1];
assign data_write = cc.dWEN[0] | cc.dWEN[1];
assign inst_read = cc.iREN[0] | cc.iREN[1];
assign invalidate_check = cc.ccwrite[0] | cc.ccwrite[1];
always_ff @(posedge CLK, negedge nRST) begin
    if(!nRST) begin
        state <= IDLE;
        core <= 0;
        lru <= 0; // DOUBLE CHECK if we allow core 0 to be served first,
        cc.ccsnoopaddr <= '0;
        cc.ramREN <= 0;
        cc.ramWEN <= 0;
        cc.ramaddr <= 0;
        cc.ramstore <= 0;
       // cc.ccwait <= 0;
    end else begin
        state <= next_state; 
        core <= next_core;
        lru <= next_lru;
        cc.ccsnoopaddr <= next_snoop_addr;
        cc.ramREN <= next_ramREN;
        cc.ramWEN <= next_ramWEN;
        cc.ramaddr <= next_ramaddr;
        cc.ramstore <= next_ramstore;        
    end
end
// Priority read / readX >> WEN >> IREN
always_comb begin
    next_state = state;
    next_core = core;
    next_lru = lru;
    next_snoop_addr = cc.ccsnoopaddr;
    cc.iwait = 2'b11;
    cc.dwait = 2'b11;
    next_ramREN = 1'b0; //cc.ramREN;
    next_ramWEN = 1'b0; //cc.ramWEN;
    next_ramaddr = cc.ramaddr; //cc.ramaddr;
    next_ramstore = cc.ramstore;
    cc.iload = '0;
    cc.dload = '0;
    cc.ccinv = 0;
    cc.ccwait[0] = cc.cctrans[1] ? 1'b1 : 1'b0;
    cc.ccwait[1] = cc.cctrans[0] ? 1'b1 : 1'b0;
    casez(state)
        IDLE: begin 
            if (data_write) begin // just a generic write back to memory if block is evicted from cache
                next_state = D_UPDATE_1;
                next_ramWEN = 1'b1;
                if(cc.dWEN[0] && cc.dWEN[1]) begin // basic case
                    //next_lru = !lru;
                    if(!lru) begin // take dREN[1]
                        next_core = 0;
                        next_ramaddr = {cc.daddr[0][31:2], 2'b00};
                        next_ramstore = cc.dstore[0];
                        next_lru = cc.cctrans[0] ? lru : !lru;
                    end else begin // take dREN [0]
                        next_core = 1;
                        next_ramaddr = {cc.daddr[1][31:2], 2'b00};
                        next_lru = cc.cctrans[1] ? lru : !lru;
                        next_ramstore = cc.dstore[1];
                    end
                end else if(cc.dWEN[0]) begin
                    next_core = 0;
                    next_lru = cc.cctrans[0] ? 1'b0 : 1'b1;
                    next_ramaddr = {cc.daddr[0][31:2], 2'b00};
                    next_ramstore = cc.dstore[0];
                end else if (cc.dWEN[1]) begin
                    next_core = 1;
                    next_lru = cc.cctrans[1] ? 1'b1 : 1'b0;
                    next_ramaddr = {cc.daddr[1][31:2], 2'b00};
                    next_ramstore = cc.dstore[1];
                end
            end 
            else if(data_read) begin // busRD or busRDX
                next_state = SNOOP_REQ;
                if(cc.dREN[0] && cc.dREN[1]) begin // basic case : basically if both of them have a request at the same time
                    next_lru = !lru;
                    if(!lru) begin // take dREN[0] since it is least recently used
                        next_core = 0;
                        next_snoop_addr[1] = {cc.daddr[0][31:2], 2'b01};
                    end else begin // take dREN [1] since it is least recently used
                        next_core = 1;
                        next_snoop_addr[0] = {cc.daddr[1][31:2], 2'b01};
                    end
                end 
                else if(cc.dREN[0]) begin // only 1 request so no need to check LRU; idk if I need to update LRU (probably should)
                    next_core = 0;
                    next_lru = 1'b1; //(!lru) ? 1'b1 : 1'b0;
                    next_snoop_addr[1] = {cc.daddr[0][31:2], 2'b01};
                end else if (cc.dREN[1]) begin
                    next_core = 1;
                    next_lru = 1'b0;//lru ? 1'b0 : 1'b1;
                    next_snoop_addr[0] = {cc.daddr[1][31:2], 2'b01};
                end
            end 
            else if (invalidate_check) begin
                next_state = CACHE_INVALIDATE;
                if(cc.ccwrite[0] && cc.ccwrite[1]) begin
                    next_lru = !lru;
                    if(!lru) begin
                        next_core = 1'b0;
                        
                        //cc.ccinv[1] = 1'b1;//cc.ccwrite[0];
                        //cc.ccwait[1] = 1'b1;
                        next_snoop_addr[1] = {cc.daddr[0][31:2], 2'b00};
                    end else begin
                        next_core = 1'b1;
                        //cc.ccinv[0] = 1'b1; //cc.ccwrite[1];
                        //cc.ccwait[0] = 1'b1;
                        next_snoop_addr[0] = {cc.daddr[1][31:2], 2'b00};
                    end
                end else if (cc.ccwrite[0]) begin
                    next_core = 1'b0;
                    //cc.ccinv[1] = 1'b1; 
                    next_lru = 1'b1;
                    //cc.ccwait[1] = 1'b1;
                    next_snoop_addr[1] = {cc.daddr[0][31:2], 2'b00};
                end else if (cc.ccwrite[1]) begin
                    next_core = 1'b1;
                    //cc.ccinv[0] = 1'b1; 
                    next_lru = 1'b0; 
                    //cc.ccwait[0] = 1'b1;
                    next_snoop_addr[0] = {cc.daddr[1][31:2], 2'b00};
                end
            end 
            else if (inst_read) begin // instruction read
                next_state = IFETCH;
                next_ramREN = 1'b1;
                if(cc.iREN[0] && cc.iREN[1]) begin // basic case
                    next_lru = !lru;
                    if(!lru) begin // take dREN[1]
                        next_core = 0;
                        next_ramaddr = cc.iaddr[0];
                    end else begin // take dREN [0]
                        next_core = 1;
                        next_ramaddr = cc.iaddr[1];
                    end
                end else if(cc.iREN[0]) begin
                    next_core = 0;
                    next_ramaddr = cc.iaddr[0];
                    next_lru = 1'b1; //(!lru) ? 1'b1 : 1'b0;
                end else if (cc.iREN[1]) begin
                    next_core = 1;
                    next_ramaddr = cc.iaddr[1];
                    next_lru = 1'b0; //lru ? 1'b0 : 1'b1;
                end
            end
        end
        IFETCH: begin
            //cc.iwait[core] = 1'b1;
            next_ramREN = 1'b1;
            if(cc.ramstate == ACCESS) begin
                next_state = IDLE;
                next_ramREN = 1'b0;
                next_ramaddr = '0;
                cc.iwait[core] = 1'b0;
                cc.iload[core] = cc.ramload;
            end
        end
        D_UPDATE_1: begin
            //cc.dwait[core] = 1'b1;
            next_ramWEN = 1'b1;
            if(cc.ramstate == ACCESS) begin
                cc.dwait[core] = 1'b0;
                next_ramWEN = 1'b0;
                next_state = WAIT_MEM; // might update to a wait state 
                next_ramaddr = {cc.daddr[core][31:2], 2'b0};
                next_ramstore = cc.dstore[core];
            end
        end
        WAIT_MEM : begin

            if(cc.dWEN[core]) begin
                next_state = D_UPDATE_2;
                //cc.dwait[core] = 1'b1;
                next_ramWEN = 1'b1;  
                next_ramaddr = {cc.daddr[core][31:2], 2'b0};
                next_ramstore = cc.dstore[core];
            end
        end
        D_UPDATE_2: begin
            //cc.dwait[core] = 1'b1;
            next_ramWEN = 1'b1;
            if(cc.ramstate == ACCESS) begin
                cc.dwait[core] = 1'b0;
                next_ramWEN = 1'b0;
                next_state = IDLE;
                next_ramaddr = 0;
            end
        end
        SNOOP_REQ: begin
            next_state = SNOOP_RESP;

            next_snoop_addr[1] = {cc.ccsnoopaddr[1][31:2], 2'b00};
            next_snoop_addr[0] = {cc.ccsnoopaddr[0][31:2], 2'b00};
        end
        SNOOP_RESP: begin
            casez({cc.daddr[!core][1:0]})
                2'b0? : begin 
                    next_state = MEM_FETCH_1;
                    next_ramREN = 1'b1;
                    next_ramaddr = {cc.daddr[core][31:2], 2'b00};
                end
                2'b10 : begin
                    next_state = CACHE_UPDATE_1;
                end
                2'b11 : begin 
                    next_state = CACHE_MEM_UPDATE_1;
                    next_ramWEN = 1'b1;
                    next_ramaddr = {cc.daddr[core][31:2], 2'b00};
                    next_ramstore = cc.dstore[!core];
                end
            endcase
        end
        
        MEM_FETCH_1: begin // 
            next_ramREN = 1'b1;
            //cc.dwait[core] = 1'b1;
            if(cc.ramstate == ACCESS) begin
                next_ramREN = 1'b0;
                cc.dload[core] = cc.ramload;
                next_state = WAIT_FETCH;
                cc.dwait[core] = 1'b0;
                next_ramaddr = {cc.daddr[core][31:2], 2'b00};
            end
        end
        WAIT_FETCH: begin
            //cc.dwait[core] = 1'b1;
            next_ramREN = 1'b1;
            next_state = MEM_FETCH_2;
            next_ramaddr = {cc.daddr[core][31:2], 2'b00};
        end
        MEM_FETCH_2: begin // update from mem because other cache is in Invalid state
        // some things to keep in mind is that data address needs to be updated for the other block, so it needs to communicate with the d cache to update
            //cc.dwait[core] = 1'b1;
            next_ramREN = 1'b1;
            if(cc.ramstate == ACCESS) begin
                next_ramREN = 1'b0;
                cc.dload[core] = cc.ramload;
                next_state = IDLE;
                next_ramaddr = 0;
                cc.dwait[core] = 1'b0;
            end
        end
        CACHE_MEM_UPDATE_1: begin  // update cache and mem because other cache is in MODIFIED state
            cc.dload[core] = cc.dstore[!core];
            next_ramWEN = 1'b1;
            //cc.dwait = 2'b11;
            if(cc.ramstate == ACCESS) begin
                next_state = CACHE_MEM_UPDATE_2;
                next_ramaddr = {cc.daddr[core][31:2], 2'b00};
                next_ramstore = {cc.dstore[!core]};
                cc.dwait = 2'b00;

            end
        end
        CACHE_MEM_UPDATE_2: begin
            cc.dload[core] = cc.dstore[!core];
            next_ramWEN = 1'b1;
            //cc.dwait = 2'b11;
            if(cc.ramstate == ACCESS) begin
                next_ramWEN = 1'b0;
                next_state = CACHE_INVALIDATE;
                cc.dwait = 2'b00;
            end
        end
        CACHE_INVALIDATE : begin
            cc.ccwait[!core] = cc.ccwrite[core];
            cc.ccinv[!core] = cc.ccwrite[core];
            next_state = IDLE;
        end
        CACHE_UPDATE_1: begin  // update cache because other cache is in shared state
            // might need an acknowledgement signal to transition
            cc.dwait = 2'b0;
            cc.dload[core] = cc.dstore[!core];
            next_state = CACHE_UPDATE_2;
        end
        CACHE_UPDATE_2: begin
            cc.dwait = 2'b0;
            cc.dload[core] = cc.dstore[!core];
            next_state = CACHE_INVALIDATE;
        end
        default:;

    endcase

end

//assign cc.iwait[0] = (cc.ramstate == BUSY || (dREN[0] | dWEN[0])) && (!core); 
//assign cc.iwait[1] = ((cc.ramstate == BUSY) || (dREN[1] | dWEN[1]) && core); // core determines if this is the current core being servied
//assign cc.dwait[0] = !(cc.ramstate == ACCESS && (dREN[0] | dWEN[1]) && !core);
//assign cc.dwait[1] = !(cc.ramstate == ACCESS && (dREN[1] | dWEN[1]) && !core);

endmodule