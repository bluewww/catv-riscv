// This file ONLY is placed under the Creative Commons Public Domain, for
// any use, without warranty, 2017 by Wilson Snyder.
// SPDX-License-Identifier: CC0-1.0
// Author: Wilson Synder
// Author: Robert Balas (balasr@iis.ee.ethz.ch)

#include <memory>
#include <verilated.h>
#include "Vcatv_riscv.h"
#include "verilated_vcd_c.h"

// Legacy function required only so linking works on Cygwin and MSVC++
double sc_time_stamp()
{
    return 0;
}

#define TIMEUNITS_PER_PERIOD (1000 * 10)
#define TICKS_PER_BAUD (868)

int main(int argc, char **argv, char **env)
{
    // Prevent unused variable warnings
    if (false && argc && argv && env) {
    }

    // Create logs/ directory in case we have traces to put under it
    Verilated::mkdir("logs");

    // Construct a VerilatedContext to hold simulation time, etc.
    // Multiple modules (made later below with Vtop) may share the same
    // context to share time, or modules may have different contexts if
    // they should be independent from each other.
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};

    // Set debug level, 0 is off, 9 is highest presently used
    // May be overridden by commandArgs argument parsing
    contextp->debug(0);

    // Randomization reset policy
    // May be overridden by commandArgs argument parsing
    contextp->randReset(2);

    // Verilator must compute traced signals
    contextp->traceEverOn(true);

    // Pass arguments so Verilated code can see them, e.g. $value$plusargs
    // This needs to be called before you create any model
    contextp->commandArgs(argc, argv);

    // Construct the Verilated model, from Vtop.h generated from Verilating
    // "top.v". "TOP" will be the hierarchical name of the module.
    const std::unique_ptr<Vcatv_riscv> top{
        new Vcatv_riscv{contextp.get(), "TOP"}};

#if VM_TRACE
    VerilatedVcdC *tfp = new VerilatedVcdC;
    top->trace(tfp, 2); // Trace 99 levels of hierarchy
    tfp->open("logs/catv.vcd");

    Verilated::scopesDump();
#endif
    // Set top level inputs
    top->rst_ni = !0;
    top->clk_i = 0;

    // Simulate until $finish
    while (!contextp->gotFinish()) {
        // Historical note, before Verilator 4.200 Verilated::gotFinish()
        // was used above in place of contextp->gotFinish().
        // Most of the contextp-> calls can use Verilated:: calls instead;
        // the Verilated:: versions simply assume there's a single context
        // being used (per thread).  It's faster and clearer to use the
        // newer contextp-> versions.

        contextp->timeInc(TIMEUNITS_PER_PERIOD/2);
        // Historical note, before Verilator 4.200 a sc_time_stamp()
        // function was required instead of using timeInc.  Once timeInc()
        // is called (with non-zero), the Verilated libraries assume the
        // new API, and sc_time_stamp() will no longer work.

        // Toggle a fast (time/2 period) clock
        top->clk_i = !top->clk_i;

        // Toggle control signals on an edge that doesn't correspond
        // to where the controls are sampled; in this example we do
        // this only on a negedge of clk, because we know
        // reset is not sampled there.
        if (!top->clk_i) {
            if (contextp->time() > 1 * TIMEUNITS_PER_PERIOD
		&& contextp->time() < 10 * TIMEUNITS_PER_PERIOD) {
                top->rst_ni = !1; // Assert reset
            } else {
                top->rst_ni = !0; // Deassert reset
            }
        }
        top->eval();
#if VM_TRACE
        tfp->dump(contextp->time());
#endif
    }

    // Final model cleanup
    top->final();
#if VM_TRACE
    if (tfp)
        tfp->close();
#endif

    // Coverage analysis (calling write only after the test is known to
    // pass)
#if VM_COVERAGE
    Verilated::mkdir("logs");
    contextp->coveragep()->write("logs/coverage.dat");
#endif

    // Don't use exit() or destructor won't get called
    return 0;
}
