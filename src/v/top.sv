`include "common_defines.svh"

module top
    (
        input logic clk_i
    );
    //parameter NUM_ADDR = 3898078;
    //parameter NUM_ADDR = 4797614;
    //parameter NUM_ADDR = 8613065;
    //parameter NUM_ADDR = 5988668;
    //parameter NUM_ADDR = 5114376;
    //parameter NUM_ADDR = 4270713;
    //parameter NUM_ADDR = 3970578;
    parameter NUM_ADDR = 4840286;
    logic [31:0] addresses [NUM_ADDR - 1:0];
    logic branchresults [NUM_ADDR - 1:0];

    logic [`IDX_WIDTH-1:0] w_idx_i;
    logic br_result_i;
    logic [`IDX_WIDTH-1:0] r_idx_i;
    logic prediction_o;

    integer br_index = 0;
    integer prev_br_index = 0;
    integer mispredictions = 0;

    //always_predictor p (.*);
    bht b (.*);

    initial begin
        $readmemh("traces/addresses7", addresses);
        $readmemb("traces/branchresults7", branchresults);
    end

    always_ff @(posedge clk_i) begin
        w_idx_i <= addresses[prev_br_index][`IDX_WIDTH-1:0];
        r_idx_i <= addresses[br_index][`IDX_WIDTH-1:0];
        br_result_i <= branchresults[prev_br_index];
        if(prediction_o != branchresults[br_index])
            mispredictions <= mispredictions + 1;
        prev_br_index <= br_index;
        br_index <= br_index + 1;
        
        if(br_index >= NUM_ADDR) begin
            $display("Branches: %d", br_index);
            $display("Mispredictions: %d", mispredictions);
            $display("Misprediction Rate: %f", real'(mispredictions) / real'(br_index));
            $finish;
        end
    end
endmodule