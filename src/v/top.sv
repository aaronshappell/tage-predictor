`include "common_defines.svh"

module top
    (
        input logic clk_i,
        input logic reset_i,
        output logic prediction
    );
    assign prediction = `BR_TAKEN;
endmodule