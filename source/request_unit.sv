`include "request_unit_if.vh"
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;
module request_unit(
    input logic CLK, nRST, request_unit_if.ru ruif
);

    always_ff @(posedge CLK, negedge nRST) begin
        if(!nRST) begin
            ruif.imemREN <= '0;
            ruif.dmemWEN <= '0;
            ruif.dmemREN <= '0;
        end else begin
            ruif.imemREN <= 1'b1;
            ruif.dmemWEN <= (!ruif.dhit & ruif.memwrite);
            ruif.dmemREN <= (!ruif.dhit & ruif.memread); 
        end
    end
    assign ruif.pc_enable = ruif.ihit;
    // always_ff @(posedge CLK, negedge nRST) begin
    //     if(!nRST) begin
    //         ruif.imemREN <= 1'b0;
    //         ruif.dmemREN <= 1'b0;
    //         ruif.dmemWEN <= 1'b0;
    //         ruif.imemaddr <= '0;
    //         ruif.dmemaddr <= '0;
    //         ruif.dmemstore <= '0;
    //         //ruif.instruction <= '0;
    //         state <= IDLE;
    //         previous_dhit <= 1'b0;
    //         previous_imemaddr <= '0;
    //     end else begin
    //         ruif.imemREN <= 1'b1;
    //         ruif.dmemREN <= next_dmemREN;
    //         ruif.dmemWEN <= next_dmemWEN;
    //         ruif.imemaddr <= next_imemaddr;
    //         ruif.dmemaddr <= next_dmemaddr;
    //         ruif.dmemstore <= next_dmemstore;
    //         state <= next_state;
    //         previous_dhit <= ruif.dhit;
    //         //ruif.instruction <= next_instruction;
    //         previous_imemaddr <= ruif.imemaddr;
    //     end
    // end

    // always_ff @(negedge CLK, negedge nRST) begin
    //     if(!nRST) begin
    //         ruif.instruction <= '0;
    //         ruif.memread_data <= '0;
    //     end else if (!ruif.dmemREN || !ruif.dmemWEN)begin
    //         ruif.instruction <= ruif.imemload;
    //     end else begin
    //         ruif.memread_data <= ruif.dmemload;
    //     end
    // end
 
    // always_comb begin
    //     next_dmemREN = 1'b0;
    //     next_dmemWEN = 1'b0;
    //     next_state = state;
    //    //next_dmemaddr = '0;
    //     next_imemaddr = ruif.pc;
    //     next_dmemstore = '0;
    //     next_memdata = ruif.memread_data;
    //     //next_instruction = ruif.instruction;
    //     //ruif.instruction = '0;
    //     //ruif.imemaddr = previous_imemaddr;
    //     case(state)
    //         IDLE: begin
    //             if(ruif.memread && !previous_dhit) begin
    //                 next_state = DATA_READ;
    //                 next_dmemREN = 1'b1;
    //                 next_dmemaddr = ruif.result;
    //                 next_imemaddr = ruif.imemaddr;
    //             end else if(ruif.memwrite && !previous_dhit) begin
    //                 next_state = DATA_WRITE;
    //                 next_dmemWEN = 1'b1;
    //                 next_dmemaddr = ruif.result;
    //                 next_dmemstore = ruif.memwrite_data;
    //                 next_imemaddr = ruif.imemaddr;
    //             end else if(!cif.halt) begin
    //                 next_state = INSTRUCTION_READ;
    //                 next_imemaddr = ruif.pc;
    //                 //ruif.imemaddr = ruif.pc;
    //             end else begin
    //                 next_state = state;
    //                // next_instruction = '0;
    //             end
    //         end
    //         DATA_READ : begin
    //             next_dmemREN = 1'b1;
    //             //next_memdata = ruif.dmemload;
    //             next_state = state;
    //             if(ruif.dhit) begin
    //                 //next_memdata = ruif.dmemload;
    //                 next_state = IDLE;
    //                 next_dmemREN = 1'b0;
    //             end
    //         end
    //         DATA_WRITE : begin
    //             next_state = state;
    //             next_dmemstore = ruif.memwrite_data;
    //             next_dmemWEN = 1'b1;
    //             if(ruif.dhit) begin
    //                 next_state = IDLE;
    //                 next_dmemWEN = 1'b0;
    //             end
    //         end
    //         INSTRUCTION_READ : begin
    //             next_state = state;
    //             //next_instruction = ruif.imemload;
    //             if(ruif.ihit) begin
    //                 next_state = IDLE;
    //                 //ruif.instruction = ruif.imemload;
    //                 //next_instruction = ruif.imemload;
    //             end
    //         end
    //     endcase
    // end
    
endmodule
