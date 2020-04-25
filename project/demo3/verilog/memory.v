/*
   CS/ECE 552 Spring '20
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
module memory (out, wdata, ALUData, MemWrite, MemRead, PCData, WriteDataPC, WriteDataMem, 
    createdump, clk, rst, MemErr, MemStall);
    input clk, rst;
    input MemWrite, MemRead, createdump, WriteDataPC, WriteDataMem; // control signal
    input [15:0] wdata, ALUData, PCData;
    output [15:0] out;
    output MemErr, MemStall;
    
    wire [15:0] rdata;

    assign out = (WriteDataPC) ? PCData : ((WriteDataMem) ? rdata : ALUData);

    mem_system #(1) mem(.DataOut(rdata), .DataIn(wdata), .Addr(ALUData), .Rd(MemRead), .Wr(MemWrite), .createdump(createdump), 
        .clk(clk), .rst(rst), .err(MemErr), .Done(), .Stall(MemStall), .CacheHit());
endmodule
