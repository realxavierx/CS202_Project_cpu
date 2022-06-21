`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/13 13:47:21
// Design Name: 
// Module Name: LED
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


module LED(cpu_clk, reset, LEDCtrl, LEDWrite, LED_addr, LEDwdata, LEDout);
    input cpu_clk;
    input reset;
    input LEDCtrl;
    input LEDWrite;
    input[1:0] LED_addr;
    input[15:0] LEDwdata;
    output reg [23:0] LEDout;//rstҪ��ֵ������Ҫreg
    
    always@(posedge cpu_clk or posedge reset) begin
        if(reset) begin
           LEDout <= 24'h00_0000; 
        end
        else if(LEDCtrl && LEDWrite) begin
            if(LED_addr == 2'b00)
                LEDout[23:0] <= { LEDout[23:16], LEDwdata[15:0] };
            else if(LED_addr == 2'b10)
                LEDout[23:0] <= { LEDwdata[7:0], LEDout[15:0] };
            else
                LEDout <= LEDout;
        end
        else begin
            LEDout <= LEDout;
        end
    end
endmodule
