`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/21 08:33:35
// Design Name: 
// Module Name: Tub
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


module Tub(clk, rst, IOWrite, LED_addr, writeData, Y, DIG, LEDCtrl
    );
    input clk;
    input rst;
    input IOWrite;
    input LEDCtrl;
    input[1:0] LED_addr;
    input[15:0] writeData;
    
    output[7:0] Y;
    output[7:0] DIG;

    
   reg clkout = 0;
   reg [31:0] cnt = 0;
   reg [3:0] scan_cnt = 4'b0000;

   // clk(Y18) = 100Mhz  cpu_clk = 23Mhz
   
    // period 变成 原来的4倍还是 原来的0.25倍？

   parameter period = 4600; //5000HZ stable    

   
    reg[31:0] data;

    reg[3:0] next_send = 4'b0001;

    // 左边第一位显示Test Case  空一�??  接下来四位显示输入数�??  空一�?? �??后一位显示两个发送键的状�??
   always@(posedge clk or posedge rst) begin
      if (rst) begin
          data <= 32'b0;
          next_send <= 4'b0001;
      end
      else begin
        if(IOWrite && LEDCtrl) begin
            if(LED_addr == 2'b00) begin
                data <= {data[31:24], writeData[15:0], data[7:0]};
            end
            else if(LED_addr == 2'b10) begin
                if (writeData[1:0] == 2'b10) begin
                    next_send <= 4'b0001;
                end
                else if (writeData[1:0] == 2'b01) begin
                    next_send <= 4'b0010;
                end
                else begin
                    next_send <= next_send;
                end

                data <= {1'b0, writeData[7:5], data[27:4], next_send};
            end  
            else data <= data;
        end
        else data <= data;
      end
   end 


   reg [6:0] Y_r = 7'b0000000;
   reg [7:0] DIG_r;
   reg [3:0] value; 
   
   assign Y = {1'b1,(~Y_r[6:0])}; //dont light
   assign DIG = ~DIG_r;
   

   always@( posedge clk or posedge rst)  //frequency division : clk -> clkout
   begin
    if(rst) begin
        cnt <= 0;
        clkout <= 0;
    end
    else if(cnt == (period >> 1) - 1)   //ż����Ƶ
       begin
       clkout <= ~clkout;
       cnt <= 0;
       end
   else
       cnt <= cnt + 1;   
   end
   
   always@(posedge clkout or posedge rst) //change scan_cnt based on clkout
   begin
       if(rst) scan_cnt <= 4'b0000;
       else begin
            scan_cnt <= scan_cnt + 1;
            if(scan_cnt == 4'b1001) scan_cnt <= 0;
       end
   end
   
   
   always@(scan_cnt) begin //select tube 
      case(scan_cnt) 
           4'b0001 : DIG_r = 8'b0000_0001;

           4'b0010 : DIG_r = 8'b0000_0000;
           
           4'b0011 : DIG_r = 8'b0000_0100;
           4'b0100 : DIG_r = 8'b0000_1000;
           4'b0101 : DIG_r = 8'b0001_0000;
           4'b0110 : DIG_r = 8'b0010_0000;

           4'b0111 : DIG_r = 8'b0000_0000;
           
           4'b1000 : DIG_r = 8'b1000_0000;

           default : DIG_r = 8'b0000_0000;
       endcase   
    end
    
    always@(scan_cnt) begin
        case(scan_cnt) 
            1: value = data[3:0];
            2: value = data[7:4];
            3: value = data[11:8];
            4: value = data[15:12];
            5: value = data[19:16];
            6: value = data[23:20];
            7: value = data[27:24];
            8: value = data[31:28];
            default: value = 4'bzzzz;
        endcase
    end
    
    always@(value) begin
        case(value)
            4'b0000: Y_r = 7'b0111_111; //0
            4'b0001: Y_r = 7'b0000_110; //1
            4'b0010: Y_r = 7'b1011_011; //2
            4'b0011: Y_r = 7'b1001_111; //3
            4'b0100: Y_r = 7'b1100_110; //4
            4'b0101: Y_r = 7'b1101_101; //5
            4'b0110: Y_r = 7'b1111_101; //6
            4'b0111: Y_r = 7'b0000_111; //7
            4'b1000: Y_r = 7'b1111_111; //8
            4'b1001: Y_r = 7'b1101_111; //9
            4'b1010: Y_r = 7'b1110_111; //A
            4'b1011: Y_r = 7'b1111_100; //b
            4'b1100: Y_r = 7'b0111_001; //C
            4'b1101: Y_r = 7'b1011_110; //d
            4'b1110: Y_r = 7'b1111_001; //E
            4'b1111: Y_r = 7'b1110_001; //F
            default: Y_r = 7'b0000_000; //ȫ��
        endcase
    end
    
    
    
endmodule
