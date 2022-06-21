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
                 Jal,RegWrite,MemtoReg,RegDst,Sign_extend,clock,reset,opcplus4
                 );
    output[31:0] read_data_1;               // ����ĵ�һ������
    output[31:0] read_data_2;               // ����ĵڶ�������
    input[31:0]  Instruction;               // ȡָ��Ԫ����ָ��
    input[31:0]  mem_data;   				//  ��DATA RAM or I/O portȡ��������
    input[31:0]  ALU_result;   				// ��ִ�е�Ԫ��������Ľ��
    input        Jal;                       //  ���Կ��Ƶ�Ԫ��˵����JALָ�� 
    input        RegWrite;                  // ���Կ��Ƶ�Ԫ --> �Ƿ�Ҫ д�Ĵ���
    input        MemtoReg;              // ���Կ��Ƶ�Ԫ --> �Ƿ�Ҫ ���洢����д�Ĵ���
    input        RegDst;               //  ���Կ��Ƶ�Ԫ --> 1 indicate destination register is "rd"(R),otherwise it's "rt"(I)
    output[31:0] Sign_extend;               // ��չ���32λ������
    input		 clock,reset;                // ʱ�Ӻ͸�λ
    input[31:0]  opcplus4;                 // ����ȡָ��Ԫ��JAL����

    
    // ����һ���Ĵ����� --> 32���Ĵ�����ÿ��λ����Ϊ32bits
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
    
    // sign extend : lui:�����16λ����16λ��0    andiu,andi,ori,xori��sltiu --> zero_extended     other instructions: sign_extended
//    assign Sign_extend = (opcode == 6'b001111) ? {immediate,{16{1'b0}}} : 
//                         ((opcode == 6'b001001 || opcode == 6'b001100 || opcode == 6'b001101 || opcode == 6'b001110 || opcode == 6'b001011) ? 
//                         {{16{1'b0}}, immediate} : {{16{immediate[15]}}, immediate});
    assign Sign_extend = (6'b001100 == opcode || 6'b001101 == opcode)?{{16{1'b0}},immediate}:{{16{Instruction[15]}},immediate};
    // read register
    assign read_data_1 = Registers[rs];
    assign read_data_2 = Registers[rt];
    
    // reset ��λ�źŸߵ�ƽ��Ч  --> rst �͵�ƽ��Ч
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