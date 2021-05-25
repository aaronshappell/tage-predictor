/*
Geometric history series: (5, 15, 44, 130)
*/

`include "common_defines.svh"

module tage_predictor
    (
        input logic clk_i,
        input logic br_result_i, correct_i,
        input logic [31:0] idx_i,
        output logic prediction_o
    );

    localparam T0 = 4'b0000;
    localparam T1 = 4'b0001;
    localparam T2 = 4'b0010;
    localparam T3 = 4'b0100;
    localparam T4 = 4'b1000;

    // Global branch and path histories
    logic [`GHIST_LEN-1:0] ghist;
    //logic [`PHIST_LEN-1:0] phist;

    logic [4:0] predictions;
    logic pred, alt_pred;
    logic update_u;
    logic [3:0] providers;
    logic [4:0] alt_providers;
    logic [`TAGE_IDX_WIDTH-1:0] hash_idxs [3:0];
    logic [8:0] hash_tags [3:0];
    logic [3:0] tag_hits, alt_tag_hits;
    logic [3:0] dec_us;
    logic [1:0] us [3:0];
    logic [3:0] allocs;

    bht c_T0 (.clk_i, .br_result_i, .update_en_i(providers == 0), .idx_i(idx_i[`BHT_IDX_WIDTH-1:0]), .prediction_o(predictions[0]));
    tage_table c_T1 (.clk_i, .br_result_i, .update_u_i(update_u), .dec_u_i(dec_us[0]), .alloc_i(allocs[0]), .provider_i(providers[0]), .hash_idx_i(hash_idxs[0]), .hash_tag_i(hash_tags[0]), .prediction_o(predictions[1]), .tag_hit_o(tag_hits[0]), .u_o(us[0]));
    tage_table c_T2 (.clk_i, .br_result_i, .update_u_i(update_u), .dec_u_i(dec_us[1]), .alloc_i(allocs[1]), .provider_i(providers[1]), .hash_idx_i(hash_idxs[1]), .hash_tag_i(hash_tags[1]), .prediction_o(predictions[2]), .tag_hit_o(tag_hits[1]), .u_o(us[1]));
    tage_table c_T3 (.clk_i, .br_result_i, .update_u_i(update_u), .dec_u_i(dec_us[2]), .alloc_i(allocs[2]), .provider_i(providers[2]), .hash_idx_i(hash_idxs[2]), .hash_tag_i(hash_tags[2]), .prediction_o(predictions[3]), .tag_hit_o(tag_hits[2]), .u_o(us[2]));
    tage_table c_T4 (.clk_i, .br_result_i, .update_u_i(update_u), .dec_u_i(dec_us[3]), .alloc_i(allocs[3]), .provider_i(providers[3]), .hash_idx_i(hash_idxs[3]), .hash_tag_i(hash_tags[3]), .prediction_o(predictions[4]), .tag_hit_o(tag_hits[3]), .u_o(us[3]));

    initial begin
        ghist = 0;
        //phist = 0;
    end

    always_comb begin
        providers = tag_hits[3] ? T4 :
                    tag_hits[2] ? T3 :
                    tag_hits[1] ? T2 :
                    tag_hits[0] ? T1 : T0;

        pred = tag_hits[3] ? predictions[4] :
                tag_hits[2] ? predictions[3] :
                tag_hits[1] ? predictions[2] :
                tag_hits[0] ? predictions[1] : predictions[0];

        alt_tag_hits = providers ^ tag_hits;
        alt_providers = alt_tag_hits[3] ? 5'b10000 :
                        alt_tag_hits[2] ? 5'b01000 :
                        alt_tag_hits[1] ? 5'b00100 :
                        alt_tag_hits[0] ? 5'B00010 : 5'b00001;
        alt_pred = (alt_providers & predictions) != 0;
        
        // Calculate update useful counter signal
        update_u = (pred != alt_pred);
    end

    always_ff @(posedge clk_i) begin
        // Update ghist/phist, always a br for sim
        ghist <= {ghist[`GHIST_LEN-2:0], br_result_i};
        //phist <= {phist[`PHIST_LEN-2:0], idx_i[0]};

        // Calculate hashed indexes
        // Hard coded for TAGE_IDX_WIDTH=9 :(
        hash_idxs[0] <= idx_i[8:0]^idx_i[17:9]^idx_i[26:18]^{4'b0, idx_i[31:27]}^{4'b0, ghist[4:0]};//^phist[8:0]^{2'b0 ,phist[15:9]};
        hash_idxs[1] <= idx_i[8:0]^idx_i[17:9]^idx_i[26:18]^{4'b0, idx_i[31:27]}^ghist[8:0]^{3'b0, ghist[14:9]};//^phist[8:0]^{2'b0 ,phist[15:9]};
        hash_idxs[2] <= idx_i[8:0]^idx_i[17:9]^idx_i[26:18]^{4'b0, idx_i[31:27]}^ghist[8:0]^ghist[17:9]^ghist[26:18]^ghist[35:27]^{1'b0, ghist[43:36]};//^phist[8:0]^{2'b0 ,phist[15:9]};
        hash_idxs[3] <= idx_i[8:0]^idx_i[17:9]^idx_i[26:18]^{4'b0, idx_i[31:27]}^ghist[8:0]^ghist[17:9]^ghist[26:18]^ghist[35:27]^ghist[44:36]^ghist[53:45]^ghist[62:54]
                        ^ghist[71:63]^ghist[80:72]^ghist[89:81]^ghist[98:90]^ghist[107:99]^ghist[116:108]^ghist[125:117]^{5'b0 ,ghist[129:126]};//^phist[8:0]^{2'b0 ,phist[15:9]};
        
        // Calculate hashed tags
        hash_tags[0] <= idx_i[8:0]^{4'b0, ghist[4:0]}^{3'b0, ghist[4:0], 1'b0};
        hash_tags[1] <= idx_i[8:0]^ghist[8:0]^{3'b0, ghist[14:9]}^{ghist[7:0], 1'b0}^{1'b0, ghist[14:8], 1'b0};
        hash_tags[2] <= idx_i[8:0]^ghist[8:0]^ghist[17:9]^ghist[26:18]^ghist[35:27]^{1'b0, ghist[43:36]}^{ghist[7:0], 1'b0}^{ghist[15:8], 1'b0}
                        ^{ghist[23:16], 1'b0}^{ghist[31:24], 1'b0}^{ghist[39:32], 1'b0}^{4'b0 ,ghist[43:40], 1'b0};
        hash_tags[3] <= idx_i[8:0]^ghist[8:0]^ghist[17:9]^ghist[26:18]^ghist[35:27]^{1'b0, ghist[43:36]}^{ghist[7:0], 1'b0}^{ghist[15:8], 1'b0}
                        ^{ghist[23:16], 1'b0}^{ghist[31:24], 1'b0}^{ghist[39:32], 1'b0}^{ghist[47:40], 1'b0}^{ghist[55:48], 1'b0}^{ghist[63:56], 1'b0}
                        ^{ghist[71:64], 1'b0}^{ghist[79:72], 1'b0}^{ghist[87:80], 1'b0}^{ghist[95:88], 1'b0}^{ghist[103:96], 1'b0}^{ghist[111:104], 1'b0}
                        ^{ghist[119:112], 1'b0}^{ghist[127:120], 1'b0}^{6'b0 ,ghist[129:128], 1'b0};

        // Determine final prediction
        prediction_o <= pred;

        // Entry allocation
        if (~correct_i) begin
            case (providers)
                T0: begin
                    if (us[0] != 0 && us[1] != 0 && us[2] != 0 && us[3] != 0) // No available entries
                        dec_us <= 4'b1111;
                    else begin
                        dec_us <= 4'b0;
                        allocs <= (us[0] == 0) ? T1 : (us[1] == 0) ? T2 : (us[2] == 0) ? T3 : T4;
                    end
                end
                T1: begin
                    if (us[1] != 0 && us[2] != 0 && us[3] != 0)
                        dec_us <= 4'b1110;
                    else begin
                        dec_us <= 4'b0;
                        allocs <= (us[1] == 0) ? T2 : (us[2] == 0) ? T3 : T4;
                    end
                end
                T2: begin
                    if (us[2] != 0 && us[3] != 0)
                        dec_us <= 4'b1100;
                    else begin
                        dec_us <= 4'b0;
                        allocs <= (us[2] == 0) ? T3 : T4;
                    end
                end
                T3: begin
                    if (us[3] != 0)
                        dec_us <= 4'b1000;
                    else begin
                        dec_us <= 4'b0;
                        allocs <= T4;
                    end
                end
                default: begin
                    dec_us <= 4'b0;
                    allocs <= 4'b0;
                end
            endcase
        end
    end
endmodule
