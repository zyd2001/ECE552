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
    wire decodeErr, executeErr;
    wire branch; // branch flush
    wire [15:0] nextPC, RegWriteData;
    wire [15:0] IF_PC, IF_ins;
    wire [15:0] ID_PC, ID_ins, ID_imm, ID_data1, ID_data2;
    wire [3:0] ID_ALUControl;
    wire [2:0] ID_RegWriteAddr;
    wire ID_ALUInB, ID_MemRead, ID_MemWrite, ID_WriteDataMem, ID_WriteDataPC, ID_RegWrite, ID_Halt;
    wire [15:0] EX_imm, EX_data1, EX_data2, EX_ALUOut, EX_PC, EX_data2_M;
    wire [3:0] EX_ALUControl;
    wire [2:0] EX_RegWriteAddr, EX_r2addr;
    wire EX_ALUInB, EX_MemRead, EX_MemWrite, EX_WriteDataMem, EX_WriteDataPC, EX_RegWrite, EX_Halt;
    wire [15:0] MEM_data2, MEM_ALUOut, MEM_Out, MEM_PC;
    wire [2:0] MEM_RegWriteAddr;
    wire MEM_MemRead, MEM_MemWrite, MEM_WriteDataMem, MEM_WriteDataPC, MEM_RegWrite, MEM_Halt;
    // wire [15:0] WB_MemOut, WB_ALUOut, WB_PC;
    wire [2:0] WB_RegWriteAddr;
    // wire WB_WriteDataMem, WB_WriteDataPC, WB_RegWrite, WB_Halt;
    wire WB_RegWrite, WB_Halt;

    wire stall, EX_EX_forward_1, EX_EX_forward_2, MEM_EX_forward_1, MEM_EX_forward_2, MEM_MEM_forward, EX_ID_forward;
    wire [15:0] data1, data2;

    assign err = decodeErr | executeErr;

    // forward logic
    assign EX_EX_forward_1 = EX_RegWrite & (ID.r1addr == EX_RegWriteAddr);
    assign EX_EX_forward_2 = EX_RegWrite & (ID.r2addr == EX_RegWriteAddr);
    assign MEM_EX_forward_1 = MEM_RegWrite & (ID.r1addr == MEM_RegWriteAddr);
    assign MEM_EX_forward_2 = MEM_RegWrite & (ID.r2addr == MEM_RegWriteAddr);
    assign MEM_MEM_forward = MEM_RegWrite & MEM_MemRead & EX_MemWrite & (EX_r2addr == MEM_RegWriteAddr);
    assign EX_ID_forward = MEM_RegWrite & ID.jmux1 & (ID.r1addr == MEM_RegWriteAddr);

    // forwarding path, EX to EX first
    assign data1 = (EX_EX_forward_1) ? EX_ALUOut : ((MEM_EX_forward_1) ? MEM_Out : ID_data1);
    assign data2 = (EX_EX_forward_2) ? EX_ALUOut : ((MEM_EX_forward_2) ? MEM_Out : ID_data2);
    assign EX_data2_M = (MEM_MEM_forward) ? MEM_Out : EX_data2;

    assign stall = EX_RegWrite & ((EX_MemRead & ((ID.r1addr == EX_RegWriteAddr) | (ID.r2addr == EX_RegWriteAddr)))
        | ((ID.r1addr == EX_RegWriteAddr) & ID.jmux1)) // stall for branch
        & ~(EX_MemRead & ID.MW & (ID.r2addr == EX_RegWriteAddr)); // don't stall for st after ld when r2 is same

    // IF/ID reg
    dffe IF_ID_ins[15:0](.q(ID_ins), .d(IF_ins), .en(~stall), .clk(clk), .rst(rst));
    dffe IF_ID_PC[15:0](.q(ID_PC), .d(IF_PC), .en(~stall), .clk(clk), .rst(rst));

    // ID/EX reg
    dff ID_EX_imm[15:0](.q(EX_imm), .d(ID_imm), .clk(clk), .rst(rst));
    dff ID_EX_data1[15:0](.q(EX_data1), .d(data1), .clk(clk), .rst(rst));
    dff ID_EX_data2[15:0](.q(EX_data2), .d(data2), .clk(clk), .rst(rst));
    dff ID_EX_ALUControl[3:0](.q(EX_ALUControl), .d(ID_ALUControl), .clk(clk), .rst(rst));
    dff ID_EX_PC[15:0](.q(EX_PC), .d(ID_PC), .clk(clk), .rst(rst));
    dff ID_EX_r2addr[2:0](.q(EX_r2addr), .d(ID.r2addr), .clk(clk), .rst(rst));
    dff ID_EX_ALUInB(.q(EX_ALUInB), .d(ID_ALUInB), .clk(clk), .rst(rst)); // ALU input B selection signal
    dff ID_EX_MemRead(.q(EX_MemRead), .d(ID_MemRead), .clk(clk), .rst(rst));
    dff ID_EX_MemWrite(.q(EX_MemWrite), .d(ID_MemWrite), .clk(clk), .rst(rst));
    dff ID_EX_WriteDataMem(.q(EX_WriteDataMem), .d(ID_WriteDataMem), .clk(clk), .rst(rst));
    dff ID_EX_WriteDataPC(.q(EX_WriteDataPC), .d(ID_WriteDataPC), .clk(clk), .rst(rst));
    dff ID_EX_Halt(.q(EX_Halt), .d(ID_Halt), .clk(clk), .rst(rst));
    dff ID_EX_RegWrite(.q(EX_RegWrite), .d(ID_RegWrite), .clk(clk), .rst(rst));
    dff ID_EX_RegWriteAddr[2:0](.q(EX_RegWriteAddr), .d(ID_RegWriteAddr), .clk(clk), .rst(rst));

    // EX/MEM reg
    dff EX_MEM_data2[15:0](.q(MEM_data2), .d(EX_data2_M), .clk(clk), .rst(rst));
    dff EX_MEM_ALUOut[15:0](.q(MEM_ALUOut), .d(EX_ALUOut), .clk(clk), .rst(rst));
    dff EX_MEM_PC[15:0](.q(MEM_PC), .d(EX_PC), .clk(clk), .rst(rst));
    dff EX_MEM_MemRead(.q(MEM_MemRead), .d(EX_MemRead), .clk(clk), .rst(rst));
    dff EX_MEM_MemWrite(.q(MEM_MemWrite), .d(EX_MemWrite), .clk(clk), .rst(rst));
    dff EX_MEM_WriteDataMem(.q(MEM_WriteDataMem), .d(EX_WriteDataMem), .clk(clk), .rst(rst));
    dff EX_MEM_WriteDataPC(.q(MEM_WriteDataPC), .d(EX_WriteDataPC), .clk(clk), .rst(rst));
    dff EX_MEM_Halt(.q(MEM_Halt), .d(EX_Halt), .clk(clk), .rst(rst));
    dff EX_MEM_RegWrite(.q(MEM_RegWrite), .d(EX_RegWrite), .clk(clk), .rst(rst));
    dff EX_MEM_RegWriteAddr[2:0](.q(MEM_RegWriteAddr), .d(EX_RegWriteAddr), .clk(clk), .rst(rst));

    // MEM/WB reg
    dff MEM_WB_Out[15:0](.q(RegWriteData), .d(MEM_Out), .clk(clk), .rst(rst));
    // dff MEM_WB_ALUOut[15:0](.q(WB_ALUOut), .d(MEM_ALUOut), .clk(clk), .rst(rst));
    // dff MEM_WB_MemOut[15:0](.q(WB_MemOut), .d(MEM_MemOut), .clk(clk), .rst(rst));
    // dff MEM_WB_PC[15:0](.q(WB_PC), .d(MEM_PC), .clk(clk), .rst(rst));
    // dff MEM_WB_WriteDataMem(.q(WB_WriteDataMem), .d(MEM_WriteDataMem), .clk(clk), .rst(rst));
    // dff MEM_WB_WriteDataPC(.q(WB_WriteDataPC), .d(MEM_WriteDataPC), .clk(clk), .rst(rst));
    dff MEM_WB_Halt(.q(WB_Halt), .d(MEM_Halt), .clk(clk), .rst(rst));
    dff MEM_WB_RegWrite(.q(WB_RegWrite), .d(MEM_RegWrite), .clk(clk), .rst(rst));
    dff MEM_WB_RegWriteAddr[2:0](.q(WB_RegWriteAddr), .d(MEM_RegWriteAddr), .clk(clk), .rst(rst));

    fetch IF(.halt(ID_Halt), .updatedPC(nextPC), .ins(IF_ins), .clk(clk), .rst(rst), .PC_2(IF_PC), .branch(branch), .stall(stall));
    decode ID(.ins(ID_ins), .r1data(ID_data1), .r2data(ID_data2), .immediate(ID_imm), 
        .wdata(RegWriteData), .regw(WB_RegWrite), .waddr(WB_RegWriteAddr), 
        .MemRead(ID_MemRead), .MemWrite(ID_MemWrite), .ALUInB(ID_ALUInB), .ALUControl(ID_ALUControl), 
        .WriteDataMem(ID_WriteDataMem), .WriteDataPC(ID_WriteDataPC), .RegWrite(ID_RegWrite), .RegWriteAddr(ID_RegWriteAddr),
        .clk(clk), .rst(rst), .err(decodeErr), .nextPC(nextPC), .Halt(ID_Halt), .PC_2(ID_PC), 
        .branch(branch), .stall(stall), .EX_ID_forward(EX_ID_forward), .EX_ID_forward_data(MEM_Out));
    execute EX(.data1(EX_data1), .data2(EX_data2), .immediate(EX_imm), .ALUControl(EX_ALUControl), 
        .rtControl(EX_ALUInB), .err(executeErr), .out(EX_ALUOut));
    memory MEM(.out(MEM_Out), .wdata(MEM_data2), .ALUData(MEM_ALUOut), .PCData(MEM_PC), .WriteDataPC(MEM_WriteDataPC), .WriteDataMem(MEM_WriteDataMem), 
        .MemWrite(MEM_MemWrite), .MemRead(MEM_MemRead), .createdump(MEM_Halt), .clk(clk), .rst(rst));
    // wb WB(.MemData(WB_MemOut), .ALUData(WB_ALUOut), .PCData(WB_PC), .WriteDataMem(WB_WriteDataMem), .WriteDataPC(WB_WriteDataPC), .writeData(RegWriteData));

endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
