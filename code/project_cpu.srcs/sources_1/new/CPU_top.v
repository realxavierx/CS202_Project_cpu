`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/11 23:49:23
// Design Name: 
// Module Name: CPU_top
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


module CPU_top(fpga_clk, fpga_rst, start_pg, rx, tx, switches, leds, seg_bit_selection, seg_selection
//, send
, row, col
//, IORead, stay_PC, Instruction, PC, cpu_fpga_clk
// , ALU_result, address, ioread_data
);
    input fpga_clk, fpga_rst;
    
//    input send;

    //UART Programmer Pinouts
    // start Uart communicate at high level
    input start_pg;  // Active high
    input rx;       // receive data by UART
    output tx;      // send data by UART

    // UART Programmer Pinouts
    wire upg_clk, upg_clk_o;
    wire upg_wen_o;     // Uart write out enable
    wire upg_done_o;    // Uart rx data have done
    
    // data to which memory unit of program_rom/dememory32
    wire[14:0] upg_adr_o;

    // data to program_rom or dmemory32
    wire[31:0] upg_dat_o;

    input[23:0] switches;
    output[23:0] leds;
    
//    output cpu_fpga_clk; 
//    output[31:0] Instruction;
    wire cpu_fpga_clk; 
    wire[31:0] Instruction;

    wire[31:0] Read_Data_1;
    wire[31:0] Read_Data_2;
    wire[31:0] mem_data;
    wire[31:0] branch_base_addr;
    wire[31:0] Addr_Result;
    wire[31:0] link_addr;
    wire[31:0] ALU_result;
    wire[31:0] Sign_extend;
    wire[31:0] address;
    wire[31:0] writeData;
    wire[31:0] readData;
    wire[31:0] PC_plus_4;
    wire[15:0] switchrdata;
    wire Jr, RegDST, ALUSrc, MemtoReg, RegWrite, MemWrite, Branch, nBranch, Jmp, Jal, I_format, Sftmd, Zero;
    wire[1:0] ALUOp;
    wire MemRead, IOWrite, LEDCtrl, SwitchCtrl;
    wire IORead;
    wire[15:0] ioread_data;
  
    output [7:0] seg_bit_selection; ////��һλ��ʾ
    output [7:0] seg_selection;  ///��ʾʲô
    

    

    wire spg_bufg; 
    BUFG U1(.I(start_pg), .O(spg_bufg)); // de-twitter 
    // Generate UART Programmer reset signal 
    reg upg_rst = 1; 
    always @ (posedge fpga_clk) begin 
        if (spg_bufg) upg_rst = 0; 
        if (fpga_rst) upg_rst = 1; 
    end 
    //used for other modules which don't relate to UART 
    wire rst; 
    assign rst = fpga_rst | (!upg_rst);




    input [3:0] row;    /////�������?????
    output [3:0] col;   //////�������?????
    wire KeyCtrl;
    wire KeyBoardClear;
    wire[3:0] KeyBoardVal;
        
    /////////  �������?????
    wire press;
    wire [7:0] seg_o;
    wire [7:0] se;
    key_top u(
        fpga_clk, 
        rst, 
        row, 
        col, 
        press,
        KeyBoardVal
    );

    reg[15:0] keyBoardData;
    reg[2:0] counter = 3'b000;

    reg [24:0] cnt;      // 计数�?
    wire k_clk;
    
    /////////// 分频
    always @ (posedge fpga_clk or posedge rst)
    if (rst)
        cnt <= 0;
    else
        cnt <= cnt + 1'b1;
        
    assign k_clk = cnt[24]; 



    always @(posedge k_clk or posedge rst or posedge KeyBoardClear) begin
        if(rst) begin
            keyBoardData <= 16'h0000;
            counter <= 3'b000;
        end
        else if (KeyBoardClear) begin
            keyBoardData <= 16'b0000;
            counter <= 3'b000;
        end
        else if(press) begin
            if(counter <= 3'b100) begin
                counter <= counter + 1;
                keyBoardData[4 * counter - 4] <= KeyBoardVal[0];
                keyBoardData[4 * counter - 3] <= KeyBoardVal[1];
                keyBoardData[4 * counter - 2] <= KeyBoardVal[2];
                keyBoardData[4 * counter - 1] <= KeyBoardVal[3];
            end
            else begin
                counter <= 3'b000;
            end
        end
    end


    uart_bmpg_0 uart(
      .upg_clk_i(upg_clk),
      .upg_rst_i(upg_rst),
      .upg_rx_i(rx),
      .upg_clk_o(upg_clk_o),
      .upg_wen_o(upg_wen_o),
      .upg_adr_o(upg_adr_o[14:0]),
      .upg_dat_o(upg_dat_o[31:0]),
      .upg_done_o(upg_done_o),
      .upg_tx_o(tx)  
    );

    control32 control32(
        .Opcode(Instruction[31:26]),
        .Function_opcode(Instruction[5:0]), 
        .Jr(Jr), 
        .RegDST(RegDST), 
        .ALUSrc(ALUSrc), 
        .MemOrIOtoReg(MemtoReg), 
        .RegWrite(RegWrite), 
        .MemWrite(MemWrite),

        .IORead(IORead),
        .IOWrite(IOWrite),
        .MemRead(MemRead),
        .ALU_resultHigh(ALU_result[31: 10]),
        
        .Branch(Branch), 
        .nBranch(nBranch), 
        .Jmp(Jmp), 
        .Jal(Jal), 
        .I_format(I_format), 
        .Sftmd(Sftmd), 
        .ALUOp(ALUOp));
    
    decode32 decoder(
        .read_data_1(Read_Data_1),
        .read_data_2(Read_Data_2),
        .Instruction(Instruction),
        .mem_data(mem_data),
        .ALU_result(ALU_result),
        .Jal(Jal),
        .RegWrite(RegWrite),
        .MemtoReg(MemtoReg),
        .RegDst(RegDST),
        .Sign_extend(Sign_extend),
        .clock(cpu_fpga_clk),
        .reset(rst),
        .opcplus4(link_addr));
        
    ALU alu(
        .Read_data_1(Read_Data_1),
        .Read_data_2(Read_Data_2),
        .Sign_extend(Sign_extend),
        .Function_opcode(Instruction[5:0]),
        .Exe_opcode(Instruction[31:26]),
        .ALUOp(ALUOp),
        .Shamt(Instruction[10:6]),
        .ALUSrc(ALUSrc),
        .I_format(I_format),
        .Zero(Zero),
        .Jr(Jr),
        .Sftmd(Sftmd),
        .ALU_Result(ALU_result),
        .Addr_Result(Addr_Result),
        .PC_plus_4(branch_base_addr));
        
    wire[31:0] PC;
    programrom rom(
        .rom_clk_i(cpu_fpga_clk),
        .rom_adr_i(PC[15:2]),
        .upg_rst_i(upg_rst),
        .upg_clk_i(upg_clk_o),
        .upg_wen_i((!upg_adr_o[14] & upg_wen_o)?1'b1:1'b0),
        .upg_adr_i(upg_adr_o[13:0]),
        .upg_dat_i(upg_dat_o),
        .upg_done_i(upg_done_o),
        .Instruction_o(Instruction)
    ); 
        


    Ifetc32 ifetch(
        .Instruction(Instruction),
        .branch_base_addr(branch_base_addr),
        .Addr_result(Addr_Result),
        .Read_data_1(Read_Data_1),
        .Branch(Branch),
        .nBranch(nBranch),
        .Jmp(Jmp),
        .Jal(Jal),
        .Jr(Jr),
        .Zero(Zero),
        .clock(cpu_fpga_clk),
        .reset(rst),
        .link_addr(link_addr),
        .PC(PC)
        );
    
    dmemory32 dmem(
        .fpga_clk(cpu_fpga_clk),
        .memWrite(MemWrite),
        .address(address),
        .writeData(writeData),
        .readData(readData),
        .upg_rst_i(upg_rst),
        .upg_clk_i(upg_clk_o),
        .upg_wen_i((upg_adr_o[14] & upg_wen_o)?1'b1:1'b0), ///// !upg_adr_o[14]
        .upg_adr_i(upg_adr_o[13:0]),
        .upg_dat_i(upg_dat_o),
        .upg_done_i(upg_done_o)
        );
        
    
    assign ioread_data = (address[1:0] == 2'b11) ? keyBoardData: switchrdata;

    MemOrIO memorio(
        .mRead(MemRead), 
        .mWrite(MemWrite),
        .ioRead(IORead), 
        .ioWrite(IOWrite),
        .addr_in(ALU_result), 
        .addr_out(address), 
        .m_rdata(readData), 
        .io_rdata(ioread_data), 
        .r_wdata(mem_data), 
        .r_rdata(Read_Data_2), 
        .write_data(writeData), 
        .LEDCtrl(LEDCtrl), 
        .SwitchCtrl(SwitchCtrl),
        .KeyCtrl(KeyCtrl),
        .KeyBoardClear(KeyBoardClear)
        );
        
    LED out_put(
        .cpu_clk(cpu_fpga_clk), 
        .reset(rst), 
        .LEDWrite(IOWrite), 
        .LEDCtrl(LEDCtrl), 
        .LED_addr(address[1:0]),
        .LEDwdata(writeData[15:0]), 
        .LEDout(leds)
   );
   
   Switch in_put(
        .switclk(cpu_fpga_clk),
        .switrst(rst), 
        .switchread(IORead), 
        .switchcs(SwitchCtrl),
        .switchaddr(address[1:0]), 
        .switchrdata(switchrdata), 
        .switch_i( switches)
   );
                
   cpuclk clock_gen(
        .clk_in1(fpga_clk),
        .clk_out1(cpu_fpga_clk),
        .clk_out2(upg_clk)
   );
    
   Tub tub(
        .clk(cpu_fpga_clk),
        .rst(rst),
        .IOWrite(IOWrite),
        .LEDCtrl(LEDCtrl),
        .LED_addr(address[1:0]),
        .writeData(writeData[15:0]),
        .Y(seg_selection),
        .DIG(seg_bit_selection)
   );
endmodule
