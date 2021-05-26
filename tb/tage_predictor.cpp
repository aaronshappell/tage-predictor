#include <iostream>
#include <fstream>
#include <string>
#include <verilated.h>

#include "Vtage_predictor.h"

#define NUM_TRACES 20

int main(int argc, char** argv, char** env) {
    // Prevent unused variable warnings
    if (false && argc && argv && env) {}

    // Construct verilated model
    Vtage_predictor* tp = new Vtage_predictor;

    // Simulate traces
    for(int i = 0; i < NUM_TRACES; i++) {
        // Statistics
        int num_instr = 0;
        int num_branches = 0;
        int num_mispred = 0;
        int prev_branchresult = 0;

        int T0 = 0; int T0_mispred = 0;
        int T1 = 0; int T1_mispred = 0;
        int T2 = 0; int T2_mispred = 0;
        int T3 = 0; int T3_mispred = 0;
        int T4 = 0; int T4_mispred = 0;

        std::string address;
        std::string branchresult;
        std::string conditional;
        std::ifstream address_file("traces/addresses" + std::to_string(i));
        std::ifstream branchresult_file("traces/branchresults" + std::to_string(i));
        std::ifstream conditional_file("traces/conditionals" + std::to_string(i));
        if(address_file.is_open() && branchresult_file.is_open()) {
            getline(address_file, address);
            num_instr = std::stoi(address);
            while(getline(address_file, address)) {
                getline(branchresult_file, branchresult);
                getline(conditional_file, conditional);
                if(std::stoi(conditional)) {
                    num_branches++;
                }

                tp->br_result_i = prev_branchresult;
                tp->correct_i = tp->prediction_o == prev_branchresult;
                tp->idx_i = std::stoul(address, nullptr, 16);
                tp->clk_i = 1;
                tp->eval();
                tp->clk_i = 0;
                tp->eval();
                if (tp->prediction_o != std::stoi(branchresult) && std::stoi(conditional)) {
                    num_mispred++;

                    switch (tp->tage_predictor__DOT__providers) {
                        case 0: T0_mispred++; break;
                        case 1: T1_mispred++; break;
                        case 2: T2_mispred++; break;
                        case 4: T3_mispred++; break;
                        case 8: T4_mispred++; break;
                        default: break;
                    }
                }

                switch (tp->tage_predictor__DOT__providers) {
                    case 0: T0++; break;
                    case 1: T1++; break;
                    case 2: T2++; break;
                    case 4: T3++; break;
                    case 8: T4++; break;
                    default: break;
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

        float T0_mpr = (float) T0_mispred / (float) T0;
        float T1_mpr = (float) T1_mispred / (float) T1;
        float T2_mpr = (float) T2_mispred / (float) T2;
        float T3_mpr = (float) T3_mispred / (float) T3;
        float T4_mpr = (float) T4_mispred / (float) T4;

        // Print results
        VL_PRINTF("-- Trace %d Results -------------\n", i);
        VL_PRINTF("  Conditional Branches: %d\n", num_branches);
        VL_PRINTF("  Mispredictions: %d\n", num_mispred);
        VL_PRINTF("  Misprediction Rate: %f\n", mispred_rate);
        VL_PRINTF("  MPKI: %f\n\n", mpki);
        VL_PRINTF("T0 preds: %d, T1 preds: %d, T2 preds: %d, T3 preds: %d, T4 preds: %d\n", T0, T1, T2, T3, T4);
        VL_PRINTF("T0_mp: %d, T1_mp: %d, T2_mp: %d, T3_mp: %d, T4_mp: %d\n", T0_mispred, T1_mispred, T2_mispred, T3_mispred, T4_mispred);
        VL_PRINTF("T0_mpr: %f, T1_mpr: %f, T2_mpr: %f, T3_mpr: %f, T4_mpr: %f\n\n", T0_mpr, T1_mpr, T2_mpr, T3_mpr, T4_mpr);
    }

    // Cleanup
    tp->final();
    delete tp;

    return 0;
}
