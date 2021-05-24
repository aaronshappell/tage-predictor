`include "common_defines.svh"

// TODO: columns of u counter periodic reset alternating

module tage_table
    (
        input logic clk_i,

        input logic br_result_i, update_u_i, dec_u_i, alloc_i, provider_i,
        input logic [`TAGE_IDX_WIDTH-1:0] hash_idx_i,
        input logic [8:0] hash_tag_i,

        output logic prediction_o, tag_hit_o,
        output logic [1:0] u_o
    );

    // Prediction, tag, and useful tables
    logic [2:0] ctr [2**`TAGE_IDX_WIDTH-1:0];
    logic [8:0] tag [2**`TAGE_IDX_WIDTH-1:0];
    logic [1:0] u   [2**`TAGE_IDX_WIDTH-1:0];

    logic [`TAGE_IDX_WIDTH-1:0] prev_idx;
    logic [8:0] prev_hash_tag;
    
    // Initialize tables
    initial begin
        for (int i = 0; i < 2**`TAGE_IDX_WIDTH; i++) begin
            ctr[i] = 3'b0;
            tag[i] = 9'b0;
            u[i]   = 2'b0;
        end
    end

    always_ff @(posedge clk_i) begin
        if (alloc_i) begin
            ctr[prev_idx] <= br_result_i ? 3'b100 : 3'b011; // Init ctr to weak correct
            tag[prev_idx] <= prev_hash_tag;
            u[prev_idx] <= 2'b0;
        end

        if (dec_u_i && (u[prev_idx] != 2'b00))
            u[prev_idx] <= u[prev_idx] - 1;

        if (provider_i) begin
            // Update prediction counter
            if (prev_idx != hash_idx_i) begin
                if (br_result_i && (ctr[prev_idx] != 3'b111))
                    ctr[prev_idx] <= ctr[prev_idx] + 1;
                else if (~br_result_i && ctr[prev_idx] != 3'b0)
                    ctr[prev_idx] <= ctr[prev_idx] - 1;
            end

            // Update useful counter
            if (update_u_i) begin
                if ((br_result_i == ctr[prev_idx][2]) && (u[prev_idx] != 2'b11))
                    u[prev_idx] <= u[prev_idx] + 1;
                else if ((br_result_i != ctr[prev_idx][2]) && (u[prev_idx] != 2'b00))
                    u[prev_idx] <= u[prev_idx] - 1;
            end
        end
        tag_hit_o <= (tag[hash_idx_i] == hash_tag_i);
        prediction_o <= ctr[hash_idx_i][2];
        u_o <= u[hash_idx_i];
        prev_idx <= hash_idx_i;
        prev_hash_tag <= hash_tag_i;
    end
endmodule