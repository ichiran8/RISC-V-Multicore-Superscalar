`include "cache_control_if.vh"
`include "datapath_cache_if.vh"
`include "cpu_types_pkg.vh"

module dcache (
    input logic CLK,
    input logic nRST,
    datapath_cache_if.dcache dpif,
    caches_if.dcache ccif
);
// import types
import cpu_types_pkg::*;

dcachef_t req;

dcache_frame [7:0][1:0] frame; // eight sets of two frames
dcache_frame [7:0][1:0] next_frame;

assign req.bytoff = dpif.dmemaddr[1:0]; // 2 bits, always 00
assign req.blkoff = dpif.dmemaddr[2]; // 1 bit
assign req.idx = dpif.dmemaddr[5:3]; // 3 bits
assign req.tag = dpif.dmemaddr[31:6]; // 26 bits

logic[1:0] frame_select; // 10 = hit frame2, 01 = hit frame1, 00 = no match
assign frame_select = (frame[req.idx][1].tag == req.tag & frame[req.idx][1].valid) ? 2'd2 : (frame[req.idx][0].tag == req.tag & frame[req.idx][0].valid) ? 2'd1 : 2'd0;
// we always check, maybe better to include dpif.dmemREN | dpif.dmemWEN

logic [7:0] lru; // 0 = frame1 least recently used, 1 = frame2
logic [7:0] next_lru;

logic [31:0] hit_counter;
logic [31:0] next_hit_counter;

logic prev_dhit;
logic[7:0][1:0] dirty_bits;

logic[4:0] flush_timer;
logic[4:0] next_flush_timer;

typedef enum bit [10:0] {request, access1, access2, update1, update2, flush1, flush2, write_hits, terminate, bus_data1, bus_data2} stateType;

stateType state;
stateType next_state;

logic next_dREN;
logic next_dWEN;

logic [31:0] next_daddr;
logic [31:0] next_dstore;

// Coherence signals
logic next_ccwrite;
logic next_cctrans;

// Snoopaddr breakdown
logic[1:0] snoop_req;
dcachef_t snoop;
assign snoop_req = ccif.ccsnoopaddr[1:0];
assign snoop.bytoff = 2'b00; // 2 bits
assign snoop.blkoff = ccif.ccsnoopaddr[2]; // 1 bit
assign snoop.idx = ccif.ccsnoopaddr[5:3]; // 3 bits
assign snoop.tag = ccif.ccsnoopaddr[31:6]; // 26 bits

logic[1:0] snoop_select;
assign snoop_select = (frame[snoop.idx][1].tag == snoop.tag & frame[snoop.idx][1].valid) ? 2'd2 : (frame[snoop.idx][0].tag == snoop.tag & frame[snoop.idx][0].valid) ? 2'd1 : 2'd0;
// 00: ignore 
// 01: snoop request {snoopaddr[31:2], 2'b00}
// 10: empty for now

// daddr[1:0]:
// bit1: valid
// bit0: dirty

// ccwrite: set high when writing
// ccinv: we need to set valid=0 when we get this, also need ccwait

always_comb begin : NEXT_STATE_LOGIC
    next_state = state;

    if(!ccif.ccwait) begin
        case (state)
            request: begin
                if(dpif.halt)
                    next_state = flush1;
                else if(snoop_req == 2'd0 && (dpif.dmemREN | dpif.dmemWEN) && frame_select == 2'd0) begin
                    if(!frame[req.idx][lru[req.idx]].dirty) begin // clean
                        next_state = access1;
                    end
                    if(frame[req.idx][lru[req.idx]].dirty) begin // dirty
                        next_state = update1;
                    end
                end
                else if(snoop_req == 2'b01 && snoop_select != 2'd0) begin
                    next_state = bus_data1;
                end
            end
            update1: next_state = !ccif.dwait ? update2 : state;
            update2: begin 
                if(!ccif.dwait) begin
                    next_state = access1;
                end
            end
            access1: begin 
                if(!ccif.dwait) begin
                    if(dpif.dmemWEN)
                        next_state = request;
                    else begin
                        next_state = access2;
                    end
                end
            end
            access2: next_state = !ccif.dwait ? request : state;
            // bus_data1: next_state = !ccif.dwait ? bus_data2 : state; // for actual use
            bus_data1: next_state = !ccif.ccwait ? bus_data2 : state; // for tb use
            // bus_data2: next_state = !ccif.dwait ? request : state; // for actual use
            bus_data2: next_state = !ccif.ccwait ? request : state; // for tb use
            flush1: next_state = flush_timer == 5'd16 ? write_hits : (!ccif.dwait | !frame[flush_timer[2:0]][flush_timer[3]].dirty) ? flush2 : state; // flush first word
            flush2: next_state = (!ccif.dwait | !frame[flush_timer[2:0]][flush_timer[3]].dirty) ? flush1 : state; // flush second word
            // write_hits: next_state = !ccif.dwait ? terminate : state;
            write_hits: next_state = terminate;
            // terminate: stay in terminate, i think
        endcase
    end
end

always_ff @(posedge CLK, negedge nRST) begin : REG_LOGIC
    if(!nRST) begin
        frame <= '0; // i think we reset to 0, but check
        lru <= '0;
        state <= request;
        hit_counter <= '0;
        prev_dhit <= 0;
        flush_timer <= '0;
        ccif.dREN <= 0;
        ccif.dWEN <= 0;
        ccif.daddr <= '0;
        ccif.dstore <= '0;
        ccif.ccwrite <= 0;
        ccif.cctrans <= 0;
    end
    else begin
        frame <= next_frame;
        lru <= next_lru;
        state <= next_state;
        hit_counter <= next_hit_counter;
        prev_dhit <= dpif.dhit; // prev_dhit needed for solving double counting
        flush_timer <= next_flush_timer;
        ccif.dREN <= next_dREN;
        ccif.dWEN <= next_dWEN;
        ccif.daddr <= next_daddr;
        ccif.dstore <= next_dstore;
        ccif.ccwrite <= next_ccwrite;
        ccif.cctrans <= next_cctrans;
    end
end

always_comb begin : OUTPUT_LOGIC
    // To Controller
    next_dREN = 0;
    next_dWEN = 0;
    next_daddr = '0;
    next_dstore = '0;
    next_cctrans = 0;
    next_ccwrite = 0;

    // To Datapath
    dpif.dhit = 0;
    dpif.dmemload = '0;
    dpif.flushed = 0;

    // Internal
    next_lru = lru;
    next_frame = frame;
    next_hit_counter = hit_counter;
    next_flush_timer = flush_timer;

    if(!ccif.ccwait) begin
        case (state)
            request: begin
                if(dpif.dmemREN | dpif.dmemWEN) begin
                    if(!prev_dhit & frame_select != 2'd0) begin // if not 0, then check bit 1
                        dpif.dhit = 1;
                        next_hit_counter = hit_counter + 1;

                        next_lru[req.idx] = frame_select[0]; // frame1 not used if 0, frame2 not used if 1

                        if(dpif.dmemREN) begin
                            dpif.dmemload = frame[req.idx][frame_select[1]].data[req.blkoff];
                        end
                        else if(dpif.dmemWEN) begin
                            next_frame[req.idx][frame_select[1]].data[req.blkoff] = dpif.dmemstore; // idk if next_frame will affect speed
                            next_frame[req.idx][frame_select[1]].dirty = 1;
                            next_frame[req.idx][frame_select[1]].valid = 1;

                            next_ccwrite = 1; // check, might be enough without at access1
                        end
                    end
                end
                if(snoop_req == 2'b01 && snoop_select != 2'd0) begin
                    next_daddr[1:0] = {frame[snoop.idx][1].valid, frame[snoop.idx][1].dirty}; 
                end
                if(next_state == update1) begin
                    next_dWEN = 1;
                    next_dstore = frame[req.idx][lru[req.idx]].data[0];
                    next_daddr = {frame[req.idx][lru[req.idx]].tag, req.idx, 1'b0, req.bytoff}; // check this
                end
            end
            update1: begin
                if(next_state == update1) begin
                    next_dWEN = 1;
                    next_dstore = frame[req.idx][lru[req.idx]].data[0];
                    next_daddr = {frame[req.idx][lru[req.idx]].tag, req.idx, 1'b0, req.bytoff}; // check this
                end
                if(next_state == update2) begin
                    next_dWEN = 1;
                    next_dstore = frame[req.idx][lru[req.idx]].data[1];
                    next_daddr = {frame[req.idx][lru[req.idx]].tag, req.idx, 1'b1, req.bytoff}; // check this
                end
            end
            update2: begin
                if(next_state == update2) begin
                    next_dWEN = 1;
                    next_dstore = frame[req.idx][lru[req.idx]].data[1];
                    next_daddr = {frame[req.idx][lru[req.idx]].tag, req.idx, 1'b1, req.bytoff}; // check this
                end
                if(next_state == access1) begin
                    next_dREN = 1;
                    next_daddr = {req.tag, req.idx, !req.blkoff, req.bytoff}; // get the data you don't have first
                end
            end
            access1: begin
                if(dpif.dmemWEN & next_state == request) begin
                    next_frame[req.idx][lru[req.idx]].data[!req.blkoff] = ccif.dload;
                    next_frame[req.idx][lru[req.idx]].data[req.blkoff] = dpif.dmemstore;
                    next_frame[req.idx][lru[req.idx]].tag = req.tag;
                    next_frame[req.idx][lru[req.idx]].valid = 1;
                    next_frame[req.idx][lru[req.idx]].dirty = 1;
                    next_lru[req.idx] = !lru[req.idx]; // set other frame to be least recently used

                    next_hit_counter = hit_counter - 1;

                    //    next_ccwrite = 1; // check
                end
                else if(next_state == access2) begin
                    next_frame[req.idx][lru[req.idx]].data[!req.blkoff] = ccif.dload;
                    next_dREN = 1;
                    next_daddr = {req.tag, req.idx, req.blkoff, req.bytoff};
                    
                    // here, make request to bus
                end
                else if(next_state == access1) begin
                    next_dREN = 1;
                    next_daddr = {req.tag, req.idx, !req.blkoff, req.bytoff}; // get the data you don't have first

                    // here, make request to bus
                end
            end
            access2: begin
                if(next_state == request) begin
                    next_frame[req.idx][lru[req.idx]].data[req.blkoff] = ccif.dload;
                    next_frame[req.idx][lru[req.idx]].tag = req.tag;
                    next_frame[req.idx][lru[req.idx]].valid = 1;
                    next_frame[req.idx][lru[req.idx]].dirty = 0; // if we got here, we should only be doing a read
                    next_lru[req.idx] = !lru[req.idx]; // set other frame to be least recently used

                    next_hit_counter = hit_counter - 1;
                end

                if(next_state == access2) begin
                    next_dREN = 1;
                    next_daddr = {req.tag, req.idx, req.blkoff, req.bytoff};

                    // here, make request to bus
                end
            end
            flush1: begin
                if(flush_timer != 5'd16 & frame[flush_timer[2:0]][flush_timer[3]].dirty & frame[flush_timer[2:0]][flush_timer[3]].valid) begin
                    if(next_state == flush1) begin // right now has extra cycle delay, but otherwise could write when not supposed to
                        next_dWEN = 1;
                        next_dstore = frame[flush_timer[2:0]][flush_timer[3]].data[0];
                        next_daddr = {frame[flush_timer[2:0]][flush_timer[3]].tag, flush_timer[2:0], 1'b0, 2'b00};
                    end
                end
            end
            flush2: begin
                if(frame[flush_timer[2:0]][flush_timer[3]].dirty & frame[flush_timer[2:0]][flush_timer[3]].valid) begin
                    if(next_state == flush2) begin
                        next_dWEN = 1;
                        next_dstore = frame[flush_timer[2:0]][flush_timer[3]].data[1];
                        next_daddr = {frame[flush_timer[2:0]][flush_timer[3]].tag, flush_timer[2:0], 1'b1, 2'b00};
                    end
                end
                if(next_state == flush1)
                    next_flush_timer = flush_timer + 1;
            end
            write_hits: begin
                if(next_state == write_hits) begin
                    // commented out for multicore
                    // next_dstore = hit_counter;
                    // next_daddr = 32'h3100;
                    // next_dWEN = 1;
                end
            end
            terminate: begin
                dpif.flushed = 1;
            end
            bus_data1: begin
                // no need for hit_counter in multicore
                // don't update lru

                next_dstore = frame[snoop.idx][snoop_select[1]].data[snoop.blkoff];
            end
            bus_data2: begin
                next_dstore = frame[snoop.idx][snoop_select[1]].data[!snoop.blkoff];
            end
        endcase
    end
    else begin
        if(ccif.ccinv) begin
            if(snoop_select != 2'd0)
                next_frame[snoop.idx][snoop_select[1]].valid = 0;
        end
    end
end
    
endmodule