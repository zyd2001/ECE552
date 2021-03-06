/*
   CS/ECE 552 Spring '20
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (halt, updatedPC, ins, clk, rst, PC_2, branch, stall, MemErr, MemStall);
    input clk, rst;
    input halt, branch, stall;
    input [15:0] updatedPC;
    output [15:0] ins, PC_2;
    output MemErr, MemStall;

    wire [15:0] addr, newPC, i;

    assign newPC = (stall | halt) ? addr : ((branch) ? updatedPC : PC_2); // if stall, don't update PC
    assign ins = (halt) ? 16'h0000 : ((branch) ? 16'h0800 : i); // if halt repeat halt, flush the ins if branch

    cla_16b add_PC(.A(addr), .B(16'h2), .C_in(1'b0), .S(PC_2), .C_out());
   
    mem_system #(0) insMem(.DataOut(i), .DataIn(16'b0), .Addr(addr), .Rd(1'b1), .Wr(1'b0), .createdump(halt), 
        .clk(clk), .rst(rst), .err(MemErr), .Done(), .Stall(MemStall), .CacheHit()); // always read
    dff PC[15:0](.d(newPC), .q(addr), .clk(clk), .rst(rst));
endmodule
