`timescale 1 ps / 1 ps
module tb_syn_reuleaux();
//this testbench tests the functionality of reuleaux
// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.
logic clk;
logic rst_n;
logic [2:0] colour;
logic [7:0] centre_x;
logic [6:0] centre_y;
logic [7:0] diameter;
logic start;
logic done;
logic [7:0] vga_x;
logic [6:0] vga_y;
logic [2:0] vga_colour;
logic vga_plot;

reuleaux dut(.*);
//start the clock
initial begin
    clk = 0;
    forever #1 clk = ~clk;
end
//run reuleaux
initial begin
    rst_n = 1;//deassert reset
    centre_x = 80;
    centre_y = 60;
    diameter = 80;
    start = 1;//assert start
    colour = 3'b010;//set colour to green
    #10;
    rst_n = 0;//assert reset
    #10;
    rst_n = 1; //deassert reset to move to the next state
    #1000; //check the waveform
    $stop;
end

endmodule: tb_syn_reuleaux
