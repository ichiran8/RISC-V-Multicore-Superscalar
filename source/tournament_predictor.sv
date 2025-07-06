module tournament_predictor(
    input logic CLK, nRST, enable, branch_mispredicted1, branch_mispredicted2, prev_same_pred1, prev_same_pred2, dual_branch,
    input logic [5:0] index1, index2, next_index1, next_index2, 
    input logic [31:0] pc, target1, target2,
    input logic [5:0] prev_ghr1, prev_ghr2,
    input logic branch1, branch2, if_id1_branch, if_id2_branch, id_ex2_branch, id_ex1_branch, // if_id1_branchindicates it is a branch instruction from execute stage
    output logic [31:0] predicted_pc,
    output logic branch_predicted1, branch_predicted2, same_pred1, same_pred2,
    output logic [5:0] used_ghr1, used_ghr2
);




// pseudo code
typedef struct packed {
    logic [1:0] ctr;
} GPHT;
GPHT [63:0] global_pattern_history_table, next_GPHT;

logic [5:0] global_history_register;

typedef struct packed {
    logic [1:0] ctr;
} PHT;

PHT [63:0] local_pattern_history_table, next_LPHT;

typedef struct packed {
    logic [5:0] hist;
} BHT;

BHT [63:0] branch_history_table, next_BHT;

typedef struct packed {
    logic [1:0] ctr; // if the counter is >= 2, use gshare. Otherwise, use local history
} T_PRED;

T_PRED [63:0] tournament_table, next_TT;

typedef struct packed {
    logic [31:0] addr;
    logic valid;
} BTB;

BTB [63:0] branch_target_buffer, next_BTB;

always_ff @(posedge CLK, negedge nRST) begin
    if(!nRST) begin
        global_pattern_history_table <= '0;
        local_pattern_history_table <= '0;
        branch_history_table <= '0;
        branch_target_buffer <= '0;
        tournament_table <= '0;
    end else if(enable) begin
        global_pattern_history_table <= next_GPHT;
        local_pattern_history_table <= next_LPHT;
        branch_history_table <= next_BHT;
        branch_target_buffer <= next_BTB; 
        tournament_table <= next_TT;
    end
end

always_ff @(posedge CLK, negedge nRST) begin
    if(!nRST) begin
        global_history_register <= '0;
        // we will only ever have one branch in the pipeline so this is not an issue
    end else if(enable && id_ex1_branch) begin
        global_history_register <= {global_history_register[4:0], branch1};
    end else if (enable && id_ex2_branch) begin
        global_history_register <= {global_history_register[4:0], branch2};
    end
end
assign used_ghr1 = global_history_register;
assign used_ghr2 = global_history_register;
// Buffer update stage ; we will update the buffer with the correct target
always_comb begin
    next_BTB = branch_target_buffer;
    next_BHT = branch_history_table;
    if(id_ex1_branch) begin
        next_BTB[next_index1].addr = target1; // update the buffer to store the target
        next_BTB[next_index1].valid = 1'b1; // make sure it is a valid entry 
        next_BHT[next_index1].hist = {branch_history_table[next_index1].hist[4:0], branch1}; // we update the branch history table entry   
    end else if(id_ex2_branch) begin
        next_BTB[next_index2].addr = target2;
        next_BTB[next_index2].valid = 1'b1;
        next_BHT[next_index2].hist = {branch_history_table[next_index2].hist[4:0], branch2};
    end 
end


// logic [1:0] output_index_update;
// assign output_index_update = global_pattern_history_table[global_history_register ^ next_index].ctr;
always_comb begin // branch prediction table state transition ; tag bits
    next_GPHT = global_pattern_history_table;
    if(id_ex1_branch) begin // only update if it is a branch 
        casez(global_pattern_history_table[prev_ghr1 ^ next_index1].ctr)
            2'b00 : next_GPHT[prev_ghr1 ^ next_index1].ctr = (branch1) ? {2'b10} : {2'b01}; // branch not taken soft
            2'b01 : next_GPHT[prev_ghr1 ^ next_index1].ctr = (branch1) ? {2'b00} : {2'b01}; // branch not taken hard
            2'b10 : next_GPHT[prev_ghr1 ^ next_index1].ctr = (branch1) ? {2'b11} : {2'b00}; // branch taken soft
            2'b11 : next_GPHT[prev_ghr1 ^ next_index1].ctr = (branch1) ? {2'b11} : {2'b10}; // branch taken hard
        endcase
    end else if(id_ex2_branch) begin // only update if it is a branch 
        casez(global_pattern_history_table[global_history_register ^ next_index2].ctr)
            2'b00 : next_GPHT[prev_ghr2 ^ next_index2].ctr = (branch2) ? {2'b10} : {2'b01}; // branch not taken soft
            2'b01 : next_GPHT[prev_ghr2 ^ next_index2].ctr = (branch2) ? {2'b00} : {2'b01}; // branch not taken hard
            2'b10 : next_GPHT[prev_ghr2 ^ next_index2].ctr = (branch2) ? {2'b11} : {2'b00}; // branch taken soft
            2'b11 : next_GPHT[prev_ghr2 ^ next_index2].ctr = (branch2) ? {2'b11} : {2'b10}; // branch taken hard
        endcase
    end
end


always_comb begin // branch prediction table state transition ; tag bits
    next_LPHT = local_pattern_history_table;
    if(id_ex1_branch) begin // only update if it is a branch 
        casez(local_pattern_history_table[branch_history_table[next_index1]].ctr)
            2'b00 : next_LPHT[branch_history_table[next_index1]].ctr = (branch1) ? {2'b10} : {2'b01}; // branch not taken soft
            2'b01 : next_LPHT[branch_history_table[next_index1]].ctr = (branch1) ? {2'b00} : {2'b01}; // branch not taken hard
            2'b10 : next_LPHT[branch_history_table[next_index1]].ctr = (branch1) ? {2'b11} : {2'b00}; // branch taken soft
            2'b11 : next_LPHT[branch_history_table[next_index1]].ctr = (branch1) ? {2'b11} : {2'b10}; // branch taken hard
        endcase
    end else if(id_ex2_branch) begin // only update if it is a branch 
        casez(local_pattern_history_table[branch_history_table[next_index2]].ctr)
            2'b00 : next_LPHT[branch_history_table[next_index2]].ctr = (branch2) ? {2'b10} : {2'b01}; // branch not taken soft
            2'b01 : next_LPHT[branch_history_table[next_index2]].ctr = (branch2) ? {2'b00} : {2'b01}; // branch not taken hard
            2'b10 : next_LPHT[branch_history_table[next_index2]].ctr = (branch2) ? {2'b11} : {2'b00}; // branch taken soft
            2'b11 : next_LPHT[branch_history_table[next_index2]].ctr = (branch2) ? {2'b11} : {2'b10}; // branch taken hard
        endcase
    end
end


// choose which predictor to use
// 1 indicates we chose local history and 2 indicates we chose 

logic [5:0] output_index;

assign output_index = (if_id1_branch) ? global_history_register ^ index1 : global_history_register ^ index2;

logic chosen_predictor;
always_comb begin
    chosen_predictor = 0;
    if(if_id1_branch) begin
        if(tournament_table[index1].ctr[1]) begin
            chosen_predictor = 2'd2; // use gshare predictor
        end else begin
            chosen_predictor = 2'd1; // use local history predictor 
        end
    end else if (if_id2_branch) begin
        if(tournament_table[index2].ctr[1]) begin
            chosen_predictor = 2'd2;
        end else begin
            chosen_predictor = 2'd1;
        end
    end
end

logic g_pred1, l_pred1, g_pred2, l_pred2;
assign g_pred1 = global_pattern_history_table[global_history_register ^ index1].ctr[1];
assign l_pred1 = local_pattern_history_table[branch_history_table[index1].hist].ctr[1];
assign g_pred2 = global_pattern_history_table[global_history_register ^ index2].ctr[1];
assign l_pred2 = local_pattern_history_table[branch_history_table[index2].hist].ctr[1];

assign same_pred1 = (g_pred1 == l_pred1);
assign same_pred2 = (g_pred2 == l_pred2);

always_comb begin
    branch_predicted1 = 1'b0;
    branch_predicted2 = 1'b0;
    predicted_pc = pc + 8;
    // instruction 1
    if(if_id1_branch && branch_target_buffer[index1].valid) begin
        if(chosen_predictor == 2'd2) begin
            if(global_pattern_history_table[output_index].ctr[1]) begin
                predicted_pc = branch_target_buffer[index1].addr;
                branch_predicted1 = 1'b1;
            end else begin
                predicted_pc = (dual_branch) ? pc + 4 : pc + 8; // if dual branches, fetch the second instruction again 
                branch_predicted1 = 1'b0;
            end
        end else begin
            if(local_pattern_history_table[branch_history_table[index1].hist].ctr[1]) begin
                predicted_pc = branch_target_buffer[index1].addr;
                branch_predicted1 = 1'b1;
            end else begin
                predicted_pc = (dual_branch) ? pc + 4 : pc + 8;
                branch_predicted1 = 1'b0;
            end
        end
    // instruction 2
    end else if(if_id2_branch && branch_target_buffer[index2].valid) begin
        if(chosen_predictor == 2'd2) begin
            if(global_pattern_history_table[output_index].ctr[1]) begin
                predicted_pc = branch_target_buffer[index2].addr;
                branch_predicted2 = 1'b1;
            end else begin
                predicted_pc = pc + 8;
                branch_predicted2 = 1'b0;
            end
        end else begin
            if(local_pattern_history_table[branch_history_table[index2].hist].ctr[1]) begin
                predicted_pc = branch_target_buffer[index2].addr;
                branch_predicted2 = 1'b1;
            end else begin
                predicted_pc = pc + 8;
                branch_predicted2 = 1'b0;
            end
        end
    end
end
// if the previous chosen predictor was 2, the table we index has to be 2 or 3. Therefore we must check 
// if the previous chosen predictor was 1, the table we index has to be 0 or 1

// 00 indicates that weakly local
// 01 indicates that strongly local
// 10 indicatetes weakly gshare
// 11 indicates strongly gshare
always_comb begin // branch prediction table state transition ; tag bits
    next_TT = tournament_table;
    if(id_ex1_branch && !prev_same_pred1) begin // only update if it is a branch 
        casez(tournament_table[next_index1].ctr)
            2'b00 : next_TT[next_index1].ctr = (branch_mispredicted1) ? {2'b10} : {2'b01}; // branch not taken soft
            2'b01 : next_TT[next_index1].ctr = (branch_mispredicted1) ? {2'b00} : {2'b01}; // branch not taken hard
            2'b10 : next_TT[next_index1].ctr = (branch_mispredicted1) ? {2'b00} : {2'b11}; // branch taken soft
            2'b11 : next_TT[next_index1].ctr = (branch_mispredicted1) ? {2'b10} : {2'b11}; // branch taken hard
        endcase
    end else if(id_ex2_branch && !prev_same_pred2) begin // only update if it is a branch 
        casez(tournament_table[next_index2].ctr)
            2'b00 : next_TT[next_index2].ctr = (branch_mispredicted2) ? {2'b10} : {2'b01}; // branch not taken soft
            2'b01 : next_TT[next_index2].ctr = (branch_mispredicted2) ? {2'b00} : {2'b01}; // branch not taken hard
            2'b10 : next_TT[next_index2].ctr = (branch_mispredicted2) ? {2'b00} : {2'b11}; // branch taken soft
            2'b11 : next_TT[next_index2].ctr = (branch_mispredicted2) ? {2'b10} : {2'b11}; // branch taken hard
        endcase
    end
end
endmodule

