`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/09 01:35:33
// Design Name: 
// Module Name: decode32
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


module decode32(read_data_1,read_data_2,Instruction,mem_data,ALU_result,
                 Jal,RegWrite,MemtoReg,RegDst,Sign_extend,clock,reset,opcplus4);
    output[31:0] read_data_1;               // 输出的第一操作数
    output[31:0] read_data_2;               // 输出的第二操作数
    input[31:0]  Instruction;               // 取指单元来的指令
    input[31:0]  mem_data;   				//  从DATA RAM or I/O port取出的数据
    input[31:0]  ALU_result;   				// 从执行单元来的运算的结果
    input        Jal;                       //  来自控制单元，说明是JAL指令 
    input        RegWrite;                  // 来自控制单元 --> 是否要 写寄存器
    input        MemtoReg;              // 来自控制单元 --> 是否要 读存储器并写寄存器
    input        RegDst;               //  来自控制单元 --> 1 indicate destination register is "rd"(R),otherwise it's "rt"(I)
    output[31:0] Sign_extend;               // 扩展后的32位立即数
    input		 clock,reset;                // 时钟和复位
    input[31:0]  opcplus4;                 // 来自取指单元，JAL中用
    
    // 定义一个寄存器组 --> 32个寄存器，每个位宽均为32bits
    reg[31:0] Registers[0:31];
    
    // R-type : rd = rs + rt
    // I-type : rt = rs + (sign-extended) immediate
    // J-type : jal: reg[31] = opcplus4 
    wire [15:0]immediate;
    wire [4:0] rs, rt, rd;
    wire [5:0] opcode;
    
    assign opcode = Instruction[31:26];
    assign immediate = Instruction[15:0];
    assign rs = Instruction[25:21];
    assign rt = Instruction[20:16];
    assign rd = Instruction[15:11];
    
    // sign extend : lui:放入高16位，低16位填0    andiu,andi,ori,xori，sltiu --> zero_extended     other instructions: sign_extended
//    assign Sign_extend = (opcode == 6'b001111) ? {immediate,{16{1'b0}}} : 
//                         ((opcode == 6'b001001 || opcode == 6'b001100 || opcode == 6'b001101 || opcode == 6'b001110 || opcode == 6'b001011) ? 
//                         {{16{1'b0}}, immediate} : {{16{immediate[15]}}, immediate});
    assign Sign_extend = (6'b001100 == opcode || 6'b001101 == opcode)?{{16{1'b0}},immediate}:{{16{Instruction[15]}},immediate};
    // read register
    assign read_data_1 = Registers[rs];
    assign read_data_2 = Registers[rt];
    
    // reset 复位信号高电平有效  --> rst 低电平有效
    wire rst;
    assign rst = ~reset;
     
    // write register
    always @ (posedge clock or negedge rst) begin
        if (~rst) begin
            Registers[1] <= 32'b0;
            Registers[2] <= 32'b0;
            Registers[3] <= 32'b0;
            Registers[4] <= 32'b0;
            Registers[5] <= 32'b0;
            Registers[6] <= 32'b0;
            Registers[7] <= 32'b0;
            Registers[8] <= 32'b0;
            Registers[9] <= 32'b0;
            Registers[10] <= 32'b0;
            Registers[11] <= 32'b0;
            Registers[12] <= 32'b0;
            Registers[13] <= 32'b0;
            Registers[14] <= 32'b0;
            Registers[15] <= 32'b0;
            Registers[16] <= 32'b0;
            Registers[17] <= 32'b0;
            Registers[18] <= 32'b0;
            Registers[19] <= 32'b0;
            Registers[20] <= 32'b0;
            Registers[21] <= 32'b0;
            Registers[22] <= 32'b0;
            Registers[23] <= 32'b0;
            Registers[24] <= 32'b0;
            Registers[25] <= 32'b0;
            Registers[26] <= 32'b0;
            Registers[27] <= 32'b0;
            Registers[28] <= 32'b0;
            Registers[29] <= 32'b0;
            Registers[30] <= 32'b0;
            Registers[31] <= 32'b0;            
        end
        else begin
            if (Jal) begin
                Registers[31] <= opcplus4;
            end
            else if (RegWrite) begin
                // lw
                if (MemtoReg && rt != 0)  begin
                    Registers[rt] <= mem_data;
                end
                else begin
                    // R-format 
                    if (RegDst && rd != 0) begin
                        Registers[rd] <= ALU_result;
                    end
                    // I-format
                    else if (~RegDst && rt != 0) begin
                        Registers[rt] <= ALU_result;
                    end
                end
            end
        end
    end
    
endmodule
