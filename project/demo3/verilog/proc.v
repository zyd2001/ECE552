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
    wire decodeErr, executeErr, IMemErr, DMemErr;
    wire branch; // branch flush
    wire [15:0] nextPC, WB_RegWriteData;
    wire [15:0] IF_PC, IF_ins;
    wire IF_Err;
    wire [15:0] ID_PC, ID_ins, ID_imm, ID_data1, ID_data2;
    wire [3:0] ID_ALUControl;
    wire [2:0] ID_RegWriteAddr, ID_r1addr, ID_r2addr;
    wire ID_ALUInB, ID_MemRead, ID_MemWrite, ID_WriteDataMem, ID_WriteDataPC, ID_RegWrite, 
        ID_Halt, ID_jmux1, ID_MW, ID_Err;
    wire [15:0] EX_imm, EX_data1, EX_data2, EX_ALUOut, EX_PC, EX_data2_M;
    wire [3:0] EX_ALUControl;
    wire [2:0] EX_RegWriteAddr, EX_r2addr;
    wire EX_ALUInB, EX_MemRead, EX_MemWrite, EX_WriteDataMem, EX_WriteDataPC, EX_RegWrite, EX_Halt, EX_Err;
    wire [15:0] MEM_data2, MEM_ALUOut, MEM_Out, MEM_PC;
    wire [2:0] MEM_RegWriteAddr;
    wire MEM_MemRead, MEM_MemWrite, MEM_WriteDataMem, MEM_WriteDataPC, MEM_RegWrite, MEM_Halt, MEM_Err;
    // wire [15:0] WB_MemOut, WB_ALUOut, WB_PC;
    wire [2:0] WB_RegWriteAddr;
    // wire WB_WriteDataMem, WB_WriteDataPC, WB_RegWrite, WB_Halt;
    wire WB_RegWrite, WB_Halt, WB_Err;

    wire stall, EX_EX_forward_1, EX_EX_forward_2, MEM_EX_forward_1, MEM_EX_forward_2, MEM_MEM_forward, EX_ID_forward;
    wire [15:0] data1, data2, EX_ID_forward_data;
    
    wire halt;
    wire IMemStall, DMemStall;

    assign err = WB_Err;
    assign IF_Err = IMemErr;
    assign halt = ID_Halt | IMemErr | decodeErr | executeErr | DMemErr;
    
    // forward logic
    assign EX_EX_forward_1 = EX_RegWrite & (ID_r1addr == EX_RegWriteAddr);
    assign EX_EX_forward_2 = EX_RegWrite & (ID_r2addr == EX_RegWriteAddr);
    assign MEM_EX_forward_1 = MEM_RegWrite & (ID_r1addr == MEM_RegWriteAddr);
    assign MEM_EX_forward_2 = MEM_RegWrite & (ID_r2addr == MEM_RegWriteAddr);
    assign MEM_MEM_forward = MEM_RegWrite & MEM_MemRead & EX_MemWrite & (EX_r2addr == MEM_RegWriteAddr);
    assign EX_ID_forward = MEM_RegWrite & ID_jmux1 & (ID_r1addr == MEM_RegWriteAddr);

    // forwarding path, EX to EX first
    // since jump always stall, no need to add PC to EX_EX path
    // but jal can forward to ID
    assign data1 = (EX_EX_forward_1) ? EX_ALUOut : ((MEM_EX_forward_1) ? MEM_Out : ID_data1); 
    assign data2 = (EX_EX_forward_2) ? EX_ALUOut : ((MEM_EX_forward_2) ? MEM_Out : ID_data2);
    assign EX_data2_M = (MEM_MEM_forward) ? MEM_Out : EX_data2;
    assign EX_ID_forward_data = (MEM_WriteDataPC) ? MEM_PC : MEM_ALUOut;

    assign stall = (EX_RegWrite & ((EX_MemRead & ((ID_r1addr == EX_RegWriteAddr) | (ID_r2addr == EX_RegWriteAddr))) // stall for ld
        | ((ID_r1addr == EX_RegWriteAddr) & ID_jmux1)) // stall for branch
        | (MEM_MemRead & MEM_RegWrite & (MEM_RegWriteAddr == ID_r1addr) & ID_jmux1) // if EX is ld, stall, no EX to ID forward
        & ~(EX_MemRead & ID_MW & (ID_r2addr == EX_RegWriteAddr))) // don't stall for st after ld when r2 is same
        | IMemStall | DMemStall; // stall for memory

    // IF/ID reg
    dffe IF_ID_insH[3:0](.q(ID_ins[15:12]), .d(IF_ins[15:12]), .en(~stall), .clk(clk), .rst(rst));
    dffre IF_ID_insR(.q(ID_ins[11]), .d(~IF_ins[11]), .en(~stall), .clk(clk), .rst(rst));
    dffe IF_ID_insL[10:0](.q(ID_ins[10:0]), .d(IF_ins[10:0]), .en(~stall), .clk(clk), .rst(rst));
    dffe IF_ID_PC[15:0](.q(ID_PC), .d(IF_PC), .en(~stall), .clk(clk), .rst(rst));
    dffe IF_ID_Err(.q(ID_Err), .d(IF_Err), .en(~stall), .clk(clk), .rst(rst));

    // ID/EX reg
    dffe ID_EX_imm[15:0](.q(EX_imm), .d(ID_imm), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe ID_EX_data1[15:0](.q(EX_data1), .d(data1), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe ID_EX_data2[15:0](.q(EX_data2), .d(data2), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe ID_EX_ALUControl[3:0](.q(EX_ALUControl), .d(ID_ALUControl), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe ID_EX_PC[15:0](.q(EX_PC), .d(ID_PC), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe ID_EX_r2addr[2:0](.q(EX_r2addr), .d(ID_r2addr), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe ID_EX_ALUInB(.q(EX_ALUInB), .d(ID_ALUInB), .en(~DMemStall), .clk(clk), .rst(rst)); // ALU input B selection signal
    dffe ID_EX_MemRead(.q(EX_MemRead), .d(ID_MemRead), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe ID_EX_MemWrite(.q(EX_MemWrite), .d(ID_MemWrite), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe ID_EX_WriteDataMem(.q(EX_WriteDataMem), .d(ID_WriteDataMem), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe ID_EX_WriteDataPC(.q(EX_WriteDataPC), .d(ID_WriteDataPC), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe ID_EX_Halt(.q(EX_Halt), .d(ID_Halt | ID_Err | decodeErr), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe ID_EX_RegWrite(.q(EX_RegWrite), .d(ID_RegWrite), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe ID_EX_RegWriteAddr[2:0](.q(EX_RegWriteAddr), .d(ID_RegWriteAddr), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe ID_EX_Err(.q(EX_Err), .d(ID_Err | decodeErr), .en(~DMemStall), .clk(clk), .rst(rst));

    // EX/MEM reg
    dffe EX_MEM_data2[15:0](.q(MEM_data2), .d(EX_data2_M), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe EX_MEM_ALUOut[15:0](.q(MEM_ALUOut), .d(EX_ALUOut), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe EX_MEM_PC[15:0](.q(MEM_PC), .d(EX_PC), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe EX_MEM_MemRead(.q(MEM_MemRead), .d(EX_MemRead), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe EX_MEM_MemWrite(.q(MEM_MemWrite), .d(EX_MemWrite), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe EX_MEM_WriteDataMem(.q(MEM_WriteDataMem), .d(EX_WriteDataMem), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe EX_MEM_WriteDataPC(.q(MEM_WriteDataPC), .d(EX_WriteDataPC), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe EX_MEM_Halt(.q(MEM_Halt), .d(EX_Halt | executeErr), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe EX_MEM_RegWrite(.q(MEM_RegWrite), .d(EX_RegWrite), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe EX_MEM_RegWriteAddr[2:0](.q(MEM_RegWriteAddr), .d(EX_RegWriteAddr), .en(~DMemStall), .clk(clk), .rst(rst));
    dffe EX_MEM_Err(.q(MEM_Err), .d(EX_Err | executeErr), .en(~DMemStall), .clk(clk), .rst(rst));

    // MEM/WB reg
    dff MEM_WB_Out[15:0](.q(WB_RegWriteData), .d(MEM_Out), .clk(clk), .rst(rst));
    dff MEM_WB_Halt(.q(WB_Halt), .d(MEM_Halt | DMemErr), .clk(clk), .rst(rst));
    dff MEM_WB_RegWrite(.q(WB_RegWrite), .d(MEM_RegWrite & ~DMemStall), .clk(clk), .rst(rst));
    dff MEM_WB_RegWriteAddr[2:0](.q(WB_RegWriteAddr), .d(MEM_RegWriteAddr), .clk(clk), .rst(rst));
    dff MEM_WB_Err(.q(WB_Err), .d(MEM_Err | DMemErr), .clk(clk), .rst(rst));

    fetch IF(.halt(halt), .updatedPC(nextPC), .ins(IF_ins), .clk(clk), .rst(rst), .PC_2(IF_PC), 
        .branch(branch), .stall(stall), .MemErr(IMemErr), .MemStall(IMemStall));
    decode ID(.ins(ID_ins), .r1data(ID_data1), .r2data(ID_data2), .immediate(ID_imm), 
        .wdata(WB_RegWriteData), .regw(WB_RegWrite), .waddr(WB_RegWriteAddr), 
        .MemRead(ID_MemRead), .MemWrite(ID_MemWrite), .ALUInB(ID_ALUInB), .ALUControl(ID_ALUControl), 
        .WriteDataMem(ID_WriteDataMem), .WriteDataPC(ID_WriteDataPC), .RegWrite(ID_RegWrite), .RegWriteAddr(ID_RegWriteAddr),
        .clk(clk), .rst(rst), .err(decodeErr), .nextPC(nextPC), .Halt(ID_Halt), .PC_2(ID_PC), 
        .r1addr(ID_r1addr), .r2addr(ID_r2addr), .MW(ID_MW), .jmux1(ID_jmux1),
        .branch(branch), .stall(stall), .EX_ID_forward(EX_ID_forward), .EX_ID_forward_data(EX_ID_forward_data));
    execute EX(.data1(EX_data1), .data2(EX_data2), .immediate(EX_imm), .ALUControl(EX_ALUControl), 
        .rtControl(EX_ALUInB), .err(executeErr), .out(EX_ALUOut));
    memory MEM(.out(MEM_Out), .wdata(MEM_data2), .ALUData(MEM_ALUOut), .PCData(MEM_PC), 
        .WriteDataPC(MEM_WriteDataPC), .WriteDataMem(MEM_WriteDataMem), .MemWrite(MEM_MemWrite), .MemRead(MEM_MemRead),
        .createdump(MEM_Halt), .clk(clk), .rst(rst), .MemErr(DMemErr), .MemStall(DMemStall));
    // wb WB(.MemData(WB_MemOut), .ALUData(WB_ALUOut), .PCData(WB_PC), .WriteDataMem(WB_WriteDataMem), .WriteDataPC(WB_WriteDataPC), .writeData(WB_RegWriteData));
    // don't need mux in wb module since put the mux in memory module for forwarding
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
