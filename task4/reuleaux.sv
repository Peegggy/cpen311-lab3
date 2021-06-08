`define reset 3'd1;
`define red   3'd2;
`define green 3'd3;
`define blue  3'd4;
`define done  3'd5;

module reuleaux(input logic clk, input logic rst_n, input logic [2:0] colour,
                input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] diameter,
                input logic start, output logic done,
                output logic [7:0] vga_x, output logic [6:0] vga_y,
                output logic [2:0] vga_colour, output logic vga_plot);
     // draw the Reuleaux triangle
     logic signed [7:0] c_x1, c_x2, c_x3;
     logic signed [6:0] c_y1, c_y2, c_y3;
     logic plot_red, plot_green, plot_blue;
     logic [7:0] radius;
     logic [7:0] x_red, x_green, x_blue;
     logic [6:0] y_red, y_green, y_blue;
     logic start_red, start_green, start_blue;
     logic done_red, done_green, done_blue;
     logic [2:0] state, nextstate;
     logic [2:0] red, green, blue;

     assign c_x1 = centre_x + (diameter/8'd2);
     assign c_y1 = centre_y + (diameter*($sqrt(8'd3)/8'd6));
     assign c_x2 = $signed(centre_x) - $signed((diameter/8'd2));
     assign c_y2 = centre_y + (diameter*($sqrt(8'd3)/8'd6));
     assign c_x3 = centre_x;
     assign c_y3 = $signed(centre_y) - $signed((diameter*($sqrt(8'd3)/8'd3))); 
     assign radius = diameter/8'd2;

     always_comb begin
          if(state == 3'd2)begin
               start_red = 1;
               start_green = 0;
               start_blue = 0;
          end
          else if(state == 3'd3) begin
               start_red = 0;
               start_green = 1;
               start_blue = 0;
          end
          else if(state == 3'd4) begin
               start_red = 0;
               start_green = 0;
               start_blue = 1;
          end
          else begin
               start_red = 0;
               start_green = 0;
               start_blue = 0;
          end         
     end
     always_comb begin
          case(state)
          3'd1 : nextstate = start ? 3'd2 : 3'd1;
          3'd2 : nextstate = done_red ? 3'd3 : 3'd2;
          3'd3 : nextstate = done_green ? 3'd4 : 3'd3;
          3'd4 : nextstate = done_blue ? 3'd5 : 3'd4;
          3'd5 : nextstate = 3'd5;
          default : nextstate = 3'd5;
          endcase
     end

     always_ff @(posedge clk) begin
          if(~rst_n)
          state <= 3'd1;
          else
          state <= nextstate;
     end

     always_ff @(posedge clk) begin
          case(state)
          3'd1 : begin
               done <= 0;
               vga_x <= 8'b0;
               vga_y <= 7'b0;
               vga_plot <= 0;
          end
          3'd2 : begin
               vga_x <= x_red;
               vga_y <= y_red;
               vga_plot <= plot_red;
               vga_colour <= red;
          end
          3'd3 : begin
               vga_x <= x_green;
               vga_y <= y_green;
               vga_plot <= plot_green;
               vga_colour <= green;
          end
          3'd4 : begin
               vga_x <= x_blue;
               vga_y <= y_blue;
               vga_plot <= plot_blue;
               vga_colour <= blue;
          end
          3'd5 : begin
               done <= 1;
               vga_x <= 8'b0;
               vga_y <= 7'b0;
               vga_plot <= 0;              
          end
          endcase


     end
 
     circle cr (.clk(clk),
                .rst_n(rst_n),
                .colour(3'b100),
                .centre_x(c_x3),
                .centre_y(c_y3),
                .radius(radius),
                .start(start_red),
                .done(done_red),
                .vga_x(x_red),
                .vga_y(y_red),
                .vga_colour(red),
                .vga_plot(plot_red));

     circle cg (.clk(clk),
                .rst_n(rst_n),
                .colour(3'b010),
                .centre_x(c_x2),
                .centre_y(c_y2),
                .radius(radius),
                .start(start_green),
                .done(done_green),
                .vga_x(x_green),
                .vga_y(y_green),
                .vga_colour(green),
                .vga_plot(plot_green)); 

     circle cb (.clk(clk),
                .rst_n(rst_n),
                .colour(3'b001),
                .centre_x(c_x1),
                .centre_y(c_y1),
                .radius(radius),
                .start(start_blue),
                .done(done_blue),
                .vga_x(x_blue),
                .vga_y(y_blue),
                .vga_colour(blue),
                .vga_plot(plot_blue));       
endmodule

