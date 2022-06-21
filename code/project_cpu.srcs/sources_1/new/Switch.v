`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/13 15:00:27
// Design Name: 
// Module Name: Switch
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


module Switch(switclk, switrst, switchread, switchcs,switchaddr, switchrdata, switch_i);
    input switclk;		//  时钟信号	        
    input switrst;		//  复位信号	        
    input switchcs;		//从memorio来的switch片选信号  !!!!!!!!!!!!!!!!!	       
    input[1:0] switchaddr;	//  到switch模块的地址低端  !!!!!!!!!!!!!!!	    
    input switchread;		 //  读信号	   
    output reg [15:0] switchrdata;	    //  送到CPU的拨码开关值注意数据总线只有16根 
    input [23:0] switch_i;		    //  从板上读的24位开关数据 

    always@(negedge switclk or posedge switrst) begin
        if(switrst) begin
            switchrdata <= 0;
        end
		else if(switchcs && switchread) begin
			if(switchaddr==2'b00)
				switchrdata[15:0] <= switch_i[15:0];   // data output,lower 16 bits non-extended
			else if(switchaddr==2'b10)
				switchrdata[15:0] <= { 8'h00, switch_i[23:16] }; //data output, upper 8 bits extended with zero
			else 
				switchrdata <= switchrdata;
        end
		else begin
            switchrdata <= switchrdata;
        end
    end
endmodule
