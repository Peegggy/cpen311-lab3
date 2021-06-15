`timescale 1 ps / 1 ps
`define fillscreen 2'd0; //start the fillscreen module
`define circle     2'd1; //start the circle module
`define done       2'd2;

//The purpose of this top module is to implement the fillscreen that fills the whole screen
//black before drawing the circle
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
    //seperate start and done signals for the 2 modules
    logic start_screen, start_circle, done_screen, done_circle;
    //stats and the next states
    logic [1:0] state, nextstate;
    //seperate x coordinates for fillscreen and circle
    logic [7:0] vga_x_fillscreen, vga_x_circle;
    //seperate y coordinates for fillscreen and circle
    logic [6:0] vga_y_fillscreen, vga_y_circle;
    //seperate colour wires for fillscreen and circle
    logic [2:0] vga_colour_fillscreen, vga_colour_circle;
    //seperate plot flags for fillscreen and circle
    logic vga_plot_fillscreen, vga_plot_circle;

    //instantiates the fillscreen module to fill the screen black first
    fillscreen f (.clk(CLOCK_50),
                  .rst_n(KEY[3]),
                  .colour(3'b0), //3'b000 is black
                  .start(start_screen),
                  .done(done_screen),
                  .vga_x(vga_x_fillscreen),
                  .vga_y(vga_y_fillscreen),
                  .vga_colour(vga_colour_fillscreen),
                  .vga_plot(vga_plot_fillscreen));

    //instantiates the circle module to draw a circle
    circle c (.clk(CLOCK_50),
              .rst_n(KEY[3]),
              .colour(3'b010),//3'b010 is green
              .centre_x(8'd80),
              .centre_y(8'd60),
              .radius(8'd40),
              .start(start_circle),
              .done(done_circle),
              .vga_x(vga_x_circle),
              .vga_y(vga_y_circle),
              .vga_colour(vga_colour_circle),
              .vga_plot(vga_plot_circle));

    //this always block indicates what the current state is
    always_ff @(posedge CLOCK_50) begin
          if(~KEY[3])//if reset is asserted
          state <= 2'd0; //go back to fillscreen
          else
          state <= nextstate; //nextstate becomes the current state
     end
    //this always block indicates what the next state is
     always_comb begin
         case(state)
         //when done_screen is asserted go to draw circle state, if not, then stay in fillscreen
         2'd0 : nextstate = done_screen ? 2'd1 : 2'd0;
         //when draw circle is done then go to done state
         2'd1 : nextstate = done_circle ? 2'd2 : 2'd1;
         default: nextstate = 2'd2;
         endcase
     end
     //this always block updates the output signals or any internal signals on the posedge 
     //of the clock in the current state
     always_ff @(posedge CLOCK_50) begin
         case(state)
         2'd0 : begin
             start_screen <= 1; //to start the fillscreen module
             start_circle <= 0; //but do not start the circle module
             //the vga signals from fillscreen are assigned to the VGA adaptor
             VGA_X <= vga_x_fillscreen;
             VGA_Y <= vga_y_fillscreen;
             VGA_COLOUR <= vga_colour_fillscreen;
             VGA_PLOT <= vga_plot_fillscreen;
         end
         2'd1 : begin
             start_circle <= 1; //start the circle module
             start_screen <= 0; //but do not start the fillscreen module
             //the vga signals from circle are assigned to the VGA adaptor
             VGA_X <= vga_x_circle;
             VGA_Y <= vga_y_circle;
             VGA_COLOUR <= vga_colour_circle;
             VGA_PLOT <= vga_plot_circle;
         end
         2'd2 : begin
             //done state sets every signals back to 0
             start_circle <= 0;
             start_screen <= 0;
             VGA_COLOUR <= 0;
             VGA_PLOT <= 0;
             VGA_X <= 0;
             VGA_Y <= 0;
         end
     endcase
     end
endmodule: task3
