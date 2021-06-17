`timescale 1 ps / 1 ps
module tb_rtl_fillscreen();
//this testbench tests to see if fillscreen starts properly and ends properly

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.
logic clk, rst_n;
logic [2:0] colour;
logic start, done;
logic [7:0] vga_x;
logic [6:0] vga_y;
logic [2:0] vga_colour;
logic vga_plot;

fillscreen dut(.*);

initial begin
    clk = 0;
    forever #1 clk = ~clk;
end
initial begin
    rst_n = 1;
    start = 1;
    #10;
    rst_n = 0;
    #10;
    //testing to see if the x coord starts at 0
    assert(vga_x === 8'd0)
    else $error ("x coord should start at 0");
    //testing to see if the colour starts at black
    assert(vga_colour === 3'b000)
    else $error ("first colour should be black");
    rst_n = 1;
    #38200;
    //testing to see if the x coord ends at 159
    assert(vga_x === 8'd159)
    else $error ("last x coord should be at 159");
    //and if the last colour is white
    assert(vga_colour === 3'b111)
    else $error ("last colour should be white");
    #2000;
    //checking to see if we are in the done state
    assert(dut.state === 3'b010)
    else $error ("should be in done state");
    #10;
    start = 0;//deassert start to see if done is deasserted
    #10;
    assert(done === 0)
    else $error ("done should be deasserted");
    $stop;
end
endmodule: tb_rtl_fillscreen
