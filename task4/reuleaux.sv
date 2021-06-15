`define reset            5'd0; //reset the module
`define oct2_red         5'd1; //draws octant 2 indicated with the red part of the triangle
`define oct3_red         5'd2; //draws octant 3 indicated with the red part of the triangle
`define crit_red         5'd3; //checking to see the crit conditions for red and also increment y
`define reset_red        5'd4; //when the red part is done, reset offset_x and offset_y
`define oct8_green       5'd5; //draws octant 8 indicated with the green part of the triangle
`define oct7_green       5'd6; //draws a small part of octant7 
`define crit_green       5'd7; //checking to see the crit condions for green and also increment y
`define reset_green      5'd8; //when the green part is done, reset offset_x and offset_y
`define oct5_blue        5'd9; //draws octant 5 indicated with the blue part of the triangle
`define oct6_blue        5'd10; //draws a small part of octant 6
`define crit_blue        5'd11; //checking to see the crit conditions for blue and also increment y
`define done             5'd12; //when everything is done

//the purpose of this module is to calculate the coordinates for drawing a reuleaux triangle
module reuleaux(input logic clk, input logic rst_n, input logic [2:0] colour,
                input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] diameter,
                input logic start, output logic done,
                output logic [7:0] vga_x, output logic [6:0] vga_y,
                output logic [2:0] vga_colour, output logic vga_plot);
     // draw the Reuleaux triangle
     logic signed [7:0] c_x1, c_x2, c_x3;//x coord for the centres of the 3 circles
     logic signed [6:0] c_y1, c_y2, c_y3;//y coord for the centres of the 3 circles
     //these wires are signed, and to prevent overflow, an extra bit is added
     logic signed [8:0] offset_x, offset_y, crit_red, crit_green, crit_blue;
     //done flags indicating if the 3 sides of the triangles are done
     logic done_red, done_green, done_blue;
     logic [4:0] state, nextstate;
     //a flag for the bottom part of the triangle since oct2 and oct3 are drawn together
     //that why the timing is trickier than the other 2 sides
     logic set_red_done;
     
     //----------constants for sqrt(3) rounding---------------
     //this constant is for diameter * sqrt(3)/6
     logic [31:0] constant_36;
     //extend the diameter input to match with the floating point value * 16 bits binary floating point for sqrt(3)/6 
     assign constant_36 = (diameter<<8)*(16'b0000000001001010);
     //this constant is for diameter * sqrt(3)/3
     logic [31:0] constant_33;
     //extend the diameter input to match with the floating point value * 16 bits binary floating point for sqrt(3)/3
     assign constant_33 = (diameter<<8)*(16'b0000000010010100);
     

     /*assign c_x = centre_x;
     assign c_y = centre_y;
     assign c_x1 = c_x + diameter/2;
     assign c_y1 = c_y + diameter * $sqrt(3)/6;
     assign c_x2 = c_x - diameter/2;
     assign c_y2 = c_y + diameter * $sqrt(3)/6;
     assign c_x3 = c_x;
     assign c_y3 = c_y - diameter * $sqrt(3)/3;*/
     //------------assigning the centres for each circles--------------
     assign c_x1 = centre_x + (diameter/8'd2); //centre of the blue circle
     assign c_y1 = centre_y + constant_36[23:16]; //centre of the blue circle
     assign c_x2 = $signed(centre_x) - $signed((diameter/8'd2));//centre of the green circle
     assign c_y2 = centre_y + constant_36[23:16]; //centre of the green circle
     assign c_x3 = centre_x; //centre of the red circle
     assign c_y3 = $signed(centre_y) - $signed(constant_33[23:16]);//centre of the red circle 

     //this always block indicates what the current state is
     always_comb begin
          case(state)
          //reset -> oct2_red if start is asserted
          5'd0 : nextstate = start ? 5'd1 : 5'd0;
          //oct2_red -> reset_red if red part is done, else -> oct3_red
          5'd1 : nextstate = 5'd2;
          //oct3_red -> crit_red
          5'd2 : nextstate = done_red ? 5'd4 : 5'd3;
          //crit_red -> oct2_red
          5'd3 : nextstate = 5'd1;
          //reset_red -> oct8_green
          5'd4 : nextstate = 5'd5;
          //oct8_green -> reset_green if green is done, else -> oct7_green
          5'd5 : nextstate = done_green ? 5'd8 : 5'd6;
          //oct7_green -> crit_green
          5'd6 : nextstate = 5'd7;
          //crit_green -> oct8_green
          5'd7 : nextstate = 5'd5;
          //reset_green -> oct5_blue
          5'd8 : nextstate = 5'd9;
          //oct5_blue -> done if blue is done, else -> oct6_blue
          5'd9 : nextstate = done_blue ? 5'd12 : 5'd10;
          //oct6_blue -> crit_blue
          5'd10 : nextstate = 5'd11;
          //crit_blue -> oct5_blue
          5'd11 : nextstate = 5'd9;
          //done -> reset if start is deasserted
          5'd12 : nextstate = ~start ? 5'd0 : 5'd12;
          default : nextstate = 5'd12;
          endcase
     end

     //this always block indicates what the next state is
     always_ff @(posedge clk) begin
          if(~rst_n)//if reset is asserted
          state <= 5'd0; //go back to reset state
          else
          state <= nextstate; //nextstate becomes the current state
     end

     //this always block updates the output signals/ wires or any internal signals/wires on the posedge 
     //of the clock in the current state
     always_ff @(posedge clk) begin
          case(state)
          5'd0 : begin //reset
               //---same settings as the circle pseudo code---
               offset_y <= 8'b0;
               offset_x <= diameter;
               crit_red <= $signed(8'd1) - $signed(diameter);
               crit_green <= $signed(8'd1) - $signed(diameter);
               crit_blue <= $signed(8'd1) - $signed(diameter);
               done <= 1'b0;//done is deasserted
               vga_x <= 8'b0;
               vga_y <= 7'b0;
               vga_plot <= 1'b0;//not plotting anything
               done_red <= 0;//nothing is done yet
               done_green <= 0;
               done_blue <= 0;     
               vga_colour <= 3'b000; //default colour is black    
          end
          5'd1 : begin //oct2_red
               //diameter/2 = diameter*sin(30) which is the height of the triangle
               if(offset_y > diameter/8'd2)begin
                    //the flag indicates if red is done or not, since octant 2 is always one
                    //pixel behind from observation, I need one more cycle for drawing oct2
                    //than drawing oct3, that's why the done signal gets set one state later
                    set_red_done <= 1; 
               end
               else begin 
                    //else draw oct2
                    vga_x <= offset_y + c_x3;
                    vga_y <= c_y3 + offset_x;
                    vga_plot <= 1;
                    vga_colour <= colour;//colour should be green
               end
          end
          5'd2 : begin //oct3_red
               //if the flag was previously set to 1, then done_red is 1
               if(set_red_done) begin 
                    done_red <= 1;
               end
               else begin
                    //else draw oct3
                    done_red <= 0; //and done_red remains 0 because the red part is not done
                    vga_x <= c_x3 - offset_y;
                    vga_y <= c_y3 + offset_x;
               end       
          end
          5'd3 : begin //crit_red
               //increments offset_y by 1
               offset_y <= offset_y + 1;
               //determine if crit_red is negative
               if(crit_red <= $signed(8'd0))
               crit_red <= crit_red + (8'd2*offset_y) + 8'd1;
               else begin
                    //if not done, then decrement offset_x
                    offset_x <= offset_x - 8'd1;
                    //and reassign crit_red 
                    crit_red <= crit_red + (8'd2*(offset_y - offset_x)) + 8'd1;
               end
          end
          5'd4 : begin //reset_red
               //resetting offset_y and offset_x to restart the process for another side of the triangle
               offset_y <= 8'b0;
               offset_x <= diameter;
          end
          5'd5 : begin //oct8_green
               //if offset_x + 1 (because the wires get update in the next cycle)is less than half of diameter, then that means
               //the green portion is done, or if offset_x is less than or equal to offset_y
               if(offset_x + 8'd1 < diameter/8'd2 || offset_x <= offset_y) begin
                    done_green <= 1;
               end
               else begin 
                    done_green <= 0;
                    //else draw oct8
                    vga_x <= c_x2 + offset_x;
                    vga_y <= c_y2 - offset_y;
                    vga_plot <= 1;
                    vga_colour <= colour;
               end
          end
          5'd6 : begin //oct7_green   
               vga_x <= c_x2 + offset_y;
               vga_y <= c_y2 - offset_x;    
               //setting boundary conditions
               //if the x coord is past the centre of the red circle            
               if(c_x2 + offset_y >= c_x3)
               //then draw the pixel 
                       vga_plot <= 1;
               else 
               //else the x coord is on the left side of the red circle, which is out of bound
                       vga_plot <= 0;
          end
          5'd7 : begin //crit_green
               //increments offset_y by 1
               offset_y <= offset_y + 1;
               //determine if crit_green is negative 
               if(crit_green <= $signed(8'd0))
               //if yes then reassigne crit
               crit_green <= crit_green + (8'd2*offset_y) + 8'd1;
               else begin
                    //else decrement offset_x
                    offset_x <= offset_x - 8'd1;
                    //and also reassign crit
                    crit_green <= crit_green + (8'd2*(offset_y - offset_x)) + 8'd1;
               end
          end
          5'd8 : begin //reset_green
          //resetting offset_y and offset_x to restart the process for the last side of the triangle
               offset_y <= 8'b0;
               offset_x <= diameter;
          end
          5'd9 : begin //oct5_blue
               //if offset_x + 1 (because the wires get update in the next cycle)is less than half of diameter, then that means
               //the blue portion is done, or if offset_x is less than or equal to offset_y
               if(offset_x + 8'd1 < diameter/8'd2 || offset_x <= offset_y) begin
                    done_blue <= 1;
               end
               else begin
                    done_blue <= 0;
                    //draw oct5
                    vga_x <= c_x1 - offset_x;
                    vga_y <= c_y1 - offset_y;
                    vga_plot <= 1;
                    vga_colour <= colour;
               end
          end
          5'd10 : begin //oct6_blue
               vga_x <= c_x1 - offset_y;
               vga_y <= c_y1 - offset_x;
               //boundary conditions: if the x coord is on the left side of the centre of the red circle
               //then plot the coord
               if(c_x1 - offset_y <= c_x3) begin
                    vga_plot <= 1;
               end
               //else it is out of bound
               else
                    vga_plot <= 0;
          end
          5'd11 : begin //crit_blue
               //increments offset_y by 1
               offset_y <= offset_y + 1;
               //determine if crit_blue is negative
               if(crit_blue <= $signed(8'd0))
               crit_blue <= crit_blue + (8'd2*offset_y) + 8'd1;
               else begin
                    //if not negative, derement offset_x
                    offset_x <= offset_x - 8'd1;
                    crit_blue <= crit_blue + (8'd2*(offset_y - offset_x)) + 8'd1;
               end
          end
          5'd12 : begin //done
               done <= 1'b1; //done is asserted
               vga_plot <= 1'b0; //and not plotting anything      
          end
          endcase
     end
      
endmodule