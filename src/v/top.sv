`include "common_defines.svh"

module top
    (
        input logic clk_i,
        /* verilator lint_off UNUSED */
        input logic [31:0] w_idx_i,
        input logic br_result_i,
        input logic [31:0] r_idx_i,
        /* verilator lint_on UNUSED */
        output logic prediction_o
    );
    /* verilator lint_off WIDTH */
    // always_predictor p (.*);
    bht b (.*);
    //tage_predictor tp (.*);
    /* verilator lint_on WIDTH */
endmodule