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

dcache_frame [7:0][1:0] frame; // two frames

dcache_frame [7:0][1:0] next_frame;

logic [7:0] lru; // 0 = frame1 least recently used, 1 = frame2
logic [7:0] next_lru;

logic [31:0] hit_counter;
logic [31:0] next_hit_counter;

typedef enum bit [7:0] {request} stateType;

stateType state;
stateType next_state;

always_comb begin : NEXT_STATE_LOGIC
    next_state = state;

    case (state)
        request: begin
            
        end
    endcase
end

always_ff @(posedge CLK, negedge nRST) begin : REG_LOGIC
    if(!nRST) begin
        frame <= '0; // i think we reset to 0, but check
        lru <= '0;
        state <= request;
        hit_counter <= '0;
    end
    else begin
		frame <= next_frame;
        lru <= next_lru;
        state <= next_state;
        hit_counter <= next_hit_counter;
    end
end

logic[1:0] frame_select; // 10 = hit frame2, 01 = hit frame1, 00 = no match
assign frame_select = (frame[req.idx][0].tag == req.tag & frame[req.idx][0].valid) ? 2'd2 : (frame2[req.idx].tag == req.tag & frame2[req.idx].valid) ? 2'd1 : 2'd0;

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

    case (state)
        request: begin
            if(dpif.dmemREN | dpif.dmemWEN) begin
                if(frame_select != 2'd0) begin // if not 0, then check bit 1
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
    endcase
end
    
endmodule