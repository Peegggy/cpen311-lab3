`timescale 1 ps / 1 ps
`define fillscreen 2'd0;
`define done       2'd1;

module task2(input logic CLOCK_50, input logic [3:0] KEY,
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
    logic start, done;//indicates when to start and when the module is done
    logic [2:0] colour; 
    logic [1:0] state, nextstate;

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
         //when done_screen is asserted go to done state, if not, then stay in fillscreen
         2'd0 : nextstate = done ? 2'd1 : 2'd0;
         default: nextstate = 2'd1;
         endcase
     end
     //this always block updates the output signals or any internal signals on the posedge 
     //of the clock in the current state
     always_ff @(posedge CLOCK_50) begin
         case(state)
         2'd0 : begin //fillscreen
            start <= 1;//assert start to start fillscreen
         end
         2'd1 : begin
             start <= 0;//deassert start to deassert done
         end
         endcase
     end
    //instantiates the fillscreen module to fill the vga screen with different colours
    fillscreen f (.clk(CLOCK_50),
                  .rst_n(KEY[3]),
                  .colour(colour),
                  .start(start),
                  .done(done),
                  .vga_x(VGA_X),
                  .vga_y(VGA_Y),
                  .vga_colour(VGA_COLOUR),
                  .vga_plot(VGA_PLOT));


endmodule: task2
