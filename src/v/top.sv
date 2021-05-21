`include "common_defines.svh"

module top
    (
        input logic clk_i,
        input logic [`IDX_WIDTH-1:0] w_idx_i,
        input logic br_result_i,
        input logic [`IDX_WIDTH-1:0] r_idx_i,
        output logic prediction_o
    );
    // always_predictor p (.*);
    bht b (.*);
endmodule