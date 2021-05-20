`include "common_defines.svh"

module tage_component
    #(
        parameter N = 1
    )
    (
        input logic clk_i,
        input logic pc_i,
        input logic h_i,
        output logic prediction_o
    );
    assign prediction_o = `BR_TAKEN;
endmodule