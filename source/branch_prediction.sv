module branch_prediction(
    input logic [7:0] index, next_index,
    input logic [21:0] tag, 
    input logic [31:0] pc,
    input logic branch,
    output logic [31:0] predicted_pc;
);


// pseudo code

logic [255:0] [23:0] BPT;

logic [255:0] [31:0] BTB; // why not just store the immediate field?

assign next_pc = (BPT[index][23:2] == pc[31:11] && BPT[index][1]) ? BTB[index] : pc + 4;

always_ff @(posedge CLK, posedge nRST) begin
    if(!nRST) begin
        BPT <= '0;
        BTB <= '0;
    end else begin
        BPT <= next_BPT;
        BTB <= next_BTB;
    end
end


assign next_BTB[next_index] = (branch) ? pc + imm_gen : BTB[index];
assign next_BPT[next_index]
always_comb begin // branch prediction table state transition ; tag bits
    casez(BPT[insert_index])
        2'b00 : next_BPT[next_index][1:0] = (branch) ? 2'b10 : 2'b01; // branch not taken soft
        2'b01 : next_BPT[next_index][1:0] = (branch) ? 2'b00 : 2'b01; // branch not taken hard
        2'b10 : next_BPT[next_index][1:0] = (branch) ? 2'b11 : 2'b00; // branch taken soft
        2'b11 : next_BPT[next_index][1:0] = (branch) ? 2'b11 : 2'b10; // branch taken hard
    endcase
end
always_comb begin
    predicted_pc = pc + 4;
    if(BPT[index][1]) begin
        predicted_pc = BTB[index];
    end
end


endmodule