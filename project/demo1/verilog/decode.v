/*
   CS/ECE 552 Spring '20
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
module decode (ins, wdata, r1data, r2data, immediate, MemRead, MemWrite, ALUInB, ALUControl, 
    WriteDataMem, WriteDataPC, clk, rst, err, nextPC, Halt, PC_2);
    input clk, rst;
    input [15:0] ins, PC_2;
    input [15:0] wdata; // data from WB stage
    output [15:0] r1data, r2data, immediate;
    output [15:0] nextPC;
    output [3:0] ALUControl;
    output MemRead, MemWrite, ALUInB, WriteDataMem, WriteDataPC, Halt; // control signals from control unit

    wire [15:0] immD, AddPCInA, AddPCInB, AddPCOut;
    wire [2:0] r1addr, r2addr, waddr;
    wire [1:0] waddrM; // selection inputs for 4 to 1 mux for reg write addr
    wire RegWrite;
    wire regErr, controlErr;
    wire sign, short; // selection input for 2 to 1 mux to choose which immediate
    wire jmp, br, jmux1, jmux2; // selction inputs for 2 to 1 mux that control PC update (Jump, Branch)

    assign r1addr = ins[10:8];
    assign r2addr = ins[7:5];
    assign err = regErr | controlErr;
    assign waddr = (waddrM[1]) ? ((waddrM[0]) ? 3'h7 : ins[4:2]) : ((waddrM[0]) ? ins[7:5] : ins[10:8]);
    assign immediate = (short) ? ((sign) ? {{11{ins[4]}}, ins[4:0]} : {11'b0, ins[4:0]}) : 
        ((sign) ? {{8{ins[7]}}, ins[7:0]} : {8'b0, ins[7:0]});

    assign immD = {5{ins[10]}, ins[10:0]};
    assign AddPCInA = (jmux1) ? immediate : immD;
    assign AddPCInB = (jmux2) ? r1data : PC_2;
    assign nextPC = (br | jmp) ? AddPCOut : PC_2;
    cla_16b addPC(.A(AddPCInA), .B(AddPCInB), .C_in(0), .S(AddPCOut), .C_out());

    control controlUnit(.ins(ins[15:11]), .insFunc(ins[1:0]), .RegWrite(RegWrite), .MemRead(MemRead), .MemWrite(MemWrite), 
        .RegWriteAddrSel(waddrM), .SignExtension(sign), .ShortImmediate(short), .Halt(halt),
        .Jump(jmp), .Branch(br), .NewPC(newPC), .ALUInB(ALUInB), .ALUControl(ALUControl), 
        .WriteDataMem(WriteDataMem), .WriteDataPC(WriteDataPC), .err(controlErr), .JMux1(jmux1), .JMux2(jmux2));
    RegFile regFile(.read1Data(r1data), .read2Data(r2data), .err(regErr), .clk(clk), .rst(rst), 
        .read1RegSel(r1addr), .read2RegSel(r2addr), .writeRegSel(waddr), .writeData(wdata), .writeEn(RegWrite));
endmodule
