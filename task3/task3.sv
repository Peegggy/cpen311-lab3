`timescale 1 ps / 1 ps
module task3(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

logic [9:0] VGA_R_10;
logic [9:0] VGA_G_10;
logic [9:0] VGA_B_10;
logic VGA_BLANK, VGA_SYNC;

assign VGA_R = VGA_R_10[9:2];
assign VGA_G = VGA_G_10[9:2];
assign VGA_B = VGA_B_10[9:2];
    // instantiate and connect the VGA adapter and your module
    vga_adapter#(.RESOLUTION("160x120")) vga_u0(.resetn(KEY[3]), .clock(CLOCK_50), .colour(VGA_COLOUR),
                                            .x(VGA_X), .y(VGA_Y), .plot(VGA_PLOT),
                                            .VGA_R(VGA_R_10), .VGA_G(VGA_G_10), .VGA_B(VGA_B_10),
                                            .*);
    logic start, done;
    logic [2:0] colour;


    always_comb begin
        if(KEY[3] == 1'b0)
        start = 1;
        else if(done)
        start = 0;
        else start = 1;
    end

    circle c (.clk(CLOCK_50),
              .rst_n(KEY[3]),
              .colour(colour),
              .centre_x(8'd80),
              .centre_y(8'd60),
              .radius(8'd40),
              .start(start),
              .done(done),
              .vga_x(VGA_X),
              .vga_y(VGA_Y),
              .vga_colour(VGA_COLOUR),
              .vga_plot(VGA_PLOT));

endmodule: task3
