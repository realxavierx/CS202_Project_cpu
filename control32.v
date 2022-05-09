`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/09 00:55:23
// Design Name: 
// Module Name: control32
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

module control32(
input[5:0] Opcode, // instruction[31..26], opcode 
input[5:0] Function_opcode, // instructions[5..0], funct 
output Jr, // 1 indicates the instruction is "jr", otherwise it's not "jr" 
output Jmp, // 1 indicate the instruction is "j", otherwise it's not 
output Jal, // 1 indicate the instruction is "jal", otherwise it's not 
output Branch, // 1 indicate the instruction is "beq" , otherwise it's not 
output nBranch, // 1 indicate the instruction is "bne", otherwise it's not 
output RegDST, // 1 indicate destination register is "rd"(R),otherwise it's "rt"(I) 
output MemtoReg, // 1 indicate read data from memory and write it into register 
output RegWrite, // 1 indicate write register(R,I(lw)), otherwise it's not 
output MemWrite, // 1 indicate write data memory, otherwise it's not 
output ALUSrc, // 1 indicate the 2nd data is immidiate (except "beq","bne") 
output Sftmd, // 1 indicate the instruction is shift instruction
output I_format, // 1 indicate the instruction is I-type but isn't "beq","bne","LW" or "SW" 
output[1:0] ALUOp // if the instruction is R-type or I_format, ALUOp is 2'b10;
                  // if the instruction is"beq" or "bne", ALUOp is 2'b01£» 
                  // if the instruction is"lw" or "sw", ALUOp is 2'b00£»
    );
    
    wire R_format, lw, sw;
    
    // Jr = 6'b000000 + 6'b001000)  Jmp = 6'b000010  Jal = 6'b000011
    assign Jr =((Opcode == 6'b000000) && (Function_opcode == 6'b001000)) ? 1'b1: 1'b0;
    assign Jmp = (Opcode == 6'b000010) ? 1'b1: 1'b0;
    assign Jal = (Opcode == 6'b000011) ? 1'b1: 1'b0;
    // "R_format" indicate the instruction is R_format instruction 
    assign R_format = (Opcode == 6'b000000)? 1'b1:1'b0; 
    // "RegDST" is used to determine the destination in the register file which is determined by rd(1) or rt(0)
    assign RegDST = R_format;
    // "RegWrite" is used to determine whether to write registe(1) or not(0).
    assign RegWrite = (R_format || lw || Jal || I_format) && !(Jr);
    // "I_format" is used to identify if the instruction is I_type(except for beq, bne, lw and sw). e.g. addi, subi, ori, andi¡­
    assign I_format = (Opcode[5:3]==3'b001)? 1'b1:1'b0;
    // "ALUOp" is used to code the type of instructions described in the table on the left hand
    assign ALUOp = {(R_format || I_format),(Branch || nBranch)};
    // "Sftmd " is used to identify whether the instruction is shift cmd or not.
    assign Sftmd = (((Function_opcode==6'b000000)||(Function_opcode==6'b000010) ||(Function_opcode==6'b000011)||(Function_opcode==6'b000100) ||(Function_opcode==6'b000110)||(Function_opcode==6'b000111)) && R_format)? 1'b1:1'b0;
    // beq: 000100  bne: 000101
    assign Branch = (Opcode == 6'b000100) ? 1'b1: 1'b0; 
    assign nBranch = (Opcode == 6'b000101) ? 1'b1: 1'b0;
    // ALUSrc -> second data is immediate
    assign ALUSrc = (I_format || lw || sw);
    // lw: 100011  sw: 101011
    assign lw = (Opcode == 6'b100011) ? 1'b1: 1'b0;
    assign sw = (Opcode == 6'b101011) ? 1'b1: 1'b0;
    // MemtoReg indicate read data from memory and write it into register
    assign MemtoReg = lw;
    // MemWrite indicate write data memory 
    assign MemWrite = sw;
    
endmodule

