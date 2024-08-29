`include "cpu_types_pkg.vh"
`include "arithmetic_logic_if.vh"
import cpu_types_pkg::*;

module alu(arithmetic_logic_if.aluds aluif);

always_comb begin
    aluif.result = '0;
    aluif.overflow = 1'b0;
    casez(aluif.alu_op) 
        ALU_SLL : aluif.result = aluif.rda << aluif.rdb;
        ALU_SRL : aluif.result = aluif.rda >> aluif.rdb;
        ALU_SRA : aluif.result = $signed(aluif.rda) >>> $signed(aluif.rdb);
        ALU_ADD : begin 
            aluif.result = $signed(aluif.rda) + $signed(aluif.rdb);
                if((aluif.rda[31] && aluif.rdb[31] && !aluif.result[31]) || (!aluif.rda[31] && !aluif.rdb[31] && aluif.result[31])) begin
                    aluif.overflow = 1'b1;
                end
        end
        ALU_SUB : begin 
            aluif.result = $signed(aluif.rda) - $signed(aluif.rdb);
            if((aluif.rda[31] && !aluif.rdb[31] && !aluif.result[31]) || (!aluif.rda[31] && aluif.rdb[31] && aluif.result[31])) begin
                aluif.overflow = 1'b1; 
            end
        end
        ALU_AND : aluif.result = aluif.rda & aluif.rdb;
        ALU_OR  : aluif.result = aluif.rda | aluif.rdb;
        ALU_XOR : aluif.result = aluif.rda ^ aluif.rdb;
        ALU_SLT : aluif.result = ($signed(aluif.rda) < $signed(aluif.rdb)) ? 1 : 0;
        ALU_SLTU : aluif.result = ($unsigned(aluif.rda) < $unsigned(aluif.rdb)) ? 1 : 0;
    endcase    
end

assign aluif.zero = (aluif.result == 0);
assign aluif.negative = aluif.result[31];


// always_comb begin
//     aluif.overflow = 1'b0;
//     if(aluif.alu_op == ALU_ADD) begin
//         if((aluif.rda[31] && aluif.rdb[31] && !aluif.result[31]) || (!aluif.rda[31] && !aluif.rdb[31] && aluif.result[31])) begin
//             aluif.overflow = 1'b1;
//         end
//     end else if (aluif.alu_op == ALU_SUB) begin
//         if((aluif.rda[31] && !aluif.rdb[31] && !aluif.result[31]) || (!aluif.rda[31] && aluif.rdb[31] && aluif.result[31])) begin
//             aluif.overflow = 1'b1; 
//         end
//     end
// end
endmodule