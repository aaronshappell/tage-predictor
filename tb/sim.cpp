#include <iostream>
#include <fstream>
#include <string>
#include <verilated.h>

#include "Vtop.h"

#define NUM_TRACES 13

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

        // Set input signals
        top->clk_i = 0;
        top->reset_i = 1;
        top->eval();
        top->reset_i = 0;

        std::string address;
        std::string branchresult;
        std::ifstream address_file("traces/addresses" + std::to_string(i));
        std::ifstream branchresult_file("traces/branchresults" + std::to_string(i));
        if(address_file.is_open() && branchresult_file.is_open()) {
            while(getline(address_file, address)) {
                getline(branchresult_file, branchresult);
                num_branches++;
                //top->pc_i = std::stoi(address, nullptr, 16);
                top->clk_i = 1;
                top->eval();
                top->clk_i = 0;
                top->eval();
                // TEST: predict always taken
                if(top->prediction != std::stoi(branchresult)) {
                    num_mispred++;
                }
                //top->br_result_i = std::stoi(branchresult);
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
