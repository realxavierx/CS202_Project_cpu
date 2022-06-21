`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/20 23:54:18
// Design Name: 
// Module Name: cpu_tb
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

module cpu_tb(); 
 reg clk = 1'b0; 
 reg reset = 1'b0;
 reg start_pg = 1'b0; 
 reg rx = 1'b0;
 wire tx;
 reg [23:0] switches = 24'b0000_0000_0000000000000000; 
 wire [23:0] leds; 
 wire [7:0] seg_bit_selection;
 wire [7:0] seg_selection;
 wire [31:0] ALU_result;
 wire [31:0] address;
 reg send = 1'b0;
 wire stay_PC;
 wire IORead;
 wire [31:0] Instruction;
 wire [31:0] PC;
 wire cpu_clk;
 wire[15:0] ioread_data;
 
     CPU_top cpu_ins(clk, reset, start_pg, rx, tx, switches, leds, seg_bit_selection, seg_selection, send, IORead, stay_PC, Instruction, PC, cpu_clk
 , ALU_result, address, ioread_data
 );
             

 initial begin 
 clk = 1'b0; 
 #5 reset = 1'b1;
 #8 reset = 1'b0;
 #3000 switches = switches + 1;
 #10 send = 1;
 #100 send = 0;
  #500 switches = switches + 1;
  #500 switches = switches + 1;
  #100 send = 1; 
  #100 send = 0;
  end
  
 always #5 clk = ~clk;

 
 endmodule 