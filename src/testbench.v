`timescale 1ns/1ps

`include "pipeline.v"

module pipeline_tb;

    // Clock and reset
    reg clk;
    reg reset;

    // Instantiate the pipeline
    pipeline dut (
        .clk   (clk),
        .reset (reset)
    );

    // Clock generation: 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Simulation flow
    initial begin
        $dumpfile("pipeline_tb.vcd");
        $dumpvars(0, pipeline_tb);

        // Apply reset
        reset = 1;
        #20;
        reset = 0;

        // Run simulation for a while to observe instruction flow
        #300;

        $display("Simulation completed.");
        $finish;
    end

endmodule
