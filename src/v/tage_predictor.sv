/*
Geometric history series: (5, 15, 44, 130)
*/

`include "common_defines.svh"

module tage_predictor
    (
        input logic clk_i,
        input logic br_result_i,
        input logic [31:0] idx_i,
        output logic prediction_o
    );

    // Global branch and path histories
    logic [`GHIST_LEN-1:0] ghist;
    logic [`PHIST_LEN-1:0] phist;

    logic [4:0] predictions;
    logic [3:0] update_us;
    logic [3:0] providers;
    logic [`TAGE_IDX_WIDTH-1:0] hash_idxs [3:0];
    logic [9:0] hash_tags [3:0];
    logic [3:0] tag_hits;

    bht T0 (.clk_i, .br_result_i, .idx_i, .prediction_o(predictions[0]));
    tage_table T1 (.clk_i, .br_result_i, .update_u_i(update_us[0]), .provider_i(providers[0]), .hash_idx_i(hash_idxs[0]), .hash_tag_i(hash_tags[0]), .prediction_o(predictions[1]), .tag_hit_o(tag_hits[0]));
    tage_table T2 (.clk_i, .br_result_i, .update_u_i(update_us[1]), .provider_i(providers[1]), .hash_idx_i(hash_idxs[1]), .hash_tag_i(hash_tags[1]), .prediction_o(predictions[2]), .tag_hit_o(tag_hits[1]));
    tage_table T3 (.clk_i, .br_result_i, .update_u_i(update_us[0]), .provider_i(providers[2]), .hash_idx_i(hash_idxs[2]), .hash_tag_i(hash_tags[2]), .prediction_o(predictions[3]), .tag_hit_o(tag_hits[2]));
    tage_table T4 (.clk_i, .br_result_i, .update_u_i(update_us[0]), .provider_i(providers[3]), .hash_idx_i(hash_idxs[3]), .hash_tag_i(hash_tags[3]), .prediction_o(predictions[4]), .tag_hit_o(tag_hits[3]));

    initial begin
        ghist = 0;
        phist = 0;
    end

    always_ff @(posedge clk_i) begin
        // Update ghist/phist, always a br for sim
        ghist <= {ghist[`GHIST_LEN-2:0], br_result_i};
        phist <= {phist[`PHIST_LEN-2:0], idx_i[0]};

        // Calculate hashed indexes
        // Hard coded for TAGE_IDX_WIDTH=9 :(
        hash_idxs[0] <= idx_i[8:0]^idx_i[17:9]^idx_i[26:18]^{4'b0, idx_i[31:27]}^{4'b0, ghist[4:0]};//^phist[8:0]^{2'b0 ,phist[15:9]};
        hash_idxs[1] <= idx_i[8:0]^idx_i[17:9]^idx_i[26:18]^{4'b0, idx_i[31:27]}^ghist[8:0]^{3'b0, ghist[14:9]};
        hash_idxs[2] <= idx_i[8:0]^idx_i[17:9]^idx_i[26:18]^{4'b0, idx_i[31:27]}^ghist[8:0]^ghist[17:9]^ghist[26:18]^ghist[35:27]^{1'b0, ghist[43:36]};
        hash_idxs[3] <= idx_i[8:0]^idx_i[17:9]^idx_i[26:18]^{4'b0, idx_i[31:27]}^ghist[8:0]^ghist[17:9]^ghist[26:18]^ghist[35:27]^ghist[44:36]^ghist[53:45]
                        ^ghist[62:54]^ghist[71:63]^ghist[80:72]^ghist[89:81]^ghist[98:90]^ghist[107:99]^ghist[116:108]^ghist[125:117]^{5'b0 ,ghist[129:126]};
        
        // Calculate hashed tags
        hash_tags[0] <= idx_i[8:0]^{4'b0, ghist[4:0]}^{3'b0, ghist[4:0], 1'b0};
        hash_tags[1] <= idx_i[8:0]^ghist[8:0]^{3'b0, ghist[14:9]}^{ghist[7:0], 1'b0}^{1'b0, ghist[14:8], 1'b0};
        hash_tags[2] <= idx_i[8:0]^ghist[8:0]^ghist[17:9]^ghist[26:18]^ghist[35:27]^{1'b0, ghist[43:36]}^{ghist[7:0], 1'b0}^{ghist[15:8], 1'b0}
                        ^{ghist[23:16], 1'b0}^{ghist[31:24], 1'b0}^{ghist[39:32], 1'b0}^{4'b0 ,ghist[43:40], 1'b0};
        hash_tags[3] <= idx_i[8:0]^ghist[8:0]^ghist[17:9]^ghist[26:18]^ghist[35:27]^{1'b0, ghist[43:36]}^{ghist[7:0], 1'b0}^{ghist[15:8], 1'b0}
                        ^{ghist[23:16], 1'b0}^{ghist[31:24], 1'b0}^{ghist[39:32], 1'b0}^{ghist[47:40], 1'b0}^{ghist[55:48], 1'b0}^{ghist[63:56], 1'b0}
                        ^{ghist[71:64], 1'b0}^{ghist[79:72], 1'b0}^{ghist[87:80], 1'b0}^{ghist[95:88], 1'b0}^{ghist[103:96], 1'b0}^{ghist[111:104], 1'b0}
                        ^{ghist[119:112], 1'b0}^{ghist[127:120], 1'b0}^{6'b0 ,ghist[129:128], 1'b0};
    end
endmodule
