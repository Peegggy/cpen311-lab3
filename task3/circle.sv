`timescale 1ps/1ps
`define reset   4'd0;//set offet_y = 0, offset_x to radius and crit to 1-radius
`define compare 4'd1;//check if offset_y is <= offset_x
`define oct1    4'd2;//draw octant1
`define oct2    4'd3;//draw octant2
`define oct4    4'd4;//draw octant4
`define oct3    4'd5;//draw octant3
`define oct5    4'd6;//draw octant5
`define oct6    4'd7;//draw octant6
`define oct8    4'd8;//draw octant8
`define oct7    4'd9;//draw octant7
`define crit    4'd10;//check crit condition
`define done    4'd11;//circle done

/*drawCircle(centre_x, centre_y, radius):
    offset_y = 0
    offset_x = radius
    crit = 1 - radius
    while offset_y ≤ offset_x:
        setPixel(centre_x + offset_x, centre_y + offset_y)   -- octant 1
        setPixel(centre_x + offset_y, centre_y + offset_x)   -- octant 2
        setPixel(centre_x - offset_x, centre_y + offset_y)   -- octant 4
        setPixel(centre_x - offset_y, centre_y + offset_x)   -- octant 3
        setPixel(centre_x - offset_x, centre_y - offset_y)   -- octant 5
        setPixel(centre_x - offset_y, centre_y - offset_x)   -- octant 6
        setPixel(centre_x + offset_x, centre_y - offset_y)   -- octant 8
        setPixel(centre_x + offset_y, centre_y - offset_x)   -- octant 7
        offset_y = offset_y + 1
        if crit ≤ 0:
            crit = crit + 2 * offset_y + 1
        else:
            offset_x = offset_x - 1
            crit = crit + 2 * (offset_y - offset_x) + 1
*/
//ths purpose of this module is to implement the above psuedo code using systemverilog to draw a circle
//of specified centre and radius. It should not draw anything when the pixels are out of bound
module circle(input logic clk, input logic rst_n, input logic [2:0] colour,
              input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] radius,
              input logic start, output logic done,
              output logic [7:0] vga_x, output logic [6:0] vga_y,
              output logic [2:0] vga_colour, output logic vga_plot);
     // draw the circle
     logic [3:0] state, nextstate;
     //indicate how far off the coord is from the centre
     logic [7:0] offset_x, offset_y;
     logic signed [8:0] crit;
     //if offset_x < offset_y, then finish the statemachine
     logic xLessThan;

     //this always block indicates what the next state is
     always_comb begin
          case(state)
          //reset -> compare if start is asserted
          4'd0 : nextstate = start ? 4'd1 : 4'd0;
          //compare -> oct1 if offset_y <= offset_x
          4'd1 : nextstate = xLessThan ? 4'd12 : 4'd2;
          //oct1 -> oct2
          4'd2 : nextstate = 4'd3;
          //oct2 -> oct4
          4'd3 : nextstate = 4'd4;
          //oct4 -> oct3
          4'd4 : nextstate = 4'd5;
          //oct3 -> oct5
          4'd5 : nextstate = 4'd6;
          //oct5 -> 6
          4'd6 : nextstate = 4'd7;
          //oct6 -> oct8
          4'd7 : nextstate = 4'd8;
          //oct8 -> oct7
          4'd8 : nextstate = 4'd9;
          //oct7 -> crit
          4'd9 : nextstate = 4'd10;
          //crit -> compare
          4'd10 : nextstate = 4'd1;
          //done -> reset if start is deasserted
          4'd11 : nextstate = ~start ? 4'd0 : 4'd11;
          default : nextstate = 4'd11;
          endcase
     end
     //this always block indicates what the current state is
     always_ff @(posedge clk) begin
          if(~rst_n)//if reset is asserted
          state <= 4'd0;//then go to reset state
          else
          state <= nextstate;//else nextstate becomes the current state
     end
     //this always block updates the output wires or any internal wires on the posedge 
     //of the clock in the current state
     always_ff @(posedge clk) begin
          case(state)
          4'd0 : begin //reset
               offset_y <= 8'b0;//according to the pseudo code, offset_y is 0
               offset_x <= radius;//and offset_x is radius
               //crit is 1-radius which is in the negative range, thats why there is $signed()
               crit <= $signed(9'd1) - $signed(radius);
               done <= 1'b0;
               //---set the vga wires to 0--
               vga_x <= 8'b0;
               vga_y <= 7'b0;
               vga_colour <= 3'b000;
               vga_plot <= 1'b0;
               xLessThan <= 0;
          end
          4'd1 : begin //compare
               vga_colour <= colour; //colour is green
               if(offset_y <= offset_x)
               xLessThan <= 0;
               else
               //if offset_y is greater than offset_x, then
               //the circle is done
               xLessThan <= 1;
          end
          //---- start plotting the 8 octants----
          4'd2 : begin //oct1
               vga_x <= (centre_x + offset_x);
               vga_y <= (centre_y + offset_y);
               //--checking for boundary conditions, we know the limit for x and y coords so use that as the boundary---
               if($signed(8'd0)<=(centre_x+offset_x)&&(centre_x+offset_x)<=$signed(8'd159) && $signed(7'd0)<=(centre_y+offset_y)&&(centre_y+offset_y)<=$signed(7'd119))
               vga_plot <= 1;//if the coord is within the bounds, then plot
               else vga_plot <= 0;
          end
          4'd3 : begin //oct2
               vga_x <= (centre_x + offset_y);
               vga_y <= (centre_y + offset_x); 
               //--checking for boundary conditions, we know the limit for x and y coords so use that as the boundary---
               if($signed(8'd0)<=(centre_x+offset_y)&&(centre_x+offset_y)<=$signed(8'd159) && $signed(7'd0)<=(centre_y+offset_x)&&(centre_y+offset_x)<=$signed(7'd119))
               vga_plot <= 1;//if the coord is within the bounds, then plot
               else vga_plot <= 0;
          end
          4'd4 : begin //oct4
               vga_x <= (centre_x - offset_x);
               vga_y <= (centre_y + offset_y);
               //--checking for boundary conditions, we know the limit for x and y coords so use that as the boundary---
               if($signed(8'd0)<=(centre_x-offset_x)&&(centre_x-offset_x)<=$signed(8'd159) && $signed(7'd0)<=(centre_y+offset_y)&&(centre_y+offset_y)<=$signed(7'd119))
               vga_plot <= 1;//if the coord is within the bounds, then plot
               else vga_plot <= 0;
          end
          4'd5 : begin //oct3
               vga_x <= (centre_x - offset_y);
               vga_y <= (centre_y + offset_x);
               //--checking for boundary conditions, we know the limit for x and y coords so use that as the boundary---
               if($signed(8'd0)<=(centre_x-offset_y)&&(centre_x-offset_y)<=$signed(8'd159) && $signed(7'd0)<=(centre_y+offset_x)&&(centre_y+offset_x)<=$signed(7'd119))
               vga_plot <= 1;//if the coord is within the bounds, then plot
               else vga_plot <= 0;
          end
          4'd6 : begin //oct5
               vga_x <= (centre_x - offset_x);
               vga_y <= (centre_y - offset_y);
               //--checking for boundary conditions, we know the limit for x and y coords so use that as the boundary---
               if($signed(8'd0)<=(centre_x-offset_x)&&(centre_x-offset_x)<=$signed(8'd159) && $signed(7'd0)<=(centre_y-offset_y)&&(centre_y-offset_y)<=$signed(7'd119))
               vga_plot <= 1;//if the coord is within the bounds, then plot
               else vga_plot <= 0;
          end
          4'd7 : begin //oct6
               vga_x <= (centre_x - offset_y);
               vga_y <= (centre_y - offset_x);
               //--checking for boundary conditions, we know the limit for x and y coords so use that as the boundary---
               if($signed(8'd0)<=(centre_x-offset_y)&&(centre_x-offset_y)<=$signed(8'd159) && $signed(7'd0)<=(centre_y-offset_x)&&(centre_y-offset_x)<=$signed(7'd119))
               vga_plot <= 1;//if the coord is within the bounds, then plot
               else vga_plot <= 0;
          end
          4'd8 : begin //oct8
               vga_x <= (centre_x + offset_x);
               vga_y <= (centre_y - offset_y);
               //--checking for boundary conditions, we know the limit for x and y coords so use that as the boundary---
               if($signed(8'd0)<=(centre_x+offset_x)&&(centre_x+offset_x)<=$signed(8'd159) && $signed(7'd0)<=(centre_y-offset_y)&&(centre_y-offset_y)<=$signed(7'd119))
               vga_plot <= 1;//if the coord is within the bounds, then plot
               else vga_plot <= 0;
          end
          4'd9 : begin //oct7
               vga_x <= (centre_x + offset_y);
               vga_y <= (centre_y - offset_x);
               //--checking for boundary conditions, we know the limit for x and y coords so use that as the boundary---
               if($signed(8'd0)<=(centre_x+offset_y)&&(centre_x+offset_y)<=$signed(8'd159) && $signed(7'd0)<=(centre_y-offset_x)&&(centre_y-offset_x)<=$signed(7'd119))
               vga_plot <= 1;//if the coord is within the bounds, then plot
               else vga_plot <= 0;
          end
          //---- finish the 8 octants -----
          4'd10 : begin //crit
          //increment offset_y first
          offset_y <= offset_y + 8'd1;
          //and not plotting anything
          vga_plot <= 0;
               //check if crit is negative
               if(crit <= $signed(9'd0))
               //reassign crit
               crit <= crit + (9'd2*offset_y) + 9'd1;
               else begin
                    //else decrement offset_x
                    offset_x <= offset_x - 8'd1;
                    crit <= crit + (9'd2*(offset_y - offset_x)) + 9'd1;
               end
          end
          4'd11 : begin //done
               done <= 1'b1;//assert done when the circle is done
               vga_plot <= 1'b0;
               xLessThan <= 0;
          end
          endcase
     end

endmodule

