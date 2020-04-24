/*
   CS/ECE 552 Spring '20
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
module memory (out, wdata, ALUData, MemWrite, MemRead, PCData, WriteDataPC, WriteDataMem, createdump, clk, rst, MemErr);
    input clk, rst;
    input MemWrite, MemRead, createdump, WriteDataPC, WriteDataMem; // control signal
    input [15:0] wdata, ALUData, PCData;
    output [15:0] out;
    output MemErr;
    
    wire enable;
    wire [15:0] rdata;

    assign out = (WriteDataPC) ? PCData : ((WriteDataMem) ? rdata : ALUData);

    assign enable = MemRead | MemWrite;

    memory2c mem(.data_out(rdata), .data_in(wdata), .addr(ALUData), .enable(enable), .wr(MemWrite), 
        .createdump(createdump), .clk(clk), .rst(rst), .err(MemErr));
endmodule
