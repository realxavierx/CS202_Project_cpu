`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/21 00:12:33
// Design Name: 
// Module Name: led_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module led_tb();
reg clk = 1'b0; 
 reg reset = 1'b0; 
 reg [23:0] switches = 24'b000000000000000000000000; 
 wire [23:0] leds; 
 reg ctrl = 1'b1;
 reg write = 1'b1;
 reg [1:0]addr = 2'b00;
 
 LED led(clk, reset, ctrl, write, addr, switches, leds);
 
 always 
  #10 clk = ~clk; 
  initial begin 
  #5 reset = 1'b1; 
  #8 reset = 1'b0; 
  repeat(15) begin
     #10 switches = switches + 1;
  end
  
  #200 $finish(); 
  end 
 
endmodule
