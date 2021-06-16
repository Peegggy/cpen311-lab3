`timescale 1 ps / 1 ps
module tb_rtl_task2();
//this testbench tests to see if task2 starts the fillscreen module properly and ends it properly
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

task2 dut(.*);
//start the clock
initial begin
    CLOCK_50 = 0;
    forever #1 CLOCK_50 = ~CLOCK_50;
end
initial begin
    KEY[3] = 1;
    #10;
    KEY[3] = 0;
    //testing to see if the x coord starts at 0
    assert(VGA_X === 8'd0)
    else $error ("x coord should start at 0");
    //testing to see if the colour starts at black
    assert(VGA_COLOUR === 3'b000)
    else $error ("first colour should be black");
    #10;
    KEY[3] = 1;
    #38200;
    //testing to see if the x coord ends at 159
    assert(VGA_X === 8'd159)
    else $error ("last x coord should be at 159");
    //and if the last colour is white
    assert(VGA_COLOUR === 3'b111)
    else $error ("last colour should be white");
    #2000;
    //and if the state is in done state
    assert(dut.state === 2'b01)
    else $error ("should be in done state");
    $stop;
end
endmodule: tb_rtl_task2
