/* $Author: sinclair $ */
/* $LastChangedDate: 2020-02-09 17:03:45 -0600 (Sun, 09 Feb 2020) $ */
/* $Rev: 46 $ */
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input clk;
   input rst;

   output err;

   // None of the above lines can be modified

   // OR all the err ouputs for every sub-module and assign it as this
   // err output
   
   // As desribed in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines
   
   
   /* your code here -- should include instantiations of fetch, decode, execute, mem and wb modules */
    wire Halt;
    wire decodeErr, executeErr;
    wire [15:0] nextPC, regWdata;
    wire [15:0] IF_PC, IF_ins;
    wire [15:0] ID_PC, ID_ins, ID_imm, ID_data1, ID_data2;
    wire [3:0] ID_ALUControl;
    wire [2:0] ID_RegWriteAddr;
    wire ID_ALUInB, ID_MemRead, ID_MemWrite, ID_WriteDataMem, ID_WriteDataPC, ID_RegWrite;
    wire [15:0] EX_imm, EX_data1, EX_data2, EX_ALUOut, EX_PC;
    wire [4:0] EX_ALUControl;
    wire [2:0] EX_RegWriteAddr;
    wire EX_ALUInB, EX_MemRead, EX_MemWrite, EX_WriteDataMem, EX_WriteDataPC, EX_RegWrite;
    wire [15:0] MEM_data2, MEM_ALUOut, MEM_MemOut, MEM_PC;
    wire [2:0] MEM_RegWriteAddr;
    wire MEM_MemRead, MEM_MemWrite, MEM_WriteDataMem, MEM_WriteDataPC, MEM_RegWrite;
    wire [15:0] WB_MemOut, WB_ALUOut, WB_PC;
    wire [2:0] WB_RegWriteAddr;
    wire WB_WriteDataMem, WB_WriteDataPC, WB_RegWrite;

    assign err = decodeErr | executeErr;

    // IF/ID reg
    dffe IF_ID_ins[15:0](.q(ID_ins), .d(IF_ins), .en(1'b1), .clk(clk), .rst(rst));
    dffe IF_ID_PC[15:0](.q(ID_PC), .d(IF_PC), .en(1'b1), .clk(clk), .rst(rst));

    // ID/EX reg
    dffe ID_EX_imm[15:0](.q(EX_imm), .d(ID_imm), .en(1'b1), .clk(clk), .rst(rst));
    dffe ID_EX_data1[15:0](.q(EX_data1), .d(ID_data1), .en(1'b1), .clk(clk), .rst(rst));
    dffe ID_EX_data2[15:0](.q(EX_data2), .d(ID_data2), .en(1'b1), .clk(clk), .rst(rst));
    dffe ID_EX_ALUControl[3:0](.q(EX_ALUControl), .d(ID_ALUControl), .en(1'b1), .clk(clk), .rst(rst));
    dffe ID_EX_PC[15:0](.q(EX_PC), .d(ID_PC), .en(1'b1), .clk(clk), .rst(rst));
    dffe ID_EX_ALUInB(.q(EX_ALUInB), .d(ID_ALUInB), .en(1'b1), .clk(clk), .rst(rst)); // ALU input B selection signal
    dffe ID_EX_MemRead(.q(EX_MemRead), .d(ID_MemRead), .en(1'b1), .clk(clk), .rst(rst));
    dffe ID_EX_MemWrite(.q(EX_MemWrite), .d(ID_MemWrite), .en(1'b1), .clk(clk), .rst(rst));
    dffe ID_EX_WriteDataMem(.q(EX_WriteDataMem), .d(ID_WriteDataMem), .en(1'b1), .clk(clk), .rst(rst));
    dffe ID_EX_WriteDataPC(.q(EX_WriteDataPC), .d(ID_WriteDataPC), .en(1'b1), .clk(clk), .rst(rst));
    dffe ID_EX_RegWrite(.q(EX_RegWrite), .d(ID_RegWrite), .en(1'b1), .clk(clk), .rst(rst));
    dffe ID_EX_RegWriteAddr[2:0](.q(EX_RegWriteAddr), .d(ID_RegWriteAddr), .en(1'b1), .clk(clk), .rst(rst));

    // EX/MEM reg
    dffe EX_MEM_data2[15:0](.q(MEM_data2), .d(EX_data2), .en(1'b1), .clk(clk), .rst(rst));
    dffe EX_MEM_ALUOut[15:0](.q(MEM_ALUOut), .d(EX_ALUOut), .en(1'b1), .clk(clk), .rst(rst));
    dffe EX_MEM_PC[15:0](.q(MEM_PC), .d(EX_PC), .en(1'b1), .clk(clk), .rst(rst));
    dffe EX_MEM_MemRead(.q(MEM_MemRead), .d(EX_MemRead), .en(1'b1), .clk(clk), .rst(rst));
    dffe EX_MEM_MemWrite(.q(MEM_MemWrite), .d(EX_MemWrite), .en(1'b1), .clk(clk), .rst(rst));
    dffe EX_MEM_WriteDataMem(.q(MEM_WriteDataMem), .d(EX_WriteDataMem), .en(1'b1), .clk(clk), .rst(rst));
    dffe EX_MEM_WriteDataPC(.q(MEM_WriteDataPC), .d(EX_WriteDataPC), .en(1'b1), .clk(clk), .rst(rst));
    dffe EX_MEM_RegWrite(.q(MEM_RegWrite), .d(EX_RegWrite), .en(1'b1), .clk(clk), .rst(rst));
    dffe EX_MEM_RegWriteAddr[2:0](.q(MEM_RegWriteAddr), .d(EX_RegWriteAddr), .en(1'b1), .clk(clk), .rst(rst));

    // MEM/WB reg
    dffe MEM_WB_ALUOut[15:0](.q(WB_ALUOut), .d(MEM_ALUOut), .en(1'b1), .clk(clk), .rst(rst));
    dffe MEM_WB_MemOut[15:0](.q(WB_MemOut), .d(MEM_MemOut), .en(1'b1), .clk(clk), .rst(rst));
    dffe MEM_WB_PC[15:0](.q(WB_PC), .d(MEM_PC), .en(1'b1), .clk(clk), .rst(rst));
    dffe MEM_WB_WriteDataMem(.q(WB_WriteDataMem), .d(MEM_WriteDataMem), .en(1'b1), .clk(clk), .rst(rst));
    dffe MEM_WB_WriteDataPC(.q(WB_WriteDataPC), .d(MEM_WriteDataPC), .en(1'b1), .clk(clk), .rst(rst));
    dffe MEM_WB_RegWrite(.q(WB_RegWrite), .d(MEM_RegWrite), .en(1'b1), .clk(clk), .rst(rst));
    dffe MEM_WB_RegWriteAddr[2:0](.q(WB_RegWriteAddr), .d(MEM_RegWriteAddr), .en(1'b1), .clk(clk), .rst(rst));

    fetch fetch(.halt(Halt), .updatedPC(nextPC), .ins(IF_ins), .clk(clk), .rst(rst), .PC_2(IF_PC));
    decode decode(.ins(ID_ins), .r1data(ID_data1), .r2data(ID_data2), .immediate(ID_imm), 
        .wdata(regWdata), .regw(WB_RegWrite), .waddr(WB_RegWriteAddr), 
        .MemRead(ID_MemRead), .MemWrite(ID_MemWrite), .ALUInB(ID_ALUInB), .ALUControl(ID_ALUControl), 
        .WriteDataMem(ID_WriteDataMem), .WriteDataPC(ID_WriteDataPC), .RegWrite(ID_RegWrite), .RegWriteAddr(ID_RegWriteAddr),
        .clk(clk), .rst(rst), .err(decodeErr), .nextPC(nextPC), .Halt(Halt), .PC_2(ID_PC));
    execute execute(.data1(EX_data1), .data2(EX_data2), .immediate(EX_imm), .ALUControl(EX_ALUControl), 
        .rtControl(EX_ALUInB), .err(executeErr), .out(EX_ALUOut));
    memory memory(.rdata(MEM_MemOut), .wdata(MEM_data2), .addr(MEM_ALUOut), .MemWrite(MEM_MemWrite), .MemRead(MEM_MemRead), 
        .createdump(Halt), .clk(clk), .rst(rst));
    wb wb(.MemData(WB_MemOut), .ALUData(WB_ALUOut), .PCData(WB_PC), .WriteDataMem(WB_WriteDataMem), .WriteDataPC(WB_WriteDataPC), .writeData(regWdata));

endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
