#include <iostream>
#include <fstream>
#include <string>
#include <verilated.h>

#include "Vbht.h"

#define NUM_TRACES 13

void tick(Vbht* bht) {
    bht->clk_i = 1;
    bht->eval();
    bht->clk_i = 0;
    bht->eval();
}

int main(int argc, char** argv, char** env) {
    // Prevent unused variable warnings
    if (false && argc && argv && env) {}

    // Construct verilated model
    Vbht* bht = new Vbht;

    // Set input signals
    bht->clk_i = 0;
    bht->eval();

    // 00 -> 00
    bht->w_idx_i = 0;
    bht->br_result_i = 0;
    bht->r_idx_i = 1;
    tick(bht);

    bht->r_idx_i = 0;
    tick(bht);

    VL_PRINTF("Prediction: %d\n", bht->prediction_o);

    // 00 -> 01
    bht->br_result_i = 1;
    bht->r_idx_i = 1;
    tick(bht);

    bht->r_idx_i = 0;
    tick(bht);

    VL_PRINTF("Prediction: %d\n", bht->prediction_o);

    // 01 -> 00
    bht->br_result_i = 0;
    bht->r_idx_i = 1;
    tick(bht);

    bht->r_idx_i = 0;
    tick(bht);

    VL_PRINTF("Prediction: %d\n", bht->prediction_o);

    // revert to 01
    bht->br_result_i = 1;
    bht->r_idx_i = 1;
    tick(bht);
    bht->r_idx_i = 0;
    tick(bht);

    // 01 -> 10
    bht->br_result_i = 1;
    bht->r_idx_i = 1;
    tick(bht);

    bht->r_idx_i = 0;
    tick(bht);

    VL_PRINTF("Prediction: %d\n", bht->prediction_o);

    // 10 -> 01
    bht->br_result_i = 0;
    bht->r_idx_i = 1;
    tick(bht);

    bht->r_idx_i = 0;
    tick(bht);

    VL_PRINTF("Prediction: %d\n", bht->prediction_o);

    // refert to 10
    bht->br_result_i = 1;
    bht->r_idx_i = 1;
    tick(bht);
    bht->r_idx_i = 0;
    tick(bht);

    // 10 -> 11
    bht->br_result_i = 1;
    bht->r_idx_i = 1;
    tick(bht);

    bht->r_idx_i = 0;
    tick(bht);

    VL_PRINTF("Prediction: %d\n", bht->prediction_o);

    // 11 -> 11
    bht->br_result_i = 1;
    bht->r_idx_i = 1;
    tick(bht);

    bht->r_idx_i = 0;
    tick(bht);

    VL_PRINTF("Prediction: %d\n", bht->prediction_o);

    // 11 -> 10
    bht->br_result_i = 0;
    bht->r_idx_i = 1;
    tick(bht);

    bht->r_idx_i = 0;
    tick(bht);

    VL_PRINTF("Prediction: %d\n", bht->prediction_o);

    // Cleanup
    bht->final();
    delete bht;
    return 0;
}
