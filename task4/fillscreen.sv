`define reset       3'd0;
`define turnPixel   3'd1;
`define done        3'd2;

//the purpose of this module is to fill the vga screen black before starting the reuleaux shape
module fillscreen(input logic clk, input logic rst_n, input logic [2:0] colour,
                  input logic start, output logic done,
                  output logic [7:0] vga_x, output logic [6:0] vga_y,
                  output logic [2:0] vga_colour, output logic vga_plot);
     // fill the screen
     logic [7:0] x; //the x coord
     logic [6:0] y; //the y coord
     logic [2:0] state, nextstate;

     //this always block assigns what the next state is
     always_comb begin
          case(state)
          3'd0 : nextstate = start ? 3'd1 : 3'd0; //reset -> turnPixel if start is asserted
          //turnPixel -> done if x exceeds the limit
          3'd1 : nextstate = (x == 8'd160) ? 3'd2 : 3'd1; 
         default: nextstate = 3'd2;
          endcase
     end

     //this always block decides what the current state is
     always_ff @(posedge clk) begin
          if(~rst_n)//if reset is asserted
          state <= 3'd0; //go back to reset state
          else
          state <= nextstate; //else nextstate becomes the current state
     end

     //this always block updates the output wires or internal wires in the current state
     always_ff @(posedge clk) begin
          case(state)
          3'd0 : begin  //`reset
               //resets everything 
               x <= 8'b0;
               y <= 7'b0;
               done <= 1'b0;
               vga_colour <= colour; //colour is black
               vga_plot <= 1'b1;
          end
          3'd1 : begin
               vga_plot <= 1;//filling the whole screen
               //if y is less than 119 and x is less than or equal to 159
               if(y < 7'd119 && x <= 8'd159)
               //increment y
               y <= y + 1'b1;
               else begin
                    //else y resets back to 0
                    y <= 0; 
                    //and increment x
                    x <= x + 1'b1;
               end
          end
          3'd2 : begin //`done
               done <= 1'b1; //assert the done signal
               vga_colour <= 3'b0;
               vga_plot <= 1'b0;
          end
          endcase
     end
     //x and y are assigned to vga_x and vga_y
     assign vga_x = x;
     assign vga_y = y;
endmodule

