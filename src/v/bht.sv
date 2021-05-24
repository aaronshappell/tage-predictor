/*
This is a bimodal prediction history table (BHT)

Table Format:
[Bit 1][Bit 0]

Bit 1: if the branch was taken or not taken
Bit 0: If the prediction is strong or weak

if prev correct
    if curr strong, nothing changes in BHT
    if curr weak, update entry to strong
if prev incorrect
    if curr strong, update to weak
    if curr weak, change prediction from taken to not taken or from not taken to taken
*/

`include "common_defines.svh"

module bht
    (
        input logic clk_i,

        input logic br_result_i,
        input logic [`BHT_IDX_WIDTH-1:0] idx_i,

        output logic prediction_o
    );

    logic [`BHT_IDX_WIDTH-1:0] prev_idx;
    
    // BHT data
    logic [1:0] bht_data [2**`BHT_IDX_WIDTH-1:0];

    // Initialize data to 00 indicating a strong predict not taken entry
    initial begin
        for (int i = 0; i < 2**`BHT_IDX_WIDTH; i++)
            bht_data[i] = 2'b0;
    end

    always_ff @(posedge clk_i) begin
        // Update previous entry based on prediction results
        if (prev_idx != idx_i) begin
            if(br_result_i && (bht_data[prev_idx] != 2'b11))
                bht_data[prev_idx] <= bht_data[prev_idx] + 1;
            else if(~br_result_i && (bht_data[prev_idx] != 2'b0))
                bht_data[prev_idx] <= bht_data[prev_idx] - 1;
        end

        // Output prediction for current entry
        prediction_o <= bht_data[idx_i][1];
        prev_idx <= idx_i;
    end
endmodule