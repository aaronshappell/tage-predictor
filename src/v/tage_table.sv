`include "common_defines.svh"

module tage_table
    (
        input logic clk_i,

        input logic br_result_i, update_u_i, dec_u_i, alloc_i, provider_i,
        input logic [`TAGE_IDX_WIDTH-1:0] hash_idx_i,
        input logic [8:0] hash_tag_i,

        output logic prediction_o, tag_hit_o, new_entry_o,
        output logic [1:0] u_o
    );

    // Prediction, tag, and useful tables
    logic [2:0] ctr [2**`TAGE_IDX_WIDTH-1:0];
    logic [8:0] tag [2**`TAGE_IDX_WIDTH-1:0];
    logic [1:0] u   [2**`TAGE_IDX_WIDTH-1:0];

    logic [`TAGE_IDX_WIDTH-1:0] prev_idx;
    logic [8:0] prev_hash_tag;

    logic [17:0] u_clear_ctr;
    logic u_clear_col;
    
    // Initialize tables
    initial begin
        for (int i = 0; i < 2**`TAGE_IDX_WIDTH; i++) begin
            ctr[i] = 3'b0;
            tag[i] = 9'b0;
            u[i]   = 2'b0;
        end

        u_clear_ctr = 0;
        u_clear_col = 0;
    end

    assign new_entry_o = ((ctr[prev_idx] == `TAGE_WEAK_TAKEN || ctr[prev_idx] == `TAGE_WEAK_NOT_TAKEN) && u[prev_idx] == 2'b0);

    always_ff @(posedge clk_i) begin
        if (alloc_i) begin
            // Init ctr to weak correct
            ctr[prev_idx] <= br_result_i ? `TAGE_WEAK_TAKEN : `TAGE_WEAK_NOT_TAKEN;
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

        // Update useful clear counter
        if (u_clear_ctr == 2**18-1) begin
            for (int i = 0; i < `TAGE_IDX_WIDTH; i++)
                u[i][u_clear_col] <= 0;

            u_clear_ctr <= 0;
            u_clear_col <= ~u_clear_col;
        end else
            u_clear_ctr <= u_clear_ctr + 1;
    end
endmodule