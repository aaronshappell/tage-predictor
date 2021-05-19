module top
    (
        input logic clk_i,
        input logic reset_i,
        output logic prediction
    );

    localparam NOT_TAKEN = 1'b0;
    localparam TAKEN = 1'b1;

    assign prediction = TAKEN;
endmodule