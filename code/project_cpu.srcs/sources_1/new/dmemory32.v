`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/09 19:34:09
// Design Name: 
// Module Name: dmemory32
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


module dmemory32(fpga_clk,memWrite,address,writeData,readData
,upg_rst_i, upg_clk_i, upg_wen_i, upg_adr_i, upg_dat_i, upg_done_i   
 );

    input fpga_clk, memWrite;  //memWrite ����controller��Ϊ1'b1ʱ��ʾҪ��data-memory��д����
    input [31:0] address;   //address ���ֽ�Ϊ��λ
    input [31:0] writeData; //writeData ����data-memory��д�������?
    output[31:0] readData;  //writeData ����data-memory�ж���������
    
    //UART Programmer Pinouts
    input upg_rst_i; // UPG reset (Active High) 
    input upg_clk_i; // UPG ram_clk_i (10MHz) 
    input upg_wen_i; // UPG write enable 
    input [13:0] upg_adr_i; // UPG write address 
    input [31:0] upg_dat_i; // UPG write data 
    input upg_done_i; // 1 if programming is finished
    
    
    wire ram_clk = !fpga_clk;
// CPU work on normal mode when no_Uart_mode is 1.
// CPU work on Uart communicate mode when no_Uart_mode is 0.
    wire no_Uart_mode = upg_rst_i | (~upg_rst_i & upg_done_i);

    RAM ram ( 
    .clka(no_Uart_mode? ram_clk: upg_clk_i), // input wire clka 
    .wea(no_Uart_mode? memWrite: upg_wen_i), // input wire [0 : 0] wea 
    .addra(no_Uart_mode? address[15:2]: upg_adr_i[13:0]), // input wire [13 : 0] addra 
    .dina(no_Uart_mode? writeData: upg_dat_i), // input wire [31 : 0] dina 
    .douta(readData)) ;// output wire [31 : 0] douta 
    
    
    
endmodule
