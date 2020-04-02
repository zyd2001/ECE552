/*
   CS/ECE 552 Spring '20
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
module memory (rdata, wdata, addr, MemWrite, MemRead, createdump, clk, rst);
    input clk, rst;
    input MemWrite, MemRead, createdump; // control signal
    input [15:0] rdata, wdata, addr;
    
    wire enable;

    assign enable = MemRead | MemWrite;

    memory2c mem(.data_out(rdata), .data_in(wdata), .addr(addr), .enable(enable), .wr(MemWrite), 
        .createdump(createdump), .clk(clk), .rst(rst));
endmodule
