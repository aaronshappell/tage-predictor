#include <verilated.h>

#include "Vtop.h"

int main(int argc, char** argv, char** env) {
    // Prevent unused variable warnings
    if (false && argc && argv && env) {}

    // Construct verilated model
    Vtop* top = new Vtop;

    // Set input signals
    top->clk_i = 0;
    top->reset_i = 1;
    top->eval();
    top->reset_i = 0;

    // Simulate
    for(int i = 0; i < 10; i++) {
        top->clk_i = 1;
        top->eval();
        top->clk_i = 0;
        top->eval();
        VL_PRINTF("count: %d\n", top->count);
    }

    // Cleanup
    top->final();
    delete top;
    return 0;
}
