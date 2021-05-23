#include <iostream>
#include <fstream>
#include <string>
#include <verilated.h>

#include "Vtop.h"

#define NUM_TRACES 8

int main(int argc, char** argv, char** env) {
    // Prevent unused variable warnings
    if (false && argc && argv && env) {}

    // Simulate traces
    for(int i = 0; i < NUM_TRACES; i++) {
        // Construct verilated model
        Vtop* top = new Vtop;

        // Statistics
        int num_branches = 0;
        int num_mispred = 0;
        uint32_t prev_address = 0;
        int prev_branchresult = 0;

        std::string address;
        std::string branchresult;
        std::ifstream address_file("traces/addresses" + std::to_string(i));
        std::ifstream branchresult_file("traces/branchresults" + std::to_string(i));
        if(address_file.is_open() && branchresult_file.is_open()) {
            while(getline(address_file, address)) {
                getline(branchresult_file, branchresult);
                num_branches++;

                uint32_t mask = 0x3ff;

                top->w_idx_i = prev_address;
                top->br_result_i = prev_branchresult;
                top->r_idx_i = mask & std::stoul(address, nullptr, 16);
                top->clk_i = 1;
                top->eval();
                top->clk_i = 0;
                top->eval();

                if (top->prediction_o != std::stoi(branchresult)) {
                    num_mispred++;
                }

                prev_address = mask & std::stoul(address, nullptr, 16);
                prev_branchresult = std::stoi(branchresult);
            }
            address_file.close();
            branchresult_file.close();
        } else {
            VL_PRINTF("ERROR: unable to open trace files\n");
        }

        // Calculate mispred_rate
        float mispred_rate = (float) num_mispred / (float) num_branches;

        // Print results
        VL_PRINTF("-- Trace %d Results -------------\n", i);
        VL_PRINTF("  Branches: %d\n", num_branches);
        VL_PRINTF("  Mispredictions: %d\n", num_mispred);
        VL_PRINTF("  Misprediction Rate: %f\n\n", mispred_rate);

        // Cleanup
        top->final();
        delete top;
    }

    return 0;
}
