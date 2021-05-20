/*
    This is a bimodal prediction history table (BHT)

Table Format:
    [Bit 1][Bit 0]

    Bit 1: if the branch was taken or not taken
    Bit 0: If the prediction is strong or weak

    if prev correct
        if curr strong, nothing changes in BHT
        if curr weak, update entry to strong
    if prev incorrect
        if curr strong, update to weak
        if curr weak, change prediction from taken to not taken or from not taken to taken
*/

module bht
    #(parameter IDX_WIDTH = 9)
    (
        input logic clk_i,

        input logic [IDX_WIDTH-1:0] w_addr_i,
        input logic correct_i,
        input logic [1:0] prev_prediction_i,

        input logic [IDX_WIDTH-1:0] r_addr_i,
        output logic [1:0] prediction_o
    );
    
    // BHT
    logic [1:0] bht_data [2**IDX_WIDTH-1:0];

    initial begin
        for (int i = 0; i < 2**IDX_WIDTH; i = i+1)
            bht_data[i] = 2'b00;
    end

    // ?
    logic [1:0] w_data;
    assign w_data = correct_i ? {prev_prediction_i[1], prev_prediction_i[1]} : {prev_prediction_i[0], ~prev_prediction_i[0]};

    // On reset, set contents of BHT to 0
    integer i;
    always_ff @(posedge clk_i) begin
        // Update previous entry based on prediction results
        if (w_addr_i != r_addr_i)
            bht_data[w_addr_i] <= w_data;

        // Output prediction for current entry
        prediction_o <= bht_data[r_addr_i][1:0];
    end
endmodule