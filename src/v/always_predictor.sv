/*
Simple always taken branch predictor
*/

`include "common_defines.svh"

module always_predictor
    (
        input logic clk_i,
        input logic reset_i,
        output logic prediction
    );
    assign prediction = `BR_TAKEN;
endmodule