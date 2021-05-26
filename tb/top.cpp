#include <iostream>
#include <fstream>
#include <string>
#include <verilated.h>

#include "Vtop.h"

#define NUM_TRACES 20

int main(int argc, char** argv, char** env) {
    // Prevent unused variable warnings
    if (false && argc && argv && env) {}

    // Construct verilated model
    Vtop* top = new Vtop;

    // Simulate traces
    for(int i = 0; i < NUM_TRACES; i++) {
        // Statistics
        int num_instr = 0;
        int num_branches = 0;
        int num_mispred = 0;
        int prev_branchresult = 0;

        top->update_en_i = 1;

        std::string address;
        std::string branchresult;
        std::string conditional;
        std::ifstream address_file("traces/addresses" + std::to_string(i));
        std::ifstream branchresult_file("traces/branchresults" + std::to_string(i));
        std::ifstream conditional_file("traces/conditionals" + std::to_string(i));
        if(address_file.is_open() && branchresult_file.is_open() && conditional_file.is_open()) {
            getline(address_file, address);
            num_instr = std::stoi(address);
            while(getline(address_file, address)) {
                getline(branchresult_file, branchresult);
                getline(conditional_file, conditional);
                if(std::stoi(conditional)) {
                    num_branches++;
                }

                top->br_result_i = prev_branchresult;
                top->correct_i = top->prediction_o == prev_branchresult;
                top->idx_i = std::stoul(address, nullptr, 16);
                top->clk_i = 1;
                top->eval();
                top->clk_i = 0;
                top->eval();
                if (top->prediction_o != std::stoi(branchresult) && std::stoi(conditional)) {
                    num_mispred++;
                }
                prev_branchresult = std::stoi(branchresult);
            }
            address_file.close();
            branchresult_file.close();
            conditional_file.close();
        } else {
            VL_PRINTF("ERROR: unable to open trace files\n");
        }

        // Calculate mispred_rate
        float mispred_rate = (float) num_mispred / (float) num_branches;
        float mpki = (float) num_mispred / ((float) num_instr / 1000);

        // Print results
        VL_PRINTF("-- Trace %d Results -------------\n", i);
        VL_PRINTF("  Conditional Branches: %d\n", num_branches);
        VL_PRINTF("  Mispredictions: %d\n", num_mispred);
        VL_PRINTF("  Misprediction Rate: %f\n", mispred_rate);
        VL_PRINTF("  MPKI: %f\n\n", mpki);
    }

    // Cleanup
    top->final();
    delete top;

    return 0;
}
