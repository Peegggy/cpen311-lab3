`timescale 1 ps / 1 ps
module tb_syn_task3();
//run the task3 simulation
// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.
logic CLOCK_50;
logic [3:0] KEY;
logic [9:0] SW, LEDR;
logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
logic [7:0] VGA_R, VGA_G, VGA_B;
logic VGA_HS, VGA_VS, VGA_CLK;
logic [7:0] VGA_X;
logic [6:0] VGA_Y;
logic [2:0] VGA_COLOUR;
logic VGA_PLOT;

task3 dut(.*);
//run the clock
initial begin
    CLOCK_50 = 0;
    forever #1 CLOCK_50 = ~CLOCK_50;
end
//run the top module
initial begin
    KEY[3] = 1;
    #10;
    KEY[3] = 0;
    #10;
    KEY[3] = 1;
    #40000; //check the fake vga screen
    $stop;
end
endmodule: tb_syn_task3
