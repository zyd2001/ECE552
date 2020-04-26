/*
   CS/ECE 552 Spring '20
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
module decode (ins, wdata, regw, waddr, r1data, r2data, immediate, MemRead, MemWrite, ALUInB, ALUControl, 
    WriteDataMem, WriteDataPC, RegWrite, RegWriteAddr, clk, rst, err, nextPC, Halt, PC_2, branch, 
    stall, EX_ID_forward, EX_ID_forward_data, MW, jmux1, r1addr, r2addr);
    input clk, rst;
    input regw;
    input stall, EX_ID_forward;
    input [2:0] waddr;
    input [15:0] ins, PC_2;
    input [15:0] wdata; // data from WB stage
    input [15:0] EX_ID_forward_data;
    output [15:0] r1data, r2data, immediate;
    output [15:0] nextPC;
    output [3:0] ALUControl;
    output [2:0] RegWriteAddr, r1addr, r2addr;
    output MemRead, MemWrite, ALUInB, WriteDataMem, WriteDataPC, RegWrite, Halt, branch, MW, jmux1; // control signals from control unit
    output err;

    wire [15:0] immD, AddPCInA, AddPCInB, r1d, addedPC;
    wire [15:0] ePC;
    wire [1:0] waddrM; // selection inputs for 4 to 1 mux for reg write addr
    wire regErr;
    wire exception, RTI;
    wire sign, short; // selection input for 2 to 1 mux to choose which immediate
    wire jmp, br, jmux2, zero; // selction inputs for 2 to 1 mux that control PC update (Jump, Branch)
    wire RW, MR; // original MemRead, MemWrite, RegWrite signal
    reg doBranch, branchErr;

    assign RegWrite = ~stall & RW;
    assign MemRead = ~stall & MR;
    assign MemWrite = ~stall & MW;

    assign r1data = (EX_ID_forward) ? EX_ID_forward_data : r1d;

    assign RegWriteAddr = (waddrM[1]) ? ((waddrM[0]) ? 3'h7 : ins[4:2]) : ((waddrM[0]) ? ins[7:5] : ins[10:8]);
    assign r1addr = ins[10:8];
    assign r2addr = ins[7:5];
    assign err = regErr | branchErr;
    assign immediate = (short) ? ((sign) ? {{11{ins[4]}}, ins[4:0]} : {11'b0, ins[4:0]}) : 
        ((sign) ? {{8{ins[7]}}, ins[7:0]} : {8'b0, ins[7:0]});

    assign immD = {{5{ins[10]}}, ins[10:0]};
    assign AddPCInA = (jmux1) ? immediate : immD;
    assign AddPCInB = (jmux2) ? r1data : PC_2;
    assign nextPC = (exception) ? 16'h02 : ((RTI) ? ePC : addedPC);
    assign branch = (doBranch & br) | jmp;
    assign zero = ~|r1data;
    cla_16b addPC(.A(AddPCInA), .B(AddPCInB), .C_in(1'b0), .S(addedPC), .C_out());

    always @* begin
        doBranch = 0; branchErr = 0;
        case (ins[12:11]) 
            2'b00: doBranch = zero; 
            2'b01: doBranch = ~zero;
            2'b10: doBranch = r1data[15];
            2'b11: doBranch = ~r1data[15] | zero;
            default: branchErr = 1;
        endcase
    end

    dffe EPC[15:0](.q(ePC), .d(PC_2), .en(exception), .clk(clk), .rst(rst));

    control controlUnit(.ins(ins[15:11]), .insFunc(ins[1:0]), .RegWrite(RW), .MemRead(MR), .MemWrite(MW), 
        .RegWriteAddrSel(waddrM), .SignExtension(sign), .ShortImmediate(short), .Halt(Halt),
        .Jump(jmp), .Branch(br), .ALUInB(ALUInB), .ALUControl(ALUControl), .exception(exception), .RTI(RTI),
        .WriteDataMem(WriteDataMem), .WriteDataPC(WriteDataPC), .JMux1(jmux1), .JMux2(jmux2));
    regFile_bypass regFile(.read1Data(r1d), .read2Data(r2data), .err(regErr), .clk(clk), .rst(rst), 
        .read1RegSel(r1addr), .read2RegSel(r2addr), .writeRegSel(waddr), .writeData(wdata), .writeEn(regw));
endmodule
