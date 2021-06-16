`timescale 1 ps / 1 ps
module tb_rtl_reuleaux();
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
    #2;
    //check to see if it is drawing oct2 for the red side of the triangle
    assert(dut.state === 5'd1)
    else $error ("not in oct2_Red state");
    #2;
    //check to see if it is drawing oct3 for the red side of the triangle
    assert(dut.state === 5'd2)
    else $error ("not in oct3_Red state");
    #256;
    //check to see if offset_x and offset_y are reset
    assert(dut.offset_x === 80)
    else $error ("offset_x not equal to the diameter");
    assert(dut.offset_y === 0)
    else $error ("offset_y not equal to 0");
    //check to see if it is drawing oct8 for the green side of the triangle
    assert(dut.state === 5'd5)
    else $error ("not in oct8_green state");
    #2;
    //check to see if it is drawing oct7 for the green side of the triangle
    assert(dut.state === 5'd6)
    else $error ("not in oct7_green state");
    #356;
    //check to see if offset_x and offset_y are reset
    assert(dut.offset_x === 80)
    else $error ("offset_x not equal to the diameter");
    assert(dut.offset_y === 0)
    else $error ("offset_y not equal to 0");
    //check to see if it is drawing oct5 for the blue side of the triangle
    assert(dut.state === 5'd9)
    else $error ("not in oct5_blue state");
    #2;
    //check to see if it is drawing oct6 for the green side of the triangle
    assert(dut.state === 5'd10)
    else $error ("not in oct6_blue state");
    #364;
    //check to see if we are in the done state
    assert(dut.state === 5'd12)
    else $error ("not in done state");
    #2;
    start = 0;
    #4;
    //check if done is deasserted
    assert(dut.done === 0)
    else $error ("done should be deasserted");
    #10;
    $stop;
end

endmodule: tb_rtl_reuleaux
