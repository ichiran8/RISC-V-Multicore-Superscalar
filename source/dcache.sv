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

assign req.bytoff = dpif.dmemaddr[1:0]; // 2 bits, always 00
assign req.blkoff = dpif.dmemaddr[2]; // 1 bit
assign req.idx = dpif.dmemaddr[5:3]; // 3 bits
assign req.tag = dpif.dmemaddr[31:6]; // 26 bits

logic[1:0] frame_select; // 10 = hit frame2, 01 = hit frame1, 00 = no match
assign frame_select = (frame[req.idx][1].tag == req.tag & frame[req.idx][1].valid) ? 2'd2 : (frame[req.idx][0].tag == req.tag & frame[req.idx][0].valid) ? 2'd1 : 2'd0;
// we always check, maybe better to include dpif.dmemREN | dpif.dmemWEN

dcache_frame [7:0][1:0] frame; // eight sets of two frames
dcache_frame [7:0][1:0] next_frame;

logic [7:0] lru; // 0 = frame1 least recently used, 1 = frame2
logic [7:0] next_lru;

logic [31:0] hit_counter;
logic [31:0] next_hit_counter;

logic prev_dhit;
logic[7:0][1:0] dirty_bits;

logic[3:0] flush_timer;
logic[3:0] next_flush_timer;

typedef enum bit [8:0] {request, access1, access2, update1, update2, flush1, flush2, write_hits, terminate} stateType;

stateType state;
stateType next_state;

always_comb begin : NEXT_STATE_LOGIC
    next_state = state;

    case (state)
        request: begin
            if(dpif.halt)
                next_state = flush1;
            else if((dpif.dmemREN | dpif.dmemWEN) && frame_select == 2'd0) begin
                if(!frame[req.idx][lru[req.idx]].dirty) // clean
                    next_state = access1;
                if(frame[req.idx][lru[req.idx]].dirty) // dirty
                    next_state = update1;
            end
        end
        update1: next_state = !ccif.dwait ? update2 : state;
        update2: next_state = !ccif.dwait ? access1 : state;
        access1: next_state = (!ccif.dwait & dpif.dmemWEN) ? request : !ccif.dwait ? access2 : state;
        access2: next_state = !ccif.dwait ? request : state;
        flush1: next_state = (!ccif.dwait | !frame[flush_timer[2:0]][flush_timer[3]].dirty) ? flush2 : state; // flush first word
        flush2: next_state = flush_timer == 4'd15 ? write_hits : (!ccif.dwait | !frame[flush_timer[2:0]][flush_timer[3]].dirty) ? flush1 : state; // flush second word
        write_hits: next_state = !ccif.dwait ? terminate : state;
        // terminate: stay in terminate, i think
    endcase
end

always_ff @(posedge CLK, negedge nRST) begin : REG_LOGIC
    if(!nRST) begin
        frame <= '0; // i think we reset to 0, but check
        lru <= '0;
        state <= request;
        hit_counter <= '0;
        prev_dhit <= 0;
        flush_timer <= '0;
    end
    else begin
        frame <= next_frame;
        lru <= next_lru;
        state <= next_state;
        hit_counter <= next_hit_counter;
        prev_dhit <= dpif.dhit; // prev_dhit needed for solving double counting
        flush_timer <= next_flush_timer;
    end
end

always_comb begin : OUTPUT_LOGIC
    // To Controller
    ccif.dREN = 0;
    ccif.dWEN = 0;
    ccif.daddr = 0;
    ccif.dstore = 0;

    // To Datapath
    dpif.dhit = 0;
    dpif.dmemload = '0;
    dpif.flushed = 0;

    // Internal
    next_lru = lru;
    next_frame = frame;
    next_hit_counter = hit_counter;
    next_flush_timer = flush_timer;

    // for(int i = 0; i < 8; i++) begin
    //     for(int j = 0; j < 2; j++) begin
    //         dirty_bits[i][j] = frame[i][j].dirty;
    //     end
    // end

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
                    end
                end
            end
        end
        update1: begin
            ccif.dWEN = 1; // no way to know if victim block is written, so need both updates
            ccif.dstore = frame[req.idx][lru[req.idx]].data[0];
            ccif.daddr = {frame[req.idx][lru[req.idx]].tag, req.idx, 1'b0, req.bytoff}; // check this
        end
        update2: begin
            ccif.dWEN = 1;
            ccif.dstore = frame[req.idx][lru[req.idx]].data[1];
            ccif.daddr = {frame[req.idx][lru[req.idx]].tag, req.idx, 1'b1, req.bytoff}; // check this
        end
        access1: begin
            ccif.dREN = 1;
            ccif.daddr = {req.tag, req.idx, !req.blkoff, req.bytoff}; // get the data you don't have first

            if(dpif.dmemWEN & next_state == request) begin
               next_frame[req.idx][lru[req.idx]].data[!req.blkoff] = ccif.dload;
               next_frame[req.idx][lru[req.idx]].data[req.blkoff] = dpif.dmemstore;
               next_frame[req.idx][lru[req.idx]].tag = req.tag;
               next_frame[req.idx][lru[req.idx]].valid = 1;
               next_frame[req.idx][lru[req.idx]].dirty = 1;
			   next_lru[req.idx] = !lru[req.idx]; // set other frame to be least recently used

               next_hit_counter = hit_counter - 1;
            end
            else if(next_state == access2)
               next_frame[req.idx][lru[req.idx]].data[!req.blkoff] = ccif.dload;
        end
        access2: begin
            ccif.dREN = 1;
            ccif.daddr = {req.tag, req.idx, req.blkoff, req.bytoff};

            if(next_state == request) begin
               next_frame[req.idx][lru[req.idx]].data[req.blkoff] = ccif.dload;
               next_frame[req.idx][lru[req.idx]].tag = req.tag;
               next_frame[req.idx][lru[req.idx]].valid = 1;
               next_frame[req.idx][lru[req.idx]].dirty = 0; // if we got here, we should only be doing a read
               next_lru[req.idx] = !lru[req.idx]; // set other frame to be least recently used

               next_hit_counter = hit_counter - 1;
            end
        end
        flush1: begin
            if(frame[flush_timer[2:0]][flush_timer[3]].dirty) begin
                ccif.dWEN = 1;
                ccif.dstore = frame[flush_timer[2:0]][flush_timer[3]].data[0];
                ccif.daddr = {frame[flush_timer[2:0]][flush_timer[3]].tag, flush_timer[2:0], 1'b0, 2'b00};
            end
        end
        flush2: begin
            if(frame[flush_timer[2:0]][flush_timer[3]].dirty) begin
                ccif.dWEN = 1;
                ccif.dstore = frame[flush_timer[2:0]][flush_timer[3]].data[1];
                ccif.daddr = {frame[flush_timer[2:0]][flush_timer[3]].tag, flush_timer[2:0], 1'b1, 2'b00};
                // next_frame = frame[i][j].dirty = 0; // clean up
            end
            next_flush_timer = flush_timer + 1;
        end
        write_hits: begin
            ccif.dWEN = 1;
            ccif.dstore = hit_counter;
            ccif.daddr = 32'h3100;
        end
        terminate: begin
            dpif.flushed = 1;
        end
    endcase
end
    
endmodule