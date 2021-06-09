`define reset 5'd0;
`define oct2_red   5'd1;
`define oct3_red 5'd2;
`define Yincre_red 5'd3;
`define crit_red 5'd4;
`define reset_red 5'd5;
`define oct8_green 5'd6;
`define oct7_green 5'd7;
`define Yincre_green 5'd8;
`define crit_green 5'd9;
`define reset_green 5'd10;
`define oct5_blue  5'd11;
`define oct6_blue 5'd12;
`define Yincre_blue 5'd13;
`define crit_blue 5'd14;
`define done  5'd15;

module reuleaux(input logic clk, input logic rst_n, input logic [2:0] colour,
                input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] diameter,
                input logic start, output logic done,
                output logic [7:0] vga_x, output logic [6:0] vga_y,
                output logic [2:0] vga_colour, output logic vga_plot);
     // draw the Reuleaux triangle
     logic signed [7:0] c_x1, c_x2, c_x3;//x coord for the centres of the 3 circles
     logic signed [6:0] c_y1, c_y2, c_y3;//y coord for the centres of the 3 circles
     logic signed [7:0] offset_x, offset_y, crit_red, crit_green, crit_blue;
     logic done_red, done_green, done_blue;
     logic [4:0] state, nextstate;


     assign c_x1 = centre_x + (diameter/8'd2); //centre off the blue circle
     assign c_y1 = centre_y + (diameter*($sqrt(8'd3)/8'd6)); //centre of the blue circle
     assign c_x2 = $signed(centre_x) - $signed((diameter/8'd2));//centre of the green circle
     assign c_y2 = centre_y + (diameter*($sqrt(8'd3)/8'd6)); //centre of the green circle
     assign c_x3 = centre_x; //centre of the red circle
     assign c_y3 = $signed(centre_y) - $signed((diameter*($sqrt(8'd3)/8'd3)));//centre of the red circle 


     always_comb begin
          case(state)
          //reset -> oct2_red if start is asserted
          5'd0 : nextstate = start ? 5'd1 : 5'd0;
          //oct2_red -> reset_red if red part is done, else -> oct3_red
          5'd1 : nextstate = done_red ? 5'd5 : 5'd2;
          //oct3_red -> Yibcre_red
          5'd2 : nextstate = 5'd3;
          //Yincre_red -> crit_red
          5'd3 : nextstate = 5'd4;
          //crit_red -> oct2_red
          5'd4 : nextstate = 5'd1;
          //reset_red -> oct8_green
          5'd5 : nextstate = 5'd6;
          //oct8_green -> reset_green if green is done, else -> oct7_green
          5'd6 : nextstate = done_green ? 5'd10 : 5'd7;
          //oct7_green -> Yincre_green
          5'd7 : nextstate = 5'd8;
          //Yincre_green -> crit_green
          5'd8 : nextstate = 5'd9;
          //crit_green -> oct8_green
          5'd9 : nextstate = 5'd6;
          //reset_green -> oct5_blue
          5'd10 : nextstate = 5'd11;
          //oct5_blue -> done if blue is done, else -> oct6_blue
          5'd11 : nextstate = done_blue ? 5'd15 : 5'd12;
          //oct6_blue -> Yincre_blue
          5'd12 : nextstate = 5'd13;
          //Yincre_blue -> crit_blue
          5'd13 : nextstate = 5'd14;
          //crit_blue -> oct5_blue
          5'd14 : nextstate = 5'd11;
          //done -> done
          5'd15 : nextstate = 5'd15;
          default : nextstate = 5'd15;
          endcase
     end

     always_ff @(posedge clk) begin
          if(~rst_n)//if reset is asserted
          state <= 5'd0; //go back to reset state
          else
          state <= nextstate; //nextstate becomes the current state
     end

     always_ff @(posedge clk) begin
          case(state)
          5'd0 : begin //reset
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
               vga_colour <= 3'b000;     
          end
          5'd1 : begin //oct2_red
               //if offset_y + 1 because we want to predict offset_y in the next cycle 
               //so done can update in time
               //diameter/2 = diameter*sin(30) which is the height of the triangle
               if(offset_y + 8'd1 > diameter/8'd2)begin
                    done_red <= 1;
               end
               else begin 
                    done_red <= 0;
                    //else draw oct2
                    vga_x <= offset_y + c_x3;
                    vga_y <= c_y3 + offset_x;
                    vga_plot <= 1;
                    vga_colour <= 3'b100;
               end
          end
          5'd2 : begin //oct3_red
               //and draw oct3
               vga_x <= c_x3 - offset_y;
               vga_y <= c_y3 + offset_x;
          end
          5'd3 : begin //Yincre_red
               //increment offset_y
               offset_y <= offset_y + 1;
          end
          5'd4 : begin //crit_red
               //determine if the octant is done
               if(crit_red <= $signed(8'd0))
               crit_red <= crit_red + (8'd2*offset_y) + 8'd1;
               else begin
                    //if not done, then decrement offset_x
                    offset_x <= offset_x - 8'd1;
                    crit_red <= crit_red + (8'd2*(offset_y - offset_x)) + 8'd1;
               end
          end
          5'd5 : begin //reset_red
               offset_y <= 8'b0;
               offset_x <= diameter;
          end
          5'd6 : begin //oct8_green
               //if offset_y is greater than the height of the triangle, then that means
               //the green portion is done
               if(offset_y + 8'd1 > diameter * $sqrt(8'd3)/8'd2) begin
                    done_green <= 1;
               end
               else begin 
                    done_green <= 0;
                    //else draw oct8
                    vga_x <= c_x2 + offset_x;
                    vga_y <= c_y2 - offset_y;
                    vga_plot <= 1;
                    vga_colour <= 3'b010;
               end
          end
          5'd7 : begin //oct7_green
                    //vga_x <= (c_x2 + offset_y) + diameter/8'd2;
                    //vga_y <= c_y2 - (offset_x * $sqrt(8'd3)/8'd2);
          end
          5'd8 : begin  //Yincre_green
               offset_y <= offset_y + 1;
          end
          5'd9 : begin //crit_green
               //determine if the octant is done 
               if(crit_green <= $signed(8'd0))
               crit_green <= crit_green + (8'd2*offset_y) + 8'd1;
               else begin
                    //else decrement offset_x
                    offset_x <= offset_x - 8'd1;
                    crit_green <= crit_green + (8'd2*(offset_y - offset_x)) + 8'd1;
               end
          end
          5'd10 : begin //reset_green
               offset_y <= 8'b0;
               offset_x <= diameter;
          end
          5'd11 : begin //oct5_blue
               if(offset_y + 8'd1 > diameter * $sqrt(8'd3)/8'd2) begin
                    done_blue <= 1;
               end
               else begin
                    done_blue <= 0;
                    //draw oct5
                    vga_x <= c_x1 - offset_x;
                    vga_y <= c_y1 - offset_y;
                    vga_plot <= 1;
                    vga_colour <= 3'b001;
               end
          end
          5'd12 : begin //oct6_blue
               //vga_x <= c_x1 - offset_y - diameter/8'd2;
               //vga_y <= c_y1 - offset_x;
          end
          5'd13 : begin //Yincre_blue
               offset_y <= offset_y + 1;
          end
          5'd14 : begin //crit_blue
               if(crit_blue <= $signed(8'd0))
               crit_blue <= crit_blue + (8'd2*offset_y) + 8'd1;
               else begin
                    offset_x <= offset_x - 8'd1;
                    crit_blue <= crit_blue + (8'd2*(offset_y - offset_x)) + 8'd1;
               end
          end
          5'd15 : begin //done
               done <= 1'b1; //done is asserte
               vga_plot <= 1'b0;           
          end
          endcase
     end
      
endmodule

