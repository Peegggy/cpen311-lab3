`timescale 1ps/1ps
`define reset   4'd0;
`define compare 4'd1
`define oct1    4'd2;
`define oct2    4'd3;
`define oct4    4'd4;
`define oct3    4'd5;
`define oct5    4'd6;
`define oct6    4'd7;
`define oct8    4'd8;
`define oct7    4'd9;
`define Yincre  4'd10;
`define crit    4'd11;
`define done    4'd12;

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
module circle(input logic clk, input logic rst_n, input logic [2:0] colour,
              input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] radius,
              input logic start, output logic done,
              output logic [7:0] vga_x, output logic [6:0] vga_y,
              output logic [2:0] vga_colour, output logic vga_plot);
     // draw the circle
     logic [3:0] state, nextstate;
     logic signed [7:0] offset_x, offset_y, crit;
     logic xLessThan;

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
          //oct7 -> Yincre
          4'd9 : nextstate = 4'd10;
          //Yincre -> crit
          4'd10 : nextstate = 4'd11;
          //crit -> compare
          4'd11 : nextstate = 4'd1;
          //done -> done
          4'd12 : nextstate = 4'd12;
          default : nextstate = 4'd12;
          endcase
     end

     always_ff @(posedge clk) begin
          if(~rst_n)
          state <= 4'd0;
          else
          state <= nextstate;
     end

     always_ff @(posedge clk) begin
          case(state)
          4'd0 : begin //reset
               offset_y <= 8'b0;
               offset_x <= radius;
               crit <= $signed(8'd1) - $signed(radius);
               done <= 1'b0;
               vga_x <= 8'b0;
               vga_y <= 7'b0;
               vga_colour <= 3'b010;
               vga_plot <= 1'b0;
               xLessThan <= 0;
          end
          4'd1 : begin //compare
               if(offset_y <= offset_x)
               xLessThan <= 0;
               else
               xLessThan <= 1;
          end
          4'd2 : begin //oct1
               vga_x <= (centre_x + offset_x);
               vga_y <= (centre_y + offset_y);
               vga_plot <= 1;
          end
          4'd3 : begin //oct2
               vga_x <= (centre_x + offset_y);
               vga_y <= (centre_y + offset_x); 
          end
          4'd4 : begin //oct4
               vga_x <= (centre_x - offset_x);
               vga_y <= (centre_y + offset_y);
          end
          4'd5 : begin //oct3
               vga_x <= (centre_x - offset_y);
               vga_y <= (centre_y + offset_x);
          end
          4'd6 : begin //oct5
               vga_x <= (centre_x - offset_x);
               vga_y <= (centre_y - offset_y);
          end
          4'd7 : begin //oct6
               vga_x <= (centre_x - offset_y);
               vga_y <= (centre_y - offset_x);
          end
          4'd8 : begin //oct8
               vga_x <= (centre_x + offset_x);
               vga_y <= (centre_y - offset_y);
          end
          4'd9 : begin //oct7
               vga_x <= (centre_x + offset_y);
               vga_y <= (centre_y - offset_x);
          end
          4'd10 : begin //Yincre
               offset_y <= offset_y + 8'd1;
          end
          4'd11 : begin //crit
               if(crit <= $signed(8'd0))
               crit <= crit + (8'd2*offset_y) + 8'd1;
               else begin
                    offset_x <= offset_x - 8'd1;
                    crit <= crit + (8'd2*(offset_y - offset_x)) + 8'd1;
               end
          end
          4'd12 : begin //done
               done <= 1'b1;
               vga_plot <= 1'b0;
               xLessThan <= 0;
          end
          endcase
     end

endmodule

