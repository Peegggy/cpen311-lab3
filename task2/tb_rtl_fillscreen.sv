module tb_rtl_fillscreen();

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
    #10;
    rst_n = 0;
    start = 1;
    #10;
    rst_n = 1;
    #80000;
    $stop;
end
endmodule: tb_rtl_fillscreen
