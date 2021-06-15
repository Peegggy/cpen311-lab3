`timescale 1 ps / 1 ps
`define fillscreen 2'd0; //start the fillscreen module
`define reuleaux   2'd1; //start the reuleaux module
`define done       2'd2; 

//The purpose of this top module is to implement the fillscreen that fills the whole screen
//black before drawing the reuleaux triangle

module task4(input logic CLOCK_50, input logic [3:0] KEY,
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
    logic start_screen, start_reuleaux, done_screen, done_reuleaux;
    //stats and the next states
    logic [1:0] state, nextstate;
    //seperate x coordinates for fillscreen and reuleaux
    logic [7:0] vga_x_fillscreen, vga_x_reuleaux;
    //seperate y coordinates for fillscreen and reuleaux
    logic [6:0] vga_y_fillscreen, vga_y_reuleaux;
    //seperate colour wires for fillscreen and reuleaux
    logic [2:0] vga_colour_fillscreen, vga_colour_reuleaux;
    //seperate plot flags for fillscreen and reuleaux
    logic vga_plot_fillscreen, vga_plot_reuleaux;
    
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

    //instantiates the reuleaux module to draw the reuleaux triangle
    reuleaux r (.clk(CLOCK_50),
                .rst_n(KEY[3]),
                .colour(3'b010),//3'b010 is green
                .centre_x(8'd80),
                .centre_y(8'd60),
                .diameter(8'd80),
                .start(start_reuleaux),
                .done(done_reuleaux),
                .vga_x(vga_x_reuleaux),
                .vga_y(vga_y_reuleaux),
                .vga_colour(vga_colour_reuleaux),
                .vga_plot(vga_plot_reuleaux));

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
         //when done_screen is asserted go to draw reuleaux state, if not, then stay in fillscreen
         2'd0 : nextstate = done_screen ? 2'd1 : 2'd0;
         //when draw reuleaux is done then go to done state
         2'd1 : nextstate = done_reuleaux ? 2'd2 : 2'd1;
         default: nextstate = 2'd2;
         endcase
     end
     //this always block updates the output signals or any internal signals on the posedge 
     //of the clock in the current state
     always_ff @(posedge CLOCK_50) begin
         case(state)
         2'd0 : begin //`fillscreen
             start_screen <= 1; //to start the fillscreen module
             start_reuleaux <= 0; //but do not start the reuleaux module
             //the vga signals from fillscreen are assigned to the VGA adaptor
             VGA_X <= vga_x_fillscreen;
             VGA_Y <= vga_y_fillscreen;
             VGA_COLOUR <= vga_colour_fillscreen;
             VGA_PLOT <= vga_plot_fillscreen;
         end
         2'd1 : begin //`reuleaux
             start_reuleaux <= 1; //start the reuleaux module
             start_screen <= 0; //but do not start the fillscreen module
             //the vga signals from reuleaux are assigned to the VGA adaptor
             VGA_X <= vga_x_reuleaux;
             VGA_Y <= vga_y_reuleaux;
             VGA_COLOUR <= vga_colour_reuleaux;
             VGA_PLOT <= vga_plot_reuleaux;
         end
         2'd2 : begin //`done
            //done state sets every signals back to 0
             start_reuleaux <= 0; 
             start_screen <= 0;
             VGA_COLOUR <= 0;
             VGA_PLOT <= 0;
             VGA_X <= 0;
             VGA_Y <= 0;
         end
     endcase
     end
endmodule: task4
