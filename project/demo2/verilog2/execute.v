/*
   CS/ECE 552 Spring '20
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
module execute (data1, data2, immediate, ALUControl, rtControl, out, err);
    input [15:0] data1, data2, immediate;
    input [3:0] ALUControl;
    input rtControl;
    output [15:0] out;
    output err;

    wire [15:0] inB;

    assign inB = (rtControl) ? data2 : immediate;
    alu ALU(.InA(data1), .InB(inB), .Op(ALUControl), .Out(out), .err(err));
endmodule
