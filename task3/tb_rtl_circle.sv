`timescale 1 ps / 1 ps
module tb_rtl_circle();
//this testbench tests the functionality of circle
// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.
logic clk, rst_n;
logic [2:0] colour;
logic [7:0] centre_x;
logic [6:0] centre_y;
logic [7:0] radius;
logic start, done;
logic [7:0] vga_x;
logic [6:0] vga_y;
logic [2:0] vga_colour;
logic vga_plot;

circle dut(.*);
//start the clock
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    rst_n = 1;//deassert reset
    centre_x = 80;
    centre_y = 60;
    radius = 40;
    start = 1;//assert start
    colour = 3'b010;//set colour to green
    #10;
    rst_n = 0;//assert reset
    #10;
    rst_n = 1; //deassert reset to move to the next state
    #20;
    //check if octant 1 is being drawn
    assert(dut.state === 4'd2)
    else $error ("not in octant 1");
    //check to see if the colour is green
    assert(vga_colour === 3'b010)
    else $error ("vga colour should be green");
    #10;
    //check if octant2 is being drawn
    assert(dut.state === 4'd3)
    else $error ("not in octant2");
    #10;
    //check if octant4 is being drawn
    assert(dut.state === 4'd4)
    else $error ("not in octant4");
    #10;
    //check if octant3 is being drawn
    assert(dut.state === 4'd5)
    else $error ("not in octant3");
    #10;
    //check if octant5 is being drawn
    assert(dut.state === 4'd6)
    else $error ("not in octant5");
    #10;
    //check if octant6 is being drawn
    assert(dut.state === 4'd7)
    else $error ("not in octant6");
    #10;
    //check if octant8 is being drawn
    assert(dut.state === 4'd8)
    else $error ("not in octant8");
    #10;
    //check if octant7 is being drawn
    assert(dut.state === 4'd9)
    else $error ("not in octant7");
    #3500;
    $stop;
end

endmodule: tb_rtl_circle
