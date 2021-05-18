module top
    (
        input logic clk_i,
        input logic reset_i,
        output logic [7:0] count
    );

    always_ff @(posedge clk_i) begin
        if(reset_i)
            count <= 0;
        else
            count <= count + 1;
    end
endmodule