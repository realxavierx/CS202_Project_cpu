`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/09 12:17:09
// Design Name: 
// Module Name: Ifetc32
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

module Ifetc32(Instruction,branch_base_addr,Addr_result,Read_data_1,Branch,nBranch,Jmp,Jal,Jr,Zero,clock,reset,link_addr,PC
//,stay_PC
);
    output[31:0] Instruction;			// ����PC��ֵ�Ӵ��ָ���prgrom��ȡ����ָ��
    output[31:0] branch_base_addr;      // ������������ת���ָ����ԣ���ֵΪ(pc+4)����ALU
    input[31:0]  Addr_result;            // ����ALU,ΪALU���������ת���?
    input[31:0]  Read_data_1;           // ����Decoder��jrָ���õĵ�ַ
    input        Branch;                // ���Կ��Ƶ�Ԫ
    input        nBranch;               // ���Կ��Ƶ�Ԫ
    input        Jmp;                   // ���Կ��Ƶ�Ԫ
    input        Jal;                   // ���Կ��Ƶ�Ԫ
    input        Jr;                   // ���Կ��Ƶ�Ԫ
    input        Zero;                  //����ALU��ZeroΪ1��ʾ����ֵ��ȣ���֮��ʾ�����
    input        clock,reset;           //ʱ���븴λ,��λ�ź����ڸ�PC����ʼֵ����λ�źŸߵ�ƽ��Ч
    output reg [31:0]  link_addr;             // JALָ��ר�õ�PC+4
    output reg [31:0] PC;
    
    reg[31:0] Next_PC; 
    
//    input stay_PC;
   
    
    assign branch_base_addr = PC+4;  
   
   
    always @(*) begin
         if(Jr == 1'b1)begin
            Next_PC =Read_data_1 ;
         end
         else if((Branch == 1'b1 && Zero == 1'b1) || (nBranch == 1'b1 && Zero == 1'b0)) begin
             Next_PC =Addr_result ;
         end
        else Next_PC = PC + 4; // PC+4
    end


    always @(negedge clock or posedge reset) begin
        if (reset) begin
            PC <= 32'h0000_0000;
        end 
        
        else begin
        if (Jal == 1'b1 || Jmp == 1'b1) begin
            link_addr <= Next_PC;
            PC <= {PC[31:28], Instruction[25:0], 2'b00};
            end
        else begin
            PC <= Next_PC;
        end
        end
    end
    
    
    // prgrom instmem(
    //  .clka(clock), 
    //  .addra(PC[15:2]),
    //   .douta(Instruction)
    //    );
    
endmodule
