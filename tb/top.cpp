#include <iostream>
#include <fstream>
#include <string>
#include <verilated.h>

#include "Vtop.h"

// #define NUM_TRACES 13
#define NUM_TRACES 8

int main(int argc, char** argv, char** env) {
    // Prevent unused variable warnings
    if (false && argc && argv && env) {}

    // Construct verilated model
    Vtop* top = new Vtop;

    // Simulate
    while(!Verilated::gotFinish()) {
        top->clk_i = 1;
        top->eval();
        top->clk_i = 0;
        top->eval();
    }

    // Cleanup
    top->final();
    delete top;
    return 0;
}
