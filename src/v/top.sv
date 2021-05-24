`include "common_defines.svh"

module top
    (
        input logic clk_i,
        /* verilator lint_off UNUSED */
        input logic br_result_i, correct_i,
        input logic [31:0] idx_i,
        /* verilator lint_on UNUSED */
        output logic prediction_o
    );
    /* verilator lint_off WIDTH */
    // always_predictor p (.*);
    //bht b (.*);
    tage_predictor tp (.*);
    /* verilator lint_on WIDTH */
endmodule