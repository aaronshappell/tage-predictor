/*
Simple always taken branch predictor
*/

`include "common_defines.svh"

module always_predictor
    (
        input logic clk_i,
        output logic prediction_o
    );
    assign prediction_o = `BR_TAKEN;
endmodule