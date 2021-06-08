module tb_rtl_circle();

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

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    rst_n = 1;
    centre_x = 80;
    centre_y = 60;
    radius = 40;
    start = 1;
    #10;
    rst_n = 0;
    #10;
    rst_n = 1;
    #20000;
    $stop;
end

endmodule: tb_rtl_circle
