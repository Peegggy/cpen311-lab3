`define reset       3'd0;
`define turnPixel   3'd1;
`define Yincre      3'd2;
`define Xincre      3'd3;
`define done        3'd4;

module fillscreen(input logic clk, input logic rst_n, input logic [2:0] colour,
                  input logic start, output logic done,
                  output logic [7:0] vga_x, output logic [6:0] vga_y,
                  output logic [2:0] vga_colour, output logic vga_plot);
     // fill the screen
     logic [7:0] x;
     logic [6:0] y;
     logic [2:0] state, nextstate;

     always_comb begin
          case(state)
          3'd0 : nextstate = start ? 3'd1 : 3'd0; //reset -> turnPixel if start is asserted
          3'd1 : nextstate = 3'd2; //turnPixel -> Yincre
          // Yincre -> turnPixel if y has not reached 119
          // Yincre -> done if y has gone over 119 and x is at 159
          // Yincre -> Xincre if y has gone over 119 but x is not a 159
          3'd2 : nextstate = (y < 7'd119) ? 3'd1 : (x == 8'd159 ? 3'd4 : 3'd3); 
          3'd3 : nextstate = 3'd1; //Xincre -> turnPixel
          3'd4 : nextstate = 3'd4; //done stays in done
         default: nextstate = 3'd4;
          endcase
     end

     always_ff @(posedge clk) begin
          if(~rst_n)
          state <= 3'd0;
          else
          state <= nextstate;
     end

     always_ff @(posedge clk) begin
          case(state)
          3'd0 : begin  //`reset
               x <= 8'b0;
               y <= 7'b0;
               done <= 1'b0;
               vga_colour <= 3'b0;
               vga_plot <= 1'b0;
          end
          3'd1 : begin //`turnPixel
               vga_plot <= 1'b1;
               vga_colour <= (x % 8'd8);
          end
          3'd2 : begin //`Yincre
               y <= y + 7'b1;
               vga_plot <= 1'b0;
          end
          3'd3 : begin //`Xincre
               x <= x + 1'b1;
               y <= 7'b0;
          end
          3'd4 : begin //`done
               done <= 1'b1;
               vga_colour <= 3'b0;
               vga_plot <= 1'b0;
          end
          endcase
     end
     assign vga_x = x;
     assign vga_y = y;
endmodule

