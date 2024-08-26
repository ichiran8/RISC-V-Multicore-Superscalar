`include "request_unit_if.vh"
`include "cpu_types_pkg.vh"
import cpu_types_pkg::*;
module request_unit(
    input logic CLK, nRST, request_unit_if.ru ruif
);

    typedef enum logic [2:0] {
        IDLE, INSTRUCTION_READ, DATA_READ, DATA_WRITE
    } state_t;

    state_t state, next_state;
    logic next_dmemREN, next_dmemWEN;

    
    word_t next_instruction, next_memdata, next_dmemstore, next_dmemaddr, next_imemaddr;

    always_ff @(posedge CLK, negedge nRST) begin
        if(!nRST) begin
            ruif.imemREN <= 1'b0;
            ruif.dmemREN <= 1'b0;
            ruif.dmemWEN <= 1'b0;
            state <= IDLE;
            ruif.instruction <= '0;
            ruif.memread_data <= '0;
            ruif.imemaddr <= '0;
            ruif.dmemaddr <= '0;
            ruif.dmemstore <= '0;
        end else begin
            ruif.imemREN <= 1'b1;
            ruif.dmemREN <= next_dmemREN;
            ruif.dmemWEN <= next_dmemWEN;
            state <= next_state;
            ruif.instruction <= next_instruction;
            ruif.memread_data <= next_memdata;
            ruif.imemaddr <= next_imemaddr;
            ruif.dmemaddr <= next_dmemaddr;
            ruif.dmemstore <= next_dmemstore;
        end
    end

    always_comb begin
        next_dmemREN = 1'b0;
        next_dmemWEN = 1'b0;
        next_state = state;
        ruif.pc_enable = 1'b0;
        next_dmemaddr = '0;
        next_imemaddr = '0;
        next_dmemstore = '0;
        next_instruction = ruif.instruction;
        next_memdata = ruif.memread_data;
        case(state)
            IDLE: begin
                ruif.pc_enable = 1'b1;
                if(ruif.memread && !ruif.dhit) begin
                    next_state = DATA_READ;
                    next_dmemREN = 1'b1;
                    next_dmemaddr = ruif.result;
                end else if(ruif.memwrite && !ruif.dhit) begin
                    next_state = DATA_WRITE;
                    next_dmemWEN = 1'b1;
                    next_dmemaddr = ruif.result;
                    next_dmemstore = ruif.memwrite_data;
                end else if(ruif.opcode != HALT) begin
                    next_state = INSTRUCTION_READ;
                    next_imemaddr = ruif.pc;
                end else begin
                    next_state = state;
                end
            end
            DATA_READ : begin
                ruif.pc_enable = 1'b0;
                next_memdata = ruif.dmemload;
                next_state = IDLE;
            end
            DATA_WRITE : begin
                ruif.pc_enable = 1'b0;
                next_state = IDLE;
            end
            INSTRUCTION_READ : begin
                ruif.pc_enable = 1'b0;
                next_instruction = ruif.imemload;
                next_state = IDLE;
            end
            default : begin
                next_dmemREN = 1'b0;
                next_dmemWEN = 1'b0;
                next_state = state;
                ruif.pc_enable = 1'b0;
                next_dmemaddr = '0;
                next_imemaddr = '0;
                next_dmemstore = '0;
                next_instruction = ruif.instruction;
                next_memdata = ruif.memread_data;
            end
        endcase
    
    end
assign ru.halt = 1'b1;
assign ru.datomic = 1'b0;
endmodule
