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
    wire Halt, MemRead, MemWrite, ALUInB, WriteDataMem, WriteDataPC;
    wire decodeErr, executeErr;
    wire [3:0] ALUControl;
    wire [15:0] ins, PC, regData1, regData2, imm, ALUOut, MemOut, PC_2, regWdata;

    assign err = decodeErr | executeErr;

    fetch fetch(.halt(Halt), .updatedPC(PC), .ins(ins), .clk(clk), .rst(rst), .PC_2(PC_2));
    decode decode(.ins(ins), .wdata(regWdata), .r1data(regData1), .r2data(regData2), .immediate(imm), 
        .MemRead(MemRead), .MemWrite(MemWrite), .ALUInB(ALUInB), .ALUControl(ALUControl), 
        .WriteDataMem(WriteDataMem), .WriteDataPC(WriteDataPC),
        .clk(clk), .rst(rst), .err(decodeErr), .nextPC(PC), .Halt(Halt), .PC_2(PC_2));
    execute execute(.data1(regData1), .data2(regData2), .immediate(imm), .ALUControl(ALUControl), 
        .rtControl(ALUInB), .err(executeErr), .out(ALUOut));
    memory memory(.rdata(MemOut), .wdata(regData2), .addr(ALUOut), .MemWrite(MemWrite), .MemRead(MemRead), 
        .createdump(Halt), .clk(clk), .rst(rst));
    wb wb(.MemData(MemOut), .ALUData(ALUOut), .PCData(PC), .WriteDataMem(WriteDataMem), .WriteDataPC(WriteDataPC), .writeData(regWdata));

endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
