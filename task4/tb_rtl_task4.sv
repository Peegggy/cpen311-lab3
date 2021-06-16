`timescale 1 ps / 1 ps
module tb_rtl_task4();
//run the task4 simulation
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

task4 dut(.*);
//run the clock
initial begin
    CLOCK_50 = 0;
    forever #1 CLOCK_50 = ~CLOCK_50;
end
//run the top module
initial begin
    KEY[3] = 1;//deassert reset
    #10;
    KEY[3] = 0;//assert reset 
    #10;
    KEY[3] = 1;//deassert reset to move onto the next state
    //check to see if fillscreen is started
    assert(dut.state === 2'b00)
    else $error ("should be in fillscreen state");
    #38410;
    //check to see if the transition from fillscreen to reuleaux is correct
    assert(dut.state === 2'b01)
    else $error ("should be in reuleaux state");
    #1000;
    //check if the top module is done
    assert(dut.state === 2'b10)
    else $error ("should be in done state");
    #100;
    $stop;
end
endmodule: tb_rtl_task4
