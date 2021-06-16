module tb_syn_fillscreen();
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
//start the clock
initial begin
    clk = 0;
    forever #1 clk = ~clk;
end
initial begin
    rst_n = 1;//assert reset
    start = 1;//assert start
    #10;
    rst_n = 0;//deassert reset to move to the next state
    #10;
    rst_n = 1;
    #40000; //check the waveform to see if the numbers line up
    $stop;
end
endmodule: tb_syn_fillscreen
