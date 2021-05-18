#include <iostream>
#include <fstream>
#include <string>
#include <verilated.h>

#include "Vtop.h"

int main(int argc, char** argv, char** env) {
    // Prevent unused variable warnings
    if (false && argc && argv && env) {}

    // Simulate
    for(int i = 0; i < 5; i++) {
        // Construct verilated model
        Vtop* top = new Vtop;

        // Statistics
        float mpki = 0;

        // Set input signals
        top->clk_i = 0;
        top->reset_i = 1;
        top->eval();
        top->reset_i = 0;

        std::string line;
        std::string filename = "traces/trace" + std::to_string(i);
        std::ifstream trace(filename);
        if(trace.is_open()) {
            while(getline(trace, line)) {
                top->clk_i = 1;
                top->eval();
                top->clk_i = 0;
                top->eval();
                // Test predictor
                // TODO
            }
            trace.close();
        } else {
            VL_PRINTF("ERROR: unable to open file: %s\n", filename.c_str());
        }

        // Calculate MPKI
        // TODO

        // Print results
        VL_PRINTF("%s mpki: %f\n", filename.c_str(), mpki);

        // Cleanup
        top->final();
        delete top;
    }

    return 0;
}
