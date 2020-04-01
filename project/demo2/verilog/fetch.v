/*
   CS/ECE 552 Spring '20
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (halt, updatedPC, ins, clk, rst, PC_2);
    input clk, rst;
    input halt;
    input [15:0] updatedPC;
    output [15:0] ins, PC_2;

    wire [15:0] addr, newPC;

    assign newPC = (halt) ? addr : updatedPC; // if halt, don't update PC

    cla_16b add_PC(.A(addr), .B(16'h2), .C_in(1'b0), .S(PC_2), .C_out());

    memory2c insMem(.data_out(ins), .data_in(15'b0), .addr(addr), .enable(1'b1), .wr(1'b0), 
        .createdump(halt), .clk(clk), .rst(rst)); // only read and always enable
    dff PC[15:0](.d(newPC), .q(addr), .clk(clk), .rst(rst));
endmodule
